import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/features/events/domain/event_model.dart';
import 'package:uuid/uuid.dart';
import 'package:joinus/core/services/event_service.dart';

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

void _submitForm() async {
  if (!_formKey.currentState!.validate() || _selectedDate == null) return;

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario no autenticado')),
    );
    return;
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
    invitedUsers: [],
    eventType: _eventType,
    contribution: _contributionController.text.trim().isEmpty
        ? null
        : double.tryParse(_contributionController.text.trim()),
  );

  try {
    await _eventService.createEvent(event);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento creado con éxito')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear evento: $e')),
    );
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
                decoration: const InputDecoration(labelText: 'Título del evento *'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Requerido' : null,
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
                const Text('Debes seleccionar una fecha', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(labelText: 'Nombre del lugar'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationUrlController,
                decoration: const InputDecoration(labelText: 'URL de Google Maps'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Etiquetas (separadas por comas)'),
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
                decoration: const InputDecoration(labelText: 'Contribución (opcional)'),
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
