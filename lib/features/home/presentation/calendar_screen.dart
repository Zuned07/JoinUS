import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:joinus/features/events/presentation/create_event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinus/features/events/domain/event_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<EventModel>> _eventsByDay = {};
  bool _loading = true;
  List<EventModel> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  Future<void> _fetchUserEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Traer eventos donde el usuario es organizador
    final creatorQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('creatorUid', isEqualTo: user.uid)
        .get();
    // Traer eventos donde el usuario es invitado
    final invitedQuery = await FirebaseFirestore.instance
        .collection('events')
        .where('invitedUsers', arrayContains: user.uid)
        .get();
    final List<EventModel> allEvents = [
      ...creatorQuery.docs.map(
        (doc) => EventModel.fromMap(doc.data(), id: doc.id),
      ),
      ...invitedQuery.docs.map(
        (doc) => EventModel.fromMap(doc.data(), id: doc.id),
      ),
    ];
    // Eliminar duplicados (por si acaso)
    final Map<String, EventModel> uniqueEvents = {
      for (var e in allEvents) e.id ?? '': e,
    };
    final userEvents = uniqueEvents.values.toList();
    final Map<DateTime, List<EventModel>> eventsByDay = {};
    for (var event in userEvents) {
      final eventDay = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      eventsByDay.putIfAbsent(eventDay, () => []).add(event);
    }
    setState(() {
      _eventsByDay = eventsByDay;
      _loading = false;
      if (_selectedDay != null) {
        final normalizedSelectedDay = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        );
        _selectedDayEvents = _eventsByDay[normalizedSelectedDay] ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario de eventos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
      ),
      body: Column(
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(20),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      final normalizedSelectedDay = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      _selectedDayEvents =
                          _eventsByDay[normalizedSelectedDay] ?? [];
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  eventLoader: (day) {
                    final d = DateTime(day.year, day.month, day.day);
                    return _eventsByDay[d] ?? [];
                  },
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Día seleccionado: ${DateFormat.yMMMMd('es').format(_selectedDay!)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedDayEvents.isEmpty)
                      const Text(
                        'No hay eventos para este día.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ..._selectedDayEvents.map(
                      (event) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(
                            Icons.event,
                            color: Colors.deepPurple,
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            event.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          ).then((_) => _fetchUserEvents());
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear evento',
      ),
    );
  }
}
