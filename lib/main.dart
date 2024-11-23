import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocy/provider/user_provider.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'package:grocy/screens/tabs_container_screen.dart';
import 'package:grocy/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Supabase redirects do not work with the default URL for flutter, so use this:
// https://docs.flutter.dev/ui/navigation/url-strategies
import 'package:flutter_web_plugins/url_strategy.dart';

final _theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color.fromARGB(255, 255, 0, 0),
      primary: const Color.fromARGB(0xff, 0xc0, 0x0f, 0x0c),
      surface: const Color.fromARGB(0xff, 0xf7, 0xf7, 0xf7)),
  textTheme: GoogleFonts.latoTextTheme(),
);

// "These variables will be exposed on the app, and that's completely fine since we have Row Level Security enabled on our Database" - Supabase.
const supabaseUrl = 'https://rmjqrlqmzuvmfutfvipl.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtanFybHFtenV2bWZ1dGZ2aXBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk5NDE0NDAsImV4cCI6MjA0NTUxNzQ0MH0.aXh9aJ7SywoceUaWe1N-5BlfsYHlbwpB7oPMQ4ofBeI';
Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  // For the redirects on web.
  // https://supabase.com/docs/guides/getting-started/tutorials/with-flutter?queryGroups=platform&platform=android
  usePathUrlStrategy();
  runApp(ProviderScope(child: const MyApp()));
}

final supabase = Supabase.instance.client;

/// Main entry point of the grocy app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Grocy', theme: _theme, home: _AuthenticationCheckWidget());
  }
}

/// A helper class to check the state of the user:
/// - If user is not authenticated, they are sent to the welcome page that lets them either sign in/ or up.
/// - If the user doesn't have a username (freshly signed up) then they are given a dialog to choose their username.
/// - If the user is authenticated and has a username, they are sent directly to the TabsContainerScreen.

class _AuthenticationCheckWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthenticationCheck();
}

class _AuthenticationCheck extends ConsumerState<_AuthenticationCheckWidget> {
  UserProvider? userProvider;
  bool _isAuth = false;
  Session? currentSession;
  @override
  void initState() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      userProvider = ref.read(userNotifier.notifier);

      setState(() {
        _isAuth = session != null;
        currentSession = session;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuth) {
      return FutureBuilder(
        future: userProvider!.checkUserName(),
        builder: (context, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.data == null) {
            supabase.auth.signOut();
            return CircularProgressIndicator();
          } else if (snapshot.data == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => showUsernameDialog(context)
              );
            });
          }
          return TabsContainerScreen();
        }
      );
    } else {
      return WelcomePage();
    }
  }

  Widget showUsernameDialog(BuildContext context) {
    final dialogUsernameController = TextEditingController();
    return AlertDialog(
      title: const Text('Set Your Username'),
      content: TextField(
        controller: dialogUsernameController,
        decoration: const InputDecoration(
          hintText: 'Enter a username, minimum 5 characters',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            final username = dialogUsernameController.text.trim();
            if (username.isEmpty || username.length < 5) {
              context.showSnackBar(
                'Username cannot be empty or less than 5 characters!',
              );
              return;
            }
            try {
              await userProvider!.updateProfile(username);

              if (context.mounted) {
                // Navigate to TabsContainerScreen after a successful username update.
                Navigator.of(context).pop(); // Close the dialog after.
              }
            } catch (error) {
              if (context.mounted) {
                context.showSnackBar('Unable to update user profile: $error');
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
