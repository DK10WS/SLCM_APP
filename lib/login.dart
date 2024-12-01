import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    setState(() {
      _usernameController.text = savedUsername;
      _passwordController.text = savedPassword;
    });
  }

  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

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

            _saveCredentials(username, password);

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

  void _toggleLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello,',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome to MUJ Switch',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF24272B),
                  hintText: 'Name.registration',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF24272B),
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    const url = 'https://passwordreset.microsoftonline.com/';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () async {
                    _toggleLoading(true);
                    String username = _usernameController.text;
                    String password = _passwordController.text;

                    final result = await _login(username, password);
                    _toggleLoading(false);

                    if (result != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            name: result['name'] ?? "",
                            newCookies: result['newCookies'] ?? "",
                          ),
                        ),
                      );
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
