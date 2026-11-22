import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/catalog_provider.dart';
import '../providers/nav_provider.dart';
import '../services/category_service.dart';
import '../services/favorite_service.dart';
import '../services/item_service.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import 'favourites_screen.dart';
import 'home_screen.dart';
import 'item_details_screen.dart';
import 'messages_screen.dart';
import 'orders_screen.dart';
import 'post_item_screen.dart';
import 'profile_screen.dart';

/// What the user sees after signing in: the sticky header, the current page and the bottom bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavProvider>(create: (_) => NavProvider()),
        ChangeNotifierProvider<CatalogProvider>(
          create: (ctx) {
            final catalog = CatalogProvider(
              ctx.read<ItemService>(),
              ctx.read<CategoryService>(),
              ctx.read<FavoriteService>(),
            );
            catalog.init();
            return catalog;
          },
        ),
      ],
      child: const _ShellView(),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            // The order here must match the AppPage enum in nav_provider.dart.
            child: IndexedStack(
              index: nav.page.index,
              children: [
                const HomeScreen(),
                FavouritesScreen(active: nav.page == AppPage.saved),
                PostItemScreen(key: ValueKey(nav.editingItem?.id ?? 0), editing: nav.editingItem),
                OrdersScreen(active: nav.page == AppPage.orders),
                MessagesScreen(active: nav.page == AppPage.inbox),
                const ProfileScreen(),
                ItemDetailsScreen(key: ValueKey(nav.selectedItem?.id ?? 0), item: nav.selectedItem),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
