import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Eventos'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Aquí irán los eventos programados'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí iría la navegación a la pantalla para crear un evento
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
