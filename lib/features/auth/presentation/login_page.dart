import 'package:flutter/material.dart';
import 'package:mujslcm/core/theme/app_colors.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mujslcm/features/home/presentation/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mujslcm/core/constants/urls.dart';
import 'package:mujslcm/core/network/slcm_client.dart';
import 'package:mujslcm/core/session/session_store.dart';
import 'package:mujslcm/features/auth/data/auth_repository.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'change_password_page.dart';
import 'package:dio/dio.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;
  var selectedIndex = 0;
  bool sentOTP = false;
  String Gcookie = "";

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

    // Prevent auto-login if loggedOut is true
    if (!SessionStore.loggedOut &&
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

  Future<Map<String, String>?> _login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill in both fields.');
      return null;
    }

    try {
      final result =
          await AuthRepository.loginStudentFull(username, password);
      if (result.cookies.isEmpty) {
        _showError("Login failed. Please check your credentials.");
        return null;
      }

      final locationHeader = result.location;
      if (locationHeader == null) {
        _showError("Login failed. Please check your credentials.");
        return null;
      }

      if (locationHeader.contains('/Home/ChangePassword')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChangePasswordPage(sessionCookie: result.cookies),
          ),
        );
        return null;
      }

      final redirectResponse = await slcm.get(
        Urls.login + locationHeader,
        headers: {'Cookie': result.cookies},
      );

      if (redirectResponse.statusCode == 200) {
        final redirectDocument = parse(redirectResponse.data);
        final name =
            redirectDocument.querySelector('.kt-user-card__name')?.text.trim();

        _saveCredentials(username, password);

        SessionStore.set(result.cookies);

        return {'name': name ?? '', 'newCookies': result.cookies};
      }

      _showError("Login failed. Please check your credentials.");
      return null;
    } catch (e) {
      _showError("An error occurred: $e");
      return null;
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
          color: AppColors.accent.withOpacity(0.2),
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
                        ? AppColors.accent
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
                          : AppColors.accent,
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
                        ? AppColors.accent
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
                          : AppColors.accent,
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
            fillColor: AppColors.inputFill,
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
            suffixIcon: IconButton(
              icon: Icon(
                color: AppColors.accent,
                _isObscure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () async {
                if (_isObscure) {
                  bool canAuthenticate = await auth.canCheckBiometrics ||
                      await auth.isDeviceSupported();

                  if (canAuthenticate) {
                    try {
                      bool didAuthenticate = await auth.authenticate(
                        localizedReason: 'Please authenticate to show password',
                        options:
                            const AuthenticationOptions(biometricOnly: false),
                      );

                      if (didAuthenticate) {
                        setState(() {
                          _isObscure = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    setState(() {
                      _isObscure = false;
                    });
                  }
                } else {
                  setState(() {
                    _isObscure = true;
                  });
                }
              },
            ),
            filled: true,
            fillColor: AppColors.inputFill,
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
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
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

    if (result?["name"] != "") {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              name: result?['name'] ?? "",
              newCookies: result?['newCookies'] ?? "",
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
            fillColor: AppColors.inputFill,
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
              backgroundColor: AppColors.accent,
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
    final ExpirePayload = {"Flag": "--"};

    final onExpire = await slcm.post(
      Urls.onExpire,
      headers: {'Cookie': Gcookie},
      body: ExpirePayload,
    );

    if (onExpire.statusCode != 200) {
      _showError("Expire request failed: ${onExpire.statusCode}");
      return;
    }

    final payload = {"QnsStr": "--"};

    final response = await slcm.post(Urls.resendOtp, body: payload);

    if (response.statusCode == 200) {
      print("OTP Sent Successfully!");
      setState(() {
        _remainingTime = 120;
      });
      _startTimer();
    } else {
      _showError("Failed to send OTP: ${response.statusCode}");
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
            fillColor: AppColors.inputFill,
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
              backgroundColor: AppColors.accent,
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

  Future<Map<String, String>?> otpLogin(String otp) async {
    if (otp.isEmpty) {
      _showError('Please fill in OTP.');
      return null;
    }

    final payload = {
      "OTP": otp,
    };

    var name = "";

    final otpPage = await slcm.get(
      Urls.otpIndex,
      headers: {'Cookie': Gcookie},
    );

    final document = parse(otpPage.data);

    final tokenElement =
        document.querySelector('input[name="__RequestVerificationToken"]');
    final token = tokenElement?.attributes['value'];

    final response = await slcm.dio.post(Urls.otpValidate,
        data: payload,
        options: Options(
          headers: SlcmClient.defaultHeaders,
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status! < 500,
        ));

    final newpayload = {
      "__RequestVerificationToken": token ?? "",
      "OTPPassword": otp ?? ""
    };
    if (response.data == "Yes") {
      final finalresponse = await slcm.post(Urls.otpIndex, body: newpayload);

      if (finalresponse.statusCode == 302) {
        final request = await slcm.get(Urls.home);
        final redirectDocument = parse(request.data);
        name =
            redirectDocument.querySelector('.kt-user-card__name')!.text.trim();
      }
    } else {
      _showError("Plese Enter Correct OTP");
    }
    return {'name': name ?? "", 'newCookies': Gcookie};
  }

  Future<bool> _Parentslogin(String username) async {
    if (username.isEmpty) {
      _showError('Please fill in the username field.');
      return false;
    }

    try {
      final newCookies = await AuthRepository.loginParent(username);
      if (newCookies.isEmpty) {
        _showError("Invalid Credentials or Server Error");
        return false;
      }
      Gcookie = newCookies;
      return true;
    } catch (e) {
      _showError("An error occurred: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                  color: AppColors.accent,
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
