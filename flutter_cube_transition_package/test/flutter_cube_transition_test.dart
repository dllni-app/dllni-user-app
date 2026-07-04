import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';

void main() {
  group('CubeUtils tests', () {
    test('normalizeRotation should return value between 0 and 2π', () {
      expect(CubeUtils.normalizeRotation(-3.5), inInclusiveRange(0, 2 * 3.14159));
      expect(CubeUtils.normalizeRotation(10.0), inInclusiveRange(0, 2 * 3.14159));
    });

    test('getCurrentFace returns correct face', () {
      expect(CubeUtils.getCurrentFace(0), CubeFace.front);
      expect(CubeUtils.getCurrentFace(3.14159 / 2), CubeFace.right);
      expect(CubeUtils.getCurrentFace(3.14159), CubeFace.back);
      expect(CubeUtils.getCurrentFace(3.14159 * 1.5), CubeFace.left);
    });

    test('createDefaultFaces returns 4 faces', () {
      final faces = CubeUtils.createDefaultFaces();
      expect(faces.length, 4);
      expect(faces.containsKey(CubeFace.front), true);
      expect(faces.containsKey(CubeFace.back), true);
      expect(faces.containsKey(CubeFace.left), true);
      expect(faces.containsKey(CubeFace.right), true);
    });
  });

  group('FlutterCubeTransition widget tests', () {
    testWidgets('renders cube with instructions', (tester) async {
      final faces = CubeUtils.createDefaultFaces();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCubeTransition(
              faces: faces,
              showControls: false,
            ),
          ),
        ),
      );

      // Check that instruction text is visible
      expect(find.text('Swipe left/right to rotate the cube'), findsOneWidget);
    });

    testWidgets('renders control buttons when enabled', (tester) async {
      final faces = CubeUtils.createDefaultFaces();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCubeTransition(
              faces: faces,
              showControls: true,
            ),
          ),
        ),
      );

      expect(find.text('LEFT'), findsOneWidget);
      expect(find.text('RESET'), findsOneWidget);
      expect(find.text('RIGHT'), findsOneWidget);
    });

    testWidgets('can rotate cube with drag', (tester) async {
      final faces = CubeUtils.createDefaultFaces();

      double? lastRotation;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCubeTransition(
              faces: faces,
              onRotationChanged: (value) => lastRotation = value,
            ),
          ),
        ),
      );

      // Drag horizontally
      await tester.drag(find.byType(GestureDetector), const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(lastRotation, isNotNull);
    });

    testWidgets('RESET button resets rotation', (tester) async {
      final faces = CubeUtils.createDefaultFaces();
      double? lastRotation;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCubeTransition(
              faces: faces,
              showControls: true,
              onRotationChanged: (value) => lastRotation = value,
            ),
          ),
        ),
      );

      // Rotate cube first
      await tester.drag(find.byType(GestureDetector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Press RESET button
      await tester.tap(find.text('RESET'));
      await tester.pump(); //

      expect(lastRotation, equals(0));
    });
  });
}
