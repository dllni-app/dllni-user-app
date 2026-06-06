# Laravel Backend Request: Corridor Room Type + Cleaning Type (Estimate + Create)

Date: June 3, 2026

## Goal

Mobile app now supports:

1. A new room type bucket in `propertyDetails.room_size_breakdown`: **`corridor`** (الموزع).
2. A top-level cleaning option field: **`cleaningType`** with values `deep_cleaning` or `regular_cleaning`.

This update applies to:

- `POST /api/v1/user/cleaning/orders/estimate-price`
- `POST /api/v1/user/cleaning/orders`

## Important rollout note

The mobile app keeps legacy fields and adds new data in the same request.

- Legacy fields remain unchanged (`propertyDetails.bedrooms`, `rooms`, `bathrooms`, `living_room_size`, etc.).
- `propertyDetails.room_size_breakdown` now may include `corridor`.
- New top-level field: `cleaningType` (camelCase, next to `propertyType`).

Backend should accept requests without `cleaningType` and without `corridor` for backward compatibility.

## New field: `cleaningType`

| Value | Arabic UI label | Meaning |
|-------|-----------------|--------|
| `deep_cleaning` | تنظيف عميق | Deep cleaning: floor washing, walls, ceilings, dusting |
| `regular_cleaning` | تنظيف عادي | Regular cleaning: dusting and floor wiping |

Mobile default when user does not change selection: `regular_cleaning`.

## New room bucket: `corridor`

Inside `propertyDetails.room_size_breakdown`, add support for:

```json
"corridor": { "small": 0, "medium": 0, "large": 0 }
```

Same shape as existing room types (`bedroom`, `bathroom`, `kitchen`, `living_room`, `balcony`).

## Updated request shape — estimate price

```json
{
  "propertyType": "apartment",
  "cleaningType": "deep_cleaning",
  "propertyDetails": {
    "bedrooms": 10,
    "rooms": 4,
    "bathrooms": 3,
    "living_room_size": "medium",
    "room_size_breakdown": {
      "bedroom": { "small": 1, "medium": 2, "large": 1 },
      "bathroom": { "small": 1, "medium": 1, "large": 1 },
      "kitchen": { "small": 1, "medium": 0, "large": 0 },
      "living_room": { "small": 0, "medium": 1, "large": 0 },
      "balcony": { "small": 0, "medium": 1, "large": 0 },
      "corridor": { "small": 1, "medium": 0, "large": 0 }
    }
  },
  "addressLatitude": 33.5138,
  "addressLongitude": 36.2765
}
```

## Updated request shape — create order

```json
{
  "propertyType": "apartment",
  "cleaningType": "regular_cleaning",
  "propertyDetails": {
    "address": "Home address",
    "location_name": "المنزل",
    "bedrooms": 10,
    "rooms": 4,
    "bathrooms": 3,
    "living_room_size": "medium",
    "room_size_breakdown": {
      "bedroom": { "small": 1, "medium": 2, "large": 1 },
      "bathroom": { "small": 1, "medium": 1, "large": 1 },
      "kitchen": { "small": 1, "medium": 0, "large": 0 },
      "living_room": { "small": 0, "medium": 1, "large": 0 },
      "balcony": { "small": 0, "medium": 1, "large": 0 },
      "corridor": { "small": 1, "medium": 0, "large": 0 }
    }
  },
  "scheduledDate": "2026-06-05",
  "scheduledTime": "10:00",
  "addressLatitude": 33.5138,
  "addressLongitude": 36.2765,
  "genderPreference": "any",
  "termsAccepted": true
}
```

## Laravel validation guidance

Example rules to add/extend for non-event-assistance flows:

```php
return [
    'propertyType' => ['required', 'string'],
    'cleaningType' => ['nullable', 'in:deep_cleaning,regular_cleaning'],

    'propertyDetails' => ['required', 'array'],
    'propertyDetails.room_size_breakdown' => ['nullable', 'array'],

    'propertyDetails.room_size_breakdown.corridor' => [
        'required_with:propertyDetails.room_size_breakdown',
        'array',
    ],
    'propertyDetails.room_size_breakdown.corridor.small' => [
        'required_with:propertyDetails.room_size_breakdown.corridor',
        'integer',
        'min:0',
    ],
    'propertyDetails.room_size_breakdown.corridor.medium' => [
        'required_with:propertyDetails.room_size_breakdown.corridor',
        'integer',
        'min:0',
    ],
    'propertyDetails.room_size_breakdown.corridor.large' => [
        'required_with:propertyDetails.room_size_breakdown.corridor',
        'integer',
        'min:0',
    ],
];
```

## Backend parsing behavior

Recommended server behavior for non-event-assistance flows:

1. If `propertyDetails.room_size_breakdown` exists:
   - Include `corridor` buckets in area/effort/pricing calculations when present.
   - Continue to prefer breakdown over legacy-only fields when breakdown is valid.
2. If `cleaningType` is present:
   - Apply pricing multipliers or service rules for deep vs regular cleaning.
   - Persist `cleaningType` on the booking/order record for fulfillment.
3. If `cleaningType` is absent:
   - Treat as legacy request; default to `regular_cleaning` or existing server default.
4. Event-assistance requests remain unchanged (no `cleaningType`, no home room breakdown).

## Mobile legacy mapping (reference)

When mobile sends the new breakdown, legacy fields are still auto-derived:

- `bedrooms`: total of all buckets across all room types (including `corridor`).
- `rooms`: total bucket count for `bedroom`.
- `bathrooms`: total bucket count for `bathroom`.
- `living_room_size`: derived from living room buckets only.

## Acceptance checklist

- [ ] Both endpoints accept requests without `cleaningType` (backward compatible).
- [ ] Both endpoints accept `cleaningType` = `deep_cleaning` or `regular_cleaning`.
- [ ] `room_size_breakdown.corridor` is validated and used in pricing when sent.
- [ ] Estimation/creation logic applies deep vs regular cleaning rules when `cleaningType` is sent.
- [ ] Order/booking detail responses can expose stored `cleaningType` for customer and worker apps.
- [ ] Event-assistance request shape remains unchanged.
