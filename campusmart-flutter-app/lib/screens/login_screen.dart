import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';

/// The "Welcome back" form (shown inside AuthScreen).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onShowRegister});

  final VoidCallback onShowRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty || _password.text.isEmpty) {
      showToast('Enter your email and password');
      return;
    }
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      await auth.login(email, _password.text);
      showToast('Signed in successfully');
      // The AuthGate in main.dart now replaces this screen with the marketplace.
    } on ApiException catch (e) {
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 36),
        const Text('Welcome back', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        const Text('Sign in to your student marketplace.', style: TextStyle(color: AppColors.muted)),
        AppTextField(
          controller: _email,
          label: 'Email address',
          hint: 'student@university.ac.ug',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          margin: const EdgeInsets.symmetric(vertical: 15),
        ),
        AppTextField(
          controller: _password,
          label: 'Password',
          hint: 'Your password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          margin: const EdgeInsets.symmetric(vertical: 15),
        ),
        AppButton(label: 'Sign in', full: true, loading: _loading, onPressed: _submit),
        const SizedBox(height: 20),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text('New to CampusMart? '),
              GestureDetector(
                onTap: _loading ? null : widget.onShowRegister,
                child: const Text('Create account', style: TextStyle(color: AppColors.orange2)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
