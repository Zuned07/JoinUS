import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/core/services/firebase_auth_service.dart';
import 'package:joinus/core/utils/validators.dart';
import 'package:joinus/core/services/google_auth_servide.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _googleAuthService = GoogleAuthService();
  final _formKey = GlobalKey<FormState>();
  final _authService = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        await _authService.loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inicio de sesión exitoso")),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() => _loading = true);

    final user = await _googleAuthService.signInWithGoogle();

    setState(() => _loading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión iniciada con Google')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar sesión con Google')),
      );
    }
  }

  /// Builds the Google Sign-In button with proper styling.
 Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Fondo blanco
        foregroundColor: Colors.black.withOpacity(0.87), // Texto casi negro
        side: const BorderSide(color: Color(0xFF747775), width: 1), // Borde gris sutil
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0), // Bordes ligeramente redondeados
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Espaciado interno
        elevation: 0, // Sin sombra o muy poca
      ),
      // --- ¡Aquí está el cambio clave para el logo multicolor! ---
      icon: Image.asset( // Usamos SvgPicture.asset para el SVG
        'assets/images/google.png', // Ruta a tu archivo SVG
        height: 30, // Ajusta la altura del logo según necesites
        width: 30,  // Ajusta el ancho del logo según necesites
      ),
      // Si usas PNG, sería:
      // icon: Image.asset(
      //   'assets/images/google_g_logo.png', // Ruta a tu archivo PNG
      //   height: 20, // Ajusta la altura del logo
      //   width: 20,  // Ajusta el ancho del logo
      // ),
      // --- Fin del cambio para el logo ---
      onPressed: _loading ? null : _loginWithGoogle,
      label: const Text(
        "Continuar con Google", // Texto recomendado por Google
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500, // Simula Roboto Medium
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text("Iniciar sesión"),
                    ),
              const SizedBox(height: 20),
              // Aquí integramos el botón de Google modificado
              _buildGoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}