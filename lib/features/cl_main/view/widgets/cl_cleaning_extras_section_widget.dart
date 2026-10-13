import '../../../../core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_services_response_model.dart';
import 'cl_service_section_card_widget.dart';

class ClCleaningExtrasSectionWidget extends StatelessWidget {
  const ClCleaningExtrasSectionWidget({
    this.showMaterials = true,
    this.showAddButton = true,
    this.compactSpecialEditor = false,
    this.showSpecialServices = true,
    required this.requestMaterials,
    required this.specialServices,
    required this.openTime,
    required this.availableSpecialServices,
    required this.materials,
    required this.estimatedSpecialServices,
    required this.estimatedOpenTime,
    required this.isSpecialServicesLoading,
    required this.isEstimateLoading,
    required this.onRequestMaterialsChanged,
    required this.onAddSpecialService,
    required this.onSpecialServiceChanged,
    required this.onRemoveSpecialService,
    required this.onOpenTimeChanged,
    required this.onOpenTimeWorkerCountChanged,
    required this.onOpenTimeExpectedMaxMinutesChanged,
    required this.onRetryEstimate,
    required this.onRetrySpecialServices,
    this.specialServicesError,
    this.estimateError,
    this.openTimeDurationOptions = const <int>[60, 120, 180, 240, 480],
    this.showOpenTime = true,
    this.selectableSessionIds = const <int>[],
    this.sessionLabels = const <int, String>{},
    super.key,
  });

  final bool showMaterials;
  final bool showAddButton;
  final bool compactSpecialEditor;
  final bool showSpecialServices;
  final bool requestMaterials;
  final List<CleaningSpecialServiceRequest> specialServices;
  final CleaningOpenTimeRequest? openTime;
  final List<CleaningServiceModel> availableSpecialServices;
  final List<CleaningMaterialLineModel> materials;
  final List<CleaningSpecialServiceLineModel> estimatedSpecialServices;
  final CleaningOpenTimeModel? estimatedOpenTime;
  final bool isSpecialServicesLoading;
  final bool isEstimateLoading;
  final ValueChanged<bool> onRequestMaterialsChanged;
  final VoidCallback onAddSpecialService;
  final void Function(int index, CleaningSpecialServiceRequest service)
  onSpecialServiceChanged;
  final ValueChanged<int> onRemoveSpecialService;
  final ValueChanged<bool> onOpenTimeChanged;
  final ValueChanged<int> onOpenTimeWorkerCountChanged;
  final ValueChanged<int> onOpenTimeExpectedMaxMinutesChanged;
  final VoidCallback onRetryEstimate;
  final VoidCallback onRetrySpecialServices;
  final String? specialServicesError;
  final String? estimateError;
  final List<int> openTimeDurationOptions;
  final bool showOpenTime;
  final List<int> selectableSessionIds;
  final Map<int, String> sessionLabels;

