class AddressModel {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;

  AddressModel({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zip: map['zip'] ?? '',
    );
  }

  factory AddressModel.fromMapWithId(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      name: map['name'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zip: map['zip'] ?? '',
    );
  }
}