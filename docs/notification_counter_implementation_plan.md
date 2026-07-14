# Notification Counter — Implementation Plan

Use this plan to replicate the **unread notification badge counter** from the Dllni user app in another client (Flutter, React Native, web, etc.) against the same backend.

Related reference: [notifications_read_logic.md](./notifications_read_logic.md)

---

## 1. Goal & UX

| Behavior | Detail |
|----------|--------|
| **What the counter shows** | Total unread notifications for the logged-in user |
| **Where it appears** | Red circular badge on the bell icon in home/app bars |
| **When it updates** | After every successful notifications fetch; reset to `0` after mark-all-read |
| **Typical user flow** | User sees badge → taps bell → list opens → all items marked read in background → badge clears |

The counter is **server-driven** (`countUnread` from the API), not computed locally from the visible list.

---

## 2. Backend API Contract

### 2.1 Fetch notifications (source of truth for counter)

```
GET /api/v1/user/notifications?page=1&perPage=10
Authorization: Bearer {token}
```

**Response fields used by the counter:**

```json
{
  "data": [ /* notification items */ ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 42,
    "countUnread": 3
  },
  "countUnread": 3
}
```

- **`countUnread`** (root or `meta.countUnread`) is the badge value.
- Parse from root first; fall back to `meta.countUnread` if needed.
- Optional filter: `filter[unread]=1` when you only need unread items (not required for the badge).

### 2.2 Mark all as read (clears counter)

```
PATCH /api/v1/user/notifications/read-all
Authorization: Bearer {token}
Body: {}
```

### 2.3 Mark one as read (list item only; badge already cleared on screen open)

```
PATCH /api/v1/user/notifications/{id}/read
Authorization: Bearer {token}
Body: {}
```

### 2.4 Notification item read state

Each item includes `readAt`:

- `readAt` empty/null → unread (`isRead: false`, show accent dot)
- `readAt` non-empty → read (`isRead: true`, hide accent dot)

---

## 3. Architecture (mirror this app)

```
┌─────────────────┐     dispatch      ┌──────────────────┐
│  Home / App Bar │ ────────────────► │  Notifications   │
│  (badge UI)     │ ◄── unreadCount ──│  State Manager   │
└─────────────────┘                   └────────┬─────────┘
                                               │
┌─────────────────┐                          │
│ Notifications   │ ─── same state mgr ──────┤
│ List Screen     │                          │
└─────────────────┘                          ▼
                                    ┌──────────────────┐
                                    │  API Layer         │
                                    │  GET /notifications│
                                    │  PATCH /read-all   │
                                    │  PATCH /{id}/read  │
                                    └──────────────────┘
```

### Recommended state shape

```ts
interface NotificationsState {
  unreadCount: number | null;   // null = not loaded yet; drives badge
  items: NotificationItem[];    // paginated list
  pagination: { page, perPage, total, isEndPage, status };
  markAllReadStatus?: 'idle' | 'loading' | 'success' | 'failed';
  actionError?: string;
}
```

In this app the field is `ProfileState.unreadNotification` inside `ProfileBloc`.

---

## 4. Core Events / Actions

Implement these three actions (names are illustrative):

| Action | When to call | Side effects on counter |
|--------|--------------|-------------------------|
| `fetchNotifications` | App/home open, pull-to-refresh, pagination | Set `unreadCount = response.countUnread` |
| `markAllNotificationsRead` | After fetch when opening notifications screen | Set `unreadCount = 0` on success |
| `markNotificationRead` | User taps one unread row | **Do not** change counter (mark-all already ran) |

### 4.1 `fetchNotifications`

**Parameters:**

- `page`, `perPage` — pagination
- `isReload` — reset list vs append
- `markAllReadOnSuccess` — **only `true` on the notifications list screen**

**Handler logic:**

