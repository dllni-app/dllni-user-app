# Deep Linking Implementation Architecture

This document provides a detailed technical overview of the deep linking feature implementation in dllni-user-app.

---

## Overview

The deep linking feature enables users to open content directly within the app via URLs, whether from messages, social media, browser, or other sources. The system supports:

- **Cold starts** (app not running)
- **Warm starts** (app in background)
- **Authentication gates** (login-required content)
- **Analytics** (UTM tracking)
- **Fallback handling** (non-existent or restricted content)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     DEEP LINK RECEIVED                          │
│        https://dllni.mustafafares.com/api/v1/user/...          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │     Deep Link Service Init     │
        │  (main.dart - post frame add)  │
        └────────────────┬───────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │    AppLinks Stream Listener    │
        │   (watch incoming URIs)        │
        └────────────────┬───────────────┘
                         │
                         ▼
       ┌─────────────────────────────────┐
       │  handleIncomingUri()            │
       │  ├─ Normalize host              │
       │  ├─ Check if supported          │
       │  ├─ Check for duplicates        │
       │  └─ Extract UTM parameters      │
       └────────────┬────────────────────┘
                    │
                    ▼
       ┌─────────────────────────────────┐
       │  DeepLinkParser Validation      │
       │  ├─ Host check                  │
       │  ├─ Path prefix check           │
       │  └─ www handling                │
       └────────────┬────────────────────┘
                    │
                   ┌─ Unsupported? → Ignore
                    │
                   ┌ Supported? ▼
                    │
       ┌─────────────────────────────────┐
       │  Log Analytics Event            │
       │  POST /api/v1/deep-links/events │
       │  ├─ url                         │
       │  ├─ utm_source, medium, etc.    │
       │  ├─ sharer_id                   │
       │  └─ platform (android/ios)      │
       └────────────┬────────────────────┘
                    │
                    ▼
       ┌─────────────────────────────────┐
       │  Check Authentication           │
       │  (hasAuthToken())               │
       └────────┬──────────────┬──────────┘
                │              │
         Not Logged In    Logged In
                │              │
                ▼              ▼
    ┌──────────────────┐  ┌──────────────┐
    │ Save as Pending  │  │   Proceed    │
    │ & Go to Login    │  │  Directly    │
    └──────────────────┘  └──────┬───────┘
         │                       │
         │  (After login)        │
         │  resumePending()      │
         │       │               │
         └───────┼───────────────┘
                 │
                 ▼
    ┌─────────────────────────────────┐
    │  Attempt Direct Dispatch        │
    │  (try canonical URI routing)    │
    │  ├─ Parse path segments         │
    │  └─ Match to app routes         │
    └────────────┬────────────────────┘
                 │
            ┌────┴────┐
            │          │
        Success?   Failed?
            │          │
            ▼          ▼
      ┌────────┐  ┌──────────────────────┐
      │Navigate│  │Call Resolver API     │
      │Directly│  │POST /api/v1/deep-    │
      │        │  │  links/resolve       │
      └────────┘  │                      │
                  │ Send:                │
                  │  {"url": "..."}      │
                  │                      │
                  │ Receive:             │
                  │  - type              │
                  │  - status            │
                  │  - id                │
                  │  - target            │
                  │  - requires_auth     │
                  │  - fallback_url      │
                  └──────────┬───────────┘
                             │
                   ┌─────────┴─────────┐
                   │                   │
              Status = ok      Status ≠ ok
                   │                   │
                   ▼                   ▼
    ┌───────────────────────┐ ┌──────────────────┐
    │ DeepLinkDispatcher    │ │ Show Fallback    │
    │ ├─ type = product?    │ │ Screen           │
    │ ├─ type = restaurant? │ │ ├─ Message       │
    │ ├─ type = vote?       │ │ ├─ Fallback URL  │
    │ └─ type = group-order?│ │ └─ Error handled │
    │                       │ │  in Arabic       │
    │ Routes:               │ └──────────────────┘
    │  /product             │
    │  /rs_store            │
    │  /votefollowup        │
    │  /group-order/followup│
    └───────────┬───────────┘
                │
                ▼
    ┌─────────────────────────────────┐
    │  Push Named Route with Args     │
    │  nav.pushNamed(                 │
    │    routeName,                   │
    │    arguments: params            │
    │  )                              │
    └────────────┬────────────────────┘
                 │
                 ▼
    ┌─────────────────────────────────┐
    │  Screen Displayed               │
    │  ├─ Product Details             │
    │  ├─ Restaurant Details          │
    │  ├─ Vote Followup               │
    │  └─ Group Order Followup        │
    └─────────────────────────────────┘
