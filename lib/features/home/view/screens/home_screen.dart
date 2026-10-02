import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/user_session_store.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../cl_main/view/screens/cl_main_screen.dart';
import '../../../orders/data/models/cleaning_booking_status.dart';
import '../../../orders/data/models/cleaning_orders_api_models.dart';
import '../../../orders/data/models/orders_api_models.dart';
import '../../../orders/view/manager/bloc/orders_bloc.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../orders/view/screens/restaurant_order_tracking_screen.dart';
import '../../../profile/domain/usecases/fetch_addresses_use_case.dart';
import '../../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../profile/view/screens/notifications_screen.dart';
import '../../../rs_main/view/rs_main_screen.dart';
import '../../../sm_main_page.dart';
import '../../domain/usecases/fetch_user_offers_use_case.dart';
import '../manager/bloc/home_bloc.dart';
import '../widgets/home_cube.dart';
import '../widgets/platform_home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileBloc profileBloc;
  late final HomeBloc homeBloc;
  late final OrdersBloc cleaningOrdersBloc;
  late final OrdersBloc restaurantOrdersBloc;
  late final OrdersBloc supermarketOrdersBloc;

  @override
  void initState() {
    super.initState();
    profileBloc = getIt<ProfileBloc>();
    homeBloc = getIt<HomeBloc>();
    cleaningOrdersBloc = getIt<OrdersBloc>();
    restaurantOrdersBloc = getIt<OrdersBloc>();
    supermarketOrdersBloc = getIt<OrdersBloc>();

    homeBloc.add(
      FetchUserOffersEvent(params: FetchUserOffersParams(), isReload: true),
    );

    if (AuthGate.isAuthenticated) {
      _refreshAuthenticatedContext();
    }
  }

  @override
  void dispose() {
    homeBloc.close();
    cleaningOrdersBloc.close();
    restaurantOrdersBloc.close();
    supermarketOrdersBloc.close();
    profileBloc.close();
    super.dispose();
  }

  void _refreshAuthenticatedContext() {
    profileBloc
      ..add(
        FetchNotificationsEvent(
          params: FetchNotificationsParams(),
          isReload: true,
        ),
      )
      ..add(FetchAddressesEvent(params: FetchAddressesParams()));

    supermarketOrdersBloc.add(OrdersSectionChangedEvent(0));
    restaurantOrdersBloc.add(OrdersSectionChangedEvent(1));
    cleaningOrdersBloc.add(OrdersSectionChangedEvent(2));
  }

  Future<void> _refreshAll() async {
    homeBloc.add(
      FetchUserOffersEvent(params: FetchUserOffersParams(), isReload: true),
    );
    if (AuthGate.isAuthenticated) {
      _refreshAuthenticatedContext();
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _openCleaning() {
    context.pushRoute(
      '/clmain',
      arguments: ClMainScreenParams(profileBloc: profileBloc),
    );
  }

  void _openRestaurants() {
    context.pushRoute(
      '/rsmain',
      arguments: RsMainScreenParams(profileBloc: profileBloc),
    );
  }

  void _openSupermarket() {
    context.pushRoute('/smmain', arguments: SmMainScreenParams(initialPage: 0));
  }

  Future<void> _requireAuth({
    required String message,
    required VoidCallback onAuthenticated,
  }) {
    return AuthGate.requireAuth(
      context,
      message: message,
      onAuthenticated: onAuthenticated,
    );
  }

  Future<void> _openNotifications() async {
    await _requireAuth(
      message: 'سجّل الدخول لعرض الإشعارات',
      onAuthenticated: () async {
        await context.pushRoute(
          '/notifications',
          arguments: NotificationsScreenParams(profileBloc: profileBloc),
        );
        if (mounted) {
          profileBloc.add(
            FetchNotificationsEvent(
              params: FetchNotificationsParams(),
              isReload: true,
            ),
          );
        }
      },
    );
  }

  Future<void> _openAddresses() async {
    await _requireAuth(
      message: 'سجّل الدخول لإدارة عناوينك',
      onAuthenticated: () async {
        await context.pushRoute('/myaddresses', arguments: false);
        if (mounted) {
          profileBloc.add(FetchAddressesEvent(params: FetchAddressesParams()));
        }
      },
    );
  }

  void _openCoupons() {
    _requireAuth(
      message: 'سجّل الدخول لعرض كوبوناتك',
      onAuthenticated: () => context.pushRoute('/coupons'),
    );
  }

  void _openShoppingLists() {
    _requireAuth(
      message: 'سجّل الدخول لإدارة قوائم التسوق',
      onAuthenticated: () => context.pushRoute('/shopping_list'),
    );
  }

  Future<void> _loginFromHome() async {
    await AuthGate.requireAuth(
      context,
      message: '',
      onAuthenticated: () {
        if (!mounted) return;
        setState(() {});
        _refreshAuthenticatedContext();
      },
    );
  }

  CleaningOrderModel? _activeCleaningOrder(List<CleaningOrderModel> orders) {
    for (final order in orders) {
      final status = (order.status ?? '').trim().toLowerCase();
      if (status != CleaningBookingStatus.completed &&
          status != CleaningBookingStatus.cancelled) {
        return order;
      }
    }
    return null;
  }

  bool _isMerchantOrderActive(OrderResourceModel order) {
    if (order.deliverySummary?.isTerminal == true) return false;
    final status = (order.status ?? '').trim().toLowerCase();
    const terminal = <String>{
      'completed',
      'cancelled',
      'canceled',
      'delivered',
      'rejected',
      'failed',
    };
    return !terminal.contains(status);
  }

  OrderResourceModel? _activeMerchantOrder(List<OrderResourceModel> orders) {
    for (final order in orders) {
      if (_isMerchantOrderActive(order)) return order;
    }
    return null;
  }

  String _money(double value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '$buffer ل.س';
  }

  _ActiveHomeOrder? _merchantPresentation(
    OrderResourceModel? order,
    String section,
  ) {
    if (order == null) return null;
    final isRestaurant = section == 'restaurant';
    final sectionLabel = isRestaurant ? 'مطاعم' : 'سوبرماركت';
    final title = order.merchant?.name?.trim().isNotEmpty == true
        ? order.merchant!.name!.trim()
        : (order.orderNumber?.trim().isNotEmpty == true
              ? 'طلب ${order.orderNumber}'
              : 'طلب $sectionLabel');
    final status = order.statusLabel?.trim().isNotEmpty == true
        ? order.statusLabel!.trim()
        : 'قيد المعالجة';
    final total = order.amounts?.total ?? 0;
    final meta = <String>[
      if (order.orderNumber?.trim().isNotEmpty == true) order.orderNumber!,
      if (total > 0) _money(total),
    ].join(' • ');

    return _ActiveHomeOrder(
      section: section,
      sectionLabel: sectionLabel,
      title: title,
      status: status,
      meta: meta.isEmpty ? 'اضغط لمتابعة تفاصيل الطلب' : meta,
      onTap: () => context.pushRoute(
        '/restaurant-order-tracking',
        arguments: RestaurantOrderTrackingArgs(order: order, section: section),
      ),
    );
  }

  _ActiveHomeOrder? _cleaningPresentation(CleaningOrderModel? order) {
    if (order == null || order.id == null) return null;
    final date = order.scheduledDate?.trim();
    final time = order.scheduledTime?.trim();
    final schedule = [
      date,
      time,
    ].where((value) => value != null && value.isNotEmpty).join(' • ');

    return _ActiveHomeOrder(
      section: 'cleaning',
      sectionLabel: 'تنظيف',
      title: order.bookingNumber?.trim().isNotEmpty == true
          ? 'حجز ${order.bookingNumber}'
          : 'خدمة تنظيف',
      status: cleaningOrderStatusLabelAr(
        order.status,
        startedTravelAt: order.startedTravelAt,
        arrivedAt: order.arrivedAt,
      ),
      meta: schedule.isEmpty
          ? (order.locationName ?? 'عرض تفاصيل الحجز')
          : schedule,
      onTap: () => context.pushRoute(
        '/cleaning-order-details',
        arguments: CleaningOrderDetailsArgs(orderId: order.id!),
      ),
    );
  }

  Widget _buildGlobalActiveOrder() {
    if (!AuthGate.isAuthenticated) {
      return PlatformGuestBenefitCard(
        onLogin: _loginFromHome,
        onRegister: () => context.pushRoute('/register'),
      );
    }

    return BlocBuilder<OrdersBloc, OrdersState>(
      bloc: restaurantOrdersBloc,
      builder: (context, restaurantState) {
        return BlocBuilder<OrdersBloc, OrdersState>(
          bloc: supermarketOrdersBloc,
          builder: (context, supermarketState) {
            return BlocBuilder<OrdersBloc, OrdersState>(
              bloc: cleaningOrdersBloc,
              builder: (context, cleaningState) {
                final restaurant = _merchantPresentation(
                  _activeMerchantOrder(restaurantState.orders.list),
                  'restaurant',
                );
                final supermarket = _merchantPresentation(
                  _activeMerchantOrder(supermarketState.orders.list),
                  'supermarket',
                );
                final cleaning = _cleaningPresentation(
                  _activeCleaningOrder(cleaningState.cleaningOrders.list),
                );
                final active = restaurant ?? supermarket ?? cleaning;

                if (active != null) {
                  return PlatformActiveOrderCard(
                    section: active.section,
                    sectionLabel: active.sectionLabel,
                    title: active.title,
                    status: active.status,
                    meta: active.meta,
                    onTap: active.onTap,
                  );
                }

                final loading =
                    restaurantState.orders.status == BlocStatus.loading ||
                    supermarketState.orders.status == BlocStatus.loading ||
                    cleaningState.cleaningOrders.status == BlocStatus.loading;
                if (loading) {
                  return const _HomeLoadingCard();
                }

                return const _NoActiveOrderCard();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOffers() {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: homeBloc,
      builder: (context, state) {
        if (state.userOffersStatus == BlocStatus.loading &&
            state.userOffers.list.isEmpty) {
          return const _HomeLoadingCard(height: 170);
        }
        return HomeCube(offers: state.userOffers.list);
      },
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: UserSessionStore.userNotifier,
          builder: (context, user, _) {
            final displayName = AuthGate.isAuthenticated
                ? UserSessionStore.displayName(user)
                : 'زائر';
            final address = state.defaultAddress;
            final label = address?.label.trim() ?? '';
            final line1 = address?.line1.trim() ?? '';
            final location = AuthGate.isAuthenticated
                ? (label.isNotEmpty
                      ? label
                      : line1.isNotEmpty
                      ? line1
                      : 'اختر عنوانك')
                : 'تصفح الخدمات كزائر';

            return PlatformHomeHeader(
              displayName: displayName,
              locationLabel: location,
              isAuthenticated: AuthGate.isAuthenticated,
              unreadCount: AuthGate.isAuthenticated
                  ? (state.unreadNotification ?? 0)
                  : 0,
              onNotificationsTap: _openNotifications,
              onLocationTap: _openAddresses,
              onLoginTap: _loginFromHome,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ColoredBox(
        color: SharedPlatformColors.background,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  children: [
                    const PlatformSectionTitle(title: 'شو بدك اليوم؟'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        PlatformServiceCard(
                          title: 'تنظيف',
                          subtitle: 'منزل ومناسبات',
                          icon: Icons.cleaning_services_rounded,
                          accent: SharedPlatformColors.cleaning,
                          soft: SharedPlatformColors.cleaningSoft,
                          onTap: _openCleaning,
                        ),
                        const SizedBox(width: 8),
                        PlatformServiceCard(
                          title: 'مطاعم',
                          subtitle: 'وجبات قريبة',
                          icon: Icons.restaurant_rounded,
                          accent: SharedPlatformColors.restaurant,
                          soft: SharedPlatformColors.restaurantSoft,
                          onTap: _openRestaurants,
                        ),
                        const SizedBox(width: 8),
                        PlatformServiceCard(
                          title: 'سوبرماركت',
                          subtitle: 'مشترياتك',
                          icon: Icons.shopping_basket_rounded,
                          accent: SharedPlatformColors.supermarket,
                          soft: SharedPlatformColors.supermarketSoft,
                          onTap: _openSupermarket,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const PlatformSectionTitle(
                      title: 'عروض مختارة لك',
                      subtitle: 'اسحب المكعب لاكتشاف المزيد من العروض.',
                    ),
                    const SizedBox(height: 8),
                    _buildOffers(),
                    const SizedBox(height: 20),
                    PlatformSectionTitle(
                      title: 'طلبك الحالي',
                      subtitle: AuthGate.isAuthenticated
                          ? 'أهم طلب نشط لديك الآن'
                          : 'سجّل الدخول لحفظ العناوين ومتابعة الطلبات',
                    ),
                    const SizedBox(height: 10),
                    _buildGlobalActiveOrder(),
                    const SizedBox(height: 22),
                    const PlatformSectionTitle(title: 'اختصارات مفيدة'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        PlatformQuickAction(
                          label: 'العناوين',
                          icon: Icons.location_on_outlined,
                          onTap: _openAddresses,
                        ),
                        const SizedBox(width: 8),
                        PlatformQuickAction(
                          label: 'الكوبونات',
                          icon: Icons.local_offer_outlined,
                          onTap: _openCoupons,
                        ),
                        const SizedBox(width: 8),
                        PlatformQuickAction(
                          label: 'قوائمي',
                          icon: Icons.checklist_rounded,
                          onTap: _openShoppingLists,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveHomeOrder {
  const _ActiveHomeOrder({
    required this.section,
    required this.sectionLabel,
    required this.title,
    required this.status,
    required this.meta,
    required this.onTap,
  });

  final String section;
  final String sectionLabel;
  final String title;
  final String status;
  final String meta;
  final VoidCallback onTap;
}

class _HomeLoadingCard extends StatelessWidget {
  const _HomeLoadingCard({this.height = 112});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharedPlatformColors.border),
      ),
      child: const CircularProgressIndicator(
        color: SharedPlatformColors.primary,
      ),
    );
  }
}

class _NoActiveOrderCard extends StatelessWidget {
  const _NoActiveOrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SharedPlatformColors.border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: SharedPlatformColors.success,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'لا يوجد طلب نشط الآن. اختر الخدمة التي تحتاجها من الأعلى.',
              style: TextStyle(
                color: SharedPlatformColors.muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
