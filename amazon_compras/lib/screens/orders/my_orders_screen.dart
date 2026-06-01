import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final String? searchQuery;

  const MyOrdersScreen({super.key, this.searchQuery});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _activeSearchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _activeSearchQuery = widget.searchQuery ?? '';
    _searchController = TextEditingController(text: _activeSearchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Mis Pedidos"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: user == null
          ? const Center(
              child: Text("Por favor, inicia sesión para ver tus pedidos"),
            )
          : Column(
              children: [
                // 🔍 Barra de Búsqueda Interactiva
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        setState(() {
                          _activeSearchQuery = value.trim();
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          _activeSearchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Buscar por ID, producto o estado...",
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF1F3A5F)),
                        suffixIcon: _activeSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _activeSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // 📦 Listado de Órdenes con StreamBuilder
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error al cargar pedidos: ${snapshot.error}"),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      
                      // Ordenar cronológicamente
                      final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
                        ..sort((a, b) {
                          final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                          final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                          if (aTime == null) return 1;
                          if (bTime == null) return -1;
                          return bTime.compareTo(aTime); // Descendente
                        });

                      // Filtrar localmente por query
                      final filteredDocs = _activeSearchQuery.isEmpty
                          ? sortedDocs
                          : sortedDocs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final orderId = doc.id.toLowerCase();
                              final status = (data['status'] ?? '').toString().toLowerCase();
                              final items = data['items'] as List? ?? [];
                              final lowercaseQuery = _activeSearchQuery.toLowerCase();

                              // Coincide con ID del Pedido
                              if (orderId.contains(lowercaseQuery)) return true;
                              // Coincide con Estado del Pedido
                              if (status.contains(lowercaseQuery)) return true;
                              // Coincide con Nombre de Producto
                              for (var it in items) {
                                final name = (it['name'] ?? '').toString().toLowerCase();
                                if (name.contains(lowercaseQuery)) return true;
                              }
                              return false;
                            }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  _activeSearchQuery.isEmpty
                                      ? "Aún no tienes pedidos registrados."
                                      : "No se encontraron pedidos coincidentes.",
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                if (_activeSearchQuery.isNotEmpty)
                                  Text(
                                    "No hay resultados para \"$_activeSearchQuery\"",
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 20),
                                if (_activeSearchQuery.isNotEmpty)
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _activeSearchQuery = '';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9900),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Mostrar todos los pedidos", style: TextStyle(fontWeight: FontWeight.bold)),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9900),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Explorar Productos", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final orderId = doc.id;
                          final data = doc.data() as Map<String, dynamic>;

                          final total = double.tryParse(data['total'].toString()) ?? 0.0;
                          final status = data['status'] ?? 'pendiente';
                          final items = data['items'] as List? ?? [];
                          
                          DateTime date = DateTime.now();
                          if (data['createdAt'] is Timestamp) {
                            date = (data['createdAt'] as Timestamp).toDate();
                          }

                          // Calcular cantidad de items
                          int totalQty = 0;
                          for (var it in items) {
                            totalQty += (it['quantity'] as num? ?? 1).toInt();
                          }

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cabecera: ID & Estado
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Código: $orderId",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Courier',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F3A5F),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusBadge(status),
                                    ],
                                  ),
                                  const Divider(height: 24),

                                  // Detalles: Fecha & Items
                                  Text(
                                    "Fecha de Pedido: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}",
                                    style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Artículos: $totalQty",
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Total Pagado: \$${total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Botón de Rastreo / Detalle
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OrderTrackingScreen(orderId: orderId),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1F3A5F),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.map_outlined, color: Color(0xFFFF9900), size: 18),
                                      label: const Text(
                                        "Rastrear Pedido",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'entregado':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = "Entregado";
        break;
      case 'cancelado':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = "Cancelado";
        break;
      case 'pendiente':
      default:
        bgColor = const Color(0xFFFF9900).withOpacity(0.1);
        textColor = const Color(0xFFFF8800);
        label = "Pendiente";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
