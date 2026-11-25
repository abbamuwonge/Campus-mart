class Message {
  const Message({required this.id, required this.senderId, required this.body});

  final int id;
  final int senderId;
  final String body;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['message_id'] as int,
      senderId: json['sender_id'] as int,
      body: json['body'] as String,
    );
  }
}
