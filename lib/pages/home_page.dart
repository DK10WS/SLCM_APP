import 'package:flutter/material.dart';
import 'package:mujslcm/pages/Attendance.dart';
import 'package:mujslcm/pages/grades.dart';
import 'package:mujslcm/pages/information.dart';
import 'package:mujslcm/pages/marks.dart';
import 'package:mujslcm/pages/settings.dart';
import 'package:mujslcm/pages/timetable.dart';
import 'package:mujslcm/pages/cgpa.dart';
import 'login.dart';
import 'package:mujslcm/session_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

String capitalizeFirstName(String fullName) {
  if (fullName.isEmpty) return fullName;
  String firstName = fullName.split(' ')[0];
  return firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
}

class HomePage extends StatefulWidget {
  final String name;
  final String newCookies;

  const HomePage({Key? key, required this.name, required this.newCookies})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Information(),
      HomeScreen(name: widget.name, newCookies: widget.newCookies),
      Settings(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    SessionManager.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyLogin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121316),
        title: const Text(
          "SLCM SWITCH",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD5E7B5)),
            onPressed: _logout,
          ),
        ],
        scrolledUnderElevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF232531),
          indicatorColor: Colors.transparent,
          indicatorShape: CircleBorder(),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFFE7F5D5).withOpacity(0.1),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Color(0xFFD5E7B5)),
              selectedIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0
                      ? Color(0xFFD5E7B5)
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.person, color: Colors.black),
              ),
              label: 'Me',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFFD5E7B5)),
              selectedIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1
                      ? Color(0xFFD5E7B5)
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.home, color: Colors.black),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.contact_support_outlined,
                color: Color(0xFFD5E7B5),
                size: 20,
              ),
              selectedIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 2
                      ? Color(0xFFD5E7B5)
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.contact_support, color: Colors.black),
              ),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String name;
  final String newCookies;

  const HomeScreen({Key? key, required this.name, required this.newCookies})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello,",
              style: TextStyle(
                  fontSize: 24, color: Colors.white, fontFamily: "poppins"),
            ),
            Text(
              "${capitalizeFirstName(name)}",
              style: TextStyle(
                  fontSize: screenWidth * 0.1,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto"),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: screenWidth * 0.44,
                width: screenWidth * 0.9,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFffcb69),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    _navigateTo(context, Timetable());
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -70,
                        left: 45,
                        child: SvgPicture.asset(
                          'assets/svg/timetable.svg',
                          height: screenWidth * 1.15,
                          width: screenWidth * 1.1,
                          color: const Color(0xFFE0A84F).withOpacity(0.8),
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        child: Text(
                          "Time Table",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _attendanceCard(context, screenWidth),
                _marksCard(context, screenWidth),
                _cgpaCard(context, screenWidth),
                _gradesCard(context, screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceCard(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () => _navigateTo(context, AttendancePage()),
      child: Container(
        height: screenWidth * 0.6,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFffac81),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 10,
              child: SvgPicture.asset('assets/svg/people.svg',
                  height: screenWidth * 0.27,
                  width: screenWidth * 0.5,
                  color: const Color(0xFFE08E63).withOpacity(0.8)),
            ),
            const Positioned(
              bottom: 10,
              child: Text(
                "Attendance",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marksCard(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () => _navigateTo(context, Marks()),
      child: ClipRRect(
        // Ensures border radius applies to children too
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: screenWidth * 0.6,
          width: screenWidth * 0.9,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFcdeac0),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -33,
                right: 43,
                child: SvgPicture.asset(
                  'assets/svg/cap.svg',
                  height: screenWidth * 0.45,
                  width: screenWidth * 0.6,
                  color: const Color(0xFFA8C79D).withOpacity(0.8),
                ),
              ),
              const Positioned(
                bottom: 10,
                child: Text(
                  "Marks",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cgpaCard(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () => _navigateTo(context, CGPA()),
      child: Container(
        height: screenWidth * 0.6,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFff928b),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -20,
              right: 32,
              child: SvgPicture.asset(
                'assets/svg/graph.svg',
                height: screenWidth * 0.4,
                width: screenWidth * 0.2,
                color: const Color(0xFFCC756F).withOpacity(0.8),
              ),
            ),
            const Positioned(
              bottom: 10,
              child: Text(
                "CGPA",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradesCard(BuildContext context, double screenWidth) {
    return InkWell(
        onTap: () => _navigateTo(context, Grades()),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: screenWidth * 0.6,
            width: screenWidth * 0.9,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF9ab7d3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -30,
                  right: -20,
                  child: SvgPicture.asset(
                    'assets/images/grades.svg',
                    height: screenWidth * 0.36,
                    width: screenWidth * 0.2,
                    color: const Color(0xFF7695B3).withOpacity(0.8),
                  ),
                ),
                const Positioned(
                  bottom: 10,
                  child: Text(
                    "Grades",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: "Monserat",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
