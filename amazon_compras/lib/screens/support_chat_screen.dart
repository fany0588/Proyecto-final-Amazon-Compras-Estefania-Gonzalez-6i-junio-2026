import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/support_message_service.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _auth = AuthService();
  final _messageService = SupportMessageService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? _userId;
  String _userName = 'Cliente';
  String _userEmail = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
        _userId = user.uid;
        _userEmail = user.email ?? '';
      });
      final userData = await _auth.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Cliente';
        });
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null) return;

    _messageService.sendMessage(
      userId: _userId!,
      userName: _userName,
      userEmail: _userEmail,
      message: text,
      isAdmin: false,
    );

    _messageController.clear();
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Chat de Soporte"),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
      ),
      body: !_isLoggedIn
          ? _buildLoginPrompt()
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _messageService.getMessagesStream(_userId, false),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      
                      // Sort in memory by date
                      final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                      sortedDocs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aDate = aData['createdAt'] as Timestamp?;
                        final bDate = bData['createdAt'] as Timestamp?;
                        if (aDate == null) return 1;
                        if (bDate == null) return -1;
                        return aDate.compareTo(bDate);
                      });

                      if (sortedDocs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              "¿Tienes alguna duda o inconveniente? Escríbenos aquí y un administrador te responderá.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedDocs.length,
                        itemBuilder: (context, index) {
                          final data = sortedDocs[index].data() as Map<String, dynamic>;
                          final message = data['message'] ?? '';
                          final isAdmin = data['isAdmin'] ?? false;
                          final timestamp = data['createdAt'] as Timestamp?;

                          final isMe = !isAdmin;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFFF9900) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isAdmin)
                                    const Text(
                                      "Soporte Amazon",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F3A5F),
                                      ),
                                    ),
                                  if (isAdmin) const SizedBox(height: 2),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      color: isMe ? Colors.black : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (timestamp != null)
                                    Text(
                                      _formatTime(timestamp.toDate()),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isMe ? Colors.black54 : Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
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
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Inicia sesión para contactar a soporte",
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Escribe tu mensaje...",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFFF9900)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
