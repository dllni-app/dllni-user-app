import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/features/orders/view/widgets/restaurant_order_tracking_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restaurant order timeline uses shared design tokens', () {
    expect(RestaurantOrderTrackingColors.primary, SharedPlatformColors.primary);
    expect(RestaurantOrderTrackingColors.accent, SharedPlatformColors.restaurant);
    expect(RestaurantOrderTrackingColors.grey, SharedPlatformColors.neutral);
    expect(RestaurantOrderTrackingColors.lineMuted, SharedPlatformColors.border);
    expect(RestaurantOrderTrackingColors.primary, isNot(RestaurantOrderTrackingColors.accent));
  });
}
