import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

/// Barra de navegación inferior reutilizable para toda la app.
/// [currentIndex]: índice de la pestaña activa (0=Inicio, 1=Categorías, 2=Perfil, 3=Carrito).
/// [onTap]: función opcional para manejar el toque en las pestañas.
class PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  /// Navega de forma segura a la pantalla de inicio seleccionando la pestaña correcta.
  static void navigateToTab(BuildContext context, int tabIndex) {
    // Limpiar todo el stack hasta /home y pasar el índice como argumento
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartCount = cartProvider.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF9900),
        unselectedItemColor: const Color(0xFF1F3A5F).withOpacity(0.55),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (onTap != null) {
            onTap!(index);
          } else {
            // Desde pantallas secundarias: ir a HomeScreen y seleccionar pestaña
            navigateToTab(context, index);
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: Color(0xFFFF9900)),
            label: "Inicio",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view, color: Color(0xFFFF9900)),
            label: "Categorías",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Color(0xFFFF9900)),
            label: "Perfil",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart, color: Color(0xFFFF9900)),
                if (cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Carrito",
          ),
        ],
      ),
    );
  }
}
