# Laravel Backend Request: Worker Room Assignments (Estimate + Create)

Date: June 5, 2026

## Goal

The Flutter user app now collects worker assignment preferences on the home-description step (before schedule) and sends them as an additive optional field:

- `workerRoomAssignments`

This applies to:

- `POST /api/v1/user/cleaning/orders/estimate-price`
- `POST /api/v1/user/cleaning/orders`

## Rollout note

- Legacy clients can omit `workerRoomAssignments`.
- When present, backend should use it for pricing hints / pre-assignment during booking creation.
- Post-order room edits remain via `PATCH /api/v1/user/cleaning/orders/{order}/room-assignments`.

## Field: `workerRoomAssignments`

Type: `array` of objects.

Each item:

| Key | Type | Required | Notes |
|-----|------|----------|-------|
| `workerSlot` | integer | yes | 1-based slot, bounded by `numberOfWorkers` |
| `preferredWorkerId` | integer/null | yes | Set for preferred-worker mode; null for team slots |
| `rooms` | array | yes | Room units assigned to this slot |

Each room object:

| Key | Type | Required | Notes |
|-----|------|----------|-------|
| `roomKey` | string | yes | e.g. `bedroom.small.1` — derived from `propertyDetails.room_size_breakdown` |
| `roomType` | string | yes | `bedroom`, `bathroom`, `kitchen`, `living_room`, `balcony`, `corridor` |
| `roomSize` | string | yes | `small`, `medium`, `large` |

## Team mode example (`assignmentMode = open_count`)

```json
{
  "propertyType": "apartment",
  "assignmentMode": "open_count",
  "numberOfWorkers": 2,
  "propertyDetails": {
    "room_size_breakdown": {
      "bedroom": { "small": 1, "medium": 0, "large": 0 },
      "bathroom": { "small": 1, "medium": 0, "large": 0 },
      "kitchen": { "small": 0, "medium": 1, "large": 0 },
      "living_room": { "small": 0, "medium": 1, "large": 0 },
      "balcony": { "small": 0, "medium": 0, "large": 0 }
    }
  },
  "workerRoomAssignments": [
    {
      "workerSlot": 1,
      "preferredWorkerId": null,
      "rooms": [
        { "roomKey": "bedroom.small.1", "roomType": "bedroom", "roomSize": "small" },
        { "roomKey": "bathroom.small.1", "roomType": "bathroom", "roomSize": "small" }
      ]
    },
    {
      "workerSlot": 2,
      "preferredWorkerId": null,
      "rooms": [
        { "roomKey": "kitchen.medium.1", "roomType": "kitchen", "roomSize": "medium" },
        { "roomKey": "living_room.medium.1", "roomType": "living_room", "roomSize": "medium" }
      ]
    }
  ]
}
```

## Preferred-worker mode example

```json
{
  "propertyType": "apartment",
  "assignmentMode": "preferred_worker",
  "numberOfWorkers": 1,
  "preferredWorkerId": 44,
  "workerRoomAssignments": [
    {
      "workerSlot": 1,
      "preferredWorkerId": 44,
      "rooms": [
        { "roomKey": "bedroom.small.1", "roomType": "bedroom", "roomSize": "small" },
        { "roomKey": "bathroom.small.1", "roomType": "bathroom", "roomSize": "small" }
      ]
    }
  ]
}
```

## Validation guidance

```php
return [
    'workerRoomAssignments' => ['nullable', 'array'],
    'workerRoomAssignments.*.workerSlot' => ['required_with:workerRoomAssignments', 'integer', 'min:1'],
    'workerRoomAssignments.*.preferredWorkerId' => ['nullable', 'integer'],
    'workerRoomAssignments.*.rooms' => ['required_with:workerRoomAssignments', 'array'],
    'workerRoomAssignments.*.rooms.*.roomKey' => ['required', 'string'],
    'workerRoomAssignments.*.rooms.*.roomType' => ['required', 'string'],
    'workerRoomAssignments.*.rooms.*.roomSize' => ['required', 'in:small,medium,large'],
];
```

## Backend behavior

1. If `workerRoomAssignments` is omitted: keep current behavior.
2. If present with `assignmentMode = open_count`:
   - Validate `workerSlot <= numberOfWorkers`.
   - Validate each `roomKey` exists in the booking's derived room units from `room_size_breakdown`.
   - Unassigned rooms may be auto-balanced across slots server-side.
3. If present with `assignmentMode = preferred_worker`:
   - Expect a single slot with `preferredWorkerId` matching top-level `preferredWorkerId`.
4. Ignore for `event_assistance` flows.

## Acceptance checklist

- [ ] Both endpoints accept requests without `workerRoomAssignments`.
- [ ] Both endpoints accept valid `workerRoomAssignments` for team and preferred-worker modes.
- [ ] Invalid `roomKey` / slot / worker count returns clear validation errors.
- [ ] Estimate pricing can factor per-worker room weights when assignments are sent.
- [ ] Create order persists intended pre-assignments for later team fulfillment.
