import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brand.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// The prototype's sign-in page. "Create account" and "Sign in" swap the two forms in place.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Brand(),
                  const SizedBox(height: 14),
                  const Text(
                    'Buy · Sell · Connect — Across Universities',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  if (_showRegister)
                    RegisterScreen(onShowLogin: () => setState(() => _showRegister = false))
                  else
                    LoginScreen(onShowRegister: () => setState(() => _showRegister = true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
