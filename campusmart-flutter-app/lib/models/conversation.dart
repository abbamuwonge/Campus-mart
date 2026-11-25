/// Which chat is open: the other person and (optionally) the item being discussed.
class ChatTarget {
  const ChatTarget({
    required this.otherUserId,
    required this.otherUserName,
    this.itemId,
    this.itemTitle,
  });

  final int otherUserId;
  final String otherUserName;
  final int? itemId;
  final String? itemTitle;
}

/// One inbox row, from GET /messages/conversations.
class Conversation {
  const Conversation({
    required this.target,
    required this.lastMessage,
    required this.unreadCount,
  });

  final ChatTarget target;
  final String lastMessage;
  final int unreadCount;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      target: ChatTarget(
        otherUserId: json['other_user_id'] as int,
        otherUserName: json['other_user_name'] as String,
        itemId: json['item_id'] as int?,
        itemTitle: json['item_title'] as String?,
      ),
      lastMessage: json['last_message'] as String,
      unreadCount: json['unread_count'] as int,
    );
  }
}
