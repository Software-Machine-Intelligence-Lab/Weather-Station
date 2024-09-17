import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:demo1/pages/variables.dart';

class User {
  final String username;
  final String password;
  final String email;
  final String role;
  final String otp;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'role': role,
      'otp': otp,
    };
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Regular expressions for form validation
  final RegExp usernameRegex = RegExp(r'^.{6,}[a-zA-Z0-9_]+$');
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp passwordRegex = RegExp(r'^.{6,}$');

  void _dialogOtpSendingLoading() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OTP Sending'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> sendOTP() async {
    if (_formKey.currentState!.validate()) {
      _dialogOtpSendingLoading();
      final Uri url = Uri.parse($domain+'/generate_otp/?email=${emailController.text}');
      final http.Response response = await http.post(url);

      Navigator.of(context).pop(); // Close loading dialog
      if (response.statusCode == 200) {
        _dialogEnterOtpForVerification();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP')),
        );
      }
    }
  }

  void _dialogEnterOtpForVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify OTP'),
          content: TextField(
            controller: otpController,
            decoration: InputDecoration(labelText: 'Enter OTP'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _submitOtp(),
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitOtp() async {
    final user = User(
      username: usernameController.text,
      password: passwordController.text,
      email: emailController.text,
      role: roleController.text,
      otp: otpController.text,
    );

    final Uri url = Uri.parse($domain+'/users/');
    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    Navigator.of(context).pop(); // Close the OTP verification dialog
    if (response.statusCode == 200) {
      Navigator.pushNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User successfully created')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgm.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/BDU Logo.png', height: 100),
                SizedBox(height: 100.0),
                TextFormField(
                  controller: usernameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    } else if (!usernameRegex.hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Username",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: roleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your role';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Role",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: sendOTP,
                  style: ElevatedButton.styleFrom(
                    elevation: 5.0,
                  ),
                  child: Text('Sign Up'),
                ),
                SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Already have an account? Login here.',
                      style: TextStyle(color: Colors.black),
                    ),
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
