import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

/// Thrown for every failed request. [status] is 0 when the server could not be reached.
class ApiException implements Exception {
  ApiException(this.status, this.message);

  final int status;
  final String message;

  bool get isNetworkError => status == 0;

  @override
  String toString() => message;
}

/// The only place that talks HTTP. Screens never call `http` directly:
/// they use the services (item_service.dart, order_service.dart, ...), which use this class.
class ApiClient {
  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const Duration _timeout = Duration(seconds: 15);

  final FlutterSecureStorage _storage;

  /// Called when the server rejects a saved token (expired or invalid), so the app can go back to login.
  void Function()? onUnauthorized;

  Future<String?> get token => _storage.read(key: _tokenKey);
  Future<void> saveToken(String value) => _storage.write(key: _tokenKey, value: value);

  /// Logging out only has to clear the token from the phone.
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  /// Full address of an uploaded photo, from the `image_url` the API returns (or null if there is none).
  static String? imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '${AppConfig.apiBaseUrl}$path';
  }

  Future<dynamic> get(String path) => request('GET', path);
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) => request('POST', path, body: body);
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) => request('PUT', path, body: body);
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) => request('PATCH', path, body: body);
  Future<dynamic> delete(String path) => request('DELETE', path);

  /// Sends one JSON request. Returns the decoded JSON, or throws [ApiException].
  Future<dynamic> request(String method, String path, {Map<String, dynamic>? body}) async {
    final savedToken = await token;
    final req = http.Request(method, Uri.parse('${AppConfig.apiBaseUrl}$path'));
    req.headers['Content-Type'] = 'application/json';
    if (savedToken != null) {
      req.headers['Authorization'] = 'Bearer $savedToken'; // sent with every request
    }
    if (body != null) {
      req.body = jsonEncode(body);
    }
    return _send(req, savedToken, _timeout);
  }

  /// Uploads a photo (multipart form with a field called `file`), e.g. POST /items/{id}/image.
  Future<dynamic> upload(String path, String filePath, {String field = 'file'}) async {
    final savedToken = await token;
    final req = http.MultipartRequest('POST', Uri.parse('${AppConfig.apiBaseUrl}$path'));
    if (savedToken != null) {
      req.headers['Authorization'] = 'Bearer $savedToken';
    }
    req.files.add(await http.MultipartFile.fromPath(field, filePath));
    return _send(req, savedToken, const Duration(seconds: 60));
  }

  Future<dynamic> _send(http.BaseRequest req, String? savedToken, Duration timeout) async {
    final http.Response res;
    try {
      final streamed = await req.send().timeout(timeout);
      res = await http.Response.fromStream(streamed);
    } catch (error) {
      // The reason (refused, timed out, cleartext blocked...) shows in the terminal while developing.
      debugPrint('API request to ${req.url} failed: $error');
      throw ApiException(0, 'Cannot reach the server. Check your connection and try again.');
    }

    dynamic data;
    if (res.body.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    if (res.statusCode == 401 && savedToken != null) {
      await clearToken();
      onUnauthorized?.call();
    }
    throw ApiException(res.statusCode, _messageFrom(data, res.statusCode));
  }

  /// Turns the API's error body into one readable sentence.
  /// Validation errors look like {"detail": "Validation failed", "errors": [{"field", "message"}]}.
  String _messageFrom(dynamic data, int status) {
    if (data is Map) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final first = errors.first as Map;
        final field = first['field']?.toString() ?? '';
        final message = first['message']?.toString() ?? 'Invalid input';
        return field.isEmpty ? message : '$field: $message';
      }
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
    }
    return 'Something went wrong (error $status). Please try again.';
  }
}
