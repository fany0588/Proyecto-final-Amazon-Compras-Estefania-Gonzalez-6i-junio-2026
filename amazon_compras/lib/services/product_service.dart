import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// OBTENER TODOS LOS PRODUCTOS
  Stream<List<ProductModel>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// OBTENER PRODUCTOS POR CATEGORÍA Y OPCIONALMENTE SUBCATEGORÍA
  Stream<List<ProductModel>> getProductsByCategory(String category, {String? subcategory}) {
    Query query = _db.collection('products').where('category', isEqualTo: category);
    
    if (subcategory != null && subcategory.isNotEmpty) {
      query = query.where('subcategory', isEqualTo: subcategory);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// AGREGAR PRODUCTO (ADMIN)
  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add(product.toMap());
  }

  /// ACTUALIZAR PRODUCTO (ADMIN)
  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  /// ELIMINAR PRODUCTO (ADMIN)
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}