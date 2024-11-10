import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_complete_screen.dart'; // Import OnboardingCompleteScreen

class InterestSelectionScreen extends StatefulWidget {
  @override
  _InterestSelectionScreenState createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  List<String> _selectedInterests = [];
  final List<String> _allInterests = [
    "Software Engineering",
    "Medicine",
    "Software Design",
    "Business",
    "Music",
    "Art",
  ]; // Add more interests here

  Future<void> _saveInterestsToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'interests': _selectedInterests});
        print("Interests saved successfully!");
        await Navigator.pushReplacementNamed(context, '/imageUpload');
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OnboardingCompleteScreen(),
        //   ),
        // );
      } else {
        print("User is not logged in!");
        // Handle the case where the user is not logged in.
        // You might want to navigate back to the login/signup screen.
      }
    } catch (e) {
      print('Error saving interests: $e');
      // Handle the error appropriately (e.g., show an error message to the user).
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Interests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your career interests:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _allInterests.length,
                itemBuilder: (context, index) {
                  final interest = _allInterests[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (_selectedInterests.contains(interest)) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedInterests.contains(interest)
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          interest,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _selectedInterests.contains(interest)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveInterestsToFirestore(); // Save to Firestore
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
