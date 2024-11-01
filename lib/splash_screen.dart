import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'welcome_screen.dart'; // Import your WelcomeScreen
import 'login_screen.dart';
// Import other necessary screens

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    // Add a delay to simulate loading
    await Future.delayed(Duration(seconds: 2));

    User? user = FirebaseAuth.instance.currentUser;

    // Navigate to the appropriate screen based on authentication status
    if (user != null) {
      // User is logged in, navigate to the main app screen
      // Replace with your main app screen
      Navigator.pushReplacementNamed(context, '/main'); 
    } else {
      // User is not logged in, navigate to the welcome screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: Color(0xFF0001), //0b0014
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/jlk_logo.png', // Replace with your app logo asset path
              height: 100,
              width: 100,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Display a loading indicator
          ],
        ),
      ),
    );
  }
}