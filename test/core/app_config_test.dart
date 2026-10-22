import 'package:dllni_user_app/core/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API URL defaults to deployed HTTPS endpoint in every build mode', () {
    // A developer may explicitly override the URL via --dart-define.
    const expectedUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dllni.mustafafares.com',
    );
    expect(AppConfig.baseUrl, expectedUrl);
  });
}
