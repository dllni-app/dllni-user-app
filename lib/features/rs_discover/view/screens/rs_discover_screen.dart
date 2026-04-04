import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/app_app_bars.dart';
import '../../domain/discover_tab_query.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import '../widgets/discover_tab_bar.dart';
import '../widgets/store_card.dart';

@AutoRoutePage(path: "/discover")
class RsDiscoverScreen extends StatefulWidget {
  const RsDiscoverScreen({super.key, this.selectedView = 0});

  final int selectedView;

  @override
  State<RsDiscoverScreen> createState() => _RsDiscoverScreenState();
}

class _RsDiscoverScreenState extends State<RsDiscoverScreen> {
  late int _selectedView;

  @override
  void initState() {
    _selectedView = widget.selectedView;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RsDiscoverBloc>()..add(FetchDiscoverRestaurantsEvent(isReload: true)),
      child: Scaffold(
        backgroundColor: _selectedView == 0 ? Color(0xFFF9FAFB) : Color(0xFFEFEFEF),
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
                  setState(() => _selectedView = 1);
                },
              ),
              _SearchView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainDiscoverView extends StatelessWidget {
  const _MainDiscoverView({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSimpleAppBarWithSearch(
          title: "اكتشف",
          onSearchTap: onSearchTap,
          onSearchChanged: (value) {
            context.read<RsDiscoverBloc>().add(DiscoverSearchQueryChangedEvent(value));
          },
        ),
        SizedBox(height: 16),
        DiscoverTabBar(
          items: discoverTabs,
          onChanged: (index) {
            context.read<RsDiscoverBloc>().add(DiscoverTabChangedEvent(index));
          },
        ),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
            buildWhen: (p, c) => p.totalCount != c.totalCount || p.selectedTabIndex != c.selectedTabIndex,
            builder: (context, state) {
              return Row(
                children: [
                  AppText(
                    "${state.totalCount} متجر متاح",
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                  ),
                  Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        "ترتيب حسب: ${DiscoverTabQuery.sortLabelAr(state.selectedTabIndex)}",
                        style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                      ),
                      SizedBox(width: 4),
                      FaIcon(FontAwesomeIcons.angleDown, size: 12, color: Color(0xFF4CAF50)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 4),
        Expanded(
          child: BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
            builder: (context, state) {
              final p = state.restaurants;
              if (p.isFailed) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText.labelLarge(p.errorMessage),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.read<RsDiscoverBloc>().add(FetchDiscoverRestaurantsEvent(isReload: true));
                          },
                          child: AppText('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (p.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (p.isEmpty) {
                return Center(
                  child: AppText('لا توجد مطاعم', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
                );
              }
              final showFooter = !p.isEndPage && p.status == BlocStatus.loading && p.list.isNotEmpty;
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    final m = notification.metrics;
                    if (m.pixels >= m.maxScrollExtent - 240) {
                      final bloc = context.read<RsDiscoverBloc>();
                      final r = bloc.state.restaurants;
                      if (r.isEndPage || r.status == BlocStatus.loading) {
                        return false;
                      }
                      bloc.add(FetchDiscoverRestaurantsEvent(loadMore: true));
                    }
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(20),
                  itemCount: p.list.length + (showFooter ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= p.list.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                      );
                    }
                    return StoreCard(store: p.list[index]);
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 16),
                ),
              );
            },
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
          // child: SearchFieldWithVoice(backgroundColor: Color(0xFFF9FAFB), onVoiceTap: () {}, onSearch: (search) {}),
        ),
        SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20),
            FaIcon(FontAwesomeIcons.locationDot, size: 18, color: context.primary),
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
                    style: TextStyle(color: context.primaryContainer, fontSize: 15, fontWeight: FontWeight.w500, height: 16 / 15),
                  ),
                  SizedBox(width: 9),
                  FaIcon(FontAwesomeIcons.angleDown, size: 16, color: Color(0xFF9CA3AF), weight: 1.5),
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
          searches: ["لبن المراعي", "أندومي", "حليب مكثف", "حليب هوى الشام", "طحين كاتو", "رز كبسة"],
          onSearchTap: (search) {
            print(search);
          },
        ),
        SizedBox(height: 16),
        Divider(height: 1, color: Color(0xFFDBDCDE)),
        SizedBox(height: 16),
        SearchesGroup(
          title: "تاريخ البحث",
          searches: ["لبن المراعي", "أندومي", "حليب مكثف", "حليب هوى الشام", "طحين كاتو", "رز كبسة"],
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
  const SearchesGroup({super.key, required this.searches, required this.title, this.onDeleteAllTap, required this.onSearchTap});

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
                style: TextStyle(color: Colors.black, fontSize: 14, height: 16 / 14),
              ),
              if (onDeleteAllTap != null)
                InkWell(
                  onTap: onDeleteAllTap,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: AppText(
                    " مسح الكل ",
                    style: TextStyle(color: context.primaryContainer, fontSize: 10, fontWeight: FontWeight.w300, height: 19 / 10),
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
  const _SearchChip({this.onTap, required this.label});

  final void Function()? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(22)),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 4, 8, 5),
        decoration: BoxDecoration(color: Color(0xFFDADCEA), borderRadius: BorderRadius.all(Radius.circular(22))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.magnifyingGlass, size: 12, color: context.primary),
            SizedBox(width: 4),
            AppText(
              label,
              style: TextStyle(color: context.primary, fontSize: 10, fontWeight: FontWeight.w300, height: 19 / 10),
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
    icon: const FaIcon(FontAwesomeIcons.locationDot, size: 14, color: Color(0xFF9CA3AF)),
  ),
  DiscoverTabBarItem(
    title: "الأعلى تقييماً",
    icon: const FaIcon(FontAwesomeIcons.solidStar, size: 15, color: Color(0xFFFACC15)),
  ),
  DiscoverTabBarItem(
    title: "الأسرع توصيلاً",
    icon: const FaIcon(FontAwesomeIcons.bolt, size: 14, color: Color(0xFF4CAF50)),
  ),
  DiscoverTabBarItem(
    title: "يوجد عروض",
    icon: const FaIcon(FontAwesomeIcons.tag, size: 12, color: Color(0xFFEF4444)),
  ),
  DiscoverTabBarItem(
    title: "مفتوح الآن",
    icon: const FaIcon(FontAwesomeIcons.solidClock, size: 14, color: Color(0xFF22C55E)),
  ),
];
