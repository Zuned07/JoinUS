import 'package:flutter/material.dart';
import 'package:joinus/core/services/firebase_auth_service.dart';
import 'package:joinus/features/home/presentation/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = FirebaseAuthService();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Inicio: Eventos programados')),
    const Center(child: Text('Calendario')),
    const Center(child: Text('Perfil')),
    const SizedBox(), 
  ];

  void _onItemTapped(int index) {
    switch (index){
      case 0:
      Navigator.popAndPushNamed(context, '/home');
        break;

      case 1:
      Navigator.popAndPushNamed(context, '/calendar');
        break;

      case 2:
      print("Aún no existe la pantalla");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Eventos'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
      ),
    );
  }
}
