# Dllni Customer App Design System

Status: authoritative for new `v2` cleaning experiences. Generated as a documented `ui-ux-pro-max` fallback because the optional Python search runner is unavailable in this workspace. It preserves the existing brand instead of redesigning it.

## Foundations

- Direction: Arabic-first RTL. Use `EdgeInsetsDirectional`, `AlignmentDirectional`, localized dates/numbers, and verify semantic traversal order.
- Type: Cairo. Never clamp text below the operating-system request inside a feature; new cleaning layouts must remain usable at 200% text scale even while the current application-wide clamp is retired separately.
- Brand: primary `#1E2A78`, secondary `#6C63FF`, accent `#FF7A00`, page `#F3F4F6`, surface `#FFFFFF`, text `#1F2937`, muted text `#6B7280`, border `#D1D5DB`, error `#BF393D`.
- Contrast: normal text at least 4.5:1 and large text at least 3:1. Status must use icon/text as well as color.
- Spacing: 4dp base; preferred gaps 8/12/16/20/24. Cards use 12-16dp radius and 16-20dp internal padding.
- Interaction: at least 48x48dp. One visually dominant action per screen. Disable repeated submissions and keep entered values after failures.
- Motion: short opacity/color transitions only; respect reduced motion and never animate counter dimensions.

## Shared cleaning components

- `CleaningOpenTimeLiveCard`: server-anchored duration, tabular digits, stable-width amount, explicit pending-extension/end states.
- `CleaningScheduleChangeResolutionCard`: proposal comparison, worker approval state, replacement/revert/cancel recovery paths.
- `ClCleaningExtrasSectionWidget`: platform-material toggle and special-service item/session input.
- Dynamic event form: visible labels, helper text, field-level errors, persisted answers, and API ordering.
- State surfaces: loading skeleton/progress, empty explanation plus recovery action, inline retryable error, pending, accepted, rejected, and success confirmation.

## Responsive and accessibility contract

- Verify 375px phone, large phone, tablet, landscape, keyboard-visible, safe areas, light and dark color schemes.
- No horizontal overflow at 200% text scale. Actions wrap or stack; labels never disappear in favor of icons alone.
- Every actionable control has a localized semantic label; decorative graphics are excluded; focus and reading order follow RTL meaning.
- Preserve scroll/form/session selections across navigation and route notifications to the exact booking/change request.
- Counter updates must rebuild only the value region at no more than once per second and use tabular figures or fixed width.

## Page overrides

- [Open-time request and live session](pages/open-time.md)
- [Recurring schedule changes](pages/recurring.md)
- [Dynamic multi-day events](pages/events.md)
- [Special services and materials](pages/special-services.md)

