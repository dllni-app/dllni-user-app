import 'dart:async';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/view/manager/bloc/profile_bloc.dart';
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
import '../../../rs_home/view/widgets/home_app_bar.dart';
import '../../data/models/cleaning_banners_response_model.dart';
import '../../domain/usecases/get_cleaning_banners_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_main_service_tabs_widget.dart';
import '../widgets/cl_occasion_type_card_widget.dart';
import '../widgets/cl_property_type_card_widget.dart';

class ClMainScreenParams {
  final ProfileBloc profileBloc;
  final ClMainBloc? bloc;

  ClMainScreenParams({required this.profileBloc, this.bloc});
}

@AutoRoutePage()
class ClMainScreen extends StatefulWidget {
  final ClMainScreenParams? params;
  final ClMainBloc? bloc;

  const ClMainScreen({super.key, this.params, this.bloc});

  @override
  State<ClMainScreen> createState() => _ClMainScreenState();
}

class _ClMainScreenState extends State<ClMainScreen> {
  static const List<CleaningHomeTypeModel> _fallbackPropertyTypes = [
    CleaningHomeTypeModel(
      section: 'property',
      code: 'villa',
      value: 'villa',
      title: 'فيلا دوبلكس',
      imageUrl: 'assets/images/villa_image.png',
      sortOrder: 10,
    ),
    CleaningHomeTypeModel(
      section: 'property',
      code: 'office',
      value: 'office',
      title: 'مكتب',
      imageUrl: 'assets/images/office_image.png',
      sortOrder: 20,
    ),
    CleaningHomeTypeModel(
      section: 'property',
      code: 'apartment',
      value: 'apartment',
      title: 'شقة',
      imageUrl: 'assets/images/home_image.png',
      sortOrder: 30,
    ),
    CleaningHomeTypeModel(
      section: 'property',
      code: 'studio',
      value: 'studio',
      title: 'استديو',
      imageUrl: 'assets/images/studio_image.png',
      sortOrder: 40,
    ),
  ];

  static const List<CleaningHomeTypeModel> _fallbackOccasionTypes = [
    CleaningHomeTypeModel(
      section: 'occasion',
      code: 'family_dinner',
      value: 'family_dinner',
      title: 'عشاء عائلي',
      imageUrl: 'assets/images/family_dinner.png',
      sortOrder: 10,
    ),
    CleaningHomeTypeModel(
      section: 'occasion',
      code: 'birthday',
      value: 'birthday',
      title: 'حفلة عيد ميلاد',
      imageUrl: 'assets/images/party.png',
      sortOrder: 20,
    ),
    CleaningHomeTypeModel(
      section: 'occasion',
      code: 'large_gathering',
      value: 'large_gathering',
      title: 'عزيمة كبيرة',
      imageUrl: 'assets/images/big_launch.png',
      sortOrder: 30,
    ),
    CleaningHomeTypeModel(
      section: 'occasion',
      code: 'funeral',
      value: 'funeral',
      title: 'عزاء',
      imageUrl: 'assets/images/aza.png',
      sortOrder: 40,
    ),
  ];

  int _selectedTabIndex = ClMainServiceTabsWidget.cleaningIndex;

  late final PageController _cleaningBannersPageController;
  Timer? _cleaningBannersTimer;

  List<CleaningBannerModel> _cleaningBanners = const <CleaningBannerModel>[];
  List<CleaningHomeTypeModel> _propertyTypes = _fallbackPropertyTypes;
  List<CleaningHomeTypeModel> _occasionTypes = _fallbackOccasionTypes;
  BlocStatus _cleaningBannersStatus = BlocStatus.init;
  String? _cleaningBannersErrorMessage;
  int _lengthOfBanners = 0;

  ClMainBloc? get _injectedBloc => widget.params?.bloc ?? widget.bloc;

  @override
  void initState() {
    super.initState();
    _cleaningBannersPageController = PageController();
    _loadCleaningHomeContent();
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

  Future<void> _loadCleaningHomeContent() async {
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
          _propertyTypes = response.propertyTypes.isNotEmpty
              ? response.propertyTypes
              : _fallbackPropertyTypes;
          _occasionTypes = response.occasionTypes.isNotEmpty
              ? response.occasionTypes
              : _fallbackOccasionTypes;
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الرابط')),
      );
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
          message: _cleaningBannersErrorMessage ?? 'تعذر تحميل محتوى التنظيف',
          onRetry: _loadCleaningHomeContent,
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

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.params != null)
              HomeAppBar(
                isCleaning: true,
                profileBloc: widget.params!.profileBloc,
              ),
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
              child:
                  _selectedTabIndex == ClMainServiceTabsWidget.cleaningIndex
                  ? ListView.separated(
                      key: const Key('cl_main_cleaning_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      itemCount: _propertyTypes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _propertyTypes[index];
                        final propertyType = _nonEmpty(item.value, 'apartment');
                        return ClPropertyTypeCardWidget(
                          title: _nonEmpty(item.title, 'نوع تنظيف'),
                          icon: _nonEmpty(
                            item.imageUrl,
                            _propertyFallbackImage(propertyType),
                          ),
                          args: ClMainHomeDescriptionArgs(
                            propertyType: propertyType,
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
                      itemCount: _occasionTypes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _occasionTypes[index];
                        final bookingValue = _nonEmpty(item.value, 'other');
                        final option = ClMainOccasionOption(
                          id: _nonEmpty(item.code, bookingValue),
                          bookingValue: bookingValue,
                          title: _nonEmpty(item.title, 'مناسبة'),
                          imagePath: _nonEmpty(
                            item.imageUrl,
                            _occasionFallbackImage(bookingValue),
                          ),
                        );
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

  String _nonEmpty(String? value, String fallback) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  String _propertyFallbackImage(String propertyType) {
    return switch (propertyType) {
      'villa' => Assets.images.villaImage.path,
      'office' => Assets.images.officeImage.path,
      'studio' => Assets.images.studioImage.path,
      _ => Assets.images.homeImage.path,
    };
  }

  String _occasionFallbackImage(String eventType) {
    return switch (eventType) {
      'family_dinner' => Assets.images.familyDinner.path,
      'birthday' => Assets.images.party.path,
      'large_gathering' => Assets.images.bigLaunch.path,
      'funeral' => Assets.images.aza.path,
      _ => Assets.images.party.path,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenContent = Builder(builder: _buildScreenBody);
    final injectedBloc = _injectedBloc;
    final screenBody = injectedBloc != null
        ? BlocProvider<ClMainBloc>.value(
            value: injectedBloc,
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
    return Semantics(
      button: _hasTargetUrl,
      child: GestureDetector(
        onTap: _hasTargetUrl ? () => onTap(banner.targetUrl) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AppImage.network(
            banner.imageUrl ?? '',
            width: double.infinity,
            height: 130,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
