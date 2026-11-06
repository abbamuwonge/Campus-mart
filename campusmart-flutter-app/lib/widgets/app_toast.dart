import 'package:flutter/material.dart';

import '../theme.dart';

/// Lets any code show a toast without a BuildContext. Passed to MaterialApp in main.dart.
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

/// The prototype's small dark message that appears above the bottom bar for about two seconds.
void showToast(String message) {
  final messenger = messengerKey.currentState;
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: AppColors.toastBg,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      duration: const Duration(milliseconds: 2200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.toastLine),
      ),
    ),
  );
}
