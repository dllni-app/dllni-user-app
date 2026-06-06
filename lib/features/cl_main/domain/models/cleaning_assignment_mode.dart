enum CleaningAssignmentMode {
  preferredWorker,
  openCount,
}

extension CleaningAssignmentModeX on CleaningAssignmentMode {
  String get apiValue {
    switch (this) {
      case CleaningAssignmentMode.preferredWorker:
        return 'preferred_worker';
      case CleaningAssignmentMode.openCount:
        return 'open_count';
    }
  }

  static CleaningAssignmentMode fromApi(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'open_count':
        return CleaningAssignmentMode.openCount;
      case 'preferred_worker':
      default:
        return CleaningAssignmentMode.preferredWorker;
    }
  }
}
