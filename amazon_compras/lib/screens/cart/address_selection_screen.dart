import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import 'payment_selection_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  bool _isAddingNew = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing addresses from Firestore
    Future.microtask(() => context.read<AddressProvider>().loadAddresses());
  }

  void _saveNewAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final newAddress = AddressModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zip: _zipController.text.trim(),
    );

    await context.read<AddressProvider>().addAddress(newAddress);
    
    // Select the newly added address automatically
    context.read<AddressProvider>().selectAddress(newAddress);

    setState(() {
      _isAddingNew = false;
      _nameController.clear();
      _streetController.clear();
      _cityController.clear();
      _stateController.clear();
      _zipController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Dirección guardada exitosamente!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    final selected = addressProvider.selected;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Dirección de Envío"),
        backgroundColor: const Color(0xFF1F3A5F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Paso 1: ¿Dónde enviamos tu pedido?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3A5F),
              ),
            ),
            const SizedBox(height: 16),

            // Inline form to add address
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isAddingNew
                  ? _buildAddAddressForm()
                  : const SizedBox.shrink(),
            ),

            if (!_isAddingNew) ...[
              // Addresses List
              if (addresses.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "No tienes direcciones registradas.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isAddingNew = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Dirección", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    final isSelected = selected?.id == addr.id;

                    return Card(
                      color: isSelected ? const Color(0xFFE6D3B3).withOpacity(0.3) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFFF9900) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          addressProvider.selectAddress(addr);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: addr.id,
                                groupValue: selected?.id,
                                activeColor: const Color(0xFFFF9900),
                                onChanged: (value) {
                                  addressProvider.selectAddress(addr);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addr.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1F3A5F),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      addr.street,
                                      style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 13),
                                    ),
                                    Text(
                                      "${addr.city}, ${addr.state} C.P. ${addr.zip}",
                                      style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Add address button when list is not empty
                OutlinedButton.icon(
                  onPressed: () => setState(() => _isAddingNew = true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F3A5F),
                    side: const BorderSide(color: Color(0xFF1F3A5F)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text("Registrar otra dirección", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ],

            const SizedBox(height: 32),

            // Continue Button
            if (!_isAddingNew)
              ElevatedButton(
                onPressed: selected == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentSelectionScreen(),
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
                      "Continuar a Método de Pago",
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

  Widget _buildAddAddressForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nueva Dirección",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F3A5F)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => setState(() => _isAddingNew = false),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre del Recipiente (ej. Casa, Oficina, Juan Pérez)",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
            ),
            const SizedBox(height: 12),

            // Street
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: "Calle y Número",
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
            ),
            const SizedBox(height: 12),

            // City and State
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: "Ciudad",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: "Estado",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ZIP Code
            TextFormField(
              controller: _zipController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Código Postal (C.P.)",
                prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => v == null || v.length < 5 ? "C.P. inválido" : null,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _isAddingNew = false),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveNewAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3A5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Guardar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
