# Cleaning realtime contract (user app)

This contract captures the event/channel names currently consumed by the user app.

## Transport and auth

- Transport: Pusher Channels.
- Private channel auth endpoint: `POST /broadcasting/auth`.
- Required headers: `Accept: application/json`, `Authorization: Bearer <token>`.

## Channels

- Booking channel: `private-cleaning-booking.{bookingId}`
- Worker channel: `private-cleaning-worker.{workerId}`

## Supported event names

- `CleaningBookingTrackingUpdated`
- `WorkerArrived`
- `SecurityCodeIssued`
- `cleaning_order.awaiting_start_verification`
- `cleaning_order.security_code_issued`
- `cleaning_order.awaiting_customer_completion`
- `ArrivalVerified`
- `CompletionDecisionMade`
- `ServiceExtensionRequested`
- `WorkerLocationUpdated`

## Payload requirements

- Booking id fallback chain:
  - `tracking.cleaningBookingId`
  - `tracking.bookingId`
  - `tracking.id`
  - `cleaningBookingId`
  - `bookingId`
  - `id`
- Worker location:
  - latitude: `latitude` or `lat`
  - longitude: `longitude` or `lng`
- Service extension:
  - warning id: `warningId` or `warning_id`
  - requested minutes: `requestedMinutes` or `requested_minutes`
