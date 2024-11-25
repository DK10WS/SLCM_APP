import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Timetable extends StatefulWidget {
  final String newCookies;

  const Timetable({Key? key, required this.newCookies}) : super(key: key);

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> events = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        events = [];
      });
      await fetchEventsForDate(picked);
    }
  }

  Future<void> fetchEventsForDate(DateTime? date) async {
    if (date == null) return;

    String formattedDate =
        "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
    String newCookies = widget.newCookies;

    final Map<String, String> parameters = {
      "year": "",
      "month": "",
      "type": "agendaDay",
      "dated": formattedDate,
      "preNext": "2"
    };

    var url =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetStudentCalenderEventList";

    var response = await http.post(Uri.parse(url),
        headers: _buildHeaders(newCookies), body: parameters);

    List<dynamic> data = jsonDecode(response.body);
    List<Map<String, dynamic>> result = [];

    for (var entry in data) {
      String entryNo = entry['EntryNo'] ?? "Unknown";
      String description = entry['Description'] ?? "No Description";

      // Fetch detailed event data
      Map<String, dynamic> eventDetails = await fetchEventDetails(entryNo);

      result.add({
        'Description': description,
        'EntryNo': entryNo,
        ...eventDetails,
      });
    }

    setState(() {
      events = result;
    });
  }

  Future<Map<String, dynamic>> fetchEventDetails(String entryNo) async {
    var newCookies = widget.newCookies;
    var newParameters = {"EventID": entryNo};

    var newUrl =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetEventDetailStudent";

    var response = await http.post(Uri.parse(newUrl),
        headers: _buildHeaders(newCookies), body: newParameters);

    var eventDetails = jsonDecode(response.body);

    return {
      'AttendanceType': eventDetails['AttendanceType'] ?? "",
      'ProgramCode': eventDetails['ProgramCode'] ?? "N/A",
      'CourseID': eventDetails['CourseID'] ?? "N/A",
      'Semester': eventDetails['Semester'] ?? "N/A",
      'Time': eventDetails['SlotScheme'] ?? "N/A",
    };
  }

  void showEventDetailsPopup(
      BuildContext context, Map<String, dynamic> eventDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "${eventDetails['CourseID']}",
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Program Code: ${eventDetails['ProgramCode']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Course ID: ${eventDetails['CourseID']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Semester: ${eventDetails['Semester']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Attendance Type: ${eventDetails['AttendanceType']}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Time: ${eventDetails['SlotScheme']}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.cyan), // Cyan button text
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, String> _buildHeaders(String cookies) {
    return {
      "Accept": "application/json, text/javascript, */*; q=0.01",
      "Accept-Encoding": "gzip, deflate, br, zstd",
      "Accept-Language": "en-US,en;q=0.8",
      "Connection": "keep-alive",
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "Cookie": cookies,
      "Host": "mujslcm.jaipur.manipal.edu:122",
      "Origin": "https://mujslcm.jaipur.manipal.edu:122",
      "Referer":
          "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/ViewTimeTableForStudent",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "same-origin",
      "Sec-GPC": "1",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "X-Requested-With": "XMLHttpRequest",
      "sec-ch-ua":
          "\"Brave\";v=\"131\", \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\"",
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": "\"Windows\"",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Timetable",
            style: TextStyle(fontSize: 24, color: Colors.white), // White text
          ),
          const SizedBox(height: 10),
          // Legend for colors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green, "Present"),
              _buildLegendItem(Colors.red, "Absent"),
              _buildLegendItem(Colors.grey, "Not Marked"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan, // Cyan button for visibility
                foregroundColor: Colors.black, // Black text on button
              ),
              onPressed: () => _selectDate(context),
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}",
                style: const TextStyle(color: Colors.black), // Black text
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                String attendanceType = events[index]['AttendanceType'] ?? "";
                Color buttonColor;

                if (attendanceType == "Present") {
                  buttonColor = Colors.green;
                } else if (attendanceType == "Absent") {
                  buttonColor = Colors.red;
                } else {
                  buttonColor = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    onPressed: () {
                      showEventDetailsPopup(context, events[index]);
                    },
                    child: ListTile(
                      title: Text(
                        events[index]['Description']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text on buttons
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white), // White text in legend
        ),
      ],
    );
  }
}
