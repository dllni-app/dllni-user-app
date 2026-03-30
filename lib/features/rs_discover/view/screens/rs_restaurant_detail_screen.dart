import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../rs_profile/view/widgets/section_title.dart';

@AutoRoutePage()
class RsRestaurantDetailScreen extends StatefulWidget {
  const RsRestaurantDetailScreen({super.key, required this.params});

  final RsRestaurantDetailParams params;

  @override
  State<RsRestaurantDetailScreen> createState() => _RsRestaurantDetailScreenState();
}

class _RsRestaurantDetailScreenState extends State<RsRestaurantDetailScreen> {
  int _selectedCategoryIndex = 0;

  static const List<String> _menuCategories = <String>[
    'الأكثر طلباً',
    'السندويشات',
    'الوجبات',
    'المشروبات',
  ];

  static const List<_OfferData> _offers = <_OfferData>[
    _OfferData(
      title: 'خصم 20% على الطلب الأول',
      subtitle: 'صالح حتى نهاية الأسبوع',
      color: Color(0xffFFEDD5),
      textColor: Color(0xffC2410C),
    ),
    _OfferData(
      title: 'توصيل مجاني',
      subtitle: 'على الطلبات فوق 50 ل.س',
      color: Color(0xffDCFCE7),
      textColor: Color(0xff166534),
    ),
    _OfferData(
      title: 'وجبة مجانية',
      subtitle: 'مع كل طلبين عائليين',
      color: Color(0xffE0E7FF),
      textColor: Color(0xff3730A3),
    ),
  ];

