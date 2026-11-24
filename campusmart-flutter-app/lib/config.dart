/// App-wide settings.
///
/// The API address can be changed when building or running the app.
///
/// For local development:
///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
///
/// For production:
///   https://campus-mart-uqh5.onrender.com
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://campus-mart-uqh5.onrender.com',
  );
}
