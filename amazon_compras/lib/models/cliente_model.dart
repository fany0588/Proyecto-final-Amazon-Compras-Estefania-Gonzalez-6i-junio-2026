import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role;
  final DateTime createdAt;

  ClienteModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role = 'cliente',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory ClienteModel.fromMap(Map<String, dynamic> map, String id) {
    return ClienteModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'cliente',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}