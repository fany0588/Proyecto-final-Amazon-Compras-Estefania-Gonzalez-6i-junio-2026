import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/premium_bottom_nav_bar.dart';
import '../models/cart_item.dart';


class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();

  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  int _selectedRating = 5;
  bool _submitting = false;
  String? _userId;
  String? _userEmail;
  bool _isLoggedIn = false;
  bool _isCheckingLogin = true;
  
  // ✅ Variables para atributos
  ProductAttribute? _selectedAttribute;

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    setState(() {
      _isCheckingLogin = true;
    });
    
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        setState(() {
          _isLoggedIn = true;
          _userId = user.uid;
          _userEmail = user.email;
        });
        
        final userData = await _auth.getUserData();
        if (userData != null && userData['name'] != null && mounted) {
          _nameController.text = userData['name'];
        }
      } else {
        setState(() {
          _isLoggedIn = false;
          _userId = null;
          _userEmail = null;
        });
        _nameController.text = '';
      }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLogin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu nombre y comentario"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRating < 1 || _selectedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecciona una calificación"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await _db.collection('reviews').add({
        'productId': widget.product.id,
        'productName': widget.product.name,
        'userId': _userId ?? 'anonymous',
        'userName': name,
        'userEmail': _userEmail ?? 'no-email@anonymous.com',
        'rating': _selectedRating.toDouble(),
        'comment': comment,
        'date': FieldValue.serverTimestamp(),
      });

      await NotificationService().createNotification(
        userId: 'admin',
        title: "Nueva reseña publicada",
        body: "$name calificó '${widget.product.name}' con $_selectedRating ⭐",
        type: 'new_review',
        extraData: {
          'productId': widget.product.id,
          'productName': widget.product.name,
          'rating': _selectedRating,
        },
      );

      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Reseña agregada con éxito!"),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedRating = 5;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al agregar reseña: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
  
  // ✅ Método para agrupar atributos por tipo
  Map<String, List<ProductAttribute>> _groupAttributesByType(List<ProductAttribute> attributes) {
    final Map<String, List<ProductAttribute>> grouped = {};
    for (var attr in attributes) {
      grouped.putIfAbsent(attr.name, () => []);
      grouped[attr.name]!.add(attr);
    }
    return grouped;
  }
  
  double get _finalPrice => widget.product.price + (_selectedAttribute?.extraPrice ?? 0);

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Detalle del Producto"),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
      ),
      bottomNavigationBar: const PremiumBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductImage(),
            _buildProductInfo(cart),
            const Divider(height: 20),
            _buildReviewsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      color: Colors.white,
      height: 280,
      width: double.infinity,
      child: Hero(
        tag: widget.product.id,
        child: CachedNetworkImage(
          imageUrl: widget.product.image,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF9900),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.image_not_supported,
            size: 80,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1F3A5F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.product.category +
                  (widget.product.subcategory.isNotEmpty
                      ? " > ${widget.product.subcategory}"
                      : ""),
              style: const TextStyle(
                color: Color(0xFF1F3A5F),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3A5F),
            ),
          ),
          const SizedBox(height: 6),
          // ✅ Precio con atributo seleccionado
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedAttribute != null && _selectedAttribute!.extraPrice > 0)
                Row(
                  children: [
                    Text(
                      "\$${widget.product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+\$${_selectedAttribute!.extraPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, color: Colors.orange),
                    ),
                  ],
                ),
              Text(
                "\$${_finalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // ✅ SECCIÓN DE ATRIBUTOS (Talla, Color, etc.)
          if (widget.product.attributes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Opciones disponibles:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ..._groupAttributesByType(widget.product.attributes).entries.map((entry) {
                    final attributeType = entry.key;
                    final options = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attributeType,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: options.map((attr) {
                              final isSelected = _selectedAttribute?.name == attr.name && 
                                                 _selectedAttribute?.value == attr.value;
                              return FilterChip(
                                label: Text(attr.value),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedAttribute = attr;
                                    } else if (isSelected) {
                                      _selectedAttribute = null;
                                    }
                                  });
                                },
                                selectedColor: const Color(0xFFFF9900).withOpacity(0.3),
                                checkmarkColor: const Color(0xFFFF9900),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFFFF9900) : Colors.grey.shade300,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          
          const Text(
            "Descripción del Producto",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3A5F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.product.description.isNotEmpty
                ? widget.product.description
                : "Este es un producto de alta calidad seleccionado por Amazon para ti. Ofrece rendimiento excepcional, durabilidad superior y diseño ergonómico.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // ✅ Verificar selección de atributo si hay opciones
                if (widget.product.attributes.isNotEmpty && _selectedAttribute == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Por favor selecciona una opción (talla, color, etc.)"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                // Crear item con atributo seleccionado
                final cartItem = CartItem(
                  product: widget.product,
                  selectedAttribute: _selectedAttribute,
                  quantity: 1,
                );
                
                cart.addCartItem(cartItem);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${widget.product.name} agregado al carrito!"),
                    backgroundColor: const Color(0xFF1F3A5F),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart, color: Colors.black, size: 20),
              label: const Text(
                "Agregar al Carrito",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Reseñas de Clientes",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3A5F),
            ),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('reviews')
                .where('productId', isEqualTo: widget.product.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        "Error al cargar reseñas: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Aún no hay reseñas. ¡Sé el primero en opinar!",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              }

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

              return Column(
                children: sortedDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final userName = data['userName'] ?? 'Anónimo';
                  final rating = (data['rating'] as num?)?.toDouble() ?? 5.0;
                  final comment = data['comment'] ?? '';
                  final timestamp = data['date'] as Timestamp?;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1F3A5F),
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 14,
                                    color: i < rating.round() ? Colors.amber : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (timestamp != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(timestamp.toDate()),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            comment,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),
          
          if (_isCheckingLogin)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Verificando sesión..."),
                  ],
                ),
              ),
            )
          else if (_isLoggedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Escribir una reseña",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3A5F),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Tu Nombre",
                          hintText: "Ingresa tu nombre",
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            "Calificación: ",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(
                              5,
                              (i) => IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedRating = i + 1;
                                  });
                                },
                                icon: Icon(
                                  Icons.star,
                                  size: 26,
                                  color: i < _selectedRating ? Colors.amber : Colors.grey.shade300,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Tu comentario...",
                          hintText: "Comparte tu experiencia con este producto",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3A5F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Enviar Reseña",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    "Inicia sesión para escribir una reseña",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/login');
                      if (result == true) {
                        await _checkUserLoginStatus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Iniciar Sesión"),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return 'hace ${(difference.inDays / 365).floor()} año(s)';
    } else if (difference.inDays > 30) {
      return 'hace ${(difference.inDays / 30).floor()} mes(es)';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día(s)';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora(s)';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto(s)';
    } else {
      return 'hace unos segundos';
    }
  }
}