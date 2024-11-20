import 'package:flutter/material.dart';
import 'package:mujslcm/Login.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "login",
    routes: {"login": (context) => const MyLogin()},
  ));
}
