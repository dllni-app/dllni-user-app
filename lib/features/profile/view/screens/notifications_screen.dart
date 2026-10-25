import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../../../core/themes/shared_platform_colors.dart';

import '../../data/models/fetch_notifications_model.dart';
import '../../domain/usecases/fetch_notifications_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/notification_feed_item.dart';
import '../widgets/notification_navigation.dart';
import '../widgets/v7_notification_filter.dart';

@AutoRoutePage()
class NotificationsScreen extends StatefulWidget {
  final NotificationsScreenParams args;

  const NotificationsScreen({super.key, required this.args});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ProfileBloc profileBloc;
  String _activeFilter = 'all';

  bool _matchesFilter(FetchNotificationsModelDataItem item) =>
      notificationMatchesV7Filter(item, _activeFilter);

  Widget _filterStrip() {
    const options = <(String, String)>[
      ('all', 'الكل'),
      ('unread', 'غير المقروءة'),
      ('orders', 'الطلبات'),
      ('offers', 'العروض'),
    ];
    return SizedBox(
      height: 57,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option.$2),
              selected: _activeFilter == option.$1,
              showCheckmark: false,
              onSelected: (_) => setState(() => _activeFilter = option.$1),
              selectedColor: SharedPlatformColors.cleaningSoft,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: _activeFilter == option.$1
                    ? SharedPlatformColors.cleaning
                    : const Color(0xFFE2E7EE),
              ),
              labelStyle: TextStyle(
                color: _activeFilter == option.$1
                    ? SharedPlatformColors.primary
                    : SharedPlatformColors.muted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    profileBloc = widget.args.profileBloc
      ..add(
        FetchNotificationsEvent(
          params: FetchNotificationsParams(),
          isReload: true,
          markAllReadOnSuccess: true,
        ),
      );
    super.initState();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _bucketLabel(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);

    if (_isSameDay(today, target)) return 'اليوم';
    if (_isSameDay(today.subtract(const Duration(days: 1)), target)) {
      return 'أمس';
    }
    if (today.difference(target).inDays <= 7) return 'الأسبوع الماضي';
    return 'الأقدم';
  }

  Map<String, List<FetchNotificationsModelDataItem>> _groupNotifications(
    List<FetchNotificationsModelDataItem> notifications,
  ) {
    final grouped = <String, List<FetchNotificationsModelDataItem>>{
      'اليوم': [],
      'أمس': [],
      'الأسبوع الماضي': [],
      'الأقدم': [],
    };

    for (final item in notifications) {
      final parsed = DateTime.tryParse(item.createdAt ?? '');
      if (parsed == null) {
        grouped['الأقدم']!.add(item);
      } else {
        grouped[_bucketLabel(parsed)]!.add(item);
      }
    }

    return grouped;
  }

