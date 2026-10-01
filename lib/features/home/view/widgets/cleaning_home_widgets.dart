import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../orders/data/models/cleaning_booking_status.dart';
import '../../../orders/data/models/cleaning_orders_api_models.dart';

class CleaningHomeHeader extends StatelessWidget {
  const CleaningHomeHeader({
    super.key,
    required this.displayName,
    required this.isAuthenticated,
    required this.unreadCount,
    required this.onNotificationsTap,
  });

  final String displayName;
  final bool isAuthenticated;
  final int unreadCount;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAuthenticated ? 'مرحباً بعودتك 👋' : 'مرحباً بك 👋',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayName,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onNotificationsTap,
            customBorder: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF172033),
                  ),
                ),
                if (unreadCount > 0)
                  PositionedDirectional(
                    top: -2,
                    end: -2,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B8C4),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CleaningHomeAddressCard extends StatelessWidget {
  const CleaningHomeAddressCard({
    super.key,
    required this.onTap,
    this.label,
    this.line1,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final String? label;
  final String? line1;
  final bool isLoading;

  bool get _hasAddress =>
      (label?.trim().isNotEmpty ?? false) ||
      (line1?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF0F8E98),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasAddress
                                ? (label ?? 'العنوان الافتراضي')
                                : 'عنوان الخدمة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Color(0xFF172033),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _hasAddress
                                ? (line1 ?? 'اضغط لإدارة العنوان')
                                : 'أضف عنواناً لتسريع حجز التنظيف',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CleaningHomeActiveBookingCard extends StatelessWidget {
  const CleaningHomeActiveBookingCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final CleaningOrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = (order.status ?? '').toLowerCase();
    final title = order.propertyType == 'event_assistance'
        ? 'مساعدة للمناسبة'
        : 'طلب تنظيف';
    final location = order.locationName?.trim();
    final date = order.scheduledDate?.trim();
    final time = order.scheduledTime?.trim();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17204A),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _HomeStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.bookingNumber == null
                ? 'طلبك النشط'
                : 'رقم الطلب #${order.bookingNumber}',
            textAlign: TextAlign.start,
            style: const TextStyle(color: Color(0xFFC7D0EA), fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (date?.isNotEmpty == true || time?.isNotEmpty == true)
            _HomeInfoRow(
              icon: Icons.calendar_today_outlined,
              text: [
                date,
                time,
              ].where((value) => value?.isNotEmpty == true).join(' • '),
            ),
          if (location?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            _HomeInfoRow(icon: Icons.location_on_outlined, text: location!),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'متابعة الطلب',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class CleaningHomeEmptyBookingCard extends StatelessWidget {
  const CleaningHomeEmptyBookingCard({
    super.key,
    required this.onBookTap,
    required this.isAuthenticated,
  });

  final VoidCallback onBookTap;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: Color(0xFF0F8E98),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAuthenticated ? 'لا يوجد طلب تنظيف قادم' : 'ابدأ أول طلب تنظيف',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isAuthenticated
                ? 'عندما تحجز خدمة ستظهر حالتها وموعدها هنا.'
                : 'يمكنك استكشاف الخدمة، وسنطلب تسجيل الدخول عند الحاجة.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              height: 1.45,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onBookTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'احجز تنظيفاً',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class CleaningHomePrimaryServiceCard extends StatelessWidget {
  const CleaningHomePrimaryServiceCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تنظيف منزلك بسهولة',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'حدد الغرف والموعد واترك دلّني ينسق الفريق المناسب.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFFDCE2F5),
                    height: 1.45,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('ابدأ طلب تنظيف'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF12B8C4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.cleaning_services_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeInfoRow extends StatelessWidget {
  const _HomeInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9EDDE2), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeStatusBadge extends StatelessWidget {
  const _HomeStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF12B8C4).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFF55D6DE)),
      ),
      child: Text(
        cleaningHomeStatusLabel(status),
        style: const TextStyle(
          color: Color(0xFFE8FCFD),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String cleaningHomeStatusLabel(String status) {
  return switch (status) {
    CleaningBookingStatus.pending => 'جاري البحث عن عمال',
    CleaningBookingStatus.workerAssigned => 'تم تعيين الفريق',
    CleaningBookingStatus.awaitingStartVerification => 'بانتظار رمز البدء',
    CleaningBookingStatus.awaitingWorkerStartConfirmation =>
      'بانتظار بدء العامل',
    CleaningBookingStatus.inProgress => 'التنظيف جارٍ',
    CleaningBookingStatus.awaitingCustomerCompletion => 'بانتظار تأكيدك',
    CleaningBookingStatus.timeExtensionRequested => 'طلب تمديد الوقت',
    CleaningBookingStatus.completed => 'مكتمل',
    CleaningBookingStatus.cancelled => 'ملغي',
    _ => 'قيد المتابعة',
  };
}
