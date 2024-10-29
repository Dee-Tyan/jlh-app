import 'package:flutter/material.dart';
import 'authentication_screen.dart'; // Import your AuthenticationScreen

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to JLK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'Discover your dream career path and achieve your goals!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Authentication screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthenticationScreen()));
              },
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}