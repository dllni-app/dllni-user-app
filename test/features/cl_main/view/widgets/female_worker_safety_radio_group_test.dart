import 'package:dllni_user_app/features/cl_main/data/models/female_worker_safety_policy_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/work_environment_confirmation.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_female_worker_safety_confirmation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = FemaleWorkerSafetyPolicyModel(
    title: 'تأكيد بيئة العمل',
    question: 'من سيكون متواجداً؟',
    options: [
      FemaleWorkerSafetyOptionModel(
        value: 'blocked',
        label: 'خيار غير مسموح',
        allowed: false,
        blockedMessage: 'هذا الخيار غير مسموح',
      ),
      FemaleWorkerSafetyOptionModel(
        value: 'allowed',
        label: 'خيار مسموح',
        allowed: true,
      ),
    ],
    pledge: FemaleWorkerSafetyPledgeModel(
      version: 'safety-v1',
      title: 'التعهد',
      body: 'أؤكد الالتزام بالشروط',
      acceptanceLabel: 'أوافق على التعهد',
    ),
  );

  testWidgets('blocked choice remains blocked with RadioGroup', (tester) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showFemaleWorkerSafetyConfirmationSheet(
                context: context,
                policy: policy,
              ),
              child: const Text('فتح'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('خيار غير مسموح'));
    await tester.pumpAndSettle();
    expect(find.text('هذا الخيار غير مسموح'), findsOneWidget);
    expect(find.text('أوافق على التعهد'), findsNothing);
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد بيئة العمل'), findsOneWidget);
    expect(find.text('هذا الخيار غير مسموح'), findsOneWidget);
  });

  testWidgets('allowed selection and pledge return same confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    WorkEnvironmentConfirmation? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showFemaleWorkerSafetyConfirmationSheet(
                  context: context,
                  policy: policy,
                );
              },
              child: const Text('فتح'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('خيار مسموح'));
    await tester.pumpAndSettle();
    expect(find.text('أوافق على التعهد'), findsOneWidget);
    await tester.tap(find.text('أوافق على التعهد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(result?.beneficiaryPresence, 'allowed');
    expect(result?.pledgeAccepted, isTrue);
    expect(result?.pledgeVersion, 'safety-v1');
  });
}
