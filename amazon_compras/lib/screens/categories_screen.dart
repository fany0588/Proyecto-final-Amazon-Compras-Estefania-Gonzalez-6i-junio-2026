import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/categoria_service.dart';
import 'category_products_screen.dart';
import 'search_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;

  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _ropaExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToCategory(widget.initialCategory!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToCategory(String categoryName, {String subcategory = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          category: categoryName,
          subcategory: subcategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Categorías Amazon"),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 8),
            const Text(
              "Explora por Departamento",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3A5F),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Encuentra lo que necesitas en nuestras categorías",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildCategoriesFromFirestore(),
            _buildRopaPanel(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchProductsScreen(initialQuery: query.trim()),
              ),
            );
          }
        },
        decoration: InputDecoration(
          hintText: "Buscar productos...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1F3A5F)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCategoriesFromFirestore() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categorias')
          .where('padreId', isEqualTo: '')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
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

        final categorias = snapshot.data?.docs ?? [];

        if (categorias.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No hay categorías disponibles",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "El administrador agregará categorías pronto",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categorias.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Más espacio para la imagen
          ),
          itemBuilder: (context, index) {
            final cat = categorias[index];
            final data = cat.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? 'Sin nombre';
            String imageUrl = data['imageUrl']?.toString() ?? '';
            final isRopa = nombre == "Ropa";

            return _buildCategoryCard(
              nombre: nombre,
              imageUrl: imageUrl,
              isRopa: isRopa,
              onTap: () {
                if (isRopa) {
                  setState(() => _ropaExpanded = true);
                  _scrollToBottom();
                } else {
                  _navigateToCategory(nombre);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String nombre,
    required String imageUrl,
    required bool isRopa,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ IMAGEN GRANDE Y PROFESIONAL
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF1F3A5F).withOpacity(0.05),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1F3A5F),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF1F3A5F).withOpacity(0.05),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Sin imagen",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF1F3A5F).withOpacity(0.05),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sin imagen",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              
              // ✅ NOMBRE DE CATEGORÍA
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nombre,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isRopa && _ropaExpanded
                              ? const Color(0xFFFF9900)
                              : const Color(0xFF1F3A5F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9900).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Ver productos",
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFFFF9900),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: const Color(0xFFFF9900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  Widget _buildRopaPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: _ropaExpanded
          ? Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFF9900), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9900).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.checkroom_outlined,
                                color: Color(0xFFFF9900),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ropa y Accesorios",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF1F3A5F),
                                  ),
                                ),
                                Text(
                                  "Explora nuestras colecciones",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _ropaExpanded = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('categorias')
                          .where('nombre', isEqualTo: 'Ropa')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final ropaDoc = snapshot.data?.docs.first;
                        if (ropaDoc == null) {
                          return const Text("No hay subcategorías disponibles");
                        }
                        
                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('categorias')
                              .where('padreId', isEqualTo: ropaDoc.id)
                              .get(),
                          builder: (context, subSnapshot) {
                            if (!subSnapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final subs = subSnapshot.data?.docs ?? [];
                            
                            if (subs.isEmpty) {
                              return const Text("No hay subcategorías disponibles");
                            }
                            
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: subs.map((sub) {
                                final subData = sub.data() as Map<String, dynamic>;
                                final subNombre = subData['nombre'] ?? 'Sin nombre';
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: () => _navigateToCategory("Ropa",
                                        subcategory: subNombre),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF1F3A5F),
                                            Color(0xFF2C4E7E),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        subNombre,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}