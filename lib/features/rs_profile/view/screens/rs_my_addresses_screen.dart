import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/rs_address_list_item.dart';
import '../../domain/usecases/fetch_addresses_use_case.dart';
import '../manager/bloc/rs_profile_bloc.dart';
import '../widgets/rs_address_card.dart';
import '../widgets/rs_personal_details_app_bar.dart';

@AutoRoutePage()
class RsMyAddressesScreen extends StatefulWidget {
  const RsMyAddressesScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<RsMyAddressesScreen> createState() => _RsMyAddressesScreenState();
}

class _RsMyAddressesScreenState extends State<RsMyAddressesScreen> {
  Future<void> _refreshAddresses() async {
    final bloc = context.read<RsProfileBloc>();
    bloc.add(FetchAddressesEvent(params: FetchAddressesParams()));
    await bloc.stream.firstWhere((state) => state.addressesStatus != BlocStatus.loading);
  }

  void _setDefaultAddress(RsAddressListItem item) {
    final id = int.tryParse(item.id);
    if (id == null) return;
    context.read<RsProfileBloc>().add(SetDefaultAddressEvent(addressId: id));
  }

  void _showSoonMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsProfileBloc>(
      lazy: false,
      create: (_) => getIt<RsProfileBloc>()..add(FetchAddressesEvent(params: FetchAddressesParams())),
      child: BlocListener<RsProfileBloc, RsProfileState>(
        listenWhen: (previous, current) =>
            previous.setDefaultAddressStatus != current.setDefaultAddressStatus && current.setDefaultAddressStatus == BlocStatus.failed,
        listener: (context, state) {
          if (state.errorMessage == null || state.errorMessage!.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                RsPersonalDetailsAppBar(title: widget.selectMode ? 'اختيار العنوان' : 'عناويني'),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<RsProfileBloc, RsProfileState>(
                    builder: (context, state) {
                      if (state.addressesStatus == null || state.addressesStatus == BlocStatus.loading || state.addressesStatus == BlocStatus.init) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final addresses = state.addresses;
                      if (addresses.isEmpty) {
                        return const Center(child: Text('لا توجد عناوين محفوظة'));
                      }
                      return RefreshIndicator(
                        onRefresh: _refreshAddresses,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!widget.selectMode) ...[
                                ElevatedButton(
                                  onPressed: () => _showSoonMessage('ميزة إضافة عنوان جديد قريباً'),
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
                                  child: RsAddressCard(
                                    item: item,
                                    isDefault: isDefault,
                                    showActions: !widget.selectMode,
                                    onTap: widget.selectMode ? () => context.pop(item) : null,
                                    onSetDefault: isDefault ? null : () => _setDefaultAddress(item),
                                    onEdit: () => _showSoonMessage('تعديل العنوان غير متاح حالياً'),
                                    onDelete: () => _showSoonMessage('حذف العنوان غير متاح حالياً'),
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
      ),
    );
  }
}
