import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/order.dart';
import '../providers/catalog_provider.dart';
import '../providers/nav_provider.dart';
import '../services/api_client.dart';
import '../services/item_service.dart';
import '../services/order_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/app_button.dart';
import '../widgets/app_row.dart';
import '../widgets/app_toast.dart';
import '../widgets/panel.dart';
import '../widgets/section_title.dart';
import '../widgets/state_message.dart';
import '../widgets/status_badge.dart';

class _Action {
  const _Action(this.label, this.run);

  final String label;
  final Future<void> Function() run;
}

/// "My orders": my buying requests, requests received for my items, and my listings.
/// Tap a row to manage it (cancel, accept, reject, complete, edit, mark sold, delete).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.active});

  final bool active;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _buying = [];
  List<Order> _received = [];
  List<Item> _listings = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.active) _reloadAfterBuild();
  }

  @override
  void didUpdateWidget(OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _reloadAfterBuild();
  }

  void _reloadAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final orders = context.read<OrderService>();
    final items = context.read<ItemService>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([orders.mine(), orders.received(), items.mine()]);
      if (!mounted) return;
      setState(() {
        _buying = results[0] as List<Order>;
        _received = results[1] as List<Order>;
        _listings = results[2] as List<Item>;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Runs one action, shows a toast, then reloads the lists.
  Future<void> _run(Future<void> Function() action, String done) async {
    try {
      await action();
      showToast(done);
    } on ApiException catch (e) {
      showToast(e.message);
    }
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    context.read<CatalogProvider>().refresh(); // statuses changed, so the feed may have too
  }

  Future<void> _showActions(String title, List<_Action> actions) async {
    if (actions.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final action in actions)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppButton(
                    label: action.label,
                    secondary: true,
                    full: true,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      action.run();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _manageBuying(Order order) {
    final orders = context.read<OrderService>();
    _showActions(order.itemTitle, [
      if (order.status == 'pending')
        _Action('Cancel request', () => _run(() => orders.setStatus(order.id, 'cancelled'), 'Request cancelled')),
    ]);
  }

  void _manageReceived(Order order) {
    final orders = context.read<OrderService>();
    _showActions('Request from ${order.buyerName}', [
      if (order.status == 'pending')
        _Action('Accept request', () => _run(() => orders.setStatus(order.id, 'accepted'), 'Request accepted')),
      if (order.status == 'accepted')
        _Action('Mark as completed', () => _run(() => orders.setStatus(order.id, 'completed'), 'Order completed')),
      if (order.status == 'pending' || order.status == 'accepted')
        _Action('Reject request', () => _run(() => orders.setStatus(order.id, 'rejected'), 'Request rejected')),
    ]);
  }

  void _manageListing(Item item) {
    final items = context.read<ItemService>();
    final nav = context.read<NavProvider>();
    _showActions(item.title, [
      _Action('Edit listing', () async => nav.editItem(item)),
      if (item.status != 'sold')
        _Action('Mark as sold', () => _run(() => items.setStatus(item.id, 'sold'), 'Marked as sold')),
      if (item.status == 'sold')
        _Action('Mark as available', () => _run(() => items.setStatus(item.id, 'available'), 'Listing is available again')),
      _Action('Delete listing', () => _confirmDelete(item)),
    ]);
  }

  Future<void> _confirmDelete(Item item) async {
    final items = context.read<ItemService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete this listing?'),
        content: Text('"${item.title}" will be removed for everyone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() => items.delete(item.id), 'Listing deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      for (final o in _received)
        AppRow(
          onTap: () => _manageReceived(o),
          trailing: StatusBadge(capitalize(o.status)),
          child: _rowText(o.itemTitle, 'Request from ${o.buyerName} · ${cash(o.priceAtOrder)}'),
        ),
      for (final o in _buying)
        AppRow(
          onTap: () => _manageBuying(o),
          trailing: StatusBadge(capitalize(o.status)),
          child: _rowText(o.itemTitle, 'Buying · ${cash(o.priceAtOrder)}'),
        ),
      for (final i in _listings)
        AppRow(
          onTap: () => _manageListing(i),
          trailing: StatusBadge(i.status == 'available' ? 'Published' : capitalize(i.status)),
          child: _rowText(i.title, 'Selling · ${cash(i.price)}'),
        ),
    ];

    final Widget list;
    if (_loading && rows.isEmpty) {
      list = const LoadingIndicator();
    } else if (_error != null && rows.isEmpty) {
      list = ErrorRetry(message: _error!, onRetry: _load);
    } else if (rows.isEmpty) {
      list = const Text(
        'Your buying requests and published listings will appear here.',
        style: TextStyle(color: AppColors.muted),
      );
    } else {
      list = Column(children: rows);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      children: [
        const SectionTitle('My orders', 'Buying & selling'),
        Panel(
          child: Column(
            children: [
              AppRow(trailing: Text('${_buying.length}', style: const TextStyle(fontWeight: FontWeight.bold)), child: const Text('Buying requests')),
              AppRow(last: true, trailing: Text('${_listings.length}', style: const TextStyle(fontWeight: FontWeight.bold)), child: const Text('My listings')),
            ],
          ),
        ),
        Panel(child: list),
      ],
    );
  }

  Widget _rowText(String title, String meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(meta, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
      ],
    );
  }
}
