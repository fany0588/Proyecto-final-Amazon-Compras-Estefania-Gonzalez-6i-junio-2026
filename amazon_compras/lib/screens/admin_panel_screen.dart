import 'package:flutter/material.dart';
// ... el resto de tus imports
import '../models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/support_message_service.dart';


class AdminMenuItem {
  final IconData icon;
  final String title;
  final Color color;

  AdminMenuItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}

// Modelos adicionales
class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class PaymentMethodModel {
  final String id;
  final String name;
  final String icon;
  final bool isActive;
  final String description;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'isActive': isActive,
      'description': description,
    };
  }

  factory PaymentMethodModel.fromMap(String id, Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '💰',
      isActive: map['isActive'] ?? true,
      description: map['description'] ?? '',
    );
  }
}

class CarrierModel {
  final String id;
  final String name;
  final String logo;
  final double baseRate;
  final double ratePerKm;
  final int estimatedDays;
  final bool isActive;

  CarrierModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.baseRate,
    required this.ratePerKm,
    required this.estimatedDays,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logo': logo,
      'baseRate': baseRate,
      'ratePerKm': ratePerKm,
      'estimatedDays': estimatedDays,
      'isActive': isActive,
    };
  }

  factory CarrierModel.fromMap(String id, Map<String, dynamic> map) {
    return CarrierModel(
      id: id,
      name: map['name'] ?? '',
      logo: map['logo'] ?? '',
      baseRate: (map['baseRate'] ?? 0).toDouble(),
      ratePerKm: (map['ratePerKm'] ?? 0).toDouble(),
      estimatedDays: map['estimatedDays'] ?? 1,
      isActive: map['isActive'] ?? true,
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final ProductService _productService = ProductService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _selectedIndex = 0;
  late final ScrollController _scrollController;

  // ✅ Diccionario para almacenar controllers por userId (CORRECCIÓN PRINCIPAL)
  final Map<String, TextEditingController> _replyControllers = {};

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(icon: Icons.inventory_2, title: "Productos", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.category, title: "Categorías", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.star, title: "Reseñas", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.payment, title: "Métodos de Pago", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.local_shipping, title: "Transportistas", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.receipt_long, title: "Pedidos", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.people, title: "Clientes", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.location_on, title: "Direcciones", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.chat_bubble_outline, title: "Mensajes", color: const Color(0xFF1F3A5F)),
    AdminMenuItem(icon: Icons.notifications_outlined, title: "Notificaciones", color: const Color(0xFF1F3A5F)),
  ];

  final List<String> _categories = [
    "Deportes", "Regalos", "Ofertas", "Super y convivencia",
    "Farmacia y cuidado personal", "Mascotas", "Moda y belleza",
    "Hogar y diy", "Música", "Video y gaming", "Electrónica",
    "Libros y lectura", "Juguetes y bebes", "Ropa"
  ];

  final List<String> _subcategories = ["Hombre", "Mujer", "Niños", "Niñas"];

  // Variables temporales para atributos en el formulario
  List<ProductAttribute> _tempAttributes = [];

  // ✅ Método para obtener o crear controller para un userId específico
  TextEditingController _getReplyController(String userId) {
  final safeUserId = userId.isEmpty || userId == 'unknown' ? 'default' : userId;
  if (!_replyControllers.containsKey(safeUserId)) {
    _replyControllers[safeUserId] = TextEditingController();
  }
  return _replyControllers[safeUserId]!;
}
@override
void initState() {
  super.initState();
  _scrollController = ScrollController();
}

  // Agregar atributo
  void _addAttribute() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final extraPriceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings, color: Color(0xFFFF9900)),
              SizedBox(width: 8),
              Text("Agregar Atributo", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nombre (ej: Talla, Color, Material)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: "Valor (ej: M, Rojo, Algodón)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: extraPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Precio extra (opcional)",
                    border: OutlineInputBorder(),
                    helperText: "Dejar 0 si no aplica",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final value = valueController.text.trim();
                if (name.isEmpty || value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Completa nombre y valor"), backgroundColor: Colors.red),
                  );
                  return;
                }
                final extraPrice = double.tryParse(extraPriceController.text.trim()) ?? 0;
                setState(() {
                  _tempAttributes.add(ProductAttribute(name: name, value: value, extraPrice: extraPrice));
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9900)),
              child: const Text("Agregar", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _removeAttribute(int index) {
    setState(() {
      _tempAttributes.removeAt(index);
    });
  }

  @override
  void dispose() {
    // ✅ Limpiar todos los controllers (CORRECCIÓN)
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _replyControllers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: _buildAppBar(),
      drawer: isMobile ? Drawer(child: _buildSideMenuContent()) : null,
      body: isMobile
          ? _buildMainContent()
          : Row(
              children: [
                _buildSideMenu(),
                Expanded(child: _buildMainContent()),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Panel de Administración",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF1F3A5F),
      elevation: 2,
      leading: Builder(
        builder: (context) {
          final isMobile = MediaQuery.of(context).size.width < 700;
          if (isMobile) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/pre-login', (route) => false);
              }
            },
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: const Text("Salir"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9900),
              foregroundColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _buildSideMenuContent(),
    );
  }

  Widget _buildSideMenuContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            "MENÚ ADMIN",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3A5F),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final isSelected = _selectedIndex == index;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1F3A5F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? const Color(0xFFFF9900) : Colors.grey[600],
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildContentHeader(),
            Expanded(
              child: _buildContentBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader() {
    final titles = [
      "Productos", "Categorías", "Reseñas",
      "Método Pago", "Transportes", "Pedidos",
      "Clientes", "Direcciones", "Mensajes de Soporte", "Notificaciones"
    ];
    final icons = [
      Icons.inventory_2, Icons.category, Icons.star,
      Icons.payment, Icons.local_shipping, Icons.receipt_long,
      Icons.people, Icons.location_on, Icons.chat_bubble_outline, Icons.notifications_outlined
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1F3A5F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(icons[_selectedIndex], color: const Color(0xFFFF9900), size: 28),
          const SizedBox(width: 12),
          Text(
            titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (_shouldShowFloatingButton())
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Nuevo registro"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildProductsTab();
      case 1:
        return _buildCategoriasTab();
      case 2:
        return _buildReviewsTab();
      case 3:
        return _buildPaymentMethodsTab();
      case 4:
        return _buildCarriersTab();
      case 5:
        return _buildOrdersTab();
      case 6:
        return _buildClientesTab();
      case 7:
        return _buildDireccionesTab();
      case 8:
        return _buildMessagesTab(); // ✅ TAB CORREGIDA
      case 9:
        return _buildAdminNotificationsTab();
      default:
        return const Center(child: Text("Selecciona una opción"));
    }
  }

  bool _shouldShowFloatingButton() {
    return _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 3 || _selectedIndex == 4;
  }

  void _showCreateDialog() {
    switch (_selectedIndex) {
      case 0:
        _showProductFormDialog();
        break;
      case 1:
        _showCategoriaFormDialog();
        break;
      case 3:
        _showPaymentMethodFormDialog();
        break;
      case 4:
        _showCarrierFormDialog();
        break;
    }
  }

  // ==================== TAB 1: PRODUCTOS ====================
  Widget _buildProductsTab() {
    return StreamBuilder<List<ProductModel>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay productos en el catálogo."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              product.category,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (product.subcategory.isNotEmpty)
              Text(
                "Sub: ${product.subcategory}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            if (product.attributes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: product.attributes.map((attr) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFF9900).withOpacity(0.4)),
                      ),
                      child: Text(
                        "${attr.name}: ${attr.value}${(attr.extraPrice ?? 0) > 0 ? ' (+\$${((attr.extraPrice ?? 0).toStringAsFixed(2))})' : ''}",
                        style: const TextStyle(fontSize: 10, color: Color(0xFF1F3A5F)),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showProductFormDialog(product: product),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteProduct(product.id, product.name),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getCategoriesWithSubcategories() async {
    final snapshot = await _firestore.collection('categorias').get();
    final Map<String, List<Map<String, dynamic>>> result = {};
    
    final categoriasPadre = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['padreId'] == null || data['padreId'].toString().isEmpty;
    });
    
    for (var padre in categoriasPadre) {
      final padreData = padre.data() as Map<String, dynamic>;
      final padreNombre = padreData['nombre'] ?? 'Sin nombre';
      
      final subcategorias = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['padreId'] == padre.id;
      }).map((sub) {
        final subData = sub.data() as Map<String, dynamic>;
        return {
          'id': sub.id,
          'nombre': subData['nombre'] ?? 'Sin nombre',
        };
      }).toList();
      
      result[padreNombre] = subcategorias;
    }
    
    return result;
  }

  // ==================== TAB 2: CATEGORÍAS ====================
  Widget _buildCategoriasTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('categorias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final categorias = snapshot.data?.docs ?? [];

        if (categorias.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay categorías."),
              ],
            ),
          );
        }

        final Map<String, List<QueryDocumentSnapshot>> subcategorias = {};
        final List<QueryDocumentSnapshot> categoriasPadre = [];

        for (var cat in categorias) {
          final data = cat.data() as Map<String, dynamic>;
          final padreId = data['padreId'];
          
          if (padreId == null || padreId.toString().isEmpty) {
            categoriasPadre.add(cat);
          } else {
            subcategorias.putIfAbsent(padreId.toString(), () => []);
            subcategorias[padreId.toString()]!.add(cat);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categoriasPadre.length,
          itemBuilder: (context, index) {
            final catPadre = categoriasPadre[index];
            final dataPadre = catPadre.data() as Map<String, dynamic>;
            final hijos = subcategorias[catPadre.id] ?? [];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: dataPadre['imageUrl'] != null && dataPadre['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                          dataPadre['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: const Color(0xFF1F3A5F).withOpacity(0.1),
                            child: const Icon(Icons.category, color: Color(0xFF1F3A5F)),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFF1F3A5F).withOpacity(0.1),
                          child: const Icon(Icons.category, color: Color(0xFF1F3A5F)),
                        ),
                ),
                title: Text(
                  dataPadre['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${hijos.length} subcategoría${hijos.length != 1 ? 's' : ''}"),
                    if (dataPadre['imageUrl'] != null && dataPadre['imageUrl'].toString().isNotEmpty)
                      const SizedBox(height: 4),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCategoriaFormDialog(
                        categoria: dataPadre,
                        id: catPadre.id,
                      ),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteCategoria(catPadre.id, dataPadre['nombre'] ?? ''),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
                children: [
                  if (hijos.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(),
                    ),
                  ...hijos.map((hija) {
                    final dataHija = hija.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.subdirectory_arrow_right, size: 20, color: Colors.grey),
                      title: Text(dataHija['nombre'] ?? 'Sin nombre'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: () => _showCategoriaFormDialog(
                              categoria: dataHija,
                              id: hija.id,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _confirmDeleteCategoria(hija.id, dataHija['nombre'] ?? ''),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showCategoriaFormDialog(padreId: catPadre.id),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Agregar Subcategoría"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: const Color(0xFF1F3A5F),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== TAB 3: RESEÑAS ====================
  Widget _buildReviewsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reviews').orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data?.docs ?? [];

        if (reviews.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay reseñas registradas."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = ReviewModel.fromMap(reviews[index].id, reviews[index].data() as Map<String, dynamic>);
            return _buildReviewCard(review);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1F3A5F),
                  child: Text(review.userName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        review.productName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(review.rating.toString()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment),
            const SizedBox(height: 8),
            Text(
              _formatDate(review.date),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _confirmDeleteReview(review.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 4: MÉTODOS DE PAGO ====================
  Widget _buildPaymentMethodsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('payment_methods').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final methods = snapshot.data?.docs ?? [];

        if (methods.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay métodos de pago configurados."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = PaymentMethodModel.fromMap(methods[index].id, methods[index].data() as Map<String, dynamic>);
            return _buildPaymentMethodCard(method);
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodModel method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1F3A5F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              method.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(method.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: method.isActive,
              onChanged: (value) => _togglePaymentMethod(method.id, value),
              activeColor: const Color(0xFFFF9900),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showPaymentMethodFormDialog(method: method),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeletePaymentMethod(method.id, method.name),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 5: TRANSPORTISTAS ====================
  Widget _buildCarriersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('carriers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final carriers = snapshot.data?.docs ?? [];

        if (carriers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay transportistas configurados."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: carriers.length,
          itemBuilder: (context, index) {
            final carrier = CarrierModel.fromMap(carriers[index].id, carriers[index].data() as Map<String, dynamic>);
            return _buildCarrierCard(carrier);
          },
        );
      },
    );
  }

  Widget _buildCarrierCard(CarrierModel carrier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: carrier.logo.isNotEmpty
              ? Image.network(
                  carrier.logo,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: const Color(0xFF1F3A5F).withOpacity(0.1),
                    child: const Icon(Icons.local_shipping, color: Color(0xFF1F3A5F)),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFF1F3A5F).withOpacity(0.1),
                  child: const Icon(Icons.local_shipping, color: Color(0xFF1F3A5F)),
                ),
        ),
        title: Text(
          carrier.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tarifa base: \$${carrier.baseRate.toStringAsFixed(2)}"),
            Text("Por km: \$${carrier.ratePerKm.toStringAsFixed(2)} | Entrega: ${carrier.estimatedDays} días"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: carrier.isActive,
              onChanged: (value) => _toggleCarrier(carrier.id, value),
              activeColor: const Color(0xFFFF9900),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showCarrierFormDialog(carrier: carrier),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteCarrier(carrier.id, carrier.name),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 6: PEDIDOS ====================
  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No se han realizado pedidos en la tienda."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildOrderCard(docs[index]),
        );
      },
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderId = doc.id;
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pendiente';
    final total = double.tryParse(data['total'].toString()) ?? 0.0;
    final address = data['address'] as Map<String, dynamic>? ?? {};
    final userId = data['userId']?.toString() ?? '';
    final paymentMethod = data['paymentMethod']?.toString() ?? 'No especificado';
    final timestamp = data['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F3A5F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusDropdown(orderId, status),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person_outline, "Cliente", address['name'] ?? 'Sin nombre'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.attach_money, "Total", "\$${total.toStringAsFixed(2)}",
                valueColor: Colors.green),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.payment, "Pago", paymentMethod),
            if (timestamp != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_today, "Fecha",
                  "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"),
            ],
            if (userId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3A5F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "UID: ${userId.substring(0, userId.length > 12 ? 12 : userId.length)}...",
                  style: const TextStyle(fontSize: 10, color: Color(0xFF1F3A5F)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== TAB 7: CLIENTES ====================
  Widget _buildClientesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final clientes = snapshot.data?.docs ?? [];

        if (clientes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay clientes registrados."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clientes.length,
          itemBuilder: (context, index) => _buildClienteCard(clientes[index]),
        );
      },
    );
  }

  Widget _buildClienteCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = doc.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1F3A5F),
          child: Text(
            data['name']?.toString()[0]?.toUpperCase() ?? '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          data['name'] ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(data['email'] ?? 'Sin email'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, "Teléfono", data['phone'] ?? 'No registrado'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.badge, "Rol", data['role'] ?? 'cliente'),
                const SizedBox(height: 16),
                if ((data['role'] ?? 'cliente') == 'cliente')
                  ElevatedButton.icon(
                    onPressed: () => _updateClienteRol(uid, 'admin'),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text("Hacer Administrador"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if ((data['role'] ?? 'cliente') == 'admin')
                  ElevatedButton.icon(
                    onPressed: () => _updateClienteRol(uid, 'cliente'),
                    icon: const Icon(Icons.person),
                    label: const Text("Quitar Admin"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 8: DIRECCIONES ====================
  Widget _buildDireccionesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = userSnapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No hay direcciones registradas."),
              ],
            ),
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadAllAddresses(users),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allAddresses = snapshot.data ?? [];

            if (allAddresses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No hay direcciones registradas."),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allAddresses.length,
              itemBuilder: (context, index) => _buildAddressCard(allAddresses[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> item) {
    final address = item['address'] as AddressModel;
    final userName = item['userName'];
    final userEmail = item['userEmail'];
    final addressDocId = item['addressDocId'];
    final userId = item['userId'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F3A5F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on, color: Color(0xFF1F3A5F)),
        ),
        title: Text(
          address.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address.street),
            Text("${address.city}, ${address.state} ${address.zip}"),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1F3A5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Cliente: $userName ($userEmail)",
                style: const TextStyle(fontSize: 11, color: Color(0xFF1F3A5F)),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showDireccionFormDialog(
                direccion: address,
                userId: userId,
                addressDocId: addressDocId,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteAddress(userId, addressDocId, address.name),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 9: MENSAJES DE SOPORTE (CORREGIDA) ====================
// ==================== TAB 9: MENSAJES DE SOPORTE (VERSIÓN CON BOTTOMSHEET) ====================
Widget _buildMessagesTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('messages').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("No hay mensajes de soporte."),
            ],
          ),
        );
      }

      final messages = snapshot.data!.docs;

      // Group messages by userId
      final Map<String, List<QueryDocumentSnapshot>> grouped = {};
      for (var doc in messages) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId']?.toString() ?? 'unknown';
        grouped.putIfAbsent(userId, () => []);
        grouped[userId]!.add(doc);
      }

      if (grouped.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("No hay mensajes de soporte."),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.keys.length,
        itemBuilder: (context, index) {
          final userId = grouped.keys.elementAt(index);
          final userMessages = grouped[userId]!;

          // Sort by date
          userMessages.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = aData['createdAt'] as Timestamp?;
            final bDate = bData['createdAt'] as Timestamp?;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return aDate.compareTo(bDate);
          });

          final firstMsg = userMessages.first.data() as Map<String, dynamic>;
          final userName = firstMsg['userName'] ?? 'Usuario';
          final userEmail = firstMsg['userEmail'] ?? '';

          return _buildChatCard(
            userName: userName,
            userEmail: userEmail,
            userId: userId,
            messages: userMessages,
          );
        },
      );
    },
  );
}

// Widget de tarjeta de chat (sin TextField dentro)
Widget _buildChatCard({
  required String userName,
  required String userEmail,
  required String userId,
  required List<QueryDocumentSnapshot> messages,
}) {
  final isExpanded = ValueNotifier<bool>(false);
  
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        // Header
        ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1F3A5F),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(userEmail, style: const TextStyle(fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de responder (fuera del expansion)
              IconButton(
                icon: const Icon(Icons.reply, color: Color(0xFFFF9900)),
                onPressed: () => _showReplyBottomSheet(
                  context: context,
                  userId: userId,
                  userName: userName,
                ),
                tooltip: 'Responder',
              ),
              // Botón de expandir
              ValueListenableBuilder<bool>(
                valueListenable: isExpanded,
                builder: (context, expanded, _) {
                  return IconButton(
                    icon: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF1F3A5F),
                    ),
                    onPressed: () => isExpanded.value = !isExpanded.value,
                  );
                },
              ),
            ],
          ),
        ),
        
        // Contenido expandible (solo mensajes, sin TextField)
        ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, expanded, _) {
            if (!expanded) return const SizedBox.shrink();
            
            return Column(
              children: [
                const Divider(height: 1),
                
                // Lista de mensajes
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, msgIndex) {
                    final data = messages[msgIndex].data() as Map<String, dynamic>;
                    final message = data['message'] ?? '';
                    final isAdmin = data['isAdmin'] ?? false;
                    final timestamp = data['createdAt'] as Timestamp?;
                    
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAdmin ? const Color(0xFFFF9900).withOpacity(0.2) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAdmin ? "Soporte (Admin)" : userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF1F3A5F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(message, style: const TextStyle(fontSize: 13)),
                            if (timestamp != null)
                              Text(
                                "${timestamp.toDate().day}/${timestamp.toDate().month} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// ✅ BottomSheet para responder (el teclado funciona perfectamente aquí)
void _showReplyBottomSheet({
  required BuildContext context,
  required String userId,
  required String userName,
}) {
  final replyController = TextEditingController();
  final focusNode = FocusNode();
  
  // Auto-focus cuando se abre el BottomSheet
  Future.delayed(const Duration(milliseconds: 100), () {
    focusNode.requestFocus();
  });
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1F3A5F),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Responder a $userName",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "Escribe tu respuesta",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Campo de texto
            TextField(
              controller: replyController,
              focusNode: focusNode,
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: "Escribe tu mensaje...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F1E8),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) async {
                await _sendReplyFromBottomSheet(
                  context: context,
                  userId: userId,
                  userName: userName,
                  replyController: replyController,
                );
              },
            ),
            const SizedBox(height: 16),
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _sendReplyFromBottomSheet(
                        context: context,
                        userId: userId,
                        userName: userName,
                        replyController: replyController,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Enviar"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  ).then((_) {
    // Limpiar cuando se cierra el BottomSheet
    replyController.dispose();
    focusNode.dispose();
  });
}

// Enviar respuesta desde el BottomSheet
// Enviar respuesta desde el BottomSheet
Future<void> _sendReplyFromBottomSheet({
  required BuildContext context,
  required String userId,
  required String userName,
  required TextEditingController replyController,
}) async {
  final text = replyController.text.trim();
  if (text.isEmpty) return;
  
  await SupportMessageService().sendMessage(
    userId: userId,
    userName: 'Administrador',
    userEmail: 'admin@amazon.com',
    message: text,
    isAdmin: true,
  );
  
  if (context.mounted) {
    Navigator.pop(context); // Cerrar el BottomSheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( // ✅ Sin 'const'
        content: Text("✅ Respuesta enviada a $userName"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2), // ✅ 'const' permitido aquí
      ),
    );
  }
}

