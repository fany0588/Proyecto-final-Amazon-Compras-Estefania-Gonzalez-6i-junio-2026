import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class OrderFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> saveOrder({
    required String uid,
    required List<CartItem> items,
    required double total,
    required Map<String, dynamic> address,
    required String paymentMethod,
    Map<String, dynamic>? cardDetails,
  }) async {
    try {
      final docRef = _firestore.collection('orders').doc();
      final orderId = docRef.id;

      // Convertir items a Map con atributos
      final itemsData = items.map((item) {
        return {
          'productId': item.product.id,
          'name': item.product.name,
          'originalPrice': item.product.price,
          'unitPrice': item.unitPrice, // Precio con atributo
          'quantity': item.quantity,
          'image': item.product.image,
          'category': item.product.category,
          'subcategory': item.product.subcategory,
          'selectedAttribute': item.selectedAttribute != null
              ? {
                  'name': item.selectedAttribute!.name,
                  'value': item.selectedAttribute!.value,
                  'extraPrice': item.selectedAttribute!.extraPrice,
                }
              : null,
          'subtotal': item.subtotal,
        };
      }).toList();

      final orderData = {
        'orderId': orderId,
        'userId': uid,
        'items': itemsData,
        'total': total,
        'address': address,
        'paymentMethod': paymentMethod,
        'status': 'pendiente',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Agregar datos de tarjeta si existen (sin guardar CVV por seguridad)
      if (cardDetails != null) {
        orderData['cardInfo'] = {
          'cardType': cardDetails['cardType'],
          'lastFourDigits': cardDetails['cardNumber']?.substring(
            cardDetails['cardNumber']!.length - 4
          ),
          'expiry': cardDetails['expiry'],
        };
      }

      await docRef.set(orderData);

      print("✅ Orden guardada con ID: $orderId");
      print("📦 Items: ${items.length}");
      print("💰 Total: \$${total.toStringAsFixed(2)}");

      return orderId;
    } catch (e) {
      print("❌ Error guardando orden: $e");
      return null;
    }
  }

  // 📋 Obtener órdenes de un usuario
  Future<List<QueryDocumentSnapshot>> getUserOrders(String uid) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs;
  }

  // 📋 Obtener todas las órdenes (para admin)
  Future<List<QueryDocumentSnapshot>> getAllOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs;
  }

  // 🔄 Actualizar estado de orden
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("❌ Error actualizando estado: $e");
      return false;
    }
  }

  // 📊 Obtener detalle de una orden específica
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("❌ Error obteniendo orden: $e");
      return null;
    }
  }
}