import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Marks extends StatefulWidget {
  final String newCookies;

  const Marks({super.key, required this.newCookies});

  @override
  _MarksState createState() => _MarksState();
}

class _MarksState extends State<Marks> {
  List<Map<String, dynamic>> marksData = [];
  bool isLoading = false;
  String? errorMessage;
  String? selectedSemester;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchMarksData() async {
    if (selectedSemester == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> courses =
          await parseMarks(widget.newCookies, selectedSemester!);

      setState(() {
        marksData = courses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching marks: $e';
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> parseMarks(
      String newCookies, String semester) async {
    final Map<String, String> headers = {
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Cookie': newCookies,
      'User-Agent': 'Mozilla/5.0',
    };

    final Map<String, String> body = {"Enrollment": "", "Semester": semester};

    final url =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetInternalMarkForFaculty";

    var session = http.Client();

    try {
      var response =
          await session.post(Uri.parse(url), headers: headers, body: body);

      List<dynamic> marksList = jsonDecode(response.body)["InternalMarksList"];
      List<Map<String, dynamic>> courses = marksList.map((course) {
        return {
          'CourseID': course['CourseID'],
          'CourseName': course['CourseName'] ?? 'N/A',
          'CWS': course['CWS'],
          'MTE1': course['MTE1'],
          'MTE2': course['MTE2'] ?? 'N/A',
          'Ressional': course["RESESSION"] ?? 'N/A',
          'Total': course['Total'],
        };
      }).toList();

      return courses;
    } catch (e) {
      print("Error fetching marks: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Marks Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedSemester,
                hint: const Text('Select Semester',
                    style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
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
                    fetchMarksData();
                  });
                },
              ),
            ),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            if (!isLoading && errorMessage == null && marksData.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No data available for this semester',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            if (!isLoading && marksData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: marksData.length,
                  itemBuilder: (context, index) {
                    final course = marksData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      elevation: 3,
                      color: Colors.cyan,
                      child: ListTile(
                        title: Text('Course: ${course['CourseID']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "poppins",
                                fontSize: 20)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CWS: ${course['CWS']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('MTE1: ${course['MTE1']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('MTE2: ${course['MTE2']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Ressional: ${course['Ressional']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Total: ${course['Total']}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
