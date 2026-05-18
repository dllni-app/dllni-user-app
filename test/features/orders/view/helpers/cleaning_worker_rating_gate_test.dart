import 'package:common_package/helpers/error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_worker_profile_model.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_worker_rating_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveCleaningWorkerProfileForRating', () {
    test('returns worker profile when fetch succeeds', () async {
      final messages = <String>[];
      final profile = await resolveCleaningWorkerProfileForRating(
        workerId: 77,
        fetchWorkerProfile: (_) async => Right(
          const FetchCleaningWorkerProfileModel(
            data: CleaningWorkerProfileModel(
              id: 77,
              firstName: 'Ahmad',
              user: CleaningWorkerUserModel(name: 'Ahmad Ali'),
              avatar: CleaningWorkerAvatarModel(url: 'https://img'),
            ),
          ),
        ),
        onError: messages.add,
      );

      expect(profile, isNotNull);
      expect(profile!.id, 77);
      expect(profile.user?.name, 'Ahmad Ali');
      expect(messages, isEmpty);
    });

    test('returns null and emits backend failure message', () async {
      final messages = <String>[];
      final profile = await resolveCleaningWorkerProfileForRating(
        workerId: 77,
        fetchWorkerProfile: (_) async =>
            const Left(ServerFailure(message: 'failed to load worker')),
        onError: messages.add,
      );

      expect(profile, isNull);
      expect(messages, <String>['failed to load worker']);
    });

    test(
      'returns null and emits default message when worker id missing',
      () async {
        var invoked = false;
        final messages = <String>[];
        final profile = await resolveCleaningWorkerProfileForRating(
          workerId: null,
          fetchWorkerProfile: (_) async {
            invoked = true;
            return Right(
              FetchCleaningWorkerProfileModel(
                data: const CleaningWorkerProfileModel(id: 1),
              ),
            );
          },
          onError: messages.add,
        );

        expect(profile, isNull);
        expect(invoked, isFalse);
        expect(messages, <String>['تعذر تحميل بيانات مقدم الخدمة.']);
      },
    );

    test('returns null when payload has no profile id', () async {
      final messages = <String>[];
      final profile = await resolveCleaningWorkerProfileForRating(
        workerId: 55,
        fetchWorkerProfile: (_) async => Right(
          const FetchCleaningWorkerProfileModel(
            data: CleaningWorkerProfileModel(firstName: 'No Id'),
          ),
        ),
        onError: messages.add,
      );

      expect(profile, isNull);
      expect(messages, <String>['تعذر تحميل بيانات مقدم الخدمة.']);
    });
  });
}
