import 'package:mujslcm/features/marks/data/marks_repository.dart';

import 'package:flutter/material.dart';
import 'package:mujslcm/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class Marks extends StatefulWidget {
  const Marks({super.key});

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

    try {
      final data = await MarksRepository.fetchMarks(selectedSemester!);
      setState(() {
        marksData = data;
        isLoading = false;
      });
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Marks Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: AppColors.surface,
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: selectedSemester,
                  hint: const Text('Select Semester',
                      style: TextStyle(color: Colors.white)),
                  dropdownColor: AppColors.background,
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
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent))),
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
                      double maxMarks = 100;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFA3C78F).withOpacity(0.125),
                            borderRadius: BorderRadius.circular(25),
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
                                              color: AppColors.accent)),
                                    if (course['MTE1'] != "-")
                                      Text('MTE1: ${course['MTE1']}',
                                          style: const TextStyle(
                                              color: AppColors.accent)),
                                    if (course['MTE2'] != "-")
                                      Text('MTE2: ${course['MTE2']}',
                                          style: const TextStyle(
                                              color: AppColors.accent)),
                                    if (course['RESESSION'] != "-")
                                      Text('Ressional: ${course['RESESSION']}',
                                          style: const TextStyle(
                                              color: AppColors.accent)),
                                    if (course['PRS'] != "-")
                                      Text('PRS: ${course['PRS']}',
                                          style: const TextStyle(
                                              color: AppColors.accent)),
                                    if (course['ETE'] != "-")
                                      Text('ETE: ${course['ETE']}',
                                          style: const TextStyle(
                                              color: AppColors.accent)),
                                    if (course['Total'] != "-")
                                      Text('Total: ${course['Total']}/100',
                                          style: const TextStyle(
                                              color: AppColors.accent)),
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
