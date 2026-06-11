# Laravel Backend Request: Allow Partial Cleaning Room Size Breakdown

Date: June 11, 2026

## Goal

The mobile app can send `propertyDetails.room_size_breakdown` with only the room types that the customer actually selected.

Backend validation should not require every room type (`bedroom`, `bathroom`, `kitchen`, `living_room`, `balcony`) or every bucket (`small`, `medium`, `large`) just because `room_size_breakdown` is present.

This applies to:

- `POST /api/v1/user/cleaning/orders/estimate-price`
- `POST /api/v1/user/cleaning/orders`

## Current failing request

Endpoint:

```text
POST /api/v1/user/cleaning/orders/estimate-price
```

Request body sent by Flutter:

```json
{
  "propertyType": "villa",
  "propertyDetails": {
    "bedrooms": 2,
    "rooms": 1,
    "bathrooms": 1,
    "balconies": 0,
    "living_room_size": "small",
    "room_size_breakdown": {
      "bedroom": {
        "small": 0,
        "medium": 0,
        "large": 1
      },
      "bathroom": {
        "small": 0,
        "medium": 1,
        "large": 0
      }
    },
    "cleaning_mode": "deep"
  },
  "addressLatitude": 36.2001697,
  "addressLongitude": 37.1169824,
  "assignmentMode": "preferred_worker",
  "preferredWorkerId": 1,
  "numberOfWorkers": 1,
  "workerRoomAssignments": [
    {
      "workerSlot": 1,
      "preferredWorkerId": 1,
      "rooms": [
        {
          "roomKey": "bedroom.large.1",
          "roomType": "bedroom",
          "roomSize": "large"
        },
        {
          "roomKey": "bathroom.medium.1",
          "roomType": "bathroom",
          "roomSize": "medium"
        }
      ]
    }
  ]
}
```

## Current backend response

Backend returns `422` because it requires missing room types and bucket keys:

```json
{
  "message": "The property details.room size breakdown.kitchen field is required when property details.room size breakdown is present. (and 11 more errors)",
  "errors": {
    "propertyDetails.room_size_breakdown.kitchen": [
      "The property details.room size breakdown.kitchen field is required when property details.room size breakdown is present."
    ],
    "propertyDetails.room_size_breakdown.living_room": [
      "The property details.room size breakdown.living room field is required when property details.room size breakdown is present."
    ],
    "propertyDetails.room_size_breakdown.balcony": [
      "The property details.room size breakdown.balcony field is required when property details.room size breakdown is present."
    ],
    "propertyDetails.room_size_breakdown.kitchen.small": [
      "The property details.room size breakdown.kitchen.small field is required when property details.room size breakdown is present."
    ]
  }
}
```

## Required backend behavior

If `propertyDetails.room_size_breakdown` is present:

- Accept only the room type objects included in the request.
- Do not require missing room types.
- Do not require missing size buckets inside a provided room type.
- Treat missing room types and missing size buckets as `0` in pricing logic.
- Validate provided values as non-negative integers.
- Continue accepting legacy fields such as `bedrooms`, `rooms`, `bathrooms`, `balconies`, and `living_room_size`.

The example request above should be valid because the selected rooms are only:

- `bedroom.large.1`
- `bathroom.medium.1`

It is valid that `kitchen`, `living_room`, and `balcony` are absent from `room_size_breakdown`.

## Suggested Laravel validation

Avoid `required_with:propertyDetails.room_size_breakdown` for each room type and bucket.

Suggested direction:

```php
return [
    'propertyType' => ['required', 'string'],
    'propertyDetails' => ['required', 'array'],

    // Legacy compatibility fields.
    'propertyDetails.bedrooms' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.rooms' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.bathrooms' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.balconies' => ['nullable', 'integer', 'min:0'],
    'propertyDetails.living_room_size' => ['nullable', 'in:small,medium,large'],
    'propertyDetails.cleaning_mode' => ['nullable', 'string'],

    // New breakdown. The object itself is optional.
    'propertyDetails.room_size_breakdown' => ['nullable', 'array'],

    // Room types are optional. Validate only when present.
    'propertyDetails.room_size_breakdown.bedroom' => ['sometimes', 'array'],
    'propertyDetails.room_size_breakdown.bathroom' => ['sometimes', 'array'],
    'propertyDetails.room_size_breakdown.kitchen' => ['sometimes', 'array'],
    'propertyDetails.room_size_breakdown.living_room' => ['sometimes', 'array'],
    'propertyDetails.room_size_breakdown.balcony' => ['sometimes', 'array'],

    // Buckets are optional. Validate only when present.
    'propertyDetails.room_size_breakdown.*.small' => ['sometimes', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.*.medium' => ['sometimes', 'integer', 'min:0'],
    'propertyDetails.room_size_breakdown.*.large' => ['sometimes', 'integer', 'min:0'],
];
```

If stricter key validation is needed, allow only these room type keys:

```text
bedroom, bathroom, kitchen, living_room, balcony
```

And only these size bucket keys:

```text
small, medium, large
```

## Pricing normalization

Before pricing, backend can normalize the partial payload into a complete internal structure:

```json
{
  "bedroom": { "small": 0, "medium": 0, "large": 1 },
  "bathroom": { "small": 0, "medium": 1, "large": 0 },
  "kitchen": { "small": 0, "medium": 0, "large": 0 },
  "living_room": { "small": 0, "medium": 0, "large": 0 },
  "balcony": { "small": 0, "medium": 0, "large": 0 }
}
```

This normalization should happen server-side and should not be required from Flutter.

## Acceptance checklist

- [ ] Estimate-price endpoint accepts partial `room_size_breakdown`.
- [ ] Create-order endpoint accepts partial `room_size_breakdown`.
- [ ] Missing room types are treated as zero counts.
- [ ] Missing `small`, `medium`, or `large` buckets are treated as zero counts.
- [ ] Provided bucket values still reject negative numbers and non-integers.
- [ ] Existing legacy-only requests continue to work.
