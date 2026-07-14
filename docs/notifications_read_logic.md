# Notifications "Read" Logic

This document describes how notification read state is handled in the user app:
marking a single notification as read, marking all notifications as read, and how
the unread badge count is kept in sync.

## Overview

All notification read logic lives in the **Profile** feature and flows through
`ProfileBloc`. Two independent "read" actions exist:

- **Mark one as read** — when a user taps a single notification.
- **Mark all as read** — triggered automatically when the notifications list is
  opened/refreshed (and also available as an explicit action).

The unread count (`unreadNotification`) drives the red badge shown on the bell
icon in the home app bars.

## Layers involved

| Layer | File | Responsibility |
|-------|------|----------------|
| UI (list) | `lib/features/profile/view/screens/notifications_screen.dart` | Dispatches fetch + read events, renders grouped list |
| UI (badge) | `lib/features/rs_home/.../home_app_bar.dart`, `sm_home`, `cl_main` | Shows unread badge, opens the notifications screen |
| Bloc | `lib/features/profile/view/manager/bloc/profile_bloc.dart` | Handles fetch / mark-read / mark-all-read events, updates state optimistically |
| Events | `lib/features/profile/view/manager/bloc/profile_event.dart` | `FetchNotificationsEvent`, `MarkNotificationReadEvent`, `MarkAllNotificationsReadEvent` |
| State | `lib/features/profile/view/manager/bloc/profile_state.dart` | Holds `notificationsPagination`, `unreadNotification`, `notificationActionError` |
| UseCases | `mark_all_notifications_read_use_case.dart`, `mark_notification_read_use_case.dart`, `fetch_notifications_use_case.dart` | Bridge bloc → repository |
| Repository | `lib/features/profile/data/repository/profile_repo_impl.dart` | Wraps calls with exception handling |
| Data source | `lib/features/profile/data/source/profile_remote_data_source.dart` | Performs the HTTP calls |

## API endpoints

| Action | Method | Endpoint |
|--------|--------|----------|
| Fetch notifications | `GET` | `/api/v1/user/notifications` |
| Mark one read | `PATCH` | `/api/v1/user/notifications/{id}/read` |
| Mark all read | `PATCH` | `/api/v1/user/notifications/read-all` |

The fetch response includes a `countUnread` field that is the source of truth for
the unread badge count.

## State fields

```dart
// profile_state.dart
final PaginationStateModel<FetchNotificationsModelDataItem> notificationsPagination;
final int? unreadNotification;              // drives the badge
final BlocStatus? markAllNotificationsReadStatus;
final String? notificationActionError;      // surfaced as a SnackBar
```

Each list item (`FetchNotificationsModelDataItem`) carries:

- `isRead` — read state (mapped from the backend `readAt` timestamp being non-empty).
- `showTrailingAccent` — the small "unread" accent dot; hidden once read.

## Flow 1 — Mark a single notification as read

Triggered when the user taps a notification row in `NotificationsScreen`:

```dart
// notifications_screen.dart (onTap)
if (id != null && id.isNotEmpty && item.isRead != true) {
  profileBloc.add(MarkNotificationReadEvent(id: id));
}
tryNavigateFromNotificationPayload(context, module: item.module, data: item.data);
```

Handled by `_markNotificationRead`:

1. Trims the id and returns early if empty.
2. Calls `markNotificationReadUseCase` → `PATCH .../{id}/read`.
3. On success, **optimistically** updates only the matching item in the current
   list (`isRead: true`, `showTrailingAccent: false`) and clears any action error.
4. On failure, sets `notificationActionError` (shown as a SnackBar), leaving the
   list unchanged.

Note: This action only mutates the tapped item locally; it does not decrement
`unreadNotification` on its own because the screen already marks everything read
on open (see Flow 2).

## Flow 2 — Mark all notifications as read

There are two variants, distinguished by the `silent` flag on
`MarkAllNotificationsReadEvent`.

### 2a. Automatic (silent) mark-all on open / refresh / load-more

When the notifications screen opens, refreshes, or paginates, it fetches with
`markAllReadOnSuccess: true`:

```dart
// notifications_screen.dart initState / refresh / scroll
FetchNotificationsEvent(
  params: FetchNotificationsParams(),
  isReload: true,
  markAllReadOnSuccess: true,
);
```

Inside `_fetchNotifications`, after a successful fetch:

```dart
if (event.markAllReadOnSuccess) {
  final hasUnread = (result.countUnread ?? 0) > 0 ||
      mapped.any((item) => item.isRead != true);
  if (hasUnread) {
    add(MarkAllNotificationsReadEvent(silent: true));
  }
}
```

So the app dispatches a **silent** mark-all only when there is something unread.

`_markAllNotificationsRead` with `silent: true`:

1. Skips emitting the loading state (no UI spinner for the background action).
2. Calls `markAllNotificationsReadUseCase` → `PATCH .../read-all`.
3. On success, maps **every** item in the current list to `isRead: true`,
   `showTrailingAccent: false`, and sets `unreadNotification: 0`.
4. On failure, silently returns (no error surfaced), since it was a background action.

### 2b. Explicit (non-silent) mark-all

When dispatched with `silent: false` (the default):

1. Immediately emits `markAllNotificationsReadStatus: loading`, clears the action
   error, and optimistically sets `unreadNotification: 0`.
2. Calls the same `read-all` endpoint.
3. On success, marks all list items read and keeps `unreadNotification: 0`.
4. On failure, clears the loading status and sets `notificationActionError`.

## Flow 3 — Unread badge count

The badge on the bell icon reads `state.unreadNotification`:

```dart
// home_app_bar.dart
if (AuthGate.isAuthenticated &&
    state.unreadNotification != null &&
    state.unreadNotification! > 0)
  // ...renders the red badge with state.unreadNotification
```

Badge lifecycle:

- **Populated** on any `FetchNotificationsEvent` success from
  `result.countUnread` (dispatched from home screens/app bars on init and by the
  notifications screen).
- **Reset to 0** whenever a mark-all action runs (silent or explicit).

Because opening the notifications screen fetches with `markAllReadOnSuccess: true`,
the typical UX is: user sees a badge → taps bell → list opens → all notifications
are marked read in the background → badge disappears on the next fetch.

## Error handling

- Single/explicit read failures set `notificationActionError`, which the screen's
  `BlocListener` shows as a `SnackBar`.
- Silent mark-all failures are swallowed (no user-facing error), so a failed
  background sync never interrupts browsing. The badge/read state simply refreshes
  on the next successful fetch.

## Sequence (open notifications screen)

```
User taps bell
  -> pushRoute('/notifications', NotificationsScreenParams(profileBloc))
  -> initState: FetchNotificationsEvent(isReload, markAllReadOnSuccess: true)
     -> _fetchNotifications
        -> GET /notifications  (sets list + unreadNotification = countUnread)
        -> if hasUnread: add MarkAllNotificationsReadEvent(silent: true)
           -> _markAllNotificationsRead(silent)
              -> PATCH /notifications/read-all
              -> on success: all items isRead = true, unreadNotification = 0
User taps a row
  -> MarkNotificationReadEvent(id)  (only if not already read)
     -> PATCH /notifications/{id}/read
     -> on success: that item isRead = true
  -> tryNavigateFromNotificationPayload(...)  (deep link into the target)
```
