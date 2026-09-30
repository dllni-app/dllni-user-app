# Dllni User App — Remaining UI/UX Design Pass (DEV)

Extend the existing PEN design. Do NOT rebuild or remove the already approved cleaning booking frames.
Use the Flutter repository passed via --repo as the behavioral source of truth for the remaining cleaning/general-user screens.
The repository is on branch `dev`, and the design file must remain inside the same repository.

## Scope boundary
Design ONLY:
- App shell / main home relevant to the cleaning-focused product surface
- Cleaning occasion/event flow
- Cleaning orders list and full cleaning order lifecycle
- Worker profile / reviews used by cleaning
- General user account surfaces: profile, personal details, saved addresses, add/edit address, notifications, support/terms/account actions

Explicitly DO NOT design restaurant, supermarket, merchant carts, shopping lists, group orders, voting, lucky box, or other commerce-specific flows even if they exist on dev.

## Existing design to preserve
Keep the current Arabic RTL visual language and approved progressive booking flow:
- room count separate from room size
- regular vs deep cleaning
- add-ons
- schedule
- worker selection
- optional manual room assignment
- review + confirm
- booking success
Do not reintroduce technical/backend terms in customer-facing copy.

## Required new screen group A — App Shell / Home
Add screens/components for:
1. Main Home — cleaning-focused landing with greeting, notification entry, current/default address summary, strong cleaning CTA, service discovery, and active/upcoming booking card when present.
2. Main Home — no upcoming booking / first-use state.
3. Bottom navigation concept: الرئيسية / طلباتي / حسابي.

Home should feel useful before any banner content. Prioritize active booking and booking CTA over marketing content.

## Required new screen group B — Occasion / Event Cleaning
Use the actual `cl_main_occasion_description_screen.dart` and `cl_main_occasion_schedule_screen.dart` behavior as source.
Add an occasion/event cleaning flow that matches supported fields and does not invent unsupported backend behavior.
At minimum design:
4. Occasion description / event details.
5. Occasion schedule/date configuration.
6. Occasion review/confirmation state if supported by the current flow, otherwise reuse the normal review pattern with occasion-specific summary.

## Required new screen group C — Orders & Lifecycle
Use `orders_screen.dart`, `cleaning_order_card.dart`, `cleaning_order_details_screen.dart`, and related cleaning widgets/screens as source of truth.
Design:
7. Orders list — active cleaning orders.
8. Orders list — completed/previous cleaning orders.
9. Orders empty state.
10. Active cleaning order details with a clear lifecycle timeline and contextual primary CTA.
11. Team search / waiting for required workers state for open-count bookings.
12. Preferred worker pending/accepted/rejected decision state where supported.
13. Worker en route / live tracking state with map emphasis.
14. Worker arrival + start verification UI (prefer a focused bottom sheet/dialog design consistent with existing behavior).
15. In-progress cleaning state with worker/team summary and service details.
16. Reschedule screen.
17. Problem report screen.
18. SOS screen — serious but calm visual hierarchy, explicit confirmation before destructive/emergency action where current behavior supports it.
19. Completion decision sheet/state: completed / needs more time / problem.
20. Extension request/decision state.
21. Completion success state.
22. Worker rating/review screen.

The order detail should use a vertical timeline instead of presenting all lifecycle data as equally weighted cards. The primary CTA changes with state. Secondary/destructive actions should not visually dominate.

## Required new screen group D — Worker
Use `cl_worker_profile_detail_screen.dart`, `cl_worker_reviews_all_screen.dart`, and existing worker widgets as source.
Design:
23. Worker profile detail.
24. Worker reviews list.
Worker information should emphasize name, verified/trusted signals only if actually supported, rating, previous work relation where supported, and clear selection/contact actions allowed by current behavior.

## Required new screen group E — Account
Use the actual profile/address/notification screens as source. Exclude commerce-only profile destinations.
Design:
25. Profile / account overview.
26. Personal details.
27. Saved addresses list.
28. Add/edit address.
29. Notifications feed with Today / Yesterday / Last week / Older grouping, unread treatment, swipe/delete affordance, delete-all action.
30. Support / help entry state using the current supported contact mechanism.
31. Terms & conditions view concept.
32. Delete account confirmation modal/state.
33. Logout confirmation modal/state.

## States / design quality
For the new screens, include reusable states or small component examples for loading, empty, error, disabled, selected, and destructive confirmation where useful. Avoid creating a full separate mobile frame for every trivial state unless it materially changes the UX.

## Visual system
Continue the existing brand language in the current PEN file:
- Arabic RTL first
- deep navy + teal/cyan brand accents
- restrained neutral surfaces
- 8pt spacing rhythm
- 12–16 px card radius
- 44–48 px minimum touch targets
- one obvious primary CTA per screen
- sticky bottom action where appropriate
- status must not rely on color alone
- concise natural Arabic copy
- avoid excessive nested cards and borders

## Canvas organization
Do not mix these screens randomly with the booking flow. Create clearly labeled canvas sections after the existing booking flow:
- 02 App Shell & Home
- 03 Occasion Flow
- 04 Orders Lifecycle
- 05 Worker
- 06 Account
Keep frames compact and readable, with English frame names for handoff while UI copy stays Arabic.

Export the complete updated canvas for visual QA after finishing.