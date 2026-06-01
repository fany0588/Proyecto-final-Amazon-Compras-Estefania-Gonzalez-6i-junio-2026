import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginAdmin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor complete todos los campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Intentamos el inicio de sesión real en Firebase
    final error = await _authService.login(email: email, password: password);

    if (!mounted) return;

    if (error == null) {
      final role = await _authService.getUserRole();

      if (!mounted) return;

      if (role == 'admin') {
        // 🧹 Limpiamos toda la pila de navegación y entramos al panel administrador de raíz
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        setState(() => _isLoading = false);
        // Si inicia sesión pero no es administrador
        await _authService.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Acceso Denegado: Su cuenta no tiene permisos de Administrador"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al ingresar: $error"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Ingreso Administrador"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 80,
                color: Color(0xFF1F3A5F),
              ),
              const SizedBox(height: 16),
              const Text(
                "Panel de Control",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3A5F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ingrese sus credenciales administrativas específicas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              // 📧 Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1F3A5F)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔑 Contraseña
              TextField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF1F3A5F)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF1F3A5F),
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 🟧 Botón Ingresar
              ElevatedButton(
                onPressed: _isLoading ? null : loginAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Entrar como Admin",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // 🔙 Volver
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Volver a Inicio",
                  style: TextStyle(
                    color: Color(0xFF1F3A5F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}