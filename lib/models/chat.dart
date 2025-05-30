class Chat {
  final int id;
  final int sellerId;
  final String sellerName;
  final String lastMessage;
  final String lastMessageTime;
  final String senderName;

  Chat({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.senderName,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    String time = json['last_message_time']?.toString() ?? '';
    if (time.isNotEmpty) {
      try {
        DateTime.parse(time);
      } catch (e) {
        print('Invalid date format for last_message_time: $time');
        time = DateTime.now().toIso8601String();
      }
    } else {
      time = DateTime.now().toIso8601String();
    }
    return Chat(
      id: json['id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      sellerName: json['seller_name'] ?? 'Penjual Tidak Diketahui',
      lastMessage: json['last_message']?.isNotEmpty == true ? json['last_message'] : 'Belum ada pesan',
      lastMessageTime: time,
      senderName: json['sender_name'] ?? 'Pengguna Tidak Diketahui',
    );
  }
}