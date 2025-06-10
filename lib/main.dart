import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Asegúrate de que esta ruta sea correcta
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/events/presentation/create_event_screen.dart';
import 'features/home/presentation/calendar_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/auth/presentation/create_username.dart'; // Importa la nueva pantalla
import 'features/profile/add_friend_screen.dart';
import 'features/profile/friends_list_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  );
  
  runApp(const JoinUsApp());
}

class JoinUsApp extends StatefulWidget {
  const JoinUsApp({super.key});

  @override
  State<JoinUsApp> createState() => _JoinUsAppState();
}

class _JoinUsAppState extends State<JoinUsApp> {
  // Estado para controlar el modo del tema (claro/oscuro)
  ThemeMode _themeMode = ThemeMode.light;

  // Función para cambiar el tema, que se pasará a ProfileScreen
  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoinUS',
      // Usa el ThemeMode para cambiar entre claro y oscuro
      themeMode: _themeMode,
      // Tema para el modo claro
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 255, 57, 57), // rojo suave
          secondary: Color.fromARGB(255, 243, 140, 105), // naranja suave
          background: Color.fromARGB(255, 199, 105, 89), // marrón oscuro cálido para fondo
          surface: Color.fromARGB(255, 255, 221, 202), // marrón para tarjetas
          onBackground: Colors.orangeAccent, // texto sobre fondo oscuro
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 245, 224), // fondo cálido en Scaffold
      ),
      // Tema para el modo oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 134, 109, 225), // morado/azul suave
          secondary: Color.fromARGB(255, 68, 112, 170), // azul medio
          background: Color.fromARGB(255, 19, 12, 59), // azul oscuro profundo para fondo
          surface: Color.fromARGB(255, 37, 34, 101), // azul/morado oscuro para tarjetas
          onBackground: Color.fromARGB(255, 119, 178, 217), // azul claro para texto sobre fondo oscuro
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 15, 61), // fondo cálido en modo oscuro
      ),
      // Builder para asegurar que el color de fondo de la paleta se aplique a toda la app
      builder: (context, child) {
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: child,
        );
      },
      // La primera pantalla que ve el usuario, basada en el estado de autenticación
      home: AuthWrapper(toggleTheme: toggleTheme),
      // Define todas las rutas de la aplicación
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/create-event': (context) => const CreateEventScreen(),        
        '/profile': (context) => ProfileScreen(toggleTheme: toggleTheme),
        '/create-username': (context) => const CreateUsernameScreen(),
        '/add-friend': (context) => const AddFriendScreen(),
        '/view-friend': (context) => const FriendsListScreen(),

      },
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de depuración
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final void Function(bool)? toggleTheme; // Ahora es opcional
  const AuthWrapper({super.key, this.toggleTheme}); // Constructor ajustado

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un indicador de carga mientras se verifica el estado de autenticación
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          // Si el usuario está autenticado, dirígelo a la pantalla de inicio
          return const HomeScreen(); // Cambiado de WelcomeScreen a HomeScreen como en el segundo main.dart
        } else {
          // Si el usuario no está autenticado, dirígelo a la pantalla de bienvenida
          return const WelcomeScreen();
        }
      },
    );
  }
}