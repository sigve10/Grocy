import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocy/screens/tabs_container_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocy/screens/welcome_screen.dart';
import 'package:grocy/screens/account_screen.dart';
// Supabase redirects do not work with the default URL for flutter, so use this:
// https://docs.flutter.dev/ui/navigation/url-strategies
import 'package:flutter_web_plugins/url_strategy.dart';

final _theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 255, 0, 0),
    primary: const Color.fromARGB(0xff, 0xc0, 0x0f, 0x0c),
    surface: const Color.fromARGB(0xff, 0xf7, 0xf7, 0xf7)
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

// If we want, we can set up RLS for security.
// "These variables will be exposed on the app, and that's completely fine since we have Row Level Security enabled on our Database" - Supabase.
const supabaseUrl = 'https://rmjqrlqmzuvmfutfvipl.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJtanFybHFtenV2bWZ1dGZ2aXBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk5NDE0NDAsImV4cCI6MjA0NTUxNzQ0MH0.aXh9aJ7SywoceUaWe1N-5BlfsYHlbwpB7oPMQ4ofBeI';
Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  // For the redirects on web.
  //TODO: set up android and IOS as well, before we push our project at the end.
  // https://supabase.com/docs/guides/getting-started/tutorials/with-flutter?queryGroups=platform&platform=android
  usePathUrlStrategy();
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _theme,
      home: const TabsContainerScreen(),

      //Uncomment this and replace the home above for the login- & account pages.
      /* home: supabase.auth.currentSession == null
          ? const WelcomePage()
          : const AccountPage(), */
    );
  }
}
