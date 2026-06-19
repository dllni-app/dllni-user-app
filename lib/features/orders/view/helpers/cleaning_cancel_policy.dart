import '../../data/models/cleaning_booking_status.dart';

class CleaningCancelPolicy {
  CleaningCancelPolicy._();

  static bool isCancellable(String? status) {
    final normalized = (status ?? '').trim().toLowerCase();
    return normalized == CleaningBookingStatus.pending ||
        normalized == CleaningBookingStatus.workerAssigned;
  }
}
