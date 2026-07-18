import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClMainOccasionOption', () {
    test('maps canonical birthday value to the existing birthday flow', () {
      const option = ClMainOccasionOption(
        id: 'graduation_party',
        bookingValue: 'birthday',
        title: 'حفلة تخرج',
        imagePath: 'https://example.com/graduation.jpg',
      );

      expect(option.id, 'birthday_party');
      expect(option.bookingValue, 'birthday');
    });

    test('maps canonical funeral value to the existing condolences flow', () {
      const option = ClMainOccasionOption(
        id: 'memorial_service',
        bookingValue: 'funeral',
        title: 'عزاء',
        imagePath: 'https://example.com/funeral.jpg',
      );

      expect(option.id, 'condolences');
      expect(option.bookingValue, 'funeral');
    });

    test('keeps existing occasion ids backward compatible', () {
      const option = ClMainOccasionOption(
        id: 'family_dinner',
        title: 'عشاء عائلي',
        imagePath: 'assets/images/family_dinner.png',
      );

      expect(option.id, 'family_dinner');
      expect(option.bookingValue, 'family_dinner');
    });
  });
}