  Future<void> _refreshNotifications(BuildContext context) async {
    profileBloc.add(
      FetchNotificationsEvent(
        params: FetchNotificationsParams(),
        isReload: true,
        markAllReadOnSuccess: true,
      ),
    );
    await profileBloc.stream.firstWhere(
      (state) => state.notificationsStatus != BlocStatus.loading,
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الكل'),
          content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      profileBloc.add(DeleteAllNotificationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      listenWhen: (previous, current) {
        final listFailed =
            previous.notificationsStatus != current.notificationsStatus &&
            current.notificationsStatus == BlocStatus.failed;
        final actionErr =
            (current.notificationActionError ?? '').isNotEmpty &&
            current.notificationActionError != previous.notificationActionError;
        return listFailed || actionErr;
      },
      listener: (context, state) {
        final action = state.notificationActionError;
        if (action != null && action.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(action)));
          return;
        }
        if (state.errorMessage == null || state.errorMessage!.isEmpty) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                bloc: profileBloc,
                buildWhen: (previous, current) =>
                    previous.notifications.isEmpty !=
                    current.notifications.isEmpty,
                builder: (context, state) {
                  return _NotificationsAppBar(
                    showDeleteAll: state.notifications.isNotEmpty,
                    onDeleteAll: () => _confirmDeleteAll(context),
                  );
                },
              ),
              _filterStrip(),
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  bloc: profileBloc,
                  builder: (context, state) {
                    final notifications = state.notifications;
                    final pagination = state.notificationsPagination;
                    final filtered = notifications
                        .where(_matchesFilter)
                        .toList(growable: false);
                    final groups = _groupNotifications(filtered);
                    const sections = [
                      'اليوم',
                      'أمس',
                      'الأسبوع الماضي',
                      'الأقدم',
                    ];
                    if (state.notificationsStatus == BlocStatus.loading &&
                        notifications.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (filtered.isEmpty &&
                        state.notificationsStatus != BlocStatus.loading) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE4E7EC)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              V7ArtTile(
                                asset: V7Artwork.empty,
                                size: 88,
                                radius: 20,
                              ),
                              SizedBox(height: 10),
                              Text(
                                _activeFilter == 'all'
                                    ? 'لا توجد إشعارات حالياً'
                                    : 'لا توجد إشعارات في هذا التصنيف',
                                style: TextStyle(
                                  color: Color(0xFF172033),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'ستظهر هنا تحديثات الطلبات والتنبيهات المهمة.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          await _refreshNotifications(context),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels <
                              notification.metrics.maxScrollExtent - 180) {
                            return false;
                          }
                          if (pagination.isEndPage ||
                              pagination.status == BlocStatus.loading) {
                            return false;
                          }
                          profileBloc.add(
                            FetchNotificationsEvent(
                              params: FetchNotificationsParams(
                                perPage: pagination.perPage,
                              ),
                              loadMore: true,
                            ),
                          );
                          return false;
                        },
                        child: ListView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            8,
                            16,
                            16,
                          ),
                          children: [
                            for (final section in sections)
                              if (groups[section]!.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    2,
                                    10,
                                    2,
                                    8,
                                  ),
                                  child: AppText.labelLarge(
                                    section,
                                    color: const Color(0xff9CA3AF),
                                    fontWeight: FontWeight.w700,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < groups[section]!.length;
                                        i++
                                      ) ...[
                                        Dismissible(
                                          key: ValueKey(
                                            'notification_${section}_${i}_${groups[section]![i].id ?? groups[section]![i].createdAt ?? 'unknown'}',
                                          ),
                                          direction:
                                              DismissDirection.endToStart,
                                          background: Container(
                                            alignment:
                                                AlignmentDirectional.centerEnd,
                                            color: const Color(0xffEF4444),
                                            padding:
                                                const EdgeInsetsDirectional.only(
                                                  end: 20,
                                                ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onDismissed: (_) {
                                            final id = groups[section]![i].id;
                                            if (id != null && id.isNotEmpty) {
                                              profileBloc.add(
                                                DeleteNotificationEvent(id: id),
                                              );
                                            }
                                          },
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                final item =
                                                    groups[section]![i];
                                                final id = item.id;
                                                if (id != null &&
                                                    id.isNotEmpty &&
                                                    item.isRead != true) {
                                                  profileBloc.add(
                                                    MarkNotificationReadEvent(
                                                      id: id,
                                                    ),
                                                  );
                                                }
                                                tryNavigateFromNotificationPayload(
                                                  context,
                                                  module: item.module,
                                                  data: item.data,
                                                );
                                              },
                                              child: NotificationFeedItem(
                                                notification:
                                                    groups[section]![i],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (i != groups[section]!.length - 1)
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Color(0xffF3F4F6),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            if (!pagination.isEndPage &&
                                pagination.status == BlocStatus.loading)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
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

class _NotificationsAppBar extends StatelessWidget {
  final bool showDeleteAll;
  final VoidCallback? onDeleteAll;

  const _NotificationsAppBar({this.showDeleteAll = false, this.onDeleteAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 16, 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE6EAF0))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'الرجوع',
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: SharedPlatformColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'الإشعارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: SharedPlatformColors.primary,
              ),
            ),
          ),
          if (showDeleteAll)
            TextButton.icon(
              onPressed: onDeleteAll,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('حذف الكل'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFBA3E4B),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationsScreenParams {
  final ProfileBloc profileBloc;

  NotificationsScreenParams({required this.profileBloc});
}
