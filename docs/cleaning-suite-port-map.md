# Cleaning Suite Port Map

Updated: 2026-09-06

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

### Recurring Cleaning pause/resume slice

Implemented end-to-end and ported selectively to both User App feature branches:

- Pause/resume is a series-level action, separate from per-visit skip and cancellation.
- Backend stores `recurring_paused_at` and `recurring_pause_reason` on the parent booking and uses reversible session status `paused` for eligible future recurring visits.
- Pausing releases active future session assignments before travel/work starts, which also releases the worker schedule and financial reservation capacity represented by those active assignments.
- Paused visits remain part of the recurring contract and are not treated as terminal or removed from customer fallback totals merely because the series is paused.
- Worker acceptance is blocked while a visit is paused.
- Resuming returns future paused visits to `scheduled/searching` so they can be accepted again.
- A visit whose scheduled time passed while the series was paused becomes `skipped` on resume without a cancellation penalty; parent financial totals are recalculated through the shared session financial aggregation service.
- Schedule payload is server-authoritative through `isRecurring`, `isPaused`, `canPause`, `canResume`, `pausedAt` and `pauseReason`.
- User App calls dedicated `/recurring/pause` and `/recurring/resume` endpoints and presents one series-management card above the individual visits.
- The Flutter model treats `paused` as non-terminal and relies on server capabilities rather than guessing whether pause/resume is allowed.

Verification:

- Backend pause/resume implementation commit: `d5bfe5841ccc0ebda10c56be5435eeee9af9c944`.
- Backend permanent recurring CI after staging cleanup: run `33930541324`, green.
- User main pause/resume UI commit: `9a5e206b2690107f3a36ae6e0b303e3a71e74c89`.
- User main permanent recurring CI after staging cleanup: run `33930730121`, green.
- User dev selective four-file pause/resume port commit: `bf9becde21a4518cb563c655a8d0be964a7a9c8b`.
- User dev permanent recurring CI: run `33930783514`, green.
- User dev general Cleaning Suite CI for the same port: run `33930783459`, green.

Status: recurring pause/resume parity verified for this slice. This does not declare whole-branch parity.

### Recurring Cleaning future schedule revision slice

Implemented end-to-end and ported selectively to both User App feature branches:

- Customer edits only the eligible future recurring visits; completed, skipped, cancelled and already-started history is preserved.
- Revision uses a server-authoritative two-step contract: preview first, then confirm with the returned `revisionToken`.
- Preview recalculates the canonical per-visit pricing and returns the current total, proposed total, price delta, discount, editable/preserved/proposed visit counts and whether reconfirmation is required without mutating the booking.
- Confirm recalculates the proposal again while locking the booking/session state and rejects a stale token if session state, versions, schedule or price changed since preview.
- Replaced future visits are retained as terminal `superseded` audit rows; they are hidden from the active schedule payload and excluded from parent financial aggregation.
- Active assignments on replaced future visits are released before the replacement visits are created, and affected workers receive a booking-updated notification.
- New visits receive fresh pricing snapshots including the revision token and pricing algorithm version.
- Existing parent discount is preserved when session financial totals are re-aggregated.
- The recurring 30-day window and duplicate/future-slot validation remain server-authoritative for revisions.
- A paused recurring series cannot be revised; the User App also hides the revision action while paused.
- User App shows the recalculated old/new totals and price delta before the customer confirms the exact revision token.

Verification:

- Backend revision implementation commit: `bb15a2fe0992646a6fa8f220620930fe2be05a19`.
- Backend final permanent recurring CI after staging cleanup/coverage update: run `33931319421`, green.
- User main revision UI/model/datasource commit: `9e49c6d7fec6cf46a369a59938a52e6a3f958bb8`.
- User main permanent recurring CI after staging cleanup/coverage update: run `33931541590`, green.
- User dev selective revision port commit: `bd20439fe79a729897ef3bb502d8d8f1f33171fe`.
- User dev permanent recurring CI: run `33931611667`, green.
- User dev general Cleaning Suite CI for the same port: run `33931611665`, green.

Status: recurring future schedule revision, repricing and reconfirmation parity verified for this slice. This does not declare whole-branch parity.

### Recurring Cleaning task/hour calculation-mode slice

Implemented end-to-end and ported selectively to both User App feature branches:

