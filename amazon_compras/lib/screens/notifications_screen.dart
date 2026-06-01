import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _auth = AuthService();
  final _notifService = NotificationService();
  
  String? _userId;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
        _userId = user.uid;
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'purchase_made':
        return Icons.shopping_bag_outlined;
      case 'order_update':
        return Icons.local_shipping_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline;
      case 'new_review':
        return Icons.star_outline;
      case 'admin_announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'purchase_made':
        return Colors.green;
      case 'order_update':
        return const Color(0xFFFF9900);
      case 'new_message':
        return Colors.blue;
      case 'new_review':
        return Colors.amber;
      case 'admin_announcement':
        return Colors.red;
      default:
        return const Color(0xFF1F3A5F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
        actions: _isLoggedIn
            ? [
                TextButton(
                  onPressed: () async {
                    if (_userId != null) {
                      await _notifService.markAllAsRead(_userId!, false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Todas las notificaciones marcadas como leídas")),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Marcar todo leído",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ]
            : null,
      ),
      body: !_isLoggedIn
          ? _buildLoginPrompt()
          : StreamBuilder<QuerySnapshot>(
              stream: _notifService.getNotificationsStream(_userId!, false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Filter notifications belonging to the user OR "all" (announcements)
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final targetUser = data['userId']?.toString();
                  return targetUser == _userId || targetUser == 'all';
                }).toList();

                // Sort in memory by date descending
                filteredDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aDate = aData['createdAt'] as Timestamp?;
                  final bDate = bData['createdAt'] as Timestamp?;
                  if (aDate == null) return -1;
                  if (bDate == null) return 1;
                  return bDate.compareTo(aDate);
                });

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No tienes notificaciones en este momento.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final title = data['title'] ?? 'Aviso';
                    final body = data['body'] ?? '';
                    final isRead = data['isRead'] ?? false;
                    final type = data['type'] ?? '';
                    final timestamp = data['createdAt'] as Timestamp?;

                    return Card(
                      color: isRead ? Colors.white : const Color(0xFFFFF7ED),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isRead
                            ? BorderSide.none
                            : const BorderSide(color: Color(0xFFFF9900), width: 1),
                      ),
                      elevation: isRead ? 1 : 3,
                      child: InkWell(
                        onTap: () {
                          if (!isRead) {
                            _notifService.markAsRead(id);
                          }
                          _showNotificationDetail(title, body, type);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getColorForType(type).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForType(type),
                                  color: _getColorForType(type),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                                              color: const Color(0xFF1F3A5F),
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF9900),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                    if (timestamp != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDate(timestamp.toDate()),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                onPressed: () {
                                  _notifService.deleteNotification(id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Inicia sesión para ver tus notificaciones",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                foregroundColor: Colors.black,
              ),
              child: const Text("Iniciar Sesión"),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(String title, String body, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(_getIconForType(type), color: _getColorForType(type)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          body,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return "Hoy a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 1) {
      return "Ayer a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
