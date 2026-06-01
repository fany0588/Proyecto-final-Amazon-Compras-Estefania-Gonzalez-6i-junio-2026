import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _cartSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _cartSlide = Tween<double>(begin: -150, end: 400).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();

    // Redirige al wrapper de sesión después de 3.2 segundos
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🧱 Fondo en degradado radial premium
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF2C4E7E),
                  Color(0xFF13243C),
                ],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),

          // 📱 Contenido principal centrado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 📦 Logo de la app con animación de escala y opacidad
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo circular premium
                            Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Texto del Logo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "amazon",
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  " compras",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFFFF9900).withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 80),

                // 🛒 Carrito deslizándose
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Mapear de -150 a ancho total
                    final double slideOffset = (_cartSlide.value / 400.0) * (size.width + 200) - 150;
                    return Transform.translate(
                      offset: Offset(slideOffset, 0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9900).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 40,
                          color: Color(0xFFFF9900),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 📝 Eslogan inferior sutil
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Entregando Sonrisas a tu Puerta",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}