import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/cleaning_services_response_model.dart';
import 'cl_service_section_card_widget.dart';

class ClCleaningExtrasSectionWidget extends StatelessWidget {
  const ClCleaningExtrasSectionWidget({
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
    required this.onRetryEstimate,
    required this.onRetrySpecialServices,
    this.specialServicesError,
    this.estimateError,
    super.key,
  });

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
  final VoidCallback onRetryEstimate;
  final VoidCallback onRetrySpecialServices;
  final String? specialServicesError;
  final String? estimateError;

  @override
  Widget build(BuildContext context) {
    final currency = estimatedOpenTime?.currency ?? 'SYP';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEstimateLoading)
          Semantics(
            liveRegion: true,
            label: 'cleaningExtras.loadingEstimate'.tr(),
            child: const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ),
        if (estimateError != null) ...[
          _InlineFeedback(
            message: 'cleaningExtras.estimateError'.tr(),
            onRetry: onRetryEstimate,
          ),
          const SizedBox(height: 10),
        ],
        ClServiceSectionCardWidget(
          step: 0,
          showStepBadge: false,
          title: 'cleaningExtras.materialsTitle'.tr(),
          subtitle: 'cleaningExtras.materialsDescription'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: 'cleaningExtras.requestMaterials'.tr(),
                toggled: requestMaterials,
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text('cleaningExtras.requestMaterials'.tr()),
                  value: requestMaterials,
                  onChanged: onRequestMaterialsChanged,
                ),
              ),
              if (requestMaterials && materials.isNotEmpty) ...[
                const SizedBox(height: 8),
                _CalculatedLinesCard(
                  title: 'cleaningExtras.materialsEstimate'.tr(),
                  children: materials
                      .map(
                        (line) => _MaterialLine(
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
        const SizedBox(height: 10),
        ClServiceSectionCardWidget(
          step: 0,
          showStepBadge: false,
          title: 'cleaningExtras.specialServicesTitle'.tr(),
          subtitle: 'cleaningExtras.specialServicesDescription'.tr(),
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
                  message: 'cleaningExtras.estimateError'.tr(),
                  onRetry: onRetrySpecialServices,
                )
              else if (availableSpecialServices.isEmpty)
                Text(
                  'cleaningExtras.noSpecialServices'.tr(),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                )
              else ...[
                for (var index = 0; index < specialServices.length; index++) ...[
                  _SpecialServiceForm(
                    key: ValueKey<String>(
                      '${specialServices[index].specialServiceId}-$index',
                    ),
                    service: specialServices[index],
                    availableServices: availableSpecialServices,
                    onChanged: (service) =>
                        onSpecialServiceChanged(index, service),
                    onRemove: () => onRemoveSpecialService(index),
                  ),
                  const SizedBox(height: 10),
                ],
                Semantics(
                  button: true,
                  label: 'cleaningExtras.addSpecialService'.tr(),
                  child: OutlinedButton.icon(
                    onPressed: onAddSpecialService,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text('cleaningExtras.addSpecialService'.tr()),
                  ),
                ),
              ],
              if (estimatedSpecialServices.isNotEmpty) ...[
                const SizedBox(height: 12),
                _CalculatedLinesCard(
                  title: 'cleaningExtras.specialServicesEstimate'.tr(),
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
        const SizedBox(height: 10),
        ClServiceSectionCardWidget(
          step: 0,
          showStepBadge: false,
          title: 'cleaningExtras.openTimeTitle'.tr(),
          subtitle: 'cleaningExtras.openTimeDescription'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: 'cleaningExtras.requestOpenTime'.tr(),
                toggled: openTime != null,
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text('cleaningExtras.requestOpenTime'.tr()),
                  value: openTime != null,
                  onChanged: onOpenTimeChanged,
                ),
              ),
              if (openTime != null) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: openTime!.workerCount,
                  decoration: InputDecoration(
                    labelText: 'cleaningExtras.workerCount'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  items: List<DropdownMenuItem<int>>.generate(
                    20,
                    (index) {
                      final count = index + 1;
                      return DropdownMenuItem<int>(
                        value: count,
                        child: Text('$count'),
                      );
                    },
                  ),
                  onChanged: (count) {
                    if (count != null) onOpenTimeWorkerCountChanged(count);
                  },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'cleaningExtras.readOnlyDetails'.tr(),
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (materials.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CalculatedLinesCard(
              title: 'cleaningExtras.materialsTitle'.tr(),
              children: materials
                  .map(
                    (line) => _MaterialLine(line: line, currency: currency),
                  )
                  .toList(growable: false),
            ),
          ],
          if (specialServices.isNotEmpty) ...[
            const SizedBox(height: 10),
            _CalculatedLinesCard(
              title: 'cleaningExtras.specialServicesTitle'.tr(),
              children: specialServices
                  .map(
                    (line) => _SpecialServiceLine(
                      line: line,
                      currency: currency,
                    ),
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

class _SpecialServiceForm extends StatelessWidget {
  const _SpecialServiceForm({
    required super.key,
    required this.service,
    required this.availableServices,
    required this.onChanged,
    required this.onRemove,
  });

  final CleaningSpecialServiceRequest service;
  final List<CleaningServiceModel> availableServices;
  final ValueChanged<CleaningSpecialServiceRequest> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selectedService = _findServiceById(
      availableServices,
      service.specialServiceId,
    );
    final dirtinessLevels =
        selectedService?.selectableDirtinessLevels ??
        cleaningServiceFallbackDirtinessLevels;
    final selectedDirtiness = selectedService?.normalizeDirtinessLevel(
          service.dirtinessLevel,
        ) ??
        (dirtinessLevels.contains(service.dirtinessLevel)
            ? service.dirtinessLevel
            : dirtinessLevels.first);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: service.specialServiceId,
            decoration: InputDecoration(
              labelText: 'cleaningExtras.selectSpecialService'.tr(),
              border: const OutlineInputBorder(),
            ),
            items: availableServices
                .where((item) => item.id != null && item.name != null)
                .map(
                  (item) => DropdownMenuItem<int>(
                    value: item.id,
                    child: Text(item.name!),
                  ),
                )
                .toList(growable: false),
            onChanged: (id) {
              if (id == null) return;
              final nextService = _findServiceById(availableServices, id);
              final nextDirtiness = nextService?.normalizeDirtinessLevel(
                    service.dirtinessLevel,
                  ) ??
                  service.dirtinessLevel;
              onChanged(
                service.copyWith(
                  specialServiceId: id,
                  dirtinessLevel: nextDirtiness,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final quantity = TextFormField(
                initialValue: service.quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'cleaningExtras.quantity'.tr(),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0) {
                    onChanged(service.copyWith(quantity: parsed));
                  }
                },
              );
              final dirtiness = DropdownButtonFormField<String>(
                value: selectedDirtiness,
                decoration: InputDecoration(
                  labelText: 'cleaningExtras.dirtiness'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: dirtinessLevels
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(_dirtinessDisplayLabel(value)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(service.copyWith(dirtinessLevel: value));
                  }
                },
              );
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    quantity,
                    const SizedBox(height: 10),
                    dirtiness,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: quantity),
                  const SizedBox(width: 10),
                  Expanded(child: dirtiness),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: service.notes,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'cleaningExtras.notesOptional'.tr(),
              border: const OutlineInputBorder(),
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
              label: Text('cleaningExtras.removeSpecialService'.tr()),
            ),
          ),
        ],
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
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
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
      if (quantity != null) quantity,
      if (line.pricingUnit?.trim().isNotEmpty == true)
        line.pricingUnit!.trim(),
      if (line.dirtinessLabel?.trim().isNotEmpty == true)
        line.dirtinessLabel!.trim()
      else if (line.dirtinessLevel?.trim().isNotEmpty == true)
        _dirtinessDisplayLabel(line.dirtinessLevel!.trim()),
    ];
    return _DetailLine(
      title: line.name ?? '-',
      subtitle: details.join(' · '),
      amount: _money(line.totalPrice, currency),
      imageUrl: line.imageUrl,
    );
  }
}

class _OpenTimeCard extends StatelessWidget {
  const _OpenTimeCard({required this.openTime, required this.currency});

  final CleaningOpenTimeModel openTime;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (openTime.workerCount != null)
        MapEntry('cleaningExtras.workerCount'.tr(), '${openTime.workerCount}'),
      if (openTime.hourlyRate != null)
        MapEntry(
          'cleaningExtras.hourlyRate'.tr(),
          '${_money(openTime.hourlyRate, currency)} ${'cleaningExtras.perHour'.tr()}',
        ),
      if (openTime.minimumDuration != null)
        MapEntry(
          'cleaningExtras.minimumDuration'.tr(),
          '${_number(openTime.minimumDuration)} ${'cleaningExtras.hours'.tr()}',
        ),
      if (openTime.actualDuration != null)
        MapEntry(
          'cleaningExtras.actualDuration'.tr(),
          '${_number(openTime.actualDuration)} ${'cleaningExtras.hours'.tr()}',
        ),
      if (openTime.billableDuration != null)
        MapEntry(
          'cleaningExtras.billableDuration'.tr(),
          '${_number(openTime.billableDuration)} ${'cleaningExtras.hours'.tr()}',
        ),
      if (openTime.totalPrice != null)
        MapEntry(
          'cleaningExtras.finalPrice'.tr(),
          _money(openTime.totalPrice, currency),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return _CalculatedLinesCard(
      title: 'cleaningExtras.openTimeEstimate'.tr(),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
            Text(amount!, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: onRetry,
              child: Text('cleaningExtras.retry'.tr()),
            ),
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

String _dirtinessDisplayLabel(String value) {
  final normalized = value.trim();
  return switch (normalized) {
    'light' || 'medium' || 'heavy' => 'cleaningExtras.$normalized'.tr(),
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

String? _money(double? value, String currency) {
  if (value == null) return null;
  return '${value.formatMoney()} $currency'.trim();
}
