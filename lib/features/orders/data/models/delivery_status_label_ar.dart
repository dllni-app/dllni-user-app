/// Localize delivery-related API codes without displaying internal enum values.
String deliveryStatusLabelAr(String? code, {String? fallback}) {
  final normalized = (code ?? fallback ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  const labels = <String, String>{
    'new': 'طلب توصيل جديد',
    'waiting_merchant_ready': 'بانتظار تجهيز الطلب',
    'dispatching': 'جارٍ البحث عن مندوب',
    'searching_for_driver': 'جارٍ البحث عن مندوب',
    'offered': 'بانتظار قبول المندوب',
    'accepted': 'تم قبول التوصيل',
    'in_progress': 'المندوب في الطريق للمتجر',
    'arrived_pickup': 'وصل المندوب إلى المتجر',
    'ready_for_pickup': 'الطلب جاهز للاستلام',
    'picked_up': 'استلم المندوب الطلب',
    'arrived_dropoff': 'وصل المندوب إلى العميل',
    'returning_to_merchant': 'جارٍ إرجاع الطلب إلى المتجر',
    'returned_to_merchant': 'أُعيد الطلب إلى المتجر',
    'delivered': 'تم التوصيل',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
    'canceled': 'ملغي',
    'stopped': 'توقف البحث عن مندوب',
    'rejected': 'تم رفض التوصيل',
  };
  final mapped = labels[normalized];
  if (mapped != null) return mapped;
  if (RegExp(r'[ء-ي]').hasMatch(fallback ?? '')) return fallback!;
  return 'جاري تحديث حالة التوصيل';
}
