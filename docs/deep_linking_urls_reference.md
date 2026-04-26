# Deep Linking URLs Reference

This document provides a comprehensive reference for all supported deep link URLs in the dllni-user-app.

**Canonical Host:** `dllni.mustafafares.com`
**API Base:** `https://dllni.mustafafares.com/api/v1/user`

---

## Supported URL Patterns

### 1. Restaurant Details
Open a specific restaurant/store details page.

**Pattern:** `/api/v1/user/restaurants/{id}`

**Examples:**
```
https://dllni.mustafafares.com/api/v1/user/restaurants/1
https://dllni.mustafafares.com/api/v1/user/restaurants/123
```

**Legacy Pattern (also supported):**
```
https://dllni.mustafafares.com/restaurant/1
https://dllni.mustafafares.com/restaurant/123
```

**Expected Navigation:** → Restaurant Store Details Screen
**Required Auth:** No
**Supports UTM Params:** Yes (utm_source, utm_medium, utm_campaign)

---

### 2. Restaurant Product Details
Open a specific product from a restaurant.

**Pattern:** `/api/v1/user/products/{id}`

**Examples:**
```
https://dllni.mustafafares.com/api/v1/user/products/1
https://dllni.mustafafares.com/api/v1/user/products/456
```

**Legacy Pattern (also supported):**
```
https://dllni.mustafafares.com/product/1
https://dllni.mustafafares.com/product/456
```

**Expected Navigation:** → Restaurant Product Details Screen
**Required Auth:** No
**Target Type:** `restaurant` (RS)
**Query Parameters Example:**
```
https://dllni.mustafafares.com/api/v1/user/products/123?utm_source=facebook&utm_medium=share&utm_campaign=promo&sharer_id=789
```

---

### 3. Supermarket Product Details
Open a specific product from a supermarket.

**Pattern:** `/api/v1/user/supermarket/products/{id}`

**Examples:**
```
https://dllni.mustafafares.com/api/v1/user/supermarket/products/1
https://dllni.mustafafares.com/api/v1/user/supermarket/products/789
```

**Expected Navigation:** → Supermarket Product Details Screen
**Required Auth:** No
**Target Type:** `supermarket`
**Query Parameters Example:**
```
https://dllni.mustafafares.com/api/v1/user/supermarket/products/123?sharer_id=456
```

---

### 4. Supermarket Store Details
Open a specific supermarket store.

**Pattern:** `/api/v1/user/supermarket/stores/{id}`

**Examples:**
```
https://dllni.mustafafares.com/api/v1/user/supermarket/stores/1
https://dllni.mustafafares.com/api/v1/user/supermarket/stores/321
```

**Expected Navigation:** → Supermarket Store Details Screen
**Required Auth:** No
**Supports UTM Params:** Yes

---

### 5. Vote/Poll Details
Open a vote or poll follow-up screen.

**Pattern:** `/api/v1/user/restaurants/votes/{id}`

**Examples:**
```
https://dllni.mustafafares.com/api/v1/user/restaurants/votes/1
https://dllni.mustafafares.com/api/v1/user/restaurants/votes/555
```

**Expected Navigation:** → Vote Follow-up Screen
**Required Auth:** May require auth (depends on vote settings)
**Supports UTM Params:** Yes

---

### 6. Group Order Details
Open a group order follow-up screen.

**Pattern (with ID):** `/api/v1/user/restaurants/group-orders/{id}`

**Pattern (with Share Token):** `/api/v1/user/restaurants/group-orders/{shareToken}`

**Examples:**
```
https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/1
https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/999
https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/abc123xyz
https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/share-token-here
```

**Expected Navigation:** → Group Order Follow-up Screen
**Required Auth:** May require auth (depends on group order settings)
**Supports UTM Params:** Yes
**Note:** Share tokens should be URL-encoded if they contain special characters

---

### 7. Short Links
Short-form deep links using share codes.

**Pattern:** `/s/{shortCode}`

**Examples:**
```
https://dllni.mustafafares.com/s/abc123
https://dllni.mustafafares.com/s/xyz789
```

**Expected Navigation:** Resolved by backend deep link resolver API
**Required Auth:** No
**Note:** Short codes are resolved via the `POST /api/v1/deep-links/resolve` API endpoint

---

## URL with Query Parameters

All URLs support optional query parameters for analytics and sharing tracking:

### UTM Parameters (Google Analytics)
```
utm_source=facebook
utm_medium=share
utm_campaign=summer_promo
```

### Sharing & Tracking
```
sharer_id=123  # ID of the user who shared the link
```

### Complete Example
```
https://dllni.mustafafares.com/api/v1/user/restaurants/1?utm_source=instagram&utm_medium=story&utm_campaign=special_offer&sharer_id=456
```

---

## Testing URLs by Platform

### iOS (Universal Links)
iOS will automatically open these links in the app if:
- The app is installed
- The Apple App Site Association (AASA) file is properly configured
- The URL domain matches the configured domains

**Test URL:** Copy any deep link URL and open in Safari on iOS

### Android (App Links & Custom Schemes)
Android will automatically open these links in the app if:
- The app is installed
- Digital Asset Links (assetlinks.json) are properly configured
- The URL domain matches the configured domains

**Test URL:** Copy any deep link URL and open in Chrome on Android

### Web/Browser
When opened in a browser, the behavior depends on backend configuration:
- **Option A:** Redirect to a public-facing page (e.g., `/product/{id}`)
- **Option B:** Return an HTML landing page with "Open in App" button
- **Option C:** Redirect to app store if app is not installed

---

