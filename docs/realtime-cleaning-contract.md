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
- `cleaning_order.arrival_verified`
- `cleaning_order.awaiting_worker_start_confirmation` (worker-app action required after customer verifies the code)
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
- Start verification success:
  - Customer app may receive `ArrivalVerified` / `cleaning_order.arrival_verified` after the customer enters the correct 4-digit code.
  - Backend should return/broadcast status `awaiting_worker_start_confirmation` until the worker confirms start.
  - Worker app should receive `cleaning_order.awaiting_worker_start_confirmation` and then call the worker confirm-start endpoint before the order moves to `in_progress`.

## CompletionDecisionMade

- Event name: `CompletionDecisionMade`
- Payload fields:
  - `cleaningBookingId`
  - `workerId`
  - `decision`: `approved` | `rejected` | `extension_requested` | `extension_accepted` | `extension_rejected`
  - `message` (optional)
  - `decidedAt` (ISO-8601)
  - `warningId` (optional, extension flows)
  - `status` (post-decision booking status)
  - `version`
- Status mapping:
  - `extension_requested` → `time_extension_requested`
  - `extension_accepted` → `in_progress` (return to service UI, do not reopen completion sheet)
  - `extension_rejected` → `completed` (terminal; do not reopen completion sheet)