- Canonical recurring schedule contract supports `schedule.calculationMode=task|hours`; older clients that omit the field remain on `task` mode.
- `task` mode keeps the existing room/task estimation flow.
- `hours` mode requires `hoursPerVisit` between 1 and 24 hours and normalizes to half-hour increments.
- Hour-mode pricing remains server-authoritative: configured recurring hourly pricing is applied per requested worker seat and visit duration, then the existing commission/travel pricing engine is reused.
- Child sessions retain their calculation mode, duration and pricing snapshots so worker capacity and later lifecycle logic use the same visit duration that was priced.
- Future recurring schedule revision preserves the calculation mode and uses canonical repricing before reconfirmation.
- User App exposes an explicit `حسب المهام / حسب الساعات` selector; hour mode changes visit duration in 0.5-hour increments.
- Create and estimate share the same recurring serialization source of truth, and the client displays the server estimate rather than calculating an hourly price locally.

Verification:

- Backend task/hour implementation commit: `3b9687fc37dc0994b472e8bc274247e204ed1377`.
- Backend final permanent recurring CI after staging cleanup/coverage update: run `33932500507`, green.
- User main task/hour UI and serialization commit: `a8dea1a018664a3795d08aaf7357641c839a0018`.
- User main final permanent recurring CI: run `33932758826`, green.
- User dev selective eight-file task/hour port commit: `a5e25ddba991a8b203f19693c06c8d33d3354fba`.
- User dev permanent recurring CI: run `34027040732`, green.
- User dev general Cleaning Suite CI for the same port: run `34027040749`, green.

Status: recurring task/hour calculation-mode parity verified for this slice. This does not declare whole-branch parity.

### Recurring Cleaning worker-scope slice

Implemented end-to-end and ported selectively to both User App feature branches:

- Recurring bookings expose an explicit `workerScope=any|specific` contract shared by create and estimate.
- `any` clears preferred-worker IDs and keeps the recurring visit in the eligible open worker pool with the requested worker-seat count.
- `specific` requires at least one selected worker and persists the exact selected worker IDs; the requested worker count is locked to that selected set.
- Multiple selected workers remain a specific closed scope even though the existing multi-seat assignment mode is reused internally; they are not silently reinterpreted as open-pool seats.
- Backend validation rejects `workerScope` outside recurring Cleaning bookings and rejects `specific` without selected worker IDs.
- Worker listing, dispatch and acceptance all enforce the same persisted recurring worker scope so non-selected workers cannot see, receive or accept a specific recurring visit.
- Future recurring schedule revision preserves the parent worker scope instead of reopening specific bookings.
- User App shows `أي عامل متاح` versus `عمال محددون فقط`; previous-worker selection is shown only when the recurring scope is specific.
- Switching to `any` clears selected worker IDs from the outgoing recurring request and triggers a fresh server estimate.
- Create and estimate use the same worker-selection resolver, so pricing/availability previews and final creation cannot drift on worker count or selected IDs.

Verification:

- Backend worker-scope implementation commit: `d0982709c1220bcc31dbb1288dc6f7a39ecd966e`.
- Backend final permanent recurring CI after staging cleanup: run `34029198646`, green.
- User main worker-scope UI/serialization commit: `34fdfff8b2d02c51523abd0095337914dbc114a4`.
- User main final permanent recurring CI: run `34029844064`, green.
- User dev selective worker-scope port commit: `466a1f2d9208e46546265d160dc519aa00787bad`.
- User dev permanent recurring CI: run `34030086485`, green.
- User dev general Cleaning Suite CI for the same port: run `34030086494`, green.

Status: recurring worker-scope parity verified for this slice. This does not declare whole-branch parity.

### Recurring Cleaning notification interaction/coverage slice

Implemented end-to-end without requiring a Flutter production-code fork because both User and Worker apps already consume the shared notification feed and mark notifications through the existing `/read` contract:

- Notification feed responses now expose explicit `deliveredAt` and `viewedAt` interaction state while retaining `readAt` for backward compatibility.
- Loading the authenticated notification feed records delivery for entries that have not yet been marked delivered.
- Marking one notification read records it as viewed and keeps `readAt` compatible with existing clients.
- Recurring worker-seat coverage changes are summarized at the parent-series level instead of emitting one customer coverage notification per visit.
- Aggregate coverage payload reports fully covered, partially covered and searching visit counts plus accepted/required/remaining worker seats.
- Coverage notifications are deduplicated by a deterministic series snapshot fingerprint, so refreshing the same coverage state does not create duplicate feed entries.
- A distinct completion notification is emitted when all active future recurring seats are covered.
- Existing generic notification title/body/deep-link handling in Flutter is reused; no recurring-specific notification screen is required.

