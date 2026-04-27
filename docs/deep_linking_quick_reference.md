# Deep Linking - Quick Reference Guide

A one-page summary of the deep linking feature.

---

## What is Deep Linking?

Deep linking allows users to open specific content in the app via URLs. Examples:
- User opens `https://dllni.mustafafares.com/api/v1/user/restaurants/1` in browser
- App launches and shows restaurant #1 details
- Works whether app is closed (cold start) or in background (warm start)

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/core/deeplink/deep_link_service.dart` | Main orchestrator |
| `lib/core/deeplink/deep_link_parser.dart` | URL validation |
| `lib/core/deeplink/deep_link_dispatcher.dart` | Route mapping |
| `lib/core/deeplink/deep_link_models.dart` | Data structures |
| `lib/core/deeplink/deep_link_remote_data_source.dart` | API calls |
| `lib/core/deeplink/deep_link_fallback_screen.dart` | Error screen |
| `lib/core/deeplink/deep_link_share_targets.dart` | URL generation |
| `lib/main.dart` | Initialization |

---

## Quick Setup

### 1. Initialization (main.dart)
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  unawaited(getIt<DeepLinkService>().init(navigatorKey: navigatorKey));
});
```

### 2. After Login (any auth success handler)
```dart
// Save token
await SharedPreferencesHelper.saveData(key: 'token', value: token);

// Resume pending deep link
await getIt<DeepLinkService>().resumePendingIfAny();
```

### 3. DI Registration (if needed)
```dart
@lazySingleton
DeepLinkService deepLinkService(DeepLinkRemoteDataSource remoteDataSource) =>
    DeepLinkService(remoteDataSource);
```

---

## Supported URL Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Restaurant | `/api/v1/user/restaurants/{id}` | `/api/v1/user/restaurants/1` |
| Restaurant Product | `/api/v1/user/products/{id}` | `/api/v1/user/products/123` |
| Supermarket Product | `/api/v1/user/supermarket/products/{id}` | `/api/v1/user/supermarket/products/456` |
| Supermarket Store | `/api/v1/user/supermarket/stores/{id}` | `/api/v1/user/supermarket/stores/789` |
| Vote | `/api/v1/user/restaurants/votes/{id}` | `/api/v1/user/restaurants/votes/1` |
| Group Order (ID) | `/api/v1/user/restaurants/group-orders/{id}` | `/api/v1/user/restaurants/group-orders/999` |
| Group Order (Token) | `/api/v1/user/restaurants/group-orders/{token}` | `/api/v1/user/restaurants/group-orders/abc123` |
| Short Link | `/s/{code}` | `/s/abc123` |
| Legacy Restaurant | `/restaurant/{id}` | `/restaurant/1` |
| Legacy Product | `/product/{id}` | `/product/123` |

---

## Query Parameters

### UTM Parameters (Analytics)
```
?utm_source=facebook&utm_medium=share&utm_campaign=summer_promo
```

### Sharer ID
```
?sharer_id=456
```

### Full Example
```
https://dllni.mustafafares.com/api/v1/user/restaurants/1?utm_source=facebook&utm_campaign=special_offer&sharer_id=123
```

---

## Generate Shareable Links

```dart
// Using helper functions from deep_link_share_targets.dart

// Restaurant
String url = restaurantUrl(1);

// Product
String url = restaurantProductUrl(123);
String url = supermarketProductUrl(456);

// Supermarket store
String url = supermarketStoreUrl(789);

// Vote
String url = voteUrl(1);

// Group order
String url = groupOrderUrl(id: 999);
String url = groupOrderUrl(shareToken: 'abc123xyz');

// Share with system sheet
await shareDeepLinkUrl(url, subject: 'Check this out!', context: context);
```

---

## Testing

### Simple Manual Test (Android)
```bash
adb shell am start -a android.intent.action.VIEW -d "https://dllni.mustafafares.com/api/v1/user/restaurants/1"
```

### Simple Manual Test (iOS)
```bash
xcrun simctl openurl booted "https://dllni.mustafafares.com/api/v1/user/restaurants/1"
```

### Using HTML Form
- Open `docs/deep_linking_url_generator.html` in browser
- Generate URLs and scan QR codes

---

## Resolver API Contract

### Request
```json
POST /api/v1/deep-links/resolve
{
  "url": "https://dllni.mustafafares.com/api/v1/user/restaurants/123"
}
```

### Response (Success)
```json
{
  "type": "restaurant",
  "id": 123,
  "status": "ok",
  "requires_auth": false,
  "canonical_url": "https://dllni.mustafafares.com/api/v1/user/restaurants/123",
  "fallback_url": "https://dllni.mustafafares.com/restaurant/123",
  "target": null,
  "slug": null
}
```

### Response (Error)
```json
{
  "type": "restaurant",
  "status": "not_found",
  "requires_auth": false,
  "message": "Restaurant not found"
}
```

### Status Values
| Value | Meaning | Action |
|-------|---------|--------|
| `ok` | Content found | Navigate to screen |
| `not_found` | Doesn't exist | Show fallback screen |
| `forbidden` | No access | Show auth gate or fallback |
| `expired` | No longer available | Show fallback screen |

---

## Navigation Routes

