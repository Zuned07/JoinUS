import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUsernameScreen extends StatefulWidget {
  const CreateUsernameScreen({Key? key}) : super(key: key);

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> _usernameExists(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> _saveUsername() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final username = _usernameController.text.trim();
    if (await _usernameExists(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de usuario ya está en uso')),
      );
      return;
    }

    await _firestore.collection('users').doc(user.uid).update({
      'username': username,
    });

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear nombre de usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Elige tu nombre de usuario para continuar."),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Nombre de usuario"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Este campo es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _loading = true);
                          await _saveUsername();
                          setState(() => _loading = false);
                        }
                      },
                      child: const Text("Guardar y continuar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
