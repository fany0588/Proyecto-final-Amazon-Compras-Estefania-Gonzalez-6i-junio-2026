class DireccionModel {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String clienteId;

  DireccionModel({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.clienteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'clienteId': clienteId,
    };
  }

  factory DireccionModel.fromMap(Map<String, dynamic> map, String id) {
    return DireccionModel(
      id: id,
      name: map['name'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zip: map['zip'] ?? '',
      clienteId: map['clienteId'] ?? '',
    );
  }
}