import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_gender_preference_section_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_assignment_mode_section_widget.dart';

Widget wrap(Widget child) => MaterialApp(
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'V6 gender choice keeps the same enum callback and selected state',
    (tester) async {
      CleaningGenderPreference? choice;
      await tester.pumpWidget(
        wrap(
          ClServiceGenderPreferenceSectionWidget(
            selectedPreference: CleaningGenderPreference.male,
            onChanged: (v) => choice = v,
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('cleaning_gender_pref_female')));
      expect(choice, CleaningGenderPreference.female);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('V6 worker assignment choices preserve existing backend enum', (
    tester,
  ) async {
    CleaningAssignmentMode? chosen;
    await tester.pumpWidget(
      wrap(
        ClServiceAssignmentModeSectionWidget(
          selectedMode: CleaningAssignmentMode.openCount,
          onModeChanged: (v) => chosen = v,
        ),
      ),
    );
    await tester.tap(
      find.byKey(const Key('cleaning_assignment_preferred_worker')),
    );
    expect(chosen, CleaningAssignmentMode.preferredWorker);
    expect(tester.takeException(), isNull);
  });
}
