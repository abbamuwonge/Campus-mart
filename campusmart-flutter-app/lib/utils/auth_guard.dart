import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth_screen.dart';

/// Runs [action] for signed-in users, otherwise opens authentication first.
void requireAuth(BuildContext context, VoidCallback action) {
  if (context.read<AuthProvider>().status == AuthStatus.authenticated) {
    action();
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AuthScreen(
        onAuthenticated: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
