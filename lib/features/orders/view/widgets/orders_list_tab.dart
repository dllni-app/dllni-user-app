import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/orders_bloc.dart';
import 'orders_app_bar.dart';
import 'orders_cart_orders_segment_bar.dart';
import 'orders_list_body.dart';
import 'orders_screen_segment_section.dart';
import 'orders_shopping_list_tab.dart';

class OrdersListTab extends StatefulWidget {
  const OrdersListTab({
    super.key,
    required this.state,
    this.initialSegmentIndex = OrdersCartOrdersSegmentBar.ordersIndex,
    required this.scrollController,
    required this.onRefresh,
    required this.onRefreshCart,
    required this.onSectionChanged,
  });

  final OrdersState state;
  final int initialSegmentIndex;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRefreshCart;
  final ValueChanged<int> onSectionChanged;

  @override
  State<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<OrdersListTab> {
  static const int _currentCleaningOrdersIndex = 0;
  static const int _previousCleaningOrdersIndex = 1;
  static const Duration _cleaningPollInterval = Duration(seconds: 10);

  late int segmentIndex;
  int cleaningOrdersTabIndex = _currentCleaningOrdersIndex;
  Timer? _cleaningPollTimer;

  @override
  void initState() {
    super.initState();
    segmentIndex = widget.initialSegmentIndex;
    if (segmentIndex == OrdersCartOrdersSegmentBar.cartIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OrdersBloc>().add(FetchCartForActiveSectionEvent());
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncCleaningPollTimer();
    });
  }

  @override
  void didUpdateWidget(covariant OrdersListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedTabIndex != widget.state.selectedTabIndex &&
        segmentIndex == OrdersCartOrdersSegmentBar.cartIndex) {
      context.read<OrdersBloc>().add(FetchCartForActiveSectionEvent());
    }
    if (oldWidget.state.selectedTabIndex != widget.state.selectedTabIndex) {
      _syncCleaningPollTimer();
    }
  }

  @override
  void dispose() {
    _cleaningPollTimer?.cancel();
    super.dispose();
  }

  void _syncCleaningPollTimer() {
    final isCleaningSection = widget.state.selectedTabIndex == 2;
    if (isCleaningSection) {
      _cleaningPollTimer ??= Timer.periodic(_cleaningPollInterval, (_) {
        if (!mounted) return;
        if (widget.state.selectedTabIndex != 2) return;
        context.read<OrdersBloc>().add(
          FetchOrdersEvent(isReload: true, silentRefresh: true),
        );
      });
      return;
    }
    _cleaningPollTimer?.cancel();
    _cleaningPollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final isCleaningSection = widget.state.selectedTabIndex == 2;
    final effectiveSegmentIndex = isCleaningSection
        ? OrdersCartOrdersSegmentBar.ordersIndex
        : segmentIndex;
    return Column(
      children: [
        OrdersAppBar(
          selectedIndex: widget.state.selectedTabIndex,
          onChanged: widget.onSectionChanged,
        ),
        if (!isCleaningSection) ...[
          const SizedBox(height: 14),
          OrdersScreenSegmentSection(
            selectedIndex: segmentIndex,
            onChanged: (index) {
              setState(() => segmentIndex = index);
              if (index == OrdersCartOrdersSegmentBar.cartIndex) {
                context.read<OrdersBloc>().add(
                  FetchCartForActiveSectionEvent(),
                );
              }
            },
          ),
        ] else ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: _CleaningOrdersTabBar(
              selectedIndex: cleaningOrdersTabIndex,
              onChanged: (index) {
                setState(() => cleaningOrdersTabIndex = index);
              },
            ),
          ),
          const SizedBox(height: 14),
        ],
        Expanded(
          child: IndexedStack(
            index: effectiveSegmentIndex,
            sizing: StackFit.expand,
            children: [
              OrdersShoppingListTab(
                state: widget.state,
                onRefresh: widget.onRefreshCart,
              ),
              RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: OrdersListBody(
                  state: widget.state,
                  scrollController: widget.scrollController,
                  showCompletedCleaningOrders:
                      cleaningOrdersTabIndex == _previousCleaningOrdersIndex,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CleaningOrdersTabBar extends StatelessWidget {
  const _CleaningOrdersTabBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _titles = <String>['الطلبات الحالية', 'الطلبات السابقة'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_titles.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: AppText.labelLarge(
                  _titles[index],
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xff1E2A78)
                      : const Color(0xff6B7280),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
