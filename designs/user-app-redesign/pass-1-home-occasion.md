# Pass 1 — App Shell, Home, Occasion Flow

Extend the existing PEN design without rebuilding or changing the approved cleaning booking flow.

Repository source: current dev branch. Keep scope cleaning-focused. Ignore restaurant, supermarket, carts, shopping lists, group orders, voting, lucky box, and merchant-only modules.

## 02 App Shell & Home
Design:
1. Main Home with greeting, notification entry, default/current address summary, prominent cleaning booking CTA, service discovery, and an upcoming/active cleaning booking card.
2. Main Home first-use/no-upcoming-booking state.
3. Bottom navigation concept with الرئيسية / طلباتي / حسابي.

Prioritize the active booking and booking CTA over banners/marketing.

## 03 Occasion / Event Cleaning
Use the actual dev implementation of:
- lib/features/cl_main/view/screens/cl_main_occasion_description_screen.dart
- lib/features/cl_main/view/screens/cl_main_occasion_schedule_screen.dart
and their related models/widgets.

Design:
4. Occasion description / event details.
5. Occasion schedule/date configuration.
6. Occasion review/confirmation summary if supported; otherwise reuse the existing booking review structure with occasion-specific content.

Do not invent unsupported fields or backend behavior.

## Quality
Continue the existing Arabic RTL visual system: navy + teal, restrained neutral surfaces, 8pt spacing, 12–16 radius, 44–48px targets, one primary CTA, concise Arabic, no developer/backend terms, no clipped text.

Keep English frame names for handoff and Arabic UI copy.
Export the complete updated canvas when done.