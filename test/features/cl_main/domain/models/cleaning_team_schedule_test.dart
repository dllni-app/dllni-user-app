import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_booking_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_team_schedule.dart';

CleaningBookingDraft fixture(int roomCount) {
  final draft = CleaningBookingDraft.fromRooms([
    for (var index = 1; index <= roomCount; index++)
      CleaningProgressiveRoomUnit(
        roomType: CleaningRoomType.bedroom,
        index: index,
        size: CleaningRoomSize.medium,
      ),
  ], DateTime(2026, 11, 10));
  var updated = draft;
  for (final schedule in draft.schedules) {
    updated = updated.replaceSchedule(schedule.copyWith(workMinutes: 120));
  }
  return updated;
}

void main() {
  test('one worker never overlaps rooms when a specialist adds work', () {
    final draft = fixture(3);
    final planned = planCleaningTeam(
      draft,
      workerCount: 1,
      effectiveWorkMinutesByRoom: const {
        'bedroom.1': 210, // 120 base + 90 specialist work
        'bedroom.2': 120,
        'bedroom.3': 120,
      },
    );
    expect(planned.peakWorkers, 1);
    expect(cleaningTeamDurationMinutes(planned), 450);
    expect(planned.schedules.first.workMinutes, 210);
    expect(planned.schedules[1].start, planned.schedules[0].end);
    expect(planned.schedules[2].start, planned.schedules[1].end);
    expect(cleaningTeamDurationMinutes(planned)! <= 480, isTrue);
  });

  test('one worker cleans multiple rooms in succession', () {
    final result = planCleaningTeam(fixture(3), workerCount: 1);
    expect(result.schedules.map((s) => s.workers), everyElement(1));
    expect(result.peakWorkers, 1);
    expect(cleaningTeamDurationMinutes(result), 360);
    expect(result.schedules[1].start, result.schedules[0].end);
    expect(result.schedules[2].start, result.schedules[1].end);
  });

  test('more workers than rooms share work without multiplying workers', () {
    final result = planCleaningTeam(fixture(2), workerCount: 5);
    expect(result.peakWorkers, 5);
    expect(result.schedules.map((s) => s.workers).reduce((a, b) => a + b), 5);
    expect(cleaningTeamDurationMinutes(result), lessThan(120));
  });

  test('one room can request several workers', () {
    final result = planCleaningTeam(fixture(1), workerCount: 4);
    expect(result.schedules.single.workers, 4);
    expect(cleaningTeamDurationMinutes(result), 30);
  });

  test('more workers reduce total elapsed time', () {
    final draft = fixture(3);
    final one = planCleaningTeam(draft, workerCount: 1);
    final two = planCleaningTeam(draft, workerCount: 2);
    final four = planCleaningTeam(draft, workerCount: 4);
    expect(
      cleaningTeamDurationMinutes(two),
      lessThan(cleaningTeamDurationMinutes(one)!),
    );
    expect(
      cleaningTeamDurationMinutes(four),
      lessThan(cleaningTeamDurationMinutes(two)!),
    );
    expect(two.peakWorkers, 2);
    expect(four.peakWorkers, 4);
  });
}
