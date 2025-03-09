import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class Marks extends StatefulWidget {
  final String newCookies;

  const Marks({super.key, required this.newCookies});

  @override
  _MarksState createState() => _MarksState();
}

class _MarksState extends State<Marks> {
  List<Map<String, dynamic>> marksData = [];
  bool isLoading = false;
  String errorMessage = '';
  String? selectedSemester;

  Future<void> fetchMarksData() async {
    if (selectedSemester == null) return;

    setState(() {
      isLoading = true;
    });
    final Map<String, String> header = {
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
      "Content-Type": "application/json",
    };
    final url =
        "http://34.131.23.80:8000/internal_marks?semester=$selectedSemester";

    final Map<String, String> body = {"login_cookies": widget.newCookies};

    try {
      final session = http.Client();
      var response = await session.post(Uri.parse(url),
          body: jsonEncode(body), headers: header);
      session.close();

      if (response.statusCode == 200) {
        setState(() {
          marksData = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)["InternalMarksList"]);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch marks');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching marks: $e';
      });
    }
  }

  Color getGradeColor(double total) {
    return total >= 50 ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        title: Text(
          "Marks Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121316),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color(0xFF232531),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: screenWidth * 0.90,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF121316),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: selectedSemester,
                  hint: const Text('Select Semester',
                      style: TextStyle(color: Colors.white)),
                  dropdownColor: const Color(0xFF121316),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  isExpanded: true,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(30),
                  items: ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII']
                      .map((semester) => DropdownMenuItem<String>(
                            value: semester,
                            child: Text('Semester $semester',
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSemester = value;
                      marksData = [];
                      isLoading = false;
                    });
                    fetchMarksData();
                  },
                ),
              ),
            ),
            if (selectedSemester == null)
              const Expanded(
                child: Center(
                  child: Text('Please select a semester to view marks',
                      style: TextStyle(color: Colors.white)),
                ),
              )
            else ...[
              if (isLoading && selectedSemester != null)
                const Expanded(
                    child: Center(child: CircularProgressIndicator())),
              if (errorMessage.isNotEmpty)
                Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.white))),
              if (marksData.isEmpty)
                const Expanded(
                  child: Center(
                      child: Text('No data available for this semester',
                          style: TextStyle(color: Colors.white))),
                ),
              if (marksData.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: marksData.length,
                    itemBuilder: (context, index) {
                      var course = marksData[index];
                      String courseName = course['CourseID'];
                      double total = course['Total'] != "-"
                          ? double.parse(course['Total'].toString())
                          : 0.0;
                      double maxMarks = 60;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          width: screenWidth * 0.95,
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sectionsSpace: 0,
                                        borderData: FlBorderData(show: false),
                                        sections: [
                                          PieChartSectionData(
                                            value: total / maxMarks * 100,
                                            color: Colors.green,
                                            showTitle: false,
                                            radius: 45,
                                          ),
                                          PieChartSectionData(
                                            value:
                                                100 - (total / maxMarks * 100),
                                            color: Colors.red,
                                            showTitle: false,
                                            radius: 45,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      total != 0
                                          ? '${total.toStringAsFixed(1)}'
                                          : "N/A",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8.0),
                                    Text('Course: $courseName',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                    const SizedBox(height: 8.0),
                                    if (course['CWS'] != "-")
                                      Text('CWS: ${course['CWS']}',
                                          style: const TextStyle(
                                              color: Colors.cyan)),
                                    if (course['MTE1'] != "-")
                                      Text('MTE1: ${course['MTE1']}',
                                          style: const TextStyle(
                                              color: Colors.cyan)),
                                    if (course['MTE2'] != "-")
                                      Text('MTE2: ${course['MTE2']}',
                                          style: const TextStyle(
                                              color: Colors.cyan)),
                                    if (course['RESESSION'] != "-")
                                      Text('Ressional: ${course['RESESSION']}',
                                          style: const TextStyle(
                                              color: Colors.cyan)),
                                    if (course['PRS'] != "-")
                                      Text('PRS: ${course['PRS']}',
                                          style: const TextStyle(
                                              color: Colors.cyan)),
                                    if (course['Total'] != "-")
                                      Text('Total: ${course['Total']}/60',
                                          style: const TextStyle(
                                              color: Colors.cyan)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
