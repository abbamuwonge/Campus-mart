import 'package:flutter/material.dart';

import '../theme.dart';

/// The prototype's `.row`: content on the left, something small on the right, a line underneath.
class AppRow extends StatelessWidget {
  const AppRow({super.key, required this.child, this.trailing, this.last = false, this.onTap});

  final Widget child;
  final Widget? trailing;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: content);
  }
}
