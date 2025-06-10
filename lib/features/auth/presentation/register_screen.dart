import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:joinus/core/services/firebase_auth_service.dart';
import 'package:joinus/core/utils/validators.dart';
import 'package:joinus/core/services/google_auth_servide.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {
  final _googleAuthService = GoogleAuthService();
  final _formKey = GlobalKey<FormState>();
  final _authService = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        await _authService.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Usuario registrado con éxito")),          
        );


        Navigator.popAndPushNamed(context, '/home');

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
    await _googleAuthService.saveFcmTokenToFirestore();
  }

  /// Builds the Google Sign-In button with proper styling.
 Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Fondo blanco
        foregroundColor: Colors.black.withOpacity(0.87), // Texto casi negro
        side: const BorderSide(color: Color(0xFF747775), width: 1), // Borde gris sutil
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0), // Bordes ligeramente redondeados
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Espaciado interno
        elevation: 0, // Sin sombra o muy poca
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
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Nombre de usuario", helperText: "Será su identificador único como usuario"),
                validator: Validators.validateUsername,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Contraseña"),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text("Registrarse"),
                    ),
              const SizedBox(height: 20),              
              _buildGoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
