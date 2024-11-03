import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocy/main.dart';

/// Allows a user to log in or sign up.
///
/// Uses Supabase with magic link authentication.
/// Open source project used from Supabase: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
class LoginPage extends StatefulWidget {
  // Whether user is registered already or not.
  final bool isRegistered;
  const LoginPage({super.key, required this.isRegistered});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// State class for the login page, manages user authentication.
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  /// Handles user authentication via Superbase's magic link.
  /// Sends a one-time password via email to user.
  Future<void> _handleAuth() async {
    final action = widget.isRegistered ? 'Sign Up' : 'Sign In';
    try {
      setState(() { _isLoading = true; });
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
      if (mounted) {
        final message = widget.isRegistered
            ? 'Check your email to confirm sign up!'
            : 'Check your email for a login link!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        _emailController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action failed: ${error.message}'), backgroundColor: Colors.red));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error during $action'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            widget.isRegistered ? 'Sign Up' : 'Welcome Back',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              style: buttonStyle,
              onPressed: _isLoading ? null : _handleAuth,
              child: Text(_isLoading ? 'Please wait...' : (widget.isRegistered ? 'Sign Up' : 'Sign In')),
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
