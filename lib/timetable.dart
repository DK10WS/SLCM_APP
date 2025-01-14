import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Timetable extends StatefulWidget {
  final String newCookies;

  const Timetable({Key? key, required this.newCookies}) : super(key: key);

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  late String selectedDate;
  late List<String> weekDates;
  Map<String, List<Map<String, dynamic>>> eventsByDate = {};
  Map<String, String> attendanceCache = {}; // Cache for attendance types

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    weekDates = _getWeekDates(DateTime.now());
    fetchWeekEvents(); // Fetch events for the current date
  }

  List<String> _getWeekDates(DateTime currentDate) {
    int currentDay = currentDate.weekday;
    DateTime startOfWeek = currentDate.subtract(Duration(days: currentDay - 1));
    List<String> weekDatesList = [];

    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startOfWeek.add(Duration(days: i));
      weekDatesList.add(DateFormat('yyyy-MM-dd').format(currentDay));
    }

    return weekDatesList;
  }

  Future<void> fetchWeekEvents() async {
    var data = await weekTT(widget.newCookies);
    if (data != null) {
      setState(() {
        eventsByDate = data;
      });
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> weekTT(
      String newCookies) async {
    var url =
        "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetStudentCalenderEventList";
    Map<String, String> payload = {
      "Year": "",
      "Month": "",
      "Type": "agendaWeek",
      "Dated": selectedDate,
      "PreNext": "2"
    };
    Map<String, String> headers = {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "Cookie": newCookies,
    };

    var response =
        await http.post(Uri.parse(url), headers: headers, body: payload);
    if (response.statusCode == 200) {
      List<dynamic> rawEvents = json.decode(response.body);
      Map<String, List<Map<String, dynamic>>> groupedEvents = {};
      for (var event in rawEvents) {
        String date = event['StartDate'].split('T')[0];
        if (!groupedEvents.containsKey(date)) {
          groupedEvents[date] = [];
        }
        groupedEvents[date]!.add(event);
      }
      return groupedEvents;
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return {};
    }
  }

  Future<Map<String, String>> fetchEventDetails(
      String entryNo, String newCookies) async {
    var newUrl =
        "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetEventDetailStudent";
    Map<String, String> newParameters = {"EventID": entryNo};
    Map<String, String> headers = {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "Cookie": newCookies,
    };
    var response = await http.post(Uri.parse(newUrl),
        headers: headers, body: newParameters);
    var eventDetails = jsonDecode(response.body);
    return {
      'AttendanceType': eventDetails['AttendanceType'] ?? "",
      'ProgramCode': eventDetails['ProgramCode'] ?? "N/A",
      'CourseID': eventDetails['CourseID'] ?? "N/A",
      'Semester': eventDetails['Semester'] ?? "N/A",
      'Time': eventDetails['SlotScheme'] ?? "N/A",
    };
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        weekDates =
            _getWeekDates(pickedDate); // Update weekDates when date changes
      });
      fetchWeekEvents(); // Fetch events for the newly selected date
    }
  }

  void _showSubjectDetails(BuildContext context, Map<String, dynamic> event) {
    String entryNo = event['EntryNo'].toString();
    fetchEventDetails(entryNo, widget.newCookies).then((eventDetails) {
      String attendanceType = eventDetails['AttendanceType'] ?? 'Not Marked';
      Color attendanceColor;

      // Determine the attendance color
      if (attendanceType == 'Absent') {
        attendanceColor = Colors.red;
      } else if (attendanceType == 'Present') {
        attendanceColor = Colors.green;
      } else {
        attendanceColor = Colors.grey;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "${eventDetails['CourseID']?.split(":")[1] ?? 'N/A'}",
              style: const TextStyle(color: Colors.black),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    "Program Code: ${eventDetails['ProgramCode'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Course ID: ${eventDetails['CourseID']?.split(":")[0] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Semester: ${eventDetails['Semester'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Attendance Type: ${eventDetails['AttendanceType'] ?? 'Not Marked'}",
                    style: TextStyle(color: attendanceColor),
                  ),
                  Text(
                    "Time: ${eventDetails['Time'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timetable')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select a Date'),
            ),
            SizedBox(height: 16),
            Container(
              height: 120.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: weekDates.map((date) {
                    DateTime day = DateTime.parse(date);
                    String formattedDate = DateFormat('EEE, dd/MM').format(day);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDate = date;
                          });
                          fetchWeekEvents(); // Fetch events for the selected date
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          backgroundColor: Colors.blueAccent,
                          minimumSize: Size(120, 60),
                        ),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: eventsByDate.isEmpty
                  ? Center(child: Text("No events available"))
                  : ListView.builder(
                      itemCount: eventsByDate[selectedDate]?.length ?? 0,
                      itemBuilder: (context, index) {
                        var event = eventsByDate[selectedDate]![index];
                        String entryNo = event['EntryNo'].toString();

                        // Fetch event details and determine the attendance status color
                        return FutureBuilder<Map<String, String>>(
                          future: fetchEventDetails(entryNo, widget.newCookies),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Card(
                                child: ListTile(
                                  title: Text('Loading...'),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Card(
                                child: ListTile(
                                  title: Text('Error fetching data'),
                                ),
                              );
                            } else {
                              Map<String, String> eventDetails = snapshot.data!;
                              String attendanceType =
                                  eventDetails['AttendanceType'] ??
                                      'Not Marked';
                              Color boxColor;

                              if (attendanceType == 'Absent') {
                                boxColor = Colors.red!;
                              } else if (attendanceType == 'Present') {
                                boxColor = Colors.green!;
                              } else {
                                boxColor = Colors.grey!;
                              }

                              return Card(
                                color: boxColor,
                                child: ListTile(
                                  title: Text(
                                    event['Description'].split(",")[0] ??
                                        'No Description',
                                  ),
                                  onTap: () =>
                                      _showSubjectDetails(context, event),
                                ),
                              );
                            }
                          },
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
