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
  DateTime selectedDate = DateTime.now(); // Default to current date
  List<Map<String, dynamic>> events = [];
  bool isLoading = false; // Loading indicator state

  @override
  void initState() {
    super.initState();
    fetchEventsForDate(selectedDate); // Load events for current date
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      events = [];
    });
    fetchEventsForDate(selectedDate);
  }

  Future<void> fetchEventsForDate(DateTime date) async {
    if (date == null) return;

    setState(() {
      isLoading = true;
    });

    String formattedDate =
        "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";

    final Map<String, String> parameters = {
      "year": "",
      "month": "",
      "type": "agendaDay",
      "dated": formattedDate,
      "preNext": "2"
    };

    var url =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetStudentCalenderEventList";

    try {
      var response = await http.post(Uri.parse(url),
          headers: _buildHeaders(widget.newCookies), body: parameters);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> result = [];

        for (var entry in data) {
          String entryNo = entry['EntryNo'] ?? "Unknown";
          String fullDescription = entry['Description'] ?? "No Description";
          String subjectName = fullDescription.split(',')[0];
          Map<String, dynamic> eventDetails = await fetchEventDetails(entryNo);

          result.add({
            'Description': subjectName,
            'EntryNo': entryNo,
            ...eventDetails,
          });
        }

        setState(() {
          events = result;
        });
      } else {
        // Handle server error
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchEventDetails(String entryNo) async {
    var newParameters = {"EventID": entryNo};

    var newUrl =
        "https://mujslcm.jaipur.manipal.edu:122/Student/Academic/GetEventDetailStudent";

    try {
      var response = await http.post(Uri.parse(newUrl),
          headers: _buildHeaders(widget.newCookies), body: newParameters);

      if (response.statusCode == 200) {
        var eventDetails = jsonDecode(response.body);
        return {
          'AttendanceType': eventDetails['AttendanceType'] ?? "",
          'ProgramCode': eventDetails['ProgramCode'] ?? "N/A",
          'CourseID': (eventDetails['CourseID'] ?? "N/A"),
          'Semester': eventDetails['Semester'] ?? "N/A",
          'Time': eventDetails['SlotScheme'] ?? "N/A",
        };
      } else {
        // Handle error in fetching event details
        return {};
      }
    } catch (e) {
      print("Error fetching event details: $e");
      return {};
    }
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

  void showEventDetailsPopup(
      BuildContext context, Map<String, dynamic> eventDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "${eventDetails['CourseID'].split(":")[1]}",
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
                  "Course ID: ${eventDetails['CourseID'].split(":")[0]}",
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
                  "Time: ${eventDetails['Time']}",
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
                style: TextStyle(color: Colors.cyan),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Timetable",
            style: TextStyle(
                fontFamily: "gotham", fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green, "Present"),
              _buildLegendItem(Colors.red, "Absent"),
              _buildLegendItem(Colors.grey, "Not Marked"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _changeDate(-1),
              ),
              Expanded(
                child: SizedBox(
                  width: double
                      .infinity, // Ensures the button expands to available space
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => _selectDate(context),
                    child: Text(
                      "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return EventTile(
                        event: events[index],
                        onPressed: () {
                          showEventDetailsPopup(context, events[index]);
                        },
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
          height: 15,
          width: 15,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontFamily: "gotham", color: Colors.white),
        ),
      ],
    );
  }
}

class EventTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onPressed;

  const EventTile({Key? key, required this.event, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.black,
        child: ListTile(
          title: Text(
            event['Description'] ?? 'No Description',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            event['EntryNo'] ?? 'No Entry Number',
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.info,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
