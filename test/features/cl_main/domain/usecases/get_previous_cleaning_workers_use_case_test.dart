import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getParams includes propertyType when provided', () {
    final params = GetPreviousCleaningWorkersParams(
      page: 2,
      perPage: 15,
      propertyType: 'villa',
    );

    expect(params.getParams(), {
      'page': 2,
      'per_page': 15,
      'propertyType': 'villa',
    });
  });

  test('getParams omits propertyType when null or empty', () {
    expect(
      GetPreviousCleaningWorkersParams(page: 1).getParams(),
      {'page': 1, 'per_page': 10},
    );
    expect(
      GetPreviousCleaningWorkersParams(
        page: 1,
        propertyType: '',
      ).getParams(),
      {'page': 1, 'per_page': 10},
    );
  });

  test('getParams includes event_assistance propertyType', () {
    final params = GetPreviousCleaningWorkersParams(
      propertyType: 'event_assistance',
    );

    expect(params.getParams()['propertyType'], 'event_assistance');
  });
}
