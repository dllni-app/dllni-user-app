import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../domain/repository/shopping_lists_repo.dart';
import '../../domain/usecases/search_master_products_for_shopping_list_use_case.dart';

class ShoppingListMasterProductOption {
  final int id;
  final String name;

  const ShoppingListMasterProductOption({required this.id, required this.name});
}

class ShoppingListMasterProductsSearchScreen extends StatefulWidget {
  final List<ShoppingListMasterProductOption> initialSelected;

  const ShoppingListMasterProductsSearchScreen({
    super.key,
    this.initialSelected = const <ShoppingListMasterProductOption>[],
  });

  @override
  State<ShoppingListMasterProductsSearchScreen> createState() =>
      _ShoppingListMasterProductsSearchScreenState();
}

class _ShoppingListMasterProductsSearchScreenState
    extends State<ShoppingListMasterProductsSearchScreen> {
  static const int _perPage = 20;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 400);

  late final SearchMasterProductsForShoppingListUseCase _searchUseCase;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<int, ShoppingListMasterProductOption> _selectedById =
      <int, ShoppingListMasterProductOption>{};

  final List<ShoppingListMasterProductOption> _results =
      <ShoppingListMasterProductOption>[];
  Timer? _searchDebounce;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String _query = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final count = _selectedById.length;
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: 'اختر منتجاتك',
            arrowBackType: ArrowBackType.cupertino,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: hasQuery
                ? _buildSearchResults()
                : Center(
                    child: AppText.bodyMedium(
                      'اكتب اسم منتج للبحث',
                      color: const Color(0xFF64748B),
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -2),
                  blurRadius: 8,
                  color: Color(0x12000000),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText.bodyMedium(
                    'المختار: $count',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton(
                  onPressed: count == 0
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pop(_selectedById.values.toList()),
                  child: const Text('تأكيد'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchUseCase = SearchMasterProductsForShoppingListUseCase(
      shoppingListsRepo: getIt<ShoppingListsRepo>(),
    );
    for (final item in widget.initialSelected) {
      _selectedById[item.id] = item;
    }
    _scrollController.addListener(_onScroll);
  }

  Widget _buildSearchResults() {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _results.isEmpty) {
      return Center(
        child: FailureWidget(
          message: _errorMessage!,
          onRetry: () => _runSearch(reload: true),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: AppText.bodyMedium(
          'لا توجد نتائج',
          color: const Color(0xFF64748B),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _results.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= _results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final item = _results[index];
        final selected = _selectedById.containsKey(item.id);
        return Material(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _toggleSelection(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: AppText.bodyMedium(
                      item.name,
                      textAlign: TextAlign.start,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Checkbox(
                    value: selected,
                    onChanged: (_) => _toggleSelection(item),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.extentAfter > 200) return;
    _runSearch(reload: false);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      final query = value.trim();
      if (!mounted) return;
      if (query.isEmpty) {
        setState(() {
          _query = '';
          _results.clear();
          _errorMessage = null;
          _page = 1;
          _hasMore = false;
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }
      _query = query;
      _runSearch(reload: true);
    });
  }

  Future<void> _runSearch({required bool reload}) async {
    final query = _query.trim();
    if (query.isEmpty) return;
    if (reload) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _errorMessage = null;
        _page = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _errorMessage = null;
      });
    }

    final targetPage = reload ? 1 : (_page + 1);
    final response = await _searchUseCase(
      SearchMasterProductsForShoppingListParams(
        index: query,
        page: targetPage,
        perPage: _perPage,
      ),
    );

    if (!mounted) return;

    response.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      },
      (result) {
        final mapped = result.data
            .where((e) => e.id > 0)
            .map((e) => ShoppingListMasterProductOption(id: e.id, name: e.name))
            .toList();
        final current = result.meta?.currentPage ?? targetPage;
        final last = result.meta?.lastPage ?? current;
        setState(() {
          if (reload) {
            _results
              ..clear()
              ..addAll(mapped);
          } else {
            _results.addAll(mapped);
          }
          _page = current;
          _hasMore = current < last;
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      },
    );
  }

  void _toggleSelection(ShoppingListMasterProductOption item) {
    setState(() {
      if (_selectedById.containsKey(item.id)) {
        _selectedById.remove(item.id);
      } else {
        _selectedById[item.id] = item;
      }
    });
  }
}
