import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Rastreo en Tiempo Real"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("No se encontró información del pedido."),
            );
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final status = orderData['status'] ?? 'pendiente';
          final total = double.tryParse(orderData['total'].toString()) ?? 0.0;
          final payment = orderData['paymentMethod'] ?? 'efectivo';
          final items = orderData['items'] as List? ?? [];
          final address = orderData['address'] as Map<String, dynamic>? ?? {};

          DateTime date = DateTime.now();
          if (orderData['createdAt'] is Timestamp) {
            date = (orderData['createdAt'] as Timestamp).toDate();
          }

          // Determinar valor de progreso para la animación
          double targetProgress = 0.15; // Pedido Confirmado
          if (status == 'pendiente') {
            targetProgress = 0.55; // En Camino
          } else if (status == 'entregado') {
            targetProgress = 1.0; // Entregado
          } else if (status == 'cancelado') {
            targetProgress = 1.0; // Cancelado
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🏷️ Cabecera de la orden
                _buildOrderHeader(orderId, status, date),
                const SizedBox(height: 20),

                // 🚚 ANIMACIÓN INTERACTIVA (Steppers con TweenAnimationBuilder)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Estado del Envío",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F3A5F),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // TweenAnimationBuilder para el progreso de la línea
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: targetProgress),
                          duration: const Duration(seconds: 2),
                          curve: Curves.fastOutSlowIn,
                          builder: (context, progress, child) {
                            return _buildAnimatedTracker(status, progress);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 📍 Detalles de entrega
                _buildDeliveryDetailsCard(address, payment, total),
                const SizedBox(height: 20),

                // 📦 Artículos en el paquete
                _buildItemsListCard(items),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(String id, String status, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3A5F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pedido: #${id.substring(0, 8).toUpperCase()}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Realizado el ${DateFormat('dd MMMM yyyy, HH:mm').format(date)}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Genera el stepper interactivo animado
  Widget _buildAnimatedTracker(String status, double progress) {
    final isCancelled = status == 'cancelado';
    final activeColor = isCancelled ? Colors.red : const Color(0xFFFF9900);
    final inactiveColor = Colors.grey.shade300;

    return Column(
      children: [
        // Renglón de Iconos y Línea animada
        Stack(
          alignment: Alignment.center,
          children: [
            // Línea de Fondo gris
            Container(
              height: 6,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Línea de Progreso activa animada
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.only(left: 32, right: 32),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Nodos / Paradas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepNode(
                  icon: Icons.assignment_turned_in_outlined,
                  isActive: progress >= 0.15,
                  isCancelled: isCancelled,
                  label: "Confirmado",
                ),
                _buildStepNode(
                  icon: isCancelled ? Icons.close : Icons.local_shipping_outlined,
                  isActive: progress >= 0.55,
                  isCancelled: isCancelled,
                  label: isCancelled ? "Cancelado" : "En Camino",
                ),
                _buildStepNode(
                  icon: isCancelled ? Icons.delete_forever_outlined : Icons.home_work_outlined,
                  isActive: progress >= 1.0,
                  isCancelled: isCancelled,
                  label: isCancelled ? "Sin Entrega" : "Entregado",
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Mensaje de Estado interactivo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: activeColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCancelled
                    ? Icons.cancel
                    : (status == 'entregado'
                        ? Icons.stars_rounded
                        : Icons.pending_actions_outlined),
                color: activeColor,
              ),
              const SizedBox(width: 8),
              Text(
                isCancelled
                    ? "Tu pedido ha sido CANCELADO."
                    : (status == 'entregado'
                        ? "¡Pedido entregado con éxito!"
                        : "Tu pedido está de camino a tu dirección."),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: activeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepNode({
    required IconData icon,
    required bool isActive,
    required bool isCancelled,
    required String label,
  }) {
    final nodeColor = isCancelled
        ? (isActive ? Colors.red : Colors.grey.shade300)
        : (isActive ? const Color(0xFFFF9900) : Colors.grey.shade300);

    final iconColor = isCancelled
        ? (isActive ? Colors.white : Colors.grey.shade600)
        : (isActive ? Colors.black : Colors.grey.shade600);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: nodeColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: nodeColor.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF1F3A5F) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDetailsCard(Map<String, dynamic> address, String payment, double total) {
    String payLabel = "";
    if (payment == 'efectivo') payLabel = "Efectivo al recibir";
    else if (payment == 'tarjeta') payLabel = "Tarjeta Bancaria";
    else if (payment == 'paypal') payLabel = "PayPal";

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_history, color: Color(0xFF1F3A5F)),
                SizedBox(width: 8),
                Text("Detalles de Entrega", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 6),
            const Text("Dirección:", style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text(
              "${address['name'] ?? 'S/N'}\n${address['street'] ?? 'Sin Calle'}\n${address['city'] ?? ''}, ${address['state'] ?? ''} CP ${address['zip'] ?? ''}",
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Método de Pago:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(payLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Monto Pagado:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsListCard(List items) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: Color(0xFF1F3A5F)),
                SizedBox(width: 8),
                Text("Productos en este paquete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final it = items[index] as Map<String, dynamic>;
                final name = it['name'] ?? 'Producto';
                final price = double.tryParse(it['price'].toString()) ?? 0.0;
                final qty = it['quantity'] as int? ?? 1;
                final img = it['image'] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          img,
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey, width: 45, height: 45, child: const Icon(Icons.image)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text("Cantidad: $qty", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(
                        "\$${price.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
