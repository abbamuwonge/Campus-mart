import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brand.dart';

/// Shown for a moment at start-up while the app checks whether a saved login is still valid.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Brand(),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}
