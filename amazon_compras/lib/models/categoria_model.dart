class CategoriaModel {
  final String idCategoria;
  final String nombre;
  final String? padreId;

  CategoriaModel({
    required this.idCategoria,
    required this.nombre,
    this.padreId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'padreId': padreId,
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoriaModel(
      idCategoria: id,
      nombre: map['nombre'] ?? '',
      padreId: map['padreId'],
    );
  }
}