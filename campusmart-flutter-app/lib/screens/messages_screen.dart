import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../providers/auth_provider.dart';
import '../providers/nav_provider.dart';
import '../services/api_client.dart';
import '../services/message_service.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_row.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';
import '../widgets/panel.dart';
import '../widgets/section_title.dart';
import '../widgets/state_message.dart';

/// "Messages": the chat list, and below it the open chat, as in the prototype.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.active});

  final bool active;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _input = TextEditingController();
  final _chatScroll = ScrollController();

  List<Conversation> _conversations = [];
  bool _loading = false;
  String? _error;

  ChatTarget? _chat;
  List<Message> _messages = [];
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    if (widget.active) _activateAfterBuild();
  }

  @override
  void didUpdateWidget(MessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _activateAfterBuild();
    if (oldWidget.active && !widget.active) _poll?.cancel();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _input.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  void _activateAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadConversations();
      final nav = context.read<NavProvider>();
      final target = nav.pendingChat;
      if (target != null) {
        nav.clearPendingChat();
        _openChat(target);
      } else if (_chat != null) {
        _openChat(_chat!); // came back to an open chat: refresh it
      }
    });
  }

  Future<void> _loadConversations() async {
    final service = context.read<MessageService>();
    setState(() {
      _loading = _conversations.isEmpty;
      _error = null;
    });
    try {
      final list = await service.conversations();
      if (mounted) setState(() => _conversations = list);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openChat(ChatTarget target) async {
    setState(() {
      _chat = target;
      _messages = [];
    });
    await _loadThread();
    _poll?.cancel();
    // No push messages in this backend, so the open chat checks for new messages every few seconds.
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _loadThread(quiet: true));
  }

  Future<void> _loadThread({bool quiet = false}) async {
    final target = _chat;
    if (target == null) return;
    final service = context.read<MessageService>();
    try {
      final list = await service.thread(withUser: target.otherUserId, itemId: target.itemId);
      if (!mounted || _chat != target) return;
      final changed = list.length != _messages.length;
      setState(() => _messages = list);
      if (changed) _scrollToEnd();
    } on ApiException catch (e) {
      if (!quiet) showToast(e.message);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.jumpTo(_chatScroll.position.maxScrollExtent);
      }
    });
  }

  void _closeChat() {
    _poll?.cancel();
    setState(() => _chat = null);
    _loadConversations();
  }

  Future<void> _send() async {
    final target = _chat;
    final text = _input.text.trim();
    if (target == null || text.isEmpty) return;
    final service = context.read<MessageService>();
    try {
      await service.send(receiverId: target.otherUserId, itemId: target.itemId, body: text);
      _input.clear();
      await _loadThread();
      _loadConversations();
    } on ApiException catch (e) {
      showToast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().user?.id;

    final Widget list;
    if (_loading && _conversations.isEmpty) {
      list = const LoadingIndicator();
    } else if (_error != null && _conversations.isEmpty) {
      list = ErrorRetry(message: _error!, onRetry: _loadConversations);
    } else if (_conversations.isEmpty) {
      list = const Text('No conversations yet.', style: TextStyle(color: AppColors.muted));
    } else {
      list = Column(
        children: [
          for (final c in _conversations)
            AppRow(
              onTap: () => _openChat(c.target),
              trailing: const Text('›', style: TextStyle(fontSize: 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.target.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    c.target.itemTitle == null ? c.lastMessage : '${c.target.itemTitle} · ${c.lastMessage}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      children: [
        const SectionTitle('Messages', 'Chat with sellers'),
        Panel(child: list),
        if (_chat != null)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppRow(
                  last: true,
                  trailing: AppButton(label: 'Back', secondary: true, onPressed: _closeChat),
                  child: Text(_chat!.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 180, maxHeight: 310),
                  child: ListView(
                    controller: _chatScroll,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (final m in _messages) _Bubble(text: m.body, mine: m.senderId == myId),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _input,
                        hint: 'Type a message...',
                        margin: EdgeInsets.zero,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 7),
                    AppButton(label: '', icon: Icons.send, onPressed: _send),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82 - 40),
        decoration: BoxDecoration(
          color: mine ? AppColors.bubbleMine : AppColors.bubble,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(text),
      ),
    );
  }
}
