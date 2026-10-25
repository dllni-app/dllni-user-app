import 'package:dllni_user_app/features/home/view/widgets/home_cube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('restored promotional cube has a square face even without offers', (
    tester,
  ) async {
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
    expect(cube.width, 280);
    await tester.pumpWidget(const SizedBox());
  });
}
