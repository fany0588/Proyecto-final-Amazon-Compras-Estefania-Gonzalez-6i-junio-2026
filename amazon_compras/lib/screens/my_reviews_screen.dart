import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart'; 

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final AuthService _authService = AuthService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _authService.currentUser?.uid;
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Reseña"),
        content: const Text("¿Estás seguro de que deseas eliminar esta reseña?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('reviews').doc(reviewId).delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Reseña eliminada"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al eliminar: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// ✅ Método para navegar al detalle del producto
  void _navigateToProduct(String productId, String productName) async {
    // Primero obtener el producto completo desde Firestore
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        
        // Importar el modelo de producto
        final product = ProductModel(
          id: productDoc.id,
          name: productData['name'] ?? '',
          description: productData['description'] ?? '',
          price: (productData['price'] ?? 0).toDouble(),
          image: productData['image'] ?? '',
          category: productData['category'] ?? '',
          subcategory: productData['subcategory'] ?? '',
        );
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto no encontrado"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error al cargar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cargar el producto: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Mis Reseñas"),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
      ),
      body: _userId == null
          ? const Center(child: Text("Usuario no autenticado"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('userId', isEqualTo: _userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text("Error: ${snapshot.error}"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text("Reintentar"),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "No has escrito ninguna reseña aún",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "¡Califica los productos que has comprado!",
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                // Ordenar en memoria
                final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                sortedDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aDate = aData['date'] as Timestamp?;
                  final bDate = bData['date'] as Timestamp?;
                  
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;
                  return bDate.compareTo(aDate);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final data = sortedDocs[index].data() as Map<String, dynamic>;
                    final reviewId = sortedDocs[index].id;
                    final productName = data['productName'] ?? 'Producto';
                    final productId = data['productId'] ?? '';
                    final rating = (data['rating'] as num?)?.toDouble() ?? 5.0;
                    final comment = data['comment'] ?? '';
                    final timestamp = data['date'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Producto y rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1F3A5F),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      size: 16,
                                      color: i < rating.round() ? Colors.amber : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Fecha
                            if (timestamp != null)
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate()),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            const SizedBox(height: 8),
                            // Comentario
                            Text(
                              comment,
                              style: const TextStyle(fontSize: 14, height: 1.3),
                            ),
                            const SizedBox(height: 12),
                            // Botones de acción
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    if (productId.isNotEmpty) {
                                      _navigateToProduct(productId, productName);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("ID de producto no disponible"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text("Ver Producto"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF1F3A5F),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _deleteReview(reviewId),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text("Eliminar"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
