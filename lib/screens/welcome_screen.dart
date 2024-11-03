import 'package:flutter/material.dart';
import 'package:grocy/screens/login_screen.dart';

/// The welcome page that user lands on if they're not already signed in.
/// Allows user to sign in or sign up.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the button style
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(200, 60),
      padding: const EdgeInsets.symmetric(
          horizontal: 30, vertical: 20),
      textStyle: const TextStyle(fontSize: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'Welcome',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        // Just to lower the welcome to not hit the top of the phone.
        toolbarHeight: 80,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: buttonStyle,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const LoginPage(isRegistered: false))),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 15),
            const Text('Or'),
            const SizedBox(height: 15),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const LoginPage(isRegistered: true))),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
