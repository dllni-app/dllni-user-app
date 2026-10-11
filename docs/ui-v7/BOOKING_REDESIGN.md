# V7 cleaning booking — implementation notes

Branch: `dev` / `dllni-user-app`

## Customer flow
The ordinary home-cleaning journey now has six visible steps across two existing Flutter screens. The first three select rooms, sizes and cleaning type. The remaining three select date/address, adjust service options/worker preferences, and review before submitting. Navigation preserves local selections and scrolls to the top of the next step.

The final review displays cleaning type, chosen address, worker count, optional materials, selected services and the backend-provided date/time/price summary. It does not generate or alter pricing. Sending a request is gated on a complete service address, worker-gender preference, applicable safety confirmation and a current successful price estimate.

## Visual changes
- Removed decorative service/task illustrations from the requested-service chips.
- Removed the worker illustration from the number-of-workers control.
- Collapsed optional custom-service input behind an expansion control.
- Collapsed the itemized material estimate and fixed dark-on-dark text contrast.
- Replaced implementation-oriented explanations with concise customer-oriented copy.
- Removed duplicated status-bar height from the booking header and supplied a visible back button.

## Behaviour intentionally preserved
- Existing `ClMainBloc` events, remote quote/estimate flow, worker assignments, discounts and create-order payload.
- Recurring and special-service options and user-selected details.
- Backend authority for prices, eligibility, safety, address requirements and order creation.
- No backend/API/schema changes made.

## Verification
- Focused `dart analyze` for seven modified/new booking files: no issues.
- 11 related Flutter tests passed, including two review widget tests at 320/390 dp in RTL.
- Android ARM64 debug APK built, installed via USB, and app launch verified. **No real order was created**, so end-to-end backend order creation in staging has not been claimed.

## Further acceptance
- Check complete manual scenarios in a safe staging environment: single/recurring visits, date changes, different worker counts, a preferred worker, female-worker confirmation, missing address, material quotes, coupon recalculation and submission failure/retry.
- Inspect keyboard and font scaling on real devices and compare the step-by-step screens with Pen V7.
- The separate occasion/other cleaning flows have not been comprehensively refactored in this change.
