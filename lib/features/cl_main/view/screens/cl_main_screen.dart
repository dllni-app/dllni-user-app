import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:dllni_user_app/core/themes/app_theme.dart';
import 'dart:async';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/view/manager/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../generated/assets.dart';
import '../../../rs_home/view/widgets/home_app_bar.dart';
import '../../data/models/cleaning_banners_response_model.dart';
import '../../data/models/cleaning_suite_config_model.dart';
import '../../data/source/cl_main_remote_data_source.dart';
import '../../domain/usecases/get_cleaning_banners_use_case.dart';
import '../data/cl_main_route_args.dart';
import 'cl_hourly_worker_screen.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_main_service_tabs_widget.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../widgets/v6_cleaning_discovery.dart';
import '../widgets/v6_hourly_service_guide.dart';
import '../widgets/cl_occasion_type_card_widget.dart';
import '../widgets/cl_property_type_card_widget.dart';
import '../widgets/cl_cleaning_landing_hero.dart';

class ClMainScreenParams {
  final ProfileBloc profileBloc;
  final ClMainBloc? bloc;

  ClMainScreenParams({required this.profileBloc, this.bloc});
}

@AutoRoutePage()
class ClMainScreen extends StatefulWidget {
  final ClMainScreenParams? params;
  final ClMainBloc? bloc;
  final GetCleaningBannersUseCase? cleaningBannersUseCase;
  final Future<CleaningSuiteConfigModel> Function()? cleaningSuiteConfigLoader;

  const ClMainScreen({
    super.key,
    this.params,
    this.bloc,
    this.cleaningBannersUseCase,
    this.cleaningSuiteConfigLoader,
  });

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
  bool _bannerInteractionPaused = false;

  List<CleaningBannerModel> _cleaningBanners = const <CleaningBannerModel>[];
  List<CleaningHomeTypeModel> _propertyTypes = _fallbackPropertyTypes;
  List<CleaningHomeTypeModel> _occasionTypes = _fallbackOccasionTypes;
  Map<String, CleaningEventTypeConfigModel> _eventTypesBySlug =
      const <String, CleaningEventTypeConfigModel>{};
  BlocStatus _cleaningBannersStatus = BlocStatus.init;
  String? _cleaningBannersErrorMessage;
  int _lengthOfBanners = 0;

  ClMainBloc? get _injectedBloc => widget.params?.bloc ?? widget.bloc;

  @override
  void initState() {
    super.initState();
    _cleaningBannersPageController = PageController();
    _loadCleaningHomeContent();
    _loadSuiteConfig();
  }

  @override
  void dispose() {
    _cleaningBannersTimer?.cancel();
    _cleaningBannersPageController.dispose();
    super.dispose();
  }

