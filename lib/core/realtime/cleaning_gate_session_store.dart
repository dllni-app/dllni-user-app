import '../../features/orders/data/models/cleaning_booking_status.dart';

enum CleaningGateSuppressionReason {
  userDismissed,
  cancelled,
  bookingTimeExpired,
  terminalStatus,
}

class CleaningGateSessionStore {
  CleaningGateSessionStore._();

  static final CleaningGateSessionStore instance = CleaningGateSessionStore._();

  final Map<int, _CleaningGateSessionEntry> _entries =
      <int, _CleaningGateSessionEntry>{};

  static const Set<CleaningGateSuppressionReason> _startPermanentReasons =
      <CleaningGateSuppressionReason>{
        CleaningGateSuppressionReason.cancelled,
        CleaningGateSuppressionReason.bookingTimeExpired,
        CleaningGateSuppressionReason.terminalStatus,
      };
  static const Set<CleaningGateSuppressionReason> _completionPermanentReasons =
      <CleaningGateSuppressionReason>{
        CleaningGateSuppressionReason.cancelled,
        CleaningGateSuppressionReason.terminalStatus,
      };

  _CleaningGateSessionEntry _entryFor(int bookingId) {
    return _entries.putIfAbsent(bookingId, _CleaningGateSessionEntry.new);
  }

  void suppressStartVerification(
    int bookingId,
    CleaningGateSuppressionReason reason,
  ) {
    _entryFor(bookingId).startReasons.add(reason);
  }

  void suppressCompletion(
    int bookingId,
    CleaningGateSuppressionReason reason, {
    bool currentAwaitingCycleOnly = false,
  }) {
    final entry = _entryFor(bookingId);
    entry.completionReasons.add(reason);
    if (currentAwaitingCycleOnly) {
      entry.completionDismissedForCurrentAwaitingCycle = true;
    }
  }

  void clearStartDismissed(int bookingId) {
    final entry = _entries[bookingId];
    if (entry == null) return;
    entry.startReasons.remove(CleaningGateSuppressionReason.userDismissed);
    _cleanupIfEmpty(bookingId, entry);
  }

  void clearCompletionAwaitingCycle(int bookingId) {
    final entry = _entries[bookingId];
    if (entry == null) return;
    entry.completionDismissedForCurrentAwaitingCycle = false;
    entry.completionReasons.remove(CleaningGateSuppressionReason.userDismissed);
    _cleanupIfEmpty(bookingId, entry);
  }

  bool isStartVerificationSuppressed(int bookingId, {bool force = false}) {
    final entry = _entries[bookingId];
    if (entry == null) return false;
    if (entry.startReasons.any(_startPermanentReasons.contains)) {
      return true;
    }
    if (!force &&
        entry.startReasons.contains(
          CleaningGateSuppressionReason.userDismissed,
        )) {
      return true;
    }
    return false;
  }

  bool isCompletionSuppressed(int bookingId, {bool force = false}) {
    final entry = _entries[bookingId];
    if (entry == null) return false;
    if (entry.completionReasons.any(_completionPermanentReasons.contains)) {
      return true;
    }
    if (!force &&
        (entry.completionDismissedForCurrentAwaitingCycle ||
            entry.completionReasons.contains(
              CleaningGateSuppressionReason.userDismissed,
            ))) {
      return true;
    }
    return false;
  }

  void syncWithStatus({
    required int bookingId,
    required String normalizedStatus,
  }) {
    if (normalizedStatus == CleaningBookingStatus.cancelled) {
      suppressStartVerification(
        bookingId,
        CleaningGateSuppressionReason.cancelled,
      );
      suppressCompletion(bookingId, CleaningGateSuppressionReason.cancelled);
      return;
    }
    if (normalizedStatus == CleaningBookingStatus.completed) {
      suppressStartVerification(
        bookingId,
        CleaningGateSuppressionReason.terminalStatus,
      );
      suppressCompletion(
        bookingId,
        CleaningGateSuppressionReason.terminalStatus,
      );
      return;
    }
    if (normalizedStatus != CleaningBookingStatus.awaitingStartVerification) {
      clearStartDismissed(bookingId);
    }
    if (normalizedStatus != CleaningBookingStatus.awaitingCustomerCompletion) {
      clearCompletionAwaitingCycle(bookingId);
    }
  }

  void reset() {
    _entries.clear();
  }

  void _cleanupIfEmpty(int bookingId, _CleaningGateSessionEntry entry) {
    if (entry.startReasons.isEmpty &&
        entry.completionReasons.isEmpty &&
        !entry.completionDismissedForCurrentAwaitingCycle) {
      _entries.remove(bookingId);
    }
  }
}

class _CleaningGateSessionEntry {
  final Set<CleaningGateSuppressionReason> startReasons =
      <CleaningGateSuppressionReason>{};
  final Set<CleaningGateSuppressionReason> completionReasons =
      <CleaningGateSuppressionReason>{};
  bool completionDismissedForCurrentAwaitingCycle = false;
}

DateTime? resolveCleaningBookingStartDateTime({
  required String? scheduledDate,
  required String? scheduledTime,
}) {
  final date = scheduledDate?.trim() ?? '';
  final time = scheduledTime?.trim() ?? '';
  if (date.isEmpty || time.isEmpty) return null;
  final raw = '$date ${time.split('.').first}';
  return DateTime.tryParse(raw);
}

double resolveCleaningBookingHours({
  required double? totalHours,
  required String? estimatedHours,
}) {
  if (totalHours != null && totalHours > 0) {
    return totalHours;
  }
  return double.tryParse((estimatedHours ?? '').trim()) ?? 0;
}

DateTime? resolveCleaningBookingEndDateTime({
  required String? scheduledDate,
  required String? scheduledTime,
  required double? totalHours,
  required String? estimatedHours,
}) {
  final start = resolveCleaningBookingStartDateTime(
    scheduledDate: scheduledDate,
    scheduledTime: scheduledTime,
  );
  if (start == null) return null;
  final hours = resolveCleaningBookingHours(
    totalHours: totalHours,
    estimatedHours: estimatedHours,
  );
  if (hours <= 0) return null;
  return start.add(Duration(minutes: (hours * 60).round()));
}

bool isCleaningBookingPastEndTime({
  required String? scheduledDate,
  required String? scheduledTime,
  required double? totalHours,
  required String? estimatedHours,
  DateTime? now,
}) {
  final end = resolveCleaningBookingEndDateTime(
    scheduledDate: scheduledDate,
    scheduledTime: scheduledTime,
    totalHours: totalHours,
    estimatedHours: estimatedHours,
  );
  if (end == null) return false;
  return (now ?? DateTime.now()).isAfter(end);
}

bool isCleaningBookingScheduledDateBeforeToday({
  required String? scheduledDate,
  DateTime? now,
}) {
  final rawDate = scheduledDate?.trim() ?? '';
  if (rawDate.isEmpty) return false;
  final parsedDate = DateTime.tryParse(rawDate);
  if (parsedDate == null) return false;
  final scheduledDay = DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
  );
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  return scheduledDay.isBefore(today);
}
