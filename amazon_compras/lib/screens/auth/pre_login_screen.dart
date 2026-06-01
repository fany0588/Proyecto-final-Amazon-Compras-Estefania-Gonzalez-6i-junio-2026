import 'package:flutter/material.dart';

class PreLoginScreen extends StatelessWidget {
  const PreLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🧱 Fondo: Mitad Blanco, Mitad Café (#E6D3B3)
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: const Color(0xFFE6D3B3),
                ),
              ),
            ],
          ),

          // 📱 Contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🏷️ Logo de Amazon (Arriba del contenedor)
                    Center(
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg",
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            "amazon",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // 📦 Contenedor Azul (#1F3A5F) Centrado
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F3A5F),
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "¡Te damos la bienvenida!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Disfruta de la mejor experiencia de compras en línea",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 🟧 Botón 1: Ya eres cliente iniciar sesión (#FF9900)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9900),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Ya eres cliente, iniciar sesión",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // ⬜ Botón 2: Nuevo en Amazon, crear una cuenta (Blanco)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F3A5F),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Nuevo en Amazon, crear una cuenta",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ⬜ Botón 3: Administrador (Blanco)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/admin-login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F3A5F),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Administrador",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // 🗒️ Lista de 3 cosas abajo del contenedor
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          _buildBenefitItem(
                            Icons.local_shipping_outlined,
                            "Envíos gratis y súper rápidos",
                            "Recibe tus productos favoritos en la puerta de tu hogar sin costo adicional.",
                          ),
                          const SizedBox(height: 16),
                          _buildBenefitItem(
                            Icons.security_outlined,
                            "Compras 100% seguras",
                            "Tus pagos y datos personales están protegidos con los estándares más altos.",
                          ),
                          const SizedBox(height: 16),
                          _buildBenefitItem(
                            Icons.keyboard_return_outlined,
                            "Devoluciones fáciles y rápidas",
                            "¿No te gustó? Devuélvelo de manera sencilla sin preguntas complicadas.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F3A5F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1F3A5F),
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3A5F),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
