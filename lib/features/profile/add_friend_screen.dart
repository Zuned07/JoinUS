import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _etiquetaController = TextEditingController();

  List<String> etiquetas = [];
  bool _isLoading = false;

  Future<DocumentSnapshot?> buscarUsuarioPorUsername(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    } else {
      return null;
    }
  }

  Future<void> agregarAmigoConEtiquetas({
    required String currentUserId,
    required String friendUid,
    required String username,
    required String email,
    required List<String> etiquetas,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendUid)
        .set({
      'uid': friendUid,
      'username': username,
      'email': email,
      'etiquetas': etiquetas,
    });
  }

  void _agregarEtiqueta() {
    final texto = _etiquetaController.text.trim();
    if (texto.isNotEmpty && !etiquetas.contains(texto)) {
      setState(() {
        etiquetas.add(texto);
        _etiquetaController.clear();
      });
    }
  }

  void _buscarYAgregarAmigo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isLoading = true);

    final friendDoc = await buscarUsuarioPorUsername(username);
    if (friendDoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no encontrado')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final data = friendDoc.data() as Map<String, dynamic>;
    final friendUid = data['uid'];
    final friendUsername = data['username'];
    final friendEmail = data['email'];

    await agregarAmigoConEtiquetas(
      currentUserId: currentUser.uid,
      friendUid: friendUid,
      username: friendUsername,
      email: friendEmail,
      etiquetas: etiquetas,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amigo agregado con éxito')),
    );

    setState(() {
      _usernameController.clear();
      _etiquetaController.clear();
      etiquetas.clear();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar amigo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Nombre de usuario",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _etiquetaController,
                    decoration: const InputDecoration(
                      labelText: "Etiqueta",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agregarEtiqueta,
                  child: const Text("Añadir"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: etiquetas
                  .map((e) => Chip(
                        label: Text(e),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() => etiquetas.remove(e));
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _buscarYAgregarAmigo,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Agregar amigo"),
                  ),
          ],
        ),
      ),
    );
  }
}
