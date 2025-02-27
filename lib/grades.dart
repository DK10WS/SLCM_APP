import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Grades extends StatefulWidget {
  final String newCookies;

  const Grades({super.key, required this.newCookies});

  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  Map<String, dynamic>? gradesData;
  bool isLoading = false;
  String errorMessage = '';
  String? selectedSemester;

  Future<void> fetchGrades() async {
    if (selectedSemester == null) return;

    setState(() {
      isLoading = true;
    });

    final url = "http://127.0.0.1:3000/grades";

    final Map<String, String> headers = {
      "Cookie": widget.newCookies,
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    };

    final Map<String, String> body = {"Semester": selectedSemester!};

    try {
      final session = http.Client();
      var response = await session.post(Uri.parse(url), body: body);
      session.close();

      if (response.statusCode == 200) {
        setState(() {
          gradesData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch grades');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching grades: $e';
      });
    }
  }

  Color getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Color(0xFF6EEB83);
      case 'S':
        return Color(0xFFAB87FF);
      case 'A+':
        return Color(0xFF1BE7FF);
      case 'B':
      case 'B+':
        return Colors.yellow;
      case 'C':
      case 'C+':
        return Colors.orange;
      case 'D':
      case 'E':
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        title: Text(
          "Grades",
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
                      gradesData = null;
                      isLoading = false;
                    });
                    fetchGrades();
                  },
                ),
              ),
            ),
            if (selectedSemester == null)
              const Expanded(
                child: Center(
                  child: Text('Please select a semester to view grades',
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
              if (gradesData == null ||
                  gradesData!['InternalMarksList'] == null ||
                  gradesData!['InternalMarksList'].isEmpty)
                const Expanded(
                  child: Center(
                      child: Text('No data available for this semester',
                          style: TextStyle(color: Colors.white))),
                ),
              if (gradesData != null &&
                  gradesData!['InternalMarksList'] != null &&
                  gradesData!['InternalMarksList'].isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: gradesData!['InternalMarksList'].length,
                    itemBuilder: (context, index) {
                      var course = gradesData!['InternalMarksList'][index];
                      String courseName =
                          course['CourseID'] ?? 'No Course Name';
                      String grade = course['Grade'] ?? 'No Grade';
                      String credits = course['Credits'] ?? 'No Credits';

                      if (courseName.isEmpty || courseName == 'Total') {
                        return const SizedBox.shrink();
                      } else {
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
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: getGradeColor(grade),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      grade,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        courseName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Credits: $credits',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
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
