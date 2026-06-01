import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
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

    setState(() {
      loading = true;
    });

    final error = await _authService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (error == null) {
      final role = await _authService.getUserRole();

      if (!mounted) return;

      // 🧹 Limpiar la pila y establecer la pantalla correspondiente como raíz
      if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔙 Botón flotante para regresar (opcional/limpio)
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F3A5F), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                const SizedBox(height: 10),

                // 🏷️ Logo de la aplicación
                Center(
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Títulos e identidad de marca
                const Text(
                  "Iniciar Sesión",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3A5F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "¡Qué bueno verte de nuevo por aquí!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),

                const SizedBox(height: 35),

                // 📦 Formulario contenedor estilizado
                Container(
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Correo Electrónico
                      const Text(
                        "Correo electrónico",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1F3A5F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "ejemplo@correo.com",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1F3A5F), size: 20),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contraseña
                      const Text(
                        "Contraseña",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1F3A5F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Ingrese su contraseña",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1F3A5F), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botón Ingresar
                      ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Enlace a registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Aún no tienes cuenta? ',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        'Crea una aquí',
                        style: TextStyle(
                          color: Color(0xFF1F3A5F),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}