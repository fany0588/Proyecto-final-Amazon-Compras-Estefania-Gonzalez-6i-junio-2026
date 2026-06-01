import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final ProductAttribute? selectedAttribute;
  int quantity;

  CartItem({
    required this.product,
    this.selectedAttribute,
    this.quantity = 1,
  });

  double get subtotal {
    final basePrice = product.price;
    final extraPrice = selectedAttribute?.extraPrice ?? 0;
    return (basePrice + extraPrice) * quantity;
  }
  
  double get unitPrice => product.price + (selectedAttribute?.extraPrice ?? 0);
  
  String get attributeDisplay {
    if (selectedAttribute == null) return '';
    final extra = selectedAttribute!.extraPrice > 0 
        ? ' (+\$${selectedAttribute!.extraPrice.toStringAsFixed(2)})' 
        : '';
    return '${selectedAttribute!.name}: ${selectedAttribute!.value}$extra';
  }
}