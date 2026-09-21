import 'package:flutter/material.dart';
import 'package:mujslcm/core/session/session_store.dart';
import 'package:mujslcm/features/auth/data/auth_repository.dart';
import 'package:mujslcm/features/auth/presentation/login_page.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository.bindSessionRefresh();

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
  return SessionStore.isLoggedIn() ? 'home' : 'login';
}
