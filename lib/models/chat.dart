class Chat {
  final int id;
  final int sellerId;
  final String sellerName;
  final String lastMessage;
  final String lastMessageTime;

  Chat({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      sellerId: json['seller_id'],
      sellerName: json['seller_name'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] ?? '',
    );
  }
}