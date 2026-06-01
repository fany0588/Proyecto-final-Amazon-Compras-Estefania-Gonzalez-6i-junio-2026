import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
  final name = _nameController.text.trim();
  final phone = _phoneController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirm = _confirmPasswordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    _showError("Por favor completa todos los campos obligatorios.");
    return;
  }

  if (password != confirm) {
    _showError("Las contraseñas no coinciden.");
    return;
  }

  if (password.length < 6) {
    _showError("La contraseña debe tener al menos 6 caracteres.");
    return;
  }

  setState(() => _isLoading = true);

  final error = await _authService.register(
    name: name,
    phone: phone,
    email: email,
    password: password,
    role: 'cliente',
  );

  if (mounted) {
    setState(() => _isLoading = false);
  }

  if (error == null) {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  } else {
    _showError(error);
  }
}

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3A5F),
        title: const Text('Crear Cuenta'),
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Header
              const SizedBox(height: 8),
              Center(
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg',
                  height: 40,
                  errorBuilder: (c, e, s) => const Text(
                    'amazon',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9900),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Crea tu cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3A5F),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los campos para registrarte',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 28),

              // ── NOMBRE COMPLETO ──
              _buildLabel('Nombre completo *'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nameController,
                hint: 'Ej. María García López',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // ── TELÉFONO ──
              _buildLabel('Teléfono (opcional)'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _phoneController,
                hint: 'Ej. 55 1234 5678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ── CORREO ──
              _buildLabel('Correo electrónico *'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _emailController,
                hint: 'ejemplo@correo.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // ── CONTRASEÑA ──
              _buildLabel('Contraseña *'),
              const SizedBox(height: 6),
              _buildPasswordField(
                controller: _passwordController,
                hint: 'Mínimo 6 caracteres',
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),

              // ── CONFIRMAR CONTRASEÑA ──
              _buildLabel('Confirmar contraseña *'),
              const SizedBox(height: 6),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: 'Repite tu contraseña',
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 32),

              // ── BOTÓN REGISTRARSE ──
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // ── YA TENGO CUENTA ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta? '),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: Color(0xFF1F3A5F),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Color(0xFF1F3A5F),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF1F3A5F), size: 20),
        filled: true,
        fillColor: Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFF1F3A5F), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1F3A5F), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFF1F3A5F), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}