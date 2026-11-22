import '../models/user.dart';
import 'api_client.dart';

/// Register, log in and log out. Talks to /auth/* on the backend.
class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  /// POST /auth/login. Saves the token on the phone and returns the user.
  Future<User> login(String email, String password) async {
    final data = await _api.post('/auth/login', body: {
      'email': email.trim(),
      'password': password,
    }) as Map<String, dynamic>;
    await _api.saveToken(data['access_token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// POST /auth/register. The backend returns the new user but no token, so the caller logs in next.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String campus,
    required String password,
  }) async {
    await _api.post('/auth/register', body: {
      'full_name': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'campus': campus.trim(),
      'password': password,
    });
  }

  /// On app start: if a token is saved, ask the server who it belongs to (GET /auth/me).
  /// Returns null when there is no token or the token is no longer valid.
  Future<User?> restoreSession() async {
    if (await _api.token == null) return null;
    try {
      final data = await _api.get('/auth/me') as Map<String, dynamic>;
      return User.fromJson(data);
    } on ApiException catch (e) {
      if (e.status == 401) return null;
      rethrow;
    }
  }

  Future<void> logout() => _api.clearToken();
}
