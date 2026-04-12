import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../manager/shopping_lists_cubit.dart';

@AutoRoutePage(path: "/shopping_list")
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShoppingListsCubit>(
      create: (context) => getIt<ShoppingListsCubit>()..loadShoppingLists(),
      child: BlocListener<ShoppingListsCubit, ShoppingListsState>(
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
          body: Column(
            children: [
              const _ShoppingListHeader(title: "قائمة التسوق الذكي"),
              Expanded(
                child: BlocBuilder<ShoppingListsCubit, ShoppingListsState>(
                  builder: (context, state) {
                    if (state.status == BlocStatus.loading ||
                        state.status == BlocStatus.init) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.lists.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<ShoppingListsCubit>()
                              .loadShoppingLists();
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('لا توجد قوائم تسوق')),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<ShoppingListsCubit>()
                            .loadShoppingLists();
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.lists.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (_, index) => _ShoppingListCard(
                          list: state.lists[index],
                          onTap: () async {
                            await context.pushRoute(
                              "/shopping_list_details",
                              arguments: ShoppingListDetailsArgs(
                                shoppingListId: state.lists[index].id,
                                title: state.lists[index].name,
                              ),
                            );
                            if (!mounted) return;
                          },
                        ),
                      ),
                    );
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
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      builder: (sheetContext) {
                        return BlocProvider.value(
                          value: context.read<ShoppingListsCubit>(),
                          child: CreateShoppingListSheet(),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 14, bottom: 13),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7A00),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: AppText(
                      "إضافة قائمة تسوق جديدة",
                      style: TextStyle(
                        color: Color(0xFFFFEEFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 16 / 14,
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}

class CreateShoppingListSheet extends StatefulWidget {
  const CreateShoppingListSheet({super.key});

  @override
  State<CreateShoppingListSheet> createState() =>
      _CreateShoppingListSheetState();
}

class _CreateShoppingListSheetState extends State<CreateShoppingListSheet> {
  static const Color _fieldFill = Color(0xFFF9FAFB);
  static const Color _borderIdle = Color(0xFFE5E7EB);
  static const Color _brandOrange = Color(0xFFFF7A00);
  static const Color _textPrimary = Color(0xFF2F2B3D);
  static const Color _hintColor = Color(0xFF9CA3AF);

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
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
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFE0CC)),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.bagShopping,
                  size: 20,
                  color: _brandOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'إضافة قائمة تسوق جديدة',
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
            controller: nameController,
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
            controller: descriptionController,
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
            child: BlocBuilder<ShoppingListsCubit, ShoppingListsState>(
              buildWhen: (p, c) => p.createStatus != c.createStatus,
              builder: (context, state) {
                final isLoading = state.createStatus == BlocStatus.loading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى إدخال اسم القائمة'),
                              ),
                            );
                            return;
                          }
                          await context
                              .read<ShoppingListsCubit>()
                              .createShoppingList(
                                name: name,
                                description: descriptionController.text,
                              );
                          if (!context.mounted) return;
                          final current = context
                              .read<ShoppingListsCubit>()
                              .state;
                          if (current.createStatus == BlocStatus.success) {
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إضافة'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingListCard extends StatelessWidget {
  const _ShoppingListCard({required this.list, required this.onTap});

  final ShoppingListSummaryModel list;
  final VoidCallback onTap;

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
                    list.name,
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
                    '${list.itemsCount} منتج',
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

class _ShoppingListHeader extends StatelessWidget {
  const _ShoppingListHeader({required this.title});

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
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFDDF3E3),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.basketShopping,
              size: 20,
              color: Color(0xFF43B654),
            ),
          ),
        ],
      ),
    );
  }
}
