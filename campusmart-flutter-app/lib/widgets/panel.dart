import 'package:flutter/material.dart';

import '../theme.dart';

/// The prototype's `.panel`: a rounded dark card.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.margin = const EdgeInsets.only(bottom: 12)});

  final Widget child;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
