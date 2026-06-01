import 'package:cloud_firestore/cloud_firestore.dart';
import 'direccion_model.dart';

class PedidoCompletoModel {
  final String idPedido;
  final String idCliente;
  final double total;
  final String estado;
  final DateTime createdAt;
  final List<ItemPedidoModel> items;
  final DireccionModel? direccion;
  final PagoModel? pago;
  final EnvioModel? envio;

  PedidoCompletoModel({
    required this.idPedido,
    required this.idCliente,
    required this.total,
    required this.estado,
    required this.createdAt,
    required this.items,
    this.direccion,
    this.pago,
    this.envio,
  });
}

class ItemPedidoModel {
  final String idItem;
  final String idPedido;
  final String idProducto;
  final int cantidad;
  final double precioUnitario;
  final String? productName;

  ItemPedidoModel({
    required this.idItem,
    required this.idPedido,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.productName,
  });

  Map<String, dynamic> toMap() {
    return {
      'idPedido': idPedido,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
    };
  }
}

class PagoModel {
  final String idPago;
  final String idPedido;
  final String metodo;
  final String estado;
  final DateTime? fechaPago;

  PagoModel({
    required this.idPago,
    required this.idPedido,
    required this.metodo,
    required this.estado,
    this.fechaPago,
  });
}

class EnvioModel {
  final String idEnvio;
  final String idPedido;
  final String transportista;
  final String estado;
  final String guia;

  EnvioModel({
    required this.idEnvio,
    required this.idPedido,
    required this.transportista,
    required this.estado,
    required this.guia,
  });
}