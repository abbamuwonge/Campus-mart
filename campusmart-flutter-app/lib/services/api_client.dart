import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

/// Thrown for every failed request.
/// [status] is 0 when the server could not be reached.
class ApiException implements Exception {
  ApiException(this.status, this.message);

  final int status;
  final String message;

  bool get isNetworkError => status == 0;

  @override
  String toString() => message;
}

/// The only place that talks HTTP.
/// Screens use services such as item_service.dart,
/// order_service.dart, and others.
class ApiClient {
  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const Duration _timeout = Duration(seconds: 15);

  final FlutterSecureStorage _storage;

  /// Called when the server rejects a saved token.
  void Function()? onUnauthorized;

  Future<String?> get token => _storage.read(key: _tokenKey);

  Future<void> saveToken(String value) =>
      _storage.write(key: _tokenKey, value: value);

  /// Clears the saved login token.
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  /// Converts an image path returned by the API into a usable URL.
  ///
  /// Supports:
  /// 1. Full Supabase URLs.
  /// 2. Other absolute image URLs.
  /// 3. Older relative backend paths such as /uploads/image.jpg.
  static String? imageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final imagePath = path.trim();
    final uri = Uri.tryParse(imagePath);

    // Use complete URLs directly without adding the Render API address.
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority) {
      return imagePath;
    }

    // Preserve support for older backend-hosted images.
    return '${AppConfig.apiBaseUrl}$imagePath';
  }

  Future<dynamic> get(String path) => request('GET', path);

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      request('POST', path, body: body);

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      request('PUT', path, body: body);

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      request('PATCH', path, body: body);

  Future<dynamic> delete(String path) => request('DELETE', path);

  /// Sends a JSON request and returns the decoded response.
  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final savedToken = await token;

    final req = http.Request(
      method,
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
    );

    req.headers['Content-Type'] = 'application/json';

    if (savedToken != null) {
      req.headers['Authorization'] = 'Bearer $savedToken';
    }

    if (body != null) {
      req.body = jsonEncode(body);
    }

    return _send(req, savedToken, _timeout);
  }

  /// Uploads a photo using multipart form data.
  /// The default field name is "file".
  Future<dynamic> upload(
    String path,
    String filePath, {
    String field = 'file',
  }) async {
    final savedToken = await token;

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
    );

    if (savedToken != null) {
      req.headers['Authorization'] = 'Bearer $savedToken';
    }

    req.files.add(
      await http.MultipartFile.fromPath(field, filePath),
    );

    return _send(
      req,
      savedToken,
      const Duration(seconds: 60),
    );
  }

  /// Sends the request and handles the HTTP response.
  Future<dynamic> _send(
    http.BaseRequest req,
    String? savedToken,
    Duration timeout,
  ) async {
    final http.Response res;

    try {
      final streamed = await req.send().timeout(timeout);
      res = await http.Response.fromStream(streamed);
    } catch (error) {
      debugPrint('API request to ${req.url} failed: $error');

      throw ApiException(
        0,
        'Cannot reach the server. Check your connection and try again.',
      );
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

    throw ApiException(
      res.statusCode,
      _messageFrom(data, res.statusCode),
    );
  }

  /// Converts the API error response into a readable message.
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

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    }

    return 'Something went wrong (error $status). Please try again.';
  }
}
