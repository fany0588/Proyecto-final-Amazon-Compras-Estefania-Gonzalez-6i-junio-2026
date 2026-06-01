import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of notifications for a specific user
  Stream<QuerySnapshot> getNotificationsStream(String userId, bool isAdmin) {
    if (isAdmin) {
      // Admin sees notifications directed to 'admin'
      return _db
          .collection('notifications')
          .where('userId', isEqualTo: 'admin')
          .snapshots();
    } else {
      // Clients see their own notifications or general announcements ('all')
      return _db
          .collection('notifications')
          .snapshots();
    }
  }

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final doc = _db.collection('notifications').doc();
      await doc.set({
        'id': doc.id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'extraData': extraData ?? {},
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _db.collection('notifications').doc(id).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId, bool isAdmin) async {
    try {
      final targetUser = isAdmin ? 'admin' : userId;
      final snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: targetUser)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      if (!isAdmin) {
        // Also mark 'all' announcements as read
        final allSnapshot = await _db
            .collection('notifications')
            .where('userId', isEqualTo: 'all')
            .where('isRead', isEqualTo: false)
            .get();
        for (var doc in allSnapshot.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _db.collection('notifications').doc(id).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
