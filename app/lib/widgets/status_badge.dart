import 'package:flutter/material.dart';

import '../theme.dart';

/// The prototype's `.badge` (Pending, Published...).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, color: AppColors.badgeText)),
    );
  }
}
