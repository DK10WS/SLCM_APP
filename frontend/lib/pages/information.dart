import 'package:flutter/material.dart';
import 'package:mujslcm/pages/redirects.dart';

import '../utils/util.dart';

class Information extends StatefulWidget {
  const Information({super.key});

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
    final url = informationURL;

    try {
      final response = await post(url, headers, body);

      final document = response.data;

      final registrationNumber = document["registration_no"];
      final name = document["name"];
      final semester = document["semester"];
      final program = document["program"];
      final batch = document["batch"];
      final section = document["section"];
      final classCoordinatoremail = document["class_coordinator_mail"];
      final classCoordinator = document["class_coordinator"];

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
            "Class Coordinator Email": classCoordinatoremail ?? "N/A",
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
                color: Color(0xFFD5E7B5),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFF212121),
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
                              SelectableText(
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
                                    color: Color(0xFFD5E7B5),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: SelectableText(
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
