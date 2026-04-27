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
import 'add_edit_shopping_list_screen.dart';
import 'shopping_list_details_screen.dart';

@AutoRoutePage(path: "/shopping_list")
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListCard extends StatelessWidget {
  final GetShoppingListModelDataItem item;

  final VoidCallback onTap;
  const _ShoppingListCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Color(0x0D000000),
            ),
          ],
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0x2B22C55E),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const FaIcon(
                FontAwesomeIcons.bagShopping,
                size: 20,
                color: Color(0xFF4CAF50),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    item.name ?? '',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '${item.itemsCount ?? 0} منتج',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: FaIcon(
                FontAwesomeIcons.penToSquare,
                size: 17,
                color: Color(0xFF64748B),
              ),
            ),
          ],
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
        backgroundColor: const Color(0xFFF3F4F6),
        body: Column(
          children: [
            AppSimpleAppBar2(
              title: 'قائمة التسوق الذكي',
              arrowBackType: ArrowBackType.cupertino,
            ),
            Expanded(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {},
                buildWhen: (previous, current) =>
                    previous.shoppingListStatus != current.shoppingListStatus,
                builder: (context, state) {
                  if (state.shoppingListStatus == BlocStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.shoppingListStatus == BlocStatus.failed) {
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
                  } else if (state.shoppingListStatus == BlocStatus.success) {
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
                              itemBuilder: (_, index) => _ShoppingListCard(
                                item: state.shoppingList!.data![index],
                                onTap: () {
                                  context.pushRoute(
                                    "/shopping_list_details",
                                    arguments: ShoppingListDetailsScreenArgs(
                                      shoppingListId:
                                          state.shoppingList!.data![index].id ??
                                          0,
                                      shoppingListName:
                                          state
                                              .shoppingList!
                                              .data![index]
                                              .name ??
                                          '',
                                    ),
                                  );
                                },
                              ),
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
          color: const Color(0xFFF3F4F6),
          child: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () async {
                  final result = await context.pushRoute(
                    "/add_edit_shopping_list",
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
                    color: Color(0xFFFF7A00),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: AppText(
                    "إضافة قائمة تسوق جديدة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFEEFF),
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
