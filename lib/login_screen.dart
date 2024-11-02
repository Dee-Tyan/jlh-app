import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interest_selection_screen.dart';
import 'signup_screen.dart';
import 'recommendations_tab.dart';
import 'main.dart'; // Import your main page
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

const Color babyPowder = Color(0xFFFFF7F7); // Baby Powder
const Color pinkLavender = Color(0xFFFBCAEF); // Pink Lavender
const Color darkPink = Color(0xFF8A1C7C); // Dark Pink
const Color blackOlive = Color(0xFF343633); // Black Olive
const Color licorice = Color(0xFF0B0014); // Licorice

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool interestSelected = prefs.getBool('interestSelected') ?? false;

    if (!interestSelected) {
      // Check Firebase for interest selection
      final user = FirebaseAuth.instance.currentUser;
      final interestsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      interestSelected = interestsDoc.exists && interestsDoc.data()?['interestSelected'] == true;

      // Save locally to SharedPreferences for future logins
      if (interestSelected) {
        await prefs.setBool('interestSelected', true);
      }
    }

    // Navigate based on interest selection status
    if (interestSelected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationsTab(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InterestSelectionScreen(),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = e.message;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In', style: TextStyle(color: Colors.white)),
        backgroundColor: darkPink,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hey Girl, Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                  ),
                ),
                SizedBox(height: 20),
                if (_errorMessage != null) // Display error message
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: darkPink),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: darkPink),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _login();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkLavender,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Log In'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: darkPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
