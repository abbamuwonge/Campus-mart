import 'package:flutter/material.dart';

import '../theme.dart';
import 'app_button.dart';

/// Spinner shown while a list loads.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
    );
  }
}

/// Error text with a Retry button (for example when the server is off).
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 12),
          AppButton(label: 'Retry', secondary: true, onPressed: onRetry),
        ],
      ),
    );
  }
}

/// Grey text for empty lists, like the prototype's `<p class="muted">`.
class EmptyMessage extends StatelessWidget {
  const EmptyMessage(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(text, style: const TextStyle(color: AppColors.muted)),
    );
  }
}
