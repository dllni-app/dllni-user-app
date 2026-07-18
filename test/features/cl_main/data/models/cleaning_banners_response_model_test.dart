import 'package:dllni_user_app/features/cl_main/data/models/cleaning_banners_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningBannersResponseModel parsing', () {
    test('parses cleaning home content with camelCase keys', () {
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
        'propertyTypes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 10,
            'section': 'property',
            'code': 'villa',
            'contentCode': 'villa_duplex',
            'value': 'villa',
            'title': 'فيلا دوبلكس',
            'imageUrl': 'https://example.com/villa.jpg',
            'sortOrder': 10,
          },
        ],
        'occasionTypes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 20,
            'section': 'occasion',
            'code': 'birthday_party',
            'contentCode': 'kids_birthday',
            'value': 'birthday',
            'title': 'حفلة عيد ميلاد',
            'imageUrl': 'https://example.com/birthday.jpg',
            'sortOrder': 20,
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

      expect(model.propertyTypes, hasLength(1));
      expect(model.propertyTypes.first.code, 'villa');
      expect(model.propertyTypes.first.contentCode, 'villa_duplex');
      expect(model.propertyTypes.first.value, 'villa');
      expect(model.propertyTypes.first.title, 'فيلا دوبلكس');
      expect(model.propertyTypes.first.imageUrl, 'https://example.com/villa.jpg');

      expect(model.occasionTypes, hasLength(1));
      expect(model.occasionTypes.first.code, 'birthday_party');
      expect(model.occasionTypes.first.value, 'birthday');
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
        'property_types': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '3',
            'section': 'property',
            'code': 'office',
            'content_code': 'office_card',
            'booking_value': 'office',
            'title': 'مكتب',
            'image_url': 'https://example.com/office.jpg',
            'sort_order': '2',
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

      expect(model.propertyTypes.first.id, 3);
      expect(model.propertyTypes.first.contentCode, 'office_card');
      expect(model.propertyTypes.first.value, 'office');
      expect(model.propertyTypes.first.sortOrder, 2);
    });

    test('returns empty content lists when keys are missing', () {
      final model = cleaningBannersResponseModelFromJson(<String, dynamic>{});

      expect(model.banners, isEmpty);
      expect(model.propertyTypes, isEmpty);
      expect(model.occasionTypes, isEmpty);
    });
  });
}
