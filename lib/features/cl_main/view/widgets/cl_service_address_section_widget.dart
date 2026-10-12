import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../../profile/domain/usecases/fetch_addresses_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';

/// Read-only address preview; the caller remains responsible for selection.
class ClServiceAddressSectionWidget extends StatelessWidget {
  const ClServiceAddressSectionWidget({
    super.key,
    this.locationName = 'المنزل',
    this.address = 'العنوان غير محدد',
    this.showChangeAction = true,
    this.changeActionEnabled = true,
    this.onChangeTap,
    required this.afterBringDefault,
  });

  final String locationName;
  final String address;
  final bool showChangeAction;
  final bool changeActionEnabled;
  final VoidCallback? onChangeTap;
  final void Function() afterBringDefault;

  @override
  Widget build(BuildContext context) => _BookingAddressCard(
    title: locationName,
    address: address,
    showChangeAction: showChangeAction,
    onChangeTap: changeActionEnabled ? onChangeTap : null,
  );
}

/// Keeps the existing address BLoC, default selection, and user callbacks.
class CleaningAddressSelectWidget extends StatelessWidget {
  const CleaningAddressSelectWidget({
    super.key,
    required this.selectedAddress,
    this.showChangeAction = true,
    this.onChangeTap,
    this.afterBringDefault,
  });

  final ValueNotifier<AddressListItem?> selectedAddress;
  final bool showChangeAction;
  final VoidCallback? onChangeTap;
  final VoidCallback? afterBringDefault;

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileBloc>(
    lazy: false,
    create: (_) =>
        getIt<ProfileBloc>()
          ..add(FetchAddressesEvent(params: FetchAddressesParams())),
    child: BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.addressesStatus != current.addressesStatus,
      listener: (context, state) {
        if (state.addressesStatus != BlocStatus.success ||
            selectedAddress.value != null ||
            state.defaultAddress == null) {
          return;
        }
        selectedAddress.value = state.defaultAddress;
        afterBringDefault?.call();
      },
      builder: (context, state) {
        if (state.addressesStatus == BlocStatus.loading ||
            state.addressesStatus == BlocStatus.init) {
          return const _AddressSkeleton();
        }
        return ValueListenableBuilder<AddressListItem?>(
          valueListenable: selectedAddress,
          builder: (context, address, _) => _BookingAddressCard(
            title: address?.label ?? 'لم تحدد عنوان الخدمة',
            address:
                address?.line1 ?? 'اختر عنواناً محفوظاً أو أضف عنواناً جديداً.',
            showChangeAction: showChangeAction,
            onChangeTap: onChangeTap,
          ),
        );
      },
    ),
  );
}

class _BookingAddressCard extends StatelessWidget {
  const _BookingAddressCard({
    required this.title,
    required this.address,
    required this.showChangeAction,
    required this.onChangeTap,
  });

  final String title;
  final String address;
  final bool showChangeAction;
  final VoidCallback? onChangeTap;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    section: AppSection.cleaning,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AlnadhaTokens.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('عنوان الخدمة', style: AlnadhaTokens.sectionTitle),
            ),
            if (showChangeAction)
              TextButton.icon(
                onPressed: onChangeTap,
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: const Text('تغيير'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AlnadhaTokens.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AlnadhaTokens.body.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(address, style: AlnadhaTokens.caption),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AddressSkeleton extends StatelessWidget {
  const _AddressSkeleton();
  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('عنوان الخدمة', style: AlnadhaTokens.sectionTitle),
        const SizedBox(height: 12),
        Container(
          height: 68,
          decoration: BoxDecoration(
            color: AlnadhaTokens.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ],
    ),
  );
}
