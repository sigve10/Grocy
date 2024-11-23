import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocy/styling/button_styles.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'package:grocy/main.dart';
import '../provider/user_provider.dart';

/// Provides user profile management via Supabase.
/// Users can see and update their profile, while also signing out.
///
/// Followed a user management app from Supabase, to add authentication with proper security.
/// https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

/// Manages the state of user interactions and data.
/// Allows user to update their username, and view their email.
/// Allows user to sign out, taking them to the welcome page. Where they can sign in/ or up.
class _AccountPageState extends ConsumerState<AccountPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  var _loading = true;

  /// Called once a user id is received from the user provider.
  /// Retrieves the user's profile from Supabase.
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }
    final userProvider = ref.read(userNotifier.notifier);
    final profile = await userProvider.fetchMyProfile();

    if (profile == null) {
      if (mounted) {
        context.showSnackBar(
          'You are not signed in. Please sign in or register.',
          isError: true,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
      }
      return;
    }

    // Update the UI controllers from the user_provider.
    final state = ref.read(userNotifier);
    _usernameController.text = state['username'] ?? '';
    _emailController.text = state['email'] ?? '';

    setState(() {
      _loading = false;
    });
  }

  /// Called when user taps `Update` button
  /// Updates the user's profile in the database.
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final username = _usernameController.text.trim();

    // Now there's actual feedback when user tries to create an invalid username :)
    if (username.isEmpty || username.length < 5) {
      if (mounted) {
        context.showSnackBar(
          'Username cannot be empty or less than 5 characters!',
        );
      }
      setState(() {
        _loading = false;
      });
      return;
    }

    final userProvider = ref.read(userNotifier.notifier);
    await userProvider.updateProfile(username);

    if (mounted) {
      context.showSnackBar('Profile updated successfully!');
    }

    setState(() {
      _loading = false;
    });
  }

  /// Allows user to sign out, taking them back to the welcome page.
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
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
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'My Account',
            style: TextStyle(
              fontSize: 32,
            ),
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
      ),
    );
  }
}
