import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Obtener datos del usuario
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // Subir imagen a Storage y obtener URL
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error subiendo imagen: $e');
      return null;
    }
  }

  // Actualizar foto de perfil en Firestore
  Future<bool> updateProfilePhoto(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error actualizando foto: $e');
      return false;
    }
  }

  // Método completo para cambiar foto
  Future<String?> changeProfilePhoto(String userId, XFile imageFile) async {
    try {
      // Convertir XFile a File
      final file = File(imageFile.path);
      
      // Subir a Storage
      final imageUrl = await uploadProfileImage(file, userId);
      if (imageUrl != null) {
        // Actualizar en Firestore
        final success = await updateProfilePhoto(userId, imageUrl);
        if (success) {
          return imageUrl;
        }
      }
      return null;
    } catch (e) {
      print('Error cambiando foto: $e');
      return null;
    }
  }

  // Seleccionar imagen de la galería
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Error seleccionando imagen: $e');
      return null;
    }
  }
}