  @override
  Widget build(BuildContext context) {
    final currency = estimatedOpenTime?.currency ?? 'SYP';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEstimateLoading)
          Semantics(
            liveRegion: true,
            label: 'جارٍ تحديث تقدير التكلفة',
            child: const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ),
        if (estimateError != null) ...[
          _InlineFeedback(
            message: 'تعذر تحديث تقدير التكلفة',
            onRetry: onRetryEstimate,
          ),
          const SizedBox(height: 10),
        ],
        if (showMaterials)
          ClServiceSectionCardWidget(
            step: 0,
            showStepBadge: false,
            title: 'مواد التنظيف',
            subtitle: 'هل ترغب أن نحضر المواد اللازمة معنا؟',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'اختر من سيوفر المواد. ستُحدّث التكلفة تلقائياً عند تغيير اختيارك.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                for (final suppliedByService in [true, false])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      button: true,
                      selected: requestMaterials == suppliedByService,
                      label: suppliedByService
                          ? 'أحضروا مواد التنظيف'
                          : 'سأوفر مواد التنظيف بنفسي',
                      child: InkWell(
                        key: Key(
                          suppliedByService
                              ? 'cleaning_materials_from_service'
                              : 'cleaning_materials_from_customer',
                        ),
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            onRequestMaterialsChanged(suppliedByService),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: requestMaterials == suppliedByService
                                ? const Color(0xFFE7F7F5)
                                : const Color(0xFFF8FAFC),
                            border: Border.all(
                              color: requestMaterials == suppliedByService
                                  ? const Color(0xFF0F9E92)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                requestMaterials == suppliedByService
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: requestMaterials == suppliedByService
                                    ? const Color(0xFF0F9E92)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suppliedByService
                                          ? 'أحضروا مواد التنظيف'
                                          : 'سأوفر مواد التنظيف بنفسي',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      suppliedByService
                                          ? 'نجهّز المواد اللازمة ونُظهر تكلفتها في التقدير.'
                                          : 'استخدم موادي دون إضافة تكلفة مواد من الخدمة.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (requestMaterials && materials.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('عرض تفاصيل المواد'),
                    subtitle: const Text('يمكن مراجعة الكميات والتكلفة هنا'),
                    children: [
                      _CalculatedLinesCard(
                        title: 'المواد المطلوبة',
                        children: materials
                            .map(
                              (line) =>
                                  _MaterialLine(line: line, currency: currency),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 10),
        if (showSpecialServices && compactSpecialEditor) ...[
          for (var index = 0; index < specialServices.length; index++) ...[
            _SpecialServiceForm(
              key: ValueKey<String>(
                'compact-special-${specialServices[index].specialServiceId}-$index',
              ),
              compact: true,
              service: specialServices[index],
              availableServices: availableSpecialServices,
              currency: currency,
              selectableSessionIds: selectableSessionIds,
              sessionLabels: sessionLabels,
              onChanged: (service) => onSpecialServiceChanged(index, service),
              onRemove: () => onRemoveSpecialService(index),
            ),
            const SizedBox(height: 12),
          ],
        ],
        if (showSpecialServices && !compactSpecialEditor)
          ClServiceSectionCardWidget(
            step: 0,
            showStepBadge: false,
            title: 'الخدمات المتخصصة',
            subtitle:
                'اختر خدمة متخصصة فقط إذا كانت مطلوبة خارج مهام التنظيف المعتادة.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isSpecialServicesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (specialServicesError != null)
                  _InlineFeedback(
                    message: 'تعذر تحديث تقدير التكلفة',
                    onRetry: onRetrySpecialServices,
                  )
                else if (availableSpecialServices.isEmpty)
                  Text(
                    'لا توجد خدمات متخصصة متاحة لهذا الطلب حالياً.',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  )
                else ...[
                  for (
                    var index = 0;
                    index < specialServices.length;
                    index++
                  ) ...[
                    _SpecialServiceForm(
                      key: ValueKey<String>(
                        '${specialServices[index].specialServiceId}-$index',
                      ),
                      service: specialServices[index],
                      availableServices: availableSpecialServices,
                      currency: currency,
                      selectableSessionIds: selectableSessionIds,
                      sessionLabels: sessionLabels,
                      onChanged: (service) =>
                          onSpecialServiceChanged(index, service),
                      onRemove: () => onRemoveSpecialService(index),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (showAddButton)
                    Semantics(
                      button: true,
                      label: 'إضافة خدمة متخصصة',
                      child: OutlinedButton.icon(
                        onPressed: onAddSpecialService,
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text('إضافة خدمة متخصصة'),
                      ),
                    ),
                ],
                if (estimatedSpecialServices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _CalculatedLinesCard(
                    title: 'التكلفة المقدرة للخدمات المتخصصة',
                    children: estimatedSpecialServices
                        .map(
                          (line) => _SpecialServiceLine(
                            line: line,
                            currency: currency,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        if (showOpenTime) ...[
          const SizedBox(height: 10),
          ClServiceSectionCardWidget(
            step: 0,
            showStepBadge: false,
            title: 'خدمة بوقت مفتوح',
            subtitle: 'حجز مدة قصوى للجدولة؛ الحساب النهائي حسب الوقت الفعلي.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'أحتاج عملاً بوقت مفتوح',
                  toggled: openTime != null,
                  child: Material(
                    color: Colors.transparent,
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text('أحتاج عملاً بوقت مفتوح'),
                      value: openTime != null,
                      onChanged: onOpenTimeChanged,
                    ),
                  ),
                ),
                if (openTime != null) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: openTime!.workerCount,
                    decoration: InputDecoration(
                      labelText: 'عدد العمال',
                      border: const OutlineInputBorder(),
                    ),
                    items: List<DropdownMenuItem<int>>.generate(20, (index) {
                      final count = index + 1;
                      return DropdownMenuItem<int>(
                        value: count,
                        child: Text('$count'),
                      );
                    }),
                    onChanged: (count) {
                      if (count != null) onOpenTimeWorkerCountChanged(count);
                    },
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'الحد المتوقع لمدة الطلب المفتوح',
                    child: DropdownButtonFormField<int>(
                      initialValue:
                          openTimeDurationOptions.contains(
                            openTime!.expectedMaxMinutes,
                          )
                          ? openTime!.expectedMaxMinutes
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'المدة القصوى المتوقعة',
                        helperText:
                            'يُحجز وقت العامل حتى هذا الحد، والفوترة حسب الوقت الفعلي.',
                        border: OutlineInputBorder(),
                      ),
                      items: openTimeDurationOptions
                          .map(
                            (minutes) => DropdownMenuItem<int>(
                              value: minutes,
                              child: Text(_durationLabel(minutes)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (minutes) {
                        if (minutes != null) {
                          onOpenTimeExpectedMaxMinutesChanged(minutes);
                        }
                      },
                    ),
                  ),
                ],
                if (estimatedOpenTime != null) ...[
                  const SizedBox(height: 12),
                  _OpenTimeCard(
                    openTime: estimatedOpenTime!,
                    currency: currency,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class CleaningOrderExtrasDetailsSection extends StatelessWidget {
  const CleaningOrderExtrasDetailsSection({
    required this.materials,
    required this.specialServices,
    required this.openTime,
    required this.currency,
    super.key,
  });

  final List<CleaningMaterialLineModel> materials;
  final List<CleaningSpecialServiceLineModel> specialServices;
  final CleaningOpenTimeModel? openTime;
  final String currency;

  bool get _hasContent =>
      materials.isNotEmpty || specialServices.isNotEmpty || openTime != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تفاصيل الخدمات الإضافية',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (materials.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CalculatedLinesCard(
              title: 'مواد التنظيف',
              children: materials
                  .map((line) => _MaterialLine(line: line, currency: currency))
                  .toList(growable: false),
            ),
          ],
          if (specialServices.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CalculatedLinesCard(
              title: 'الخدمات المتخصصة',
              children: specialServices
                  .map(
                    (line) =>
                        _SpecialServiceLine(line: line, currency: currency),
                  )
                  .toList(growable: false),
            ),
          ],
          if (openTime != null) ...[
            const SizedBox(height: 10),
            _OpenTimeCard(openTime: openTime!, currency: currency),
          ],
        ],
      ),
    );
  }
}

/// Material-only rows for the order details card. The outer V7OrderPanel
/// provides the heading/border; don't nest another duplicate card here.
class CleaningOrderMaterialLines extends StatelessWidget {
  const CleaningOrderMaterialLines({
    super.key,
    required this.materials,
    required this.currency,
  });

  final List<CleaningMaterialLineModel> materials;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < materials.length; index++) ...[
          if (index > 0) const Divider(height: 16),
          _MaterialLine(line: materials[index], currency: currency),
        ],
      ],
    );
  }
}

/// Specialized service rows (including pieces, notes and evidence), never
/// mixed into the cleaning materials card.
class CleaningOrderSpecialServiceLines extends StatelessWidget {
  const CleaningOrderSpecialServiceLines({
    super.key,
    required this.specialServices,
    required this.currency,
  });

  final List<CleaningSpecialServiceLineModel> specialServices;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < specialServices.length; index++) ...[
          if (index > 0) const Divider(height: 16),
          _SpecialServiceLine(line: specialServices[index], currency: currency),
        ],
      ],
    );
  }
}

/// Hourly work also has an independent heading in the order details page.
class CleaningOrderHourlyDetails extends StatelessWidget {
  const CleaningOrderHourlyDetails({
    super.key,
    required this.openTime,
    required this.currency,
  });

