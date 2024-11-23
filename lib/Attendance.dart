import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      "Host": "mujslcm.jaipur.manipal.edu:122",
      "User-Agent":
          "Mozilla/5.0 (X11; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0",
      "Cookie": newCookies,
      "Accept": "application/json, text/javascript, */*; q=0.01",
      "Accept-Language": "en-US,en;q=0.5",
      "Accept-Encoding": "gzip, deflate, br, zstd",
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "X-Requested-With": "XMLHttpRequest",
      "Origin": "https://mujslcm.jaipur.manipal.edu:122",
      "DNT": "1",
      "Referer":
          "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/AttendanceSummaryForStudent",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "same-origin",
    };

    final Map<String, String> body = {"StudentCode": ""};

    const attendanceUrl =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetAttendanceSummaryList";

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
      String percentage = record["Percentage"] ?? "0%";

      // Split subject and course code
      String courseCode = fullName.split(":").length > 1
          ? fullName.split(":")[0].trim()
          : "Unknown Code";

      String subjectName = fullName.split(":").length > 1
          ? fullName.split(":")[1].trim()
          : fullName;

      // Calculate attended and missed classes based on the available data
      int totalClasses = int.tryParse(record["TotalClasses"] ?? "0") ?? 0;
      int attendedClasses = int.tryParse(record["Present"] ?? "0") ?? 0;
      int missedClasses = totalClasses - attendedClasses;

      attendanceData.add({
        "courseCode": courseCode,
        "subject": subjectName,
        "percentage": percentage,
        "attendedClasses": attendedClasses,
        "missedClasses": missedClasses,
        "totalClasses": totalClasses,
      });
    }

    session.close();
    return attendanceData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        // Load attendance data
        future: _attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance data available'));
          } else {
            final attendanceList = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: DataTable(
                      columnSpacing: 32.0,
                      headingRowHeight: 48.0,
                      dataRowHeight: 60.0,
                      columns: const [
                        DataColumn(
                          label: Text('Subject',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Attendance %',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Attended Classes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Missed Classes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: attendanceList.map((attendance) {
                        final subject = attendance["subject"];
                        final percentage = attendance["percentage"];
                        final attendedClasses = attendance["attendedClasses"];
                        final missedClasses = attendance["missedClasses"];
                        final courseCode = attendance[
                            "courseCode"]; // Hidden in table but used in popup

                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(subject),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Course Code: $courseCode"),
                                            Text("Attendance: $percentage"),
                                            Text(
                                                "Attended Classes: $attendedClasses"),
                                            Text(
                                                "Missed Classes: $missedClasses"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text(
                                    subject,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 100.0,
                                child: Text(
                                  percentage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150.0,
                                child: Text(
                                  "$attendedClasses",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150.0,
                                child: Text(
                                  "$missedClasses",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
