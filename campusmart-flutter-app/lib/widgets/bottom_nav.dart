import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nav_provider.dart';
import '../providers/message_notification_provider.dart';
import '../theme.dart';
import '../utils/auth_guard.dart';

class _NavItem {
  const _NavItem(this.page, this.icon, this.label, this.iconSize);

  final AppPage page;
  final IconData icon;
  final String label;
  final double iconSize;
}

/// The prototype's bottom bar: Home, Saved, Sell, Orders, Inbox, Account.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  static const List<_NavItem> _items = [
    _NavItem(AppPage.home, Icons.home_outlined, 'Home', 22),
    _NavItem(AppPage.saved, Icons.favorite_border, 'Saved', 22),
    _NavItem(AppPage.sell, Icons.add, 'Sell', 22),
    _NavItem(AppPage.orders, Icons.list_alt, 'Orders', 22),
    _NavItem(AppPage.inbox, Icons.mail_outline, 'Inbox', 22),
    _NavItem(AppPage.profile, Icons.circle, 'Account', 13),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    final unread = context.watch<MessageNotificationProvider>().unreadCount;
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 69 + bottom,
      padding: EdgeInsets.fromLTRB(3, 7, 3, 7 + bottom),
      decoration: BoxDecoration(
        color: AppColors.navBg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in _items)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (item.page == AppPage.home) {
                  nav.go(AppPage.home);
                } else {
                  requireAuth(context, () => nav.go(item.page));
                }
              },
              child: SizedBox(
                width: 52,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: item.iconSize,
                            color: nav.page == item.page
                                ? AppColors.orange
                                : AppColors.navInactive,
                          ),
                          if (item.page == AppPage.inbox && unread > 0)
                            Positioned(
                              right: -13,
                              top: -7,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                constraints: const BoxConstraints(
                                    minWidth: 16, minHeight: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: nav.page == item.page
                            ? AppColors.orange
                            : AppColors.navInactive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
