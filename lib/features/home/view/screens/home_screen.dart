import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/user_session_store.dart';
import '../../../cl_main/view/screens/cl_main_screen.dart';
import '../../../orders/data/models/cleaning_booking_status.dart';
import '../../../orders/data/models/cleaning_orders_api_models.dart';
import '../../../orders/view/manager/bloc/orders_bloc.dart';
import '../../../orders/view/screens/cleaning_order_details_screen.dart';
import '../../../profile/domain/usecases/fetch_addresses_use_case.dart';
import '../../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../profile/view/screens/notifications_screen.dart';
import '../widgets/cleaning_home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileBloc profileBloc;

  @override
  void initState() {
    super.initState();
    profileBloc = getIt<ProfileBloc>();
    if (AuthGate.isAuthenticated) {
      _refreshProfileContext();
    }
  }

  void _refreshProfileContext() {
    profileBloc
      ..add(
        FetchNotificationsEvent(
          params: FetchNotificationsParams(),
          isReload: true,
        ),
      )
      ..add(FetchAddressesEvent(params: FetchAddressesParams()));
  }

  void _openCleaning() {
    context.pushRoute(
      '/clmain',
      arguments: ClMainScreenParams(profileBloc: profileBloc),
    );
  }

  Future<void> _openNotifications() async {
    await AuthGate.requireAuth(
      context,
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
    await AuthGate.requireAuth(
      context,
      message: 'سجّل الدخول لإدارة عناوينك',
      onAuthenticated: () async {
        await context.pushRoute('/myaddresses');
        if (mounted) {
          profileBloc.add(FetchAddressesEvent(params: FetchAddressesParams()));
        }
      },
    );
  }

  void _openCleaningOrder(CleaningOrderModel order) {
    final id = order.id;
    if (id == null) return;
    context.pushRoute(
      '/cleaning-order-details',
      arguments: CleaningOrderDetailsArgs(orderId: id),
    );
  }

  CleaningOrderModel? _activeOrder(List<CleaningOrderModel> orders) {
    for (final order in orders) {
      final status = (order.status ?? '').trim().toLowerCase();
      if (status != CleaningBookingStatus.completed &&
          status != CleaningBookingStatus.cancelled) {
        return order;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<OrdersBloc>(
          create: (_) {
            final bloc = getIt<OrdersBloc>();
            if (AuthGate.isAuthenticated) {
              bloc.add(OrdersSectionChangedEvent(2));
            }
            return bloc;
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: const Color(0xFFF7F8FA),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (AuthGate.isAuthenticated) {
                      _refreshProfileContext();
                      context.read<OrdersBloc>().add(
                        FetchOrdersEvent(isReload: true),
                      );
                    }
                    await Future<void>.delayed(
                      const Duration(milliseconds: 250),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _buildAddressCard(),
                      const SizedBox(height: 18),
                      _SectionTitle(
                        title: 'طلبك الحالي',
                        subtitle: 'تابع آخر طلب تنظيف يحتاج انتباهك',
                      ),
                      const SizedBox(height: 10),
                      _buildActiveBooking(),
                      const SizedBox(height: 20),
                      CleaningHomePrimaryServiceCard(onTap: _openCleaning),
                      const SizedBox(height: 22),
                      const _SectionTitle(
                        title: 'خدمات التنظيف',
                        subtitle: 'تجربة مركزة للتنظيف والمناسبات فقط',
                      ),
                      const SizedBox(height: 10),
                      _CleaningDiscoveryTile(
                        icon: Icons.home_outlined,
                        title: 'تنظيف المنزل',
                        subtitle:
                            'حدد الغرف والأحجام ونوع التنظيف ثم أكمل الموعد.',
                        onTap: _openCleaning,
                      ),
                      const SizedBox(height: 10),
                      _CleaningDiscoveryTile(
                        icon: Icons.celebration_outlined,
                        title: 'مساعدة المناسبات',
                        subtitle:
                            'اختر نوع المناسبة وعدد الضيوف والمدة والفريق.',
                        onTap: _openCleaning,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      buildWhen: (previous, current) =>
          previous.unreadNotification != current.unreadNotification,
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: UserSessionStore.userNotifier,
          builder: (context, user, _) {
            return CleaningHomeHeader(
              displayName: AuthGate.isAuthenticated
                  ? UserSessionStore.displayName(user)
                  : 'زائر',
              isAuthenticated: AuthGate.isAuthenticated,
              unreadCount: AuthGate.isAuthenticated
                  ? (state.unreadNotification ?? 0)
                  : 0,
              onNotificationsTap: _openNotifications,
            );
          },
        );
      },
    );
  }

  Widget _buildAddressCard() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      buildWhen: (previous, current) =>
          previous.defaultAddress != current.defaultAddress ||
          previous.addressesStatus != current.addressesStatus,
      builder: (context, state) {
        final address = state.defaultAddress;
        return CleaningHomeAddressCard(
          label: address?.label,
          line1: address?.line1,
          isLoading:
              AuthGate.isAuthenticated &&
              state.addressesStatus == BlocStatus.loading,
          onTap: _openAddresses,
        );
      },
    );
  }

  Widget _buildActiveBooking() {
    if (!AuthGate.isAuthenticated) {
      return CleaningHomeEmptyBookingCard(
        isAuthenticated: false,
        onBookTap: _openCleaning,
      );
    }

    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (previous, current) =>
          previous.cleaningOrders != current.cleaningOrders ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        final pagination = state.cleaningOrders;
        if (pagination.status == BlocStatus.loading ||
            pagination.status == BlocStatus.init) {
          return const _HomeLoadingCard();
        }

        if (pagination.status == BlocStatus.failed) {
          return _HomeLoadErrorCard(
            message: state.errorMessage ?? 'تعذر تحميل طلبات التنظيف',
            onRetry: () => context.read<OrdersBloc>().add(
              FetchOrdersEvent(isReload: true),
            ),
          );
        }

        final active = _activeOrder(pagination.list);
        if (active == null) {
          return CleaningHomeEmptyBookingCard(
            isAuthenticated: true,
            onBookTap: _openCleaning,
          );
        }

        return CleaningHomeActiveBookingCard(
          order: active,
          onTap: () => _openCleaningOrder(active),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textAlign: TextAlign.start,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
        ),
      ],
    );
  }
}

class _CleaningDiscoveryTile extends StatelessWidget {
  const _CleaningDiscoveryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF0F8E98)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLoadingCard extends StatelessWidget {
  const _HomeLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _HomeLoadErrorCard extends StatelessWidget {
  const _HomeLoadErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2B8B5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: Color(0xFFB42318)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7A271A)),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
