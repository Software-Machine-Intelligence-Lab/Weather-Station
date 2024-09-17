import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    Future<void> sendOTP(String email) async {
      try {
        final Uri url = Uri.parse('http://127.0.0.1:8000/generate_otp/?email=$email');
        final http.Response response = await http.get(url);

        if (response.statusCode == 200) {
          print('OTP sent successfully.');
          // Optionally, you can navigate to the OTP verification page here
        } else {
          print('Failed to send OTP. Error: ${response.body}');
        }
      } catch (error) {
        print('Error sending OTP: $error');
      }
    }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "OTP",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  sendOTP(emailController.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                ),
                child: Text('Send OTP'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Validate and process OTP
                  // You can add your logic here
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                ),
                child: Text('Verify OTP'),
              ),
              SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  // Add navigation to the registration page if needed
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(),
                child: Text(
                  'Back to Registration',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
