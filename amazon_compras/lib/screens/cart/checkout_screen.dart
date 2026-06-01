import 'package:flutter/material.dart';
import 'address_selection_screen.dart';

/// CheckoutScreen redirige al nuevo flujo de 3 pasos.
/// Mantenido por compatibilidad con la ruta /checkout de main.dart.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente al Paso 1: Selección de Dirección
    return const AddressSelectionScreen();
  }
}