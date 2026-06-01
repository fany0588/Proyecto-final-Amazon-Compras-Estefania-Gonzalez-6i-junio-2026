import 'package:flutter/material.dart';
import '../orders/my_orders_screen.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderId;

  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 🎉 Icono Animado / Grande de éxito
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 💬 Mensaje de éxito
              const Text(
                "¡Pedido Realizado!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3A5F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tu pedido ha sido registrado con éxito en nuestro sistema y está listo para ser procesado.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              
              // Mostrar ID de orden
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "Código de Pedido: $orderId",
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF1F3A5F),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 📦 Botón 1: Ver mis pedidos
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.local_shipping_outlined, color: Color(0xFFFF9900)),
                label: const Text(
                  "Ver mis pedidos",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // 🛍️ Botón 2: Seguir comprando
              ElevatedButton(
                onPressed: () {
                  // Volver al Home principal limpiando el stack
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1F3A5F),
                  side: const BorderSide(color: Color(0xFF1F3A5F)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                child: const Text(
                  "Seguir comprando",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
