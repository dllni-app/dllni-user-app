# Laravel Backend Request: Fix Deep Linking

Date: April 28, 2026

## 1) Current Mobile Status

Deep-linking implementation in the Flutter app is ready:

- Core deep-link tests: `flutter test test/core/deeplink` -> **PASS** (39 tests)
- Static analysis: `flutter analyze lib/core/deeplink` -> **PASS**

So the current blocker is backend/web behavior.

## 2) Live Checks Executed (HTTP)

### Canonical host currently used by app config: `alnadha.net`

Observed responses:

- `GET https://alnadha.net/product/1` -> `302` to `https://app.dllni.com/not-found?reason=not_found`
- `GET https://alnadha.net/restaurant/1` -> `302` to `https://app.dllni.com/not-found?reason=not_found`
- `GET https://alnadha.net/store/1` -> `302` to `https://app.dllni.com/not-found?reason=not_found`
- `GET https://alnadha.net/vote/1` -> `302` to `https://app.dllni.com/not-found?reason=not_found`
- `GET https://alnadha.net/group-order/1` -> `302` to `https://app.dllni.com/not-found?reason=not_found`
- `GET https://alnadha.net/api/v1/deep-links/product/1` -> `404`
- `GET https://alnadha.net/open?deep_link=https%3A%2F%2Falnadha.net%2Fproduct%2F1` -> `404`
- `POST https://alnadha.net/api/v1/deep-links/resolve` -> `302` redirect to home (expected JSON 200)
- `POST https://alnadha.net/api/v1/deep-links/events` -> `302` redirect to home (expected JSON 200)

### Old host still active in old flow: `dllni.mustafafares.com`

Observed responses:

- `GET https://dllni.mustafafares.com/product/1` -> `302` to `/open?deep_link=...&store_url=...`
- `GET https://dllni.mustafafares.com/api/v1/deep-links/product/1` -> same `302` to `/open?...`
- `GET https://dllni.mustafafares.com/open?deep_link=...` -> `404`
- `POST https://dllni.mustafafares.com/api/v1/deep-links/resolve` -> `302` redirect to home (expected JSON 200)
- `POST https://dllni.mustafafares.com/api/v1/deep-links/events` -> `302` redirect to home (expected JSON 200)

## 3) Required Laravel Changes

## A. Implement/repair these API routes (public; no redirect to homepage)

1. `POST /api/v1/deep-links/resolve`
2. `POST /api/v1/deep-links/events`

These must return JSON responses and must not issue `302` redirects.

### Resolve endpoint expected behavior

- Input:
```json
{
  "url": "https://<canonical-host>/product/123"
}
```

- Success response example (`200`):
```json
{
  "type": "product",
  "id": 123,
  "slug": null,
  "status": "ok",
  "requires_auth": false,
  "canonical_url": "https://<canonical-host>/product/123",
  "fallback_url": "https://<canonical-host>/open",
  "query": {
    "source": "whatsapp"
  }
}
```

- Business statuses in body: `ok | not_found | forbidden | expired`
- Validation error: `422`

### Events endpoint expected behavior

- Accepted actions (mobile now sends exactly these):
  - `click`
  - `resolve`
  - `open`

- Input example:
```json
{
  "action": "click",
  "url": "https://<canonical-host>/product/123",
  "source": "whatsapp",
  "medium": "social",
  "campaign": "eid-share",
  "sharer_id": 17,
  "platform": "android"
}
```

- Success response:
```json
{
  "status": "ok"
}
```

## B. Implement/repair open endpoints and landing route

1. `GET /api/v1/deep-links/{type}/{identifier}` must return `302` redirect (not 404).
2. `GET /open` route must exist and be functional (currently returns `404` on both hosts tested).

Expected open behavior:

- If resolved status is `ok`:
  - redirect to `DEEP_LINK_WEB_LANDING_URL` with:
    - `deep_link={canonical_url}`
    - optional `source`, `medium`, `campaign`, `sharer_id`
    - `store_url={configured_store_landing_url}`
- If status is `not_found|forbidden|expired`:
  - redirect to `DEEP_LINK_INVALID_FALLBACK_URL?reason={status}`

## C. Support canonical shapes + compatibility shapes in resolver

Canonical shapes:

- `/product/{identifier}`
- `/restaurant/{identifier}`
- `/store/{identifier}`
- `/vote/{identifier}`
- `/group-order/{identifier}`

Compatibility shapes to keep during migration:

- `/api/v1/user/products/{id}`
- `/api/v1/user/supermarket/products/{id}`
- `/api/v1/user/supermarket/stores/{id}`
- `/api/v1/user/restaurants/{id-or-slug}`
- `/api/v1/user/restaurants/votes/{id}`
- `/api/v1/user/restaurants/group-orders/{id-or-token}`
- `/s/{code}` (if short links still required)

## D. Pick one canonical host and align infra

The app is currently configured for:

- `scheme`: `https`
- `host`: `alnadha.net`

Backend must confirm canonical host. If backend wants `dllni.mustafafares.com` instead, inform mobile team so app config/native link domains are switched back.

## E. Infrastructure files required for verified app links

Deploy these on the canonical host:

- `https://<host>/.well-known/assetlinks.json`
- `https://<host>/.well-known/apple-app-site-association`

Must match mobile app IDs:

- Android package ID: `com.alnadha.user`
- iOS bundle ID: `com.alnadha.user`

## 4) Laravel Acceptance Criteria

1. `POST /api/v1/deep-links/resolve` returns `200 JSON` (never homepage redirect).
2. `POST /api/v1/deep-links/events` returns `200 JSON {"status":"ok"}` (never homepage redirect).
3. `GET /api/v1/deep-links/product/1` returns `302` to `/open?...` (or configured landing flow).
4. `GET /open?deep_link=...` is not `404`.
5. Canonical URLs above return meaningful statuses (`ok/not_found/forbidden/expired`) instead of always not-found.
6. Invalid links redirect to invalid fallback with `reason`.

## 5) Quick Re-Test Commands (after backend fix)

```bash
curl -i -X POST "https://<host>/api/v1/deep-links/resolve" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://<host>/product/1"}'

curl -i -X POST "https://<host>/api/v1/deep-links/events" \
  -H "Content-Type: application/json" \
  -d '{"action":"click","url":"https://<host>/product/1","platform":"android"}'

curl -I "https://<host>/api/v1/deep-links/product/1"
curl -I "https://<host>/open?deep_link=https%3A%2F%2F<host>%2Fproduct%2F1"
curl -I "https://<host>/product/1"
```

Expected:

- API endpoints -> JSON (`200`)
- Open/deep-link GET endpoints -> redirect flow (`302`), no `404`

## 6) User App Deep-Link Verification (Executed Locally)

Date: April 28, 2026
Project: `dllni-user-app`

Executed:

```bash
flutter test test/core/deeplink
flutter analyze lib/core/deeplink
```

Observed:

- `flutter test test/core/deeplink` -> **PASS** (`39` tests)
- `flutter analyze lib/core/deeplink` -> **PASS** (`No issues found`)

Conclusion:

- User app deep-link parsing/dispatch/share-target logic is green locally.
- Remaining blocker is backend Laravel route/redirect behavior described above.

## 7) Workspace Note for Backend Team

This workspace currently contains Flutter apps and docs only; no Laravel/PHP backend repository is present here.  
Backend fixes in sections **A-E** must be implemented/deployed in the server codebase, then re-tested using the curl checks in section **5**.
