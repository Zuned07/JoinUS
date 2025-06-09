import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joinus/features/events/domain/event_model.dart';

class EventService {
  final _eventsCollection = FirebaseFirestore.instance.collection('events');


  Future<void> createEvent(EventModel event) async {
    await _eventsCollection.add(event.toMap());
  }

  // Método opcional para obtener todos los eventos
  Future<List<EventModel>> getAllEvents() async {
    final snapshot = await _eventsCollection.get();
    return snapshot.docs.map((doc) => EventModel.fromMap(doc.data())).toList();
  }
}