1. Call `GET /notifications`.
2. Map items; derive `isRead` from `readAt`.
3. Update pagination + **`unreadCount = result.countUnread`**.
4. If `markAllReadOnSuccess`:
   ```pseudo
   hasUnread = (countUnread > 0) OR any(item.isRead == false)
   if hasUnread:
     dispatch markAllNotificationsRead(silent: true)
   ```

### 4.2 `markAllNotificationsRead`

**Two modes:**

| Mode | Trigger | UI behavior | On failure |
|------|---------|-------------|------------|
| **Silent** | Auto after opening notifications list | No spinner; no error toast | Swallow error; counter refreshes on next fetch |
| **Explicit** | Manual "mark all read" button (if you add one) | Show loading; optimistic `unreadCount = 0` | Show error; revert loading state |

**On success (both modes):**

- Set every loaded item to `isRead: true`
- Set **`unreadCount = 0`**

### 4.3 `markNotificationRead`

- Call `PATCH /{id}/read`
- Update only that item in the local list
- **Do not decrement `unreadCount`** — this app clears the badge when the list opens, not per tap

---

## 5. Where to Trigger Fetches

| Screen / moment | Event | `markAllReadOnSuccess` |
|-----------------|-------|------------------------|
| Main home (authenticated) | `fetchNotifications(page: 1, isReload: true)` | `false` |
| Home app bar init (optional duplicate) | Same as above | `false` |
| Notifications screen `initState` | `fetchNotifications(page: 1, isReload: true)` | **`true`** |
| Pull-to-refresh on list | Same | **`true`** |
| Infinite scroll (load more) | `fetchNotifications(loadMore: true)` | **`true`** |
| After login | Fetch page 1 | `false` |
| After logout | Clear `unreadCount` to `null` or `0` | — |

**Important:** Use a **single shared state instance** (singleton bloc/store) so the badge and list stay in sync when navigating between home and notifications.

---

## 6. Badge UI Rules

Show the badge when **all** are true:

1. User is authenticated
2. `unreadCount != null`
3. `unreadCount > 0`

Display:

- Position: top-right of bell icon (stack/overlay)
- Content: numeric string of `unreadCount`
- Hide completely when count is 0 or null

Example from this app (`sm_home/view/widgets/home_app_bar.dart`):

```dart
if (state.unreadNotification != null && state.unreadNotification! > 0)
  // render badge with state.unreadNotification.toString()
```

Restaurant home also gates on `AuthGate.isAuthenticated`.

---

## 7. End-to-End Sequence

### 7.1 User opens app (has 3 unread)

```
Home init (authenticated)
  → GET /notifications?page=1
  → unreadCount = 3
  → badge shows "3"
```

### 7.2 User opens notifications screen

```
Notifications init
  → GET /notifications?page=1&markAllReadOnSuccess=true
  → unreadCount = 3 (from response)
  → hasUnread → PATCH /read-all (silent)
  → on success: unreadCount = 0, all items isRead=true
  → badge hidden on home when user navigates back
```

### 7.3 User taps one notification row

```
if item not read:
  → PATCH /notifications/{id}/read
  → update that item locally
  → navigate via deep link payload (module + data)
(unreadCount unchanged — already 0)
```

---

## 8. Implementation Checklist (another app)

### Phase A — Data layer

- [ ] HTTP client with auth header (Bearer token)
- [ ] `fetchNotifications(page, perPage, unreadOnly?)` → parse `countUnread` + items
- [ ] `markAllNotificationsRead()` → `PATCH .../read-all`
- [ ] `markNotificationRead(id)` → `PATCH .../{id}/read`
- [ ] Map `readAt` → `isRead` boolean

### Phase B — State layer

- [ ] Add `unreadCount: number | null` to global/session state
- [ ] Implement `fetchNotifications` with pagination
- [ ] Implement conditional auto `markAllReadOnSuccess` chain
- [ ] Implement silent vs explicit mark-all
- [ ] Clear state on logout