```

---

## Core Components

### 1. DeepLinkService (`deep_link_service.dart`)

**Purpose:** Main orchestrator for deep link handling

**Key Responsibilities:**
- Initialize stream listeners
- Route incoming URIs
- Manage pending links
- Coordinate with other components
- Handle navigation retries

**Key Methods:**

```dart
// Initialization
Future<void> init({required GlobalKey<NavigatorState> navigatorKey})

// URI handling
Future<void> handleIncomingUri(Uri uri, {bool isResume = false})

// Pending link management
Future<void> resumePendingIfAny()

// Internal helpers
bool _hasAuthToken()
Map<String, String> _utmFromUri(Uri uri)
int? _sharerIdFromUri(Uri uri)
bool _isDuplicate(String fingerprint)
```

**Architecture Pattern:** Singleton (registered with GetIt/Injectable)

**State Management:**
- `_navigatorKey`: Reference to Material app navigator
- `_uriSub`: Subscription to AppLinks stream
- `_lastFingerprint`: For deduplication
- `_lastAt`: Timestamp for deduplication window
- `_pendingKey`: SharedPreferences key for pending URL

**Deduplication Logic:**
```dart
static const Duration _dedupe = Duration(seconds: 2);

bool _isDuplicate(String fingerprint) {
  final now = DateTime.now();
  if (_lastFingerprint == fingerprint && 
      _lastAt != null && 
      now.difference(_lastAt!) < _dedupe) {
    return true; // Ignore duplicate
  }
  _lastFingerprint = fingerprint;
  _lastAt = now;
  return false;
}
```

---

### 2. DeepLinkParser (`deep_link_parser.dart`)

**Purpose:** Validate and parse incoming deep link URIs

**Key Features:**
- Host validation (canonical host checking)
- Path prefix validation
- Subdomain normalization (www handling)
- Support for multiple URL patterns

**Supported Paths:**

```dart
// API paths (main routes)
/api/v1/user/restaurants/{id}
/api/v1/user/products/{id}
/api/v1/user/supermarket/products/{id}
/api/v1/user/supermarket/stores/{id}
/api/v1/user/restaurants/votes/{id}
/api/v1/user/restaurants/group-orders/{id|token}

// Short links
/s/{shortCode}

// Legacy paths
/restaurant/{id}
/product/{id}
/vote/{id}
/group-order/{id|token}
```

**Key Methods:**

```dart
// Check if host is supported
static String canonicalHost(Uri uri)

// Normalize www subdomain
static Uri normalizeHostIfNeeded(Uri uri)

// Validate entire URI
static bool isSupportedDeepLink(Uri uri)

// Check specific path patterns
static bool _isSupportedApiUserPath(List<String> segments)
static bool _isSupportedLegacyPath(String first)
```

**Host Normalization Logic:**
```dart
static Uri normalizeHostIfNeeded(Uri uri) {
  // Both www.dllni... and dllni... work
  // Converted to canonical: dllni.mustafafares.com
  
  if (canonicalHost(uri) != AppConfig.deepLinkCanonicalHost) {
    return uri; // Different host, don't modify
  }
  
  if (uri.host.toLowerCase() == AppConfig.deepLinkCanonicalHost) {
    return uri; // Already canonical
  }
  
  return uri.replace(host: AppConfig.deepLinkCanonicalHost);
}
```

---

### 3. DeepLinkRemoteDataSource (`deep_link_remote_data_source.dart`)

**Purpose:** Handle API communication for deep link resolution and analytics

**Key Responsibilities:**
- Call resolver API
- Parse resolver responses
- Handle resolver errors
- Log analytics events

**Key Methods:**

```dart
// Resolve deep link via API
Future<DeepLinkResolveResult?> resolve(String url)