## Deep Link Resolver API

All complex deep links are resolved using the backend resolver API.

**Endpoint:** `POST /api/v1/deep-links/resolve`

**Request Body:**
```json
{
  "url": "https://dllni.mustafafares.com/api/v1/user/restaurants/123"
}
```

**Response (Success - HTTP 200):**
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

**Response (Not Found - HTTP 200):**
```json
{
  "status": "not_found",
  "type": "restaurant",
  "requires_auth": false,
  "message": "Restaurant not found"
}
```

**Response (Forbidden - HTTP 200):**
```json
{
  "status": "forbidden",
  "type": "restaurant",
  "requires_auth": true,
  "message": "You don't have access to this content"
}
```

**Response (Malformed URL - HTTP 422):**
```json
{
  "error": "Invalid URL format"
}
```

---

## Resolver Status Codes

| Status | Meaning | Action |
|--------|---------|--------|
| `ok` | Content found and accessible | Navigate to screen with resolved data |
| `not_found` | Content does not exist | Show fallback screen with message |
| `forbidden` | Content exists but user lacks permission | Show auth gate or fallback screen |
| `expired` | Content is no longer available (expired) | Show fallback screen with message |
| `unknown` | Unknown status from server | Show generic fallback screen |

---

## Auth-Gated Deep Links

If a deep link requires authentication (`requires_auth: true`):

1. If user is NOT logged in:
   - Link is saved as "pending"
   - User is directed to login screen
   - After successful login, pending link is resumed automatically
   
2. If user IS logged in:
   - Navigate directly to the screen

**Pending Link Storage Key:** `pending_deep_link_url` (SharedPreferences)

---

## Analytics Events

When a deep link is received, the app logs analytics events.

**Event Name:** `link_received`

**Event Properties:**
```
{
  "url": "https://dllni.mustafafares.com/api/v1/user/restaurants/123",
  "source": "facebook",           // utm_source
  "medium": "share",              // utm_medium
  "campaign": "special_offer",    // utm_campaign
  "sharer_id": "456",             // sharer_id parameter
  "platform": "android"           // or "ios" or "web"
}
```

---

## Common Testing Scenarios

### Scenario 1: Cold Start (App Not Running)
1. Click/scan deep link URL on device
2. App launches and navigates to correct screen
3. No login screen should appear if content doesn't require auth

### Scenario 2: Warm Start (App in Background)
1. Open any screen in app
2. Click/scan deep link URL
3. App brings to foreground and navigates to correct screen

### Scenario 3: Auth-Required Content (Not Logged In)
1. Not logged into app
2. Click deep link that requires auth
3. Login screen appears
4. After login, automatically navigates to linked screen

### Scenario 4: Non-Existent Content
1. Click deep link to non-existent restaurant/product
2. Fallback screen appears with error message (in Arabic)
3. Optional "Open in Browser" button shows fallback_url if available

### Scenario 5: With UTM Parameters
1. Click link: `https://dllni.mustafafares.com/api/v1/user/restaurants/1?utm_source=twitter&utm_medium=post`
2. App navigates correctly
3. Analytics event is logged with utm parameters

### Scenario 6: With Sharer ID
1. Click link: `https://dllni.mustafafares.com/api/v1/user/restaurants/1?sharer_id=999`
2. App navigates correctly
3. Analytics event is logged with sharer_id

---

## Deduplication

The app implements deduplication to prevent duplicate deep link handling:

- **Deduplication Window:** 2 seconds
- **Fingerprint:** Combination of `isResume` flag and URL
- **Behavior:** If same deep link received within 2 seconds, it's ignored

---

## Error Messages (Arabic)

| Error | Message (AR) |
|-------|--------------|
| Not Found | "المحتوى غير متوفر حالياً" |
| Forbidden | "لا يمكنك الوصول إلى هذا المحتوى" |
| Expired | "انتهت صلاحية هذا الرابط" |
| Generic | "تعذر فتح هذا الرابط" |

---

## Development Mode Testing

### Using adb (Android)
```bash
# Test a deep link
adb shell am start -a android.intent.action.VIEW -d "https://dllni.mustafafares.com/api/v1/user/restaurants/1"
```

### Using xcrun (iOS via Simulator)
```bash
# Test a deep link
xcrun simctl openurl booted "https://dllni.mustafafares.com/api/v1/user/restaurants/1"
```

### Flutter Log Monitoring
```bash
# Watch for deep link events in flutter logs
flutter logs | grep -i "deeplink"
```

---

## Troubleshooting

### Links not opening app (Android/iOS)
- Verify `.well-known/assetlinks.json` (Android) or `.well-known/apple-app-site-association` (iOS) is deployed
- Check app signing certificate matches configuration
- Verify bundle ID and package name are correct
- Wait 24-48 hours for platform verification to complete

### Links opening app but navigating to wrong screen
- Check deep link resolver API is returning correct `type` and `target`
- Verify dispatcher logic in app matches resolver output
- Check logs for dispatcher errors

### Auth-gated links not prompting login
- Verify server is returning `requires_auth: true` in resolver response
- Check SharedPreferences is saving pending URL correctly
- Verify login flow calls `DeepLinkService.resumePendingIfAny()`

### Analytics not logging
- Check `POST /api/v1/deep-links/events` endpoint is accessible
- Verify network connectivity in test environment
- Check app has permission to make network requests

---

## References

- **Source Code:** `lib/core/deeplink/`
- **Backend Requirements:** `docs/backend-deep-links.md`
- **Share Targets Helper:** `lib/core/deeplink/deep_link_share_targets.dart`

