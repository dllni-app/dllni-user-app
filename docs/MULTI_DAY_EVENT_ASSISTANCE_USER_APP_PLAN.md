# Multi-Day Event Assistance — Flutter User App UI Flow & API Implementation Plan

## 1. Objective

Update the Flutter user app so a customer can create, review, track, and manage a multi-day event-assistance booking.

Repository:

`dllni-app/dllni-user-app`

The implementation must preserve all current single-day cleaning flows.

## 2. Phase-1 User Rules

1. One event request can contain one or multiple selected days.
2. Each day has its own start time and duration.
3. The same required worker team is used for all event days in Phase 1.
4. Before worker acceptance, the user may edit the schedule.
5. After any worker acceptance, direct multi-day schedule editing is blocked in Phase 1.
6. Each day progresses independently.
7. The booking is not complete until all required non-cancelled days are complete.
8. Review is submitted once after the full booking completes.
9. Cancellation after partial completion applies only to future sessions.
10. Current single-day requests remain supported.

## 3. Current User-App Assumptions to Refactor

Primary files:

- `lib/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart`
- `lib/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart`
- `lib/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart`
- `lib/features/cl_main/view/screens/cl_main_occasion_schedule_screen.dart`
- `lib/features/cl_main/view/data/cl_main_route_args.dart`
- `lib/features/orders/data/models/cleaning_orders_api_models.dart`
- `lib/features/orders/view/widgets/cleaning_order_card.dart`
- `lib/features/orders/view/screens/cleaning_order_details_screen.dart`
- `lib/features/orders/view/screens/cleaning_order_reschedule_screen.dart`
- related Bloc/repository/API data source files

The current occasion schedule screen is based on:

```text
_selectedDate
_fromTimeHhMm
_toTimeHhMm
```

These need to become a collection of session inputs for event assistance.

## 4. User Journey

Target flow:

```text
Choose Event Assistance
        |
        v
Enter event details
        |
        v
Select one or multiple dates
        |
        v
Configure time/duration for each selected day
        |
        v
Choose workers/preferences
        |
        v
Review multi-day summary
        |
        v
Estimate price
        |
        v
Submit one booking
        |
        v
Track day-by-day progress
        |
        v
Complete all days
        |
        v
Review booking
```

## 5. Data Models

Add input model:

```dart
class CleaningEventSessionInput {
  final DateTime date;
  final String time;
  final double hours;
}
```

Add response model:

```dart
class CleaningBookingSessionModel {
  final int id;
  final int sequence;
  final DateTime date;
  final String time;
  final double hours;
  final String status;
  final bool isToday;
  final bool isPast;
  final SessionPricingModel? pricing;
  final SessionWorkerStateModel? workerState;
}
```

Add aggregate schedule model:

```dart
class CleaningBookingScheduleModel {
  final String mode;
  final int daysCount;
  final int completedDaysCount;
  final int cancelledDaysCount;
  final double totalHours;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final CleaningBookingSessionModel? nextSession;
  final List<CleaningBookingSessionModel> sessions;
}
```

Keep legacy model fields for backward compatibility.

## 6. API Request Serialization

### Single-day compatibility

Existing single-day event request remains valid.

### Multi-day request

Serialize:

```json
{
  "propertyType": "event_assistance",
  "schedule": {
    "mode": "multi_day",
    "sessions": [
      {
        "date": "2026-09-10",
        "time": "18:00",
        "hours": 4
      },
      {
        "date": "2026-09-11",
        "time": "17:00",
        "hours": 5
      }
    ]
  }
}
```

Update both:

- price estimate
- create booking

Do not calculate authoritative totals on the device.

## 7. Occasion Schedule Screen State

Replace one selected date with:

```dart
List<CleaningEventSessionDraft> _sessions;
```

Suggested draft model:

```dart
class CleaningEventSessionDraft {
  final DateTime date;
  String fromTime;
  String toTime;
  double hours;
}
```

State rules:

- list always sorted chronologically
- duplicate date selection is prevented
- changing start/end updates that session only
- duration validation follows backend rules
- removing a date removes its session card
- one selected date still works as a normal one-session event

## 8. Multi-Date Selection UI

Update `cl_main_occasion_schedule_screen.dart`.

Required UI:

### Date selection section

- calendar/date picker supports selecting multiple dates
- selected dates are visually highlighted
- show count: `3 أيام مختارة`
- selected dates can be removed

### Session cards

One card per selected day:

```text
اليوم 1
الخميس، 10 سبتمبر
من 06:00 م
إلى 10:00 م
المدة 4 ساعات
```

