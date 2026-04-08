import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

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
  void _setDefaultAddress(AddressListItem item, ProfileBloc bloc, BuildContext context) {
    final id = int.tryParse(item.id);
    if (id == null) return;
    bloc.add(SetDefaultAddressEvent(addressId: id, context: context));
  }

  Future<void> _confirmDeleteAddress(AddressListItem item, ProfileBloc bloc, BuildContext context) async {
    final id = int.tryParse(item.id);
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: AppText.labelLarge('تحذير', color: Colors.black, textAlign: TextAlign.start),
          content: AppText.labelLarge('هل أنت متأكد من حذف هذا العنوان؟ لا يمكن التراجع عن العملية.', color: Colors.black),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('حذف', style: TextStyle(color: context.error)),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    bloc.add(DeleteAddressEvent(addressId: id, context: context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      lazy: false,
      create: (_) => getIt<ProfileBloc>()..add(FetchAddressesEvent(params: FetchAddressesParams())),
      child: Scaffold(
        backgroundColor: const Color(0xffF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
              PersonalDetailsAppBar(title: widget.selectMode ? 'اختيار العنوان' : 'عناويني'),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state.addressesStatus == null || state.addressesStatus == BlocStatus.loading || state.addressesStatus == BlocStatus.init) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final addresses = state.addresses;
                    if (addresses.isEmpty) {
                      return const Center(child: Text('لا توجد عناوين محفوظة'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(FetchAddressesEvent(params: FetchAddressesParams()));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!widget.selectMode) ...[
                              ElevatedButton(
                                onPressed: () {
                                  context.pushRoute('/addaddress', arguments: MyAddressesScreenParams(bloc: context.read<ProfileBloc>()));
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: context.primaryContainer,
                                  foregroundColor: context.onPrimaryContainer,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppText.labelLarge('إضافة عنوان جديد', color: context.onPrimaryContainer, fontWeight: FontWeight.w700),
                                    const SizedBox(width: 10),
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: context.onPrimaryContainer,
                                      child: Icon(Icons.add, size: 16, color: context.primaryContainer),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            ...addresses.map((item) {
                              final isDefault = state.defaultAddressId == item.id;
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: 12),
                                child: AddressCard(
                                  item: item,
                                  isDefault: isDefault,
                                  showActions: !widget.selectMode,
                                  onTap: widget.selectMode ? () => context.pop(item) : null,
                                  onSetDefault: isDefault ? null : () => _setDefaultAddress(item, context.read<ProfileBloc>(), context),
                                  onEdit: () {
                                    context.pushRoute(
                                      '/addaddress',
                                      arguments: MyAddressesScreenParams(bloc: context.read<ProfileBloc>(), addressItem: item),
                                    );
                                  },
                                  onDelete: () => _confirmDeleteAddress(item, context.read<ProfileBloc>(), context),
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
