import 'package:dllni_user_app/features/orders/data/models/cleaning_worker_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FetchCleaningWorkerProfileModel parsing', () {
    test('parses full profile payload', () {
      final model = fetchCleaningWorkerProfileModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': 12,
          'userId': 44,
          'firstName': 'Ahmad',
          'gender': 'male',
          'avatar': <String, dynamic>{
            'id': 201,
            'url': 'https://example.com/storage/avatar.jpg',
            'mimeType': 'image/jpeg',
            'size': 183421,
          },
          'bio': 'Experienced cleaning specialist',
          'averageRating': 4.8,
          'totalCompletedJobs': 126,
          'trustScore': 92,
          'acceptanceRate': 97.5,
          'cancellationRate': 1.2,
          'openDisputesCount': 0,
          'isActive': true,
          'isSuspended': false,
          'suspendedUntil': null,
          'homeAddress': 'Damascus',
          'homeLatitude': 33.5138,
          'homeLongitude': 36.2765,
          'defaultWorkingHours': <String, dynamic>{
            'monday': <String, dynamic>{
              'available': true,
              'data': <dynamic>[
                <String, dynamic>{'09:00': '17:00'},
              ],
            },
          },
          'user': <String, dynamic>{
            'id': 44,
            'name': 'Ahmad Ali',
            'email': 'ahmad@example.com',
            'phone': '+9639xxxxxxx',
          },
          'zones': <dynamic>[
            <String, dynamic>{
              'id': 1,
              'worker_id': 12,
              'name': 'Mezzeh',
              'city': 'Damascus',
            },
          ],
          'availability': <dynamic>[
            <String, dynamic>{
              'id': 8,
              'worker_id': 12,
              'day': 'monday',
              'from': '09:00',
              'to': '17:00',
            },
          ],
          'trustLogs': <dynamic>[],
          'createdAt': '2026-05-10 14:20:31',
          'updatedAt': '2026-05-17 20:11:05',
        },
      });

      final profile = model.data;
      expect(profile, isNotNull);
      expect(profile!.id, 12);
      expect(profile.userId, 44);
      expect(profile.firstName, 'Ahmad');
      expect(profile.avatar?.url, 'https://example.com/storage/avatar.jpg');
      expect(profile.user?.name, 'Ahmad Ali');
      expect(profile.zones?.first.name, 'Mezzeh');
      expect(profile.availability?.first.day, 'monday');
      expect(
        profile.defaultWorkingHours?['monday']?.data?.first['09:00'],
        '17:00',
      );
      expect(profile.averageRating, 4.8);
      expect(profile.totalCompletedJobs, 126);
    });

    test('handles sparse or null fields safely', () {
      final model = fetchCleaningWorkerProfileModelFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'id': '22',
          'firstName': 'Sara',
          'avatar': null,
          'defaultWorkingHours': <String, dynamic>{
            'friday': <String, dynamic>{
              'available': false,
              'data': <dynamic>[],
            },
          },
        },
      });

      final profile = model.data;
      expect(profile, isNotNull);
      expect(profile!.id, 22);
      expect(profile.firstName, 'Sara');
      expect(profile.avatar, isNull);
      expect(profile.defaultWorkingHours?['friday']?.available, isFalse);
      expect(profile.defaultWorkingHours?['friday']?.data, isEmpty);
      expect(profile.user, isNull);
      expect(profile.zones, isNull);
    });
  });
}
