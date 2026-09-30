# Pass 2 — Cleaning Orders & Lifecycle

Extend the current PEN file. Preserve all existing booking, Home, and Occasion frames.

Use the dev code as source of truth, especially:
- lib/features/orders/view/screens/orders_screen.dart
- lib/features/orders/view/widgets/cleaning_order_card.dart
- lib/features/orders/view/screens/cleaning_order_details_screen.dart
- cleaning_order_reschedule_screen.dart
- cleaning_order_problem_report_screen.dart
- cleaning_order_sos_screen.dart
- cleaning_worker_rating_screen.dart
- cleaning_start_verification_dialog.dart
- cleaning_completion_decision_sheet.dart
- cleaning_team_search_banner_widget.dart
- cleaning_worker_tracking_map.dart
- cleaning_preferred_worker_card_widget.dart

Do not design restaurant/supermarket order flows.

Add section 04 Orders & Cleaning Lifecycle with:
1. Orders list — active cleaning orders.
2. Orders list — completed/previous cleaning orders.
3. Orders empty state.
4. Active order details with vertical lifecycle timeline and state-driven primary CTA.
5. Team search / waiting for required workers state.
6. Preferred worker pending/accepted/rejected state where supported.
7. Worker en route / live tracking with map emphasis.
8. Worker arrival + start verification UI.
9. In-progress cleaning state.
10. Reschedule screen.
11. Problem report screen.
12. SOS screen.
13. Completion decision UI: completed / needs more time / problem.
14. Extension request/decision state.
15. Completion success.
16. Worker rating/review screen.

UX requirements:
- Lifecycle timeline is primary information architecture.
- One primary CTA per state.
- Secondary/destructive actions do not visually dominate.
- SOS uses serious but calm hierarchy and confirmation according to current behavior.
- Preserve actual status transitions and available actions from code; do not invent states.
- Arabic RTL, no backend terminology, no clipping.

Export the complete updated canvas.