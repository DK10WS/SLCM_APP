import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CGPA extends StatefulWidget {
  final String newCookies;
  const CGPA({super.key, required this.newCookies});

  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<CGPA> {
  Map<String, dynamic>? gradesData;
  bool isLoading = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchGrades();
  }

  Future<void> fetchGrades() async {
    final url =
        "https://mujslcm.jaipur.manipal.edu/Student/Academic/GetCGPAGPAForFaculty";
    final Map<String, String> headers = {
      "Cookie": widget.newCookies,
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    };
    final Map<String, String> body = {
      "Enrollment": "",
      "AcademicYear": "",
      "ProgramCode": "",
    };

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          gradesData = data["InternalMarksList"][0];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "CGPA/GPA",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : gradesData == null
              ? const Center(
                  child: Text(
                    "No data available",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total CGPA: ${gradesData?['CGPA']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Total Credits: ${gradesData?['TotalCredits']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: ToggleButtons(
                            isSelected: [
                              selectedIndex == 0,
                              selectedIndex == 1
                            ],
                            onPressed: (int index) {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'CGPA',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Credits',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      selectedIndex == 0
                          ? _buildCGPATable()
                          : _buildCreditsTable(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCGPATable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildScrollableTable(_buildGPATableRows()),
      ],
    );
  }

  Widget _buildCreditsTable() {
    return _buildScrollableTable(_buildCreditsTableRows());
  }

  Widget _buildScrollableTable(List<TableRow> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Table(
          border: TableBorder.all(
            color: Colors.cyan,
            width: 1.5,
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: rows,
        ),
      ),
    );
  }

  List<TableRow> _buildGPATableRows() {
    final List<TableRow> rows = [
      const TableRow(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Semester",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "GPA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ];

    final semesters = {
      "Semester I": gradesData?["GPASemesterI"],
      "Semester II": gradesData?["GPASemesterII"],
      "Semester III": gradesData?["GPASemesterIII"],
      "Semester IV": gradesData?["GPASemesterIV"],
      "Semester V": gradesData?["GPASemesterV"],
      "Semester VI": gradesData?["GPASemesterVI"],
      "Semester VII": gradesData?["GPASemesterVII"],
      "Semester VIII": gradesData?["GPASemesterVIII"],
    };

    semesters.forEach((semester, gpa) {
      if (gpa != null && gpa != "-" && gpa != 0.00) {
        rows.add(
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  semester,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  gpa.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });

    return rows;
  }

  List<TableRow> _buildCreditsTableRows() {
    final List<TableRow> rows = [
      const TableRow(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Semester",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Credits",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ];

    final credits = {
      "Semester I": gradesData?["CreditsSemesterI"],
      "Semester II": gradesData?["CreditsSemesterII"],
      "Semester III": gradesData?["CreditsSemesterIII"],
      "Semester IV": gradesData?["CreditsSemesterIV"],
      "Semester V": gradesData?["CreditsSemesterV"],
      "Semester VI": gradesData?["CreditsSemesterVI"],
      "Semester VII": gradesData?["CreditsSemesterVII"],
      "Semester VIII": gradesData?["CreditsSemesterVIII"],
    };

    credits.forEach((semester, credit) {
      if (credit != null && credit != "-") {
        rows.add(
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  semester,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  credit.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });

    return rows;
  }
}
