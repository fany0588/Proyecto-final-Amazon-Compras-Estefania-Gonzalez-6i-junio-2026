import 'dart:io';
import 'dart:typed_data';
import 'dart:convert'; // ✅ IMPORTANTE: Para base64Encode y base64Decode
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen de la galería
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );
      return image;
    } catch (e) {
      print('Error seleccionando imagen: $e');
      return null;
    }
  }

  /// Guardar imagen como Base64 en SharedPreferences (NO usa Storage)
  Future<String?> saveImageLocally(XFile imageFile, String userId) async {
    try {
      print('📸 Guardando imagen para usuario: $userId');
      
      // Leer bytes de la imagen
      final bytes = await imageFile.readAsBytes();
      
      // Comprimir si es muy grande (máximo 200KB)
      Uint8List finalBytes = bytes;
      if (bytes.length > 200 * 1024) {
        // Si es mayor a 200KB, comprimir más
        finalBytes = await _compressImage(bytes);
      }
      
      // Convertir a Base64
      final base64String = base64Encode(finalBytes); // ✅ Ahora funciona
      
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_base64_$userId', base64String);
      
      print('✅ Imagen guardada como Base64. Tamaño: ${finalBytes.length} bytes');
      return base64String;
      
    } catch (e) {
      print('❌ Error guardando imagen: $e');
      return null;
    }
  }
  
  /// Comprimir imagen si es muy grande
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    print('⚠️ Imagen grande (${bytes.length} bytes), comprimiendo...');
    // Por ahora devolvemos los bytes originales
    // En una implementación más avanzada podrías usar image_picker con calidad más baja
    return bytes;
  }

  /// Obtener imagen como Widget (MemoryImage)
  Future<ImageProvider?> getProfileImage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString('profile_image_base64_$userId');
      
      if (base64String != null && base64String.isNotEmpty) {
        final bytes = base64Decode(base64String); // ✅ Ahora funciona
        print('✅ Imagen cargada desde Base64: ${bytes.length} bytes');
        return MemoryImage(bytes);
      }
      return null;
      
    } catch (e) {
      print('Error obteniendo imagen: $e');
      return null;
    }
  }
  
  /// Obtener la ruta (para compatibilidad con código existente)
  Future<String?> getProfileImagePath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final hasImage = prefs.containsKey('profile_image_base64_$userId');
    return hasImage ? 'base64://$userId' : null;
  }

  /// Eliminar imagen de perfil
  Future<void> deleteOldProfileImage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_base64_$userId');
      print('🗑️ Imagen eliminada para usuario: $userId');
    } catch (e) {
      print('Error eliminando imagen: $e');
    }
  }
}