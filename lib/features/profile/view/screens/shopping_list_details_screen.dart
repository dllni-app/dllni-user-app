import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../manager/shopping_list_detail_cubit.dart';
import '../../../sm_discover/view/screens/sm_discover_screen.dart';

export '../../data/models/shopping_lists_api_models.dart'
    show ShoppingListDetailsArgs;

@AutoRoutePage(path: "/shopping_list_details")
class ShoppingListDetailsScreen extends StatefulWidget {
  const ShoppingListDetailsScreen({super.key, required this.args});

  final ShoppingListDetailsArgs args;

  @override
  State<ShoppingListDetailsScreen> createState() =>
      _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  late final ShoppingListDetailCubit _shoppingListDetailCubit;

  @override
  void initState() {
    super.initState();
    _shoppingListDetailCubit = getIt<ShoppingListDetailCubit>();
    _shoppingListDetailCubit.loadShoppingList(widget.args.shoppingListId);
  }

  Future<void> _refresh() async {
    await _shoppingListDetailCubit.loadShoppingList(
      widget.args.shoppingListId,
      showLoader: false,
    );
  }

  Future<void> _confirmDeleteList() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف قائمة التسوق'),
        content: const Text('هل تريد حذف هذه القائمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    final deleted = await _shoppingListDetailCubit.deleteShoppingList();
    if (deleted && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShoppingListDetailCubit>.value(
      value: _shoppingListDetailCubit,
      child: BlocListener<ShoppingListDetailCubit, ShoppingListDetailState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage &&
            (c.errorMessage?.isNotEmpty == true),
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null || message.isEmpty) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: BlocBuilder<ShoppingListDetailCubit, ShoppingListDetailState>(
            builder: (context, state) {
              final shoppingList = state.shoppingList;
              final headerTitle =
                  shoppingList?.name ??
                  widget.args.title ??
                  "قائمة التسوق الذكي";
              if (state.status == BlocStatus.loading ||
                  state.status == BlocStatus.init) {
                return Column(
                  children: [
                    _ShoppingListDetailsHeader(title: headerTitle),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
              if (shoppingList == null) {
                return Column(
                  children: [
                    _ShoppingListDetailsHeader(title: headerTitle),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 220),
                            Center(child: Text('تعذر تحميل القائمة')),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _ShoppingListDetailsHeader(title: headerTitle),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          spacing: 16,
                          children: [
                            ListView.separated(
                              itemCount: shoppingList.items.length,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, index) {
                                final item = shoppingList.items[index];
                                final isUpdating = state.updatingItemIds
                                    .contains(item.id);
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Color(0x0D000000),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 12,
                                    children: [
                                      Row(
                                        spacing: 12,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              color: Color(0x2B22C55E),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            child: const FaIcon(
                                              FontAwesomeIcons.bagShopping,
                                              size: 20,
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                          Expanded(
                                            child: AppText(
                                              item.name,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                height: 24 / 16,
                                              ),
                                            ),
                                          ),
                                          CupertinoSwitch(
                                            value: item.isIncluded,
                                            activeColor: const Color(
                                              0xFF43B654,
                                            ),
                                            onChanged: (value) {
                                              context
                                                  .read<
                                                    ShoppingListDetailCubit
                                                  >()
                                                  .toggleItemIncluded(
                                                    itemId: item.id,
                                                    isIncluded: value,
                                                  );
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        spacing: 32,
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: InkWell(
                                              onTap: isUpdating
                                                  ? null
                                                  : () {
                                                      final updated =
                                                          (item.quantity - 1)
                                                              .clamp(1, 9999)
                                                              .toDouble();
                                                      context
                                                          .read<
                                                            ShoppingListDetailCubit
                                                          >()
                                                          .updateItemQuantityOptimistic(
                                                            itemId: item.id,
                                                            quantity: updated,
                                                          );
                                                    },
                                              customBorder:
                                                  const CircleBorder(),
                                              child: const Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.minus,
                                                  size: 24,
                                                  color: Color(0xFF43B654),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: isUpdating
                                                ? const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  )
                                                : AppText(
                                                    item.quantity.toStringAsFixed(
                                                      item.quantity
                                                                  .truncateToDouble() ==
                                                              item.quantity
                                                          ? 0
                                                          : 1,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Color(0xFF111827),
                                                      fontSize: 36,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 40 / 36,
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: InkWell(
                                              onTap: isUpdating
                                                  ? null
                                                  : () {
                                                      context
                                                          .read<
                                                            ShoppingListDetailCubit
                                                          >()
                                                          .updateItemQuantityOptimistic(
                                                            itemId: item.id,
                                                            quantity:
                                                                (item.quantity +
                                                                        1)
                                                                    .toDouble(),
                                                          );
                                                    },
                                              customBorder:
                                                  const CircleBorder(),
                                              child: const Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.plus,
                                                  size: 24,
                                                  color: Color(0xFF43B654),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context
                                              .read<ShoppingListDetailCubit>()
                                              .deleteItem(item.id);
                                        },
                                        child: Container(
                                          width: context.width,
                                          padding: const EdgeInsets.only(
                                            top: 14,
                                            bottom: 13,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0x1464748B),
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                            border: Border.all(
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          child: AppText(
                                            "حذف المنتج من القائمة",
                                            style: TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              height: 16 / 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IgnorePointer(
                              ignoring: state.isReorderToCartLoading,
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .read<ShoppingListDetailCubit>()
                                      .reorderToCart(storeId: 2);
                                },
                                child: Container(
                                  width: context.width,
                                  padding: const EdgeInsets.only(
                                    top: 14,
                                    bottom: 13,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF7A00),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  child: state.isReorderToCartLoading
                                      ? const SizedBox(
                                          height: 20,
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFFFEEFF),
                                              ),
                                            ),
                                          ),
                                        )
                                      : AppText(
                                          "إعادة طلب هذه  القائمة",
                                          style: TextStyle(
                                            color: Color(0xFFFFEEFF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            height: 16 / 14,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Row(
                              spacing: 22,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await context.pushRoute(
                                        '/sm_discover',
                                        arguments: SmDiscoverScreenParams(
                                          selectedView: 1,
                                          expandSearch: true,
                                          shoppingListId:
                                              widget.args.shoppingListId,
                                        ),
                                      );
                                      if (!mounted) return;
                                      await _refresh();
                                    },
                                    onLongPress: () async {
                                      await showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        builder: (sheetContext) {
                                          return BlocProvider.value(
                                            value: context
                                                .read<
                                                  ShoppingListDetailCubit
                                                >(),
                                            child: EditSheet(
                                              initialName: shoppingList.name,
                                              initialDescription:
                                                  shoppingList.description ??
                                                  '',
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        top: 13,
                                        bottom: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFF1E3A8A),
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                      child: AppText(
                                        "تعديل قائمة التسوق",
                                        style: TextStyle(
                                          color: Color(0xFF1E3A8A),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          height: 16 / 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _confirmDeleteList,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        top: 13,
                                        bottom: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFDC2626),
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                      child: AppText(
                                        "حذف قائمة التسوق",
                                        style: TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          height: 16 / 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                await showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  builder: (sheetContext) {
                                    return BlocProvider.value(
                                      value: context
                                          .read<ShoppingListDetailCubit>(),
                                      child: EditSheet(
                                        initialName: shoppingList.name,
                                        initialDescription:
                                            shoppingList.description ?? '',
                                      ),
                                    );
                                  },
                                );
                              },
                              child: AppText(
                                'تعديل بيانات القائمة',
                                style: TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class EditSheet extends StatefulWidget {
  const EditSheet({
    super.key,
    required this.initialName,
    required this.initialDescription,
  });

  final String initialName;
  final String initialDescription;

  @override
  State<EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<EditSheet> {
  static const Color _fieldFill = Color(0xFFF9FAFB);
  static const Color _borderIdle = Color(0xFFE5E7EB);
  static const Color _brandOrange = Color(0xFFFF7A00);
  static const Color _accentBlue = Color(0xFF1E3A8A);
  static const Color _textPrimary = Color(0xFF2F2B3D);
  static const Color _hintColor = Color(0xFF9CA3AF);

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    Widget? prefixIcon,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: _hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      filled: true,
      fillColor: _fieldFill,
      isDense: true,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIcon != null
          ? const BoxConstraints(minWidth: 52, minHeight: 48)
          : null,
      border: border(_borderIdle),
      enabledBorder: border(_borderIdle),
      focusedBorder: border(_brandOrange, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    const fieldTextStyle = TextStyle(
      color: _textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.penToSquare,
                  size: 19,
                  color: _accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'تعديل بيانات القائمة',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppText.bodyMedium(
            'اسم القائمة',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            cursorColor: _brandOrange,
            style: fieldTextStyle,
            textInputAction: TextInputAction.next,
            decoration: _fieldDecoration(
              hintText: 'مثال: تسوق نهاية الأسبوع',
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.pen,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AppText.bodyMedium(
                'الوصف',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
              const SizedBox(width: 6),
              AppText.bodySmall(
                '(اختياري)',
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            cursorColor: _brandOrange,
            style: fieldTextStyle,
            textAlignVertical: TextAlignVertical.top,
            minLines: 3,
            maxLines: 5,
            decoration: _fieldDecoration(
              hintText: 'ملاحظات أو تفاصيل عن هذه القائمة…',
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('الاسم مطلوب')));
                  return;
                }
                await context
                    .read<ShoppingListDetailCubit>()
                    .updateShoppingList(
                      name: name,
                      description: _descriptionController.text.trim(),
                    );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('حفظ التعديل'),
            ),
          ),
        ],
      ),
    );
  }
}

// class StoreIdSheet extends StatefulWidget {
//   const StoreIdSheet({super.key});

//   @override
//   State<StoreIdSheet> createState() => _StoreIdSheetState();
// }

// class _StoreIdSheetState extends State<StoreIdSheet> {
//   static const Color _fieldFill = Color(0xFFF9FAFB);
//   static const Color _borderIdle = Color(0xFFE5E7EB);
//   static const Color _brandOrange = Color(0xFFFF7A00);
//   static const Color _textPrimary = Color(0xFF2F2B3D);
//   static const Color _hintColor = Color(0xFF9CA3AF);

//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   InputDecoration _fieldDecoration({
//     required String hintText,
//     Widget? prefixIcon,
//   }) {
//     OutlineInputBorder border(Color color, [double width = 1]) {
//       return OutlineInputBorder(
//         borderRadius: const BorderRadius.all(Radius.circular(14)),
//         borderSide: BorderSide(color: color, width: width),
//       );
//     }

//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: const TextStyle(
//         color: _hintColor,
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//         height: 1.35,
//       ),
//       filled: true,
//       fillColor: _fieldFill,
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       prefixIcon: prefixIcon,
//       prefixIconConstraints: prefixIcon != null
//           ? const BoxConstraints(minWidth: 52, minHeight: 48)
//           : null,
//       border: border(_borderIdle),
//       enabledBorder: border(_borderIdle),
//       focusedBorder: border(_brandOrange, 1.5),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const fieldTextStyle = TextStyle(
//       color: _textPrimary,
//       fontSize: 15,
//       fontWeight: FontWeight.w500,
//       height: 1.4,
//     );

//     return BlocProvider.value(
//       value: context.read<ShoppingListDetailCubit>(),
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(
//           16,
//           16,
//           16,
//           MediaQuery.of(context).viewInsets.bottom + 24,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 44,
//                   height: 44,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF4ED),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: const Color(0xFFFFE0CC)),
//                   ),
//                   child: const FaIcon(
//                     FontAwesomeIcons.store,
//                     size: 20,
//                     color: _brandOrange,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: AppText(
//                     'أدخل رقم المتجر',
//                     style: const TextStyle(
//                       color: Color(0xFF111827),
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       height: 1.25,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             AppText.bodyMedium(
//               'رقم المتجر',
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF374151),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _controller,
//               cursorColor: _brandOrange,
//               style: fieldTextStyle,
//               keyboardType: TextInputType.number,
//               textInputAction: TextInputAction.done,
//               decoration: _fieldDecoration(
//                 hintText: 'مثال: 101',
//                 prefixIcon: Padding(
//                   padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
//                   child: Container(
//                     width: 36,
//                     height: 36,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: const Color(0xFFE5E7EB)),
//                     ),
//                     child: const FaIcon(
//                       FontAwesomeIcons.hashtag,
//                       size: 14,
//                       color: Color(0xFF64748B),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final storeId = int.tryParse(_controller.text.trim());
//                   if (storeId == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('رقم المتجر غير صالح')),
//                     );
//                     return;
//                   }

//                   if (!context.mounted) return;
//                   Navigator.of(context).pop();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF7A00),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('إعادة الطلب'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _ShoppingListDetailsHeader extends StatelessWidget {
  const _ShoppingListDetailsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(
        16,
        16 + MediaQuery.paddingOf(context).top,
        16,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: AppText(
              title,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 30 / 22,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
