import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../data/models/get_shopping_list_model.dart';
import '../../domain/usecases/get_shopping_list_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/shopping_list_icon.dart';
import 'add_edit_shopping_list_screen.dart';
import 'shopping_list_details_screen.dart';

@AutoRoutePage(path: '/shopping_list')
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListCard extends StatelessWidget {
  final GetShoppingListModelDataItem item;
  final VoidCallback onTap;

  const _ShoppingListCard({required this.item, required this.onTap});

  String _scheduleLabel() {
    final schedule = item.schedule;
    if (schedule == null || schedule.isActive != true) return 'بدون جدولة';

    final period = schedule.periods?.isNotEmpty == true
        ? schedule.periods!.first
        : null;
    final time = period?.fromTime?.trim();
    final timeLabel = time == null || time.isEmpty ? '' : ' • $time';

    switch (schedule.frequencyType) {
      case 'weekly':
        const days = <int, String>{
          1: 'الاثنين',
          2: 'الثلاثاء',
          3: 'الأربعاء',
          4: 'الخميس',
          5: 'الجمعة',
          6: 'السبت',
          7: 'الأحد',
        };
        final selected =
            schedule.weekDays
                ?.map((day) => days[day])
                .whereType<String>()
                .join('، ') ??
            '';
        return selected.isEmpty
            ? 'أسبوعياً$timeLabel'
            : 'كل $selected$timeLabel';
      case 'monthly':
        final day = schedule.monthDays?.isNotEmpty == true
            ? schedule.monthDays!.first.toString()
            : null;
        return day == null
            ? 'شهرياً$timeLabel'
            : 'يوم $day من كل شهر$timeLabel';
      case 'once':
        return 'مرة واحدة$timeLabel';
      default:
        return 'جدولة نشطة$timeLabel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = shoppingListIconOptionForKey(
      shoppingListIconKeyFromDescription(item.description),
    );
    final active = item.isActive == true || item.schedule?.isActive == true;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  icon.icon,
                  size: 20,
                  color: const Color(0xFF168A67),
                ),
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
                            item.name ?? 'قائمة تسوق',
                            style: const TextStyle(
                              color: Color(0xFF172033),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF6F1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'نشطة',
                              style: TextStyle(
                                color: Color(0xFF168A67),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item.itemsCount ?? 0} منتج',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scheduleLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active
                            ? const Color(0xFF168A67)
                            : const Color(0xFF98A2B3),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFF98A2B3),
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
            AppSimpleAppBar2(
              accentColor: SharedPlatformColors.supermarket,
              title: 'قوائم التسوق',
              arrowBackType: ArrowBackType.cupertino,
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
                          ? const Center(child: Text('لا توجد قوائم تسوق'))
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
                  padding: const EdgeInsets.only(top: 14, bottom: 13),
                  decoration: const BoxDecoration(
                    color: Color(0xFF168A67),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: AppText(
                    'إضافة قائمة تسوق جديدة',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 16 / 14,
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
