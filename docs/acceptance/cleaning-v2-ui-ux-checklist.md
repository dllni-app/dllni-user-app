# Cleaning v2 customer UI acceptance

Design source: `design-system/MASTER.md` plus the relevant page override. Review method: `ui-ux-pro-max` local-rule fallback; Python search was unavailable.

## Open time

- [x] Expected ceiling is serialized and legacy requests default to 480 minutes.
- [x] Live meter uses `serverNow`, stable tabular digits, elapsed time, remaining time, and amount.
- [x] Pending extension and end states prevent duplicate actions and expose recovery errors.
- [x] Timer/model/widget tests cover running and fallback states.

## Recurring changes

- [x] Proposal and affected-worker decision states are visible.
- [x] Rejected changes offer replacement, revert, and cancel explicitly.
- [x] Replacement picker lists only API-eligible workers and retains selection on failure.
- [x] Busy, error, pending, rejected, accepted, and responsive RTL states are covered by widget/model tests.

## Events

- [x] Event types and ordered field definitions come from the cleaning suite API.
- [x] Dynamic answers persist through the creation/estimate payload.
- [x] Legacy event slug remains supported.
- [x] Multi-session pricing and schedule payload remain visible through existing event summary components.

## Special services and materials

- [x] Customer sees a single platform-material toggle.
- [x] Special service items support decimal quantity, dirtiness, notes, and selected sessions.
- [x] Multiple service items are editable independently with decimal measurements and per-item dirtiness.
- [x] Detail models expose item and execution states.
- [x] Input/loading/error state is retained by the shared extras component.

## Global gates

- [x] RTL directional layout and localized semantic labels.
- [x] New actions are at least 48dp and guarded against repeat submission.
- [x] No emoji icons; existing icon family retained.
- [x] Targeted model, widget, semantics, and timer tests pass.
- [x] New cleaning components are exercised in both the existing light theme and an explicit dark color scheme at 375px with large text.
