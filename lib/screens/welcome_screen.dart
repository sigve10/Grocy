import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'account_screen.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'package:grocy/styling/button_styles.dart';
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
    final action = _isRegistered ? 'New User? Create Account' : 'Sign In';

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim().toLowerCase();
    // Because the message should never be null, I am not using String? here.
    String message = '';

    try {
      // Check if the email exists in the "profiles" table
      final response = await supabase
          .from('profiles')
          .select('email')
          .ilike('email', email)
          .maybeSingle();

      if (response != null && _isRegistered) {
        message = 'This email is already registered. Please sign in instead.';
      } else if (response == null && !_isRegistered) {
        message = 'No account found for this email. Please sign up.';
      } else {
        try {
          await supabase.auth.signInWithOtp(
            email: email,
            emailRedirectTo: kIsWeb
                ? null
                : 'io.supabase.flutterquickstart://login-callback/',
          );
          message = _isRegistered
              ? 'Check your email to confirm sign up!'
              : 'Check your email for a login link!';
          _emailController.clear();
        } on AuthException catch (error) {
          message = '$action failed: ${error.message}';
        }
      }

      if (mounted) {
        context.showSnackBar(message,
            isError: message.startsWith('$action failed'));
      }
    } on PostgrestException catch (error) {
      if (mounted) {
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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'Welcome',
            style: TextStyle(
              fontSize: 32,
            ),
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 350,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 18),
                    hintText: 'Olenordmann@hotmail.com',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              style: ButtonStyles.filled,
              onPressed: _isLoading ? null : _handleAuth,
              child: Text(
                _isLoading
                    ? 'Please wait...'
                    : (_isRegistered ? 'Submit' : 'Sign in'),
              ),
            ),
            // My magnificent solution for margin / gap.
            const SizedBox(height: 15),
            const Text('Or'),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyles.outlined,
              onPressed: () {
                setState(() {
                  _isRegistered = !_isRegistered;
                  _emailController.clear();
                });
              },
              child: Text(
                _isRegistered ? 'Back to Sign In' : 'Create Account',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