// ✅ Widget separado para cada conversación (evita conflictos de estado)
Widget _buildUserChatCard({
  required String userName,
  required String userEmail,
  required String userId,
  required List<QueryDocumentSnapshot> messages,
  required TextEditingController replyController,
}) {
  final isExpanded = ValueNotifier<bool>(false);
  
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        // Header (siempre visible)
        ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1F3A5F),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(userEmail, style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, _) {
                return Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF1F3A5F),
                );
              },
            ),
            onPressed: () => isExpanded.value = !isExpanded.value,
          ),
        ),
        
        // Contenido expandible
        ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, expanded, _) {
            if (!expanded) return const SizedBox.shrink();
            
            return Column(
              children: [
                const Divider(height: 1),
                
                // Mensajes
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, msgIndex) {
                    final data = messages[msgIndex].data() as Map<String, dynamic>;
                    final message = data['message'] ?? '';
                    final isAdmin = data['isAdmin'] ?? false;
                    final timestamp = data['createdAt'] as Timestamp?;
                    
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAdmin ? const Color(0xFFFF9900).withOpacity(0.2) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAdmin ? "Soporte (Admin)" : userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF1F3A5F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(message, style: const TextStyle(fontSize: 13)),
                            if (timestamp != null)
                              Text(
                                "${timestamp.toDate().day}/${timestamp.toDate().month} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Divider(height: 1),
                
                // Input para responder - USANDO FocusNode para mejor manejo del teclado
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          focusNode: FocusNode(), // ✅ FocusNode independiente
                          decoration: InputDecoration(
                            hintText: "Responder a $userName...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendReply(
                            userId: userId,
                            userName: userName,
                            replyController: replyController,
                            context: context,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _sendReply(
                          userId: userId,
                          userName: userName,
                          replyController: replyController,
                          context: context,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(60, 48),
                        ),
                        child: const Text("Enviar"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// ✅ Función auxiliar para enviar respuestas
void _sendReply({
  required String userId,
  required String userName,
  required TextEditingController replyController,
  required BuildContext context,
}) async {
  final text = replyController.text.trim();
  if (text.isEmpty) return;
  
  // Mostrar indicador de carga
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text("Enviando respuesta..."),
        ],
      ),
      duration: Duration(seconds: 1),
    ),
  );
  
  await SupportMessageService().sendMessage(
    userId: userId,
    userName: 'Administrador',
    userEmail: 'admin@amazon.com',
    message: text,
    isAdmin: true,
  );
  
  replyController.clear();
  
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Respuesta enviada"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  // ==================== TAB 10: NOTIFICACIONES ADMIN ====================
  Widget _buildAdminNotificationsTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F3A5F).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1F3A5F).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign_outlined, color: Color(0xFF1F3A5F)),
                  SizedBox(width: 8),
                  Text(
                    "Enviar Anuncio a Todos",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F3A5F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showSendAnnouncementDialog(),
                icon: const Icon(Icons.send, size: 18),
                label: const Text("Crear Anuncio"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('notifications')
                .where('userId', isEqualTo: 'admin')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              final sorted = List<QueryDocumentSnapshot>.from(docs);
              sorted.sort((a, b) {
                final aDate = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final bDate = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                if (aDate == null) return -1;
                if (bDate == null) return 1;
                return bDate.compareTo(aDate);
              });

              if (sorted.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No hay notificaciones de administrador."),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final data = sorted[index].data() as Map<String, dynamic>;
                  final id = sorted[index].id;
                  final title = data['title'] ?? '';
                  final body = data['body'] ?? '';
                  final isRead = data['isRead'] ?? false;
                  final type = data['type'] ?? '';
                  final timestamp = data['createdAt'] as Timestamp?;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isRead
                              ? Colors.grey.shade100
                              : const Color(0xFFFF9900).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getNotificationIcon(type),
                          color: isRead ? Colors.grey : const Color(0xFFFF9900),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (timestamp != null)
                            Text(
                              _formatDate(timestamp.toDate()),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isRead)
                            IconButton(
                              icon: const Icon(Icons.done, color: Colors.green, size: 20),
                              onPressed: () {
                                _firestore
                                    .collection('notifications')
                                    .doc(id)
                                    .update({'isRead': true});
                              },
                              tooltip: "Marcar como leída",
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () {
                              _firestore.collection('notifications').doc(id).delete();
                            },
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
    );
  }

  // ==================== DIALOGOS ====================
  
  void _showProductFormDialog({ProductModel? product}) async {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final imgController = TextEditingController(text: product?.image ?? '');
    
    _tempAttributes = List.from(product?.attributes ?? []);
    
    final categoriesMap = await _getCategoriesWithSubcategories();
    final List<String> mainCategories = categoriesMap.keys.toList();
    
    String selectedMainCategory = product?.category ?? '';
    if (selectedMainCategory.isEmpty || !mainCategories.contains(selectedMainCategory)) {
      selectedMainCategory = mainCategories.isNotEmpty ? mainCategories.first : '';
    }
    
    String selectedSubcategory = product?.subcategory ?? '';
    
    List<Map<String, dynamic>> availableSubcategories = [];
    if (selectedMainCategory.isNotEmpty && categoriesMap.containsKey(selectedMainCategory)) {
      availableSubcategories = categoriesMap[selectedMainCategory] ?? [];
      if (selectedSubcategory.isNotEmpty) {
        final subExists = availableSubcategories.any((sub) => sub['nombre'] == selectedSubcategory);
        if (!subExists) selectedSubcategory = '';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add, color: const Color(0xFFFF9900)),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? "Editar Producto" : "Nuevo Producto",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 600, minWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Nombre del Producto", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Precio (\$ MXN)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imgController,
                        decoration: const InputDecoration(labelText: "URL de Imagen", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      
                      if (mainCategories.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: selectedMainCategory.isNotEmpty ? selectedMainCategory : null,
                          decoration: const InputDecoration(labelText: "Categoría", border: OutlineInputBorder()),
                          items: mainCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedMainCategory = val!;
                              selectedSubcategory = '';
                              availableSubcategories = categoriesMap[selectedMainCategory] ?? [];
                            });
                          },
                        ),
                      
                      const SizedBox(height: 12),
                      
                      if (availableSubcategories.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: selectedSubcategory.isNotEmpty ? selectedSubcategory : null,
                          decoration: const InputDecoration(labelText: "Subcategoría (opcional)", border: OutlineInputBorder()),
                          items: [
                            const DropdownMenuItem(value: '', child: Text("--- Ninguna ---")),
                            ...availableSubcategories.map((sub) => DropdownMenuItem(
                              value: sub['nombre'] as String,
                              child: Text(sub['nombre'] ?? ''),
                            )),
                          ],
                          onChanged: (val) => setDialogState(() => selectedSubcategory = val ?? ''),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.settings, size: 20, color: Color(0xFFFF9900)),
                                  const SizedBox(width: 8),
                                  const Text("Atributos del Producto", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: _addAttribute,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text("Agregar"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9900),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            if (_tempAttributes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text("No hay atributos. Agrega talla, color, etc.", style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            ..._tempAttributes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final attr = entry.value;
                              final extraPriceValue = attr.extraPrice ?? 0;
                              return ListTile(
                                leading: const Icon(Icons.label_outline),
                                title: Text("${attr.name}: ${attr.value}"),
                                subtitle: extraPriceValue > 0 
                                    ? Text("+\$${extraPriceValue.toStringAsFixed(2)}") 
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeAttribute(index),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

                    if (name.isEmpty || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Campos inválidos"), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    if (selectedMainCategory.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Selecciona una categoría"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final newProd = ProductModel(
                      id: isEditing ? product!.id : '',
                      name: name,
                      description: descController.text.trim(),
                      price: price,
                      image: imgController.text.trim().isNotEmpty 
                          ? imgController.text.trim() 
                          : 'https://via.placeholder.com/300',
                      category: selectedMainCategory,
                      subcategory: selectedSubcategory,
                      attributes: List.from(_tempAttributes),
                    );

                    if (isEditing) {
                      await _productService.updateProduct(newProd);
                    } else {
                      await _productService.addProduct(newProd);
                    }

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? "¡Producto actualizado!" : "¡Producto guardado!"), backgroundColor: Colors.green),
                      );
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9900)),
                  child: Text(isEditing ? "Actualizar" : "Guardar", style: const TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCategoriaFormDialog({Map<String, dynamic>? categoria, String? id, String? padreId}) {
    final isEditing = categoria != null;
    final nombreController = TextEditingController(text: categoria?['nombre'] ?? '');
    final imageUrlController = TextEditingController(text: categoria?['imageUrl'] ?? '');
    String? selectedPadreId = padreId ?? categoria?['padreId'];
    if (selectedPadreId != null && selectedPadreId.isEmpty) {
      selectedPadreId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('categorias').get(),
              builder: (context, snapshot) {
                List<QueryDocumentSnapshot> categoriasPadre = [];
                if (snapshot.hasData) {
                  categoriasPadre = snapshot.data!.docs.where((cat) {
                    final catData = cat.data() as Map<String, dynamic>;
                    return (catData['padreId'] == null || catData['padreId'].toString().isEmpty) && cat.id != id;
                  }).toList();
                }
                
                if (selectedPadreId != null) {
                  final exists = categoriasPadre.any((cat) => cat.id == selectedPadreId);
                  if (!exists) {
                    selectedPadreId = null;
                  }
                }
                
                return AlertDialog(
                  title: Row(
                    children: [
                      Icon(isEditing ? Icons.edit : Icons.add, color: const Color(0xFFFF9900)),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? "Editar Categoría" : "Nueva Categoría",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Container(
                    width: 450,
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      minWidth: 300,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nombreController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: "Nombre de la categoría",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: "URL de Imagen (portada)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image),
                              helperText: "Ingresa una URL de imagen para la portada de la categoría",
                            ),
                          ),
                          if (imageUrlController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrlController.text,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (categoriasPadre.isNotEmpty)
                            DropdownButtonFormField<String?>(
                              value: selectedPadreId,
                              decoration: const InputDecoration(
                                labelText: "Categoría Padre (opcional)",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.subdirectory_arrow_right),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text("📁 Ninguna"),
                                ),
                                ...categoriasPadre.map((cat) {
                                  final data = cat.data() as Map<String, dynamic>;
                                  return DropdownMenuItem(
                                    value: cat.id,
                                    child: Text("📂 ${data['nombre'] ?? cat.id}"),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedPadreId = value;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final nombre = nombreController.text.trim();
                        if (nombre.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Por favor ingresa un nombre para la categoría"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        final data = {
                          'nombre': nombre,
                          'imageUrl': imageUrlController.text.trim(),
                          'padreId': selectedPadreId ?? '',
                          'createdAt': FieldValue.serverTimestamp(),
                        };
                        
                        try {
                          if (isEditing && id != null) {
                            await _firestore.collection('categorias').doc(id).update(data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Categoría actualizada"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            await _firestore.collection('categorias').add(data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Categoría creada exitosamente"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          Navigator.pop(ctx);
                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("❌ Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                      ),
                      child: Text(
                        isEditing ? "Actualizar" : "Crear",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showPaymentMethodFormDialog({PaymentMethodModel? method}) {
    final isEditing = method != null;
    final nameController = TextEditingController(text: method?.name ?? '');
    final iconController = TextEditingController(text: method?.icon ?? '💰');
    final descriptionController = TextEditingController(text: method?.description ?? '');
    bool isActive = method?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add, color: const Color(0xFFFF9900)),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? "Editar Método de Pago" : "Nuevo Método de Pago",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  minWidth: 280,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre del método",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: iconController,
                        decoration: const InputDecoration(
                          labelText: "Icono (emoji)",
                          border: OutlineInputBorder(),
                          helperText: "Ej: 💳, 💰, 🏦, 📱",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Descripción",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text("Activo"),
                        value: isActive,
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                        activeColor: const Color(0xFFFF9900),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ingresa un nombre"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final methodData = {
                      'name': nameController.text.trim(),
                      'icon': iconController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'isActive': isActive,
                    };

                    if (isEditing && method != null) {
                      await _firestore.collection('payment_methods').doc(method.id).update(methodData);
                    } else {
                      await _firestore.collection('payment_methods').add(methodData);
                    }

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? "Método actualizado" : "Método creado"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9900),
                  ),
                  child: Text(
                    isEditing ? "Actualizar" : "Crear",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCarrierFormDialog({CarrierModel? carrier}) {
    final isEditing = carrier != null;
    final nameController = TextEditingController(text: carrier?.name ?? '');
    final logoController = TextEditingController(text: carrier?.logo ?? '');
    final baseRateController = TextEditingController(text: carrier?.baseRate.toString() ?? '');
    final ratePerKmController = TextEditingController(text: carrier?.ratePerKm.toString() ?? '');
    final daysController = TextEditingController(text: carrier?.estimatedDays.toString() ?? '');
    bool isActive = carrier?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add, color: const Color(0xFFFF9900)),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? "Editar Transportista" : "Nuevo Transportista",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  minWidth: 280,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre del transportista",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: logoController,
                        decoration: const InputDecoration(
                          labelText: "URL del logo",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: baseRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Tarifa base (\$)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ratePerKmController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Tarifa por km (\$)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: daysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Días estimados de entrega",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text("Activo"),
                        value: isActive,
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                        activeColor: const Color(0xFFFF9900),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ingresa un nombre"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final carrierData = {
                      'name': nameController.text.trim(),
                      'logo': logoController.text.trim(),
                      'baseRate': double.tryParse(baseRateController.text.trim()) ?? 0,
                      'ratePerKm': double.tryParse(ratePerKmController.text.trim()) ?? 0,
                      'estimatedDays': int.tryParse(daysController.text.trim()) ?? 1,
                      'isActive': isActive,
                    };

                    if (isEditing && carrier != null) {
                      await _firestore.collection('carriers').doc(carrier.id).update(carrierData);
                    } else {
                      await _firestore.collection('carriers').add(carrierData);
                    }

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? "Transportista actualizado" : "Transportista creado"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9900),
                  ),
                  child: Text(
                    isEditing ? "Actualizar" : "Crear",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDireccionFormDialog({AddressModel? direccion, String? userId, String? addressDocId}) {
    final isEditing = direccion != null;
    final nameController = TextEditingController(text: direccion?.name ?? '');
    final streetController = TextEditingController(text: direccion?.street ?? '');
    final cityController = TextEditingController(text: direccion?.city ?? '');
    final stateController = TextEditingController(text: direccion?.state ?? '');
    final zipController = TextEditingController(text: direccion?.zip ?? '');
    
    String? selectedUserId = userId;
    List<QueryDocumentSnapshot> clientes = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    title: Text("Cargando..."),
                    content: SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: Text("Error al cargar clientes: ${snapshot.error}"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cerrar"),
                      ),
                    ],
                  );
                }

                clientes = snapshot.data?.docs ?? [];
                
                if (selectedUserId != null && clientes.isNotEmpty) {
                  final exists = clientes.any((c) => c.id == selectedUserId);
                  if (!exists) {
                    selectedUserId = null;
                  }
                }
                
                return AlertDialog(
                  title: Row(
                    children: [
                      Icon(isEditing ? Icons.edit : Icons.add_location, color: const Color(0xFFFF9900)),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? "Editar Dirección" : "Nueva Dirección",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Nombre de la dirección",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: streetController,
                            decoration: const InputDecoration(
                              labelText: "Calle y número",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: "Ciudad",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: stateController,
                            decoration: const InputDecoration(
                              labelText: "Estado",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: zipController,
                            decoration: const InputDecoration(
                              labelText: "Código Postal",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!isEditing && clientes.isNotEmpty)
                            DropdownButtonFormField<String?>(
                              value: selectedUserId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: "Cliente",
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text("-- Selecciona un cliente --"),
                                ),
                                ...clientes.map((cliente) {
                                  final data = cliente.data() as Map<String, dynamic>;
                                  final clienteNombre = data['name'] ?? 'Cliente sin nombre';
                                  return DropdownMenuItem<String?>(
                                    value: cliente.id,
                                    child: Text(
                                      clienteNombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedUserId = value;
                                });
                              },
                            ),
                          if (!isEditing && clientes.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "No hay clientes registrados. Primero crea un cliente.",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            streetController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Complete nombre y calle"), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        
                        if (!isEditing && selectedUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Selecciona un cliente"), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        
                        final addressData = {
                          'name': nameController.text.trim(),
                          'street': streetController.text.trim(),
                          'city': cityController.text.trim(),
                          'state': stateController.text.trim(),
                          'zip': zipController.text.trim(),
                        };
                        
                        if (isEditing && userId != null && addressDocId != null) {
                          await _firestore
                              .collection('users')
                              .doc(userId)
                              .collection('addresses')
                              .doc(addressDocId)
                              .update(addressData);
                        } else if (selectedUserId != null) {
                          await _firestore
                              .collection('users')
                              .doc(selectedUserId)
                              .collection('addresses')
                              .add(addressData);
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isEditing ? "Dirección actualizada" : "Dirección agregada")),
                          );
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                      ),
                      child: Text(
                        isEditing ? "Actualizar" : "Guardar",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ==================== FUNCIONES AUXILIARES ====================
  
  Future<List<Map<String, dynamic>>> _loadAllAddresses(List<QueryDocumentSnapshot> users) async {
    List<Map<String, dynamic>> allAddresses = [];
    
    for (var userDoc in users) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['name'] ?? 'Sin nombre';
      final userEmail = userData['email'] ?? 'Sin email';
      final userId = userDoc.id;
      
      final addressesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();
      
      for (var addressDoc in addressesSnapshot.docs) {
        final addressData = addressDoc.data();
        final address = AddressModel(
          id: addressDoc.id,
          name: addressData['name'] ?? '',
          street: addressData['street'] ?? '',
          city: addressData['city'] ?? '',
          state: addressData['state'] ?? '',
          zip: addressData['zip'] ?? '',
        );
        
        allAddresses.add({
          'address': address,
          'userName': userName,
          'userEmail': userEmail,
          'userId': userId,
          'addressDocId': addressDoc.id,
        });
      }
    }
    
    return allAddresses;
  }

  void _confirmDeleteProduct(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Producto"),
        content: Text("¿Estás seguro de que deseas eliminar permanentemente '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _productService.deleteProduct(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto eliminado exitosamente"), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _confirmDeleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Reseña"),
        content: const Text("¿Estás seguro de que deseas eliminar esta reseña?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
        
        if (reviewDoc.exists) {
          await _firestore.collection('reviews').doc(reviewId).delete();
          print('✅ Reseña eliminada correctamente');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reseña eliminada"), backgroundColor: Colors.orange),
          );
          setState(() {});
        }
      } catch (e) {
        print('❌ Error al eliminar reseña: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al eliminar: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _confirmDeletePaymentMethod(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Método de Pago"),
        content: Text("¿Eliminar '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('payment_methods').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Método de pago eliminado"), backgroundColor: Colors.orange),
        );
        setState(() {});
      }
    }
  }

  void _confirmDeleteCarrier(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Transportista"),
        content: Text("¿Eliminar '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('carriers').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transportista eliminado"), backgroundColor: Colors.orange),
        );
        setState(() {});
      }
    }
  }

  void _confirmDeleteAddress(String userId, String addressDocId, String addressName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Dirección"),
        content: Text("¿Eliminar la dirección '$addressName'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressDocId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dirección eliminada"), backgroundColor: Colors.orange),
        );
        setState(() {});
      }
    }
  }

  void _confirmDeleteCategoria(String id, String nombre) async {
    final productosConCategoria = await _firestore
        .collection('products')
        .where('category', isEqualTo: nombre)
        .limit(1)
        .get();
    
    if (productosConCategoria.docs.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se puede eliminar: Hay productos usando esta categoría"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Categoría"),
        content: Text("¿Estás seguro de que deseas eliminar '$nombre'? Se eliminarán también sus subcategorías."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final subcategorias = await _firestore
          .collection('categorias')
          .where('padreId', isEqualTo: id)
          .get();
      
      for (var sub in subcategorias.docs) {
        await _firestore.collection('categorias').doc(sub.id).delete();
      }
      
      await _firestore.collection('categorias').doc(id).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Categoría eliminada"), backgroundColor: Colors.orange),
        );
        setState(() {});
      }
    }
  }

  void _togglePaymentMethod(String id, bool isActive) async {
    await _firestore.collection('payment_methods').doc(id).update({
      'isActive': isActive,
    });
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleCarrier(String id, bool isActive) async {
    await _firestore.collection('carriers').doc(id).update({
      'isActive': isActive,
    });
    if (mounted) {
      setState(() {});
    }
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });

    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final orderData = orderDoc.data();
      if (orderData != null) {
        final userId = orderData['userId']?.toString();
        if (userId != null && userId.isNotEmpty) {
          await NotificationService().createNotification(
            userId: userId,
            title: "Actualización de tu pedido",
            body: "Tu pedido #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()} cambió a: ${newStatus.toUpperCase()}",
            type: "order_update",
            extraData: {'orderId': orderId, 'status': newStatus},
          );
        }
      }
    } catch (e) {
      print('Error notifying user of order update: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pedido actualizado a: $newStatus"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _updateClienteRol(String uid, String newRole) async {
    await _firestore.collection('users').doc(uid).update({
      'role': newRole,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rol actualizado a: $newRole"), backgroundColor: Colors.green),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  // ==================== WIDGETS UI ====================
  
  Widget _buildStatusDropdown(String orderId, String currentStatus) {
    final validStatuses = ['pendiente', 'procesando', 'enviado', 'entregado', 'cancelado'];
    
    String safeValue = validStatuses.contains(currentStatus) ? currentStatus : validStatuses.first;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF9900), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: safeValue,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF9900)),
        underline: const SizedBox.shrink(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F3A5F),
          fontSize: 12,
        ),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != currentStatus) {
            _updateOrderStatus(orderId, newValue);
          }
        },
        items: validStatuses.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color valueColor = Colors.black87}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1F3A5F)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'purchase_made':
        return Icons.shopping_bag_outlined;
      case 'order_update':
        return Icons.local_shipping_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline;
      case 'new_review':
        return Icons.star_outline;
      case 'admin_announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  void _showSendAnnouncementDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.campaign_outlined, color: Color(0xFFFF9900)),
            SizedBox(width: 8),
            Text(
              "Enviar Anuncio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Título del anuncio",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Mensaje del anuncio",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final body = bodyController.text.trim();
              if (title.isEmpty || body.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Completa el título y el mensaje"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await NotificationService().createNotification(
                userId: 'all',
                title: title,
                body: body,
                type: 'admin_announcement',
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Anuncio enviado a todos los usuarios"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9900),
            ),
            child: const Text(
              "Enviar",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}