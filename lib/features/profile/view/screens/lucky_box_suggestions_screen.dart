import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_discover/domain/usecases/add_restaurant_cart_item_use_case.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/luck_box_api_models.dart';
import '../../domain/services/user_location_service.dart';
import '../../domain/usecases/suggest_luck_box_use_case.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/lucky_suggestion_card.dart';
import '../widgets/personal_details_app_bar.dart';
import 'lucky_box_suggestions_args.dart';

export 'lucky_box_suggestions_args.dart';

@AutoRoutePage()
class LuckyBoxSuggestionsScreen extends StatefulWidget {
  const LuckyBoxSuggestionsScreen({super.key, required this.args});

  final LuckyBoxSuggestionsArgs args;

  @override
  State<LuckyBoxSuggestionsScreen> createState() =>
      _LuckyBoxSuggestionsScreenState();
}

class _LuckyBoxSuggestionsScreenState
    extends State<LuckyBoxSuggestionsScreen> {
  late LuckBoxSuggestResponseModel _response;
  late final TextEditingController _budgetController;
  late final TextEditingController _constraintsController;
  late final TextEditingController _restaurantTypeController;

  bool _isSectionExpanded = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _response = widget.args.initialResponse;
    final budget = _response.budget;
    final budgetPerPerson =
        budget?.budgetPerPerson ?? widget.args.budgetPerPerson;
    _budgetController = TextEditingController(text: '$budgetPerPerson');
    _constraintsController = TextEditingController(
      text: widget.args.constraintsSummaryText,
    );
    _restaurantTypeController = TextEditingController(
      text: widget.args.cuisineSummaryText,
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _constraintsController.dispose();
    _restaurantTypeController.dispose();
    super.dispose();
  }

  List<LuckySuggestionItem> _mapBundles() {
    return _response.bundles.map((bundle) {
      final price = bundle.totalPrice;
      final minutes = bundle.estimatedMinutes;
      final secondary = [
        if (price != null) _formatPrice(price),
        if (minutes != null) '$minutes دقيقة',
      ].join(' · ');

      return LuckySuggestionItem(
        badge: bundle.labelAr ?? bundle.label ?? '',
        productsCount: bundle.totalProducts ?? 0,
        title: bundle.restaurant?.name ?? '',
        details: bundle.itemsDescription ?? '',
        secondaryInfo: secondary,
        imageUrl: bundle.restaurant?.primaryImageUrl,
      );
    }).toList();
  }

  Future<void> _refreshSuggestions() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final location = await getIt<UserLocationService>().getCurrentPosition();
      final params = widget.args.toSuggestParams(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final result = await getIt<SuggestLuckBoxUseCase>()(params);

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (response) {
          setState(() {
            _response = response;
            final perPerson =
                response.budget?.budgetPerPerson ??
                widget.args.budgetPerPerson;
            _budgetController.text = '$perPerson';
          });
        },
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تحديث الاقتراحات. حاول مرة أخرى.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String _formatPrice(num? value) {
    if (value == null) return '-';
    final normalized = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '$normalized ل.س';
  }

  Future<void> _addLineItemToCart({required int productId}) async {
    final result = await getIt<AddRestaurantCartItemUseCase>()(
      AddRestaurantCartItemParams(productId: productId, quantity: 1),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        AppToast.showToast(
          context: context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (response) {
        final message = (response.message ?? '').trim().isNotEmpty
            ? response.message!
            : 'تمت إضافة المنتج إلى السلة';
        AppToast.showToast(
          context: context,
          message: message,
          type: ToastificationType.success,
        );
      },
    );
  }

  Future<void> _openSuggestionProductsSheet(
    LuckBoxBundleModel bundle,
  ) async {
    final items = bundle.lineItems;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final addingProductIds = <int>{};

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.78,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    16,
                    12,
                    16,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xffD1D5DB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppText.titleMedium(
                        bundle.restaurant?.name ?? 'منتجات المطعم',
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff111827),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 6),
                      AppText.labelLarge(
                        '${items.length} منتج · ${_formatPrice(bundle.totalPrice)}',
                        color: const Color(0xff6B7280),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: AppText.bodyMedium(
                                  'لا توجد منتجات متاحة لهذا الاقتراح',
                                  color: const Color(0xff6B7280),
                                ),
                              )
                            : ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final productId = item.productId;
                                  final isAdding =
                                      productId != null &&
                                      addingProductIds.contains(productId);

                                  return Container(
                                    padding:
                                        const EdgeInsetsDirectional.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xffE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: _ProductImage(
                                            imageUrl: item.imageUrl,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText.bodyMedium(
                                                item.name?.trim().isNotEmpty ==
                                                        true
                                                    ? item.name!
                                                    : 'منتج',
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xff111827),
                                                textAlign: TextAlign.start,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(height: 4),
                                              AppText.labelLarge(
                                                _formatPrice(
                                                  item.unitPrice ??
                                                      item.lineTotal,
                                                ),
                                                color: const Color(0xff6B7280),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 38,
                                          child: ElevatedButton(
                                            onPressed:
                                                productId == null ||
                                                    productId <= 0 ||
                                                    isAdding
                                                ? null
                                                : () async {
                                                    setSheetState(() {
                                                      addingProductIds.add(
                                                        productId,
                                                      );
                                                    });
                                                    await _addLineItemToCart(
                                                      productId: productId,
                                                    );
                                                    if (sheetContext.mounted) {
                                                      setSheetState(() {
                                                        addingProductIds.remove(
                                                          productId,
                                                        );
                                                      });
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: context.primary,
                                              foregroundColor:
                                                  context.onPrimary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsetsDirectional.symmetric(
                                                    horizontal: 14,
                                                  ),
                                            ),
                                            child: isAdding
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : AppText.labelLarge(
                                                    'إضافة',
                                                    color: context.onPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _mapBundles();

    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'صندوق الحظ'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSuggestions,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    16,
                    18,
                    16,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SuggestionsIntro(count: items.length),
                      const SizedBox(height: 16),
                      ExpandableNumberedSection(
                        sectionNumber: '1',
                        title: 'معايير البحث',
                        isExpanded: _isSectionExpanded,
                        onHeaderTap: () {
                          setState(() {
                            _isSectionExpanded = !_isSectionExpanded;
                          });
                        },
                        child: Column(
                          children: [
                            FilledTextField(
                              label: 'ميزانية الشخص الواحد',
                              controller: _budgetController,
                              readOnly: true,
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 10),
                                child: Center(
                                  widthFactor: 1,
                                  child: AppText.bodyMedium(
                                    'ل.س',
                                    color: const Color(0xff9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledTextField(
                              label: 'القيود الغذائية',
                              controller: _constraintsController,
                              readOnly: true,
                            ),
                            const SizedBox(height: 14),
                            FilledTextField(
                              label: 'نوع المطاعم',
                              controller: _restaurantTypeController,
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: AppText.titleLarge(
                              'الاقتراحات المناسبة لك',
                              color: const Color(0xff111827),
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffECFDF3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: AppText.labelLarge(
                              '${items.length} خيارات',
                              color: const Color(0xff15803D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        const _EmptySuggestions()
                      else
                        ...items.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 12,
                            ),
                            child: LuckySuggestionCard(
                              item: entry.value,
                              onTap: () => _openSuggestionProductsSheet(
                                _response.bundles[entry.key],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xffE5E7EB)),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _isRefreshing ? null : _refreshSuggestions,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: AppText.labelLarge(
                  _isRefreshing ? 'جاري التحديث...' : 'تحديث الاقتراحات',
                  color: context.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: context.primary,
                  foregroundColor: context.onPrimary,
                  disabledBackgroundColor: context.primary.withAlpha(140),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

class _SuggestionsIntro extends StatelessWidget {
  const _SuggestionsIntro({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xffFF7A00),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleMedium(
                  count > 0
                      ? 'جهزنا لك $count اقتراحات'
                      : 'لنبحث عن اقتراحات مناسبة',
                  color: const Color(0xff9A3412),
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 5),
                AppText.labelLarge(
                  'اضغط على أي اقتراح لعرض المنتجات وإضافة ما يناسبك إلى السلة.',
                  color: const Color(0xff7C2D12),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySuggestions extends StatelessWidget {
  const _EmptySuggestions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 20,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Color(0xff9CA3AF),
          ),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            'لا توجد اقتراحات حالياً',
            color: const Color(0xff111827),
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 5),
          AppText.labelLarge(
            'حدّث الاقتراحات أو راجع معايير البحث.',
            color: const Color(0xff6B7280),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    if (url.isEmpty) {
      return const ColoredBox(
        color: Color(0xffF3F4F6),
        child: SizedBox(width: 58, height: 58),
      );
    }

    return Image.network(
      url,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Color(0xffF3F4F6),
        child: SizedBox(width: 58, height: 58),
      ),
    );
  }
}
