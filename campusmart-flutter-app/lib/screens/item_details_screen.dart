import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../models/item.dart';
import '../providers/catalog_provider.dart';
import '../providers/nav_provider.dart';
import '../services/api_client.dart';
import '../services/message_service.dart';
import '../services/order_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/app_button.dart';
import '../widgets/app_row.dart';
import '../widgets/app_toast.dart';
import '../widgets/item_photo.dart';
import '../widgets/panel.dart';

/// Product details and seller information, with Request to buy, Message seller and Save item.
class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.item});

  final Item? item;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool _busy = false;

  Future<void> _buy(Item item) async {
    final orders = context.read<OrderService>();
    final nav = context.read<NavProvider>();
    setState(() => _busy = true);
    try {
      await orders.create(item.id);
      showToast('Purchase request added to your orders');
      nav.go(AppPage.orders);
    } on ApiException catch (e) {
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _messageSeller(Item item) async {
    final messages = context.read<MessageService>();
    final nav = context.read<NavProvider>();
    setState(() => _busy = true);
    try {
      // Like the prototype: a new chat starts with a first message.
      final thread = await messages.thread(withUser: item.sellerId, itemId: item.id);
      if (thread.isEmpty) {
        await messages.send(
          receiverId: item.sellerId,
          itemId: item.id,
          body: 'Hello, I am interested in your listing.',
        );
      }
      nav.openChat(ChatTarget(
        otherUserId: item.sellerId,
        otherUserName: item.sellerName,
        itemId: item.id,
        itemTitle: item.title,
      ));
    } on ApiException catch (e) {
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleSaved(Item item) async {
    final error = await context.read<CatalogProvider>().toggleFavorite(item.id);
    showToast(error ?? 'Saved items updated');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    if (item == null) return const SizedBox.shrink();
    final nav = context.read<NavProvider>();
    final saved = context.watch<CatalogProvider>().isFavorite(item.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(label: '← Back', secondary: true, onPressed: () => nav.go(AppPage.home)),
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ItemPhoto(item: item, height: 245, emojiSize: 90),
              ),
              const SizedBox(height: 15),
              Text('${item.category.name} · ${item.conditionLabel}', style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 14),
              Text(item.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Text(
                cash(item.price),
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.price),
              ),
              const SizedBox(height: 14),
              Text(item.description, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 14),
              Panel(
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seller', style: TextStyle(fontWeight: FontWeight.bold)),
                    AppRow(
                      last: true,
                      trailing: Text(item.sellerCampus, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      child: Text(item.sellerName),
                    ),
                    const Text(
                      'Arrange a safe meeting point on campus when completing a purchase.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              AppButton(label: 'Request to buy', full: true, loading: _busy, onPressed: () => _buy(item)),
              const SizedBox(height: 8),
              AppButton(label: 'Message seller', full: true, secondary: true, onPressed: _busy ? null : () => _messageSeller(item)),
              const SizedBox(height: 8),
              AppButton(
                label: saved ? 'Remove from saved' : 'Save item',
                icon: saved ? Icons.favorite : Icons.favorite_border,
                full: true,
                secondary: true,
                onPressed: () => _toggleSaved(item),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
