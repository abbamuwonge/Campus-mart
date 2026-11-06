import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';
import '../widgets/panel.dart';
import '../widgets/section_title.dart';

/// "My account": the student's profile and sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _university;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _university = TextEditingController(text: user?.campus ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _university.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = Validators.fullName(_name.text) ??
        Validators.phone(_phone.text) ??
        Validators.campus(_university.text);
    if (problem != null) {
      showToast(problem);
      return;
    }
    FocusScope.of(context).unfocus();
    final users = context.read<UserService>();
    final auth = context.read<AuthProvider>();
    setState(() => _saving = true);
    try {
      final updated = await users.updateProfile(
        fullName: _name.text,
        phone: _phone.text,
        campus: _university.text,
      );
      auth.setUser(updated);
      _phone.text = updated.phone;
      showToast('Profile updated');
    } on ApiException catch (e) {
      showToast(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.fullName ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      children: [
        const SectionTitle('My account', 'Student profile'),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 53,
                    height: 53,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.avatarBg, shape: BoxShape.circle),
                    child: Text(
                      initials(name),
                      style: const TextStyle(color: AppColors.avatarText, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(user?.email ?? '', style: const TextStyle(color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AppTextField(controller: _name, label: 'Full name'),
              AppTextField(controller: _phone, label: 'Phone number', hint: '+256...', keyboardType: TextInputType.phone),
              AppTextField(controller: _university, label: 'University'),
              const SizedBox(height: 4),
              AppButton(label: 'Save changes', full: true, loading: _saving, onPressed: _save),
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('About CampusMart', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text(
                'A marketplace for students to buy, sell and connect across universities.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Help & assistance',
                full: true,
                secondary: true,
                onPressed: () => showToast('Help centre will be available in the full app.'),
              ),
              const SizedBox(height: 9),
              AppButton(
                label: 'Sign out',
                full: true,
                secondary: true,
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
