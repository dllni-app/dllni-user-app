# Flutter Implementation Plan — User App DEV UI/UX Redesign

## Goal
Implement the approved PEN redesign in `dllni-user-app` on the existing `dev` branch, while preserving current backend contracts, pricing behavior, and cleaning-order lifecycle rules.

## Phase 1 — Shared UI Foundations
- Introduce reusable RTL components matching the PEN design: step/progress header, buttons, segmented controls, counters, cards, status badges, date/time chips, confirmation sheets, and empty states.
- Reuse current application theme tokens where possible and keep the deep-navy + teal/cyan visual language.
- Keep touch targets at least 44–48px and add safe-area handling for sticky CTAs.

## Phase 2 — Cleaning Home + Booking Flow
Primary sources:
- `lib/features/cl_main/view/screens/cl_main_screen.dart`
- `lib/features/cl_main/view/screens/cl_main_home_description_screen.dart`
- `lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart`

Refactor the existing dense flow into progressive presentation steps:
1. Cleaning entry/property context.
2. Room counts.
3. Individual room sizes.
4. Cleaning type.
5. Add-ons.
6. Schedule/address.
7. Worker selection.
8. Optional manual room assignment.
9. Review and confirmation.
10. Booking success.

Preserve `CleaningRoomSizeBreakdown` / `room_size_breakdown` internally. The new room-unit UI must adapt back into the current estimate/create request models.

## Phase 3 — Occasion / Event Cleaning
Primary sources:
- `cl_main_occasion_description_screen.dart`
- `cl_main_occasion_schedule_screen.dart`

Apply the same visual system and progressive hierarchy while preserving only fields and behavior supported by the current dev implementation.

## Phase 4 — App Shell + Home
Primary sources:
- `lib/features/main`
- `lib/features/home`

Implement:
- Cleaning-focused main Home.
- Active/upcoming booking card.
- First-use/no-upcoming state.
- Three-item navigation: الرئيسية / طلباتي / حسابي.
- Notifications entry and supported address summary.

Keep commerce-specific destinations outside this redesign scope.

## Phase 5 — Orders & Cleaning Lifecycle
Primary sources:
- `lib/features/orders/view/screens/orders_screen.dart`
- `lib/features/orders/view/widgets/cleaning_order_card.dart`
- `lib/features/orders/view/screens/cleaning_order_details_screen.dart`
- related cleaning reschedule/problem/SOS/verification/completion/rating widgets and screens.

Implement:
- Active/history/empty lists.
- Timeline-driven order details.
- Team search and preferred-worker states.
- Live tracking and arrival verification.
- In-progress state.
- Reschedule and problem reporting.
- Emergency-help flow.
- Completion / extension / success.
- Rating/review.

Do not alter valid lifecycle transitions; CTA availability remains derived from current state/backend behavior.

## Phase 6 — Worker Surfaces
Implement the redesigned cleaning worker profile and reviews using existing worker data and actions only. Do not invent trust/verification attributes that the API does not expose.

## Phase 7 — Account
Primary source: `lib/features/profile` plus the current terms screen.

Implement:
- Account overview.
- Personal details.
- Saved addresses.
- Add/edit address.
- Notifications.
- Support/help.
- Terms.
- Logout confirmation.
- Delete-account confirmation.

For this cleaning-focused redesign, do not surface restaurant/supermarket/shopping-list/group-order/lucky-box/voting destinations.

## Backend & Data Rules
- Backend remains source of truth for estimates, totals, lifecycle, worker availability, and booking state.
- Do not calculate authoritative pricing locally.
- Preserve address IDs/coordinates and validation.
- Preserve previous/preferred-worker and open-count semantics.
- Keep automatic distribution and manual room assignment mutually exclusive in UI state.

## Testing
- Widget tests for every progressive booking step.
- Back/forward state-preservation tests.
- Room-unit -> `CleaningRoomSizeBreakdown` adapter tests.
- Estimate/create payload regression tests.
- Preferred-worker and open-count tests.
- Manual room-assignment mapping tests.
- Order lifecycle CTA/state tests.
- RTL golden/screenshot tests at common phone widths.
- Accessibility/touch-target checks.
- Existing cleaning tests must remain green.

## Branch Workflow
Work directly in the existing `dev` branch on this machine. Do not create a separate worktree unless explicitly requested later. Keep design and implementation changes scoped to `dllni-user-app`, run the relevant Flutter tests/analyzer before committing, and do not modify backend contracts as part of the UI implementation.
