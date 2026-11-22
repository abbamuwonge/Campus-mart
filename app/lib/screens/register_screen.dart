import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';

/// The "Create account" form (shown inside AuthScreen).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onShowLogin});

  final VoidCallback onShowLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _university = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _university.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      showToast('Complete name, email and password');
      return;
    }
    // The backend also needs a valid email, university, phone number and an 8-character password.
    final problem = Validators.email(_email.text) ??
        Validators.campus(_university.text) ??
        Validators.phone(_phone.text) ??
        Validators.newPassword(_password.text);
    if (problem != null) {
      showToast(problem);
      return;
    }
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      await auth.register(
        fullName: _name.text,
        email: _email.text,
        phone: _phone.text,
        campus: _university.text,
        password: _password.text,
      );
      showToast('Account created');
    } on ApiException catch (e) {
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.symmetric(vertical: 15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 36),
        const Text('Create account', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        const Text('Join your campus marketplace.', style: TextStyle(color: AppColors.muted)),
        AppTextField(controller: _name, label: 'Full name', hint: 'Full name', textInputAction: TextInputAction.next, margin: margin),
        AppTextField(
          controller: _email,
          label: 'University email',
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          margin: margin,
        ),
        AppTextField(controller: _university, label: 'University', hint: 'University name', textInputAction: TextInputAction.next, margin: margin),
        AppTextField(
          controller: _phone,
          label: 'Phone number',
          hint: '+256...',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          margin: margin,
        ),
        AppTextField(
          controller: _password,
          label: 'Password',
          hint: 'Create password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          margin: margin,
        ),
        AppButton(label: 'Create account', full: true, loading: _loading, onPressed: _submit),
        const SizedBox(height: 14),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text('Already have an account? '),
              GestureDetector(
                onTap: _loading ? null : widget.onShowLogin,
                child: const Text('Sign in', style: TextStyle(color: AppColors.orange2)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
