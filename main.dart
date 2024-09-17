import 'package:flutter/material.dart';
import 'pages/DarkProfile.dart';
import 'pages/DarkSettingPage.dart';
import 'pages/loginpage.dart';
import 'pages/registration.dart';
import 'pages/home.dart';
import 'pages/settings.dart';
import 'pages/profile.dart';
import 'pages/DarkHome.dart';
import 'pages/otp.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/reg': (context) => RegistrationPage(),
        '/home': (context) => HomePage(), // Add this line
        '/settings': (context) => SettingsPage(),
        '/profile':(context) => ProfilePage(),
        '/darksettings': (context) => DarkSettingsPage(),
        '/darkhome': (context) => DarkHomePage(),
        '/darkprofile': (context) => DarkProfilePage(),
        '/otp': (context) => OtpPage(),

      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After 1 seconds, navigate to the login page
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/BDU Logo.png'),
      ),
    );
  }
}
