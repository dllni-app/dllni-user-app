# Flutter Implementation Plan — User App MAIN Cleaning Redesign

## Goal
Implement the approved PEN booking UX in `dllni-user-app` without changing backend behavior or breaking the existing cleaning API contracts.

## Phase 1 — UI Foundations
- Add reusable booking step header / progress indicator.
- Normalize Arabic RTL spacing, card radius, button height, segmented controls, counters, worker cards, date/time chips, and status badges.
- Keep existing app theme tokens where practical; introduce feature-level tokens only where the current theme cannot express the PEN design cleanly.

## Phase 2 — Split the Current Home Description Screen
Current source: `lib/features/cl_main/view/screens/cl_main_home_description_screen.dart`.

Refactor the current all-in-one screen into progressive presentation steps/state:
1. Service location / property confirmation.
2. Room counts.
3. Room sizes per materialized room unit.
4. Cleaning type.

Important: preserve `CleaningRoomSizeBreakdown` as the internal request model. The new UI should adapt room-unit selections back into the same model before estimation.

## Phase 3 — Add-ons and Schedule
Current source: `lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart` and related widgets.

- Present add-ons as a focused step.
- Present date and time as a focused step.
- Continue to use backend estimate/quote as source of truth.
- Preserve address IDs/coordinates and schedule validation.

## Phase 4 — Worker Selection
Reuse existing BLoC state/events for:
- assignment mode
- previous/preferred workers
- number of workers
- worker room assignments

UX changes:
- automatic team selection is the recommended/default path.
- previous worker selection is a distinct option.
- worker count appears only where open-count/multi-worker is relevant.
- manual room assignment is optional; do not force it during the normal booking path.

## Phase 5 — Review and Confirmation
Add a final review presentation before the existing create-order action.
Show:
- cleaning type
- property/location
- rooms summary
- add-ons
- schedule
- worker mode/count
- backend-provided price breakdown / total

The final CTA invokes the existing create flow. Do not trust locally calculated totals.

## Phase 6 — Booking Success
Use the returned booking number and created order data. Provide clear next actions: follow the order and return home.

## Phase 7 — Existing Order Lifecycle Redesign
After the booking flow is stable, redesign the existing order surfaces without changing lifecycle rules:
- `lib/features/orders/view/widgets/cleaning_order_card.dart`
- `lib/features/orders/view/screens/cleaning_order_details_screen.dart`
- start verification
- worker search / travel / arrival states
- completion confirm/reject/extension
- SOS
- review

## Testing
- Widget tests for each new progressive booking step.
- State preservation when navigating back/forward.
- Adapter tests from room-unit UI state to `CleaningRoomSizeBreakdown`.
- Estimate payload regression tests.
- Preferred worker vs open-count tests.
- Manual room-assignment mapping tests.
- Golden/screenshot tests for RTL overflow on common phone widths.
- Existing cleaning feature tests must remain green.

## Branch Safety
Implementation should be performed from `main` in a new feature branch, then opened as a PR back to the requested integration branch after review. Do not implement from the currently checked-out local `dev` working tree without explicitly switching/using a clean MAIN-based worktree.
