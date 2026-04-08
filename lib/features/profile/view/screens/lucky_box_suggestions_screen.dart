import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/models/luck_box_api_models.dart';
import '../../domain/services/user_location_service.dart';
import '../../domain/usecases/suggest_luck_box_use_case.dart';
import 'lucky_box_suggestions_args.dart';
export 'lucky_box_suggestions_args.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/lucky_suggestion_card.dart';
import '../widgets/personal_details_app_bar.dart';
@AutoRoutePage()
class LuckyBoxSuggestionsScreen extends StatefulWidget {
  const LuckyBoxSuggestionsScreen({super.key, required this.args});

  final LuckyBoxSuggestionsArgs args;

  @override
  State<LuckyBoxSuggestionsScreen> createState() => _LuckyBoxSuggestionsScreenState();
}

class _LuckyBoxSuggestionsScreenState extends State<LuckyBoxSuggestionsScreen> {
  late LuckBoxSuggestResponseModel _response;
  late final TextEditingController _budgetController;
  late final TextEditingController _constraintsController;
  late final TextEditingController _restaurantTypeController;

  bool _isSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _response = widget.args.initialResponse;
    final b = _response.budget;
    final per = b?.budgetPerPerson ?? widget.args.budgetPerPerson;
    _budgetController = TextEditingController(text: '$per');
    _constraintsController = TextEditingController(text: widget.args.constraintsSummaryText);
    _restaurantTypeController = TextEditingController(text: widget.args.cuisineSummaryText);
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
      final mins = bundle.estimatedMinutes;
      final secondary = [
        if (price != null) '$price ل.س',
        if (mins != null) '$mins دقيقة',
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
    Loading.show(context);
    final loc = await getIt<UserLocationService>().getCurrentPosition();
    final params = widget.args.toSuggestParams(
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
    final res = await getIt<SuggestLuckBoxUseCase>()(params);
    if (!mounted) return;
    Loading.close();
    res.fold(
      (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
      (r) {
        setState(() {
          _response = r;
          final per = r.budget?.budgetPerPerson ?? widget.args.budgetPerPerson;
          _budgetController.text = '$per';
        });
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
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Column(
                  children: [
                    ExpandableNumberedSection(
                      sectionNumber: '1',
                      title: 'تخصيص البحث',
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
                              padding: const EdgeInsetsDirectional.only(end: 10),
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
                            label: 'هل هناك قيود؟',
                            controller: _constraintsController,
                            readOnly: true,
                            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                          const SizedBox(height: 14),
                          FilledTextField(
                            label: 'نوع المطاعم',
                            controller: _restaurantTypeController,
                            readOnly: true,
                            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: AppText.bodyMedium(
                          'لا توجد اقتراحات حالياً. جرّب تغيير المعايير أو التحديث.',
                          textAlign: TextAlign.center,
                          color: const Color(0xff6B7280),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 12),
                          child: LuckySuggestionCard(item: item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _refreshSuggestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: AppText.labelLarge(
                        'تحديث الاقتراحات',
                        color: context.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.error.withAlpha(200)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: AppText.labelLarge(
                        'إلغاء',
                        color: context.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
