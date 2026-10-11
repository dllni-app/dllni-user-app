# Alnadha Customer V7 — Flutter implementation notes (dev)

## Branch and source
- Branch: `dev` of `dllni-user-app`; source Pen: `designs/user-app-cleaning/alnadha-customer-v7.pen`.
- Design handoff: `V7_FLUTTER_HANDOFF.md`, `V7_ART_DIRECTION.md`, `V7_SCREEN_COVERAGE.csv`.
- Changes confined to Flutter. Backend Laravel domain behavior, pricing, quote, realtime and authorization are untouched.

## Advertisement: active and alternative
- **Active default: V7 editorial offers carousel**, using only backend-provided `UserOfferItem` content and image URL; no local fake promotions and no ad if no offers exist.
- **Preserved alternative: redesigned four-face `HomeCube`**, updated media/scrims/typography, backed by the same real offers, **disabled by default**.
- To activate cube for a development/release build: `flutter run --dart-define=ALNADHA_AD_STYLE=cube` or use this Dart define with `flutter build`.
- To restore default without edits: omit the define or use `--dart-define=ALNADHA_AD_STYLE=editorial`.
- Implementation: `lib/features/home/view/widgets/v7_campaign_presenter.dart` and `home_cube.dart`.
- Offers have title/description/discount/image fields; **no confirmed trusted action target** was found in the consumed Flutter `UserOfferItem`. Accordingly, V7 carousel does not invent a clickable promotion destination. An optional backend addition is described below.

## Coverage implemented in Flutter
- Shared V7 artwork assets copied to `assets/images/v7` and declared in `pubspec.yaml`; `V7Artwork`, `V7ArtTile`, `V7SpotState` provide reusable semantic visual treatment.
- Home: campaign section first, illustrated four business categories, photo-supported featured cleaning service, working existing auth/routes/current-order and user profile header.
- Cleaning: photo fallback and richer banners; compressed property/occasion cards with real server image fallback, illustrations for cleaning modes, room counters, task chips, worker count and previously used workers.
- Orders: cleaning service visual identity, honest unknown-price display, V7 missing/offline states; visual context in cleaning details, preserve worker tracking/last-hour decisions and backend lifecycle behavior. Restaurant/supermarket order cards use meaningful illustrations.
- Profile: illustrated account tools, saved address/support entry and empty address/coupons/notifications/shopping list states.
- Worker trust: genuine API image when available, neutral fallback otherwise; do not use marketing photo as a worker portrait.

## What is *not* claimed
- The 96 Pen boards represent many **UI states**, not 96 distinct Flutter routes. This integration updates shared components for many such states, but no frame-by-frame device golden comparison for **all** 96 states has been performed; do not label it pixel-perfect or final device E2E approved.
- Auth, existing multi-session/recurring forms, SOS, critical actions and detailed lifecycle screens keep their current backend-integrated behavior; only referenced visual surfaces were changed. More visual refinements are possible after a complete staging/real-device UX comparison.
- Assets source includes editorial imagery. Confirm each photo's attribution/rights/release and asset quality before publishing. See `designs/user-app-cleaning/V7_ASSET_MANIFEST.csv`.

## Verification
- `flutter test --no-pub test/features/home/v7_customer_visual_test.dart`: **5 passed** including default editorial, opt-in cube, category callbacks, 320dp RTL, no fabricated offers.
- Combined relevant tests for cleaning banners/lifecycle/last-hour: **12 passed, 2 skipped**, before adding the 320dp test.
- Targeted `dart analyze`: home widgets/screens and cleaning widgets/orders widgets clean. Two existing warnings in occasion schedule screen; old add-address unused helpers remain.
- Whole-tree Flutter analyzer earlier returned 251 warnings/info, no `error` diagnostics in inspected log. This is not a claim that the legacy analyzer is warning-free.
- Must still test on authorized staging/physical Android/iOS and review 320/360/390/430dp image/text scaling and WCAG semantics before publication.

## Backend conclusion
**No mandatory Laravel API/schema changes are proven necessary** to render this V7 visual adaptation: cleaning and order APIs already exist, marketing offers already expose image/title/description/discount, and worker APIs already have optional image fields. Backend remains unchanged.

Optional improvement if owner approves clickable ads: add backward-compatible optional `ctaLabel`, `targetType`, `targetId` (or allowlisted deeplink) to the *existing offers resource*, validate it server-side, and route on the customer app after a contract test. Avoid adding a new endpoint just for visuals. This is conditional, **not a blocker for the current non-clickable editorial cards**.

## Known product QA gates
- Design-to-code screen-state parity/golden export for every key P0 scenario.
- Decide advertisement CTA navigation target policy before labeling cards actionable.
- Finalize legal/editorial assets for production.
- Full app Flutter integration/widget tests and staging device QA; keep backend as source of truth.
