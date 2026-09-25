# Dllni Customer App Redesign

This folder is the visual handoff for the Dllni customer Flutter app.

## Sources of truth

- **Behavior:** current Flutter code on the `dev` branch.
- **Visuals:** `customer-app-redesign.pen`.
- **Shared design library:** `customer-app-design-system.lib.pen`.

The redesign is presentation-only. API contracts, repositories, use cases, pricing rules, booking eligibility, realtime behavior, and order lifecycle rules must remain unchanged during Flutter implementation.
## Coverage

The Pen file contains 18 organized boards covering:

- Authentication: login, registration, OTP, recovery/help.
- Main shell and Home.
- Profile, personal details, notifications, coupons.
- Saved addresses and add-address/location flows.
- Cleaning discovery and service selection.
- Complete cleaning booking builder.
- Booking review, price summary, and confirmation.
- Orders and customer-visible cleaning lifecycle states.
- Reschedule, problem report, SOS, and rating.
- Multi-day occasions, recurring cleaning, and open-time cleaning.
- Representative restaurant, supermarket, and delivery surfaces.
- Loading, empty, error, disabled, and success states.
- Developer screen mapping and implementation constraints.
## Room pricing UX

The room selector is intentionally explicit.

For every supported room type and size it separates:

1. Room type.
2. Size: small / medium / large.
3. Unit price.
4. Quantity.
5. Line subtotal.
6. Overall selected-rooms subtotal.

The current Flutter/domain source remains authoritative. `CleaningRoomSizeBreakdown` provides room type, size, and quantity. Unit price/subtotal must only be displayed when the existing estimate/config data provides them. The UI must never fabricate a unit price.

Supported room types represented in the design include bedroom, bathroom, kitchen, living room, balcony, corridor, and shed/storage.
## Implementation order

Recommended Flutter implementation order:

1. Theme/tokens and shared components.
2. Main shell, Home, and navigation.
3. Authentication and OTP.
4. Profile/settings/addresses.
5. Cleaning discovery.
6. Room pricing selector and booking builder.
7. Booking review/confirmation.
8. Orders and cleaning order details lifecycle.
9. Recovery/support/rating.
10. Recurring, open-time, and multi-day states.
11. Shared visual alignment for restaurant/supermarket/delivery.

Implement one flow at a time and compare against the Pen frame plus its developer metadata before moving to the next flow.
## UX rules

- Arabic-first RTL.
- Cairo typography.
- Visible numeric glyphs use Western digits `0-9`.
- Use Directional layout APIs in Flutter.
- Minimum interactive target: 44dp.
- Do not expose internal worker/admin financial calculations to the customer.
- Disabled actions must explain the current eligibility reason.
- Keep only the action relevant to the current order state visually prominent.
- All major flows require loading, empty, error, validation, disabled, and success handling.
