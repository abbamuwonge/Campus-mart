import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/catalog_provider.dart';
import '../providers/nav_provider.dart';
import '../services/api_client.dart';
import '../services/favorite_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_title.dart';
import '../widgets/state_message.dart';

/// "Saved items": the user's favourites, loaded from the backend each time the page is opened.
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key, required this.active});

  final bool active;

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Item> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.active) _reloadAfterBuild();
  }

  @override
  void didUpdateWidget(FavouritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _reloadAfterBuild();
  }

  void _reloadAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final service = context.read<FavoriteService>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await service.list();
      if (mounted) setState(() => _items = list);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleSaved(CatalogProvider catalog, int itemId) async {
    final error = await catalog.toggleFavorite(itemId);
    if (error != null) showToast(error);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final nav = context.read<NavProvider>();
    // Unsaving a card removes it straight away, without waiting for the server.
    final shown = _items.where((i) => catalog.isFavorite(i.id)).toList();

    final Widget body;
    if (_loading && _items.isEmpty) {
      body = const LoadingIndicator();
    } else if (_error != null && _items.isEmpty) {
      body = ErrorRetry(message: _error!, onRetry: _load);
    } else if (shown.isEmpty) {
      body = const EmptyMessage('No saved items yet. Tap ♡ on a listing to save it.');
    } else {
      body = ProductGrid(
        children: [
          for (final item in shown)
            ProductCard(
              item: item,
              isSaved: true,
              onOpen: () => nav.openDetail(item),
              onToggleSaved: () => _toggleSaved(catalog, item.id),
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      children: [
        const SectionTitle('Saved items', 'Your favourites'),
        body,
      ],
    );
  }
}
