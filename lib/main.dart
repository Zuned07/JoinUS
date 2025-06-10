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
         primary: Color.fromARGB(255, 255, 57, 57), // rojo suave
          secondary: Color.fromARGB(255, 243, 140, 105), // naranja suave
          background: Color.fromARGB(255, 199, 105, 89), // marrón oscuro cálido para fondo
          surface: Color.fromARGB(255, 255, 221, 202), // marrón para tarjetas esta vaina causa los problemas
          onBackground: Colors.orangeAccent, // texto sobre fondo oscuro
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 245, 224), // fondo cálido en Scaffold
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 134, 109, 225), // rojo suave
          secondary: Color.fromARGB(255, 68, 112, 170), // naranja suave
          background: Color.fromARGB(255, 19, 12, 59), // marrón oscuro cálido para fondo
          surface: Color.fromARGB(255, 37, 34, 101), // marrón para tarjetas
          onBackground: Color.fromARGB(255, 119, 178, 217), // texto sobre fondo oscuro
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 15, 61), // fondo cálido en modo oscuro
      ),
      builder: (context, child) {
        // Aplica el color de fondo cálido de la paleta a toda la app
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: child,
        );
      },
      home: AuthWrapper(toggleTheme: toggleTheme),
      routes: {
        '/home': (context) => const HomeScreen(),
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
          return const WelcomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
