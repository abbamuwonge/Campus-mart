import 'package:flutter/material.dart';

import '../theme.dart';

/// The prototype's `.btn` (orange) and `.btn.secondary` (dark with a border). Use [full] for `.btn.full`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.full = false,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool full;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = secondary ? Colors.white : AppColors.btnText;
    final Widget content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 16, color: foreground),
              if (icon != null && label.isNotEmpty) const SizedBox(width: 6),
              if (label.isNotEmpty)
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: foreground, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
            ],
          );

    final button = Material(
      color: secondary ? AppColors.surface2 : AppColors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: secondary ? const BorderSide(color: AppColors.line) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: loading ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          child: full ? Center(child: content) : content,
        ),
      ),
    );
    return full ? SizedBox(width: double.infinity, child: button) : button;
  }
}
