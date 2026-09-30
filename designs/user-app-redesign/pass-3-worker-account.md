# Pass 3 — Cleaning Worker + User Account

Extend the current PEN file. Preserve booking, Home, Occasion, and Orders sections.

Use the dev code as source of truth.

## 05 Worker
Use:
- lib/features/cl_main/view/screens/cl_worker_profile_detail_screen.dart
- lib/features/cl_main/view/screens/cl_worker_reviews_all_screen.dart
and related cleaning worker widgets.

Design:
1. Worker profile detail.
2. Worker reviews list.

Show only supported trust/rating/profile signals and supported user actions.

## 06 Account
Use:
- lib/features/profile/view/screens/profile_screen.dart
- personal_details_screen.dart
- my_addresses_screen.dart
- add_address_screen.dart
- notifications_screen.dart
- lib/features/main/view/screens/terms_and_conditions_screen.dart
and the current support/contact behavior.

Exclude commerce-only destinations such as shopping lists, group orders, voting, lucky box, restaurant/supermarket-specific items.

Design:
3. Profile/account overview focused on general account + cleaning-relevant destinations.
4. Personal details.
5. Saved addresses list.
6. Add/edit address.
7. Notifications feed grouped by اليوم / أمس / الأسبوع الماضي / الأقدم, with unread treatment, delete-one gesture, and delete-all action.
8. Support/help entry using the current supported contact mechanism.
9. Terms & conditions.
10. Delete-account confirmation modal/state.
11. Logout confirmation modal/state.

Include compact component/state examples for loading, empty, error, disabled, selected, and destructive confirmation where useful rather than full duplicate frames.

Continue the existing Arabic RTL system, one clear primary CTA, clean hierarchy, no technical terms, and no clipping.
Export the complete updated canvas.