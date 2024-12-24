import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class Information extends StatefulWidget {
  final String newCookies;

  const Information({Key? key, required this.newCookies}) : super(key: key);

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  Map<String, String> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInformation();
  }

  Future<void> fetchInformation() async {
    final Map<String, String> headers = {
      "Accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
      "Accept-Encoding": "gzip, deflate, br, zstd",
      "Accept-Language": "en-US,en;q=0.8",
      "Cache-Control": "max-age=0",
      "Connection": "keep-alive",
      "Cookie": widget.newCookies,
      "Host": "mujslcm.jaipur.manipal.edu:122",
      "Referer": "https://mujslcm.jaipur.manipal.edu:122/Home/Dashboard",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    };
    final url =
        "https://mujslcm.jaipur.manipal.edu/Employee/EmployeeDirectory/IndexStudent";

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final document = parse(response.body);

      final registrationNumber = document
          .querySelector('input[name="RegistrationNo"]')
          ?.attributes['value'];
      final name =
          document.querySelector('input[name="EmpName"]')?.attributes['value'];
      final semester =
          document.querySelector('input[name="Semester"]')?.attributes['value'];
      final program = document
          .querySelector('input[name="CourseName"]')
          ?.attributes['value'];
      final batch =
          document.querySelector('input[name="Batch"]')?.attributes['value'];
      final section =
          document.querySelector('input[name="Section"]')?.attributes['value'];

      var rows = document.querySelectorAll('table#kt_View tr');
      String? classCoordinator;
      for (var row in rows) {
        var cells = row.querySelectorAll('td');
        if (cells.length > 1 && cells[1].text.trim() == "Class Coordinator") {
          classCoordinator = cells[2].text.trim();
          break;
        }
      }

      if (mounted) {
        setState(() {
          userInfo = {
            "Name": name ?? "N/A",
            "Registration Number": registrationNumber ?? "N/A",
            "Section": section ?? "N/A",
            "Program": program ?? "N/A",
            "Semester": semester ?? "N/A",
            "Batch": batch ?? "N/A",
            "Class Coordinator": classCoordinator ?? "N/A",
          };
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userInfo = {"Error": "Failed to fetch data. Please try again later."};
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121316),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFF232531),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Information",
                      style: TextStyle(
                        fontFamily: "Gotham",
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: userInfo.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
