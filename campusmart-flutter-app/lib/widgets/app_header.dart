import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/nav_provider.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'brand.dart';

/// The prototype's sticky header: logo, message and profile buttons, greeting.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final nav = context.read<NavProvider>();
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16 + top, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        border: Border(bottom: BorderSide(color: AppColors.headerLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Brand(),
              Row(
                children: [
                  _IconButton(icon: Icons.mail_outline, size: 18, tooltip: 'Messages', onTap: () => nav.go(AppPage.inbox)),
                  const SizedBox(width: 9),
                  _IconButton(icon: Icons.circle, size: 12, tooltip: 'Profile', onTap: () => nav.go(AppPage.profile)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            user == null ? 'Find what you need on campus 👋' : 'Welcome, ${firstName(user.fullName)} 👋',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          const Text(
            'Buy · Sell · Connect — Across Universities',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.size, required this.tooltip, required this.onTap});

  final IconData icon;
  final double size;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: size, color: Colors.white),
        ),
      ),
    );
  }
}
