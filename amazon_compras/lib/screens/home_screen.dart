import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/notification_service.dart';
import '../widgets/premium_bottom_nav_bar.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'search_products_screen.dart';
import 'notifications_screen.dart';

// ======================== CONSTANTES ========================
class AppColors {
  static const Color primary = Color(0xFF1F3A5F);
  static const Color secondary = Color(0xFFFF9900);
  static const Color background = Color(0xFFF5F1E8);
  static const Color bannerBackground = Color(0xFFE6D3B3);
}

class AppDurations {
  static const carouselInterval = Duration(seconds: 4);
  static const carouselAnimation = Duration(milliseconds: 650);
  static const snackBarDuration = Duration(seconds: 1);
}

class AppSizes {
  static const double bannerHeight = 180;
  static const double quickCategoryHeight = 90;
  static const double quickCategoryRadius = 26;
  static const double searchBarHeight = 42;
  static const double productGridAspectRatio = 0.65;
}

// ======================== HOME SCREEN PRINCIPAL ========================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pages = const [
      HomeContent(),
      CategoriesScreen(),
      ProfileScreen(),
      CartScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexFromArguments();
  }

  void _updateIndexFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < _pages.length) {
      _currentIndex = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ======================== CONTENIDO DE INICIO ========================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final ProductService _productService;
  late final PageController _carouselController;
  late final TextEditingController _searchController;
  late Timer _carouselTimer;
  late ScrollController _scrollController;
  int _activeBannerIndex = 0;

  final List<String> _banners = const [
    "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800",
    "https://images.unsplash.com/photo-1607082349566-187342175e2f?w=800",
    "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800",
  ];

  final List<QuickCategory> _quickCategories = [
    QuickCategory(name: "Deportes", icon: Icons.sports_soccer, color: const Color(0xFFE6D3B3), category: "Deportes"),
    QuickCategory(name: "Regalos", icon: Icons.card_giftcard, color: Colors.red.shade100, category: "Regalos"),
    QuickCategory(name: "Ofertas", icon: Icons.local_offer, color: Colors.orange.shade100, category: "Ofertas"),
    QuickCategory(name: "Mascotas", icon: Icons.pets, color: Colors.brown.shade100, category: "Mascotas"),
    QuickCategory(name: "Ropa", icon: Icons.checkroom, color: Colors.blueGrey.shade100, category: "Ropa"),
    QuickCategory(name: "Electrónica", icon: Icons.electrical_services, color: AppColors.primary.withOpacity(0.2), category: "Electrónica"),
    QuickCategory(name: "Hogar", icon: Icons.home, color: Colors.blue.shade100, category: "Hogar y diy"),
    QuickCategory(name: "Juguetes", icon: Icons.toys, color: Colors.pink.shade100, category: "Juguetes y bebes"),
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startCarouselTimer();
    _loadInitialData();
    _scrollController = ScrollController();
  }

  void _initializeServices() {
    _productService = ProductService();
    _carouselController = PageController();
    _searchController = TextEditingController();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(AppDurations.carouselInterval, (timer) {
      if (_carouselController.hasClients) {
        final nextPage = (_activeBannerIndex + 1) % _banners.length;
        _carouselController.animateToPage(
          nextPage,
          duration: AppDurations.carouselAnimation,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _loadInitialData() {
    Future.microtask(() => context.read<AddressProvider>().loadAddresses());
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _carouselController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildAddressBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<AddressProvider>().loadAddresses(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCarousel(),
                      const _SectionTitle(title: "Explora por Categoría"),
                      _buildQuickCategoriesRow(),
                      const _SectionTitle(title: "Productos Recomendados para ti"),
                      _buildFeaturedProductsGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔍 Barra de Búsqueda
  Widget _buildSearchBar() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      color: AppColors.primary,
      child: Row(
        children: [
          Expanded(child: _buildSearchTextField()),
          const SizedBox(width: 8),
          const Icon(Icons.mic, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          if (user != null)
            StreamBuilder<QuerySnapshot>(
              stream: NotificationService().getNotificationsStream(user.uid, false),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final unreadCount = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final targetUser = data['userId']?.toString();
                  final isRead = data['isRead'] ?? false;
                  return (targetUser == user.uid || targetUser == 'all') && !isRead;
                }).length;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications, color: Colors.white, size: 26),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF9900),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTextField() {
    return Container(
      height: AppSizes.searchBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (query) => _navigateToSearch(query.trim()),
        decoration: InputDecoration(
          hintText: "Buscar productos en Amazon...",
          prefixIcon: InkWell(
            onTap: () => _navigateToSearch(_searchController.text.trim()),
            child: const Icon(Icons.search, color: AppColors.primary),
          ),
          suffixIcon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  void _navigateToSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchProductsScreen(initialQuery: query),
        ),
      ).then((_) => _searchController.clear());
    }
  }

  // 📍 Barra de Dirección
  Widget _buildAddressBar() {
    final address = context.watch<AddressProvider>().selected;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      color: AppColors.bannerBackground.withOpacity(0.6),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              address != null
                  ? "Enviar a ${address.name} - ${address.street}, ${address.city}"
                  : "Selecciona una dirección de envío en tu Perfil",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  // 🖼️ Carrusel de Banners
  Widget _buildCarousel() {
    return OptimizedCarousel(
      banners: _banners,
      controller: _carouselController,
    );
  }

  // 🏷️ Categorías Rápidas
  Widget _buildQuickCategoriesRow() {
    return Center(
      child: SizedBox(
        height: AppSizes.quickCategoryHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _quickCategories.length,
          itemBuilder: (context, index) => _QuickCategoryItem(
            category: _quickCategories[index],
            onTap: () => _navigateToCategory(_quickCategories[index].category),
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesScreen(initialCategory: category),
      ),
    );
  }

  // 🛍️ Grid de Productos
  Widget _buildFeaturedProductsGrid() {
    return StreamBuilder<List<ProductModel>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const _EmptyProductsMessage();
        }

        final displayedProducts = products.take(12).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: AppSizes.productGridAspectRatio,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: displayedProducts.length,
          itemBuilder: (context, index) => _ProductCard(
            product: displayedProducts[index],
            onTap: () => _navigateToProductDetail(displayedProducts[index]),
            onAddToCart: () => _addToCart(displayedProducts[index]),
          ),
        );
      },
    );
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _addToCart(ProductModel product) {
    context.read<CartProvider>().addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} agregado!"),
        duration: AppDurations.snackBarDuration,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ======================== COMPONENTES REUTILIZABLES ========================

class QuickCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String category;

  const QuickCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class _QuickCategoryItem extends StatelessWidget {
  final QuickCategory category;
  final VoidCallback onTap;

  const _QuickCategoryItem({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: AppSizes.quickCategoryRadius,
              backgroundColor: category.color,
              child: Icon(category.icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.image),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onAddToCart,
                      child: const Text(
                        "Agregar",
                        style: TextStyle(
                          fontSize: 11,
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
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _EmptyProductsMessage extends StatelessWidget {
  const _EmptyProductsMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Text(
        "Sin productos para mostrar.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

// ======================== CARRUSEL OPTIMIZADO ========================
class OptimizedCarousel extends StatefulWidget {
  final List<String> banners;
  final PageController controller;

  const OptimizedCarousel({
    super.key,
    required this.banners,
    required this.controller,
  });

  @override
  State<OptimizedCarousel> createState() => _OptimizedCarouselState();
}

class _OptimizedCarouselState extends State<OptimizedCarousel> 
    with AutomaticKeepAliveClientMixin {
  int _activeBannerIndex = 0;
  late Timer _carouselTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(AppDurations.carouselInterval, (timer) {
      if (widget.controller.hasClients && mounted) {
        final nextPage = (_activeBannerIndex + 1) % widget.banners.length;
        widget.controller.animateToPage(
          nextPage,
          duration: AppDurations.carouselAnimation,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SizedBox(
      height: AppSizes.bannerHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: widget.controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _activeBannerIndex = index;
              });
            },
            itemBuilder: (context, index) => Image.network(
              widget.banners[index],
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 12,
            child: _buildCarouselIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      children: List.generate(
        widget.banners.length,
        (index) => AnimatedContainer(
          duration: AppDurations.carouselAnimation,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _activeBannerIndex == index ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _activeBannerIndex == index 
                ? AppColors.secondary 
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}