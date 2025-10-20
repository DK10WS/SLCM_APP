import 'package:flutter/material.dart';
import 'package:mujslcm/pages/login.dart';
import 'session_manager.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: _initialRoute(),
    routes: {
      'login': (context) => const MyLogin(),
    },
  ));
}

String _initialRoute() {
  return SessionManager.isLoggedIn() ? 'home' : 'login';
}
