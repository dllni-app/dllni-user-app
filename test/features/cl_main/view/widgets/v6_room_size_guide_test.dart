import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/v6_room_size_guide.dart';

Widget wrapper(Widget child, {double scale = 1}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ),
);

void main() {
  test('each supported room type provides distinct contextual examples', () {
    for (final type in CleaningRoomType.values) {
      final guide = RoomSizeGuidance.forType(type);
      expect(guide.roomName, isNotEmpty);
      final examples = CleaningRoomSize.values.map(guide.example).toList();
      expect(examples.toSet().length, 3);
      expect(examples.every((example) => example.isNotEmpty), isTrue);
    }
    expect(
      RoomSizeGuidance.forType(
        CleaningRoomType.bedroom,
      ).example(CleaningRoomSize.medium),
      contains('سرير مزدوج'),
    );
    expect(
      RoomSizeGuidance.forType(
        CleaningRoomType.bathroom,
      ).example(CleaningRoomSize.small),
      contains('مغسلة'),
    );
  });

  testWidgets('explanation opens room-specific bottom sheet and dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapper(
        Builder(
          builder: (context) => V6RoomSizeIntro(
            onHelp: () =>
                V6RoomSizeHelpSheet.show(context, CleaningRoomType.bedroom),
          ),
        ),
      ),
    );
    await tester.tap(find.text('لست متأكداً؟ شاهد أمثلة'));
    await tester.pumpAndSettle();
    expect(find.text('كيف أختار حجم غرفة النوم؟'), findsOneWidget);
    expect(find.textContaining('سرير مفرد'), findsOneWidget);
    expect(find.textContaining('سرير مزدوج'), findsOneWidget);
    expect(find.textContaining('قطع أثاث إضافية'), findsOneWidget);
    await tester.ensureVisible(find.text('فهمت'));
    await tester.tap(find.text('فهمت'));
    await tester.pumpAndSettle();
    expect(find.text('كيف أختار حجم غرفة النوم؟'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 430.0]) {
    testWidgets('room help and examples fit RTL at ${width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        wrapper(
          Column(
            children: [
              V6RoomSizeIntro(onHelp: () {}),
              const SizedBox(height: 16),
              const V6RoomSizeExamples(roomType: CleaningRoomType.kitchen),
            ],
          ),
          scale: 1.8,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('أمثلة تساعدك'), findsOneWidget);
      expect(find.textContaining('مطبخ صغير'), findsOneWidget);
    });
  }
}
