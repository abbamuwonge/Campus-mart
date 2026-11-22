import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/catalog_provider.dart';
import '../providers/nav_provider.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_title.dart';
import '../widgets/state_message.dart';

/// Marketplace home: search, banner, category chips and the product grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<CatalogProvider>().loadMore(); // next page of 20
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _toggleSaved(CatalogProvider catalog, int itemId) async {
    final error = await catalog.toggleFavorite(itemId);
    if (error != null) showToast(error);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final nav = context.read<NavProvider>();

    final Widget results;
    if (catalog.loading && catalog.items.isEmpty) {
      results = const LoadingIndicator();
    } else if (catalog.error != null && catalog.items.isEmpty) {
      results = ErrorRetry(message: catalog.error!, onRetry: catalog.refresh);
    } else if (catalog.items.isEmpty) {
      results = const EmptyMessage('No items found.');
    } else {
      results = Column(
        children: [
          ProductGrid(
            children: [
              for (final item in catalog.items)
                ProductCard(
                  item: item,
                  isSaved: catalog.isFavorite(item.id),
                  onOpen: () => nav.openDetail(item),
                  onToggleSaved: () => _toggleSaved(catalog, item.id),
                ),
            ],
          ),
          if (catalog.loadingMore) const LoadingIndicator(),
        ],
      );
    }

    return RefreshIndicator(
      color: AppColors.orange,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        await catalog.loadFavoriteIds();
        await catalog.refresh();
      },
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _search,
                    hint: 'Search items, books, electronics...',
                    margin: EdgeInsets.zero,
                    textInputAction: TextInputAction.search,
                    onChanged: catalog.search,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showToast('Search listings'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.search, size: 22, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.bannerLine),
              gradient: const LinearGradient(
                begin: Alignment(-1, -0.6),
                end: Alignment(1, 0.6),
                colors: [AppColors.bannerA, AppColors.bannerB],
                stops: [0, 0.72],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your campus marketplace',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Great student deals, all in one place.',
                        style: TextStyle(fontSize: 12, color: AppColors.bannerText),
                      ),
                      const SizedBox(height: 13),
                      AppButton(label: 'Start selling', onPressed: () => nav.go(AppPage.sell)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🛍️', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
          const SizedBox(height: 17),
          CategoryChips(
            categories: catalog.categories,
            selectedId: catalog.categoryId,
            onSelected: catalog.selectCategory,
          ),
          SectionTitle('Recommended for you', '${catalog.items.length} items'),
          results,
        ],
      ),
    );
  }
}
