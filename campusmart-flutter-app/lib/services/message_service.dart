import '../models/conversation.dart';
import '../models/message.dart';
import 'api_client.dart';

class MessageService {
  MessageService(this._api);

  final ApiClient _api;

  /// GET /messages/conversations: the inbox.
  Future<List<Conversation>> conversations() async {
    final data = await _api.get('/messages/conversations') as List<dynamic>;
    return data.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /messages/thread: the chat with one person about one item. Also marks it as read.
  Future<List<Message>> thread({required int withUser, int? itemId}) async {
    final params = <String, String>{'with_user': '$withUser'};
    if (itemId != null) params['item_id'] = '$itemId';
    final data = await _api.get('/messages/thread?${Uri(queryParameters: params).query}') as List<dynamic>;
    return data.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /messages
  Future<void> send({required int receiverId, int? itemId, required String body}) async {
    await _api.post('/messages', body: {
      'receiver_id': receiverId,
      if (itemId != null) 'item_id': itemId,
      'body': body,
    });
  }
}
