import 'package:dllni_user_app/features/home/view/widgets/home_cube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'standalone cube rests on a rounded front face without a campaign card',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 360, child: HomeCube(offers: [])),
            ),
          ),
        ),
      );
      final cube = tester.widget<FlutterCubeTransition>(
        find.byType(FlutterCubeTransition),
      );
      expect(cube.width, cube.height);
      expect(cube.width, greaterThan(180));
      expect(cube.initialRotationY, 0);
      expect(cube.faceShadowSpreadRadius, 0);
      final viewport = tester.getRect(
        find.byKey(const Key('home_cube_safe_viewport')),
      );
      final cubeBounds = tester.getRect(find.byType(FlutterCubeTransition));
      expect(viewport.contains(cubeBounds.topLeft), isTrue);
      expect(viewport.contains(cubeBounds.bottomRight), isTrue);
      expect((cubeBounds.center - viewport.center).distance, lessThan(.001));
      expect(cube.borderRadius!.topLeft.x, greaterThanOrEqualTo(20));
      expect(find.byKey(const Key('home_compact_cube_campaign')), findsNothing);
      expect(find.text('خدمات على ذوقك'), findsNothing);
      expect(find.text('حرّك المكعب واكتشف خدمات ع الندهة'), findsNothing);
      expect(find.byType(ClipRect), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('standalone cube fits narrow RTL screens during a swipe', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HomeCube(offers: []),
            ),
          ),
        ),
      ),
    );
    final viewport = tester.getRect(
      find.byKey(const Key('home_cube_safe_viewport')),
    );
    expect(viewport.left, greaterThanOrEqualTo(16));
    expect(viewport.right, lessThanOrEqualTo(304));
    await tester.drag(
      find.byType(FlutterCubeTransition),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('swipes and automatic rotation settle on a readable front face', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(width: 320, child: HomeCube(offers: [])),
            ),
          ),
        ),
      ),
    );

    void expectFaceForward(String face) {
      final content = find.byKey(Key('cube_face_content_$face'));
      expect(tester.widget<Opacity>(content).opacity, 1);
      final projection = tester
          .widget<Transform>(
            find.ancestor(of: content, matching: find.byType(Transform)).first,
          )
          .transform;
      expect(projection.entry(0, 0), closeTo(1, .0001));
      expect(projection.entry(0, 2), closeTo(0, .0001));
    }

    expectFaceForward('front');
    expect(find.byKey(const Key('cube_face_content_left')), findsNothing);
    await tester.drag(
      find.byType(FlutterCubeTransition),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    expectFaceForward('left');
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expectFaceForward('back');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
