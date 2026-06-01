import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import 'order_placed_screen.dart';

class ConfirmPurchaseScreen extends StatefulWidget {
  final String paymentMethod;

  const ConfirmPurchaseScreen({super.key, required this.paymentMethod});

  @override
  State<ConfirmPurchaseScreen> createState() => _ConfirmPurchaseScreenState();
}

class _ConfirmPurchaseScreenState extends State<ConfirmPurchaseScreen> {
  bool _submitting = false;

  // Controladores para campos de tarjeta
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  // Validación de campos
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Formateadores
  String _formatCardNumber(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 16) cleaned = cleaned.substring(0, 16);
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 4) cleaned = cleaned.substring(0, 4);
    if (cleaned.length >= 3) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }

  // ✅ Validación de fecha de expiración (NO acepta fechas vencidas)
  bool _isValidExpiry(String expiry) {
    if (expiry.length != 5 || expiry[2] != '/') return false;
    
    final parts = expiry.split('/');
    if (parts.length != 2) return false;
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    // Obtener fecha actual
    final now = DateTime.now();
    final currentYear = now.year % 100; // Últimos 2 dígitos del año
    final currentMonth = now.month;
    
    // Validar que no esté vencida
    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;
    
    return true;
  }

  double _calculateTax(double subtotal) => subtotal * 0.16;
  double _calculateDiscount(double subtotal) => subtotal > 500 ? subtotal * 0.10 : 0.0;
  double _calculateTotal(double subtotal) {
    final tax = _calculateTax(subtotal);
    final disc = _calculateDiscount(subtotal);
    return subtotal + tax - disc;
  }

  void _processPayment() async {
    final cart = context.read<CartProvider>();
    final addressProvider = context.read<AddressProvider>();

    if (addressProvider.selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se seleccionó dirección de envío")),
      );
      return;
    }

    // Validar datos de tarjeta
    if (widget.paymentMethod == "tarjeta") {
      if (_formKey.currentState == null) {
        return;
      }
      
      if (!_formKey.currentState!.validate()) {
        return;
      }
      
      // Validación adicional de fecha
      if (!_isValidExpiry(_expiryController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Tarjeta vencida. Ingrese una fecha válida"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _submitting = true;
    });

    try {
      final orderId = await cart.checkout(
        address: addressProvider.selected!.toMap(),
        paymentMethod: widget.paymentMethod,
      );

      if (orderId != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderPlacedScreen(orderId: orderId),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al procesar la compra: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final address = context.watch<AddressProvider>().selected;

    final subtotal = cart.total;
    final tax = _calculateTax(subtotal);
    final discount = _calculateDiscount(subtotal);
    final finalTotal = _calculateTotal(subtotal);

    String paymentLabel = "";
    if (widget.paymentMethod == "efectivo") paymentLabel = "Efectivo al recibir";
    else if (widget.paymentMethod == "tarjeta") paymentLabel = "Tarjeta Bancaria";
    else if (widget.paymentMethod == "paypal") paymentLabel = "PayPal";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Confirmar Compra"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: _submitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF9900)),
                  SizedBox(height: 16),
                  Text(
                    "Procesando tu pago...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F3A5F)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Paso 3: Revisa y Confirma tu Pedido",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F3A5F)),
                  ),
                  const SizedBox(height: 16),

                  // 📍 1. Dirección Seleccionada
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFFFF9900)),
                              SizedBox(width: 8),
                              Text("Dirección de Envío", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const Divider(),
                          if (address != null) ...[
                            Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(address.street),
                            Text("${address.city}, ${address.state} C.P. ${address.zip}"),
                          ] else ...[
                            const Text("No seleccionada", style: TextStyle(color: Colors.red)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 💳 2. Método de Pago Seleccionado
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payment, color: Color(0xFFFF9900)),
                              SizedBox(width: 8),
                              Text("Método de Pago", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const Divider(),
                          Text(paymentLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          
                          // Formulario de tarjeta
                          if (widget.paymentMethod == "tarjeta") ...[
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "💳 Datos de la tarjeta",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F3A5F)),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Número de tarjeta
                                      TextFormField(
                                        controller: _cardNumberController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 19,
                                        decoration: InputDecoration(
                                          hintText: "1234 5678 9012 3456",
                                          labelText: "Número de tarjeta",
                                          prefixIcon: const Icon(Icons.credit_card, color: Color(0xFFFF9900)),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          counterText: "",
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Ingrese el número de tarjeta";
                                          }
                                          String cleanNumber = value.replaceAll(' ', '');
                                          if (cleanNumber.length < 13) {
                                            return "Mínimo 13 dígitos";
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          String formatted = _formatCardNumber(value);
                                          if (formatted != value) {
                                            _cardNumberController.value = TextEditingValue(
                                              text: formatted,
                                              selection: TextSelection.collapsed(offset: formatted.length),
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Fila: Fecha expiración + CVV
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _expiryController,
                                              keyboardType: TextInputType.number,
                                              maxLength: 5,
                                              decoration: InputDecoration(
                                                hintText: "MM/AA",
                                                labelText: "Fecha expiración",
                                                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFFF9900), size: 20),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                                counterText: "",
                                                filled: true,
                                                fillColor: Colors.white,
                                                errorMaxLines: 2,
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return "Requerido";
                                                }
                                                if (value.length != 5 || value[2] != '/') {
                                                  return "Formato: MM/AA";
                                                }
                                                // Validar que no esté vencida
                                                if (!_isValidExpiry(value)) {
                                                  return "❌ Tarjeta vencida";
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                String formatted = _formatExpiry(value);
                                                if (formatted != value) {
                                                  _expiryController.value = TextEditingValue(
                                                    text: formatted,
                                                    selection: TextSelection.collapsed(offset: formatted.length),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _cvvController,
                                              keyboardType: TextInputType.number,
                                              maxLength: 4,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                hintText: "123",
                                                labelText: "CVV",
                                                prefixIcon: const Icon(Icons.security, color: Color(0xFFFF9900)),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                                counterText: "",
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return "Requerido";
                                                }
                                                if (value.length < 3) {
                                                  return "Mínimo 3 dígitos";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "🔒 Fecha debe ser posterior al mes actual",
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 📦 3. Resumen de Artículos
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Productos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("${cart.items.length} artículos", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Divider(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.product.image,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                          Container(color: Colors.grey, width: 40, height: 40),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text("Cant: ${item.quantity}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Text("\$${item.subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 💰 4. Resumen de Precios
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Resumen de Compra", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const Divider(),
                          _buildPriceRow("Subtotal", subtotal),
                          const SizedBox(height: 6),
                          _buildPriceRow("Envío e Impuestos (16% IVA)", tax),
                          if (discount > 0) ...[
                            const SizedBox(height: 6),
                            _buildPriceRow("Descuento Promocional (10%)", -discount, isDiscount: true),
                          ],
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total del Pedido",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F3A5F)),
                              ),
                              Text(
                                "\$${finalTotal.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 🟧 Botón Pagar Ahora
                  ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9900),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Pagar ahora",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isDiscount = false}) {
    final valueText = isDiscount ? "-\$${(-value).toStringAsFixed(2)}" : "\$${value.toStringAsFixed(2)}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          valueText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDiscount ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}