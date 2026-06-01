import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';
import '../models/direccion_model.dart';
import '../models/categoria_model.dart';
import '../models/pedido_completo_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CLIENTES ====================
  Stream<List<ClienteModel>> getClientes() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClienteModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateClienteRol(String uid, String newRole) async {
    await _firestore.collection('users').doc(uid).update({
      'role': newRole,
    });
  }

  // ==================== DIRECCIONES ====================
  Stream<List<DireccionModel>> getDireccionesByCliente(String clienteId) {
    return _firestore
        .collection('direcciones')
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DireccionModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<DireccionModel>> getAllDirecciones() {
    return _firestore.collection('direcciones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DireccionModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ==================== CATEGORÍAS ====================
  Stream<List<CategoriaModel>> getCategorias() {
    return _firestore.collection('categorias').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoriaModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addCategoria(String nombre, {String? padreId}) async {
    await _firestore.collection('categorias').add({
      'nombre': nombre,
      'padreId': padreId,
    });
  }

  Future<void> updateCategoria(String id, String nombre) async {
    await _firestore.collection('categorias').doc(id).update({
      'nombre': nombre,
    });
  }

  Future<void> deleteCategoria(String id) async {
    // Primero eliminar subcategorías
    final subcategorias = await _firestore
        .collection('categorias')
        .where('padreId', isEqualTo: id)
        .get();
    
    for (var sub in subcategorias.docs) {
      await sub.reference.delete();
    }
    
    // Luego eliminar la categoría padre
    await _firestore.collection('categorias').doc(id).delete();
  }

  // ==================== ESTADÍSTICAS ====================
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final clientesQuery = await _firestore.collection('users').get();
      final productosQuery = await _firestore.collection('products').get();
      final pedidosQuery = await _firestore.collection('orders').get();
      
      double ventasTotales = 0;
      for (var doc in pedidosQuery.docs) {
        ventasTotales += (doc.data()['total'] ?? 0.0).toDouble();
      }
      
      return {
        'clientes': clientesQuery.size,
        'productos': productosQuery.size,
        'pedidos': pedidosQuery.size,
        'ventasTotales': ventasTotales,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {
        'clientes': 0,
        'productos': 0,
        'pedidos': 0,
        'ventasTotales': 0.0,
      };
    }
  }
  
  // ==================== MÉTODOS AUXILIARES ====================
  Future<Map<String, dynamic>> getClienteInfo(String clienteId) async {
    final doc = await _firestore.collection('users').doc(clienteId).get();
    if (doc.exists) {
      return doc.data() ?? {};
    }
    return {};
  }
}