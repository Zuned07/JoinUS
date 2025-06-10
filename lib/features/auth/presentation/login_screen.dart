import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/core/services/firebase_auth_service.dart';
import 'package:joinus/core/utils/validators.dart';
import 'package:joinus/core/services/google_auth_servide.dart';


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
  await _googleAuthService.signInWithGoogle(context);
}

 Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black.withOpacity(0.87),
        side: const BorderSide(color: Color(0xFF747775), width: 1), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
        elevation: 0, 
      ),
    
      icon: Image.asset( 
        'assets/images/google.png', 
        height: 30, 
        width: 30,  
      ),

      onPressed: _loading ? null : _loginWithGoogle,
      label: const Text(
        "Continuar con Google", 
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500, 
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