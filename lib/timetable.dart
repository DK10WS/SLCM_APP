import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map<String, String> attendanceCache = {};
  Map<String, String> eventTimeCache = {};
  bool isLoading = false;
  String errorMessage = '';
  ScrollController _scrollController = ScrollController();

  void _scrollToSelectedDate() {
    int selectedIndex = weekDates.indexOf(selectedDate);
    if (selectedIndex != -1) {
      double itemWidth = 110;
      double offset = selectedIndex * itemWidth;
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    weekDates = _getWeekDates(DateTime.now());
    _loadCachedData();
    fetchWeekEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchWeekEvents();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      attendanceCache = Map<String, String>.from(
          json.decode(prefs.getString('attendance_cache') ?? '{}'));
      eventTimeCache = Map<String, String>.from(
          json.decode(prefs.getString('event_time_cache') ?? '{}'));
    });
  }

  Future<void> _saveCache(String key, Map<String, String> cache) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(cache));
  }

  List<String> _getWeekDates(DateTime currentDate) {
    int currentDay = currentDate.weekday;
    DateTime startOfWeek = currentDate.subtract(Duration(days: currentDay - 1));
    return List.generate(
        7,
        (i) => DateFormat('yyyy-MM-dd')
            .format(startOfWeek.add(Duration(days: i))));
  }

  Duration parseTime(String timeString) {
    try {
      String startTime = timeString.split('To')[0].trim();
      List<String> startParts = startTime.split(':');
      int startHour = int.parse(startParts[0]);
      int startMinute = int.parse(startParts[1]);

      if (startHour < 8) {
        startHour += 12;
      }

      return Duration(hours: startHour, minutes: startMinute);
    } catch (e) {
      return Duration(days: 999);
    }
  }

  void sortEventsByTime() {
    for (var date in eventsByDate.keys) {
      eventsByDate[date]?.sort((a, b) {
        String timeA = eventTimeCache[a['EntryNo'].toString()] ?? '';
        String timeB = eventTimeCache[b['EntryNo'].toString()] ?? '';
        Duration durationA = parseTime(timeA);
        Duration durationB = parseTime(timeB);
        return durationA.compareTo(durationB);
      });
    }
  }

  Future<void> fetchWeekEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    if (attendanceCache.isEmpty || eventTimeCache.isEmpty) {
      _loadCachedData();
    }

    try {
      var data = await weekTT(widget.newCookies);
      if (data != null) {
        setState(() {
          eventsByDate = data;
        });

        sortEventsByTime();

        for (var date in weekDates) {
          eventsByDate[date]?.forEach((event) {
            _fetchAndCacheEventDetails(event['EntryNo'].toString());
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load events from API.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching events: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToSelectedDate();
    }
  }

  Future<void> _fetchAndCacheEventDetails(String entryNo) async {
    try {
      var eventDetails = await fetchEventDetails(entryNo, widget.newCookies);
      setState(() {
        attendanceCache[entryNo] =
            eventDetails['AttendanceType'] ?? 'Not Marked';
        eventTimeCache[entryNo] = eventDetails['Time'] ?? 'No Time Available';
      });
      _saveCache('attendance_cache', attendanceCache);
      _saveCache('event_time_cache', eventTimeCache);
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching event details: $e';
      });
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> weekTT(
      String newCookies) async {
    var response = await http.post(
      Uri.parse(
          "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetStudentCalenderEventList"),
      headers: {"user-agent": "Mozilla/5.0", "Cookie": newCookies},
      body: {
        "Year": "",
        "Month": "",
        "Type": "agendaWeek",
        "Dated": selectedDate,
        "PreNext": "2"
      },
    );
    if (response.statusCode == 200) {
      Map<String, List<Map<String, dynamic>>> groupedEvents = {};
      for (var event in json.decode(response.body)) {
        String date = event['StartDate'].split('T')[0];
        groupedEvents.putIfAbsent(date, () => []).add(event);
      }
      return groupedEvents;
    }
    return {};
  }

  Future<Map<String, String>> fetchEventDetails(
      String entryNo, String newCookies) async {
    var response = await http.post(
      Uri.parse(
          "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetEventDetailStudent"),
      headers: {"user-agent": "Mozilla/5.0", "Cookie": newCookies},
      body: {"EventID": entryNo},
    );
    var eventDetails = jsonDecode(response.body);
    return {
      'AttendanceType': eventDetails['AttendanceType'] ?? "Not Marked",
      'Time': eventDetails['SlotScheme'] ?? '',
    };
  }

  void shiftWeek(int direction) {
    setState(() {
      selectedDate = DateFormat('yyyy-MM-dd').format(
        DateTime.parse(selectedDate).add(Duration(days: direction * 7)),
      );
      weekDates = _getWeekDates(DateTime.parse(selectedDate));
    });
    fetchWeekEvents();
  }

  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'No Time Available';

    try {
      // Split the time string into start and end times
      List<String> times = timeString.split('To');
      if (times.length != 2)
        return timeString; // Return original if format is unexpected

      String startTime = times[0].trim();
      String endTime = times[1].trim();

      // Format start time
      List<String> startParts = startTime.split(':');
      String formattedStart =
          '${int.parse(startParts[0])}:${startParts[1].padLeft(2, '0')}';

      // Format end time
      List<String> endParts = endTime.split(':');
      String formattedEnd =
          '${int.parse(endParts[0])}:${endParts[1].padLeft(2, '0')}';

      // Return the formatted time slot
      return '$formattedStart to $formattedEnd';
    } catch (e) {
      return timeString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF121316),
        title: Text(
          'Timetable',
          style: TextStyle(color: Colors.white),
        ),
        scrolledUnderElevation: 0.0,
      ),
      backgroundColor: Color(0xFF121316),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendBox(Colors.green, 'Present'),
                  SizedBox(width: 10),
                  _buildLegendBox(Colors.red, 'Absent'),
                  SizedBox(width: 10),
                  _buildLegendBox(Colors.grey, 'Not Marked'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => shiftWeek(-1),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD5E7B5),
                    ),
                    onPressed: () => _selectDate(context),
                    child: Text(
                      'Select a Date',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  color: Colors.white,
                  onPressed: () => shiftWeek(1),
                ),
              ],
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: weekDates.map((date) {
                  bool isSelected = selectedDate == date;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Color(0xFF232531)
                            : Color.fromARGB(255, 32, 32, 32),
                        side: isSelected
                            ? BorderSide(color: Color(0xFFD5E7B5), width: 2)
                            : BorderSide.none,
                        elevation: isSelected ? 100 : 0,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedDate = date;
                        });
                        fetchWeekEvents();
                        _scrollToSelectedDate();
                      },
                      child: Text(
                        DateFormat('EEE, dd/MM').format(DateTime.parse(date)),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (isLoading) LinearProgressIndicator(),
            if (!isLoading && errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: eventsByDate[selectedDate]?.length ?? 0,
                itemBuilder: (context, index) {
                  var event = eventsByDate[selectedDate]![index];
                  String entryNo = event['EntryNo'].toString();
                  String attendanceType =
                      attendanceCache[entryNo] ?? 'Not Marked';
                  Color boxColor = attendanceType == 'Absent'
                      ? Colors.red
                      : attendanceType == 'Present'
                          ? Colors.green
                          : Colors.grey;

                  String eventTime = formatTime(eventTimeCache[entryNo]);

                  Duration eventDuration = parseTime(eventTime);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          eventTime,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                      Card(
                        color: boxColor,
                        child: ListTile(
                          title: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTime(
                                        event['Description'].split(",")[0]),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Text(
                                  event['Description'].split(",")[1] ??
                                      'No Description',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
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
        weekDates = _getWeekDates(pickedDate);
      });
      fetchWeekEvents();
    }
    _scrollToSelectedDate();
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
