/// App-wide settings.
///
/// The API address is set when you run the app, so nobody edits code to switch between
/// the emulator, Chrome and a real phone:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.23:8000
///
/// Default (no flag): the Android emulator's address for the laptop.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
