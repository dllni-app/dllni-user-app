import 'package:dllni_user_app/features/cl_main/data/models/cleaning_banners_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningBannersResponseModel parsing', () {
    test('parses contract response with camelCase keys', () {
      final model = cleaningBannersResponseModelFromJson(<String, dynamic>{
        'banners': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'title': 'Spring cleaning offer',
            'subtitle': 'Get 20% off your first deep clean',
            'imageUrl':
                'https://dllni.mustafafares.com/storage/cleaning-banners/spring-cleaning.jpg',
            'targetUrl':
                'https://dllni.mustafafares.com/cleaning/offers/1',
            'sortOrder': 1,
            'isActive': true,
            'startsAt': '2026-06-01T00:00:00+03:00',
            'endsAt': '2026-06-30T23:59:59+03:00',
          },
        ],
      });

      expect(model.banners, hasLength(1));
      final banner = model.banners.first;
      expect(banner.id, 1);
      expect(banner.title, 'Spring cleaning offer');
      expect(banner.subtitle, 'Get 20% off your first deep clean');
      expect(
        banner.imageUrl,
        'https://dllni.mustafafares.com/storage/cleaning-banners/spring-cleaning.jpg',
      );
      expect(
        banner.targetUrl,
        'https://dllni.mustafafares.com/cleaning/offers/1',
      );
      expect(banner.sortOrder, 1);
      expect(banner.isActive, isTrue);
      expect(banner.startsAt, DateTime.parse('2026-06-01T00:00:00+03:00'));
      expect(banner.endsAt, DateTime.parse('2026-06-30T23:59:59+03:00'));
    });

    test('parses snake_case keys and numeric bool values', () {
      final model = cleaningBannersResponseModelFromJson(<String, dynamic>{
        'banners': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '2',
            'title': 'Deep clean',
            'subtitle': null,
            'image_url': 'https://example.com/banner.jpg',
            'target_url': 'https://example.com/offers/2',
            'sort_order': '3',
            'is_active': 1,
            'starts_at': '2026-06-01T00:00:00Z',
            'ends_at': '2026-06-30T23:59:59Z',
          },
        ],
      });

      final banner = model.banners.first;
      expect(banner.id, 2);
      expect(banner.subtitle, isNull);
      expect(banner.imageUrl, 'https://example.com/banner.jpg');
      expect(banner.targetUrl, 'https://example.com/offers/2');
      expect(banner.sortOrder, 3);
      expect(banner.isActive, isTrue);
    });

    test('returns empty banners list when key is missing', () {
      final model = cleaningBannersResponseModelFromJson(<String, dynamic>{});

      expect(model.banners, isEmpty);
    });
  });
}
