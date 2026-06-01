import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Obtener todas las categorías
  Stream<List<Map<String, dynamic>>> getCategorias() {
    return _firestore.collection('categorias').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'] ?? '',
          'padreId': data['padreId'],
        };
      }).toList();
    });
  }
  
  // Obtener solo categorías padre (sin padreId)
  Stream<List<Map<String, dynamic>>> getCategoriasPadre() {
    return _firestore
        .collection('categorias')
        .where('padreId', isEqualTo: null)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'] ?? '',
        };
      }).toList();
    });
  }
  
  // Obtener subcategorías de una categoría padre
  Future<List<Map<String, dynamic>>> getSubcategorias(String padreId) async {
    final snapshot = await _firestore
        .collection('categorias')
        .where('padreId', isEqualTo: padreId)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nombre': data['nombre'] ?? '',
      };
    }).toList();
  }
  
  // Agregar categoría
  Future<void> addCategoria(String nombre, {String? padreId}) async {
    await _firestore.collection('categorias').add({
      'nombre': nombre,
      'padreId': padreId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}