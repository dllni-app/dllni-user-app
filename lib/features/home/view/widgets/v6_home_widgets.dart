import 'package:flutter/material.dart';

import '../../../../core/widgets/design_system/design_system.dart';

/// Pure presentation; the HomeScreen still provides user, address and auth state.
class V6HomeHeader extends StatelessWidget {
  const V6HomeHeader({
    super.key,
    required this.displayName,
    required this.locationLabel,
    required this.isAuthenticated,
    required this.unreadCount,
    required this.onNotificationsTap,
    required this.onLocationTap,
    this.onLoginTap,
  });
  final String displayName;
  final String locationLabel;
  final bool isAuthenticated;
  final int unreadCount;
  final VoidCallback onNotificationsTap;
  final VoidCallback onLocationTap;
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAuthenticated ? 'أهلاً $displayName' : 'أهلاً بك في ع الندهة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AlnadhaTokens.sectionTitle,
              ),
              const SizedBox(height: 3),
              InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AlnadhaTokens.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationLabel,
                          style: AlnadhaTokens.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AlnadhaTokens.muted,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (isAuthenticated)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: AlnadhaTokens.surface,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  onTap: onNotificationsTap,
                  borderRadius: BorderRadius.circular(13),
                  child: const SizedBox(
                    height: 48,
                    width: 48,
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AlnadhaTokens.primary,
                    ),
                  ),
                ),
              ),
              if (unreadCount > 0)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AlnadhaTokens.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          )
        else
          TextButton(onPressed: onLoginTap, child: const Text('دخول')),
      ],
    ),
  );
}

/// Filters only the actual four supported service destinations in memory.
/// Does not represent a backend universal search of stores or products.
class V6ServiceFinder extends StatefulWidget {
  const V6ServiceFinder({
    super.key,
    required this.onCleaning,
    required this.onRestaurants,
    required this.onSupermarket,
    this.onDelivery,
  });
  final VoidCallback onCleaning;
  final VoidCallback onRestaurants;
  final VoidCallback onSupermarket;
  final VoidCallback? onDelivery;

  @override
  State<V6ServiceFinder> createState() => _V6ServiceFinderState();
}

class _V6ServiceFinderState extends State<V6ServiceFinder> {
  final _controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = query.trim();
    final choices =
        <(String, VoidCallback?)>[
              ('التنظيفات', widget.onCleaning),
              ('المطاعم', widget.onRestaurants),
              ('السوبرماركت', widget.onSupermarket),
              ('التوصيل', widget.onDelivery),
            ]
            .where(
              (item) =>
                  item.$2 != null &&
                  (normalized.isEmpty || item.$1.contains(normalized)),
            )
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('v6_home_service_search'),
          controller: _controller,
          onChanged: (value) => setState(() => query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'ابحث عن قسم خدمة',
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'مسح البحث',
                    onPressed: () => setState(() {
                      _controller.clear();
                      query = '';
                    }),
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        if (normalized.isNotEmpty) ...[
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: choices.isEmpty
                ? const Text(
                    'لا يوجد قسم بهذا الاسم',
                    style: AlnadhaTokens.caption,
                  )
                : Column(
                    children: [
                      for (final item in choices)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(item.$1, style: AlnadhaTokens.body),
                          trailing: const Icon(Icons.chevron_left_rounded),
                          onTap: item.$2,
                        ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }
}

class V6HomeActiveOrder extends StatelessWidget {
  const V6HomeActiveOrder({
    super.key,
    required this.section,
    required this.sectionLabel,
    required this.title,
    required this.status,
    required this.meta,
    required this.onTap,
  });

  final String section;
  final String sectionLabel;
  final String title;
  final String status;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final group = switch (section) {
      'cleaning' => AppSection.cleaning,
      'restaurant' => AppSection.restaurant,
      'supermarket' => AppSection.supermarket,
      'delivery' => AppSection.delivery,
      _ => AppSection.platform,
    };
    return AppSurfaceCard(
      section: group,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: group.soft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 19,
                  color: group.ink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AlnadhaTokens.sectionTitle,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_left_rounded,
                color: AlnadhaTokens.muted,
              ),
            ],
          ),
          const SizedBox(height: 7),
          AppStatusBadge(label: status, intent: AppStatusIntent.info),
          const SizedBox(height: 7),
          Text(
            meta,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AlnadhaTokens.caption,
          ),
          const Divider(color: AlnadhaTokens.border),
          Row(
            children: [
              Expanded(child: Text(sectionLabel, style: AlnadhaTokens.caption)),
              const Text('عرض التفاصيل', style: AlnadhaTokens.caption),
              const Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: AlnadhaTokens.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class V6HomeQuickAction extends StatelessWidget {
  const V6HomeQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 21, color: AlnadhaTokens.primary),
          const SizedBox(height: 5),
          Text(
            label,
            style: AlnadhaTokens.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class V6GuestAccountPrompt extends StatelessWidget {
  const V6GuestAccountPrompt({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('احتفظ بطلباتك وعناوينك', style: AlnadhaTokens.sectionTitle),
        const SizedBox(height: 5),
        const Text(
          'سجّل الدخول لسهولة متابعة الطلبات وحفظ عناوين التوصيل.',
          style: AlnadhaTokens.caption,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppActionButton(label: 'دخول', onPressed: onLogin),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppActionButton(
                label: 'إنشاء حساب',
                variant: AppActionVariant.outlined,
                onPressed: onRegister,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
