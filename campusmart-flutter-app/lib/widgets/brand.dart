import 'package:flutter/material.dart';

import '../theme.dart';

/// "CampusMart" with the orange "Mart", as in the prototype.
class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -1, color: AppColors.text),
        children: [
          TextSpan(text: 'Campus'),
          TextSpan(text: 'Mart', style: TextStyle(color: AppColors.orange)),
        ],
      ),
    );
  }
}
