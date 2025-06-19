// features/profile/presentation/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modify_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final void Function(bool) toggleTheme;

  const ProfileScreen({super.key, required this.toggleTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  List<String> selectedTags = [];
  Map username = {};
  String a = "";
  bool isDarkMode = false;
  String? profileImageUrl;
  List<Map<String, dynamic>> friendsPreview = [];

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
    _loadUserData();
    _loadFriendsPreview();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        username = data;
        a = data['username'] ?? '';
        selectedTags = List<String>.from(data['interests'] ?? []);
        profileImageUrl = data['profileImageUrl'] as String?;
      });
    }
  }

  Future<void> _loadFriendsPreview() async {
    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .limit(5)
        .get();
    List<Map<String, dynamic>> friendsData = [];
    for (var doc in friendsSnapshot.docs) {
      final friendUid = doc.id;
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .get();
      if (friendDoc.exists) {
        final data = friendDoc.data()!;
        friendsData.add({
          'uid': friendUid,
          'username': data['username'] ?? 'Sin nombre',
          'profileImageUrl': data['profileImageUrl'],
        });
      }
    }
    setState(() {
      friendsPreview = friendsData;
    });
  }

  void _addfriend() {
    Navigator.pushNamed(context, '/add-friend');
  }

  Future<void> _saveTags() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'interests': selectedTags,
      'username': user.displayName,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferencias actualizadas')));
    Navigator.pop(context);
  }

  void _friendlist() {
    Navigator.pushNamed(context, '/view-friend');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModifyProfileScreen(
                    username: a,
                    email: user.email ?? '',
                    tags: selectedTags,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nombre de usuario: $a',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Intereses:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Wrap(
                spacing: 8.0,
                children: selectedTags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amigos:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: _friendlist,
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friendsPreview.length,
                itemBuilder: (context, index) {
                  final friend = friendsPreview[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: friend['profileImageUrl'] != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                friend['profileImageUrl'],
                              ),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(friend['username'] ?? 'Sin nombre'),
                      // No mostramos intereses aquí porque solo es vista previa
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addfriend,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Añadir amigo'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
