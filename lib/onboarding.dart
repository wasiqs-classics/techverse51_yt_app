import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top image or logo
            Image.asset(
              'assets/welcome_image.png', // Replace with your own image
              height: 150,
            ),
            const SizedBox(height: 20),
            // Welcome message
            const Text(
              'Welcome to Techverse 51',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Explore courses, track your progress, and connect with a community of learners!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Sign In/Sign Up button
            ElevatedButton.icon(
              onPressed: () => _signInWithGoogle(),
              icon: Image.asset('assets/google_logo.png',
                  height: 24), // Replace with Google logo
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            // Explore as Guest button
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/home'); // Navigate to home as guest
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Explore as Guest'),
            ),
            const Spacer(),
            // Links at the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to About Techverse 51
                  },
                  child: const Text('About Techverse 51'),
                ),
                const Text('|', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    // Navigate to About the Developer
                  },
                  child: const Text('About the Developer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
