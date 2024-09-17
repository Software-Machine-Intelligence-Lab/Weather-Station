import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'variables.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(text:"sayor9928");
  final TextEditingController _passwordController = TextEditingController(text:"123");
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    $username = _emailController.text;

    final response = await http.post(
      Uri.parse($domain+'/login/'),  // Your API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': _emailController.text,  // Ensure this matches your API expectation
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(context, '/home'); // Navigate to the home page on success
    } else {
      setState(() {
        _isLoading = false;
      });
      final errorData = json.decode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(errorData.containsKey('detail') ? errorData['detail'] : "Invalid login attempt"),
            // Showing error details from the server
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
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
          child: Center(
            child: SingleChildScrollView( // Added to avoid overflow when keyboard appears
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/BDU Logo.png', height: 100),
                  SizedBox(height: 100.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "User Name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
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
                  SizedBox(height: 24.0),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,  // Added to define a button color
                      elevation: 5.0,
                    ),
                    child: Text('Login'),
                  ),
                  SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reg');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Don't have an account? Register here.",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
