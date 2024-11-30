import 'package:flutter/material.dart';
import 'package:mujslcm/attendance.dart';
import 'package:mujslcm/grades.dart';
import 'package:mujslcm/information.dart';
import 'package:mujslcm/marks.dart';
import 'package:mujslcm/timetable.dart';
import 'package:mujslcm/about.dart';
import 'package:mujslcm/cgpa.dart';
import 'login.dart';
import 'session_manager.dart';

// Utility function to capitalize the first name
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
      Timetable(newCookies: widget.newCookies),
      HomeScreen(name: widget.name, newCookies: widget.newCookies),
      Information(newCookies: widget.newCookies),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("MUJ SWITCH",
            style: TextStyle(color: Colors.white, fontFamily: "Gotham")),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            activeIcon: _CircularIconWrapper(icon: Icons.book),
            label: 'Time Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: _CircularIconWrapper(icon: Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: _CircularIconWrapper(icon: Icons.person),
            label: 'Me',
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${capitalizeFirstName(name)}",
              style: const TextStyle(
                  fontSize: 24, color: Colors.white, fontFamily: "Gotham"),
            ),
            const SizedBox(height: 20),
            ChatButton(
              label: "Attendance",
              icon: Icons.check_circle_outline,
              onTap: () =>
                  _navigateTo(context, AttendancePage(newCookies: newCookies)),
            ),
            ChatButton(
              label: "Internal Marks",
              icon: Icons.grade,
              onTap: () => _navigateTo(context, marks(newCookies: newCookies)),
            ),
            ChatButton(
              label: "CGPA/GPA and Credits",
              icon: Icons.grade,
              onTap: () => _navigateTo(context, CGPA(newCookies: newCookies)),
            ),
            ChatButton(
              label: "Grades",
              icon: Icons.grade_rounded,
              onTap: () => _navigateTo(context, Grades(newCookies: newCookies)),
            ),
            ChatButton(
              label: "About",
              icon: Icons.info,
              onTap: () => _navigateTo(context, About(newCookies: newCookies)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class ChatButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ChatButton(
      {Key? key, required this.label, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.cyan,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: "Poppins")),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CircularIconWrapper extends StatelessWidget {
  final IconData icon;

  const _CircularIconWrapper({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyan,
      ),
      child: Icon(icon, size: 28, color: Colors.white),
    );
  }
}
