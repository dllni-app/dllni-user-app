import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/deeplink/deep_link_parser.dart';
import '../../../../core/deeplink/deep_link_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../generated/assets.dart';
import '../../data/models/cleaning_banners_response_model.dart';
import '../../domain/usecases/get_cleaning_banners_use_case.dart';
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

  late final PageController _cleaningBannersPageController;
  Timer? _cleaningBannersTimer;

  List<CleaningBannerModel> _cleaningBanners = const <CleaningBannerModel>[];
  BlocStatus _cleaningBannersStatus = BlocStatus.init;
  String? _cleaningBannersErrorMessage;
  int _lengthOfBanners = 0;

  @override
  void initState() {
    super.initState();
    _cleaningBannersPageController = PageController();
    _loadCleaningBanners();
    _startCleaningBannersAutoScroll();
  }

  @override
  void dispose() {
    _cleaningBannersTimer?.cancel();
    _cleaningBannersPageController.dispose();
    super.dispose();
  }

  void _startCleaningBannersAutoScroll() {
    _cleaningBannersTimer?.cancel();
    _cleaningBannersTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted ||
          _lengthOfBanners < 2 ||
          !_cleaningBannersPageController.hasClients) {
        return;
      }
      final currentPage = (_cleaningBannersPageController.page ?? 0).round();
      if (currentPage < _lengthOfBanners - 1) {
        _cleaningBannersPageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _cleaningBannersPageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadCleaningBanners() async {
    if (!mounted) return;
    setState(() {
      _cleaningBannersStatus = BlocStatus.loading;
      _cleaningBannersErrorMessage = null;
    });

    final result = await getIt<GetCleaningBannersUseCase>()(
      GetCleaningBannersParams(),
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _cleaningBannersStatus = BlocStatus.failed;
          _cleaningBannersErrorMessage = failure.message;
        });
      },
      (response) {
        setState(() {
          _cleaningBannersStatus = BlocStatus.success;
          _cleaningBanners = response.banners;
          _lengthOfBanners = response.banners.length;
          _cleaningBannersErrorMessage = null;
        });
      },
    );
  }

  Future<void> _openBannerTargetUrl(String? targetUrl) async {
    final value = targetUrl?.trim();
    if (value == null || value.isEmpty) return;

    final uri = Uri.tryParse(value);
    if (uri == null) return;

    if (getIt.isRegistered<DeepLinkService>() &&
        DeepLinkParser.isSupportedDeepLink(uri)) {
      await getIt<DeepLinkService>().handleIncomingUri(uri);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }

  Widget _buildCleaningBannersSection() {
    if (_cleaningBannersStatus == BlocStatus.loading) {
      return const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
        child: SizedBox(
          height: 130,
          child: Center(
            child: CircularProgressIndicator(
              key: Key('cl_main_banner_loading'),
            ),
          ),
        ),
      );
    }

    if (_cleaningBannersStatus == BlocStatus.failed) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
        child: FailureWidget(
          message: _cleaningBannersErrorMessage ?? 'تعذر تحميل البانرات',
          onRetry: _loadCleaningBanners,
        ),
      );
    }

    if (_cleaningBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
      child: Column(
        key: const Key('cl_main_featured_banner_section'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 130,
            child: PageView.builder(
              key: const Key('cl_main_featured_banner_page_view'),
              controller: _cleaningBannersPageController,
              itemCount: _cleaningBanners.length,
              itemBuilder: (_, index) => _ClMainBannerCard(
                banner: _cleaningBanners[index],
                onTap: _openBannerTargetUrl,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 4,
            child: Center(
              child: SmoothPageIndicator(
                controller: _cleaningBannersPageController,
                count: _cleaningBanners.length,
                effect: ExpandingDotsEffect(
                  expansionFactor: 1.01,
                  dotHeight: 4,
                  dotWidth: 18,
                  spacing: 4,
                  dotColor: AppColors.primary.withValues(alpha: .34),
                  activeDotColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenBody(BuildContext context) {
    final bloc = context.read<ClMainBloc>();
    final propertyTypes = <({String title, String icon, String value})>[
      (
        title: 'فيلا دوبلكس',
        icon: Assets.images.villaImage.path,
        value: 'villa',
      ),
      (title: 'مكتب', icon: Assets.images.officeImage.path, value: 'office'),
      (title: 'شقة', icon: Assets.images.homeImage.path, value: 'apartment'),
      (title: 'استديو', icon: Assets.images.studioImage.path, value: 'studio'),
    ];
    final occasionOptions = <ClMainOccasionOption>[
      ClMainOccasionOption(
        id: 'family_dinner',
        title: 'عشاء عائلي',
        imagePath: Assets.images.familyDinner.path,
      ),
      ClMainOccasionOption(
        id: 'birthday_party',
        title: 'حفلة عيد ميلاد',
        imagePath: Assets.images.party.path,
      ),
      ClMainOccasionOption(
        id: 'large_gathering',
        title: 'عزيمة كبيرة',
        imagePath: Assets.images.bigLaunch.path,
      ),
      ClMainOccasionOption(
        id: 'condolences',
        title: 'عزاء',
        imagePath: Assets.images.aza.path,
      ),
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
            _buildCleaningBannersSection(),
            Expanded(
              child: _selectedTabIndex == ClMainServiceTabsWidget.cleaningIndex
                  ? ListView.separated(
                      key: const Key('cl_main_cleaning_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      itemCount: propertyTypes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                    )
                  : ListView.separated(
                      key: const Key('cl_main_occasions_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      itemCount: occasionOptions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = occasionOptions[index];
                        return ClOccasionTypeCardWidget(
                          title: option.title,
                          imagePath: option.imagePath,
                          onTap: () {
                            context.pushRoute(
                              '/clmainoccasiondescription',
                              arguments: ClMainOccasionDescriptionArgs(
                                option: option,
                                bloc: bloc,
                              ),
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
  }

  @override
  Widget build(BuildContext context) {
    final screenContent = Builder(builder: _buildScreenBody);
    final screenBody = widget.bloc != null
        ? BlocProvider<ClMainBloc>.value(
            value: widget.bloc!,
            child: screenContent,
          )
        : BlocProvider<ClMainBloc>(
            create: (_) => getIt<ClMainBloc>(),
            child: screenContent,
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

class _ClMainBannerCard extends StatelessWidget {
  const _ClMainBannerCard({required this.banner, required this.onTap});

  final CleaningBannerModel banner;
  final Future<void> Function(String? targetUrl) onTap;

  bool get _hasTargetUrl {
    final value = banner.targetUrl?.trim();
    return value != null && value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    final card = Container(
      height: 130,
      width: context.width,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Stack(
        children: [
          if (hasImage)
            Positioned.fill(
              child: AppImage.network(
                imageUrl,
                fit: BoxFit.cover,
                errorWidget: const ColoredBox(color: AppColors.primary),
              ),
            ),
          if (hasImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.92),
                      AppColors.primary.withValues(alpha: 0.55),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(hasImage ? 100 : 24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  banner.title ?? '',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 20 / 16,
                  ),
                ),
                if (banner.subtitle?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  AppText(
                    banner.subtitle!,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 24 / 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasImage)
            Positioned(
              left: -36,
              top: 16,
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 68,
                child: AppImage.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  size: 136,
                  errorWidget: const Icon(
                    Icons.error_outline,
                    color: Colors.black,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(68)),
                ),
              ),
            ),
        ],
      ),
    );

    if (!_hasTargetUrl) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(banner.targetUrl),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: card,
      ),
    );
  }
}
