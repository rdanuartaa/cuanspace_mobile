import 'package:flutter/material.dart';
import '../models/massage.dart';
import '../services/api_service.dart';
import '/main.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  int? chatId;
  int? sellerId;
  String? sellerName; // Ubah dari late ke nullable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null) {
        chatId = args['chat_id'] as int? ?? 0;
        sellerId = args['seller_id'] as int? ?? 0;
        sellerName = args['seller_name'] as String? ?? 'Seller';
      } else {
        chatId = 0;
        sellerId = 0;
        sellerName = 'Seller';
      }
      fetchMessages();
    });
  }

  Future<void> fetchMessages() async {
    if (chatId == 0) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID percakapan tidak valid')),
      );
      return;
    }

    try {
      final result = await apiService.fetchMessages(chatId!);
      if (result['success']) {
        setState(() {
          messages = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memuat pesan')),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pesan: $e')),
      );
    }
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final result = await apiService.sendMessage(chatId!, _messageController.text.trim());
      if (result['success']) {
        setState(() {
          messages.add(result['data']);
          _messageController.clear();
        });
      } else {
        if (result['navigateToLogin'] == true) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal mengirim pesan')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${sellerName ?? 'Seller'}', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: darkOrange))
                : messages.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada pesan.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(14),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];
                          final isMe = sellerId != null && message.senderId != sellerId;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? darkOrange.withOpacity(0.1)
                                    : Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.createdAt,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 10,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: darkOrange),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}