Actions:

- edit time
- edit duration if duration is explicit
- remove day

### Apply same time to all

Add action:

`تطبيق نفس الوقت على جميع الأيام`

Behavior:

- user chooses source/current time
- apply start time and duration to all session drafts
- user can still override individual sessions afterward

## 9. Validation UX

Before estimate/create:

- at least one session required
- no past dates
- valid start time
- valid duration
- no invalid/duplicate entries
- all required event details present

Display errors next to the affected session, not only as a global toast.

If backend returns structured conflict/validation errors, map them to the correct day when possible.

## 10. Summary Before Submission

Update the order summary to show:

```text
عدد الأيام
أول يوم
آخر يوم
إجمالي الساعات لكل عامل
عدد العاملين
إجمالي ساعات العمل للعاملين
تفاصيل كل يوم
سعر الخدمة
إجمالي رسوم التنقل
الإجمالي النهائي
```

Example:

```text
3 أيام
10 - 13 سبتمبر
12 ساعة لكل عامل
عاملان
24 ساعة عمل إجمالية
```

Price values must come from estimate response.

## 11. Previous Workers / Preferred Workers

The current previous-worker selection must send all candidate sessions to backend availability.

Required response handling:

```text
availableForAllSessions = true/false
conflicts[]
```

UI behavior:

- only selectable if available for all sessions
- unavailable worker can be hidden or disabled
- if disabled, show conflicting date(s)
- selection count must respect required workers

Example message:

```text
هذا العامل غير متاح يوم 11 سبتمبر من 5:00 م إلى 10:00 م.
```

## 12. Create Booking Flow

On submit:

1. validate session drafts
2. build multi-day schedule payload
3. send final estimate if existing flow requires it
4. send create request
5. handle loading
6. handle backend validation
7. navigate to booking details using parent booking id

Do not create one booking per day from the Flutter app.

## 13. Cleaning Order API Model Parsing

Update `cleaning_orders_api_models.dart` / related models to parse:

```text
schedule.mode
schedule.daysCount
schedule.completedDaysCount
schedule.cancelledDaysCount
schedule.totalHours
schedule.firstDate
schedule.lastDate
schedule.nextSession
schedule.sessions[]
```

Defensive parsing:

- if `schedule` is missing, derive legacy one-session display from old fields
- do not crash when backend rollout is mixed
- unknown session status gets a safe generic label

## 14. Order List Card

Update `cleaning_order_card.dart`.

For multi-day event assistance show:

```text
مساعدة مناسبة
3 أيام
10 - 13 سبتمبر
الجلسة القادمة: 11 سبتمبر، 5:00 م
1 / 3 مكتمل
الحالة
السعر الإجمالي
```

For single-day bookings keep current compact display.

Avoid rendering all dates inside list cards.

## 15. Booking Details Screen

Update `cleaning_order_details_screen.dart`.

Recommended structure:

### Parent header

- booking number
- event type
- aggregate status
- total price
- worker team summary

### Multi-day progress

```text
1 من 3 أيام مكتمل
```

### Session timeline/list

Each session shows:

```text
Day 1/3
Date/time
Duration
Status
Workers/status
Price if needed
Available user action
```

### Next session card

Highlight the next actionable session.

## 16. Session-Specific User Actions

User action must include both:

```text
bookingId
sessionId
```

Actions may include:

- start verification confirmation
- completion confirmation
- completion rejection
- time extension request
- SOS
- session cancellation when allowed

The UI must never call a parent lifecycle endpoint for a multi-day session if the backend exposes the new session route.

## 17. Start Verification

When worker arrives for Session 2:

- details screen opens/highlights Session 2
- confirmation applies only to Session 2
- Session 1 remains historical/completed
- Session 3 remains future/scheduled

Realtime event payload `sessionId` determines which card updates.

## 18. Completion Flow

After user confirms a non-final session:

Display success state similar to:

```text
تم إكمال اليوم الأول من المناسبة.
الجلسة القادمة: الجمعة 11 سبتمبر، 5:00 م.
```

Do not navigate to review.

After final session completion:

- parent becomes completed
- normal completed UI appears
- review CTA is enabled

## 19. Time Extension UI

Extension belongs to active session.

Show:

```text
اليوم الحالي
الوقت الحالي
المدة الإضافية
التكلفة الإضافية
الإجمالي الجديد لهذا اليوم
```

After success:

- update only session duration/pricing
- refresh aggregate parent price
- keep other session times unchanged

