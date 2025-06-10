// features/profile/presentation/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final void Function(bool) toggleTheme;

  const ProfileScreen({super.key, required this.toggleTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  List<String> selectedTags = [];
  Map username= {
  };
  String a= "";
  bool isDarkMode = false;

  final List<String> availableTags = [
    'exterior', 'deportes', 'familia', 'citas', 'interior',
    'videojuegos', 'viajes', 'comida', 'música', 'arte',
    'lectura', 'cine', 'casual', 'formal', 'trabajo',
    'compras', 'escolar', 'espiritual', 'poca gente', 'mucha gente'
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null && data.containsKey('interests')) {
      setState(() {
        selectedTags = List<String>.from(data['interests']);
        username= data;
        a = data['username'];
      });
    }
  }

  void _addfriend (){
    Navigator.pushNamed(context, '/add-friend');
  }

  Future<void> _saveTags() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'interests': selectedTags,
      'username' : user.displayName,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferencias actualizadas')),
    );
    Navigator.pop(context);
  }

    void _friendlist() {
    Navigator.pushNamed(context, '/view-friend');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Correo: ${user.email}', style: const TextStyle(fontSize: 16)),
            Text('Nombre de usuario: $a', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: isDarkMode,
              onChanged: (value) {
                setState(() => isDarkMode = value);
                widget.toggleTheme(value);
              },
            ),

            const SizedBox(height: 20),
            const Text('Selecciona tus intereses:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: availableTags.map((tag) {
                final selected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        selectedTags.remove(tag);
                      } else {
                        selectedTags.add(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveTags,
              icon: const Icon(Icons.save),
              label: const Text('Guardar intereses'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _addfriend, icon: Icon(Icons.add_circle_sharp), label: Text("Añadir Amigo")),
            ElevatedButton.icon(onPressed: _friendlist, icon: Icon(Icons.people), label: Text("Ver amigos"))
          ],
        ),
      ),
    );
  }
}
