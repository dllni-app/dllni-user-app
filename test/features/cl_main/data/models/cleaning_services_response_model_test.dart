import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningServiceModel dirtiness configuration', () {
    test('parses active server rules and ignores inactive rules', () {
      final response = CleaningServicesResponseModel.fromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 17,
            'name': 'Deep sofa cleaning',
            'category': 'special_service',
            'image': 'https://example.test/sofa.png',
            'pricingUnit': 'seat',
            'baseUnitPrice': 2500,
            'dirtinessRules': <Map<String, dynamic>>[
              <String, dynamic>{
                'level': 'normal',
                'priceMultiplier': 1.0,
                'isActive': true,
              },
              <String, dynamic>{
                'level': 'deep',
                'priceMultiplier': 1.5,
                'isActive': true,
              },
              <String, dynamic>{
                'level': 'legacy',
                'priceMultiplier': 2.0,
                'isActive': false,
              },
            ],
            'equipment': <Map<String, dynamic>>[
              <String, dynamic>{'id': 4, 'name': 'Steam extractor'},
            ],
          },
        ],
      });

      final service = response.data.single;

      expect(service.id, 17);
      expect(service.pricingUnit, 'seat');
      expect(service.baseUnitPrice, 2500);
      expect(service.selectableDirtinessLevels, <String>['normal', 'deep']);
      expect(service.equipment.single.name, 'Steam extractor');
    });

    test('keeps a valid server level and normalizes an invalid level', () {
      const service = CleaningServiceModel(
        dirtinessRules: <CleaningServiceDirtinessRuleModel>[
          CleaningServiceDirtinessRuleModel(level: 'normal'),
          CleaningServiceDirtinessRuleModel(level: 'deep'),
        ],
      );

      expect(service.normalizeDirtinessLevel('deep'), 'deep');
      expect(service.normalizeDirtinessLevel('medium'), 'normal');
    });

    test('uses the legacy three-level fallback only when server has no rules', () {
      const service = CleaningServiceModel();

      expect(
        service.selectableDirtinessLevels,
        cleaningServiceFallbackDirtinessLevels,
      );
      expect(service.normalizeDirtinessLevel('medium'), 'medium');
      expect(service.normalizeDirtinessLevel('unknown'), 'medium');
    });

    test('deduplicates repeated server levels while preserving order', () {
      const service = CleaningServiceModel(
        dirtinessRules: <CleaningServiceDirtinessRuleModel>[
          CleaningServiceDirtinessRuleModel(level: 'deep'),
          CleaningServiceDirtinessRuleModel(level: 'deep'),
          CleaningServiceDirtinessRuleModel(level: 'extreme'),
        ],
      );

      expect(service.selectableDirtinessLevels, <String>['deep', 'extreme']);
    });
  });
}
