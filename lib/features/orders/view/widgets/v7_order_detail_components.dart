import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Presentation adapters for the existing order-details controllers.
/// Despite the legacy class names, these widgets use the V6 customer design kit.
class V7OrderDetailScaffold extends StatelessWidget {
  const V7OrderDetailScaffold({
    super.key,
    required this.heading,
    required this.sections,
    required this.onRefresh,
    this.helpAction,
    this.primaryAction,
    this.secondaryAction,
  });

  final String heading;
  final List<Widget> sections;
  final Future<void> Function() onRefresh;
  final Widget? helpAction;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AlnadhaTokens.background,
    appBar: AppBar(
      backgroundColor: AlnadhaTokens.surface,
      surfaceTintColor: AlnadhaTokens.surface,
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        tooltip: 'رجوع',
        icon: const Icon(Icons.arrow_forward_ios_rounded),
        color: AlnadhaTokens.primary,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(heading, style: AlnadhaTokens.sectionTitle),
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
              color: AlnadhaTokens.primary,
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
          if (primaryAction != null || secondaryAction != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: AlnadhaTokens.surface,
                border: Border(top: BorderSide(color: AlnadhaTokens.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?primaryAction,
                  if (primaryAction != null && secondaryAction != null)
                    const SizedBox(height: 8),
                  ?secondaryAction,
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

enum V7OrderTone { info, success, warning, danger }

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

  Color get _ink => switch (tone) {
    V7OrderTone.info => AlnadhaTokens.primary,
    V7OrderTone.success => AlnadhaTokens.success,
    V7OrderTone.warning => AlnadhaTokens.warning,
    V7OrderTone.danger => AlnadhaTokens.danger,
  };

  Color get _surface => switch (tone) {
    V7OrderTone.info => SharedPlatformColors.cleaningSoft,
    V7OrderTone.success => const Color(0xFFEAF7F1),
    V7OrderTone.warning => const Color(0xFFFFF6E9),
    V7OrderTone.danger => const Color(0xFFFFF0F1),
  };

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '$statusLabel. $message',
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AlnadhaTokens.surface,
        border: Border.all(color: AlnadhaTokens.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _ink, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AlnadhaTokens.sectionTitle),
                    if (reference?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        reference!,
                        style: AlnadhaTokens.caption,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: AlnadhaTokens.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(message, style: AlnadhaTokens.body),
        ],
      ),
    ),
  );
}

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
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AlnadhaTokens.surface,
      border: Border.all(color: AlnadhaTokens.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: const IconThemeData(color: AlnadhaTokens.primary),
                child: leading!,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AlnadhaTokens.sectionTitle),
                  if (subtitle?.isNotEmpty == true) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: AlnadhaTokens.caption),
                  ],
                ],
              ),
            ),
            ?trailing,
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
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AlnadhaTokens.caption.copyWith(fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                (emphasized ? AlnadhaTokens.sectionTitle : AlnadhaTokens.body)
                    .copyWith(
                      color: emphasized
                          ? AlnadhaTokens.primary
                          : AlnadhaTokens.ink,
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
    leading: const Icon(Icons.person_outline_rounded),
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
                style: AlnadhaTokens.body.copyWith(fontWeight: FontWeight.w800),
              ),
              if (rating != null) ...[
                const SizedBox(height: 4),
                Text(
                  'التقييم ${rating!.toStringAsFixed(1)}',
                  style: AlnadhaTokens.caption,
                ),
              ],
            ],
          ),
        ),
        if (onCall != null)
          IconButton(
            tooltip: 'الاتصال بالعامل',
            onPressed: onCall,
            icon: const Icon(
              Icons.phone_outlined,
              color: AlnadhaTokens.primary,
            ),
          ),
      ],
    ),
  );
}

class V7OrderPricePanel extends StatelessWidget {
  const V7OrderPricePanel({
    super.key,
    required this.cleaningAndTravelPrice,
    required this.addonsTotal,
    required this.total,
    this.materialsPrice,
    this.specializedPrice,
    this.finalPrice = true,
    this.totalLabel = 'الإجمالي',
    this.pendingNote = 'قد يتغير الإجمالي عند اكتمال تفاصيل الخدمة.',
  });

  /// Precomputed from numeric booking amounts before currency formatting.
  final String? cleaningAndTravelPrice;
  final String? addonsTotal, total;
  final String? materialsPrice, specializedPrice;
  final bool finalPrice;
  final String totalLabel, pendingNote;

  @override
  Widget build(BuildContext context) => V7OrderPanel(
    title: 'ملخص السعر',
    leading: const Icon(Icons.receipt_long_outlined),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cleaningAndTravelPrice != null)
          V7OrderInfoRow(
            label: 'خدمة التنظيف والتنقل',
            value: cleaningAndTravelPrice!,
          ),
        if (materialsPrice != null)
          V7OrderInfoRow(label: 'مواد التنظيف', value: materialsPrice!),
        if (specializedPrice != null)
          V7OrderInfoRow(label: 'الخدمات المتخصصة', value: specializedPrice!),
        if (addonsTotal != null)
          V7OrderInfoRow(label: 'الإضافات', value: addonsTotal!),
        const Divider(height: 24, color: AlnadhaTokens.border),
        Container(
          key: const Key('order_price_total_card'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: V7OrderInfoRow(
            label: totalLabel,
            value: total ?? 'سيتم تحديد التكلفة',
            emphasized: true,
          ),
        ),
        if (!finalPrice) ...[
          const SizedBox(height: 7),
          Text(pendingNote, style: AlnadhaTokens.caption),
        ],
      ],
    ),
  );
}

class V7OrderLoadingView extends StatelessWidget {
  const V7OrderLoadingView({super.key, this.message = 'جارٍ تحميل الطلب'});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AlnadhaTokens.background,
    appBar: AppBar(
      title: Text('تفاصيل الطلب', style: AlnadhaTokens.sectionTitle),
      backgroundColor: AlnadhaTokens.surface,
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AlnadhaTokens.primary),
          const SizedBox(height: 14),
          Text(message, style: AlnadhaTokens.body),
        ],
      ),
    ),
  );
}
