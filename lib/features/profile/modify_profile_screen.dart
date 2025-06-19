import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

class ModifyProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final List<String> tags;
  final String? profileImageUrl;

  const ModifyProfileScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.tags,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<ModifyProfileScreen> createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late List<String> selectedTags;
  String? profileImageUrl;
  Uint8List? _croppedImageBytes;
  XFile? _pickedImage;
  bool _saving = false;

  final List<String> availableTags = [
    'exterior',
    'deportes',
    'familia',
    'citas',
    'interior',
    'videojuegos',
    'viajes',
    'comida',
    'música',
    'arte',
    'lectura',
    'cine',
    'casual',
    'formal',
    'trabajo',
    'compras',
    'escolar',
    'espiritual',
    'poca gente',
    'mucha gente',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    selectedTags = List<String>.from(widget.tags);
    profileImageUrl = widget.profileImageUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.original,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Ajustar imagen',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Ajustar imagen'),
        ],
      );
      if (cropped != null) {
        final bytes = await cropped.readAsBytes();
        setState(() {
          _croppedImageBytes = bytes;
          _pickedImage = XFile(cropped.path);
        });
      }
    }
  }

  Future<String?> _uploadImageToSupabase(String uid) async {
    if (_croppedImageBytes == null) return profileImageUrl;
    final supabase = Supabase.instance.client;
    final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await supabase.storage
          .from('profile-images')
          .uploadBinary(
            fileName,
            _croppedImageBytes!,
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl = supabase.storage
          .from('profile-images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return profileImageUrl;
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _saving = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? imageUrl = await _uploadImageToSupabase(user.uid);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'username': _usernameController.text.trim(),
      'interests': selectedTags,
      'profileImageUrl': imageUrl,
    }, SetOptions(merge: true));
    setState(() {
      _saving = false;
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modificar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _croppedImageBytes != null
                        ? MemoryImage(_croppedImageBytes!)
                        : (profileImageUrl != null
                                  ? NetworkImage(profileImageUrl!)
                                  : null)
                              as ImageProvider?,
                    child:
                        (profileImageUrl == null && _croppedImageBytes == null)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona tus intereses:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: availableTags.map((tag) {
                final selected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        selectedTags.remove(tag);
                      } else {
                        selectedTags.add(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveChanges,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
