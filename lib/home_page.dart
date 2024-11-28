import 'package:flutter/material.dart';
import 'package:mujslcm/Attendance.dart';
import 'package:mujslcm/information.dart';
import 'package:mujslcm/timetable.dart';
import 'login.dart';
import 'session_manager.dart';
import 'about.dart';
import 'grades.dart';

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

  String capitalizeFirstName(String fullName) {
    if (fullName.isEmpty) return fullName;
    String firstName = fullName.split(' ')[0];
    return firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Welcome ${capitalizeFirstName(widget.name)}",
          style: const TextStyle(color: Colors.white, fontFamily: "Gotham"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              SessionManager.clearSession();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyLogin()),
                (route) => false,
              );
            },
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
            label: 'Time Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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

  String capitalizeFirstName(String fullName) {
    if (fullName.isEmpty) return fullName;
    String firstName = fullName.split(' ')[0];
    return firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
  }

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
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ChatButton(
              label: "Attendance",
              icon: Icons.check_circle_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendancePage(
                      newCookies: newCookies,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ChatButton(
              label: "CGPA/GPA and Credits",
              icon: Icons.grade,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Grades(newCookies: newCookies),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ChatButton(
              label: "About",
              icon: Icons.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => About(newCookies: newCookies),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ChatButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 8), // Add space between buttons
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black, // Background similar to WhatsApp
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade800, // Divider line like WhatsApp
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.cyan,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
