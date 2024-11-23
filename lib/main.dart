import 'package:flutter/material.dart';
import 'package:mujslcm/Login.dart';
import 'package:mujslcm/home_page.dart';
import 'session_manager.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: _initialRoute(),
    routes: {
      'login': (context) => const MyLogin(),
      'home': (context) => const HomePage(name: "User"),
    },
  ));
}

String _initialRoute() {
  return SessionManager.isLoggedIn() ? 'home' : 'login';
}