  final CleaningOpenTimeModel openTime;
  final String currency;

  @override
  Widget build(BuildContext context) =>
      _OpenTimeCard(openTime: openTime, currency: currency, showCard: false);
}

class _SpecialServiceForm extends StatelessWidget {
  const _SpecialServiceForm({
    this.compact = false,
    required super.key,
    required this.service,
    required this.availableServices,
    required this.currency,
    required this.onChanged,
    required this.onRemove,
    required this.selectableSessionIds,
    required this.sessionLabels,
  });

  final bool compact;
  final CleaningSpecialServiceRequest service;
  final List<CleaningServiceModel> availableServices;
  final String currency;
  final ValueChanged<CleaningSpecialServiceRequest> onChanged;
  final VoidCallback onRemove;
  final List<int> selectableSessionIds;
  final Map<int, String> sessionLabels;

  @override
  Widget build(BuildContext context) {
    final selectedService = _findServiceById(
      availableServices,
      service.specialServiceId,
    );
    final dirtinessLevels =
        selectedService?.selectableDirtinessLevels ??
        cleaningServiceFallbackDirtinessLevels;
    final selectedDirtiness =
        selectedService?.normalizeDirtinessLevel(service.dirtinessLevel) ??
        (dirtinessLevels.contains(service.dirtinessLevel)
            ? service.dirtinessLevel
            : dirtinessLevels.first);
    final selectedDirtinessRule = selectedService?.dirtinessRules
        .where((rule) => rule.level == selectedDirtiness)
        .firstOrNull;
    final effectiveItems = service.items.isNotEmpty
        ? service.items
        : <CleaningSpecialServiceItemRequest>[
            CleaningSpecialServiceItemRequest(
              quantity: service.quantity.toDouble(),
              dirtinessLevelId: selectedDirtinessRule?.id,
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compact) ...[
            Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: SharedPlatformColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    selectedService?.name ?? 'خدمة متخصصة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'حدد تفاصيل القطع التي تتطلب الخدمة، ثم راجع السعر في الخطوة الأخيرة.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 12),
          ],
          if (!compact)
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: service.specialServiceId,
              decoration: InputDecoration(
                labelText: 'اختر الخدمة المتخصصة',
                border: const OutlineInputBorder(),
              ),
              items: availableServices
                  .where((item) => item.id != null && item.name != null)
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(
                        item.categoryName?.trim().isNotEmpty == true
                            ? '${item.categoryName!.trim()} — ${item.name!}'
                            : item.name!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (id) {
                if (id == null) return;
                final nextService = _findServiceById(availableServices, id);
                final nextDirtiness =
                    nextService?.normalizeDirtinessLevel(
                      service.dirtinessLevel,
                    ) ??
                    service.dirtinessLevel;
                onChanged(
                  service.copyWith(
                    specialServiceId: id,
                    dirtinessLevel: nextDirtiness,
                    items: _normalizeItemsForService(
                      effectiveItems,
                      nextService,
                    ),
                  ),
                );
              },
            ),
          if (selectedService != null && !compact) ...[
            const SizedBox(height: 10),
            _SpecialServiceCatalogPreview(
              service: selectedService,
              currency: currency,
            ),
          ],
          if (selectableSessionIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'الجلسات المختارة للخدمة',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectableSessionIds
                  .map((sessionId) {
                    final selected = service.sessionIds.contains(sessionId);
                    return ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: FilterChip(
                        label: Text(
                          sessionLabels[sessionId] ?? 'جلسة $sessionId',
                        ),
                        selected: selected,
                        onSelected: (enabled) {
                          final ids = <int>{...service.sessionIds};
                          enabled ? ids.add(sessionId) : ids.remove(sessionId);
                          final ordered = ids.toList()..sort();
                          onChanged(service.copyWith(sessionIds: ordered));
                        },
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: 4),
            Text(
              service.sessionIds.isEmpty
                  ? 'اختر جلسة واحدة على الأقل لهذه الخدمة.'
                  : 'ستُحسب وتُنفذ الخدمة في الجلسات المحددة فقط.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: service.sessionIds.isEmpty
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          _SpecialServiceItemsEditor(
            compact: compact,
            items: effectiveItems,
            catalogService: selectedService,
            onChanged: (items) {
              final totalQuantity = items.fold<double>(
                0,
                (total, item) => total + item.quantity,
              );
              final legacyQuantity = totalQuantity.ceil();
              final firstLevelId = items.firstOrNull?.dirtinessLevelId;
              final firstLevel = selectedService?.dirtinessRules
                  .where((rule) => rule.id == firstLevelId)
                  .firstOrNull;
              onChanged(
                service.copyWith(
                  items: items,
                  quantity: legacyQuantity > 0 ? legacyQuantity : 1,
                  dirtinessLevel: firstLevel?.level ?? service.dirtinessLevel,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          if (!compact)
            TextFormField(
              initialValue: service.notes,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'ملاحظات الخدمة',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onChanged(
                service.copyWith(
                  notes: value,
                  clearNotes: value.trim().isEmpty,
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              label: Text('إزالة الخدمة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialServiceItemsEditor extends StatelessWidget {
  const _SpecialServiceItemsEditor({
    this.compact = false,
    required this.items,
    required this.catalogService,
    required this.onChanged,
  });

  final bool compact;
  final List<CleaningSpecialServiceItemRequest> items;
  final CleaningServiceModel? catalogService;
  final ValueChanged<List<CleaningSpecialServiceItemRequest>> onChanged;

  @override
  Widget build(BuildContext context) {
    final service = catalogService;
    final rules = service?.supportsDirtiness == false
        ? const <CleaningServiceDirtinessRuleModel>[]
        : service?.dirtinessRules ??
              const <CleaningServiceDirtinessRuleModel>[];

    return Semantics(
      container: true,
      label: 'عناصر الخدمة الخاصة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'عناصر الخدمة',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text('${items.length}'),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < items.length; index++) ...[
            _SpecialServiceItemEditor(
              compact: compact,
              key: ValueKey<String>('${service?.id ?? 0}-item-$index'),
              index: index,
              item: items[index],
              inputType: service?.inputType,
              unitCode: service?.unitCode ?? service?.pricingUnit,
              dirtinessRules: rules,
              canRemove: items.length > 1,
              requiresBeforeImage: service?.requiresBeforeImage == true,
              onChanged: (item) {
                final updated = List<CleaningSpecialServiceItemRequest>.of(
                  items,
                );
                updated[index] = item;
                onChanged(updated);
              },
              onRemove: () {
                final updated = List<CleaningSpecialServiceItemRequest>.of(
                  items,
                )..removeAt(index);
                onChanged(updated);
              },
            ),
            if (index != items.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: ValueKey<String>(
                'special-service-${service?.id ?? 0}-add-item',
              ),
              onPressed: items.length >= 50
                  ? null
                  : () => onChanged(<CleaningSpecialServiceItemRequest>[
                      ...items,
                      CleaningSpecialServiceItemRequest(
                        quantity: 1,
                        dirtinessLevelId: rules.firstOrNull?.id,
                      ),
                    ]),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إضافة عنصر آخر'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialServiceItemEditor extends StatelessWidget {
  const _SpecialServiceItemEditor({
    this.compact = false,
    required super.key,
    required this.index,
    required this.item,
    required this.inputType,
    required this.unitCode,
    required this.dirtinessRules,
    required this.canRemove,
    required this.requiresBeforeImage,
    required this.onChanged,
    required this.onRemove,
  });

  final bool compact;
  final int index;
  final CleaningSpecialServiceItemRequest item;
  final String? inputType;
  final String? unitCode;
  final List<CleaningServiceDirtinessRuleModel> dirtinessRules;
  final bool canRemove;
  final bool requiresBeforeImage;
  final ValueChanged<CleaningSpecialServiceItemRequest> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selectedLevel =
        dirtinessRules.any((rule) => rule.id == item.dirtinessLevelId)
        ? item.dirtinessLevelId
        : dirtinessRules.firstOrNull?.id;
    final unit = unitCode?.trim();
    final translatedUnit = switch (unit?.toLowerCase()) {
      'piece' || 'pcs' || 'item' => 'قطعة',
      'sqm' || 'square_meter' => 'متر مربع',
      'hour' => 'ساعة',
      _ => unit,
    };
    final quantityLabel = translatedUnit == null || translatedUnit.isEmpty
        ? 'الكمية المطلوبة'
        : 'الكمية ($translatedUnit)';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'العنصر ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (canRemove)
                Semantics(
                  button: true,
                  label: 'حذف العنصر ${index + 1}',
                  child: IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'حذف العنصر',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _number(item.quantity),
            keyboardType: TextInputType.numberWithOptions(
              decimal: inputType != 'quantity',
            ),
            decoration: InputDecoration(
              labelText: quantityLabel,
              helperText:
                  'أدخل قيمة أكبر من صفر، ويمكن استخدام الكسور العشرية.',
              errorText: item.quantity <= 0
                  ? 'القيمة مطلوبة وأكبر من صفر.'
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed != null && parsed > 0) {
                onChanged(item.copyWith(quantity: parsed));
              }
            },
          ),
          if (compact && dirtinessRules.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'كيف حالة القطعة؟',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'اختار الأقرب لحالتها حتى نجهّز الطريقة المناسبة.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: [
                for (final rule in dirtinessRules)
                  if (rule.id != null)
                    ChoiceChip(
                      label: Text(switch (rule.level) {
                        'low' || 'light' => 'اتساخ خفيف',
                        'medium' || 'normal' => 'اتساخ عادي',
                        'high' || 'heavy' => 'بحاجة عناية أكثر',
                        _ => rule.name ?? 'مستوى آخر',
                      }),
                      selected: selectedLevel == rule.id,
                      onSelected: (_) =>
                          onChanged(item.copyWith(dirtinessLevelId: rule.id)),
                    ),
              ],
            ),
          ],
          if (!compact) ...[
            if (dirtinessRules.isNotEmpty) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'مستوى الاتساخ لهذا العنصر',
                  helperText: 'اختر الوصف الأقرب لحالة هذا العنصر.',
                  border: OutlineInputBorder(),
                ),
                items: dirtinessRules
                    .where((rule) => rule.id != null)
                    .map(
                      (rule) => DropdownMenuItem<int>(
                        value: rule.id,
                        child: Text(
                          rule.name?.trim().isNotEmpty == true
                              ? rule.name!.trim()
                              : _dirtinessDisplayLabel(
                                  rule.level ?? rule.slug ?? '',
                                ),
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (id) => onChanged(
                  item.copyWith(
                    dirtinessLevelId: id,
                    clearDirtinessLevel: id == null,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
          if (!compact)
            TextFormField(
              initialValue: item.notes,
              maxLength: 2000,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ملاحظات القطعة (اختياري)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onChanged(
                item.copyWith(notes: value, clearNotes: value.trim().isEmpty),
              ),
            ),
          if (requiresBeforeImage || item.attachments.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.photo_camera_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.attachments.isEmpty
                        ? 'تتطلب هذه الخدمة صورة قبل التنفيذ؛ سيظهر التحقق قبل تأكيد الطلب.'
                        : 'تم إرفاق ${item.attachments.length} صورة لهذا العنصر.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialServiceCatalogPreview extends StatelessWidget {
  const _SpecialServiceCatalogPreview({
    required this.service,
    required this.currency,
  });

  final CleaningServiceModel service;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final imageUrl = service.imageUrl?.trim();
    final equipment = service.equipment
        .map((item) => item.name?.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList(growable: false);

    return Semantics(
      container: true,
      label: service.name,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.cleaning_services_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.description?.trim().isNotEmpty == true) ...[
                    Text(
                      service.description!.trim(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (service.pricingUnit?.trim().isNotEmpty == true)
                    _CatalogMetaLine(
                      label: 'وحدة التسعير',
                      value: service.pricingUnit!.trim(),
                    ),
                  if (service.baseUnitPrice != null)
                    _CatalogMetaLine(
                      label: 'سعر الوحدة الأساسي',
                      value: _money(service.baseUnitPrice, currency) ?? '-',
                    ),
                  if (service.estimatedDurationMinutes != null)
                    _CatalogMetaLine(
                      label: 'المدة التقديرية',
                      value: _durationLabel(service.estimatedDurationMinutes!),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'المعدات المطلوبة',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (equipment.isEmpty)
                    Text(
                      'لا توجد معدات خاصة مطلوبة',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: equipment
                          .map(
                            (name) => Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(name),
                            ),
                          )
                          .toList(growable: false),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogMetaLine extends StatelessWidget {
  const _CatalogMetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatedLinesCard extends StatelessWidget {
  const _CalculatedLinesCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F9),
        border: Border.all(color: const Color(0xFFD4E9EC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF172554),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _MaterialLine extends StatelessWidget {
  const _MaterialLine({required this.line, required this.currency});

  final CleaningMaterialLineModel line;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final quantity = _number(line.quantity);
    final unit = line.unit?.trim();
    return _DetailLine(
      title: line.name ?? '-',
      subtitle: [quantity, unit].whereType<String>().join(' '),
      amount: _money(line.totalPrice, currency),
    );
  }
}

class _SpecialServiceLine extends StatelessWidget {
  const _SpecialServiceLine({required this.line, required this.currency});

  final CleaningSpecialServiceLineModel line;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final quantity = _number(line.quantity);
    final details = <String>[
      ?quantity,
      if (line.pricingUnit?.trim().isNotEmpty == true) line.pricingUnit!.trim(),
      if (line.dirtinessLabel?.trim().isNotEmpty == true)
        line.dirtinessLabel!.trim()
      else if (line.dirtinessLevel?.trim().isNotEmpty == true)
        _dirtinessDisplayLabel(line.dirtinessLevel!.trim()),
      if (line.items.isNotEmpty) '${line.items.length} عناصر',
      if (line.executionStatus?.trim().isNotEmpty == true)
        line.executionStatus!.trim(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailLine(
          title: line.name ?? '-',
          subtitle: details.join(' · '),
          amount: _money(line.totalPrice, currency),
          imageUrl: line.imageUrl,
        ),
        for (var index = 0; index < line.items.length; index++)
          _SpecialServiceItemDetail(
            item: line.items[index],
            index: index,
            currency: currency,
          ),
      ],
    );
  }
}

class _SpecialServiceItemDetail extends StatelessWidget {
  const _SpecialServiceItemDetail({
    required this.item,
    required this.index,
    required this.currency,
  });

  final CleaningSpecialServiceItemLineModel item;
  final int index;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final description = <String>[
      if (item.quantity != null) 'الكمية: ${_number(item.quantity)}',
      if (item.dirtinessLevel?.trim().isNotEmpty == true)
        'الاتساخ: ${_dirtinessDisplayLabel(item.dirtinessLevel!.trim())}',
      if (item.beforeImages.isNotEmpty) 'صور قبل: ${item.beforeImages.length}',
      if (item.afterImages.isNotEmpty) 'صور بعد: ${item.afterImages.length}',
    ];
    final note = item.notes?.trim();
    final evidence = <String>[...item.beforeImageUrls, ...item.afterImageUrls]
        .where(
          (url) =>
              Uri.tryParse(url)?.hasScheme == true &&
              (url.startsWith('https://') || url.startsWith('http://')),
        )
        .toList();

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailLine(
            title: 'العنصر ${index + 1}',
            subtitle: description.join(' · '),
            amount: _money(item.totalPrice, currency),
          ),
          if (note != null && note.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
              child: Text(
                'ملاحظات: $note',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (evidence.isNotEmpty)
            SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: evidence.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, imageIndex) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    evidence[imageIndex],
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          width: 58,
                          height: 58,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OpenTimeCard extends StatelessWidget {
  const _OpenTimeCard({
    required this.openTime,
    required this.currency,
    this.showCard = true,
  });

  final CleaningOpenTimeModel openTime;
  final String currency;
  final bool showCard;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (openTime.workerCount != null)
        MapEntry('عدد العمال', '${openTime.workerCount}'),
      if (openTime.hourlyRate != null)
        MapEntry(
          'سعر الساعة',
          '${_money(openTime.hourlyRate, currency)} ${'للساعة'}',
        ),
      if (openTime.minimumDuration != null)
        MapEntry(
          'الحد الأدنى للمحاسبة',
          '${_number(openTime.minimumDuration)} ${'ساعات'}',
        ),
      if (openTime.actualDuration != null)
        MapEntry(
          'المدة الفعلية',
          '${_number(openTime.actualDuration)} ${'ساعات'}',
        ),
      if (openTime.billableDuration != null)
        MapEntry(
          'المدة المحاسبية',
          '${_number(openTime.billableDuration)} ${'ساعات'}',
        ),
      if (openTime.totalPrice != null)
        MapEntry('التكلفة النهائية', _money(openTime.totalPrice, currency)!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    if (!showCard) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows
            .map(
              (row) => _DetailLine(
                title: row.key,
                subtitle: row.value,
                amount: null,
              ),
            )
            .toList(growable: false),
      );
    }

    return _CalculatedLinesCard(
      title: 'التقدير الأولي للوقت المفتوح',
      children: rows
          .map(
            (row) =>
                _DetailLine(title: row.key, subtitle: row.value, amount: null),
          )
          .toList(growable: false),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? amount;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final normalizedImage = imageUrl?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (normalizedImage != null && normalizedImage.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                normalizedImage,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 36, height: 36),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF182232),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.trim().isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (amount != null)
            Text(
              amount!,
              style: const TextStyle(
                color: Color(0xFF172554),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.error),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

CleaningServiceModel? _findServiceById(
  List<CleaningServiceModel> services,
  int id,
) {
  for (final service in services) {
    if (service.id == id) return service;
  }
  return null;
}

List<CleaningSpecialServiceItemRequest> _normalizeItemsForService(
  List<CleaningSpecialServiceItemRequest> items,
  CleaningServiceModel? service,
) {
  if (service == null) return items;
  if (!service.supportsDirtiness) {
    return items
        .map((item) => item.copyWith(clearDirtinessLevel: true))
        .toList(growable: false);
  }

  final validIds = service.dirtinessRules
      .map((rule) => rule.id)
      .whereType<int>()
      .toSet();
  final fallbackId = validIds.firstOrNull;
  return items
      .map(
        (item) => validIds.contains(item.dirtinessLevelId)
            ? item
            : item.copyWith(
                dirtinessLevelId: fallbackId,
                clearDirtinessLevel: fallbackId == null,
              ),
      )
      .toList(growable: false);
}

String _dirtinessDisplayLabel(String value) {
  final normalized = value.trim();
  return switch (normalized) {
    'light' => 'خفيف',
    'medium' => 'متوسط',
    'heavy' => 'شديد',
    _ => normalized.replaceAll('_', ' ').replaceAll('-', ' '),
  };
}

String? _number(double? value) {
  if (value == null) return null;
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
}

String _durationLabel(int minutes) {
  if (minutes < 60) return '$minutes دقيقة';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) return '$hours ساعة';
  return '$hours ساعة و$remainder دقيقة';
}

String? _money(double? value, String currency) {
  if (value == null) return null;
  return '${value.formatMoney()} $currency'.trim();
}
