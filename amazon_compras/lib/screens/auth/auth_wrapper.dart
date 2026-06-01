import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../admin_panel_screen.dart';
import 'pre_login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authState,
      builder: (context, snapshot) {
        // 🔄 Cargando estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ No hay usuario logueado -> Pantalla de bienvenida / PreLogin
        if (!snapshot.hasData || snapshot.data == null) {
          return const PreLoginScreen();
        }

        final user = snapshot.data!;

        // 🔍 Cargar Rol del Usuario en tiempo real
        return FutureBuilder<String?>(
          future: _authService.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            // 🔄 Cargando rol
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;

            // 🛠 ADMIN
            if (role == 'admin') {
              return const AdminPanelScreen();
            }

            // 👤 CLIENTE
            return const HomeScreen();
          },
        );
      },
    );
  }
}