## 20. Cancellation UX

### Before workers accept

User can edit/remove dates according to backend rules.

### After workers accept

Direct editing is blocked in Phase 1.

Show a clear message:

```text
لا يمكن تعديل أيام المناسبة بعد قبول العامل للطلب. يمكنك إلغاء الأيام القادمة حسب سياسة الإلغاء.
```

### Partial cancellation

When cancelling future days:

- list affected dates
- show applicable fee before confirmation
- completed days remain visible
- cancelled days show cancelled state

## 21. Reschedule Screen

Update `cleaning_order_reschedule_screen.dart`.

Behavior matrix:

```text
legacy single-day cleaning -> current behavior
single-day event before acceptance -> current/new session editing
multi-day event before acceptance -> edit sessions
multi-day event after acceptance -> blocked
```

Do not silently convert a multi-day booking back to a single date.

## 22. Realtime Updates

Listen for session-aware events.

Use:

```text
bookingId
sessionId
sessionSequence
sessionDate
```

Update the matching session model in state.

If parent aggregate data changes materially, refetch booking details after event handling rather than manually reconstructing all totals.

## 23. Notifications Deep Links

Notification payload should deep-link to:

```text
booking details
selected session id when available
```

Examples:

- worker started travel for Session 2
- worker arrived for Session 2
- Session 1 completed
- Session 3 cancelled

The details screen should scroll/highlight the target session.

## 24. UI Components to Extract

Recommended reusable widgets:

```text
ClMultiDaySchedulePicker
ClEventSessionDraftCard
ClEventScheduleSummary
ClBookingSessionsProgress
ClBookingSessionCard
ClNextSessionCard
ClSessionStatusBadge
```

Keep scheduling logic outside large screen widget where possible.

## 25. Bloc / State Management

Avoid one field per session.

Suggested state:

```text
eventSessions
selected/activeSessionId
estimate
create status
schedule validation errors
```

Events:

```text
AddEventSessionDate
RemoveEventSession
UpdateEventSessionTime
ApplyTimeToAllEventSessions
EstimateMultiDayEvent
CreateMultiDayEvent
RefreshCleaningBooking
```

Follow the project's existing Bloc conventions.

## 26. Loading / Error States

Required:

- estimate loading
- create loading
- session action loading only on active card
- full refresh state
- backend validation mapped to session
- network retry
- empty legacy schedule fallback

Avoid blocking every session card when only one session action is in progress.

## 27. Accessibility / RTL / Formatting

- Arabic RTL layout
- English numerals only where project convention requires them
- use existing date/time formatting utilities
- 12-hour display if current app uses it
- API continues using `H:i`
- cards must support long Arabic text
- test small phone widths
- no horizontal overflow

## 28. User App Tests

### Models

- parse multi-day schedule
- parse missing schedule legacy response
- unknown status safe fallback

### Schedule screen

- add multiple dates
- remove date
- chronological sorting
- apply same time to all
- override one session after apply-all
- invalid session shows local error

### API

- estimate serializes sessions
- create serializes sessions
- previous-worker availability sends all sessions
- session actions send booking + session id

### List/details

- card displays count/progress/next session
- details renders sessions in order
- active session highlighted
- non-final completion does not show review
- final completion shows review

### Reschedule/cancel

- edit allowed before acceptance
- edit blocked after acceptance
- future cancellation leaves completed session visible

### Realtime

- event updates matching session
- unrelated session/booking event ignored

## 29. Implementation Order

### Phase A — Models/API

- schedule models
- parsing
- request serialization
- repositories/data sources

### Phase B — Create flow UI

- multi-date selection
- session cards
- apply same time
- validation
- estimate/create

### Phase C — Booking display

- order card
- details
- progress
- next session

### Phase D — Session actions

- confirmation
- extension
- cancellation
- SOS
- realtime

### Phase E — Previous workers / edit

- all-session availability
- reschedule rules
- conflict messages

### Phase F — QA

- regression
- RTL
- small screens
- error states
- mixed backend rollout

## 30. Definition of Done

User app work is complete when:

- customer can select one or many event days
- every day can have its own time/duration
- estimate/create sends one parent booking with sessions
- user can understand total days, hours, workers, and price before submission
- preferred-worker availability checks all days
- booking list shows progress and next session
- details show every session and its independent status
- session actions target the correct session
- non-final day completion does not complete/review the booking
- partial cancellation preserves history
- direct multi-day editing is blocked after worker acceptance
- legacy single-day cleaning/event flows remain functional
