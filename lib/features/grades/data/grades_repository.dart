import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';

/// Grades API. Returns the raw payload; throws on failure.
class GradesRepository {
  static Future<Map<String, dynamic>> fetchGrades(String semester) async {
    final response = await slcm.post(
      Urls.grades,
      body: {'Enrollment': '', 'Semester': semester},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch grades');
    }
    return Map<String, dynamic>.from(response.data);
  }
}
