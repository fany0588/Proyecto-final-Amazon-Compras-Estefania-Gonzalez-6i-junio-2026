import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';
import '../models/cart_item.dart';  // ✅ Cambiado a cart_item.dart (nuevo modelo)
import '../services/cart_firebase_service.dart';
import '../services/order_firebase_service.dart';
import '../services/notification_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  final CartFirebaseService _firebase = CartFirebaseService();
  final OrderFirebaseService _orderService = OrderFirebaseService();
  final NotificationService _notifService = NotificationService();

  List<CartItem> get items => _items;

  // ✅ NUEVO: Agregar CartItem completo (con atributo)
  void addCartItem(CartItem item) {
    final index = _items.indexWhere(
      (i) => i.product.id == item.product.id && 
             i.selectedAttribute?.value == item.selectedAttribute?.value &&
             i.selectedAttribute?.name == item.selectedAttribute?.name,
    );

    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }

    notifyListeners();
    syncToFirebase();
  }

  // ✅ Agregar producto (versión legacy, sin atributo)
  void addProduct(ProductModel product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedAttribute == null,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedAttribute: null));
    }

    notifyListeners();
    syncToFirebase();
  }

  // ✅ Agregar producto con atributo específico
  void addProductWithAttribute(ProductModel product, ProductAttribute attribute) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && 
                item.selectedAttribute?.value == attribute.value &&
                item.selectedAttribute?.name == attribute.name,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedAttribute: attribute));
    }

    notifyListeners();
    syncToFirebase();
  }

  // ➖ disminuir cantidad
  void decrease(ProductModel product) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedAttribute == null,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
    syncToFirebase();
  }

  // ➖ disminuir cantidad con atributo
  void decreaseQuantity(CartItem item) {
    final index = _items.indexWhere(
      (i) => i.product.id == item.product.id && 
             i.selectedAttribute?.value == item.selectedAttribute?.value &&
             i.selectedAttribute?.name == item.selectedAttribute?.name,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
    syncToFirebase();
  }

  // ➕ aumentar cantidad
  void increaseQuantity(CartItem item) {
    final index = _items.indexWhere(
      (i) => i.product.id == item.product.id && 
             i.selectedAttribute?.value == item.selectedAttribute?.value &&
             i.selectedAttribute?.name == item.selectedAttribute?.name,
    );

    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
      syncToFirebase();
    }
  }

  // 🗑 eliminar producto
  void removeProduct(ProductModel product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
    syncToFirebase();
  }

  // 🗑 eliminar CartItem completo
  void removeCartItem(CartItem item) {
    _items.removeWhere(
      (i) => i.product.id == item.product.id && 
             i.selectedAttribute?.value == item.selectedAttribute?.value &&
             i.selectedAttribute?.name == item.selectedAttribute?.name,
    );
    notifyListeners();
    syncToFirebase();
  }

  // 🧹 limpiar carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
    syncToFirebase();
  }

  // 💰 total
  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  // 📊 número de items
  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // ☁️ guardar carrito en Firebase
  // ☁️ guardar carrito en Firebase
Future<void> syncToFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // ✅ Enviar directamente los CartItems, no los maps
  await _firebase.saveCart(user.uid, _items);
}

  // 📥 cargar carrito desde Firebase
  // 📥 cargar carrito desde Firebase
Future<void> loadFromFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final items = await _firebase.loadCart(user.uid); // ✅ Esto ya devuelve List<CartItem>

  _items.clear();
  _items.addAll(items);
  notifyListeners();
}

  // 💳 CHECKOUT CON DIRECCIÓN Y MÉTODO DE PAGO
  Future<String?> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
    Map<String, dynamic>? cardDetails,
  }) async {
    print("🔥 CHECKOUT INICIADO");
    print("📍 Dirección: $address");
    print("💳 Método de pago: $paymentMethod");
    
    if (cardDetails != null) {
      print("💳 Datos de tarjeta recibidos:");
      print("   - Tipo: ${cardDetails['cardType']}");
      print("   - Número: ${cardDetails['cardNumber']?.substring(0, 4)}****${cardDetails['cardNumber']?.substring(cardDetails['cardNumber']!.length - 4)}");
      print("   - CVV: ***");
      print("   - Expiración: ${cardDetails['expiry']}");
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ USUARIO NO LOGUEADO");
      return null;
    }

    if (_items.isEmpty) {
      print("❌ CARRITO VACÍO");
      return null;
    }

    print("📦 Guardando orden...");
    print("📦 Total: \$${total.toStringAsFixed(2)}");
    print("📦 Items: ${_items.length}");

    final orderId = await _orderService.saveOrder(
      uid: user.uid,
      items: _items,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
    );

    print("✅ ORDEN GUARDADA EN FIREBASE CON ID: $orderId");

    // 🔔 Notificar al usuario que su compra fue realizada
    if (orderId != null) {
      await _notifService.createNotification(
        userId: user.uid,
        title: "¡Compra realizada con éxito!",
        body: "Tu pedido #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()} ha sido registrado. Total: \$${total.toStringAsFixed(2)}",
        type: "purchase_made",
        extraData: {'orderId': orderId, 'total': total},
      );

      // 🔔 Notificar al administrador de nueva compra
      await _notifService.createNotification(
        userId: "admin",
        title: "Nueva compra recibida",
        body: "Se recibió un nuevo pedido por \$${total.toStringAsFixed(2)} con ${_items.length} producto(s).",
        type: "purchase_made",
        extraData: {'orderId': orderId, 'total': total, 'userId': user.uid},
      );
    }

    // Limpiar carrito en la nube
    await _firebase.clearCart(user.uid);

    _items.clear();
    notifyListeners();

    return orderId;
  }
}