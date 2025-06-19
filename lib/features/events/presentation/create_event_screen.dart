import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/features/events/domain/event_model.dart';
import 'package:uuid/uuid.dart';
import 'package:joinus/core/services/event_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _locationUrlController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _contributionController = TextEditingController();

  final _eventService = EventService();

  DateTime? _selectedDate;
  String _eventType = 'casual';

  List<String> _selectedTags = [];
  List<String> _suggestedTags = [];

  Future<List<String>> _fetchFriendsTags() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .get();
    Set<String> tagsSet = {};
    for (var doc in friendsSnapshot.docs) {
      final data = doc.data();
      final etiquetas = data['etiquetas'] as List<dynamic>?;
      if (etiquetas != null) {
        tagsSet.addAll(etiquetas.map((e) => e.toString()));
      }
    }
    return tagsSet.toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> sendNotificationToUserHttpV1({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    // Ruta al archivo de cuenta de servicio descargado de Firebase
    final serviceAccountFile = File(
      'service-account.json',
    ); // Cambia la ruta si es necesario
    final serviceAccount = ServiceAccountCredentials.fromJson(
      json.decode(serviceAccountFile.readAsStringSync()),
    );
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);

    // Cambia esto por tu projectId de Firebase
    const projectId = 'joinus-2e386';

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );
    final message = {
      'message': {
        'token': fcmToken,
        'notification': {'title': title, 'body': body},
      },
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );
    print('Respuesta FCM: \\${response.statusCode} \\${response.body}');
    client.close();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final currentUserName =
        userDoc.data()?['username'] ?? currentUser.email ?? 'Alguien';

    // Obtener amigos invitados según coincidencia de etiquetas
    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .get();
    final selectedTagsSet = _selectedTags.toSet();
    List<String> invitedUids = [];
    for (var doc in friendsSnapshot.docs) {
      final data = doc.data();
      final etiquetas =
          (data['etiquetas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {};
      if (etiquetas.intersection(selectedTagsSet).isNotEmpty) {
        invitedUids.add(data['uid'] as String);
      }
    }

    final event = EventModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate!,
      locationName: _locationNameController.text.trim(),
      locationUrl: _locationUrlController.text.trim(),
      tags: _tagsController.text.trim().isEmpty
          ? []
          : _tagsController.text.trim().split(','),
      creatorUid: currentUser.uid,
      invitedUsers: invitedUids,
      eventType: _eventType,
      contribution: _contributionController.text.trim().isEmpty
          ? null
          : double.tryParse(_contributionController.text.trim()),
    );

    try {
      await _eventService.createEvent(event);

      // (Opcional: aquí podrías notificar solo a los invitados, si lo deseas)

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento creado con éxito')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear evento: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear nuevo evento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del evento *',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Requerido'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                          : 'Selecciona una fecha *',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Elegir fecha'),
                  ),
                ],
              ),
              if (_selectedDate == null)
                const Text(
                  'Debes seleccionar una fecha',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del lugar',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de Google Maps',
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<String>>(
                future: _fetchFriendsTags(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  _suggestedTags = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Etiquetas (elige o escribe las tuyas):'),
                      Wrap(
                        spacing: 8.0,
                        children: _suggestedTags.map((tag) {
                          final selected = _selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: selected,
                            onSelected: (isSelected) {
                              setState(() {
                                if (isSelected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                                _tagsController.text = _selectedTags.join(',');
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Etiquetas (separadas por comas)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedTags = value
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _eventType,
                items: const [
                  DropdownMenuItem(value: 'formal', child: Text('Formal')),
                  DropdownMenuItem(value: 'casual', child: Text('Casual')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _eventType = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo de evento'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contributionController,
                decoration: const InputDecoration(
                  labelText: 'Contribución (opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Guardar evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
