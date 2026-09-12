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
        'materials': <String, dynamic>{'providedByPlatform': true},
        'specialServices': <Map<String, dynamic>>[
          <String, dynamic>{
            'specialServiceId': 12,
            'quantity': 3,
            'dirtinessLevel': 'heavy',
            'notes': 'focus on edges',
          },
        ],
        'openTime': <String, dynamic>{
          'workerCount': 2,
          'expectedMaxMinutes': 480,
        },
      });
    });

    test('omits blank optional notes and open-time when not requested', () {
      const request = CleaningServiceExtrasRequest(
        specialServices: <CleaningSpecialServiceRequest>[
          CleaningSpecialServiceRequest(
            specialServiceId: 15,
            quantity: 1,
            dirtinessLevel: 'deep',
            notes: '   ',
          ),
        ],
      );

      final payload = request.toJson();
      final service =
          (payload['specialServices'] as List<dynamic>).single
              as Map<String, dynamic>;

      expect(payload['requestMaterials'], isFalse);
      expect(payload['materials'], <String, dynamic>{
        'providedByPlatform': false,
      });
      expect(payload.containsKey('openTime'), isFalse);
      expect(service.containsKey('notes'), isFalse);
      expect(service['dirtinessLevel'], 'deep');
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

    test('accepts snake-case aliases returned by persisted order payloads', () {
      final materials = cleaningMaterialLinesFromJson(<Map<String, dynamic>>[
        <String, dynamic>{
          'material_id': '9',
          'name': 'Glass cleaner',
          'quantity': '2.25',
          'unit_code': 'L',
          'unit_price': '50',
          'total_price': '112.5',
        },
      ]);
      final services = cleaningSpecialServiceLinesFromJson(
        <Map<String, dynamic>>[
          <String, dynamic>{
            'special_service_id': '17',
            'name': 'Carpet cleaning',
            'quantity': '3',
            'pricing_unit': 'carpet',
            'dirtiness_level': 'deep',
            'dirtiness_label': 'Deep',
            'total_price': '450',
            'image_url': 'https://example.test/carpet.png',
          },
        ],
      );

      expect(materials.single.materialId, 9);
      expect(materials.single.quantity, 2.25);
      expect(materials.single.unit, 'L');
      expect(materials.single.totalPrice, 112.5);
      expect(services.single.specialServiceId, 17);
      expect(services.single.quantity, 3);
      expect(services.single.pricingUnit, 'carpet');
      expect(services.single.dirtinessLevel, 'deep');
      expect(services.single.imageUrl, 'https://example.test/carpet.png');
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
        'isPricingFinal': false,
      });

      expect(openTime.workerCount, 1);
      expect(openTime.minimumDuration, 1);
      expect(openTime.billableDuration, 1);
      expect(openTime.totalPrice, 100);
      expect(openTime.isPricingFinal, isFalse);
    });

    test('serializes selected sessions and decimal special-service items', () {
      const request = CleaningServiceExtrasRequest(
        specialServices: <CleaningSpecialServiceRequest>[
          CleaningSpecialServiceRequest(
            specialServiceId: 4,
            sessionIds: <int>[2, 4],
            items: <CleaningSpecialServiceItemRequest>[
              CleaningSpecialServiceItemRequest(
                quantity: 2.75,
                dirtinessLevelId: 3,
                notes: 'بقعة جانبية',
                attachments: <String>['before/a.jpg'],
              ),
            ],
          ),
        ],
        openTime: CleaningOpenTimeRequest(
          workerCount: 2,
          expectedMaxMinutes: 240,
          sessions: <CleaningOpenTimeSessionRequest>[
            CleaningOpenTimeSessionRequest(date: '2026-09-12', time: '10:00'),
          ],
        ),
      );

      final payload = request.toJson();
      final special = (payload['specialServices'] as List).single as Map;
      final item = (special['items'] as List).single as Map;
      expect(special['sessionIds'], <int>[2, 4]);
      expect(item['quantity'], 2.75);
      expect(item['dirtinessLevelId'], 3);
      expect((payload['openTime'] as Map)['expectedMaxMinutes'], 240);
      expect((payload['openTime'] as Map)['sessions'], hasLength(1));
    });

    test('parses live Open-Time policy and pending extension', () {
      final openTime = cleaningOpenTimeEnvelopeFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'openTime': <String, dynamic>{
            'serverNow': '2026-09-09T10:00:00Z',
            'ceilingEndsAt': '2026-09-09T14:00:00Z',
            'expectedMaxMinutes': 240,
            'hardMaxMinutes': 480,
            'warningMinutes': 30,
            'extensionOptions': <int>[15, 30, 60],
            'remainingMinutes': 240,
            'liveAmount': 350,
            'liveBillableMinutes': 60,
            'endStatus': 'pending',
            'pendingExtension': <String, dynamic>{
              'id': 9,
              'requestedMinutes': 30,
              'status': 'pending',
            },
          },
        },
      });

      expect(openTime.expectedMaxMinutes, 240);
      expect(openTime.hardMaxMinutes, 480);
      expect(openTime.extensionOptions, <int>[15, 30, 60]);
      expect(openTime.pendingExtension?.id, 9);
      expect(openTime.liveAmount, 350);
    });
  });
}
