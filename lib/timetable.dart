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
  List<String> weekDates = [];
  Map<String, List<dynamic>> eventsByDate = {};
  bool isLoading = true;
  String selectedDate = "";
  DateTime currentSelectedDate = DateTime.now();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeWeek(currentSelectedDate);
  }

  void initializeWeek(DateTime startDate) {
    setState(() {
      weekDates = getWeekDates(startDate);
      selectedDate = formatDate(currentSelectedDate);
    });
    fetchAllEvents();
  }

  List<String> getWeekDates(DateTime date) {
    DateTime startOfWeek =
        date.subtract(Duration(days: date.weekday == 7 ? 6 : date.weekday - 1));
    return List.generate(
      7,
      (index) => formatDate(startOfWeek.add(Duration(days: index))),
    );
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String formatDateWithMonth(DateTime date) {
    List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return "${daysOfWeek[date.weekday - 1]}, ${date.day.toString().padLeft(2, '0')} ${getMonthName(date.month)}";
  }

  String getMonthName(int month) {
    List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  Future<void> fetchAllEvents() async {
    setState(() {
      isLoading = true;
    });

    Map<String, List<dynamic>> allEvents = {};

    for (String date in weekDates) {
      var data = await fetchEventsForDate(date);
      if (data != null) {
        allEvents[date] = data;
      } else {
        allEvents[date] = [];
      }
    }

    setState(() {
      eventsByDate = allEvents;
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedDate();
    });
  }

  Future<List<dynamic>?> fetchEventsForDate(String selectedDate) async {
    var url =
        "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetStudentCalenderEventList";
    Map<String, String> payload = {
      "Year": "",
      "Month": "",
      "Type": "agendaDay",
      "Dated": selectedDate,
      "PreNext": "2"
    };

    Map<String, String> headers = {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "Cookie": widget.newCookies,
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: payload,
    );

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body) as List<dynamic>;

      for (var event in decodedData) {
        String entryNo = event['EntryNo'] ?? '';
        if (entryNo.isNotEmpty) {
          var attendanceType = await fetchAttendanceType(entryNo);
          event['AttendanceType'] = attendanceType ?? 'Unknown';
        } else {
          event['AttendanceType'] = 'Unknown';
        }
      }
      return decodedData;
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> fetchAttendanceType(String entryNo) async {
    var newUrl = Uri.parse(
        "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetEventDetailStudent");
    Map<String, String> newPayload = {"EventID": entryNo};
    Map<String, String> headers = {
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "Cookie": widget.newCookies,
    };

    var response = await http.post(
      newUrl,
      body: newPayload,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['AttendanceType'];
    } else {
      print("Failed to fetch attendance type: ${response.statusCode}");
      return null;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentSelectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != currentSelectedDate) {
      setState(() {
        currentSelectedDate = picked;
        initializeWeek(picked);
        selectedDate = formatDate(picked);
      });

      int index = weekDates.indexOf(selectedDate);
      if (index != -1) {
        _scrollController.animateTo(
          index * 80.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  String formatTime(String time) {
    if (time == null || time.isEmpty) return 'N/A';
    final DateTime parsedTime = DateTime.parse(time);
    final String formattedTime =
        "${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}";
    return formattedTime;
  }

  void scrollToSelectedDate() {
    int index = weekDates.indexOf(selectedDate);
    if (index != -1) {
      _scrollController.animateTo(
        index * 80.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void showSubjectDetailsDialog(
      BuildContext context, Map<String, dynamic> eventDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              eventDetails['Description'].split(",")[0] ?? 'Subject Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Program Code: ${eventDetails['ProgramCode'] ?? 'N/A'}"),
              Text("Course ID: ${eventDetails['CourseID'] ?? 'N/A'}"),
              Text("Semester: ${eventDetails['Semester'] ?? 'N/A'}"),
              Text(
                  "Attendance Type: ${eventDetails['AttendanceType'] ?? 'N/A'}"),
              Text(
                  "Time: ${formatTime(eventDetails['StartDate'] ?? 'N/A')} to ${formatTime(eventDetails['EndDate'] ?? 'N/A')}"),
            ],
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Timetable')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => selectDate(context),
                child: Text('Select Date'),
              ),
            ),
            Container(
              height: 60,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  String date = weekDates[index];
                  DateTime dateTime = DateTime.parse(date);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });

                      _scrollController.animateTo(
                        index * 80.0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedDate == date
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          formatDateWithMonth(dateTime),
                          style: TextStyle(
                            color: selectedDate == date
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (eventsByDate[selectedDate]?.isEmpty ?? true)
                        ListTile(
                          title: Text("No events available for $selectedDate"),
                        )
                      else
                        ...eventsByDate[selectedDate]!.map((event) {
                          String attendanceType =
                              event['AttendanceType']?.toLowerCase() ?? '';
                          Color boxColor;

                          if (attendanceType == "absent") {
                            boxColor = Colors.red;
                          } else if (attendanceType == "present") {
                            boxColor = Colors.green;
                          } else {
                            boxColor = Colors.grey;
                          }

                          String startTime = event['StartDate'] ?? 'N/A';
                          String endTime = event['EndDate'] ?? 'N/A';
                          String formattedTime =
                              "${formatTime(startTime)} to ${formatTime(endTime)}";

                          return Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  formattedTime,
                                  style: TextStyle(
                                    color: Colors
                                        .black, // Black color for the time
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showSubjectDetailsDialog(context, event);
                                },
                                child: Card(
                                  color: boxColor,
                                  child: ListTile(
                                    title: Text(
                                      event['Description'].split(",")[0] ??
                                          'No Description Available',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
