# How to Implement Deep Linking (Flutter + Laravel)

Step-by-step guide to add **App Links** (Android) and **Universal Links** (iOS) so shared HTTPS URLs open the Flutter app, with Laravel resolving and verifying those links.

This matches the production pattern used in **dllni-user-app** (`lib/core/deeplink/`).

**Canonical host (current):** `alnadha.net`

---

## Overview

```
User taps https://alnadha.net/product/123
        │
        ▼
 OS verifies domain ownership (assetlinks / AASA)
        │
        ▼
 Flutter receives URI via app_links
        │
        ▼
 DeepLinkService → POST /api/v1/deep-links/resolve (Laravel)
        │
        ▼
 Navigate to the correct screen (or login / fallback)
```

| Layer | Responsibility |
|-------|----------------|
| **Flutter** | Listen for URIs, validate host/path, call resolve API, navigate |
| **Laravel** | Resolve URL → type/id/status, optional analytics, browser fallback HTML |
| **DevOps / hosting** | Serve `/.well-known/assetlinks.json` and AASA with HTTP 200 |

---

## Part 1 — Flutter

### 1. Add dependency

```yaml
# pubspec.yaml
dependencies:
  app_links: ^6.4.1
```

```bash
flutter pub get
```

### 2. Configure Android App Links

In `android/app/src/main/AndroidManifest.xml`, on the main activity:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    ...>
    <!-- Launcher intent-filter stays as usual -->

    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>

        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/product/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/restaurant/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/store/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/vote/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/group-order/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/s/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/api/v1/user/"/>
        <data android:scheme="https" android:host="alnadha.net" android:pathPrefix="/api/v1/deep-links/"/>
        <data android:scheme="https" android:host="alnadha.net" android:path="/open"/>
    </intent-filter>
</activity>
```

Notes:

- `android:autoVerify="true"` requires a valid `assetlinks.json` on the server.
- Prefer `singleTop` (or `singleTask`) so warm links reuse one activity.
- Keep path prefixes in sync with what Laravel serves and what the parser accepts.

### 3. Configure iOS Universal Links

**Associated Domains** in `ios/Runner/Runner.entitlements`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:alnadha.net</string>
    <!-- Optional if you also use www: -->
    <!-- <string>applinks:www.alnadha.net</string> -->
</array>
```

Also enable **Associated Domains** for the App ID in Apple Developer / Xcode Signing & Capabilities.

### 4. App config (host / scheme)

```dart
// lib/core/app_config.dart (example)
static const String deepLinkCanonicalScheme = 'https';
static const String deepLinkCanonicalHost = 'alnadha.net';
```

All shared and incoming URLs should use this host.

### 5. Core modules to implement

Recommended layout (same as this repo):

```
lib/core/deeplink/
├── deep_link_service.dart           # Orchestrator (app_links + auth + resolve)
├── deep_link_parser.dart            # Host / path validation
├── deep_link_dispatcher.dart        # type → Navigator routes
├── deep_link_models.dart            # Resolve response models
├── deep_link_remote_data_source.dart# POST resolve + events
├── deep_link_share_targets.dart     # Build share URLs
└── deep_link_fallback_screen.dart   # Error / not found UI
```

#### 5.1 Listen for links

```dart
final appLinks = AppLinks();

// Cold start
final initial = await appLinks.getInitialLink();
if (initial != null) {
  await handleIncomingUri(initial);
}

// Warm / background
appLinks.uriLinkStream.listen(handleIncomingUri);
```

Initialize **after** `navigatorKey` is available (e.g. post-frame in `main.dart`).

#### 5.2 Handle flow

1. Normalize host (`www.` → apex).
2. Reject unsupported hosts/paths (`DeepLinkParser.isSupportedDeepLink`).
3. Deduplicate rapid duplicate taps (e.g. 2s window).
4. Optionally `POST /api/v1/deep-links/events` (`opened`).
5. If auth required and user logged out → store pending URL → go to login → resume after verify.
6. `POST /api/v1/deep-links/resolve` with `{ "url": "<full https url>" }`.
7. On `status: ok` → `DeepLinkDispatcher.dispatch(...)`.
8. On `not_found` / `forbidden` / `expired` / network failure → fallback screen.

#### 5.3 Call resolve API

```dart
// POST /api/v1/deep-links/resolve
await dio.post('/api/v1/deep-links/resolve', data: {'url': url});
```

Expected JSON body (HTTP 200):

