import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'cart/address_selection_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Carrito de Compras"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tu carrito está vacío",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "¡Explora nuestro catálogo y agrega productos!",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Comprar Ahora",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Dismissible(
                        key: Key(item.product.id + (item.selectedAttribute?.value ?? '')),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text("Eliminar producto", style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text("¿Seguro que quieres quitar ${item.product.name} de tu carrito?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Eliminar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          context.read<CartProvider>().removeCartItem(item);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                        ),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.image,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey.shade100,
                                      width: 75,
                                      height: 75,
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1F3A5F),
                                        ),
                                      ),
                                      // ✅ Mostrar atributo seleccionado
                                      if (item.selectedAttribute != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            item.attributeDisplay,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "\$${item.unitPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Color(0xFFFF9900),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _button(
                                            icon: Icons.remove,
                                            onTap: () {
                                              context.read<CartProvider>().decreaseQuantity(item);
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: Text(
                                              "${item.quantity}",
                                              key: ValueKey(item.quantity),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          _button(
                                            icon: Icons.add,
                                            onTap: () {
                                              context.read<CartProvider>().increaseQuantity(item);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "\$${item.subtotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom check-out bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3)),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Monto total:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              "\$${cart.total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9900),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddressSelectionScreen()),
                            );
                          },
                          child: const Text(
                            "Proceder al Pago",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
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

  Widget _button({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1F3A5F)),
      ),
    );
  }
}