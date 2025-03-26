import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'session_manager.dart';
import 'redirects.dart';
import 'dart:async';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;
  var selectedIndex = 0;
  bool sentOTP = false;
  String Gcookie = "";
  String reqname = "";

  @override
  void initState() {
    super.initState();
    _loadSavedLoginType().then((_) {
      _loadSavedCredentialsAndLogin();
    });
  }

  Future<void> _loadSavedLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt('loginType') ?? 0;
    });
  }

  Future<void> _loadSavedCredentialsAndLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    setState(() {
      _usernameController.text = savedUsername;
      _passwordController.text = savedPassword;
    });

    if (!SessionManager.loggedOut &&
        savedUsername.isNotEmpty &&
        savedPassword.isNotEmpty &&
        selectedIndex == 0) {
      _toggleLoading(true);
      final result = await _login(savedUsername, savedPassword);
      _toggleLoading(false);

      if (result != null) {
        if (mounted) {
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
      } else {
        _showError("Auto-login failed. Please log in manually.");
      }
    }
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

  Future<Map<String, String?>?> _login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill in both fields.');
      return null;
    }

    final baseurl = loginURL;

    final payload = jsonEncode({
      "username": username,
      "password": password,
    });

    var session = http.Client();

    try {
      final response = await session.post(Uri.parse(baseurl),
          body: payload, headers: header);

      if (response.statusCode == 200) {
        _saveCredentials(username, password);
        final redirectDocument = jsonDecode(response.body);
        final name = redirectDocument["name"];
        final cookies = redirectDocument["login_cookies"];

        return {'name': name ?? '', 'newCookies': cookies};
      } else {
        _showError("Login failed: ${response.body}");
        return null;
      }
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

  void _setLoginType(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginType', index);
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildToggleButtons() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFFD5E7B5).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _setLoginType(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == 0
                        ? const Color(0xFFD5E7B5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Student",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == 0
                          ? Colors.black
                          : const Color(0xFFD5E7B5),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _setLoginType(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == 1
                        ? const Color(0xFFD5E7B5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Parents",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == 1
                          ? Colors.black
                          : const Color(0xFFD5E7B5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF24272B),
            hintText: 'name.registration',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            suffix: const Text(
              '@muj.manipal.edu',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: _isObscure,
          controller: _passwordController,
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
              style: TextStyle(color: Color(0xFFD5E7B5)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD5E7B5),
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
                if (mounted) {
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
              }
            },
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  )
                : const Text('Login'),
          ),
        ),
      ],
    );
  }

  final TextEditingController _otpController = TextEditingController();

  int _remainingTime = 120;
  Timer? _timer;

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    final result = await otpLogin(_otpController.text);

    if (result) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              name: reqname ?? "",
              newCookies: Gcookie ?? "",
            ),
          ),
        );
      }
    }
  }

  Widget _VerifyOTP() {
    _startTimer();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time Remaining: ${_formatTime(_remainingTime)}",
          style: const TextStyle(
              color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _otpController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF24272B),
            hintText: 'Enter OTP',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD5E7B5),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: _remainingTime > 0 ? _verifyOTP : _resendOTP,
            child: _remainingTime > 0
                ? (_isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.black),
                      )
                    : const Text('Login'))
                : const Text('Resend OTP'),
          ),
        ),
      ],
    );
  }

  void _resendOTP() async {
    var session = http.Client();

    var headers = {'Content-Type': 'application/json'};

    final expirepayload = jsonEncode({"login_cookies": Gcookie});

    final expireotpresponse = session.post(Uri.parse(OnExpireURL),
        headers: headers, body: expirepayload);

    final payload = jsonEncode({"login_cookies": Gcookie});

    final response = await session.post(Uri.parse(ResendOTPUrl),
        headers: headers, body: payload);

    final text = jsonDecode(response.body);
    if (text["message"] == "resent otp") {
      print("OTP Sent Successfully!");
      setState(() {
        _remainingTime = 120;
      });
      _startTimer();
    } else {
      print("Failed to send OTP: ${response.statusCode}");
    }
  }

  Widget _buildSendOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF24272B),
            hintText: 'name.regestration',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            suffix: const Text(
              '@muj.manipal.edu',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD5E7B5),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () async {
              _toggleLoading(true);
              String username = _usernameController.text;

              final result = await _Parentslogin(username);
              _toggleLoading(false);
              if (result) {
                sentOTP = true;
              }
            },
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  )
                : const Text('Send OTP'),
          ),
        ),
      ],
    );
  }

  Widget _buildParentLogin() {
    return sentOTP ? _VerifyOTP() : _buildSendOTP();
  }

  Future<bool> otpLogin(String otp) async {
    if (otp.isEmpty) {
      _showError('Please fill in OTP.');
      return false;
    }

    var headers = {'Content-Type': 'application/json'};

    final payload = jsonEncode({
      "cookies": Gcookie,
      "otp": otp,
    });

    final request =
        await http.post(Uri.parse(SendOTP), headers: headers, body: payload);
    final text = jsonDecode(request.body);
    print(text);
    if (text["message"] == "logged in sucessfully") {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _Parentslogin(String username_login) async {
    var headers = {'Content-Type': 'application/json'};

    if (username_login.isEmpty) {
      _showError('Please fill in the username field.');
      return false;
    }

    username_login = username_login + "@muj.manipal.edu";

    final payload = jsonEncode({
      "username": username_login,
    });

    final respone =
        await http.post(Uri.parse(HomeURL), headers: headers, body: payload);
    final text = jsonDecode(respone.body);
    reqname = text["name"];
    Gcookie = text["login_cookies"];
    print(Gcookie);
    if (text["message"] == "OTP sent successfully") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
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
                  color: Color(0xFFD5E7B5),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome to SLCM Switch',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              _buildToggleButtons(),
              const SizedBox(height: 32),
              selectedIndex == 0 ? _buildStudentLogin() : _buildParentLogin(),
            ],
          ),
        ),
      ),
    );
  }
}