  static const List<_MenuItemData> _popularItems = <_MenuItemData>[
    _MenuItemData(
      title: 'برجر لحم مشوي',
      subtitle: 'لحم بقري، جبنة شيدر، صوص خاص',
      price: '32 ليرة',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
      badge: 'الأكثر طلباً',
    ),
    _MenuItemData(
      title: 'برجر دبل',
      subtitle: 'قطعتان لحم، جبنة مزدوجة، بطاطا',
      price: '41 ليرة',
      imageUrl:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
    ),
    _MenuItemData(
      title: 'بطاطا مقرمشة',
      subtitle: 'مع صلصة الجبن أو الباربكيو',
      price: '15 ليرة',
      imageUrl:
          'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  static const List<_ReviewData> _reviews = <_ReviewData>[
    _ReviewData(
      name: 'أحمد حمزة',
      comment: 'الطعم ممتاز جداً والتوصيل سريع. التغليف كان مرتباً جداً.',
      rating: 5,
      timeLabel: 'منذ يومين',
      avatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=256&q=80',
    ),
    _ReviewData(
      name: 'زينب علي',
      comment: 'جودة ممتازة لكن أتمنى لو كانت البطاطا أكثر سخونة.',
      rating: 4,
      timeLabel: 'منذ 4 أيام',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final params = widget.params;
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: context.onPrimary,
            surfaceTintColor: Colors.transparent,
            leading: _AppBarCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            actions: [
              _AppBarCircleButton(icon: Icons.share_outlined, onTap: () {}),
              const SizedBox(width: 8),
              _AppBarCircleButton(icon: Icons.favorite_border_rounded, onTap: () {}),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                params.heroImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [Color(0xffE5E7EB), Color(0xffD1D5DB)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -26),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                child: Column(
                  children: [
                    _IdentitySection(params: params),
                    const SizedBox(height: 14),
                    _QuickInfoSection(params: params),
                    const SizedBox(height: 18),
                    _SectionCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: SectionTitle(title: 'العروض الخاصة')),
                              InkWell(
                                onTap: () {},
                                child: AppText.labelLarge(
                                  'عرض الكل',
                                  color: context.primaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 98,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                final offer = _offers[index];
                                return Container(
                                  width: 190,
                                  padding: const EdgeInsetsDirectional.all(12),
                                  decoration: BoxDecoration(
                                    color: offer.color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppText.labelLarge(
                                        offer.title,
                                        color: offer.textColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      const SizedBox(height: 6),
                                      AppText.labelMedium(
                                        offer.subtitle,
                                        color: offer.textColor.withAlpha(190),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemCount: _offers.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                final isSelected = _selectedCategoryIndex == index;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    padding: const EdgeInsetsDirectional.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? context.primary
                                          : const Color(0xffF3F4F6),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: AppText.labelLarge(
                                      _menuCategories[index],
                                      color: isSelected
                                          ? context.onPrimary
                                          : const Color(0xff4B5563),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemCount: _menuCategories.length,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SectionTitle(title: 'الأكثر طلباً'),
                          const SizedBox(height: 12),
                          ..._popularItems.map(
                            (item) => Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: 10),
                              child: _PopularItemCard(item: item),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: 'تقييمات العملاء'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              AppText.displaySmall(
                                params.rating.toStringAsFixed(1),
                                color: context.primary,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (_) => const Padding(
                                        padding: EdgeInsetsDirectional.only(end: 2),
                                        child: Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: Color(0xffFBBF24),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AppText.labelMedium(
                                    'بناءً على ${params.reviewCountLabel} تقييم',
                                    color: const Color(0xff6B7280),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const _RatingBarRow(stars: 5, value: 0.88),
                          const _RatingBarRow(stars: 4, value: 0.60),
                          const _RatingBarRow(stars: 3, value: 0.24),
                          const _RatingBarRow(stars: 2, value: 0.12),
                          const _RatingBarRow(stars: 1, value: 0.07),
                          const SizedBox(height: 12),
                          ..._reviews.map(
                            (review) => Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: 12),
                              child: _ReviewTile(review: review),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: context.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsetsDirectional.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {},
                              child: AppText.labelLarge(
                                'عرض جميع التعليقات',
                                color: context.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: 'معلومات المطعم'),
                          const SizedBox(height: 12),
                          AppText.bodyMedium(
                            'مطعم يقدم وجبات طازجة يومياً بمكونات محلية وجودة عالية، مع اهتمام خاص بسرعة التحضير والتوصيل.',
                            color: const Color(0xff4B5563),
                          ),
                          const SizedBox(height: 12),
                          const _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'أوقات العمل',
                            value: 'يومياً: 10:00 ص - 12:00 ص',
                          ),
                          const SizedBox(height: 8),
                          const _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'العنوان',
                            value: 'دمشق، المزة - شارع المدارس',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xff22C55E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.chat_outlined),
                                  label: const Text('واتساب'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: context.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('الخريطة'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentitySection extends StatelessWidget {
  const _IdentitySection({required this.params});

  final RsRestaurantDetailParams params;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.restaurant, color: Color(0xff9CA3AF), size: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleLarge(
                      params.name,
                      color: const Color(0xff111827),
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 2),
                    AppText.bodyMedium(
                      params.categoryLabel,
                      color: const Color(0xff6B7280),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Color(0xff22C55E)),
                    const SizedBox(width: 4),
                    AppText.labelLarge(
                      '${params.rating.toStringAsFixed(1)} (${params.reviewCountLabel})',
                      color: const Color(0xff22C55E),
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
              _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: params.isOpen
                            ? const Color(0xff22C55E)
                            : const Color(0xffEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppText.labelLarge(
                      params.isOpen ? 'مفتوح الآن' : 'مغلق الآن',
                      color: params.isOpen
                          ? const Color(0xff22C55E)
                          : const Color(0xffEF4444),
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickInfoSection extends StatelessWidget {
  const _QuickInfoSection({required this.params});

  final RsRestaurantDetailParams params;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Expanded(
            child: _QuickInfoTile(
              icon: Icons.access_time_rounded,
              label: 'الوقت',
              value: params.deliveryTimeLabel,
            ),
          ),
          Expanded(
            child: _QuickInfoTile(
              icon: Icons.local_shipping_outlined,
              label: 'التوصيل',
              value: params.deliveryFeeLabel,
            ),
          ),
          Expanded(
            child: _QuickInfoTile(
              icon: Icons.navigation_outlined,
              label: 'المسافة',
              value: params.distanceLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfoTile extends StatelessWidget {
  const _QuickInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: context.primary),
        const SizedBox(height: 4),
        AppText.labelMedium(label, color: const Color(0xff9CA3AF)),
        const SizedBox(height: 2),
        AppText.labelLarge(
          value,
          color: const Color(0xff111827),
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

class _PopularItemCard extends StatelessWidget {
  const _PopularItemCard({required this.item});

  final _MenuItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsetsDirectional.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.badge != null)
                  Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 6),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.primaryContainer.withAlpha(35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: AppText.labelSmall(
                      item.badge!,
                      color: context.primaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                AppText.titleSmall(
                  item.title,
                  color: const Color(0xff111827),
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 4),
                AppText.bodySmall(
                  item.subtitle,
                  color: const Color(0xff6B7280),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppText.titleSmall(
                      item.price,
                      color: context.primary,
                      fontWeight: FontWeight.w800,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: context.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 14,
                          ),
                        ),
                        onPressed: () {},
                        child: AppText.labelLarge(
                          '+ إضافة',
                          color: context.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 84,
              height: 84,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xffE5E7EB)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final _ReviewData review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(review.avatarUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.labelLarge(
                  review.name,
                  color: const Color(0xff111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppText.labelSmall(review.timeLabel, color: const Color(0xff9CA3AF)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              review.rating,
              (_) => const Padding(
                padding: EdgeInsetsDirectional.only(end: 2),
                child: Icon(Icons.star_rounded, color: Color(0xffFBBF24), size: 15),
              ),
            ),
          ),
          const SizedBox(height: 6),
          AppText.bodySmall(review.comment, color: const Color(0xff4B5563)),
        ],
      ),
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  const _RatingBarRow({required this.stars, required this.value});

  final int stars;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: AppText.labelMedium(
              '$stars',
              color: const Color(0xff6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: const Color(0xffE5E7EB),
                color: const Color(0xffFBBF24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.primary),
        const SizedBox(width: 8),
        AppText.labelLarge(
          '$label:',
          color: const Color(0xff374151),
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: AppText.labelLarge(value, color: const Color(0xff6B7280)),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsetsDirectional.all(14),
      child: child,
    );
  }
}

class _AppBarCircleButton extends StatelessWidget {
  const _AppBarCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(228),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: context.primary),
      ),
    );
  }
}

class _OfferData {
  const _OfferData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
}

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;
  final String? badge;
}

class _ReviewData {
  const _ReviewData({
    required this.name,
    required this.comment,
    required this.rating,
    required this.timeLabel,
    required this.avatarUrl,
  });

  final String name;
  final String comment;
  final int rating;
  final String timeLabel;
  final String avatarUrl;
}


enum RsDiscoverSort { nearest, highestRated, fastestDelivery }

class RsDiscoverFilterOption {
  const RsDiscoverFilterOption({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class RsRestaurantListItem {
  const RsRestaurantListItem({
    required this.id,
    required this.name,
    required this.categoryLabel,
    required this.heroImageUrl,
    required this.rating,
    required this.deliveryTimeLabel,
    required this.deliveryFeeLabel,
    required this.distanceLabel,
    required this.reviewCountLabel,
    this.discountLabel,
    this.badgeLabel,
    this.isOpen = true,
    this.hasOffer = false,
    this.isFastDelivery = false,
    this.isNearby = false,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String categoryLabel;
  final String heroImageUrl;
  final double rating;
  final String deliveryTimeLabel;
  final String deliveryFeeLabel;
  final String distanceLabel;
  final String reviewCountLabel;
  final String? discountLabel;
  final String? badgeLabel;
  final bool isOpen;
  final bool hasOffer;
  final bool isFastDelivery;
  final bool isNearby;
  final bool isFavorite;
}

class RsRestaurantDetailParams {
  const RsRestaurantDetailParams({
    required this.id,
    required this.name,
    required this.categoryLabel,
    required this.heroImageUrl,
    required this.rating,
    required this.reviewCountLabel,
    required this.deliveryTimeLabel,
    required this.deliveryFeeLabel,
    required this.distanceLabel,
    this.discountLabel,
    this.badgeLabel,
    this.isOpen = true,
  });

  final String id;
  final String name;
  final String categoryLabel;
  final String heroImageUrl;
  final double rating;
  final String reviewCountLabel;
  final String deliveryTimeLabel;
  final String deliveryFeeLabel;
  final String distanceLabel;
  final String? discountLabel;
  final String? badgeLabel;
  final bool isOpen;
}