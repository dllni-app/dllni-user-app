class AppConfig {
  const AppConfig._();

  static const String appName = 'My App';
  static const String orgIdentifier = 'com.dllni.userapp';
  static const String baseUrl = 'https://dllni.mustafafares.com';
  static const String privacyPolicyUrl = '$baseUrl/legal/user-app';
  static const String termsAndConditionsUrl = '$baseUrl/legal/user-app/terms';

  /// Pusher public key (same as Laravel `PUSHER_APP_KEY`). Override with
  /// `--dart-define=PUSHER_APP_KEY=...` or legacy `--dart-define=PUSHER_KEY=...`.
  /// Never put `PUSHER_APP_SECRET` in the mobile app.
  static const String pusherKey = String.fromEnvironment(
    'PUSHER_APP_KEY',
    defaultValue: String.fromEnvironment(
      'PUSHER_KEY',
      defaultValue: 'e85e7756c1171baaa471',
    ),
  );
  static const String pusherCluster = String.fromEnvironment(
    'PUSHER_APP_CLUSTER',
    defaultValue: String.fromEnvironment('PUSHER_CLUSTER', defaultValue: 'eu'),
  );

  static const String pusherAppId = String.fromEnvironment(
    'PUSHER_APP_ID',
    defaultValue: '2120839',
  );

  static const String deepLinkCanonicalScheme = String.fromEnvironment(
    'DEEP_LINK_CANONICAL_SCHEME',
    defaultValue: 'https',
  );

  /// Dev builds generate links for the dev deployment by default. Production
  /// builds can override this with --dart-define or use their branch default.
  static const String deepLinkCanonicalHost = String.fromEnvironment(
    'DEEP_LINK_CANONICAL_HOST',
    defaultValue: 'dllni.mustafafares.com',
  );
}
