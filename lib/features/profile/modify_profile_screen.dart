import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModifyProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final List<String> tags;
  final void Function(bool)? toggleTheme;

  const ModifyProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.tags,
    this.toggleTheme,
  });

  @override
  State<ModifyProfileScreen> createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late List<String> selectedTags;
  bool _saving = false;
  bool _isDarkMode = false;

  final List<String> availableTags = [
    'exterior',
    'deportes',
    'familia',
    'citas',
    'interior',
    'videojuegos',
    'viajes',
    'comida',
    'música',
    'arte',
    'lectura',
    'cine',
    'casual',
    'formal',
    'trabajo',
    'compras',
    'escolar',
    'espiritual',
    'poca gente',
    'mucha gente',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    selectedTags = List<String>.from(widget.tags);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _saving = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'username': _usernameController.text.trim(),
      'interests': selectedTags,
    }, SetOptions(merge: true));
    setState(() {
      _saving = false;
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modificar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Tema oscuro'),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    if (widget.toggleTheme != null) {
                      widget.toggleTheme!(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona tus intereses:',
              style: TextStyle(fontSize: 16),
            ),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveChanges,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
