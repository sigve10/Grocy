import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The welcome page that user lands on if they're not already signed in.
/// Allows user to sign in or sign up.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

/// Manages the state of the welcome page, UI elements and user input.
class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistered = false; // Tracks whether the user is already registered.

  /// Handles user authentication via Supabase's magic link.
  ///
  /// - If '_isRegistered' is 'false', it gives user feedback to confirm sign up via email.
  /// - If '_isRegistered' is 'true', it gives user feedback to sign in via email.
  Future<void> _handleAuth() async {
    final action = _isRegistered ? 'Create Account' : 'Sign In';
    try {
      setState(() {
        _isLoading = true;
      });

      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
      if (mounted) {
        final message = _isRegistered
            ? 'Check your email to confirm sign up!'
            : 'Check your email for a login link!';
        // Uses the snackbar extension previously in the main file.
        context.showSnackBar(message);
        _emailController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) {
        // Uses the extension instead from the new separate file.
        context.showSnackBar('$action failed: ${error.message}', isError: true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error during $action', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(200, 60),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
        toolbarHeight: 80,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width:
                    350, //temporary width. TODO: discuss with group on sizing for this.
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 18),
                    hintText: 'Olenormann@hotmail.com',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              style: buttonStyle,
              onPressed: _isLoading ? null : _handleAuth,
              child: Text(
                _isLoading
                    ? 'Please wait...'
                    : (_isRegistered ? 'Sign Up' : 'Sign In'),
              ),
            ),
            // My magnificent solution for margin / gap.
            const SizedBox(height: 15),
            const Text('Or'),
            const SizedBox(height: 15),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () {
                setState(() {
                  _isRegistered = !_isRegistered;
                  _emailController.clear();
                });
              },
              child: Text(
                _isRegistered ? 'Back to Sign In' : 'Sign Up',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
