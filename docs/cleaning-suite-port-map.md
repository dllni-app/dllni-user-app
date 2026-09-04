# Cleaning Suite Port Map

Updated: 2026-09-05

## Porting rule

Cleaning Suite Flutter work is ported feature-by-feature. The `feature/cleaning-suite-main` and `feature/cleaning-suite-dev` branches are intentionally divergent, so no blind branch merge is used for parity work.

Temporary implementation workflows may be used only to apply and verify a bounded change. They must be removed after the change is committed. Permanent Cleaning Suite CI is check-only and uses read-only repository permissions.

## User App

Repository: `dllni-app/dllni-user-app`

Recorded baseline heads before this port-map was introduced:

- `feature/cleaning-suite-main`: `e85f89c1b789e87f45a3010ab8204661ea1a601e`
- `feature/cleaning-suite-dev`: `dce77f4d0641bf5522b1751ba7c86bc2f726e3c1`

### Recurring Cleaning creation slice

Implemented on both feature branches:

- Custom recurring dates.
- Daily recurrence generation.
- Weekly recurrence generation.
- Monthly recurrence generation with calendar-safe end-of-month clamping.
- Maximum 30-day recurring window.
- No silent truncation when a generated series would exceed the 30-day window.
- Canonical request contract remains `schedule.mode=recurring` with explicit `sessions[]`.
- Create and estimate serialization include recurring sessions.
- Recurring schedule creation controls are integrated into the normal Cleaning schedule screen.

Verification:

- Main recurring pattern integration commit: `4e2baa67d27992a58e2e432841716ef4d878117d`.
- Main permanent recurring CI: run `33926931340`, green.
- Dev selective recurring creation port commit: `aa320b68ca7e32f2deb128185fad0ae2492b4ee2`.
- Dev permanent recurring CI: run `33927679331`, green.

Status: recurring creation slice parity verified. This does not declare whole-branch parity.

### Recurring Cleaning per-visit management slice

Implemented on both feature branches:

- Recurring bookings expose the shared multi-session details flow from ordinary Cleaning order details.
- Customer worker replacement remains scoped to the selected future recurring visit.
- Customer can skip one eligible future recurring visit without cancelling the series.
- Skip eligibility is server-authoritative through `canSkip`; past visits, non-recurring sessions and visits whose worker started travel cannot be skipped.
- Skipped visits are terminal in Flutter presentation, display their skip reason and are excluded from fallback remaining-hours calculations.
- Skip is presented separately from cancellation because the backend applies no cancellation penalty and recalculates parent totals for the remaining chargeable visits.

Verification:

- Backend skip capability commit: `90c352529e58b87239f7d4d8dfd01335ff109944`.
- Backend permanent recurring CI after presenter coverage: run `33928467491`, green.
- User main skip UI commit: `32a648bc4f2f93aaac04374a238d1b0ddf0f5fbe`.
- User main permanent recurring CI: run `33928728561`, green.
- User dev selective recurring details/skip port commit: `e5c2c1694c1b7f31c6d60a4abe73b9234f58ae13`.
- User dev permanent recurring CI: run `33928839899`, green.

Status: recurring per-visit details, worker-change and skip parity verified for this slice. This does not declare whole-branch parity.

### Multi-Day Event Assistance

The Multi-Day customer flow was previously promoted to both feature branches. Broader whole-branch parity is intentionally not inferred from this port map.

## Worker App

Repository: `dllni-app/dllni_cleaning_owner_app`

Recorded heads before this port-map commit:

- `feature/cleaning-suite-main`: `b7be82698f24cbe1e9ad81c1486987d300fbe9ee`
- `feature/cleaning-suite-dev`: `6b355e407320d8694fda15382cb14d211f210649`

### Recurring / generic multi-session execution slice

Implemented on both feature branches:

- Worker schedule loading is generic for Cleaning bookings with child sessions and is no longer restricted to `event_assistance`.
- Existing accept-all and accept-selected APIs are reused for recurring execution sessions.
- Realtime, fallback and BLoC refresh paths reload the multi-session schedule generically.
- Existing session lifecycle is reused for travel, arrival, OTP verification, work start, completion, cancellation and SOS.

Verification:

- Dev selective recurring multi-session details port commit: `ec171f14f78e735da478078ec437c53930b5cc0f`.
- Dev permanent Cleaning Suite CI: run `33927487014`, green.
- Main permanent Cleaning Suite CI was green after the generic multi-session implementation.

Status: recurring worker multi-session details/lifecycle parity verified for this slice. This does not declare whole-branch parity.

## Backend

Repository: `dllni-app/dllni_backend`

Branch: `feature/cleaning-suite-main` only.

Verified recurring backend capabilities include:

- Parent booking plus `recurring_cleaning` child-session materialization.
- Per-session pricing snapshots and shared coverage/lifecycle infrastructure.
- Customer worker-change continuity for selected recurring visits.
- Maximum 30-day recurring window enforced server-side.
- Preferred-worker recurring bookings do not silently fall back to the open worker pool.
- Ordinary non-recurring preferred-worker fallback remains available.
- Customer can skip one recurring visit without cancelling the remaining series; skipped visits are excluded from chargeable parent totals and do not receive a cancellation penalty.
- Skip eligibility is returned by the schedule presenter and enforced again by the mutation service.

Latest verified backend recurring CI: run `33928467491`, green.

## Remaining Recurring Cleaning work

The following items are not marked complete by this map:

- Pause/resume series.
- Edit future recurrence with repricing and reconfirmation.
- Task-based versus hour-based recurring modes.
- Full worker-scope UX for specific worker(s) versus any worker.
- Notification delivery/view state and aggregated coverage notifications.
- Per-session payment, review and dispute completion.
- Late/no-travel options and admin reporting.

## Other Cleaning Suite work still open

- Remaining Multi-Day Event Assistance dynamic/admin/travel items.
- Open-Time Worker Requests.
- Initial Cleaning Materials.
- Special Services.
- Cross-feature integration and final regression/parity audit.

Legacy `multiday` and `multiday-dev` branches remain retained until the final port/diff audit is complete.
