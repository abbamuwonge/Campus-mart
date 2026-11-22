import '../models/user.dart';
import 'api_client.dart';

class UserService {
  UserService(this._api);

  final ApiClient _api;

  /// PUT /users/me
  Future<User> updateProfile({
    required String fullName,
    required String phone,
    required String campus,
  }) async {
    final data = await _api.put('/users/me', body: {
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'campus': campus.trim(),
    });
    return User.fromJson(data as Map<String, dynamic>);
  }
}
