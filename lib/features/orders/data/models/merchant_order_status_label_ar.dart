/// Arabic labels for the order status codes shared by restaurant and supermarket.
///
/// Prefer the canonical status code over the API's presentation label:
/// the latter may be English even when the client is displaying Arabic.
String merchantOrderStatusLabelAr(String? status, {String? fallback}) {
  final normalized = (status ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('-', '_');

  switch (normalized) {
    case 'pending':
      return 'قيد الانتظار';
    case 'accepted':
      return 'تم القبول';
    case 'preparing':
      return 'قيد التحضير';
    case 'ready_for_pickup':
      return 'جاهز للاستلام';
    case 'picked_up':
      return 'تم الاستلام';
    case 'delivered':
      return 'تم التوصيل';
    case 'completed':
      return 'مكتمل';
    case 'cancelled':
    case 'canceled':
      return 'ملغي';
    case 'rejected':
      return 'مرفوض';
    case 'processing':
      return 'قيد المعالجة';
    default:
      final rawFallback = fallback?.trim() ?? '';
      // Do not display raw English backend labels in an Arabic app.
      if (RegExp(r'[ء-ي]').hasMatch(rawFallback)) {
        return rawFallback;
      }
      return 'قيد المعالجة';
  }
}
