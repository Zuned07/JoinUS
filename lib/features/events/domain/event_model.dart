import 'package:cloud_firestore/cloud_firestore.dart'; // Importar para Timestamp

class EventModel {
  final String? id;
  final String title;
  final DateTime date;
  final String? description;
  final String? locationName;
  final String? locationUrl;
  final List<String>? tags;
  final String? creatorUid;
  // invitedUsers ahora podría representar a los que han sido invitados
  final List<String>? invitedUsers;
  // Nuevo campo para el estado de las invitaciones
  final Map<String, String>? invitationStatus; // { 'uid_invitado': 'pending/accepted/declined' }
  final String? eventType; // 'formal' o 'casual'
  final double? contribution;

  EventModel({
    this.id, // Lo hago opcional porque Firestore lo asigna
    required this.title,
    required this.date,
    this.description,
    this.locationName,
    this.locationUrl,
    this.tags,
    this.creatorUid,
    this.invitedUsers, // Puede seguir siendo una lista de todos los invitados
    this.invitationStatus, // Nuevo campo
    this.eventType,
    this.contribution,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? locationName,
    String? locationUrl,
    List<String>? tags,
    String? creatorUid,
    List<String>? invitedUsers,
    Map<String, String>? invitationStatus, // Nuevo en copyWith
    String? eventType,
    double? contribution,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      locationName: locationName ?? this.locationName,
      locationUrl: locationUrl ?? this.locationUrl,
      tags: tags ?? this.tags,
      creatorUid: creatorUid ?? this.creatorUid,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      invitationStatus: invitationStatus ?? this.invitationStatus, // Nuevo
      eventType: eventType ?? this.eventType,
      contribution: contribution ?? this.contribution,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // No es necesario si el ID del documento es el ID del evento
      'title': title,
      'date': Timestamp.fromDate(date), // Usar Timestamp para fechas en Firestore
      if (description != null && description!.isNotEmpty) 'description': description,
      if (locationName != null && locationName!.isNotEmpty) 'locationName': locationName,
      if (locationUrl != null && locationUrl!.isNotEmpty) 'locationUrl': locationUrl,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      if (creatorUid != null) 'creatorUid': creatorUid,
      if (invitedUsers != null && invitedUsers!.isNotEmpty) 'invitedUsers': invitedUsers,
      if (invitationStatus != null && invitationStatus!.isNotEmpty) 'invitationStatus': invitationStatus, // Nuevo
      if (eventType != null) 'eventType': eventType,
      if (contribution != null) 'contribution': contribution,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, {String? id}) {
    // Asegurarse de que el ID del documento se use como 'id' del modelo
    return EventModel(
      id: id,
      title: map['title'] as String,
      date: (map['date'] as Timestamp).toDate(), // Convertir Timestamp a DateTime
      description: map['description'] as String?,
      locationName: map['locationName'] as String?,
      locationUrl: map['locationUrl'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      creatorUid: map['creatorUid'] as String?,
      invitedUsers: (map['invitedUsers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      invitationStatus: (map['invitationStatus'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as String),
      ), // Nuevo
      eventType: map['eventType'] as String?,
      contribution: (map['contribution'] as num?)?.toDouble(),
    );
  }
}