import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningServiceExtrasRequest', () {
    test('serializes the canonical cleaning extras request', () {
      const request = CleaningServiceExtrasRequest(
        requestMaterials: true,
        specialServices: <CleaningSpecialServiceRequest>[
          CleaningSpecialServiceRequest(
            specialServiceId: 12,
            quantity: 3,
            dirtinessLevel: 'heavy',
            notes: '  focus on edges  ',
          ),
        ],
        openTime: CleaningOpenTimeRequest(workerCount: 2),
      );

      expect(request.toJson(), <String, dynamic>{
        'requestMaterials': true,
        'specialServices': <Map<String, dynamic>>[
          <String, dynamic>{
            'specialServiceId': 12,
            'quantity': 3,
            'dirtinessLevel': 'heavy',
            'notes': 'focus on edges',
          },
        ],
        'openTime': <String, dynamic>{'workerCount': 2},
      });
    });
  });

  group('cleaning extras response parsing', () {
    test('parses canonical material and special-service snapshots', () {
      final materials = cleaningMaterialLinesFromJson(<Map<String, dynamic>>[
        <String, dynamic>{
          'materialId': 7,
          'name': 'Floor cleaner',
          'quantity': 1.5,
          'unitCode': 'liter',
          'unitPrice': 25,
          'totalPrice': 37.5,
        },
      ]);
      final services = cleaningSpecialServiceLinesFromJson(
        <Map<String, dynamic>>[
          <String, dynamic>{
            'serviceId': 5,
            'name': 'Sofa cleaning',
            'quantity': 2,
            'pricingUnit': 'sofa',
            'dirtinessLevel': 'medium',
            'dirtinessLabel': 'Medium',
            'totalPrice': 180,
            'image': 'https://example.test/sofa.png',
            'notes': 'Pet hair',
          },
        ],
      );

      expect(materials, hasLength(1));
      expect(materials.single.materialId, 7);
      expect(materials.single.quantity, 1.5);
      expect(materials.single.unit, 'liter');
      expect(materials.single.totalPrice, 37.5);
      expect(services, hasLength(1));
      expect(services.single.specialServiceId, 5);
      expect(services.single.pricingUnit, 'sofa');
      expect(services.single.dirtinessLevel, 'medium');
      expect(services.single.totalPrice, 180);
      expect(services.single.imageUrl, 'https://example.test/sofa.png');
    });

    test('parses canonical Open-Time final billing fields as UI hours', () {
      final openTime = CleaningOpenTimeModel.fromJson(<String, dynamic>{
        'requestedWorkerCount': 2,
        'hourlyRate': 200,
        'minimumBillableMinutes': 60,
        'actualDurationMinutes': 61,
        'billableDurationMinutes': 90,
        'finalAmount': 600,
        'isFinalized': true,
      });

      expect(openTime.workerCount, 2);
      expect(openTime.hourlyRate, 200);
      expect(openTime.minimumDuration, 1);
      expect(openTime.actualDuration, 1.02);
      expect(openTime.billableDuration, 1.5);
      expect(openTime.totalPrice, 600);
      expect(openTime.isPricingFinal, isTrue);
    });

    test('parses preliminary Open-Time billing fields', () {
      final openTime = CleaningOpenTimeModel.fromJson(<String, dynamic>{
        'requestedWorkerCount': 1,
        'hourlyRate': 100,
        'minimumBillableMinutes': 60,
        'preliminaryBillableMinutes': 60,
        'preliminaryAmount': 100,
      });

      expect(openTime.workerCount, 1);
      expect(openTime.minimumDuration, 1);
      expect(openTime.billableDuration, 1);
      expect(openTime.totalPrice, 100);
    });
  });
}
