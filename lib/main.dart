import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/events/presentation/create_event_screen.dart';
import 'features/home/presentation/calendar_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const JoinUsApp());
}

class JoinUsApp extends StatelessWidget {
  const JoinUsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoinUS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(214, 232, 8, 240)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), 
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/create-event': (context) => const CreateEventScreen(),
        '/profile': (context) => const ProfileScreen(), 
      },
      
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
