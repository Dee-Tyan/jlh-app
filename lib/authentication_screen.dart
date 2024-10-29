import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import your LoginScreen
import 'signup_screen.dart'; // Import your SignupScreen

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignupScreen())); // Navigate to Sign-up
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen())); // Navigate to Log-in
              },
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}