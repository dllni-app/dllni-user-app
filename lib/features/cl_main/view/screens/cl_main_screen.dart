import 'package:common_package/annotations/auto_route_page.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../generated/assets.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_home_app_bar.dart';
import '../widgets/cl_main_service_tabs_widget.dart';
import '../widgets/cl_occasion_type_card_widget.dart';
import '../widgets/cl_property_type_card_widget.dart';

@AutoRoutePage()
class ClMainScreen extends StatefulWidget {
  const ClMainScreen({this.bloc, super.key});

  final ClMainBloc? bloc;

  @override
  State<ClMainScreen> createState() => _ClMainScreenState();
}

class _ClMainScreenState extends State<ClMainScreen> {
  int _selectedTabIndex = ClMainServiceTabsWidget.cleaningIndex;

  @override
  Widget build(BuildContext context) {
    final screenBody = BlocProvider(
      create: (_) => widget.bloc ?? getIt<ClMainBloc>(),
      child: Builder(
        builder: (context) {
          final bloc = context.read<ClMainBloc>();
          final propertyTypes = <({String title, String icon, String value})>[
            (title: 'فيلا دوبلكس', icon: Assets.images.villaImage.path, value: 'villa'),
            (title: 'مكتب', icon: Assets.images.officeImage.path, value: 'office'),
            (title: 'شقة', icon: Assets.images.homeImage.path, value: 'apartment'),
            (title: 'استديو', icon: Assets.images.studioImage.path, value: 'studio'),
          ];
          final occasionOptions = <ClMainOccasionOption>[
            ClMainOccasionOption(id: 'family_dinner', title: 'عشاء عائلي', imagePath: Assets.images.familyDinner.path),
            ClMainOccasionOption(id: 'birthday_party', title: 'حفلة عيد ميلاد', imagePath: Assets.images.party.path),
            ClMainOccasionOption(id: 'large_gathering', title: 'عزيمة كبيرة', imagePath: Assets.images.bigLaunch.path),
            ClMainOccasionOption(id: 'condolences', title: 'عزاء', imagePath: Assets.images.aza.path),
          ];

          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            body: SafeArea(
              child: Column(
                children: [
                  const ClHomeAppBar(),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                    child: ClMainServiceTabsWidget(
                      selectedIndex: _selectedTabIndex,
                      onChanged: (index) {
                        if (index == _selectedTabIndex) return;
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _selectedTabIndex == ClMainServiceTabsWidget.cleaningIndex
                        ? ListView.separated(
                            key: const Key('cl_main_cleaning_list'),
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                            itemCount: propertyTypes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = propertyTypes[index];
                              return ClPropertyTypeCardWidget(
                                title: item.title,
                                icon: item.icon,
                                args: ClMainHomeDescriptionArgs(propertyType: item.value, bloc: bloc),
                              );
                            },
                          )
                        : ListView.separated(
                            key: const Key('cl_main_occasions_list'),
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                            itemCount: occasionOptions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final option = occasionOptions[index];
                              return ClOccasionTypeCardWidget(
                                title: option.title,
                                imagePath: option.imagePath,
                                onTap: () {
                                  context.pushRoute(
                                    '/clmainoccasiondescription',
                                    arguments: ClMainOccasionDescriptionArgs(option: option, bloc: bloc),
                                  );
                                },
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pushRoute('/main');
        }
      },
      canPop: false,
      child: screenBody,
    );
  }
}
