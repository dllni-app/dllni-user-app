# Backend: deep links and API URLs

This document describes what the **backend / DevOps** team should implement so that:

1. **App Links / Universal Links** open the mobile app when users tap shared URLs on Android and iOS.
2. **Opening a product (or other) URL in a browser** does not show raw JSON when the URL is the same path as a JSON API route.

The Flutter app already maps these paths in-app; the server must behave correctly for **browsers** and for **domain verification**.

---

## 1. Problem: `GET /api/v1/user/products/{id}` returns JSON in Chrome

When a user opens `https://dllni.mustafafares.com/api/v1/user/products/7` in a **browser**, the client performs a normal HTTP `GET`. Your API correctly returns **JSON**. That is expected unless you add special handling.

**Goal:** For the **same URL** (or for a dedicated public URL), users who open the link in a **browser** should get a **redirect**, an **HTML landing page** (“Open in app”), or similar—not raw JSON—while **API clients** (mobile app with `Accept: application/json`, auth headers) keep receiving JSON.

### Recommended approaches (pick one)

### Option A — Content negotiation (preferred)

For routes such as:

- `GET /api/v1/user/products/{id}`
- (and any other path you expose as both **API** and **deep link**)

Implement logic like:

- If the request has `Accept: application/json` (and/or your API auth is present), return **JSON** as today.
- If `Accept` is missing, is `*/*`, or includes `text/html` (typical browser), respond with:
  - **302 Found** to a **non-API** URL, e.g. `https://dllni.mustafafares.com/product/{id}` (matches the `shareUrl` field your API already returns in some payloads), **or**
  - **200** with a minimal HTML page that offers “Open in app” (intent / store links).

**Important:** Automated tests and non-browser API clients must still receive JSON when they send the correct `Accept` and credentials.

**Mobile app:** The user app’s HTTP client (`common_package` Dio) sets **`Accept: application/json`** on API requests. Treat **`Accept` containing `application/json`** (or authenticated API requests) as **JSON** responses; use HTML redirect or landing page when `Accept` is missing or prefers `text/html` (typical browser address bar).

### Option B — Separate public paths only

- Keep **all** JSON under strict API rules (`Accept`, `Authorization`).
- Never use pure API paths as the **only** user-facing share link; use paths like `/product/{id}` for marketing (your API already returns `shareUrl` in some responses).

Browsers hitting `/product/{id}` should be handled by the **web** stack (static page, SPA fallback, or redirect)—not by returning API JSON.

### Option C — Nginx / reverse proxy (use with care)

- Redirect browser `User-Agent` from `/api/v1/user/products/` to `/product/…`  
  **Risk:** can break monitoring, curl without headers, or mis-detect clients. Prefer **Option A** in the application layer.

---

## 2. Deep link resolver: `POST /api/v1/deep-links/resolve`

The app sends the **full HTTPS URL** (including `https://dllni.mustafafares.com/api/v1/user/...` shapes) in the request body.

**Backend should:**

- Accept those URLs as **canonical** deep link forms.
- Return `canonical_url`, `type`, `target`, `status`, etc., consistent with your API contract so the app can map to the correct screen (product, restaurant, vote, group order, …).

Coordinate with the mobile team if you change `type` / `target` enums.

---

## 3. Android App Links — `assetlinks.json`

For **verified** App Links (tap link → open app instead of Chrome):

1. Host the file at:

   `https://dllni.mustafafares.com/.well-known/assetlinks.json`

2. Include your Android app **package name** and **SHA-256** signing certificate fingerprint(s) per [Google’s documentation](https://developer.android.com/training/app-links/verify-android-applinks).

3. If you use **`www.dllni.mustafafares.com`**, duplicate the file (or redirect) so verification works for both hosts.

4. After deployment, verify with:

   `https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://dllni.mustafafares.com&relation=delegate_permission/common.handle_all_urls`

The app’s `AndroidManifest.xml` already declares `pathPrefix` entries for paths such as `/api/v1/user/products/`, `/product/`, `/api/v1/user/restaurants/`, etc. The **digital asset links** file must match the **package + cert** of the published APK/AAB.

---

## 4. iOS Universal Links — `apple-app-site-association`

1. Serve **AASA** at:

   `https://dllni.mustafafares.com/.well-known/apple-app-site-association`  
   (no `.json` extension; `application/json` content type is common.)

2. Include your **Team ID** + **bundle ID** and the **paths** your app should handle (or use wildcards per Apple rules).

3. The iOS app entitlements list **associated domains** (e.g. `applinks:dllni.mustafafares.com`). Paths are defined in AASA, not only in the app.

---

## 5. Optional: CORS and crawlers

If you add an HTML fallback page, ensure CORS and caching headers do not break your API. Search-engine indexing of `/api/...` is usually undesirable; use `noindex` on HTML fallbacks if needed.

---

## 6. Checklist

| Task | Owner |
|------|--------|
| Browser GET on API product URL does not show raw JSON (negotiation or redirect) | Backend |
| `POST /api/v1/deep-links/resolve` accepts API-shaped HTTPS URLs | Backend |
| `assetlinks.json` deployed and verified | DevOps |
| `apple-app-site-association` deployed | DevOps |
| Same host / `www` policy documented | DevOps |

---

## 7. Verification log (Flutter repo, production host)

Checked from the development machine (not a substitute for Play Console / Apple’s CDN checks):

| Resource | URL | Result (as of check) |
|----------|-----|----------------------|
| Digital Asset Links | [Google statement lookup](https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://dllni.mustafafares.com&relation=delegate_permission/common.handle_all_urls) | **ERROR_CODE_FETCH_ERROR** — `/.well-known/assetlinks.json` returned **404** |
| `assetlinks.json` | `https://dllni.mustafafares.com/.well-known/assetlinks.json` | **404** — must be deployed for verified App Links |
| AASA | `https://dllni.mustafafares.com/.well-known/apple-app-site-association` | **404** — must be deployed for Universal Links |

**Client repo is ready:** `android/app/src/main/AndroidManifest.xml` uses `android:autoVerify="true"` and the path prefixes listed above; `ios/Runner/Runner.entitlements` includes `applinks:dllni.mustafafares.com` and `applinks:www.dllni.mustafafares.com`. **Hosting** must serve the two well-known files with correct JSON and HTTP status **200**.

---

## Reference: URL shapes the app supports (Flutter)

Shared / incoming paths include (non-exhaustive):

- `/api/v1/user/products/{id}` — restaurant product  
- `/api/v1/user/supermarket/products/{id}` — supermarket product  
- `/api/v1/user/restaurants/{id}` — restaurant  
- `/api/v1/user/supermarket/stores/{id}` — supermarket store  
- `/api/v1/user/restaurants/votes/{id}` — vote  
- `/api/v1/user/restaurants/group-orders/...` — group order  
- Legacy: `/product/{id}`, `/restaurant/{id}`, …  

Exact behavior is implemented in the **dllni-user-app** repository under `lib/core/deeplink/`.
