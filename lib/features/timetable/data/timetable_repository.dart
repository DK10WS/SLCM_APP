import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';

/// Timetable APIs: week agenda + per-event details.
class TimetableRepository {
  static Future<Map<String, List<Map<String, dynamic>>>> weekEvents(
    String selectedDate,
  ) async {
    final response = await slcm.post(
      Urls.timeTableWeek,
      body: {
        'Year': '',
        'Month': '',
        'Type': 'agendaWeek',
        'Dated': selectedDate,
        'PreNext': '2',
      },
    );

    if (response.statusCode != 200) return {};

    Map<String, List<Map<String, dynamic>>> groupedEvents = {};
    for (var event in response.data) {
      String date = event['StartDate'].split('T')[0];
      groupedEvents.putIfAbsent(date, () => []).add(
            Map<String, dynamic>.from(event),
          );
    }
    return groupedEvents;
  }

  static Future<Map<String, String>> eventDetails(String entryNo) async {
    final response = await slcm.post(
      Urls.timeTableEvent,
      body: {'EventID': entryNo},
    );

    final details = response.data;
    return {
      'AttendanceType': details['AttendanceType'] ?? 'Not Marked',
      'Time': details['SlotScheme'] ?? '',
    };
  }
}
