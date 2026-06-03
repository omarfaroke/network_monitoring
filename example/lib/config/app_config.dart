import 'dart:io';

/// Demo credentials and API settings for the local server.
abstract class AppConfig {
  static const appName = 'Notes Demo';
  static const devModePassword = '123456';
  static const devModeRequiredTaps = 6;

  /// Static login (pre-filled on the login screen).
  static const defaultUsername = 'demo';
  static const defaultPassword = 'password';

  static const serverPort = 8765;
  static const jwtSecret = 'notes-example-jwt-secret';

  /// Persisted in-memory notes cache for the local server.
  static const notesCacheKey = 'notes_cache_v1';

  /// Supported targets for this example.
  static bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;

  /// Local API base URL (server runs in the same app process on the device).
  static String get apiBaseUrl => 'http://127.0.0.1:$serverPort';
}
