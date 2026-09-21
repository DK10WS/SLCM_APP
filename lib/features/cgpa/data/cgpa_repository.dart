import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';

/// CGPA/GPA API. Returns the first record of `InternalMarksList`.
/// Throws on failure.
class CgpaRepository {
  static Future<Map<String, dynamic>> fetchData() async {
    final response = await slcm.post(
      Urls.cgpa,
      body: {'Enrollment': '', 'AcademicYear': '', 'ProgramCode': ''},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return Map<String, dynamic>.from(response.data['InternalMarksList'][0]);
  }
}
