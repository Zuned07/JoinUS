import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Future<void> saveFcmTokenToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  await userRef.update({
    'fcmToken': fcmToken,
  });
}

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // Cancelado

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;  
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el usuario')),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // Nuevo usuario
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': '',
        'createdAt': Timestamp.now(),
      });
      Navigator.pushReplacementNamed(context, '/create-username');
    } else {
      final username = userDoc.data()?['username'];
      if (username == null || username.isEmpty) {
        Navigator.pushReplacementNamed(context, '/create-username');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión iniciada con Google')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error en Google Sign-In: $e')),
    );
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.disconnect();
  }
}
