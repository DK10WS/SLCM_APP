import 'package:flutter/material.dart';
import 'package:mujslcm/attendance.dart';
import 'package:mujslcm/grades.dart';
import 'package:mujslcm/information.dart';
import 'package:mujslcm/marks.dart';
import 'package:mujslcm/settings.dart';
import 'package:mujslcm/timetable.dart';
import 'package:mujslcm/cgpa.dart';
import 'login.dart';
import 'session_manager.dart';
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
      Information(newCookies: widget.newCookies),
      HomeScreen(name: widget.name, newCookies: widget.newCookies),
      Settings(newCookies: widget.newCookies),
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
          "MUJ SWITCH",
          style: TextStyle(color: Colors.white, fontFamily: "Gotham"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        decoration: const BoxDecoration(
          color: Color(0xFF232531),
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
          backgroundColor: const Color(0xFF232531),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white),
              selectedIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0 ? Colors.cyan : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              label: 'Me',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white),
              selectedIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1 ? Colors.cyan : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.home, color: Colors.white),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
              selectedIcon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 2 ? Colors.cyan : Colors.transparent,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.settings, color: Colors.white),
              ),
              label: 'Settings',
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
                  fontFamily: "poppins"),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: screenWidth * 0.44,
                width: screenWidth * 0.9,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfede67),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () {
                    _navigateTo(context, Timetable(newCookies: newCookies));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -100,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/images/timetable-icon.svg',
                          height: screenWidth * 0.60,
                          width: screenWidth * 0.10,
                          color: const Color(0xFF232531),
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        child: Text(
                          "TIME TABLE",
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
      onTap: () => _navigateTo(context, AttendancePage(newCookies: newCookies)),
      child: Container(
        height: screenWidth * 0.6,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFfc894b),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -31,
              left: -10,
              child: SvgPicture.asset(
                'assets/images/attendance.svg',
                height: screenWidth * 0.35,
                width: screenWidth * 0.6,
                color: const Color(0xFF232531),
              ),
            ),
            const Positioned(
              bottom: 10,
              child: Text(
                "Attendance",
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
    );
  }

  Widget _marksCard(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () => _navigateTo(context, Marks(newCookies: newCookies)),
      child: Container(
        height: screenWidth * 0.6,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFb6f36a),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: SvgPicture.asset(
                'assets/images/marks.svg',
                height: screenWidth * 0.29,
                width: screenWidth * 0.6,
                color: const Color(0xFF232531),
              ),
            ),
            const Positioned(
              bottom: 10,
              child: Text(
                "Marks",
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
    );
  }

  Widget _cgpaCard(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () => _navigateTo(context, CGPA(newCookies: newCookies)),
      child: Container(
        height: screenWidth * 0.6,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFfd6297),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -4,
              child: SvgPicture.asset(
                'assets/images/CGPA.svg',
                height: screenWidth * 0.3,
                width: screenWidth * 0.2,
                color: const Color(0xFF232531),
              ),
            ),
            const Positioned(
              bottom: 10,
              child: Text(
                "CGPA",
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
    );
  }

  Widget _gradesCard(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () => _navigateTo(context, Grades(newCookies: newCookies)),
      child: Container(
        height: screenWidth * 0.6,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF9b77e5),
          borderRadius: BorderRadius.circular(40),
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
                color: const Color(0xFF232531),
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
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
