import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/personal_details_app_bar.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../../../core/widgets/v7_spot_state.dart';
import '../../data/models/get_shopping_list_model.dart';
import '../../domain/usecases/get_shopping_list_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import 'add_edit_shopping_list_screen.dart';
import 'shopping_list_details_screen.dart';

@AutoRoutePage(path: '/shopping_list')
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListCard extends StatelessWidget {
  const _ShoppingListCard({required this.item, required this.onTap});
  final GetShoppingListModelDataItem item;
  final VoidCallback onTap;

  String get _schedule {
    final schedule = item.schedule;
    if (schedule == null || schedule.isActive != true) return 'بدون جدول';
    final first = schedule.periods?.isNotEmpty == true
        ? schedule.periods!.first
        : null;
    final time = (first?.fromTime ?? '').trim();
    final suffix = time.isEmpty ? '' : ' • $time';
    if (schedule.frequencyType == 'once') return 'لمرة واحدة$suffix';
    if (schedule.frequencyType == 'monthly') {
      final days = schedule.monthDays;
      return days != null && days.isNotEmpty
          ? 'شهرياً • اليوم ${days.first}$suffix'
          : 'شهرياً$suffix';
    }
    if (schedule.frequencyType == 'weekly') {
      const names = <int, String>{
        1: 'الاثنين',
        2: 'الثلاثاء',
        3: 'الأربعاء',
        4: 'الخميس',
        5: 'الجمعة',
        6: 'السبت',
        7: 'الأحد',
      };
      final days =
          schedule.weekDays
              ?.map((v) => names[v])
              .whereType<String>()
              .join('، ') ??
          '';
      return days.isEmpty ? 'أسبوعياً$suffix' : days + suffix;
    }
    return 'مجدولة$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final active = item.isActive == true || item.schedule?.isActive == true;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6EAF0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const V7ArtTile(
                asset: V7Artwork.categorySupermarket,
                size: 56,
                background: Color(0xFFEAF6F0),
                radius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name ?? 'قائمة التسوق',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: SharedPlatformColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'نشطة',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF168A67),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.itemsCount ?? 0} منتجات',
                      style: const TextStyle(
                        color: SharedPlatformColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _schedule,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SharedPlatformColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_left_rounded,
                color: SharedPlatformColors.primary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) =>
          getIt<ProfileBloc>()
            ..add(GetShoppingListEvent(params: GetShoppingListParams())),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: Column(
          children: [
            const PersonalDetailsAppBar(
              title: 'قوائم التسوق',
              section: 'supermarket',
            ),
            Expanded(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {},
                buildWhen: (previous, current) =>
                    previous.shoppingListStatus != current.shoppingListStatus ||
                    previous.shoppingList != current.shoppingList,
                builder: (context, state) {
                  if (state.shoppingListStatus == BlocStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.shoppingListStatus == BlocStatus.failed) {
                    return Center(
                      child: FailureWidget(
                        message: state.errorMessage.toString(),
                        onRetry: () {
                          context.read<ProfileBloc>().add(
                            GetShoppingListEvent(
                              params: GetShoppingListParams(),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  if (state.shoppingListStatus == BlocStatus.success) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(
                          GetShoppingListEvent(params: GetShoppingListParams()),
                        );
                      },
                      child: state.shoppingList?.data?.isEmpty ?? true
                          ? const Center(
                              child: V7SpotState(
                                asset: V7Artwork.empty,
                                title: 'لا توجد قوائم تسوق',
                                description:
                                    'أنشئ قائمة لتسهيل مشترياتك القادمة.',
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.shoppingList!.data!.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, index) {
                                final item = state.shoppingList!.data![index];
                                return _ShoppingListCard(
                                  item: item,
                                  onTap: () {
                                    context.pushRoute(
                                      '/shopping_list_details',
                                      arguments: ShoppingListDetailsScreenArgs(
                                        shoppingListId: item.id ?? 0,
                                        shoppingListName: item.name ?? '',
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          color: const Color(0xFFF6F7F9),
          child: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () async {
                  final result = await context.pushRoute(
                    '/add_edit_shopping_list',
                    arguments: AddEditShoppingListScreenArgs(
                      profileBloc: context.read<ProfileBloc>(),
                    ),
                  );
                  if (!context.mounted) return;
                  if (result == true) {
                    context.read<ProfileBloc>().add(
                      GetShoppingListEvent(params: GetShoppingListParams()),
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 50),
                  decoration: BoxDecoration(
                    color: const Color(0xFF168A67),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'إضافة قائمة تسوق',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
