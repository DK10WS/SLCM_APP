import 'dart:convert';
import 'redirects.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'app_colors.dart';

class CGPA extends StatefulWidget {
  final String newCookies;
  const CGPA({super.key, required this.newCookies});

  @override
  _CGPAState createState() => _CGPAState();
}

class _CGPAState extends State<CGPA> {
  Map<String, dynamic>? gradesData;
  bool isLoading = true;
  int selectedIndex = 0;

  get bottomTitleWidgets => null;

  @override
  void initState() {
    super.initState();
    fetchGrades();
  }

  Future<void> fetchGrades() async {
    final url = CGPAURL;
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

  Widget _buildCGPAGraph() {
    final List<String> semesters = [
      "Semester 1",
      "Semester 2",
      "Semester 3",
      "Semester 4",
      "Semester 5",
      "Semester 6",
      "Semester 7",
      "Semester 8"
    ];

    final List<double?> rawCgpas = [
      _parseCGPA(gradesData?["GPASemesterI"]),
      _parseCGPA(gradesData?["GPASemesterII"]),
      _parseCGPA(gradesData?["GPASemesterIII"]),
      _parseCGPA(gradesData?["GPASemesterIV"]),
      _parseCGPA(gradesData?["GPASemesterV"]),
      _parseCGPA(gradesData?["GPASemesterVI"]),
      _parseCGPA(gradesData?["GPASemesterVII"]),
      _parseCGPA(gradesData?["GPASemesterVIII"]),
    ];

    final List<FlSpot> spots = [];
    for (int i = 0; i < rawCgpas.length; i++) {
      if (rawCgpas[i] != 0.0) {
        spots.add(FlSpot(i.toDouble(), rawCgpas[i]!));
      }
    }

    if (spots.isEmpty) {
      return Center(child: Text("No CGPA data available"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 270,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: AppColors.mainGridLineColor,
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => const FlLine(
                  color: AppColors.mainGridLineColor,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Color(0xff37434d)),
                  bottom: BorderSide(color: Color(0xff37434d)),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
              minX: 0,
              maxX: spots.length.toDouble() - 1,
              minY: 6,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD5E7B5), // Light Green
                      Color(0xFFA3C78F), // Muted Green
                    ],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFD5E7B5)
                            .withOpacity(0.2), // Light Green (transparent)
                        Color(0xFFE7F5D5).withOpacity(0.4), // Pale Green
                      ],
                    ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        (value.toInt() + 1).toString(),
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _parseCGPA(dynamic value) {
    if (value == null || value == "-" || value == "0.00") {
      return 0.0;
    }
    double parsedValue = double.tryParse(value.toString()) ?? 0.0;
    return parsedValue.isFinite ? parsedValue : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        title: const Text("CGPA/GPA", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121316),
        scrolledUnderElevation: 0.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD5E7B5)))
            : gradesData == null
                ? const Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildHeader(),
                        const SizedBox(height: 22),
                        _buildCGPAGraph(),
                        const SizedBox(height: 0),
                        _buildToggleButtons(),
                        const SizedBox(height: 16),
                        selectedIndex == 0
                            ? _buildGPAList()
                            : _buildCreditsList(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFD5E7B5),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("CGPA",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text("${gradesData?["CGPA"]}",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text("Total Credits: ${gradesData?["TotalCredits"]}",
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFFD5E7B5).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == 0
                        ? Color(0xFFD5E7B5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "GPA",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          selectedIndex == 0 ? Colors.black : Color(0xFFD5E7B5),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == 1
                        ? Color(0xFFD5E7B5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Credits",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          selectedIndex == 1 ? Colors.black : Color(0xFFD5E7B5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsList() {
    final semesters = {
      "Semester 1": gradesData?["CreditsSemesterI"],
      "Semester 2": gradesData?["CreditsSemesterII"],
      "Semester 3": gradesData?["CreditsSemesterIII"],
      "Semester 4": gradesData?["CreditsSemesterIV"],
      "Semester 5": gradesData?["CreditsSemesterV"],
      "Semester 6": gradesData?["CreditsSemesterVI"],
      "Semester 7": gradesData?["CreditsSemesterVII"],
      "Semester 8": gradesData?["CreditsSemesterVIII"],
    };

    return Column(
      children: semesters.entries
          .where((e) => e.value != null && e.value != "-" && e.value != "0.00")
          .toList()
          .reversed
          .map((entry) {
        return Card(
          color: Color(0xFF212121),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFD5E7B5),
              child: Text(entry.key.split(" ")[1],
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            title: Text(entry.key,
                style: const TextStyle(
                    color: Color(0xFFD5E7B5), fontWeight: FontWeight.bold)),
            trailing: Text(entry.value.toString(),
                style: const TextStyle(color: Color(0xFFD5E7B5), fontSize: 18)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGPAList() {
    final semesters = {
      "Semester 1": gradesData?["GPASemesterI"],
      "Semester 2": gradesData?["GPASemesterII"],
      "Semester 3": gradesData?["GPASemesterIII"],
      "Semester 4": gradesData?["GPASemesterIV"],
      "Semester 5": gradesData?["GPASemesterV"],
      "Semester 6": gradesData?["GPASemesterVI"],
      "Semester 7": gradesData?["GPASemesterVII"],
      "Semester 8": gradesData?["GPASemesterVIII"],
    };

    return Column(
      children: semesters.entries
          .where((e) => e.value != null && e.value != "-" && e.value != "0.00")
          .toList()
          .reversed
          .map((entry) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFD5E7B5),
              child: Text(entry.key.split(" ")[1],
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            title: Text(entry.key,
                style: const TextStyle(
                    color: Color(0xFFD5E7B5), fontWeight: FontWeight.bold)),
            trailing: Text(entry.value.toString(),
                style: const TextStyle(color: Color(0xFFD5E7B5), fontSize: 18)),
          ),
        );
      }).toList(),
    );
  }
}