  void _startCleaningBannersAutoScroll() {
    _cleaningBannersTimer?.cancel();
    if (_lengthOfBanners < 2) return;
    _cleaningBannersTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted ||
          _lengthOfBanners < 2 ||
          !_cleaningBannersPageController.hasClients ||
          _bannerInteractionPaused ||
          _selectedTabIndex != ClMainServiceTabsWidget.cleaningIndex) {
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

    final useCase =
        widget.cleaningBannersUseCase ?? getIt<GetCleaningBannersUseCase>();
    final result = await useCase(GetCleaningBannersParams());
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
        _startCleaningBannersAutoScroll();
      },
    );
  }

  Future<void> _loadSuiteConfig() async {
    try {
      final config = widget.cleaningSuiteConfigLoader != null
          ? await widget.cleaningSuiteConfigLoader!()
          : await getIt<ClMainRemoteDataSource>().getCleaningSuiteConfig();
      if (!mounted || config.eventTypes.isEmpty) return;
      setState(() {
        _eventTypesBySlug = <String, CleaningEventTypeConfigModel>{
          for (final type in config.eventTypes) type.slug: type,
        };
        // The home-content endpoint owns customer card labels, descriptions,
        // icons and order. Suite config only supplies booking field metadata.
      });
    } catch (_) {
      // Keep the server home-content/legacy list when suite config is absent.
    }
  }

  Future<void> _showBannerPreview(CleaningBannerModel banner) async {
    final imageUrl = banner.imageUrl?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return;

    _bannerInteractionPaused = true;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) {
        final maxHeight = MediaQuery.sizeOf(dialogContext).height * 0.7;
        return Dialog(
          key: const Key('cl_main_banner_preview_dialog'),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  key: const Key('cl_main_banner_preview_close'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: AppImage.network(
                      _reachableBannerUrl(imageUrl),
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    _bannerInteractionPaused = false;
  }

  Future<void> _openQuickApartmentBooking() async {
    final bloc = context.read<ClMainBloc>();
    await AuthGate.requireAuth(
      context,
      onAuthenticated: () {
        if (!mounted) return;
        context.pushRoute(
          '/clmainhomedescription',
          arguments: ClMainHomeDescriptionArgs(
            propertyType: 'apartment',
            bloc: bloc,
          ),
        );
      },
    );
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
      if (_selectedTabIndex != ClMainServiceTabsWidget.cleaningIndex) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
        child: ClCleaningLandingHero(
          onBookApartment: _openQuickApartmentBooking,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
      child: Column(
        key: const Key('cl_main_featured_banner_section'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 172,
            child: PageView.builder(
              key: const Key('cl_main_featured_banner_page_view'),
              controller: _cleaningBannersPageController,
              onPageChanged: (_) {},
              itemCount: _cleaningBanners.length,
              itemBuilder: (_, index) => _ClMainBannerCard(
                banner: _cleaningBanners[index],
                onTap: _showBannerPreview,
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
                  dotColor: SharedPlatformColors.cleaning.withValues(
                    alpha: .34,
                  ),
                  activeDotColor: SharedPlatformColors.cleaning,
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
      backgroundColor: SharedPlatformColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.params != null)
              HomeAppBar(
                isCleaning: true,
                profileBloc: widget.params!.profileBloc,
              ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
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
            // One shared promotion carousel remains visible across the
            // cleaning, occasions and hourly tabs.
            _buildCleaningBannersSection(),
            Expanded(
              child: _selectedTabIndex == ClMainServiceTabsWidget.cleaningIndex
                  ? ListView.separated(
                      key: const Key('cl_main_cleaning_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: _propertyTypes.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return V6CleaningDiscoveryIntro(
                            onBookApartment: _openQuickApartmentBooking,
                          );
                        }
                        final item = _propertyTypes[index - 1];
                        final propertyType = _nonEmpty(item.value, 'apartment');
                        return ClPropertyTypeCardWidget(
                          title: _nonEmpty(item.title, 'نوع تنظيف'),
                          icon: _nonEmpty(item.iconKey, propertyType),
                          description: item.description,
                          args: ClMainHomeDescriptionArgs(
                            propertyType: propertyType,
                            bloc: bloc,
                          ),
                        );
                      },
                    )
                  : _selectedTabIndex == ClMainServiceTabsWidget.occasionsIndex
                  ? ListView.separated(
                      key: const Key('cl_main_occasions_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: _occasionTypes.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) return const V6CleaningOccasionIntro();
                        final item = _occasionTypes[index - 1];
                        final bookingValue = _nonEmpty(item.value, 'other');
                        final eventConfig = _eventTypesBySlug[bookingValue];
                        final option = ClMainOccasionOption(
                          id: _nonEmpty(item.code, bookingValue),
                          bookingValue: bookingValue,
                          title: _nonEmpty(item.title, 'مناسبة'),
                          imagePath: _nonEmpty(
                            item.imageUrl,
                            _occasionFallbackImage(bookingValue),
                          ),
                          eventTypeId: eventConfig?.id,
                          dynamicFields: eventConfig?.fields ?? const [],
                        );
                        return ClOccasionTypeCardWidget(
                          title: option.title,
                          imagePath: option.imagePath,
                          iconKey: _nonEmpty(item.iconKey, bookingValue),
                          description: item.description,
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
                    )
                  : ListView(
                      key: const Key('cl_main_hourly_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      children: [
                        Column(
                          key: const Key('cl_main_hourly_worker_card'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppSectionHeading(
                              title: 'عامل بالساعة',
                              description: 'حدّد ما تحتاجه والمدة المناسبة',
                            ),
                            const SizedBox(height: 16),
                            AppSurfaceCard(
                              section: AppSection.cleaning,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ClHourlyWorkerScreen(),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppSection.cleaning.soft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.schedule_outlined,
                                      color: AppSection.cleaning.ink,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'حجز عامل بالساعة',
                                          style: AlnadhaTokens.sectionTitle,
                                        ),
                                        Text(
                                          'اختر عدد العمال والموعد والمهام. تحدّد التكلفة بحسب الخدمة.',
                                          style: AlnadhaTokens.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_left_rounded,
                                    color: AlnadhaTokens.muted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const V6HourlyServiceGuide(),
                      ],
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
      child: Theme(data: AppTheme.forSection('cleaning'), child: screenBody),
    );
  }
}

String _reachableBannerUrl(String source) {
  final sourceUri = Uri.tryParse(source);
  final backend = Uri.tryParse(
    const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
  );
  if (sourceUri == null || backend == null || backend.host.isEmpty) {
    return source;
  }
  if (sourceUri.host != '127.0.0.1' &&
      sourceUri.host.toLowerCase() != 'localhost') {
    return source;
  }
  return sourceUri.replace(host: backend.host, port: backend.port).toString();
}

class _ClMainBannerCard extends StatelessWidget {
  const _ClMainBannerCard({required this.banner, required this.onTap});

  final CleaningBannerModel banner;
  final Future<void> Function(CleaningBannerModel banner) onTap;

  bool get _hasImage {
    final value = banner.imageUrl?.trim();
    return value != null && value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: _hasImage,
      child: GestureDetector(
        onTap: _hasImage ? () => onTap(banner) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _hasImage
              ? AppImage.network(
                  _reachableBannerUrl(banner.imageUrl!),
                  width: double.infinity,
                  height: 172,
                  fit: BoxFit.cover,
                  errorWidget: Image.asset(
                    'assets/images/cleaning_hero_banner.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/cleaning_hero_banner.png',
                  height: 172,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
