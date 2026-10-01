# Dllni User App — UI/UX Redesign Handoff

## Scope
This design set is maintained in `dllni-user-app` on branch `dev`. It redesigns the cleaning-focused customer experience plus the general app shell and account surfaces while preserving existing backend contracts and lifecycle behavior.

## PEN Sections
1. **01 Foundations + Cleaning Booking**
   - Cleaning landing
   - Room counts
   - Individual room sizes
   - Cleaning type
   - Add-ons
   - Schedule / address
   - Worker mode / previous workers / worker count
   - Optional manual room assignment
   - Review + pricing
   - Booking success
2. **02 App Shell & Home**
   - Home with active/upcoming cleaning booking
   - First-use / no-upcoming state
   - Bottom navigation: الرئيسية / طلباتي / حسابي
3. **03 Occasion / Event Cleaning**
   - Occasion description
   - Occasion schedule
   - Occasion review/confirmation
4. **04 Orders & Cleaning Lifecycle**
   - Active/history/empty order states
   - Lifecycle detail timeline
   - Team search and preferred-worker states
   - Live tracking / arrival verification / in-progress
   - Reschedule / problem report / SOS
   - Completion / extension / success / rating
5. **05 Worker**
   - Worker profile
   - Reviews
6. **06 Account**
   - Account overview
   - Personal details
   - Saved addresses + add/edit address
   - Notifications
   - Support/help
   - Terms
   - Logout and delete-account confirmations

## Key UX Decisions
- Replace the room-type × size matrix with progressive disclosure.
- Preserve `room_size_breakdown` internally but never expose backend terminology to customers.
- Worker assignment happens late in booking; automatic distribution is the default/recommended path.
- Manual room assignment is optional and mutually exclusive with automatic distribution.
- Order details use lifecycle/timeline hierarchy with a state-driven primary CTA.
- Active/upcoming cleaning work is prioritized on Home over promotional content.
- Account redesign excludes commerce-only destinations from the cleaning-focused design scope.
- Arabic RTL is primary throughout.

## Source Mapping
- App shell/home: `lib/features/main`, `lib/features/home`
- Booking/occasion/worker: `lib/features/cl_main`
- Orders lifecycle: `lib/features/orders`
- Account/address/notifications: `lib/features/profile`
- Terms: `lib/features/main/view/screens/terms_and_conditions_screen.dart`

## Implementation Principle
Do not rewrite backend contracts to fit the new UI. Add presentation state/adapters where needed and map the progressive UX back to current request/use-case models. Pricing and lifecycle status remain backend source-of-truth.

## Final Design Files
- PEN source: `designs/user-app-redesign/dllni-user-redesign-final.pen`
- Full canvas PNG: `designs/user-app-redesign/dllni-user-redesign-final.png`
- QA preview: `designs/user-app-redesign/final-complete-preview.png`