// Log analytics event
Future<void> postDeepLinkEvent({
  required String action,
  required String url,
  String? source,
  String? medium,
  String? campaign,
  int? sharerId,
})
```

**Resolver API Contract:**

**Request:**
```json
{
  "url": "https://dllni.mustafafares.com/api/v1/user/restaurants/123"
}
```

**Response (Success):**
```json
{
  "type": "restaurant",
  "id": 123,
  "status": "ok",
  "requires_auth": false,
  "canonical_url": "https://...",
  "fallback_url": "https://...",
  "target": null,
  "slug": null
}
```

**Error Handling:**
- HTTP 422: Invalid URL (parse failure)
- DioException: Network error (returns null)
- Unexpected response: Returns null

---

### 4. DeepLinkDispatcher (`deep_link_dispatcher.dart`)

**Purpose:** Map resolver results and canonical URIs to app routes

**Key Responsibilities:**
- Route based on content type
- Handle content-specific targeting (restaurant vs supermarket)
- Create navigation parameters
- Fallback when API is unavailable

**Two Dispatch Modes:**

#### Mode 1: API-Resolved Dispatch

```dart
static DeepLinkDispatchTarget? dispatch(DeepLinkResolveResult resolved)
```

Takes parsed resolver response and maps to route.

**Type Mapping:**
- `"product"` → `/product` or `/rs_product` (based on target)
- `"restaurant"` → `/rs_store`
- `"vote"` → `/votefollowup`
- `"group-order"` → `/group-order/followup`

**Example:**
```dart
final resolved = DeepLinkResolveResult(
  type: 'restaurant',
  status: DeepLinkResolveStatus.ok,
  id: 123,
  target: null,
);

final target = DeepLinkDispatcher.dispatch(resolved);
// Returns: DeepLinkDispatchTarget(
//   routeName: '/rs_store',
//   arguments: StoreDetailsScreenParams(restaurantId: 123, ...)
// )
```

#### Mode 2: Direct URI Dispatch (API Fallback)

```dart
static DeepLinkDispatchTarget? dispatchFromCanonicalUri(Uri uri)
```

When resolver API is down, parses canonical URI path directly.

**Example:**
```dart
final uri = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/123');
final target = DeepLinkDispatcher.dispatchFromCanonicalUri(uri);
// Returns same result as Mode 1
```

**Synthetic Result Creation:**

For fallback mode, creates synthetic `DeepLinkResolveResult`:
```dart
static DeepLinkResolveResult _synthetic({
  required String type,
  required int id,
  String? target,
}) {
  return DeepLinkResolveResult(
    type: type,
    status: DeepLinkResolveStatus.ok,
    requiresAuth: false,
    id: id,
    // ... other fields with defaults
  );
}
```

---

### 5. Deep Link Models (`deep_link_models.dart`)

**Purpose:** Define data structures for deep link flows

**Core Classes:**

#### DeepLinkResolveStatus (Enum)

```dart
enum DeepLinkResolveStatus {
  ok,           // Content found and accessible
  notFound,     // Content doesn't exist
  forbidden,    // Access denied (auth required or no permission)
  expired,      // Content is no longer available
  unknown,      // Unexpected status
}
```

**Parsing from String:**
```dart
DeepLinkResolveStatus deepLinkResolveStatusFromString(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'ok': return DeepLinkResolveStatus.ok;
    case 'not_found': return DeepLinkResolveStatus.notFound;
    case 'forbidden': return DeepLinkResolveStatus.forbidden;
    case 'expired': return DeepLinkResolveStatus.expired;
    default: return DeepLinkResolveStatus.unknown;
  }
}
```

#### DeepLinkResolveResult (Data Class)

```dart
class DeepLinkResolveResult {
  final String type;              // content type: product, restaurant, etc.
  final int? id;                  // content ID
  final String? slug;             // optional slug
  final DeepLinkResolveStatus status;
  final bool requiresAuth;        // needs authentication
  final String? canonicalUrl;     // canonical HTTPS URL
  final String? fallbackUrl;      // fallback browser URL
  final String? target;           // refinement: restaurant/supermarket
  final Map<String, dynamic>? raw; // raw API response
}
```

**Factory Constructor:**
```dart
factory DeepLinkResolveResult.fromJson(Map<String, dynamic> json) {
  // Handles:
  // - ID parsing (int, num, string)
  // - snake_case and camelCase fields
  // - Type coercion for booleans
  // - Field validation
}
```

#### DeepLinkDispatchTarget (Result Class)

```dart
class DeepLinkDispatchTarget {
  final String routeName;         // app route name
  final Object? arguments;        // strongly-typed route arguments
}
```

---

### 6. Share Targets Helper (`deep_link_share_targets.dart`)

**Purpose:** Generate deep link URLs for sharing content from app

**Key Functions:**

```dart
String deepLinkBase()
String deepLinkUserApiRoot()

String restaurantUrl(int id)
String restaurantProductUrl(int id)
String supermarketProductUrl(int id)
String supermarketStoreUrl(int id)
String voteUrl(int id)
String groupOrderUrl({int? id, String? shareToken})

