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

class JoinUsApp extends StatefulWidget {
  const JoinUsApp({super.key});

  @override
  State<JoinUsApp> createState() => _JoinUsAppState();
}

class _JoinUsAppState extends State<JoinUsApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoinUS',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFC62828), // rojo
          secondary: Color(0xFFFF7043), // naranja
          background: Color(0xFFFFF3E0), // fondo crema
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1A237E), // azul oscuro
          secondary: Color(0xFF536DFE), // azul medio
          background: Color(0xFFBBDEFB), // azul claro
        ),
      ),
      home: AuthWrapper(toggleTheme: toggleTheme),
      routes: {
        '/home': (context) => HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/create-event': (context) => const CreateEventScreen(),
        '/profile': (context) => ProfileScreen(toggleTheme: toggleTheme),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final void Function(bool) toggleTheme;
  const AuthWrapper({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return WelcomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
