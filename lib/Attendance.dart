import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class AttendancePage extends StatefulWidget {
  final String newCookies;

  const AttendancePage({Key? key, required this.newCookies}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<Map<String, dynamic>>?> _attendanceData;

  @override
  void initState() {
    super.initState();
    _attendanceData = fetchAttendance(widget.newCookies);
  }

  Future<List<Map<String, dynamic>>?> fetchAttendance(String newCookies) async {
    final Map<String, String> headers = {
      "User-Agent":
          "Mozilla/5.0 (X11; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0",
      "Cookie": newCookies,
    };

    final Map<String, String> body = {"StudentCode": ""};

    const attendanceUrl =
        "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetAttendanceSummaryList";

    final session = http.Client();
    final response = await session.post(Uri.parse(attendanceUrl),
        headers: headers, body: body);

    if (response.statusCode != 200) {
      print('Failed to load attendance data');
      return null;
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> attendanceList = decoded["AttendanceSummaryList"];

    List<Map<String, dynamic>> attendanceData = [];

    for (var record in attendanceList) {
      String fullName = record["CourseID"] ?? "Unknown Subject";
      String percentage = record["Percentage"] ?? "0";
      int newpercentage = int.tryParse(record["Percentage"] ?? "0%") ?? 0;

      String courseCode = fullName.split(":").length > 1
          ? fullName.split(":")[0].trim()
          : "Unknown Code";

      String subjectName = fullName.split(":").length > 1
          ? fullName.split(":")[1].trim()
          : fullName;

      int totalClasses = int.tryParse(record["Total"] ?? "0") ?? 0;
      int attendedClasses = int.tryParse(record["Present"] ?? "0") ?? 0;
      int missedClasses = totalClasses - attendedClasses;

      String statusMessage;
      int? classesNeeded;
      if (newpercentage < 75) {
        classesNeeded =
            ((0.75 * totalClasses - attendedClasses) / (1 - 0.75)).ceil();
        statusMessage = "$classesNeeded more classes needed to reach 75%.";
      } else {
        statusMessage = "Good! Your attendance is above or equal to 75%.";
        classesNeeded = null;
      }

      attendanceData.add({
        "courseCode": courseCode,
        "subject": subjectName,
        "percentage": percentage,
        "attendedClasses": attendedClasses,
        "missedClasses": missedClasses,
        "totalClasses": totalClasses,
        "statusMessage": statusMessage,
        "classesNeeded": classesNeeded,
      });
    }

    session.close();
    return attendanceData;
  }

  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
        backgroundColor: const Color(0xFF121316),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121316),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Attendance Summary',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0), // Add padding from the top
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF232531), // Background color of the body
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0), // Rounded top-left corner
                topRight: Radius.circular(20.0), // Rounded top-right corner
              ),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              future: _attendanceData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.cyan),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No attendance data available',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final attendanceList = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: attendanceList.length,
                      itemBuilder: (context, index) {
                        final attendance = attendanceList[index];
                        final subject = attendance["subject"];
                        final percentage = attendance["percentage"];
                        final attendedClasses = attendance["attendedClasses"];
                        final missedClasses = attendance["missedClasses"];
                        final totalClasses = attendance["totalClasses"];
                        final courseCode = attendance["courseCode"];

                        double attendedPercentage =
                            attendedClasses / totalClasses;
                        double missedPercentage = missedClasses / totalClasses;

                        return Container(
                          width: boxWidth,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Color(0xFF232531),
                                  title: Text(
                                    subject,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Course Code: $courseCode",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "Attendance: $percentage %",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "Attended Classes: $attendedClasses",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "Missed Classes: $missedClasses",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      if (attendance["classesNeeded"] != null)
                                        Text(
                                          "Status: ${attendance["statusMessage"]}",
                                          style: const TextStyle(
                                              color: Colors.red),
                                        )
                                      else
                                        Text(
                                          "Status: ${attendance["statusMessage"]}",
                                          style: const TextStyle(
                                              color: Colors.green),
                                        ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(color: Colors.cyan),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        "Attended: $attendedClasses | Missed Classes: $missedClasses ",
                                        style: const TextStyle(
                                          color: Colors.cyan,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                              value: attendedPercentage * 100,
                                              color: Colors.green,
                                              showTitle: false,
                                              radius: 45,
                                            ),
                                            PieChartSectionData(
                                              value: missedPercentage * 100,
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
                                        '$percentage%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ));
  }
}