Future<void> shareDeepLinkUrl(String url, {String? subject, BuildContext? context})
```

**Usage Example:**

```dart
// Generate shareable link
final url = restaurantUrl(123);
// → https://dllni.mustafafares.com/api/v1/user/restaurants/123

// Share with system sheet
await shareDeepLinkUrl(
  url,
  subject: 'Check out this restaurant!',
  context: context,
);
```

---

### 7. Fallback Screen (`deep_link_fallback_screen.dart`)

**Purpose:** Display when deep link cannot be opened

**Features:**
- Arabic error messages
- Optional fallback URL button
- Graceful error handling
- External browser launch capability

**Screen Structure:**
```
┌─────────────────────────┐
│  رابط غير متاح (Header)│
├─────────────────────────┤
│                         │
│  [Error Message]        │
│  (في وسط الشاشة)       │
│                         │
│  [Open in Browser] btn  │
│  (إن توفر fallback_url) │
│                         │
└─────────────────────────┘
```

**Error Messages (Arabic):**

| Status | Message |
|--------|---------|
| `not_found` | المحتوى غير متاح حالياً |
| `forbidden` | لا يمكنك الوصول إلى هذا المحتوى |
| `expired` | انتهت صلاحية هذا الرابط |
| Generic | تعذر فتح هذا الرابط |

---

## Data Flow

### Cold Start Flow

```
1. User taps deep link in browser/message
2. OS routes to app (intent/URL scheme)
3. Flutter initializes
4. main.dart: WidgetsBinding.addPostFrameCallback()
5. DeepLinkService.init() called
6. AppLinks.getInitialLink() retrieves pending URI
7. handleIncomingUri(uri) processes it
8. Rest of flow follows...
```

### Warm Start Flow

```
1. App already running in background
2. User taps deep link
3. AppLinks stream emits new URI
4. AppLinks.uriLinkStream.listen() triggers
5. SchedulerBinding.addPostFrameCallback() defers
6. handleIncomingUri(uri) processes it
7. Navigation happens
```

### Auth-Gated Flow

```
1. handleIncomingUri() called
2. Check _hasAuthToken()
3. If not logged in:
   a. Save URL to SharedPreferences (_pendingKey)
   b. Navigate to LoginScreen
4. User enters credentials
5. Auth success callback:
   a. Token saved
   b. resumePendingIfAny() called
   c. Saved URL processed
6. Navigate to target screen
```

### Deduplication Window

```
Time: 0s
  → URI received: /restaurant/1
  → _lastFingerprint = req1|url
  → _lastAt = now

Time: 0.5s
  → URI received: /restaurant/1 (same)
  → _isDuplicate() check
  → Now - LastAt = 0.5s < 2s
  → Return true (duplicate)
  → Ignore this URI

Time: 3s
  → URI received: /restaurant/1 (same)
  → _isDuplicate() check
  → Now - LastAt = 3s > 2s
  → Return false (not duplicate)
  → Process this URI
```

---

## Integration Points

### 1. App Initialization (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapApp();
  runApp(const MyApp());
}

void _bootstrapApp() {
  // ... setup DI, etc ...
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(getIt<DeepLinkService>().init(
      navigatorKey: navigatorKey,
    ));
  });
}
```

### 2. Application Root (`app.dart`)

```dart
MaterialApp(
  navigatorKey: navigatorKey,
  onGenerateRoute: GeneratedAppRoutes.onGenerateRoute,
  // ... other config ...
)
```

### 3. Authentication Flow (`login_screen.dart`)

```dart
// After successful token save
await SharedPreferencesHelper.saveData(
  key: 'token',
  value: token,
);

// Resume any pending deep link
await getIt<DeepLinkService>().resumePendingIfAny();
```

### 4. DI Registration (`service_locator.dart`)

```dart
@lazySingleton
DeepLinkService deepLinkService(
  DeepLinkRemoteDataSource remoteDataSource,
) => DeepLinkService(remoteDataSource);

@lazySingleton
DeepLinkRemoteDataSource deepLinkRemoteDataSource(
  DioNetwork dioNetwork,
) => DeepLinkRemoteDataSource(dioNetwork: dioNetwork);
```

---

## Error Handling Strategy

### Network Errors

```
Scenario: DeepLinkRemoteDataSource resolver call fails
├─ DioException caught
├─ Check status code:
│  ├─ 422 → Malformed URL (log & return null)
│  ├─ 5xx → Server error (log & fallback)
│  └─ Other → Network error (log & fallback)
└─ Return null
```