### Phase C — UI layer

- [ ] Bell icon with badge component (reusable)
- [ ] Wire badge to `unreadCount`
- [ ] Auth gate before opening notifications
- [ ] Notifications list with pull-to-refresh + infinite scroll
- [ ] Unread accent dot per row (`!isRead`)
- [ ] SnackBar/toast for explicit read errors only

### Phase D — Integration

- [ ] Fetch counter on home mount when logged in
- [ ] Pass shared state manager into notifications route
- [ ] Re-fetch counter after login
- [ ] (Recommended) Re-fetch counter when push notification received while app is foregrounded

### Phase E — QA scenarios

- [ ] Fresh login with 0 unread → no badge
- [ ] Fresh login with N unread → badge shows N
- [ ] Open notifications → badge clears without user action
- [ ] Silent mark-all API failure → badge may still show until next successful fetch (no crash/toast)
- [ ] Logout → badge hidden
- [ ] Pagination does not reset counter incorrectly (always use latest `countUnread` from API)

---

## 9. Differences to Avoid

| Do (this app) | Don't |
|---------------|-------|
| Use `countUnread` from API for badge | Count unread rows only in the current page |
| Mark all read when list opens | Decrement badge one-by-one on row tap |
| Share one state manager across screens | Create a new store per screen |
| Silent failure for background mark-all | Show error toast for silent mark-all |
| Fetch on home open without mark-all | Call `read-all` on every home fetch |

---

## 10. Optional Enhancements (not in current app)

These are **not required** to match current behavior but improve real-time accuracy:

1. **Push / FCM handler** — on foreground message, dispatch `fetchNotifications(page: 1)` to refresh `countUnread`.
2. **WebSocket / Pusher** — subscribe to a user notification channel; on `NotificationCreated`, increment locally or re-fetch count.
3. **App resume** — refetch count when app returns from background.
4. **Cap badge display** — show `99+` when count > 99 (UI polish; this app shows raw number).

---

## 11. Reference Files (this repo)

| Concern | File |
|---------|------|
| API calls | `lib/features/profile/data/source/profile_remote_data_source.dart` |
| Response parsing | `lib/features/profile/data/models/profile_api_models.dart` |
| Counter state + logic | `lib/features/profile/view/manager/bloc/profile_bloc.dart` |
| Events | `lib/features/profile/view/manager/bloc/profile_event.dart` |
| State field | `lib/features/profile/view/manager/bloc/profile_state.dart` |
| List + mark-all trigger | `lib/features/profile/view/screens/notifications_screen.dart` |
| Badge UI | `lib/features/sm_home/view/widgets/home_app_bar.dart` |
| Home fetch on open | `lib/features/home/view/screens/home_screen.dart` |
| Existing flow doc | `docs/notifications_read_logic.md` |

---

## 12. Minimal Pseudocode (portable)

```pseudo
function fetchNotifications(page, isReload, markAllReadOnSuccess):
  result = GET /api/v1/user/notifications?page=page&perPage=10
  items = map(result.data)
  state.unreadCount = result.countUnread
  state.items = isReload ? items : state.items + items

  if markAllReadOnSuccess:
    hasUnread = (result.countUnread > 0) or any(item => !item.isRead)
    if hasUnread:
      markAllNotificationsRead(silent: true)

function markAllNotificationsRead(silent):
  if !silent:
    state.unreadCount = 0  // optimistic
    state.markAllReadStatus = loading

  response = PATCH /api/v1/user/notifications/read-all

  if failure:
    if !silent: showError(response.message)
    return

  state.items = state.items.map(i => ({ ...i, isRead: true }))
  state.unreadCount = 0

function renderBadge():
  if !isAuthenticated: return
  if state.unreadCount == null or state.unreadCount <= 0: return
  showBadge(state.unreadCount)
```

This is the complete logic needed to reproduce the notification counter in another app using the same backend.