```json
{
  "type": "product",
  "id": 123,
  "status": "ok",
  "requires_auth": false,
  "canonical_url": "https://alnadha.net/product/123",
  "target": "restaurant",
  "fallback_url": null
}
```

| Field | Meaning |
|-------|---------|
| `type` | Screen family: `product`, `restaurant`, `store`, `vote`, `group-order`, … |
| `id` / `slug` | Entity identifier |
| `status` | `ok` \| `not_found` \| `forbidden` \| `expired` |
| `requires_auth` | If true, gate behind login |
| `target` | Refinement (e.g. `restaurant` vs `supermarket` product) |
| `canonical_url` | Normalized URL to share / track |

#### 5.4 Build share URLs

```dart
String deepLinkBase() => 'https://alnadha.net';

String productUrl(int id) => '${deepLinkBase()}/product/$id';
String restaurantUrl(int id) => '${deepLinkBase()}/restaurant/$id';
```

Share with `share_plus` (or your existing share helper). Prefer short public paths (`/product/{id}`) over raw API JSON paths when possible.

### 6. Supported URL shapes (Flutter parser)

| Pattern | Example |
|---------|---------|
| Product | `https://alnadha.net/product/123` |
| Restaurant | `https://alnadha.net/restaurant/45` |
| Store | `https://alnadha.net/store/10` |
| Vote | `https://alnadha.net/vote/7` |
| Group order | `https://alnadha.net/group-order/{id\|token}` |
| Short code | `https://alnadha.net/s/abc123` |
| API-shaped | `https://alnadha.net/api/v1/user/products/123` |
| Landing | `https://alnadha.net/open?deep_link=...` |

Optional query params: `utm_source`, `utm_medium`, `utm_campaign`, `source`, `medium`, `campaign`, `sharer_id`.

### 7. Quick device tests

**Android:**

```bash
adb shell am start -a android.intent.action.VIEW -d "https://alnadha.net/product/1"
```

**iOS Simulator:**

```bash
xcrun simctl openurl booted "https://alnadha.net/product/1"
```

More scenarios: [deep_linking_testing_guide.md](./deep_linking_testing_guide.md).

---

## Part 2 — Laravel

### 1. Routes

```php
// routes/api.php
Route::prefix('v1/deep-links')->group(function () {
    Route::post('resolve', [DeepLinkController::class, 'resolve']);
    Route::post('events', [DeepLinkController::class, 'storeEvent']); // optional auth
});
```

Public resolve is fine; events can accept optional bearer token for attribution.

### 2. Resolve endpoint

**Request**

```http
POST /api/v1/deep-links/resolve
Content-Type: application/json
Accept: application/json

{ "url": "https://alnadha.net/product/123" }
```

**Controller sketch**

```php
public function resolve(Request $request)
{
    $validated = $request->validate([
        'url' => ['required', 'url'],
    ]);

    $result = app(DeepLinkResolver::class)->resolve($validated['url']);

    // Always HTTP 200 with business status in body (matches Flutter models)
    return response()->json([
        'type' => $result->type,
        'id' => $result->id,
        'slug' => $result->slug,
        'status' => $result->status, // ok | not_found | forbidden | expired
        'requires_auth' => $result->requiresAuth,
        'canonical_url' => $result->canonicalUrl,
        'fallback_url' => $result->fallbackUrl,
        'target' => $result->target,
        'query' => $result->query,
    ]);
}
```

**Resolver responsibilities**

1. Parse host — only allow your app domains (`alnadha.net`, optional `www`).
2. Map path → entity (product, restaurant, store, vote, group order, short code `/s/{code}`).
3. Load from DB; set `status` accordingly.
4. Set `requires_auth` when the destination needs a logged-in user.
5. Return `target` when one `type` maps to multiple UIs (e.g. restaurant vs supermarket product).
6. Accept both short paths (`/product/1`) and API paths (`/api/v1/user/products/1`).

**Example mapping**

| Incoming path | `type` | `target` |
|---------------|--------|----------|
| `/product/{id}` or `/api/v1/user/products/{id}` | `product` | `restaurant` |
| `/api/v1/user/supermarket/products/{id}` | `product` | `supermarket` |
| `/restaurant/{id}` or `/api/v1/user/restaurants/{id}` | `restaurant` | null |
| `/store/{id}` or `/api/v1/user/supermarket/stores/{id}` | `store` | null |
| `/vote/{id}` | `vote` | null |
| `/group-order/{id\|token}` | `group-order` | null |
| `/s/{code}` | resolved from short-link table | … |

