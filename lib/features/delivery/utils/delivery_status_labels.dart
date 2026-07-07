String deliveryStatusLabelAr(String? status, {String? fallback}) {
  final normalized = (status ?? '').trim().toLowerCase();
  if (normalized.isEmpty) return fallback ?? 'حالة التوصيل غير محددة';

  return switch (normalized) {
    'waiting_merchant_ready' => 'بانتظار تجهيز الطلب من المتجر',
    'searching_for_driver' => 'جاري البحث عن مندوب',
    'searching_driver' => 'جاري البحث عن مندوب',
    'dispatching' => 'جاري البحث عن مندوب',
    'new' => 'تم إنشاء طلب التوصيل',
    'offered' => 'تم إرسال الطلب إلى المندوب',
    'accepted' => 'المندوب قبل الطلب',
    'in_progress' => 'المندوب في الطريق إلى المتجر',
    'driver_en_route' => 'المندوب في الطريق إلى المتجر',
    'arrived' => 'وصل المندوب',
    'arrived_pickup' => 'وصل المندوب إلى المتجر',
    'handover_complete' => 'تم استلام الطلب من المتجر',
    'picked_up' => 'تم استلام الطلب من المتجر',
    'delivered' => 'تم تسليم الطلب',
    'completed' => 'تم تسليم الطلب',
    'cancelled' => 'تم إلغاء الطلب',
    'canceled' => 'تم إلغاء الطلب',
    'stopped' => 'توقف طلب التوصيل',
    'rejected' => 'تعذر قبول طلب التوصيل',
    'not_received' => 'لم يتم الاستلام',
    _ => fallback ?? status ?? 'حالة التوصيل غير محددة',
  };
}

String deliveryStatusHintAr(String? status) {
  final normalized = (status ?? '').trim().toLowerCase();
  return switch (normalized) {
    'waiting_merchant_ready' => 'سيبدأ البحث عن مندوب عندما يصبح الطلب جاهزاً للاستلام من المتجر.',
    'searching_for_driver' || 'searching_driver' || 'dispatching' => 'نبحث الآن عن مندوب مناسب لاستلام الطلب.',
    'offered' => 'تم إرسال الطلب إلى مندوب، بانتظار قبوله.',
    'accepted' => 'المندوب قبل الطلب وسيتوجه إلى المتجر.',
    'in_progress' || 'driver_en_route' => 'المندوب في الطريق إلى المتجر لاستلام الطلب.',
    'picked_up' || 'handover_complete' => 'المندوب استلم الطلب من المتجر وهو في الطريق إليك.',
    'delivered' || 'completed' => 'تم تسليم الطلب بنجاح.',
    'cancelled' || 'canceled' => 'تم إلغاء طلب التوصيل.',
    'stopped' => 'توقف طلب التوصيل، وسيتم تحديث الطلب عند توفر معلومات جديدة.',
    _ => 'جاري تحديث حالة التوصيل.',
  };
}
