import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/failure_widget.dart';
import '../../../../profile/data/models/shopping_lists_api_models.dart';
import '../../../../profile/domain/usecases/add_shopping_list_item_use_case.dart';
import '../../../../profile/view/manager/shopping_lists_cubit.dart';
import '../../manager/bloc/sm_stores_bloc.dart';

class ShoppingListsDialog extends StatefulWidget {
  const ShoppingListsDialog({super.key, required this.masterProductId});

  final int masterProductId;

  @override
  State<ShoppingListsDialog> createState() => _ShoppingListsDialogState();
}

class _ShoppingListsDialogState extends State<ShoppingListsDialog> {
  int? _addingToListId;

  Future<void> _addProductToList(ShoppingListSummaryModel item) async {
    if (_addingToListId != null) return;
    setState(() => _addingToListId = item.id);

    final res = await getIt<AddShoppingListItemUseCase>()(
      AddShoppingListItemParams(
        shoppingListId: item.id,
        masterProductId: widget.masterProductId,
        quantity: 1,
      ),
    );

    if (!mounted) return;

    await res.fold(
      (failure) async {
        setState(() => _addingToListId = null);
        AppToast.showToast(
          context: context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (_) async {
        setState(() => _addingToListId = null);
        context.read<SmStoresBloc>().add(LoadShoppingListsEvent());
        await getIt<ShoppingListsCubit>().loadShoppingLists(showLoader: false);
        if (!mounted) return;
        AppToast.showToast(
          context: context,
          message: 'تمت إضافة المنتج إلى القائمة',
          type: ToastificationType.success,
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'قوائم التسوق',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                InkWell(
                  onTap: () => context.pop(),
                  customBorder: const CircleBorder(),
                  child: Ink(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.x,
                        size: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SmStoresBloc, SmStoresState>(
              buildWhen: (previous, current) =>
                  previous.shoppingListsStatus != current.shoppingListsStatus ||
                  previous.shoppingLists != current.shoppingLists ||
                  previous.shoppingListsErrorMessage !=
                      current.shoppingListsErrorMessage,
              builder: (context, state) {
                switch (state.shoppingListsStatus) {
                  case BlocStatus.loading:
                  case BlocStatus.init:
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  case BlocStatus.failed:
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FailureWidget(
                            message:
                                state.shoppingListsErrorMessage?.toString() ??
                                    'حدث خطأ',
                            onRetry: () => context.read<SmStoresBloc>().add(
                                  LoadShoppingListsEvent(),
                                ),
                          ),
                        ],
                      ),
                    );
                  case BlocStatus.success:
                    if (state.shoppingLists.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: AppText.labelMedium(
                          'لا توجد قوائم',
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.shoppingLists.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final list = state.shoppingLists[index];
                          return _ShoppingListTile(
                            item: list,
                            isAdding: _addingToListId == list.id,
                            onTap: () => _addProductToList(list),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingListTile extends StatelessWidget {
  const _ShoppingListTile({
    required this.item,
    required this.isAdding,
    required this.onTap,
  });

  final ShoppingListSummaryModel item;
  final bool isAdding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isAdding ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.bagShopping,
                    size: 18,
                    color: Color(0xFF1E3A8A),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          item.name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                          ),
                        ),
                        if (item.description != null &&
                            item.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          AppText(
                            item.description!,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    '${item.itemsCount} منتج',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdding)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
