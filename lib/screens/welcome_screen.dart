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
  late final StreamSubscription<AuthState> _authStateSubscription;
  

  /// Handles user authentication via Supabase's magic link.
  ///
  /// - If '_isRegistered' is 'false', it gives user feedback to confirm sign up via email.
  /// - If '_isRegistered' is 'true', it gives user feedback to sign in via email.
  Future<void> _handleAuth() async {
    final action = _isRegistered ? 'New User? Create Account' : 'Sign In';
    try {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();

      // Check if the email exists in the "profiles" table
      final response = await supabase
          .from('profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle(); // Use maybeSingle to allow for 0 or 1 result without throwing, so that rest of the response checks go through

      if (response != null && _isRegistered) {
        // Email exists and user is trying to sign up; notify to sign in instead
        if (mounted) {
          context.showSnackBar(
            'This email is already registered. Please sign in instead.',
            isError: false,
          );
        }
        return; // Exit to return user to the welcome page
      } else if (response == null && !_isRegistered) {
        // Email does not exist and user is trying to sign in; notify to sign up
        if (mounted) {
          context.showSnackBar(
            'No account found for this email. Please sign up.',
            isError: false,
          );
        }
        return; // Exit to return the user to the welcome page
      }

      // Proceed with sign-in or sign-up using Supabase's own auth
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        // Show the feedback message when a link is sent
        final message = _isRegistered
            ? 'Check your email to confirm sign up!'
            : 'Check your email for a login link!';
        context.showSnackBar(message);
        _emailController.clear();
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBar(
          '$action failed: ${error.message}',
          isError: true,
        );
      }
    } on AuthException catch (error) {
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
void initState() {
  super.initState();

  // Check for existing session
  final session = supabase.auth.currentSession;
  if (session != null) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
  }

  // Listen for authentication state changes
  _authStateSubscription = supabase.auth.onAuthStateChange.listen(
    (data) {
      final session = data.session;
      if (session != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
      }
    },
    onError: (error) {
      if (mounted) {
        context.showSnackBar('Error: ${error.toString()}', isError: true);
      }
    },
  );
}


  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
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
              style: ButtonStyles.filled,
              onPressed: _isLoading ? null : _handleAuth,
              child: Text(
                _isLoading
                    ? 'Please wait...'
                    : (_isRegistered ? 'Create an account' : 'Sign in'),
              ),
            ),
            // My magnificent solution for margin / gap.
            const SizedBox(height: 15),
            const Text('Or'),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyles.filled,
              onPressed: () {
                setState(() {
                  _isRegistered = !_isRegistered;
                  _emailController.clear();
                });
              },
              child: Text(
                _isRegistered ? 'Back to Sign In' : 'Create an account',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
