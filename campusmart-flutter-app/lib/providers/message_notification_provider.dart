import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../services/api_client.dart';
import '../services/message_service.dart';
import '../widgets/app_toast.dart';
import 'auth_provider.dart';

/// Watches the inbox while the app is open so new messages are surfaced even
/// when the user is on another page.
class MessageNotificationProvider extends ChangeNotifier {
  MessageNotificationProvider(this._messages, this._auth) {
    _auth.addListener(_authChanged);
  }

  final MessageService _messages;
  final AuthProvider _auth;
  Timer? _timer;
  List<Conversation> conversations = const [];
  int unreadCount = 0;
  bool _hasBaseline = false;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => refresh());
    refresh();
  }

  Future<void> refresh() async {
    if (_auth.status != AuthStatus.authenticated) return;
    try {
      final next = await _messages.conversations();
      if (_auth.status != AuthStatus.authenticated) return;
      final nextUnread = next.fold<int>(0, (sum, c) => sum + c.unreadCount);

      if (_hasBaseline && nextUnread > unreadCount && next.isNotEmpty) {
        final conversation =
            next.firstWhere((c) => c.unreadCount > 0, orElse: () => next.first);
        final count = conversation.unreadCount == 1
            ? 'New message'
            : '${conversation.unreadCount} new messages';
        showToast('$count from ${conversation.target.otherUserName}');
      }

      conversations = next;
      unreadCount = nextUnread;
      _hasBaseline = true;
      notifyListeners();
    } on ApiException {
      // Message notifications are best-effort; the inbox displays its own errors.
    }
  }

  void _authChanged() {
    if (_auth.status == AuthStatus.authenticated) {
      _hasBaseline = false;
      refresh();
    } else {
      conversations = const [];
      unreadCount = 0;
      _hasBaseline = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_authChanged);
    _timer?.cancel();
    super.dispose();
  }
}
