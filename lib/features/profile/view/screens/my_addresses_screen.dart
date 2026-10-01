import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/address_list_item.dart';
import '../../domain/usecases/fetch_addresses_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/address_card.dart';
import '../widgets/personal_details_app_bar.dart';
import 'add_address_screen.dart';

@AutoRoutePage()
class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  void _setDefaultAddress(AddressListItem item, ProfileBloc bloc) {
    final id = int.tryParse(item.id);
    if (id == null) return;
    bloc.add(SetDefaultAddressEvent(addressId: id, context: context));
  }

  Future<void> _confirmDeleteAddress(
    AddressListItem item,
    ProfileBloc bloc,
  ) async {
    final id = int.tryParse(item.id);
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: AppText.labelLarge(
            'تحذير',
            color: Colors.black,
            textAlign: TextAlign.start,
          ),
          content: AppText.labelLarge(
            'هل أنت متأكد من حذف هذا العنوان؟ لا يمكن التراجع عن العملية.',
            color: Colors.black,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('حذف', style: TextStyle(color: context.error)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    if (!mounted) return;
    bloc.add(DeleteAddressEvent(addressId: id, context: context));
  }

  Future<List<AddressListItem>> _refreshAndWait(ProfileBloc bloc) async {
    final completer = Completer<List<AddressListItem>>();
    late final StreamSubscription<ProfileState> subscription;
    subscription = bloc.stream.listen((state) {
      if (state.addressesStatus == BlocStatus.success ||
          state.addressesStatus == BlocStatus.failed) {
        if (!completer.isCompleted) {
          completer.complete(state.addresses);
        }
      }
    });

    bloc.add(FetchAddressesEvent(params: FetchAddressesParams()));
    final result = await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => bloc.state.addresses,
    );
    await subscription.cancel();
    return result;
  }

  AddressListItem? _resolveCreatedAddress(
    List<AddressListItem> addresses,
    CreatedAddressSelectionHint hint,
  ) {
    bool closeEnough(double? a, double? b) {
      if (a == null || b == null) return false;
      return (a - b).abs() < 0.00001;
    }

    for (final item in addresses) {
      final isMatch =
          item.label.trim() == hint.label.trim() &&
          (item.mobile ?? '').trim() == hint.mobile.trim() &&
          (item.city ?? '').trim() == hint.city.trim() &&
          (item.neighborhood ?? '').trim() == hint.neighborhood.trim() &&
          (item.street ?? '').trim() == hint.street.trim() &&
          (item.floor ?? '').trim() == hint.floor.trim() &&
          closeEnough(item.latitude, hint.latitude) &&
          closeEnough(item.longitude, hint.longitude);
      if (isMatch) return item;
    }

    final withNumericId =
        addresses
            .map((item) => (item: item, id: int.tryParse(item.id)))
            .where((entry) => entry.id != null)
            .toList()
          ..sort((a, b) => b.id!.compareTo(a.id!));
    if (withNumericId.isNotEmpty) return withNumericId.first.item;
    return addresses.isNotEmpty ? addresses.first : null;
  }

  Future<void> _openAddAddress(ProfileBloc bloc) async {
    final result = await context.pushRoute(
      '/addaddress',
      arguments: MyAddressesScreenParams(
        bloc: bloc,
        selectMode: widget.selectMode,
      ),
    );
    if (!mounted) return;

    if (widget.selectMode && result is CreatedAddressSelectionHint) {
      final refreshed = await _refreshAndWait(bloc);
      if (!mounted) return;
      final selected = _resolveCreatedAddress(refreshed, result);
      if (selected != null) {
        context.pop(selected);
      }
      return;
    }

    if (result == true) {
      bloc.add(FetchAddressesEvent(params: FetchAddressesParams()));
    }
  }

  Widget _addAddressButton(ProfileBloc bloc, BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _openAddAddress(bloc),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: const Color(0xFF1E2A78),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.add_location_alt_outlined, size: 20),
      label: const Text(
        'إضافة عنوان جديد',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      lazy: false,
      create: (_) =>
          getIt<ProfileBloc>()
            ..add(FetchAddressesEvent(params: FetchAddressesParams())),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Column(
            children: [
              PersonalDetailsAppBar(
                title: widget.selectMode ? 'اختيار العنوان' : 'عناويني',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state.addressesStatus == null ||
                        state.addressesStatus == BlocStatus.loading ||
                        state.addressesStatus == BlocStatus.init) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bloc = context.read<ProfileBloc>();
                    final addresses = state.addresses;

                    if (addresses.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          bloc.add(
                            FetchAddressesEvent(params: FetchAddressesParams()),
                          );
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            20,
                            0,
                            20,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _addAddressButton(bloc, context),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE4E7EC),
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.location_off_outlined,
                                      size: 42,
                                      color: Color(0xFF98A2B3),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'لا توجد عناوين محفوظة',
                                      style: TextStyle(
                                        color: Color(0xFF172033),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'أضف عنواناً لتسريع طلبات التوصيل والخدمات القادمة.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF667085),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(
                          FetchAddressesEvent(params: FetchAddressesParams()),
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          0,
                          20,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _addAddressButton(bloc, context),
                            const SizedBox(height: 16),
                            ...addresses.map((item) {
                              final isDefault =
                                  state.defaultAddress?.id == item.id;
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  bottom: 12,
                                ),
                                child: AddressCard(
                                  item: item,
                                  isDefault: isDefault,
                                  showActions: !widget.selectMode,
                                  onTap: widget.selectMode
                                      ? () => context.pop(item)
                                      : null,
                                  onSetDefault: isDefault
                                      ? null
                                      : () => _setDefaultAddress(item, bloc),
                                  onEdit: () {
                                    context.pushRoute(
                                      '/addaddress',
                                      arguments: MyAddressesScreenParams(
                                        bloc: bloc,
                                        addressItem: item,
                                        selectMode: widget.selectMode,
                                      ),
                                    );
                                  },
                                  onDelete: () =>
                                      _confirmDeleteAddress(item, bloc),
                                ),
                              );
                            }),
                          ],
                        ),
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
  }
}
