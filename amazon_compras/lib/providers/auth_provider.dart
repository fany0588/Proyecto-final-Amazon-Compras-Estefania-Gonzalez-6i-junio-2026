import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;

  AuthProvider() {
    _authService.authState.listen((u) {
      user = u;
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  String? get uid => user?.uid;

  String? get email => user?.email;

  /// LOGIN
  Future<String?> login(String email, String password) async {
    return await _authService.login(
      email: email,
      password: password,
    );
  }

  /// REGISTER
  Future<String?> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    return await _authService.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      role: role,
    );
  }

  /// LOGOUT
  Future<void> logout() async {
    await _authService.logout();
  }
}