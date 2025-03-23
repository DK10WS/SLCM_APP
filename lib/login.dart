import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'session_manager.dart';
import 'package:local_auth/local_auth.dart';
import 'redirects.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSavedCredentialsAndLogin();
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
    if (!SessionManager.loggedOut &&
        savedUsername.isNotEmpty &&
        savedPassword.isNotEmpty) {
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

  Future<Map<String, String>?> _login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill in both fields.');
      return null;
    }

    var url = loginURL;
    var baseurl = loginURL;

    final headers = {
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
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
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF24272B),
                  hintText: 'Username',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  suffix: Text(
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
                      color: Color(0xFFD5E7B5),
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () async {
                      if (_isObscure) {
                        // Password is currently hidden, attempt authentication before showing
                        bool canAuthenticate = await auth.canCheckBiometrics ||
                            await auth.isDeviceSupported();

                        if (canAuthenticate) {
                          try {
                            bool didAuthenticate = await auth.authenticate(
                              localizedReason:
                                  'Please authenticate to show password',
                              options: const AuthenticationOptions(
                                  biometricOnly: false),
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
                          // If authentication is not available, show password without authentication
                          setState(() {
                            _isObscure = false;
                          });
                        }
                      } else {
                        // Password is currently visible, hide it without authentication
                        setState(() {
                          _isObscure = true;
                        });
                      }
                    },
                  ),
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
                    backgroundColor: Color(0xFFD5E7B5),
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
          ),
        ),
      ),
    );
  }
}
