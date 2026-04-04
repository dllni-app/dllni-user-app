import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/fetch_notifications_model.dart';
import '../../domain/usecases/fetch_notifications_use_case.dart';
import '../manager/bloc/rs_profile_bloc.dart';
import '../widgets/notification_feed_item.dart';

@AutoRoutePage()
class RsNotificationsScreen extends StatefulWidget {
  const RsNotificationsScreen({super.key});

  @override
  State<RsNotificationsScreen> createState() => _RsNotificationsScreenState();
}

class _RsNotificationsScreenState extends State<RsNotificationsScreen> {
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
      if (parsed == null) continue;
      grouped[_bucketLabel(parsed)]!.add(item);
    }

    return grouped;
  }

  void _markAllRead() =>
      context.read<RsProfileBloc>().add(MarkAllNotificationsReadEvent());

  Future<void> _refreshNotifications() async {
    final bloc = context.read<RsProfileBloc>();
    bloc.add(FetchNotificationsEvent(params: FetchNotificationsParams()));
    await bloc.stream.firstWhere(
      (state) => state.notificationsStatus != BlocStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsProfileBloc>(
      lazy: false,
      create: (_) => getIt<RsProfileBloc>()
        ..add(FetchNotificationsEvent(params: FetchNotificationsParams())),
      child: BlocListener<RsProfileBloc, RsProfileState>(
        listenWhen: (previous, current) =>
            previous.notificationsStatus != current.notificationsStatus &&
            current.notificationsStatus == BlocStatus.failed,
        listener: (context, state) {
          if (state.errorMessage == null || state.errorMessage!.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                _RsNotificationsAppBar(onReadAll: _markAllRead),
                Expanded(
                  child: BlocBuilder<RsProfileBloc, RsProfileState>(
                    builder: (context, state) {
                      final groups = _groupNotifications(state.notifications);
                      const sections = ['اليوم', 'أمس', 'الأسبوع الماضي', 'الأقدم'];
                      if (state.notificationsStatus == null ||
                          state.notificationsStatus == BlocStatus.loading ||
                          state.notificationsStatus == BlocStatus.init) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.notifications.isEmpty) {
                        return const Center(child: Text('لا توجد إشعارات'));
                      }
                      return RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        child: ListView(
                          padding: const EdgeInsetsDirectional.only(
                            top: 8,
                            bottom: 16,
                          ),
                          children: [
                            for (final section in sections)
                              if (groups[section]!.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    16,
                                    10,
                                    16,
                                    8,
                                  ),
                                  child: AppText.labelLarge(
                                    section,
                                    color: const Color(0xff9CA3AF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  color: context.onPrimary,
                                  child: Column(
                                    children: [
                                      for (
                                        var i = 0;
                                        i < groups[section]!.length;
                                        i++
                                      ) ...[
                                        NotificationFeedItem(
                                          notification: groups[section]![i],
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
                          ],
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

class _RsNotificationsAppBar extends StatelessWidget {
  const _RsNotificationsAppBar({required this.onReadAll});

  final VoidCallback onReadAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: context.width,
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(
          bottom: BorderSide(color: context.primaryContainer, width: 2),
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppText.headlineMedium(
            'الإشعارات',
            color: context.primary,
            fontWeight: FontWeight.w700,
          ),
          PositionedDirectional(
            start: 12,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),
                child: Icon(Icons.arrow_back, color: context.primary),
              ),
            ),
          ),
          PositionedDirectional(
            end: 12,
            child: ElevatedButton(
              onPressed: onReadAll,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xff6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
              ),
              child: AppText.labelLarge(
                'قراءة الكل',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
