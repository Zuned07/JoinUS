import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/core/services/firebase_auth_service.dart';
import 'package:joinus/features/events/mock_events.dart';
import 'package:joinus/features/events/recommended_events.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = FirebaseAuthService();
  int _selectedIndex = 0;
  List<String> _userInterests = [];

  @override
  void initState() {
    super.initState();
    _loadUserInterests();
  }

  Future<void> _loadUserInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data.containsKey('interests')) {
        setState(() {
          _userInterests = List<String>.from(data['interests']);
        });
      }
    }
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    _pages.clear();

    _pages.add(
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inicio: Eventos programados', style: TextStyle(fontSize: 16)),
            RecommendedEvents(
              userInterests: _userInterests,
              mockEventsByTag: mockEventsByTag,
            ),
          ],
        ),
      ),
    );

    _pages.add(const Center(child: Text('Calendario')));
    _pages.add(const Center(child: Text('Perfil')));
    _pages.add(const SizedBox());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Eventos'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: const Color.fromARGB(255, 255, 190, 155),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.popAndPushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/calendar');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      case 3:
        _authService.logout(context);
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
    }
  }
}
