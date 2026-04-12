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
  late final ShoppingListsCubit _shoppingListsCubit;

  @override
  void initState() {
    super.initState();
    _shoppingListsCubit = getIt<ShoppingListsCubit>();
    _shoppingListsCubit.loadShoppingLists();
  }

  Future<void> _refreshLists() async {
    await context.read<ShoppingListsCubit>().loadShoppingLists(showLoader: false);
  }

  Future<void> _showCreateListSheet(ShoppingListsCubit cubit) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'إضافة قائمة تسوق جديدة',
                  style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'اسم القائمة', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'وصف (اختياري)', border: OutlineInputBorder()),
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
                                  ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('يرجى إدخال اسم القائمة')));
                                  return;
                                }
                                await cubit.createShoppingList(name: name, description: descriptionController.text);
                                if (!mounted) return;
                                final current = cubit.state;
                                if (current.createStatus == BlocStatus.success) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('إضافة'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    nameController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShoppingListsCubit>.value(
      value: _shoppingListsCubit,
      child: BlocListener<ShoppingListsCubit, ShoppingListsState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage && (c.errorMessage?.isNotEmpty == true),
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null || message.isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: Column(
            children: [
              const _ShoppingListHeader(title: "قائمة التسوق الذكي"),
              Expanded(
                child: BlocBuilder<ShoppingListsCubit, ShoppingListsState>(
                  builder: (context, state) {
                    if (state.status == BlocStatus.loading || state.status == BlocStatus.init) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.lists.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshLists,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('لا توجد قوائم تسوق')),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refreshLists,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.lists.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (_, index) => _ShoppingListCard(
                          list: state.lists[index],
                          onTap: () async {
                            await context.pushRoute(
                              "/shopping_list_details",
                              arguments: ShoppingListDetailsArgs(shoppingListId: state.lists[index].id, title: state.lists[index].name),
                            );
                            if (!mounted) return;
                            await _refreshLists();
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
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
            color: const Color(0xFFF3F4F6),
            child: GestureDetector(
              onTap: () {
                _showCreateListSheet(_shoppingListsCubit);
              },
              child: Container(
                padding: const EdgeInsets.only(top: 14, bottom: 13),
                decoration: const BoxDecoration(color: Color(0xFFFF7A00), borderRadius: BorderRadius.all(Radius.circular(12))),
                child: AppText(
                  "إضافة قائمة تسوق جديدة",
                  style: TextStyle(color: Color(0xFFFFEEFF), fontSize: 14, fontWeight: FontWeight.w700, height: 16 / 14),
                ),
              ),
            ),
          ),
        ),
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
          boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0x2B22C55E), borderRadius: BorderRadius.all(Radius.circular(12))),
              child: const FaIcon(FontAwesomeIcons.bagShopping, size: 20, color: Color(0xFF4CAF50)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    list.name,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '${list.itemsCount} منتج',
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: FaIcon(FontAwesomeIcons.penToSquare, size: 17, color: Color(0xFF64748B)),
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
      padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFF1E3A8A), width: 2)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: AppText(
              title,
              style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 22, fontWeight: FontWeight.w700, height: 30 / 22),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFDDF3E3), shape: BoxShape.circle),
            child: const FaIcon(FontAwesomeIcons.basketShopping, size: 20, color: Color(0xFF43B654)),
          ),
        ],
      ),
    );
  }
}
