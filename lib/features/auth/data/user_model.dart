// core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final List<String> tags; // Etiquetas de interés del usuario
  final List<String>? fcmTokens; // Lista de FCM tokens del usuario

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.tags = const [],
    this.fcmTokens,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'tags': tags,
      if (fcmTokens != null && fcmTokens!.isNotEmpty) 'fcmTokens': fcmTokens,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String,
      name: map['name'] as String,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      fcmTokens: (map['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
}