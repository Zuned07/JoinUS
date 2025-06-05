class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String locationName;
  final String locationUrl;
  final List<String> tags;
  final String creatorUid;
  final List<String> invitedUsers;
  final String eventType; // 'formal' o 'casual'
  final double? contribution;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.locationName,
    required this.locationUrl,
    required this.tags,
    required this.creatorUid,
    required this.invitedUsers,
    required this.eventType,
    this.contribution,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'locationName': locationName,
      'locationUrl': locationUrl,
      'tags': tags,
      'creatorUid': creatorUid,
      'invitedUsers': invitedUsers,
      'eventType': eventType,
      'contribution': contribution,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      locationName: map['locationName'],
      locationUrl: map['locationUrl'],
      tags: List<String>.from(map['tags']),
      creatorUid: map['creatorUid'],
      invitedUsers: List<String>.from(map['invitedUsers']),
      eventType: map['eventType'],
      contribution: map['contribution']?.toDouble(),
    );
  }
}
