import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class SupportMessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Stream of messages for a user (or all if admin)
  Stream<QuerySnapshot> getMessagesStream(String? userId, bool isAdmin) {
    if (isAdmin) {
      return _db.collection('messages').snapshots();
    } else {
      return _db
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .snapshots();
    }
  }

  // Send message
  Future<void> sendMessage({
    required String userId,
    required String userName,
    required String userEmail,
    required String message,
    required bool isAdmin,
  }) async {
    try {
      final doc = _db.collection('messages').doc();
      await doc.set({
        'id': doc.id,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'message': message,
        'isAdmin': isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification
      if (isAdmin) {
        // Notify client
        await _notificationService.createNotification(
          userId: userId,
          title: "Respuesta de soporte",
          body: "El administrador ha respondido a tu consulta: $message",
          type: "new_message",
          extraData: {'messageId': doc.id},
        );
      } else {
        // Notify admin
        await _notificationService.createNotification(
          userId: "admin",
          title: "Nuevo mensaje de soporte",
          body: "El usuario $userName ha enviado un mensaje: $message",
          type: "new_message",
          extraData: {'userId': userId, 'messageId': doc.id},
        );
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String id) async {
    try {
      await _db.collection('messages').doc(id).delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }
}
