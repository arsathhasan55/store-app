import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCreatePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _signup() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    
    if(!email.contains('@')) {
       email = '$email@gmail.com'; // Fallback if they just entered username
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthService>().signUpWithEmailPassword('$firstName $lastName', email, password);
      navigator.pop(); // Go back to login/home
    } on FirebaseAuthException catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249); // Gold color
    const Color backgroundColor = Color(0xFF1A1A1A); // Dark background
    const Color fieldColor = Color(0xFFE4E4E4); // Light gray for fields

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Text(
                'MLAH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Georgia',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'FASHION STORE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Titles
              const Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign up to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              
              // Name Section
              const Text(
                'Name',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallTextField(controller: _firstNameController, hintText: 'first', fillColor: fieldColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallTextField(controller: _lastNameController, hintText: 'Last', fillColor: fieldColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Username Section
              const Text(
                'choose your username',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextFieldWithSuffix(
                controller: _emailController,
                hintText: '',
                fillColor: fieldColor,
                suffixText: '@gmail.com',
              ),
              const SizedBox(height: 4),
              const Text(
                'i prefer to use my current email adderess',
                style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Create Password
              const Text(
                'create a password',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _passwordController,
                hintText: '',
                fillColor: fieldColor,
                obscureText: _obscureCreatePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCreatePassword = !_obscureCreatePassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              const Text(
                'confirm your password',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: '',
                fillColor: fieldColor,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Birthday
              const Text(
                'Birthday',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(flex: 3, child: _buildSmallTextField(hintText: 'month', fillColor: fieldColor)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildSmallTextField(hintText: 'day', fillColor: fieldColor)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildSmallTextField(hintText: 'year', fillColor: fieldColor)),
                ],
              ),
              const SizedBox(height: 16),

              // Gender
              const Text(
                'Gender',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Georgia', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildSmallTextField(hintText: 'iam...', fillColor: fieldColor),
                  ),
                  const Expanded(flex: 1, child: SizedBox()), // empty space on right
                ],
              ),
              const SizedBox(height: 32),

              // Sign Up Button
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Georgia'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallTextField({TextEditingController? controller, required String hintText, required Color fillColor}) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16), // Rounded pill-like shape
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTextFieldWithSuffix({TextEditingController? controller, required String hintText, required String suffixText, required Color fillColor}) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hintText,
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    TextEditingController? controller,
    required String hintText,
    required Color fillColor,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          isDense: true,
        ),
      ),
    );
  }
}
