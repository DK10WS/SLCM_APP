import 'package:html/parser.dart' show parse;

import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';

/// Student information page scraper. Throws on failure.
class InformationRepository {
  static Future<Map<String, String>> fetchInfo() async {
    final response = await slcm.get(Urls.information);
    final document = parse(response.data);

    final registrationNumber = document
        .querySelector('input[name="RegistrationNo"]')
        ?.attributes['value'];
    final name =
        document.querySelector('input[name="EmpName"]')?.attributes['value'];
    final semester =
        document.querySelector('input[name="Semester"]')?.attributes['value'];
    final program =
        document.querySelector('input[name="CourseName"]')?.attributes['value'];
    final batch =
        document.querySelector('input[name="Batch"]')?.attributes['value'];
    final section =
        document.querySelector('input[name="Section"]')?.attributes['value'];

    var rows = document.querySelectorAll('table#kt_View tr');
    String? classCoordinator;
    String? classCoordinatoremail;
    for (var row in rows) {
      var cells = row.querySelectorAll('td');
      if (cells.length > 1 && cells[1].text.trim() == 'Class Coordinator') {
        classCoordinator = cells[2].text.trim();
        classCoordinatoremail = cells[3].text.trim();
        break;
      }
    }

    return {
      'Name': name ?? 'N/A',
      'Registration Number': registrationNumber ?? 'N/A',
      'Section': section ?? 'N/A',
      'Program': program ?? 'N/A',
      'Semester': semester ?? 'N/A',
      'Batch': batch ?? 'N/A',
      'Class Coordinator': classCoordinator ?? 'N/A',
      'Class Coordinator Email': classCoordinatoremail ?? 'N/A',
    };
  }
}
