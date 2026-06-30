import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../../profile/domain/usecases/fetch_addresses_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';

class ClServiceAddressSectionWidget extends StatelessWidget {
  const ClServiceAddressSectionWidget({
    super.key,
    this.locationName = 'المنزل',
    this.address = 'العنوان غير محدد',
    this.showChangeAction = true,
    this.onChangeTap,
    this.afterBringDefault,
  });

  final String locationName;
  final String address;
  final bool showChangeAction;
  final VoidCallback? onChangeTap;
  final void afterBringDefault;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      lazy: false,
      create: (_) =>
          getIt<ProfileBloc>()
            ..add(FetchAddressesEvent(params: FetchAddressesParams())),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Container(
            child: switch (state.addressesStatus) {
              null || BlocStatus.failed || BlocStatus.success => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF1E2A78),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        AppText.bodyLarge(
                          'عنوان الخدمة',
                          color: const Color(0xFF1E2A78),
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.right,
                        ),
                        const Spacer(),
                        // if (showChangeAction)
                        InkWell(
                          onTap: onChangeTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9E9F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AppText.labelLarge(
                              'عرض',
                              color: const Color(0xFF1E2A78),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        14,
                        12,
                        14,
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bodyMedium(
                            locationName,
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w700,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          AppText.labelLarge(
                            address,
                            color: const Color(0xFF6B7280),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              BlocStatus.init || BlocStatus.loading => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        ShimmerWidget(
                          width: 20,
                          height: 20,
                          shape: BoxShape.circle,
                        ),
                        const SizedBox(width: 6),
                        ShimmerWidget(
                          width: 40,
                          height: 20,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const Spacer(),
                        // if (showChangeAction)
                        ShimmerWidget(
                          width: 70,
                          height: 20,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ShimmerWidget(
                      width: double.infinity,
                      height: 20,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }
}



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
  Widget build(BuildContext context) {
    return

      BlocProvider<ProfileBloc>(
      lazy: false,
      create: (_) =>
      getIt<ProfileBloc>()
        ..add(FetchAddressesEvent(params: FetchAddressesParams())),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context,state){
          if(state.addressesStatus==BlocStatus.success){
            selectedAddress.value=state.defaultAddress;
            if(selectedAddress.value !=null){
              if(afterBringDefault !=null){
                print('asdasdf');
                afterBringDefault!();

              }
            }

          }
        },
        listenWhen: (pre,cur)=>pre.addressesStatus!=cur.addressesStatus,
        builder: (context, state) {
          return Container(
            child: switch (state.addressesStatus) {
              null ||
              BlocStatus.failed ||
              BlocStatus.success => ValueListenableBuilder<AddressListItem?>(
                valueListenable: selectedAddress,
                builder: (context, value, child) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      14,
                      12,
                      14,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF1E2A78),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            AppText.bodyLarge(
                              'عنوان الخدمة',
                              color: const Color(0xFF1E2A78),
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.right,
                            ),
                            const Spacer(),
                            // if (showChangeAction)
                            InkWell(
                              onTap: onChangeTap,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9E9F3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AppText.labelLarge(
                                  'عرض',
                                  color: const Color(0xFF1E2A78),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            14,
                            12,
                            14,
                            12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.bodyMedium(
                                selectedAddress.value?.label ??
                                    state.defaultAddress?.label ??
                                    'اختر عنوان الخدمة',
                                color: const Color(0xFF1F2937),
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 4),
                              AppText.labelLarge(
                                selectedAddress?.value?.line1 ??
                                    state.defaultAddress?.line1 ??
                                    'اضغط لتغيير العنوان',
                                color: const Color(0xFF6B7280),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              BlocStatus.init || BlocStatus.loading => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        ShimmerWidget(
                          width: 35,
                          height: 35,
                          shape: BoxShape.circle,
                        ),
                        const SizedBox(width: 6),
                        ShimmerWidget(
                          width: context.width*.3,
                          height: 35,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const Spacer(),
                        // if (showChangeAction)
                        ShimmerWidget(
                          width: context.width*.15,
                          height: 35,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ShimmerWidget(
                      width: double.infinity,
                      height: 80,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            },
          );
        },
      ),
    );
  }
}
