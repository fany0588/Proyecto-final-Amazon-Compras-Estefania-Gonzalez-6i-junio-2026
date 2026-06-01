import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

class SearchProductsScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchProductsScreen({super.key, this.initialQuery});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final ProductService _productService = ProductService();
  late final TextEditingController _searchController;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Quitar acentos y caracteres especiales para búsqueda tolerante
  String _normalizeString(String input) {
    var withOutDiacritics = input.toLowerCase();
    withOutDiacritics = withOutDiacritics.replaceAll(RegExp(r'[áàäâ]'), 'a');
    withOutDiacritics = withOutDiacritics.replaceAll(RegExp(r'[éèëê]'), 'e');
    withOutDiacritics = withOutDiacritics.replaceAll(RegExp(r'[íìïî]'), 'i');
    withOutDiacritics = withOutDiacritics.replaceAll(RegExp(r'[óòöô]'), 'o');
    withOutDiacritics = withOutDiacritics.replaceAll(RegExp(r'[úùüû]'), 'u');
    return withOutDiacritics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3A5F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              setState(() {
                _currentQuery = val.trim();
              });
            },
            onChanged: (val) {
              // Filtrado dinámico en tiempo real opcional
              setState(() {
                _currentQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Buscar en Amazon...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1F3A5F), size: 20),
              suffixIcon: _currentQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _currentQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al buscar productos: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final products = snapshot.data ?? [];
          final normalizedQuery = _normalizeString(_currentQuery);

          // Filtrar en memoria por nombre, descripción o categoría
          final filteredProducts = products.where((p) {
            if (normalizedQuery.isEmpty) return true;
            final name = _normalizeString(p.name);
            final desc = _normalizeString(p.description);
            final cat = _normalizeString(p.category);
            final sub = _normalizeString(p.subcategory);
            return name.contains(normalizedQuery) ||
                desc.contains(normalizedQuery) ||
                cat.contains(normalizedQuery) ||
                sub.contains(normalizedQuery);
          }).toList();

          if (filteredProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "No encontramos productos que coincidan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3A5F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Intenta buscar usando otras palabras clave.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (_currentQuery.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _currentQuery = '';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Limpiar búsqueda", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _currentQuery.isEmpty
                      ? "Mostrando todos los productos (${filteredProducts.length})"
                      : "Resultados para \"$_currentQuery\" (${filteredProducts.length})",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3A5F),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final p = filteredProducts[index];

                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Imagen (Clickable)
                          Expanded(
                            flex: 6,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: p),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  p.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Información
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1F3A5F),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "\$${p.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFFFF9900),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Botón Agregar
                                  SizedBox(
                                    width: double.infinity,
                                    height: 32,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9900),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        context.read<CartProvider>().addProduct(p);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("${p.name} agregado al carrito!"),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: const Color(0xFF1F3A5F),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Agregar",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
