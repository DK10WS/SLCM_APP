import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';

/// Attendance summary API. Returns `null` when the request fails
/// (page shows the empty state, same as before).
class AttendanceRepository {
  static Future<List<Map<String, dynamic>>?> fetchSummary() async {
    final response = await slcm.post(
      Urls.attendance,
      body: {'StudentCode': ''},
    );

    if (response.statusCode != 200) return null;

    final decoded = response.data;
    final List<dynamic> attendanceList = decoded['AttendanceSummaryList'];

    List<Map<String, dynamic>> attendanceData = [];

    for (var record in attendanceList) {
      String fullName = record['CourseID'] ?? 'Unknown Subject';
      String percentage = record['Percentage'] ?? '0';
      int newpercentage = int.tryParse(record['Percentage'] ?? '0%') ?? 0;

      String courseCode = fullName.split(':').length > 1
          ? fullName.split(':')[0].trim()
          : 'Unknown Code';

      String subjectName = fullName.split(':').length > 1
          ? fullName.split(':')[1].trim()
          : fullName;

      int totalClasses = int.tryParse(record['Total'] ?? '0') ?? 0;
      int attendedClasses = int.tryParse(record['Present'] ?? '0') ?? 0;
      int missedClasses = totalClasses - attendedClasses;

      String statusMessage;
      int? classesNeeded;
      if (newpercentage < 75) {
        classesNeeded =
            ((0.75 * totalClasses - attendedClasses) / (1 - 0.75)).floor();
        statusMessage = '$classesNeeded more classes needed to reach 75%.';
      } else {
        statusMessage = 'Good! Your attendance is above or equal to 75%.';
        classesNeeded = null;
      }

      attendanceData.add({
        'courseCode': courseCode,
        'subject': subjectName,
        'percentage': percentage,
        'attendedClasses': attendedClasses,
        'missedClasses': missedClasses,
        'totalClasses': totalClasses,
        'statusMessage': statusMessage,
        'classesNeeded': classesNeeded,
      });
    }

    return attendanceData;
  }
}
