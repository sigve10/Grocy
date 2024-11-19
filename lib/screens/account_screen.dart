import 'package:flutter/material.dart';
import 'package:grocy/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocy/styling/button_styles.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'package:grocy/main.dart';

/// Provides user profile management via Supabase.
/// Users can see and update their profile, while also signing out.
///
/// Followed a user management app from Supabase, to add authentication with proper security.
/// https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

/// Manages the state of user interactions and data.
class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  var _loading = true;

  /// Called once a user id is received within `onAuthenticated()`
  /// Retrieves the user's profile from Supabase.
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          context.showSnackBar(
            'You are not signed in. Please sign in or register.',
            isError: true,
          );
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
        return;
      }

      final userId = user.id;
      final data =
          await supabase.from('profiles').select().eq('id', userId).single();

      _usernameController.text = data['username'] ?? '';
      _emailController.text = data['email'] ?? '';

      // Check if username is empty and prompt for username
      if ((_usernameController.text.isEmpty ||
              _usernameController.text == '') &&
          mounted) {
        _promptForUsername();
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBar('Error: ${error.message}', isError: true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred: $error',
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Same as the welcome_screen.
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            // TBD: name
            'My Account',
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
            SizedBox(
              width: 350,
              child: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'User Name'),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 350,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              style: ButtonStyles.filled,
              onPressed: _loading ? null : _updateProfile,
              child: Text(_loading ? 'Saving...' : 'Update'),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              style: ButtonStyles.outlined,
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  /// Called when user taps `Update` button
  /// Updates the user's profile in the database.
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final userName = _usernameController.text.trim();
    final user = supabase.auth.currentUser;

    final updates = {
      'id': user!.id,
      'username': userName,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) context.showSnackBar('Successfully updated profile!');
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Allows user to sign out, taking them back to the welcome page.
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomePage()),
          ModalRoute.withName('/'),
        );
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }

  /// A non-dismissable dialog that prompts user to choose a username upon signing up.
  void _promptForUsername() {
    // Likte ikke underscore, så fjerner.
    final dialogUsernameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // user can't navigate out of this screen, they have to actually choose a username.
      builder: (BuildContext context) {
        return PopScope<bool>(
          onPopInvokedWithResult: (bool didPop, bool? result) {
            if (!didPop) {
              // Handle case where back navigation was not successful
              return;
            }
            // Optionally, use the result for further actions
            debugPrint('Pop result: $result');
          },
          child: AlertDialog(
            title: const Text('Set Your Username'),
            content: TextField(
              controller: dialogUsernameController,
              decoration: const InputDecoration(
                hintText: 'Enter a username',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Submit'),
                onPressed: () async {
                  final username = dialogUsernameController.text.trim();
                  if (username.isEmpty) {
                    context.showSnackBar('Username cannot be empty',
                        isError: true);
                    return;
                  }

                  _usernameController.text = username;

                  // Update the user profile with the name chosen at sign up.
                  await _updateProfile();

                  // Close dialog when the username is set.
                  if (!mounted) return;
                  if (!_loading) {
                    Navigator.of(context)
                        .pop(true); // Pass `true` as the pop result
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
