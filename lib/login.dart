import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 200),
                alignment: Alignment.topCenter,
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 33,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 300),
                alignment: Alignment.topCenter,
                child: const Text(
                  "Better Slcm",
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 33,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.5,
                  right: 35,
                  left: 35,
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "name.registration",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.cyan,
                      child: IconButton(
                        onPressed: () {
                          // Add your action here
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () async {
                              const url =
                                  'https://passwordreset.microsoftonline.com/';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: const Text(
                              "Forgot Password",
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
