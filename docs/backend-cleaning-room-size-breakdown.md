# Laravel Backend Request: Cleaning Room Size Breakdown (Create + Estimate)

Date: May 29, 2026

## Goal

Mobile app now collects room sizes per room type using buckets (`small`, `medium`, `large`) and sends this in cleaning booking requests.

This update applies to:

- `POST /api/v1/user/cleaning/orders/estimate-price`
- `POST /api/v1/user/cleaning/orders`

## Important rollout note

The mobile app keeps legacy fields and adds new data in the same request.

- Legacy fields remain:
  - `propertyDetails.bedrooms`
  - `propertyDetails.rooms`
  - `propertyDetails.bathrooms`
  - `propertyDetails.living_room_size`
- New field added:
  - `propertyDetails.room_size_breakdown`

Backend should parse and prefer `room_size_breakdown` when present, while continuing to accept legacy-only requests.

## Old request shape (before this update)

### Estimate price

```json
{
  "propertyType": "apartment",
  "propertyDetails": {
    "bedrooms": 5,
    "rooms": 2,
    "bathrooms": 2,
    "living_room_size": "medium"
  },
  "addressLatitude": 33.5138,
  "addressLongitude": 36.2765
}
```

### Create order

```json
{
  "propertyType": "apartment",
  "propertyDetails": {
    "address": "Home address",
    "location_name": "المنزل",
    "bedrooms": 5,
    "rooms": 2,
    "bathrooms": 2,
    "living_room_size": "medium"
  },
  "scheduledDate": "2026-05-31",
  "scheduledTime": "10:00",
  "addressLatitude": 33.5138,
  "addressLongitude": 36.2765,
  "genderPreference": "any",
  "termsAccepted": true
}
```

## Updated request shape (after this update)

### Estimate price

```json
{
  "propertyType": "apartment",
  "propertyDetails": {
    "bedrooms": 9,
    "rooms": 4,
    "bathrooms": 3,
    "living_room_size": "large",
    "room_size_breakdown": {
      "bedroom": { "small": 1, "medium": 2, "large": 1 },
      "bathroom": { "small": 1, "medium": 1, "large": 1 },
      "kitchen": { "small": 1, "medium": 0, "large": 0 },
      "living_room": { "small": 0, "medium": 1, "large": 0 }
    }
  },
  "addressLatitude": 33.5138,
  "addressLongitude": 36.2765
}
```

### Create order

```json
{
  "propertyType": "apartment",
  "propertyDetails": {
    "address": "Home address",
    "location_name": "المنزل",
    "bedrooms": 9,
    "rooms": 4,
    "bathrooms": 3,
    "living_room_size": "large",
    "room_size_breakdown": {
      "bedroom": { "small": 1, "medium": 2, "large": 1 },
      "bathroom": { "small": 1, "medium": 1, "large": 1 },
      "kitchen": { "small": 1, "medium": 0, "large": 0 },
      "living_room": { "small": 0, "medium": 1, "large": 0 }
    }
  },
  "scheduledDate": "2026-05-31",
  "scheduledTime": "10:00",
  "addressLatitude": 33.5138,
  "addressLongitude": 36.2765,
  "genderPreference": "any",
  "termsAccepted": true
}
```

## Laravel validation guidance

Example validation rules to add/extend in FormRequest for non-event-assistance flows:

```php
return [
    'propertyType' => ['required', 'string'],
    'propertyDetails' => ['required', 'array'],

    // Legacy compatibility fields (keep accepting)
    'propertyDetails.bedrooms' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.rooms' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.bathrooms' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.living_room_size' => ['nullable', 'in:small,medium,large'],

    // New field
    'propertyDetails.room_size_breakdown' => ['nullable', 'array'],

    'propertyDetails.room_size_breakdown.bedroom' => ['required_with:propertyDetails.room_size_breakdown', 'array'],
    'propertyDetails.room_size_breakdown.bathroom' => ['required_with:propertyDetails.room_size_breakdown', 'array'],
    'propertyDetails.room_size_breakdown.kitchen' => ['required_with:propertyDetails.room_size_breakdown', 'array'],
    'propertyDetails.room_size_breakdown.living_room' => ['required_with:propertyDetails.room_size_breakdown', 'array'],

    'propertyDetails.room_size_breakdown.bedroom.small' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.bedroom.medium' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.bedroom.large' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.bathroom.small' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.bathroom.medium' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.bathroom.large' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.kitchen.small' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.kitchen.medium' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.kitchen.large' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.living_room.small' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.living_room.medium' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.living_room.large' => ['required_with:propertyDetails.room_size_breakdown', 'integer', 'min:0'],
];
```

## Backend parsing behavior

Recommended server behavior for non-event-assistance flows:

1. If `propertyDetails.room_size_breakdown` exists and valid:
   - Use it as the primary source for pricing/estimation logic.
2. Else:
   - Fallback to legacy fields (`bedrooms`, `rooms`, `bathrooms`, `living_room_size`).
3. Keep responses backward compatible for current mobile versions.

## Mobile legacy mapping details (for reference)

When mobile sends the new breakdown, legacy fields are auto-derived as:

- `bedrooms`: total of all buckets across all room types.
- `rooms`: total bucket count for `bedroom`.
- `bathrooms`: total bucket count for `bathroom`.
- `living_room_size`: `large` if any large living room exists, else `medium` if any medium exists, else `small`.

## Acceptance checklist

- [ ] Both endpoints accept requests with only legacy fields.
- [ ] Both endpoints accept requests with legacy + `room_size_breakdown`.
- [ ] Validation errors clearly indicate invalid bucket keys or negative values.
- [ ] Estimation/creation logic uses `room_size_breakdown` when available.
- [ ] Existing event-assistance request shape remains unchanged.
