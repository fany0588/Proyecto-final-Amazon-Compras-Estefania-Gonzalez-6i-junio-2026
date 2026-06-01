import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final List<AddressModel> _addresses = [];
  AddressModel? _selected;

  List<AddressModel> get addresses => _addresses;
  AddressModel? get selected => _selected;

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .get();

    _addresses.clear();

    for (var doc in snapshot.docs) {
      _addresses.add(AddressModel.fromMap(doc.data()));
    }

    notifyListeners();
  }

  Future<void> addAddress(AddressModel address) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .doc(address.id)
        .set(address.toMap());

    _addresses.add(address);
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _selected = address;
    notifyListeners();
  }
}