### Dispatch Errors

```
Scenario: Deep link cannot be routed to any screen
├─ Both API resolver & direct dispatch fail
├─ Show DeepLinkFallbackScreen
└─ Include fallback_url if available for browser fallback
```

### Navigation Errors

```
Scenario: Push named route fails
├─ Route not registered in app_routes.g.dart
├─ Invalid arguments type
├─ Navigator unavailable
└─ Retry with exponential backoff
```

---

## Analytics Integration

### Event: link_received

**Fired When:** Deep link is received and processed

**Event Data:**
```json
{
  "action": "link_received",
  "url": "https://dllni.mustafafares.com/api/v1/user/restaurants/1?utm_source=facebook&sharer_id=456",
  "source": "facebook",
  "medium": "share",
  "campaign": "summer_promo",
  "sharer_id": "456",
  "platform": "android",
  "timestamp": "2026-04-25T10:30:00Z"
}
```

**Endpoint:** `POST /api/v1/deep-links/events`

**Tracking Uses:**
- Attribution: Track which social platform drives traffic
- Sharing analytics: Identify influencers (sharer_id)
- Campaign performance: UTM parameters
- Platform metrics: Android vs iOS distribution

---

## Configuration

### AppConfig (`core/app_config.dart`)

```dart
class AppConfig {
  static const String appName = 'My App';
  static const String orgIdentifier = 'com.dllni.userapp';
  static const String baseUrl = 'https://alnadha.net';
  
  // Canonical host for deep links (same as API host)
  static const String deepLinkCanonicalHost = 'dllni.mustafafares.com';
}
```

### Resolver API Endpoint

Set in `common_package/lib/network/dio_network.dart`:
```
POST {baseUrl}/api/v1/deep-links/resolve
```

### Events API Endpoint

Set in `common_package/lib/network/dio_network.dart`:
```
POST {baseUrl}/api/v1/deep-links/events
```

---

## Platform-Specific Configuration

### Android

**AndroidManifest.xml** (auto-generated from `android_app_links` package):
- Intent filters with pathPrefix entries
- `android:autoVerify="true"` for verification
- assetlinks.json deployment on backend

**Build Configuration:**
- App signing certificate must match assetlinks.json
- SHA-256 fingerprint verification

### iOS

**Runner.entitlements**:
- Associated domains capability
- Configured for apex and www subdomains

**AASA File** (.well-known/apple-app-site-association):
- Defines hosting app auth and path handling
- Deployed on same domain

---

## Performance Considerations

### Lazy Initialization

- DeepLinkService registered as `@lazySingleton`
- Initialized after first frame to avoid blocking
- Stream subscription created on-demand

### Deduplication Window

- 2-second window prevents duplicate navigation
- Fingerprint comparison is O(1)
- Minimal memory footprint

### API Optimization

- Resolver API called only when direct dispatch fails
- Early return for unsupported paths
- Caching could be added for frequently-accessed short links

---

## Security Considerations

### URL Validation

- Only canonical host is processed
- Path prefixes must match whitelist
- Malformed URLs handled gracefully

### Authentication

- Protected content requires valid auth token
- Pending links stored in SharedPreferences
- Auth token cleared on logout

### API Communication

- HTTPS only (enforced by config)
- Accept: application/json header
- Standard OAuth/token auth (from common_package)

### XSS Prevention

- URLs properly encoded (especially for share tokens)
- No eval or dynamic code execution
- Safe URI parsing using Dart Uri class

---

## Testing Strategy

See `deep_linking_testing_guide.md` for comprehensive testing procedures including:
- Unit tests for parser and dispatcher
- Integration tests for service flows
- Widget tests for fallback screen
- E2E/manual testing scenarios

---

## References

- **Initialization:** `lib/main.dart`
- **Service:** `lib/core/deeplink/deep_link_service.dart`
- **Parser:** `lib/core/deeplink/deep_link_parser.dart`
- **Dispatcher:** `lib/core/deeplink/deep_link_dispatcher.dart`
- **Models:** `lib/core/deeplink/deep_link_models.dart`
- **API:** `lib/core/deeplink/deep_link_remote_data_source.dart`
- **Helpers:** `lib/core/deeplink/deep_link_share_targets.dart`
- **Fallback UI:** `lib/core/deeplink/deep_link_fallback_screen.dart`
- **Backend:** `docs/backend-deep-links.md`
- **Testing:** `docs/deep_linking_testing_guide.md`
- **URLs Reference:** `docs/deep_linking_urls_reference.md`

