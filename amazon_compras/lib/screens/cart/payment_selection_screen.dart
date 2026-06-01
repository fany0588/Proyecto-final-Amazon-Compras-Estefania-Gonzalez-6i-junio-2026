import 'package:flutter/material.dart';
import 'confirm_purchase_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String _selectedMethod = '';

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "efectivo",
      "name": "Efectivo al entregar",
      "description": "Paga en efectivo al recibir tu pedido en la puerta de tu hogar.",
      "icon": Icons.monetization_on_outlined,
      "color": Colors.green,
    },
    {
      "id": "tarjeta",
      "name": "Tarjeta de Crédito / Débito",
      "description": "Visa, MasterCard, American Express. Pago 100% encriptado y seguro.",
      "icon": Icons.credit_card_outlined,
      "color": Colors.blue,
    },
    {
      "id": "paypal",
      "name": "PayPal",
      "description": "Inicia sesión de forma segura y paga con tu saldo o tarjetas ligadas a PayPal.",
      "icon": Icons.payment_outlined,
      "color": Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Método de Pago"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Paso 2: ¿Cómo deseas pagar?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3A5F),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Option Cards
            Expanded(
              child: ListView.builder(
                itemCount: _methods.length,
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethod == method["id"];
                  final color = method["color"] as Color;

                  return Card(
                    color: isSelected ? const Color(0xFFE6D3B3).withOpacity(0.3) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFFF9900) : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMethod = method["id"];
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                method["icon"],
                                color: color,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1F3A5F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method["description"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.7),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: method["id"],
                              groupValue: _selectedMethod,
                              activeColor: const Color(0xFFFF9900),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMethod = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            ElevatedButton(
              onPressed: _selectedMethod.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmPurchaseScreen(
                            paymentMethod: _selectedMethod,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                disabledForegroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continuar a Confirmar Compra",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
