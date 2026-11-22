import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Holds who is logged in. The screens read it; the AuthGate in main.dart switches screens when it changes.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service, ApiClient api) {
    api.onUnauthorized = _onTokenRejected;
  }

  final AuthService _service;

  AuthStatus status = AuthStatus.unknown;
  User? user;

  /// Runs once at start-up.
  Future<void> restore() async {
    try {
      user = await _service.restoreSession();
      status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    } on ApiException {
      // Server unreachable: show the login screen. The saved token is kept for the next start.
      user = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Throws [ApiException] on failure so the screen can show the message.
  Future<void> login(String email, String password) async {
    user = await _service.login(email, password);
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String campus,
    required String password,
  }) async {
    await _service.register(
      fullName: fullName,
      email: email,
      phone: phone,
      campus: campus,
      password: password,
    );
    await login(email, password);
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// After the profile is edited.
  void setUser(User updated) {
    user = updated;
    notifyListeners();
  }

  void _onTokenRejected() {
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
