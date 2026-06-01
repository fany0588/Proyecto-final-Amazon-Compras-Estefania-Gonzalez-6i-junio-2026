import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/profile_image_service.dart';
import '../services/notification_service.dart';
import 'orders/my_orders_screen.dart';
import 'notifications_screen.dart';
import 'support_chat_screen.dart';
import 'my_reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileImageService _imageService = ProfileImageService();
  final searchController = TextEditingController();
  
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que deseas salir de tu cuenta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/pre-login', (route) => false);
    }
  }

  /// Cambiar foto de perfil - VERSIÓN SIN STORAGE
  Future<void> _changeProfilePhoto() async {
    try {
      final imageFile = await _imageService.pickImageFromGallery();
      if (imageFile == null) return;

      setState(() {
        _isUploading = true;
      });

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Eliminar imagen anterior si existe
      await _imageService.deleteOldProfileImage(userId);
      
      // Guardar nueva imagen localmente
      final localPath = await _imageService.saveImageLocally(imageFile, userId);
      
      if (localPath != null) {
        // Actualizar Firestore con la ruta local
        final success = await _authService.updateProfilePhoto(localPath);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Forzar rebuild del widget
          setState(() {});
        } else {
          throw Exception('No se pudo actualizar la referencia en Firestore');
        }
      } else {
        throw Exception('No se pudo guardar la imagen localmente');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Widget para mostrar la foto de perfil
  /// Widget para mostrar la foto de perfil (versión Base64)
Widget _buildProfilePhoto(String userId) {
  if (_isUploading) {
    return const CircularProgressIndicator(color: Colors.white);
  }
  
  return FutureBuilder<ImageProvider?>(
    future: _imageService.getProfileImage(userId),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        return CircleAvatar(
          radius: 45,
          backgroundColor: const Color(0xFFFF9900),
          backgroundImage: snapshot.data,
          child: null,
        );
      }
      
      // Imagen por defecto
      return const CircleAvatar(
        radius: 45,
        backgroundColor: Color(0xFFFF9900),
        child: Icon(Icons.person, size: 45, color: Colors.white),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔍 Barra de Búsqueda Superior
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    final query = value.trim();
                    if (query.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyOrdersScreen(searchQuery: query),
                        ),
                      ).then((_) {
                        searchController.clear();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Buscar en tu perfil o pedidos...",
                    prefixIcon: InkWell(
                      onTap: () {
                        final query = searchController.text.trim();
                        if (query.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyOrdersScreen(searchQuery: query),
                            ),
                          ).then((_) {
                            searchController.clear();
                          });
                        }
                      },
                      child: const Icon(Icons.search, color: Color(0xFF1F3A5F)),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔔 Botones Notificaciones y Soporte
              Builder(
                builder: (context) {
                  final userId = _authService.currentUser?.uid;
                  return Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: userId != null
                              ? NotificationService().getNotificationsStream(userId, false)
                              : const Stream.empty(),
                          builder: (context, snapshot) {
                            final docs = snapshot.data?.docs ?? [];
                            final unread = docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final target = data['userId']?.toString();
                              final isRead = data['isRead'] ?? false;
                              return (target == userId || target == 'all') && !isRead;
                            }).length;
                            return ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F3A5F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_active_outlined, size: 20),
                                  if (unread > 0)
                                    Positioned(
                                      right: -6,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF9900),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$unread',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              label: const Text("Notificaciones"),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SupportChatScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1F3A5F),
                            side: const BorderSide(color: Color(0xFF1F3A5F)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          label: const Text("Soporte"),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 👤 Contenedor de Foto e Info
              StreamBuilder<DocumentSnapshot>(
                stream: _authService.getUserDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  final name = userData['name'] ?? 'Usuario';
                  final email = userData['email'] ?? 'sin_correo@amazon.com';
                  final role = userData['role'] ?? 'client';
                  final photo = userData['photoUrl'] ?? '';
                  final phone = userData['phone'] ?? 'No registrado';
                  final userId = _authService.currentUser?.uid ?? '';
                  
                  DateTime registrationDate = DateTime.now();
                  if (userData['createdAt'] is Timestamp) {
                    registrationDate = (userData['createdAt'] as Timestamp).toDate();
                  }

                  final isClient = role != 'admin';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Contenedor principal de perfil
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F3A5F),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Foto de perfil con botón de cámara
                            // Foto de perfil con botón de cámara
Stack(
  children: [
    _buildProfilePhoto(userId),
    Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: _isUploading ? null : _changeProfilePhoto,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9900),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: const Icon(
            Icons.camera_alt,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isClient ? const Color(0xFFFF9900) : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isClient ? "Cliente Amazon" : "Administrador",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Datos de Registro
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Datos de Registro",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F3A5F),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.person_outline, "Nombre Completo", name),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.mail_outline, "Correo de Cuenta", email),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.phone_outlined, "Teléfono de Contacto", phone),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.calendar_today_outlined, 
                              "Fecha de Registro", 
                              DateFormat('dd/MM/yyyy HH:mm').format(registrationDate)
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Accesos Rápidos
              const Text(
                "Accesos Rápidos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3A5F),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF9900), width: 1.5),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.local_shipping, color: Color(0xFFFF9900), size: 30),
                            SizedBox(height: 8),
                            Text(
                              "Mis Pedidos",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F3A5F),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF9900), width: 1.5),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.star_rate, color: Color(0xFFFF9900), size: 30),
                            SizedBox(height: 8),
                            Text(
                              "Mis Reseñas",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F3A5F),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Cerrar Sesión
              ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.exit_to_app),
                label: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1F3A5F), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}