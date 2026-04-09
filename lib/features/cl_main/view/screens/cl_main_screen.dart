import 'package:common_package/annotations/auto_route_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../generated/assets.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_home_app_bar.dart';
import '../widgets/cl_property_type_card_widget.dart';

@AutoRoutePage()
class ClMainScreen extends StatelessWidget {
  const ClMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClMainBloc>(),
      child: Builder(
        builder: (context) {
          final bloc = context.read<ClMainBloc>();
          final propertyTypes = <({String title, String icon, String value})>[
            (
              title: 'فيلا دوبلكس',
              icon: Assets.images.villaImage.path,
              value: 'villa',
            ),
            (
              title: 'مكتب',
              icon: Assets.images.officeImage.path,
              value: 'office',
            ),
            (
              title: 'شقة',
              icon: Assets.images.homeImage.path,
              value: 'apartment',
            ),
            (
              title: 'استديو',
              icon: Assets.images.studioImage.path,
              value: 'studio',
            ),
          ];

          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            body: SafeArea(
              child: Column(
                children: [
                  ClHomeAppBar(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      itemCount: propertyTypes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = propertyTypes[index];
                        return ClPropertyTypeCardWidget(
                          title: item.title,
                          icon: item.icon,
                          args: ClMainHomeDescriptionArgs(
                            propertyType: item.value,
                            bloc: bloc,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