| Type | Route | Screen |
|------|-------|--------|
| Restaurant Product (Restaurant) | `/rs_product` | Restaurant Product Details |
| Restaurant Product (Supermarket) | `/product` | Supermarket Product Details |
| Restaurant Store | `/rs_store` | Restaurant Store Details |
| Supermarket Store | N/A | Supermarket Store Details |
| Vote | `/votefollowup` | Vote Followup Screen |
| Group Order | `/group-order/followup` | Group Order Followup |

---

## Common Flows

### Cold Start (App Not Running)
1. User clicks link or scans QR code
2. OS routes to app
3. App launches
4. DeepLinkService processes URI
5. App navigates to content screen

### Warm Start (App in Background)
1. App running in background
2. User clicks link
3. App comes to foreground
4. DeepLinkService processes URI
5. App navigates to content screen

### Auth-Required Content (Not Logged In)
1. User clicks link
2. Check if requires auth
3. Link saved as pending
4. Navigate to login screen
5. User logs in
6. Pending link automatically resumed
7. App navigates to content

### Content Not Found
1. Resolver returns `status: "not_found"`
2. Fallback screen displayed
3. Arabic error message: "المحتوى غير متاح حالياً"
4. Optional "Open in Browser" button (if fallback_url provided)

---

## Deduplication

- **Window:** 2 seconds
- **Purpose:** Prevent same link opening twice
- **How it works:** Compares `isResume|url` fingerprint against last 2 seconds
- **Reset:** After 2 seconds, same link can be processed again

---

## Analytics Events

### Event: link_received
Fired when deep link is received and processed.

**Data:**
```json
{
  "url": "https://dllni.mustafafares.com/api/v1/user/restaurants/1",
  "source": "facebook",
  "medium": "share",
  "campaign": "summer_promo",
  "sharer_id": "456",
  "platform": "android"
}
```

---

## Error Messages (Arabic)

| Scenario | Message |
|----------|---------|
| Content not found | المحتوى غير متاح حالياً |
| Access denied | لا يمكنك الوصول إلى هذا المحتوى |
| Content expired | انتهت صلاحية هذا الرابط |
| Generic error | تعذر فتح هذا الرابط |

---

## Debugging

### View Logs
```bash
flutter logs | grep -i deeplink
```

### Key Log Patterns
- `[DeepLinkService]` - Main service activities
- `[DeepLinkParser]` - URL validation
- `[DeepLinkDispatcher]` - Route mapping
- `[DeepLinkRemoteDataSource]` - API calls

### Monitor NetworkTab
Check `POST /api/v1/deep-links/resolve` requests/responses in network tab.

### Test with Debug Screen
Add temporary debug screen to monitor:
- Last received URL
- Last resolution status
- Pending link saved
- Navigation history

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Link opens browser instead of app (Android) | assetlinks.json not deployed or cert mismatch | Deploy assetlinks.json with correct cert SHA-256 |
| Link opens browser instead of app (iOS) | AASA file not deployed | Deploy apple-app-site-association file |
| Pending link not resumed after login | resumePendingIfAny() not called | Add call after login success |
| Duplicate navigation | Link received twice within 2 seconds | Wait 3 seconds and try again |
| Navigation fails | Route not registered | Check app_routes.g.dart for route |
| Analytics not logging | API endpoint inaccessible | Verify network, check endpoint URL |

---

## Platform-Specific Setup

### Android
1. ✅ AndroidManifest.xml has intent filters
2. ✅ assetlinks.json deployed at `/.well-known/assetlinks.json`
3. ✅ App signing cert matches assetlinks.json

### iOS
1. ✅ Runner.entitlements has associated domains
2. ✅ AASA file deployed at `/.well-known/apple-app-site-association`
3. ✅ Domains match app entitlements

### Web
1. ✅ Content served (not raw JSON)
2. ✅ Redirect or landing page for browser
3. ✅ App store link for non-installed users

---

## Configuration

**Canonical Host:**
```dart
AppConfig.deepLinkCanonicalHost = 'dllni.mustafafares.com'
```

**Pending Link Storage Key:**
```dart
'pending_deep_link_url' (SharedPreferences)
```

**Deduplication Window:**
```dart
Duration(seconds: 2)
```

---

## Documentation Files

| File | Purpose |
|------|---------|
| `docs/deep_linking_urls_reference.md` | Complete URL reference |
| `docs/deep_linking_url_generator.html` | Interactive URL & QR generator |
| `docs/deep_linking_testing_guide.md` | Comprehensive testing procedures |
| `docs/deep_linking_implementation_architecture.md` | Technical architecture details |
| `docs/backend-deep-links.md` | Backend requirements |
| **(THIS FILE)** | Quick reference |

---

## Important Notes

✅ **Works out of the box** - Feature is production-ready
✅ **Backwards compatible** - Legacy URL paths supported  
✅ **Secure** - URLs validated, auth enforced, HTTPS only
✅ **Analyzed** - Analytics events logged
✅ **Fallback handling** - Graceful error screens
✅ **Platform verified** - iOS/Android specific configs ready

---

## Quick Links

- **Source:** `lib/core/deeplink/`
- **Test:** `docs/deep_linking_testing_guide.md`
- **Try it:** `docs/deep_linking_url_generator.html`
- **Reference:** `docs/deep_linking_urls_reference.md`
- **Arch:** `docs/deep_linking_implementation_architecture.md`

