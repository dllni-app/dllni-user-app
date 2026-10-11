import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

/// Pen V7 components. Decision logic remains in the existing order controller.
class V7OrderDetailScaffold extends StatelessWidget {
  const V7OrderDetailScaffold({
    super.key,
    required this.heading,
    required this.sections,
    required this.onRefresh,
    this.helpAction,
    this.primaryAction,
  });
  final String heading;
  final List<Widget> sections;
  final Future<void> Function() onRefresh;
  final Widget? helpAction;
  final Widget? primaryAction;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F7F9),
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        tooltip: 'الرجوع',
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: SharedPlatformColors.primary,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        heading,
        style: const TextStyle(
          fontSize: 18,
          color: SharedPlatformColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        if (helpAction != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: helpAction,
          ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: SharedPlatformColors.cleaning,
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 28),
                children: [
                  for (var i = 0; i < sections.length; i++) ...[
                    sections[i],
                    if (i < sections.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          if (primaryAction != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE6E9EE))),
              ),
              child: primaryAction,
            ),
        ],
      ),
    ),
  );
}

class V7OrderStatusHero extends StatelessWidget {
  const V7OrderStatusHero({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.message,
    this.reference,
    this.icon = Icons.cleaning_services_outlined,
    this.tone = V7OrderTone.info,
  });
  final String title, statusLabel, message;
  final String? reference;
  final IconData icon;
  final V7OrderTone tone;
  @override
  Widget build(BuildContext context) {
    final background = switch (tone) {
      V7OrderTone.success => const Color(0xFFE9F8F2),
      V7OrderTone.warning => const Color(0xFFFFF6E8),
      V7OrderTone.danger => const Color(0xFFFFEFF0),
      V7OrderTone.info => const Color(0xFFEAF9FA),
    };
    final toneColor = switch (tone) {
      V7OrderTone.success => const Color(0xFF13785B),
      V7OrderTone.warning => const Color(0xFF926017),
      V7OrderTone.danger => const Color(0xFFC33F49),
      V7OrderTone.info => const Color(0xFF007885),
    };
    return Semantics(
      label: '$statusLabel. $message',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: toneColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          color: SharedPlatformColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (reference != null && reference!.trim().isNotEmpty)
                        Text(
                          reference!,
                          style: const TextStyle(
                            color: SharedPlatformColors.muted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: toneColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                color: SharedPlatformColors.ink,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum V7OrderTone { info, success, warning, danger }

class V7OrderPanel extends StatelessWidget {
  const V7OrderPanel({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading, trailing;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8EAF0)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: SharedPlatformColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: SharedPlatformColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class V7OrderInfoRow extends StatelessWidget {
  const V7OrderInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label, value;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: SharedPlatformColors.muted,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: emphasized
                  ? SharedPlatformColors.primary
                  : SharedPlatformColors.ink,
              fontSize: emphasized ? 15 : 13,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class V7OrderWorkerPanel extends StatelessWidget {
  const V7OrderWorkerPanel({
    super.key,
    required this.name,
    this.avatarUrl,
    this.rating,
    this.onCall,
  });
  final String name;
  final String? avatarUrl;
  final double? rating;
  final VoidCallback? onCall;
  @override
  Widget build(BuildContext context) => V7OrderPanel(
    title: 'مقدم الخدمة',
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: (avatarUrl?.trim().isNotEmpty ?? false)
              ? Image.network(
                  avatarUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Image.asset(V7Artwork.worker, width: 56, height: 56),
                )
              : Image.asset(V7Artwork.worker, width: 56, height: 56),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: SharedPlatformColors.ink,
                ),
              ),
              if (rating != null)
                Text(
                  'التقييم ' + rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    color: SharedPlatformColors.muted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        if (onCall != null)
          IconButton(
            tooltip: 'الاتصال بالعامل',
            onPressed: onCall,
            icon: const Icon(
              Icons.phone_outlined,
              color: SharedPlatformColors.primary,
            ),
          ),
      ],
    ),
  );
}

class V7OrderPricePanel extends StatelessWidget {
  const V7OrderPricePanel({
    super.key,
    required this.basePrice,
    required this.travelFee,
    required this.addonsTotal,
    required this.total,
    this.finalPrice = true,
  });
  final String? basePrice, travelFee, addonsTotal, total;
  final bool finalPrice;
  @override
  Widget build(BuildContext context) => V7OrderPanel(
    title: 'ملخص التكلفة',
    subtitle: finalPrice
        ? null
        : 'التكلفة الحالية قابلة للتحديث قبل إتمام الخدمة',
    child: Column(
      children: [
        V7OrderInfoRow(
          label: 'قيمة الخدمة',
          value: basePrice ?? 'لم تُحدد بعد',
        ),
        if (travelFee != null)
          V7OrderInfoRow(label: 'رسوم التنقل', value: travelFee!),
        if (addonsTotal != null)
          V7OrderInfoRow(label: 'الإضافات', value: addonsTotal!),
        const Divider(height: 20, color: Color(0xFFE9ECF1)),
        V7OrderInfoRow(
          label: 'المجموع',
          value: total ?? 'سيتم تحديد التكلفة',
          emphasized: true,
        ),
        const SizedBox(height: 5),
        const Row(
          children: [
            Icon(Icons.payments_outlined, size: 18, color: Color(0xFF087D83)),
            SizedBox(width: 8),
            Text(
              'الدفع نقداً',
              style: TextStyle(fontSize: 12, color: SharedPlatformColors.muted),
            ),
          ],
        ),
      ],
    ),
  );
}

class V7OrderLoadingView extends StatelessWidget {
  const V7OrderLoadingView({super.key, this.message = 'جارٍ تحميل الطلب'});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F7F9),
    appBar: AppBar(
      title: const Text('تفاصيل الطلب'),
      backgroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: SharedPlatformColors.cleaning),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(color: SharedPlatformColors.muted),
          ),
        ],
      ),
    ),
  );
}
