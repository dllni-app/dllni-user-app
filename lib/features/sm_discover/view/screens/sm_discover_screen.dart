import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../widgets/discover_tab_bar.dart';
import '../widgets/store_card.dart';

@AutoRoutePage(path: "/discover")
class SmDiscoverScreen extends StatefulWidget {
  const SmDiscoverScreen({super.key, this.selectedView = 0});
  final int selectedView;

  @override
  State<SmDiscoverScreen> createState() => _SmDiscoverScreenState();
}

class _SmDiscoverScreenState extends State<SmDiscoverScreen> {
  late int _selectedView;
  @override
  void initState() {
    _selectedView = widget.selectedView;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedView == 0
          ? Color(0xFFF9FAFB)
          : Color(0xFFEFEFEF),
      body: PopScope(
        canPop: _selectedView == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (_selectedView == 1) {
            _selectedView = 0;
            setState(() {});
          }
        },
        child: IndexedStack(
          index: _selectedView,
          children: [
            _MainDiscoverView(
              onSearchTap: () {
                if (_selectedView == 0) {
                  _selectedView = 1;
                  setState(() {});
                }
              },
            ),
            _SearchView(),
          ],
        ),
      ),
    );
  }
}

class _MainDiscoverView extends StatelessWidget {
  const _MainDiscoverView({this.onSearchTap});
  final void Function()? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSimpleAppBarWithSearch(
          title: "تصفح المتاجر",
          onSearchTap: onSearchTap,
          onSearchChanged: (value) {},
          onFilterTap: () {},
        ),
        SizedBox(height: 16),
        DiscoverTabBar(items: discoverTabs, onChanged: (index) {}),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              AppText(
                "124 متجر متاح",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      AppText(
                        "ترتيب حسب: الأقرب",
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      FaIcon(
                        FontAwesomeIcons.angleDown,
                        size: 12,
                        color: Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(20),
            itemBuilder: (_, index) => StoreCard(store: stores[index]),
            separatorBuilder: (_, _) => SizedBox(height: 16),
            itemCount: stores.length,
          ),
        ),
      ],
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24 + MediaQuery.paddingOf(context).top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchFieldWithVoice(
            backgroundColor: Color(0xFFF9FAFB),
            onVoiceTap: () {},
            onSearch: (search) {},
          ),
        ),
        SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20),
            FaIcon(
              FontAwesomeIcons.locationDot,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.all(Radius.circular(2)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 2),
                  AppText(
                    "المنزل",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 16 / 15,
                    ),
                  ),
                  SizedBox(width: 9),
                  FaIcon(
                    FontAwesomeIcons.angleDown,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                    weight: 1.5,
                  ),
                  SizedBox(width: 2),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Divider(height: 1, color: Color(0xFFDBDCDE)),
        SizedBox(height: 16),
        SearchesGroup(
          title: "الأكثر بحثاً من قبل المستخدمين",
          searches: [
            "لبن المراعي",
            "أندومي",
            "حليب مكثف",
            "حليب هوى الشام",
            "طحين كاتو",
            "رز كبسة",
          ],
          onSearchTap: (search) {
            print(search);
          },
        ),
        SizedBox(height: 16),
        Divider(height: 1, color: Color(0xFFDBDCDE)),
        SizedBox(height: 16),
        SearchesGroup(
          title: "تاريخ البحث",
          searches: [
            "لبن المراعي",
            "أندومي",
            "حليب مكثف",
            "حليب هوى الشام",
            "طحين كاتو",
            "رز كبسة",
          ],
          onSearchTap: (search) {
            print(search);
          },
          onDeleteAllTap: () {},
        ),
      ],
    );
  }
}

class SearchesGroup extends StatelessWidget {
  const SearchesGroup({
    super.key,
    required this.searches,
    required this.title,
    this.onDeleteAllTap,
    required this.onSearchTap,
  });
  final List<String> searches;
  final String title;
  final void Function(String search) onSearchTap;
  final void Function()? onDeleteAllTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
              if (onDeleteAllTap != null)
                InkWell(
                  onTap: onDeleteAllTap,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: AppText(
                    " مسح الكل ",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      height: 19 / 10,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: searches
                .map<_SearchChip>(
                  (search) => _SearchChip(
                    label: search,
                    onTap: () {
                      onSearchTap(search);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({super.key, this.onTap, required this.label});
  final void Function()? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(22)),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 4, 8, 5),
        decoration: BoxDecoration(
          color: Color(0xFFDADCEA),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 12,
              color: AppColors.primary,
            ),
            SizedBox(width: 4),
            AppText(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w300,
                height: 19 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<DiscoverTabBarItem> discoverTabs = [
  DiscoverTabBarItem(title: "الكل"),
  DiscoverTabBarItem(
    title: "الأقرب",
    icon: const FaIcon(
      FontAwesomeIcons.locationDot,
      size: 14,
      color: Color(0xFF9CA3AF),
    ),
  ),
  DiscoverTabBarItem(
    title: "الأعلى تقييماً",
    icon: const FaIcon(
      FontAwesomeIcons.solidStar,
      size: 15,
      color: Color(0xFFFACC15),
    ),
  ),
  DiscoverTabBarItem(
    title: "الأسرع توصيلاً",
    icon: const FaIcon(
      FontAwesomeIcons.bolt,
      size: 14,
      color: Color(0xFF4CAF50),
    ),
  ),
  DiscoverTabBarItem(
    title: "يوجد عروض",
    icon: const FaIcon(
      FontAwesomeIcons.tag,
      size: 12,
      color: Color(0xFFEF4444),
    ),
  ),
  DiscoverTabBarItem(
    title: "مفتوح الآن",
    icon: const FaIcon(
      FontAwesomeIcons.solidClock,
      size: 14,
      color: Color(0xFF22C55E), // أزرق
    ),
  ),
];

final List<StoreData> stores = [
  StoreData(
    image: AppImages.store,
    name: "سوبر ماركت الأطرش",
    description: "مفرزات • معلبات • منظفات • تسالي",
    rating: 4.5,
    distance: 1.2,
    deliveryPrice: "15 ل.س",
    time: "20-30 دقيقة",
    discount: 20,
    isFavorite: true,
  ),
  StoreData(
    image: AppImages.store,
    name: "ماركت المدينة",
    description: "خضار • فواكه • مواد غذائية",
    rating: 4.2,
    distance: 0.8,
    deliveryPrice: "10 ل.س",
    time: "15-25 دقيقة",
    discount: 0,
  ),
  StoreData(
    image: AppImages.store,
    name: "هايبر الشام",
    description: "عروض يومية • أسعار منافسة",
    rating: 4.7,
    distance: 2.3,
    deliveryPrice: "20 ل.س",
    time: "25-35 دقيقة",
    discount: 30,
  ),
  StoreData(
    image: AppImages.store,
    name: "سوق الخير",
    description: "مواد تنظيف • مستلزمات منزلية",
    rating: 4.0,
    distance: 3.1,
    deliveryPrice: "12 ل.س",
    time: "30-40 دقيقة",
    discount: 10,
  ),
];
