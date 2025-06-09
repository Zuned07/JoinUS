class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final String? locationName;
  final String? locationUrl;
  final List<String>? tags;
  final String? creatorUid;
  final List<String>? invitedUsers;
  final String? eventType; // 'formal' o 'casual'
  final double? contribution;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.locationName,
    this.locationUrl,
    this.tags,
    this.creatorUid,
    this.invitedUsers,
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
    eventType: eventType ?? this.eventType,
    contribution: contribution ?? this.contribution,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      if (description != null) 'description': description,
      if (locationName != null) 'locationName': locationName,
      if (locationUrl != null) 'locationUrl': locationUrl,
      if (tags != null) 'tags': tags,
      if (creatorUid != null) 'creatorUid': creatorUid,
      if (invitedUsers != null) 'invitedUsers': invitedUsers,
      if (eventType != null) 'eventType': eventType,
      if (contribution != null) 'contribution': contribution,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      locationName: map['locationName'],
      locationUrl: map['locationUrl'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      creatorUid: map['creatorUid'],
      invitedUsers: map['invitedUsers'] != null ? List<String>.from(map['invitedUsers']) : null,
      eventType: map['eventType'],
      contribution: map['contribution']?.toDouble(),
    );
  }
}

