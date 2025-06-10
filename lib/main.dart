import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/features/auth/presentation/create_username.dart';
import 'package:joinus/features/auth/presentation/login_screen.dart';
import 'package:joinus/features/auth/presentation/register_screen.dart';
import 'package:joinus/features/auth/presentation/welcome_screen.dart';
import 'package:joinus/features/events/presentation/create_event_screen.dart';
import 'package:joinus/features/home/presentation/calendar_screen.dart';
import 'firebase_options.dart';
import 'features/home/presentation/home_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/home':(context) => HomeScreen(),
        '/register':(context) => RegisterScreen(),
        '/welcome':(context) => WelcomeScreen(),
        '/login':(context) => LoginScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/create-event': (context) => CreateEventScreen(),
        '/create-username': (_) => CreateUsernameScreen(),    
      },
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
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
          return HomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
