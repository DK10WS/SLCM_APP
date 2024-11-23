import 'package:flutter/material.dart';
import 'package:mujslcm/Attendance.dart';
import 'package:mujslcm/information.dart';
import 'package:mujslcm/timetable.dart';
import 'login.dart';
import 'session_manager.dart';

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
      HomeScreen(newCookies: widget.newCookies),
      Information(newCookies: widget.newCookies),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Better Slcm"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
  final String newCookies;

  const HomeScreen({Key? key, required this.newCookies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "New Features Coming Soon ....",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendancePage(
                        newCookies: newCookies,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Attendance",
                  style: TextStyle(fontFamily: "DancingScript"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
