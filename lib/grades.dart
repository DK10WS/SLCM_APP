import 'dart:convert'; // Import for JSON decoding
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

    final url =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetGradesForFaculty";

    final Map<String, String> headers = {
      "Accept": "application/json, text/javascript, */*; q=0.01",
      "Accept-Encoding": "gzip, deflate, br, zstd",
      "Accept-Language": "en-US,en;q=0.8",
      "Connection": "keep-alive",
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "Cookie": widget.newCookies,
      "Host": "mujslcm.jaipur.manipal.edu:122",
      "Origin": "https://mujslcm.jaipur.manipal.edu:122",
      "Referer":
          "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GradesForStudent",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "same-origin",
      "Sec-GPC": "1",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "X-Requested-With": "XMLHttpRequest",
      "sec-ch-ua": '"Brave";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": '"Windows"',
    };

    final Map<String, String> body = {
      "Enrollment": "",
      "Semester": selectedSemester!
    };

    try {
      final session = http.Client();
      var response =
          await session.post(Uri.parse(url), headers: headers, body: body);
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grades',
          style: TextStyle(color: Colors.white),
        ),
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
                hint: Text('Select Semester',
                    style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                items: ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII']
                    .map((semester) => DropdownMenuItem<String>(
                          value: semester,
                          child: Text('Semester $semester',
                              style: TextStyle(color: Colors.white)),
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
                        style: TextStyle(color: Colors.white))),
              if (gradesData == null ||
                  gradesData!['InternalMarksList'] == null ||
                  gradesData!['InternalMarksList'].isEmpty)
                const Expanded(
                  child: Center(
                      child: Text('No data available for this semester',
                          style: TextStyle(color: Colors.black))),
                ),
              if (gradesData != null &&
                  gradesData!['InternalMarksList'] != null &&
                  gradesData!['InternalMarksList'].isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: gradesData!['InternalMarksList'].length +
                        1, // Adding 1 for the Total Credits
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "Total Credits" box
                        double totalCredits = gradesData!['InternalMarksList']
                            .fold(0, (sum, course) {
                          return sum +
                              (double.tryParse(course['Credits'].toString()) ??
                                  0);
                        });

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          elevation: 3,
                          color: Colors.cyan,
                          child: Container(
                            width: screenWidth * 0.9,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(
                                'Total Credits',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Credits: $totalCredits',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }

                      // Course information
                      var course = gradesData!['InternalMarksList'][index - 1];

                      String courseName =
                          course['CourseID'] ?? 'No Course Name';
                      String grade = course['Grade'] ?? 'No Grade';
                      String credits = course['Credits'] ?? 'No Credits';

                      if (courseName.isEmpty || courseName == 'Total') {
                        return SizedBox.shrink();
                      } else {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          elevation: 3,
                          color: Colors.cyan,
                          child: Container(
                            width: screenWidth * 0.9,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(
                                courseName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grade: $grade',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  Text(
                                    'Credits: $credits',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ],
                              ),
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
