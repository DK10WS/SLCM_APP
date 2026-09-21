import 'package:flutter/material.dart';
import 'package:mujslcm/core/theme/app_colors.dart';
import 'package:mujslcm/features/auth/data/auth_repository.dart';

class ChangePasswordPage extends StatefulWidget {
  final String sessionCookie;
  const ChangePasswordPage({super.key, required this.sessionCookie});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _newPassVisible = false;
  bool _confirmPassVisible = false;
  String _strengthFeedback = "";
  Color _feedbackColor = Colors.red;

  @override
  void initState() {
    super.initState();
    newPassController.addListener(_updatePasswordFeedback);
  }

  void _updatePasswordFeedback() {
    final password = newPassController.text;
    final result = validatePasswordStrength(password);

    setState(() {
      if (password.isEmpty) {
        _strengthFeedback = "";
      } else if (result['strength'] == 5) {
        _strengthFeedback = "Strong password";
        _feedbackColor = Colors.green;
      } else {
        _strengthFeedback =
            "Weak: ${(result['feedback'] as List<String>).join(', ')}";
        _feedbackColor = Colors.red;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final newPass = newPassController.text;
    final confirmPass = confirmPassController.text;

    final result = validatePasswordStrength(newPass);

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showError("Both fields are required.");
      return;
    }

    if (newPass != confirmPass) {
      _showError("Passwords do not match.");
      return;
    }

    if (result['strength'] != 5) {
      _showError("Password does not meet all strength requirements.");
      return;
    }

    setState(() => _isLoading = true);
    final success = await changePassword(widget.sessionCookie, newPass);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    } else {
      _showError("Failed to change password.");
    }
  }

  Future<bool> changePassword(String cookies, String newPassword) =>
      AuthRepository.changePassword(cookies, newPassword);

  Map<String, dynamic> validatePasswordStrength(String password) {
    int strength = 0;
    List<String> feedback = [];

    if (password.length >= 8) {
      strength++;
    } else {
      feedback.add("At least 8 characters");
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength++;
    } else {
      feedback.add("One uppercase letter");
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    } else {
      feedback.add("One lowercase letter");
    }

    if (RegExp(r'\d').hasMatch(password)) {
      strength++;
    } else {
      feedback.add("One number");
    }

    if (RegExp(r'[@$!%*?&]').hasMatch(password)) {
      strength++;
    } else {
      feedback.add("One special character (@\$!%*?&)");
    }

    return {"strength": strength, "feedback": feedback};
  }

  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: newPassController,
                  obscureText: !_newPassVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFill,
                    hintText: 'Enter new password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _newPassVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _newPassVisible = !_newPassVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  _strengthFeedback,
                  style: TextStyle(color: _feedbackColor, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPassController,
                  obscureText: !_confirmPassVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFill,
                    hintText: 'Confirm new password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPassVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPassVisible = !_confirmPassVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
