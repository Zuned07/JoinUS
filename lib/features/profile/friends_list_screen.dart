import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchFriendsData() async {
    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
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
          'interests': List<String>.from(data['interests'] ?? []),
        });
      }
    }

    return friendsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Amigos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFriendsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los amigos.'));
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return const Center(child: Text('Aún no tienes amigos añadidos.'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friend['username']),
                  subtitle: Text('Intereses: ${friend['interests'].join(', ')}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
