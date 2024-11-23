import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'session_manager.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  String extractSessionId(String cookie) {
    final parts = cookie.split(';');
    return parts.isNotEmpty ? parts[0].trim() : '';
  }

  Future<Map<String, String>?> _login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill in both fields.');
      return null;
    }

    const url = "https://mujslcm.jaipur.manipal.edu:122/";
    const baseurl = "https://mujslcm.jaipur.manipal.edu:122";

    final headers = {
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
      "Referer": url,
    };

    var session = http.Client();
    try {
      final response = await session.get(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        _showError("Failed to fetch login page.");
        return null;
      }

      final document = parse(response.body);
      final tokenElement =
          document.querySelector('input[name="__RequestVerificationToken"]');
      final token = tokenElement?.attributes['value'];
      final cookies = response.headers['set-cookie'];

      if (token == null || cookies == null) {
        _showError("Token or session cookies missing.");
        return null;
      }

      final cleanedCookies = cookies
          .split(',')
          .map((cookie) => extractSessionId(cookie))
          .join(';');

      final payload = {
        "__RequestVerificationToken": token,
        "EmailFor": "@muj.manipal.edu",
        "LoginFor": "2",
        "UserName": username,
        "Password": password,
      };

      final headersForLogin = {
        ...headers,
        'Cookie': cleanedCookies,
      };

      final loginResponse = await session.post(
        Uri.parse(url),
        headers: headersForLogin,
        body: payload,
      );
      var API = loginResponse.headers['set-cookie'];
      final cleanedAPI = API != null
          ? API.split(',').map((cookie) => extractSessionId(cookie)).join(';')
          : '';

      if (loginResponse.statusCode == 302) {
        final locationHeader = loginResponse.headers['location'];
        if (locationHeader != null) {
          final redirectedUrl = Uri.parse(baseurl + locationHeader);

          final newCookies =
              cleanedCookies + (cleanedAPI.isNotEmpty ? '; $cleanedAPI' : '');

          final redirectResponse = await session.get(
            redirectedUrl,
            headers: {
              'Cookie': newCookies,
              ...headers,
            },
          );

          if (redirectResponse.statusCode == 200) {
            final redirectDocument = parse(redirectResponse.body);
            final name = redirectDocument
                .querySelector('.kt-user-card__name')
                ?.text
                .trim();

            SessionManager.setSession(cleanedCookies + '; ' + cleanedAPI);

            return {'name': name ?? '', 'newCookies': newCookies};
          }
        }
      }

      _showError("Login failed. Please check your credentials.");
      return null;
    } catch (e) {
      _showError("An error occurred: $e");
      return null;
    } finally {
      session.close();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Toggle loading spinner
  void _toggleLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "name.registration",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _passwordController,
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
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : IconButton(
                              onPressed: () async {
                                _toggleLoading(true);
                                String username = _usernameController.text;
                                String password = _passwordController.text;

                                Map<String, String>? loginResult =
                                    await _login(username, password);
                                _toggleLoading(false);

                                if (loginResult != null) {
                                  String name = loginResult['name']!;
                                  String newCookies =
                                      loginResult['newCookies']!;

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(
                                        name: name,
                                        newCookies: newCookies,
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
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
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
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