### 3. Analytics events (optional)

```http
POST /api/v1/deep-links/events
{
  "action": "opened",
  "url": "https://alnadha.net/product/123",
  "source": "facebook",
  "medium": "share",
  "campaign": "ramadan",
  "sharer_id": 789,
  "platform": "android"
}
```

Store for dashboards; do not fail the app if this endpoint errors (Flutter treats it as best-effort).

### 4. Browser vs API content negotiation

If the same path can be hit from a browser address bar **and** from the mobile API client:

- `Accept: application/json` (app Dio) → return JSON.
- Browser (`text/html` / missing Accept) → **302** to a marketing/`/open` page or a small “Open in app” HTML page — **not** raw JSON.

Prefer application-layer negotiation over User-Agent hacks. Details: [backend-deep-links.md](./backend-deep-links.md).

### 5. Android — `assetlinks.json`

Host at:

`https://alnadha.net/.well-known/assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "YOUR_ANDROID_APPLICATION_ID",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:...:FF"
      ]
    }
  }
]
```

- Include **debug** and **release** (and Play App Signing) fingerprints if needed.
- Must return **HTTP 200**, `Content-Type: application/json`, no auth redirect.
- If `www` is used, serve the same file (or redirect) for that host.

Verify:

```text
https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://alnadha.net&relation=delegate_permission/common.handle_all_urls
```

Laravel static hosting example (public folder):

```text
public/.well-known/assetlinks.json
```

Or a dedicated route that returns the JSON with correct headers (no cookies forcing login).

### 6. iOS — Apple App Site Association (AASA)

Host at **either**:

- `https://alnadha.net/.well-known/apple-app-site-association`
- or `https://alnadha.net/apple-app-site-association`

No `.json` extension. Prefer `Content-Type: application/json`. HTTPS only; no redirects on the AASA URL itself if possible.

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.your.bundle.id",
        "paths": [
          "/product/*",
          "/restaurant/*",
          "/store/*",
          "/vote/*",
          "/group-order/*",
          "/s/*",
          "/open",
          "/api/v1/user/*",
          "/api/v1/deep-links/*"
        ]
      }
    ]
  }
}
```

`TEAMID` = Apple Team ID; bundle ID must match the Flutter iOS app.

### 7. Nginx / Cloudflare tips

- Do not force auth or HTML login on `/.well-known/*`.
- Disable aggressive caching while iterating; then cache with long TTL once stable.
- Ensure `www` and apex both verify if both appear in the app.

---

## End-to-end checklist

### Flutter

- [ ] `app_links` dependency added
- [ ] Android intent-filter with `autoVerify` and correct host/paths
- [ ] iOS Associated Domains entitlement
- [ ] `DeepLinkService.init` wired with `navigatorKey`
- [ ] Parser allows only your host + known prefixes
- [ ] Resolve + dispatch + auth-pending + fallback implemented
- [ ] Share helpers emit canonical HTTPS URLs

### Laravel

- [ ] `POST /api/v1/deep-links/resolve` returns contract above
- [ ] Short codes and API-shaped URLs accepted
- [ ] Optional `POST /api/v1/deep-links/events`
- [ ] Browser GETs do not dump raw JSON for share URLs
- [ ] `assetlinks.json` live and verified
- [ ] AASA live (Team ID + bundle + paths)

### QA

- [ ] Cold start: kill app → open link → correct screen
- [ ] Warm start: background app → open link → navigate
- [ ] Logged-out auth-gated link → login → resume
- [ ] Unknown id → fallback / `not_found`
- [ ] UTM / `sharer_id` preserved when required

---

## Related docs in this repo

| Doc | Use when |
|-----|----------|
| [DEEP_LINKING_DOCUMENTATION_INDEX.md](./DEEP_LINKING_DOCUMENTATION_INDEX.md) | Index of all deep-link docs |
| [deep_linking_quick_reference.md](./deep_linking_quick_reference.md) | One-page orientation |
| [backend-deep-links.md](./backend-deep-links.md) | Backend/DevOps verification details |
| [deep_linking_urls_reference.md](./deep_linking_urls_reference.md) | Full URL + API contract reference |
| [deep_linking_implementation_architecture.md](./deep_linking_implementation_architecture.md) | Flutter internals |
| [deep_linking_testing_guide.md](./deep_linking_testing_guide.md) | Test scenarios |
| [deep_linking_url_generator.html](./deep_linking_url_generator.html) | Generate / QR test links |

**Source:** `lib/core/deeplink/`
