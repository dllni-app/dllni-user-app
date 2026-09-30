# Dllni User App — Cleaning UI/UX Redesign Handoff

## Scope
This design set targets `dllni-user-app` on branch `main` and redesigns the customer cleaning booking journey while preserving the existing backend concepts and lifecycle.

## Booking Journey
1. Cleaning Home / entry
2. Service location + property type
3. Room counts
4. Individual room sizes
5. Cleaning type + add-ons
6. Schedule
7. Worker selection / team configuration
8. Optional manual room assignment
9. Review + pricing
10. Booking success

The visual stepper maps these screens into the 7 decision stages: location, room counts, room sizes, service, schedule, workers, review.

## Key UX Decisions
- Replace the old room type × size counter matrix with progressive disclosure.
- Room Count collects only how many spaces exist.
- Room Sizes materializes those rooms individually and asks Small / Medium / Large.
- Preserve compatibility with the existing `room_size_breakdown` data model internally; do not expose that term in customer-facing UI.
- Move worker assignment after scheduling.
- Default to Dllni selecting/distributing workers automatically.
- Manual room-to-worker assignment is an optional advanced path.
- Keep one primary CTA per screen.
- Arabic RTL is the primary layout direction.

## Flutter Mapping
- Cleaning entry: `lib/features/cl_main/view/screens/cl_main_screen.dart`
- Current property/rooms screen to refactor: `lib/features/cl_main/view/screens/cl_main_home_description_screen.dart`
- Scheduling/worker flow: `lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart`
- Existing worker assignment widgets under `lib/features/cl_main/view/widgets/`
- Orders list/card: `lib/features/orders/view/widgets/cleaning_order_card.dart`
- Order lifecycle/details: `lib/features/orders/view/screens/cleaning_order_details_screen.dart`

## Implementation Principle
Do not rewrite backend contracts to match the UI. Introduce UI state/adapters that convert the progressive room and worker selections into the current request models used by estimate/create APIs.

## Design Files
- Source PEN: `dllni-user-main-booking-redesign.pen`
- Refined source when completed: `dllni-user-main-booking-redesign-v2.pen`
- Full canvas export: `booking-flow.png`
- Refinement preview: `refinement-preview.png`
