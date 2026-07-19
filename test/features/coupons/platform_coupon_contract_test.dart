import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/check_restaurant_coupon_use_case.dart';
import 'package:dllni_user_app/features/orders/view/manager/bloc/merchant_checkout_coupon_bloc_extension.dart';
import 'package:dllni_user_app/features/profile/data/models/platform_coupon_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('platform coupon API contracts', () {
    test('coupon check includes explicit cart and cleaning context', () {
      final params = CheckRestaurantCouponParams(
        couponCode: ' save20 ',
        section: 'cleaning',
        cartId: 91,
        propertyType: 'villa',
        propertyDetails: const <String, dynamic>{
          'cleaning_mode': 'deep',
        },
        addressLatitude: 33.51,
        addressLongitude: 36.29,
        preferredWorkerId: 7,
      );

      expect(params.getBody(), <String, dynamic>{
        'section': 'cleaning',
        'couponCode': 'save20',
        'cartId': 91,
        'propertyType': 'villa',
        'propertyDetails': <String, dynamic>{
          'cleaning_mode': 'deep',
        },
        'addressLatitude': 33.51,
        'addressLongitude': 36.29,
        'preferredWorkerId': 7,
      });
    });

    test('restaurant checkout coupon targets the selected cart', () {
      final event = ApplyMerchantCartCouponEvent(
        cartId: 14,
        section: 'restaurant',
        couponCode: ' REST20 ',
      );
      final params = CheckRestaurantCouponParams(
        couponCode: event.couponCode,
        section: event.section,
        cartId: event.cartId,
      );

      expect(params.getBody(), <String, dynamic>{
        'section': 'restaurant',
        'couponCode': 'REST20',
        'cartId': 14,
      });
    });

    test('supermarket checkout coupon targets the selected cart', () {
      final event = ApplyMerchantCartCouponEvent(
        cartId: 29,
        section: 'supermarket',
        couponCode: ' MARKET15 ',
      );
      final params = CheckRestaurantCouponParams(
        couponCode: event.couponCode,
        section: event.section,
        cartId: event.cartId,
      );

      expect(params.getBody(), <String, dynamic>{
        'section': 'supermarket',
        'couponCode': 'MARKET15',
        'cartId': 29,
      });
    });

    test('regular cleaning order sends the accepted coupon code', () {
      const breakdown = CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 2),
        bathroom: CleaningRoomSizeBucket(small: 1),
        livingRoom: CleaningRoomSizeBucket(medium: 1),
      );
      final params = CreateCleaningOrderParams(
        addressId: 12,
        propertyType: 'villa',
        bedrooms: 2,
        rooms: 4,
        bathrooms: 1,
        livingRoomSize: 'medium',
        roomSizeBreakdown: breakdown,
        cleaningType: CleaningType.deepCleaning,
        address: 'Address line',
        locationName: 'Home',
        scheduledDate: '2026-07-21',
        scheduledTime: '09:00',
        addressLatitude: null,
        addressLongitude: null,
        genderPreference: CleaningGenderPreference.any,
        couponCode: ' DEEP25 ',
      );

      final body = params.getBody();
      expect(body['couponCode'], 'DEEP25');
      expect(body['propertyDetails']['cleaning_mode'], 'deep');
      expect(body['propertyDetails']['room_size_breakdown'], isNotEmpty);
    });

    test('event cleaning order sends coupon and event constraints', () {
      final params = CreateCleaningOrderParams.eventAssistance(
        addressId: 22,
        scheduledDate: '2026-07-22',
        scheduledTime: '18:00',
        eventType: 'birthday',
        guestCount: 40,
        venueType: 'villa',
        customService: 'Event assistance',
        hours: 4,
        couponCode: ' EVENT10 ',
      );

      final body = params.getBody();
      expect(body['couponCode'], 'EVENT10');
      expect(body['propertyType'], 'event_assistance');
      expect(body['propertyDetails']['eventType'], 'birthday');
    });

    test('unified coupon response parses section, limits, and restrictions', () {
      final response = fetchPlatformCouponsModelFromJson(<String, dynamic>{
        'coupons': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 8,
            'code': 'CLEAN20',
            'title': 'Cleaning discount',
            'description': 'For selected cleaning bookings',
            'section': 'cleaning',
            'discount': <String, dynamic>{
              'type': 'percentage',
              'value': 20,
              'maxAmount': 150,
            },
            'minOrderAmount': 300,
            'startsAt': '2026-07-19T10:00:00+00:00',
            'expiresAt': '2026-07-31T23:59:59+00:00',
            'appliesTo': <String, dynamic>{
              'propertyTypes': <String>['villa'],
              'cleaningModes': <String>['deep'],
              'eventTypes': <String>[],
            },
          },
        ],
      });

      final coupon = response.coupons.single as PlatformCouponModel;
      expect(coupon.code, 'CLEAN20');
      expect(coupon.section, 'cleaning');
      expect(coupon.discountType, 'percentage');
      expect(coupon.discountValue, 20);
      expect(coupon.maximumDiscountAmount, 150);
      expect(coupon.minimumOrderAmount, 300);
      expect(coupon.appliesTo.propertyTypes, <String>['villa']);
      expect(coupon.appliesTo.cleaningModes, <String>['deep']);
      expect(coupon.appliesToSection('cleaning'), isTrue);
      expect(coupon.appliesToSection('restaurant'), isFalse);
    });
  });
}
