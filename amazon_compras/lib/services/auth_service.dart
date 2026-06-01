import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
// No necesitas importar dart:io porque no usamos File

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'hasProfileImage': false,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_base64_${user.uid}');
    }
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<String?> getUserRole([String? uid]) async {
    try {
      final userUid = uid ?? _auth.currentUser?.uid;
      if (userUid == null) return null;

      final doc = await _db.collection('users').doc(userUid).get();
      return doc.data()?['role'];
    } catch (e) {
      return null;
    }
  }

  Stream<User?> get authState => _auth.authStateChanges();
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// Actualizar que el usuario tiene imagen
  Future<bool> updateProfilePhoto(String imageBase64) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      await _db.collection('users').doc(user.uid).update({
        'hasProfileImage': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error actualizando estado de foto: $e');
      return false;
    }
  }

  Stream<DocumentSnapshot> getUserDataStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('users').doc(user.uid).snapshots();
  }
}