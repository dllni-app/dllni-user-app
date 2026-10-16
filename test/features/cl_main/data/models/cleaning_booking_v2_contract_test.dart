import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cleaning_booking_v2_screen.dart';

void main() {
  test(
    'canonical response preserves signed quote schedule policy and real service IDs',
    () {
      final quote = EstimatePriceResponseModel.fromJson({
        'quoteId': 'quote.one',
        'quoteSignature': 'signed',
        'quoteExpiresAt': '2026-10-20T12:00:00+03:00',
        'visits': [
          {'visitKey': 'visit.1', 'roomSchedules': [], 'timePeriods': []},
        ],
        'schedulingPolicy': {'minimumWorkers': 1, 'maximumWorkers': 20},
        'specialServicesCatalog': [
          {
            'specialServiceId': 8,
            'name': 'تنظيف الكنب',
            'unitCode': 'seat',
            'supportsDirtiness': true,
          },
        ],
        'materialsPreview': [
          {'materialTypeId': 4, 'name': 'منظف الأرضيات'},
        ],
        'pricing': {
          'totalPrice': 350,
          'currency': 'SYP',
          'isPricingFinal': true,
        },
      });
      expect(quote.quoteId, 'quote.one');
      expect(quote.quoteExpiresAt?.toUtc(), DateTime.utc(2026, 10, 20, 9));
      expect(quote.visits.single['visitKey'], 'visit.1');
      expect(quote.schedulingPolicy['maximumWorkers'], 20);
      final service = CleaningServiceModel.fromJson(
        quote.specialServicesCatalog.single,
      );
      expect(service.id, 8);
      expect(service.unitCode, 'seat');
      expect(quote.availableMaterials.single.materialTypeId, 4);
      expect(quote.pricing?.totalPrice, 350);
      expect(CleaningBookingV2Screen, isNotNull);
    },
  );
}
