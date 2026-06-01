import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartFirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Guardar carrito - Recibe List<CartItem>
  Future<void> saveCart(String uid, List<CartItem> items) async {
    final cartRef = _db.collection("users").doc(uid).collection("cart");

    // Eliminar todos los items actuales
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Guardar cada item
    for (var item in items) {
      final attributeSuffix = item.selectedAttribute != null 
          ? "_${item.selectedAttribute!.name}_${item.selectedAttribute!.value}"
          : "";
      final docId = "${item.product.id}$attributeSuffix";
      
      await cartRef.doc(docId).set({
        "productId": item.product.id,
        "name": item.product.name,
        "price": item.product.price,
        "image": item.product.image,
        "category": item.product.category,
        "subcategory": item.product.subcategory,
        "quantity": item.quantity,
        "selectedAttribute": item.selectedAttribute != null
            ? {
                "name": item.selectedAttribute!.name,
                "value": item.selectedAttribute!.value,
                "extraPrice": item.selectedAttribute!.extraPrice,
              }
            : null,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ Cargar carrito - Devuelve List<CartItem>
  Future<List<CartItem>> loadCart(String uid) async {
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .get();

    final List<CartItem> cartItems = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      
      final product = ProductModel(
        id: data['productId'] ?? '',
        name: data['name'] ?? '',
        description: '',
        price: (data['price'] ?? 0).toDouble(),
        image: data['image'] ?? '',
        category: data['category'] ?? '',
        subcategory: data['subcategory'] ?? '',
        attributes: [],
      );

      ProductAttribute? selectedAttribute;
      if (data['selectedAttribute'] != null) {
        selectedAttribute = ProductAttribute(
          name: data['selectedAttribute']['name'] ?? '',
          value: data['selectedAttribute']['value'] ?? '',
          extraPrice: (data['selectedAttribute']['extraPrice'] ?? 0).toDouble(),
        );
      }

      cartItems.add(CartItem(
        product: product,
        selectedAttribute: selectedAttribute,
        quantity: data['quantity'] ?? 1,
      ));
    }

    return cartItems;
  }

  // ✅ Limpiar carrito
  Future<void> clearCart(String uid) async {
    final cartRef = _db.collection("users").doc(uid).collection("cart");
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}