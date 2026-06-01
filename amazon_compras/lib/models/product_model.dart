class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final String subcategory;
  final List<ProductAttribute> attributes;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.subcategory,
    this.attributes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'subcategory': subcategory,
      'attributes': attributes.map((a) => a.toMap()).toList(),
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    List<ProductAttribute> attributes = [];
    if (map['attributes'] != null) {
      attributes = (map['attributes'] as List)
          .map((a) => ProductAttribute.fromMap(a as Map<String, dynamic>))
          .toList();
    }
    
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      attributes: attributes,
    );
  }
}

class ProductAttribute {
  final String name;
  final String value;
  final double extraPrice;

  ProductAttribute({
    required this.name,
    required this.value,
    this.extraPrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'extraPrice': extraPrice,
    };
  }

  factory ProductAttribute.fromMap(Map<String, dynamic> map) {
    return ProductAttribute(
      name: map['name'] ?? '',
      value: map['value'] ?? '',
      extraPrice: (map['extraPrice'] ?? 0).toDouble(),
    );
  }
  
  double get safeExtraPrice => extraPrice;
}