Verification:

- Backend notification interaction/aggregate coverage feature commit: `9275843478517c097c64bff24d4029fa8670de7a`.
- Backend formatting normalization commit: `b99d87b4ddf2ba5c763a5da6ab6e50e1280b2528`.
- Backend general Cleaning Suite CI: run `34031631801`, green.
- Backend permanent recurring CI including migration, formatting, notification-state tests, aggregate-coverage tests and recurring regressions: run `34031824387`, green.

Status: recurring notification delivery/view state and aggregate coverage slice verified. Existing Flutter notification contracts remain compatible on both feature branches.

### Recurring Cleaning per-session settlement / review / dispute slice

Implemented end-to-end and ported selectively to both User App feature branches:

- Each child visit owns independent settlement/payment-readiness state; service completion does not claim that customer payment was captured.
- Admin commission settlement is idempotent per session and worker, so recurring visits for the same worker settle independently.
- Parent booking completion skips booking-level commission charging when child sessions exist, preventing a second charge after the final visit; legacy single-day bookings retain their existing booking-level path.
- Customer reviews are independent per completed session and worker, so the same worker can receive a separate review for separate visits.
- Only one active dispute can exist for a session at a time; the session payload exposes the active dispute state and identifier.
- User App recurring visit cards expose settlement state, per-visit review, and per-visit dispute actions using server-authoritative capabilities.
- Event Assistance keeps its existing whole-event multi-worker review flow; recurring visits do not reuse that aggregate review UI.

Verification:

- Backend per-session interaction implementation commit: `11e8934715f8e708d254e38ce433e5b420089fb2`.
- Backend permanent recurring CI: run `34033021594`, green.
- User main per-session interaction UI commit: `d60df5f7c83b73f3e2fcd6b70cabb0c8589f3a92`.
- User main final permanent recurring CI: run `34034325685`, green.
- User dev selective per-session interaction port commit: `9f144583eb43ea07bd06c6b0c9e4199b19d451ac`.
- User dev permanent recurring CI: run `34034276119`, green.
- User dev general Cleaning Suite CI for the same port: run `34034276149`, green.

Status: recurring per-session settlement/payment-readiness, review and dispute parity verified for this slice. This does not declare whole-branch parity.

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
- Customer can pause and resume a recurring series using reversible future-session state while releasing active worker assignments and their associated schedule/financial capacity.
- Visits that expire during a pause become penalty-free skipped visits on resume and parent totals are recalculated through shared session financial aggregation.
- Pause/resume capabilities and state are returned by the schedule presenter and enforced again by the mutation service.
- Customer can preview and confirm replacement of eligible future recurring visits with canonical repricing and stale-token protection.
- Confirmed revisions preserve historical visits, retain superseded future rows for audit, release affected active assignments, preserve discounts and create fresh session pricing snapshots.
- Recurring bookings support explicit task-based and hour-based calculation modes, with legacy task-mode compatibility, half-hour visit normalization and server-authoritative hour pricing/capacity snapshots.
- Recurring bookings support explicit `any` versus `specific` worker scope; the exact specific-worker set is persisted and enforced consistently by listing, dispatch and acceptance without silent fallback to the open pool.
- Notification feed state distinguishes delivery from viewing while keeping `readAt` backward-compatible.
- Recurring coverage changes are aggregated and deduplicated at series level with explicit completion state when all future seats are covered.

Latest verified backend recurring CI: run `34031824387`, green.

## Remaining Recurring Cleaning work

The following items are not marked complete by this map:

- Late/no-travel options and admin reporting.

## Other Cleaning Suite work still open

- Remaining Multi-Day Event Assistance dynamic/admin/travel items.
- Open-Time Worker Requests.
- Initial Cleaning Materials.
- Special Services.
- Cross-feature integration and final regression/parity audit.

Legacy `multiday` and `multiday-dev` branches remain retained until the final port/diff audit is complete.