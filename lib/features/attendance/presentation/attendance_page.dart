import 'package:flutter/material.dart';
import 'package:mujslcm/core/theme/app_colors.dart';
import 'package:mujslcm/features/attendance/data/attendance_repository.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<Map<String, dynamic>>?> _attendanceData;

  @override
  void initState() {
    super.initState();
    _attendanceData = AttendanceRepository.fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Attendance Summary',
            style: TextStyle(color: Colors.white),
          ),
          scrolledUnderElevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>?>(
              future: _attendanceData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
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
                    padding: const EdgeInsets.all(15.0),
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
                            color: Color(0xFFA3C78F).withOpacity(0.125),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.card,
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
                                        style:
                                            TextStyle(color: AppColors.accent),
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
                                          color: AppColors.accent,
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
