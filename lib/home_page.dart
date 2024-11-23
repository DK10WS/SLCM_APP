import 'package:flutter/material.dart';
import 'package:mujslcm/Attendance.dart';
import 'login.dart';
import 'session_manager.dart';

class HomePage extends StatelessWidget {
  final String name;
  final String newCookies;

  const HomePage({Key? key, required this.name, required this.newCookies})
      : super(key: key);

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
      body: Padding(
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
      ),
    );
  }
}
