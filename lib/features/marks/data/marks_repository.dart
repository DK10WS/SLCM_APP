import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';

/// Internal-marks API, including the total-calculation fallback for
/// courses whose `Total` is `"-"`. Throws on failure.
class MarksRepository {
  static Future<List<Map<String, dynamic>>> fetchMarks(
    String semester,
  ) async {
    final response = await slcm.post(
      Urls.marks,
      body: {'Enrollment': '', 'Semester': semester},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch marks');
    }

    return List<Map<String, dynamic>>.from(
      (response.data['InternalMarksList'] as List).map((course) {
        final courseMap = Map<String, dynamic>.from(course);

        double total = 0.0;
        double maxMarks = 100;

        double mte1 =
            double.tryParse(courseMap['MTE1']?.toString() ?? '0') ?? 0;
        double mte2 =
            double.tryParse(courseMap['MTE2']?.toString() ?? '0') ?? 0;
        double cws = double.tryParse(courseMap['CWS']?.toString() ?? '0') ?? 0;
        double ete = double.tryParse(courseMap['ETE']?.toString() ?? '0') ?? 0;
        double prs = double.tryParse(courseMap['PRS']?.toString() ?? '0') ?? 0;

        if (courseMap['Total'] == '-') {
          if (prs > 0) {
            total = prs;
            maxMarks = 60;
          } else if (mte1 > 0 && mte2 > 0) {
            total = mte1 + mte2 + cws + ete;
            maxMarks = 100; // 40 + 20 + 40
          } else if (mte1 > 0) {
            total = mte1 + cws + ete;
            maxMarks = 100; // 30 + 30 + 40
          }
        } else {
          total = double.tryParse(courseMap['Total']?.toString() ?? '0') ?? 0;
        }

        courseMap['RESESSION'] = courseMap['RESESSION'] ?? '-';

        return {
          ...courseMap,
          'Total': total,
          'MaxMarks': maxMarks,
        };
      }),
    );
  }
}
