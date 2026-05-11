# Deep Linking Feature - Testing Guide

This document provides comprehensive testing procedures for the deep linking feature in dllni-user-app.

---

## Table of Contents

1. [Pre-Testing Setup](#pre-testing-setup)
2. [Test Scenarios](#test-scenarios)
3. [Manual Testing Procedures](#manual-testing-procedures)
4. [Automation Testing](#automation-testing)
5. [Debugging & Logs](#debugging--logs)
6. [Known Issues & Workarounds](#known-issues--workarounds)

---

## Pre-Testing Setup

### Requirements

- **Flutter SDK:** Latest version
- **Device/Emulator:** Android emulator or iOS simulator (or real devices)
- **Network:** Access to `dllni.mustafafares.com`
- **App:** Compiled with deep linking support enabled
- **Test Data:** Valid Restaurant/Product/Vote/GroupOrder IDs from the backend

### Setup Steps

#### Android Setup

1. **Verify AndroidManifest.xml** contains intent filters:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="dllni.mustafafares.com" />
    <data android:scheme="https" android:pathPrefix="/api/v1/user/restaurants" />
    <data android:scheme="https" android:pathPrefix="/api/v1/user/products" />
    <data android:scheme="https" android:pathPrefix="/api/v1/user/supermarket" />
    <data android:scheme="https" android:pathPrefix="/s/" />
    <data android:scheme="https" android:pathPrefix="/restaurant" />
    <data android:scheme="https" android:pathPrefix="/product" />
</intent-filter>
```

2. **Check assetlinks.json deployment:**
```bash
curl -X GET https://dllni.mustafafares.com/.well-known/assetlinks.json
```

3. **Verify digital asset links:**
```bash
curl -X GET "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://dllni.mustafafares.com&relation=delegate_permission/common.handle_all_urls"
```

#### iOS Setup

1. **Verify Runner.entitlements** includes:
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:dllni.mustafafares.com</string>
    <string>applinks:www.dllni.mustafafares.com</string>
</array>
```

2. **Check AASA file deployment:**
```bash
curl -X GET https://dllni.mustafafares.com/.well-known/apple-app-site-association
```

3. **Verify on device:**
```
Settings > [App Name] > Associated Domains > Check if dllni.mustafafares.com is listed
```

---

## Test Scenarios

### Scenario 1: Cold Start - Restaurant Deep Link

**Objective:** Verify app launches and navigates to restaurant details screen when deep link is opened and app is not running.

**Test Steps:**
1. Close the app completely
2. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/1`
3. Verify app launches
4. Verify correct restaurant details screen is displayed
5. Verify restaurant data matches ID from URL

**Expected Result:** ✅ App launches and shows restaurant details for ID 1

**Platform:** Android & iOS

---

### Scenario 2: Warm Start - Product Deep Link

**Objective:** Verify app navigates to product details when deep link is opened while app is in background.

**Test Steps:**
1. Open app and navigate to home screen
2. Minimize/background the app (don't close)
3. Open link: `https://dllni.mustafafares.com/api/v1/user/products/123`
4. Verify app comes to foreground
5. Verify product details screen is displayed
6. Verify product ID matches URL

**Expected Result:** ✅ App comes to foreground and shows product details for ID 123

**Platform:** Android & iOS

---

### Scenario 3: Auth-Gated Deep Link (Not Logged In)

**Objective:** Verify pending link functionality when user is not authenticated.

**Test Steps:**
1. Logout from app completely
2. Clear SharedPreferences (or ensure no token exists)
3. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/votes/1`
4. Verify login screen appears
5. Don't perform any action, observe the link is saved
6. Login with valid credentials
7. Verify app automatically navigates to vote followup screen after login
8. Verify vote details match ID from URL

**Expected Result:** ✅ Login screen appears, and after authentication, app navigates to vote screen

**Platform:** Android & iOS

---

### Scenario 4: Supermarket Product Deep Link

**Objective:** Verify supermarket product routing works correctly.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/supermarket/products/789`
2. Verify supermarket product details screen is displayed (not restaurant product)
3. Verify product ID and category indicate supermarket origin

**Expected Result:** ✅ Supermarket product details shown (target="supermarket")

**Platform:** Android & iOS

---

### Scenario 5: Supermarket Store Deep Link

**Objective:** Verify supermarket store navigation.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/supermarket/stores/321`
2. Verify supermarket store details screen is displayed
3. Verify store ID matches URL

**Expected Result:** ✅ Supermarket store details shown correctly

**Platform:** Android & iOS

---

### Scenario 6: Group Order with Numeric ID

**Objective:** Verify group order deep link with numeric ID.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/999`
2. Verify group order followup screen is displayed
3. Verify group order details load correctly
4. Verify order ID matches URL

**Expected Result:** ✅ Group order followup screen displayed with correct data

**Platform:** Android & iOS

---

### Scenario 7: Group Order with Share Token

**Objective:** Verify group order deep link with share token.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/share-token-12345`
2. Verify group order followup screen is displayed
3. Verify group order details load using share token
4. Verify user can join/participate in group order

**Expected Result:** ✅ Group order accessible via share token

**Platform:** Android & iOS

---

### Scenario 8: UTM Parameters & Analytics

**Objective:** Verify UTM parameters are captured and logged.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/1?utm_source=facebook&utm_medium=share&utm_campaign=summer_promo&sharer_id=456`
2. Verify app navigates to restaurant screen
3. Check app logs for analytics event
4. Verify event contains:
   - `url`: full URL
   - `source`: facebook
   - `medium`: share
   - `campaign`: summer_promo
   - `sharer_id`: 456
   - `platform`: android or ios

**Expected Result:** ✅ Analytics event logged with correct parameters

**Platform:** Android & iOS

---

### Scenario 9: Short Link Resolution

**Objective:** Verify short links are resolved correctly.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/s/abc123`
2. Verify app calls `/api/v1/deep-links/resolve` API
3. Verify app resolves to correct screen based on resolver response
4. Verify navigation matches resolved type and target

**Expected Result:** ✅ Short link resolved and navigated correctly

**Platform:** Android & iOS

**Note:** Requires mock/real short link configured on backend

---

### Scenario 10: Non-Existent Content (not_found)

**Objective:** Verify fallback screen for non-existent content.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/999999999` (non-existent ID)
2. Verify deep link resolver returns `status: "not_found"`
3. Verify fallback screen is displayed
4. Verify Arabic error message is shown: "المحتوى غير متوفر حالياً"
5. Verify optional fallback_url button is available (if applicable)

**Expected Result:** ✅ Fallback screen displayed with appropriate message

**Platform:** Android & iOS

---

### Scenario 11: Forbidden Content (requires_auth or insufficient permissions)

**Objective:** Verify restricted content handling.

**Test Steps:**
1. Login as User A
2. Open link to content owned by User B with restricted permissions
3. Verify app calls resolver API
4. Verify resolver returns `status: "forbidden"`
5. Verify fallback screen is displayed
6. Verify Arabic error message: "لا يمكنك الوصول إلى هذا المحتوى"

**Expected Result:** ✅ Access denied message displayed appropriately

**Platform:** Android & iOS

---

### Scenario 12: Deduplication

**Objective:** Verify duplicate deep links within 2-second window are ignored.

**Test Steps:**
1. Open same deep link twice in rapid succession (within 1 second)
2. Verify navigation happens only once
3. No duplicate screen push or state changes

**Expected Result:** ✅ Duplicate link ignored, navigation happens once

**Platform:** Android & iOS

---

### Scenario 13: Legacy URL Paths

**Objective:** Verify backward compatibility with legacy URL patterns.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/restaurant/1`
2. Verify app navigates to restaurant details screen
3. Open link: `https://dllni.mustafafares.com/product/123`
4. Verify app navigates to product details screen

**Expected Result:** ✅ Legacy paths work correctly

**Platform:** Android & iOS

---

### Scenario 14: WWW Subdomain Handling

**Objective:** Verify links with www subdomain are handled correctly.

**Test Steps:**
1. Open link: `https://www.dllni.mustafafares.com/api/v1/user/restaurants/1`
2. Verify link pattern is normalized to apex domain
3. Verify app navigates correctly

**Expected Result:** ✅ WWW subdomain handled and normalized correctly

**Platform:** Android & iOS

---

### Scenario 15: Browser Behavior (Web)

**Objective:** Verify behavior when deep link is opened in web browser.

**Test Steps:**
1. Open link: `https://dllni.mustafafares.com/api/v1/user/restaurants/1` in desktop Chrome
2. Verify backend responds with:
   - Option A: Redirect to public page (e.g., `/restaurant/1`)
   - Option B: HTML landing page with "Open in App" button
   - Option C: Redirect to app store/website
3. Verify no raw JSON is returned

**Expected Result:** ✅ Browser receives appropriate response (not raw JSON)

**Platform:** Web/Browser

---

## Manual Testing Procedures

### Procedure 1: Using adb (Android)

```bash
# Cold start test
adb shell am start -a android.intent.action.VIEW -d "https://dllni.mustafafares.com/api/v1/user/restaurants/1"

# Multiple URLs
adb shell am start -a android.intent.action.VIEW -d "https://dllni.mustafafares.com/api/v1/user/products/123?utm_source=facebook"

# Kill app first
adb shell am force-stop com.alnadha.app
adb shell am start -a android.intent.action.VIEW -d "https://dllni.mustafafares.com/api/v1/user/restaurants/votes/789"
```

### Procedure 2: Using xcrun (iOS Simulator)

```bash
# Cold start test
xcrun simctl openurl booted "https://dllni.mustafafares.com/api/v1/user/restaurants/1"

# Kill app first
xcrun simctl launch --wait booted com.alnadha.app
xcrun simctl terminate booted com.alnadha.app
xcrun simctl openurl booted "https://dllni.mustafafares.com/api/v1/user/products/456"
```

### Procedure 3: Manual Testing on Device

1. **Generate QR Code:**
   - Use the HTML form at `docs/deep_linking_url_generator.html`
   - Click "📲 QR Code" to generate QR code
   - Scan with camera app

2. **Direct Link:**
   - Copy URL from form
   - Open in browser
   - Tap "Open" when prompted

3. **Shared Link:**
   - Use app's share feature to share content
   - Click shared link in messaging app
   - Verify navigation

### Procedure 4: Flutter Logs Monitoring

```bash
# Watch all logs
flutter logs

# Filter deep link events
flutter logs | grep -Ei "deeplink|deep_link"

# Monitor specific service
flutter logs | grep "DeepLinkService"
```

---

## Automation Testing

### Unit Tests - Deep Link Parser

**Location:** `test/core/deeplink/deep_link_parser_test.dart`

```dart
void main() {
  group('DeepLinkParser', () {
    test('isSupportedDeepLink - restaurant path', () {
      final uri = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/1');
      expect(DeepLinkParser.isSupportedDeepLink(uri), true);
    });

    test('isSupportedDeepLink - product path', () {
      final uri = Uri.parse('https://dllni.mustafafares.com/api/v1/user/products/123');
      expect(DeepLinkParser.isSupportedDeepLink(uri), true);
    });

    test('isSupportedDeepLink - unsupported path', () {
      final uri = Uri.parse('https://dllni.mustafafares.com/random/path');
      expect(DeepLinkParser.isSupportedDeepLink(uri), false);
    });

    test('normalizeHostIfNeeded - www prefix', () {
      final uri = Uri.parse('https://www.dllni.mustafafares.com/api/v1/user/restaurants/1');
      final normalized = DeepLinkParser.normalizeHostIfNeeded(uri);
      expect(normalized.host, 'dllni.mustafafares.com');
    });

    test('canonicalHost - removes www', () {
      final uri = Uri.parse('https://www.dllni.mustafafares.com/api/v1/user/restaurants/1');
      expect(DeepLinkParser.canonicalHost(uri), 'dllni.mustafafares.com');
    });
  });
}
```

### Unit Tests - Deep Link Dispatcher

**Location:** `test/core/deeplink/deep_link_dispatcher_test.dart`

```dart
void main() {
  group('DeepLinkDispatcher', () {
    test('dispatch - product', () {
      final resolved = DeepLinkResolveResult(
        type: 'product',
        status: DeepLinkResolveStatus.ok,
        requiresAuth: false,
        id: 123,
      );
      final target = DeepLinkDispatcher.dispatch(resolved);
      expect(target, isNotNull);
      expect(target?.routeName, '/product');
    });

    test('dispatch - restaurant', () {
      final resolved = DeepLinkResolveResult(
        type: 'restaurant',
        status: DeepLinkResolveStatus.ok,
        requiresAuth: false,
        id: 456,
      );
      final target = DeepLinkDispatcher.dispatch(resolved);
      expect(target?.routeName, '/rs_store');
    });

    test('dispatch - vote', () {
      final resolved = DeepLinkResolveResult(
        type: 'vote',
        status: DeepLinkResolveStatus.ok,
        requiresAuth: false,
        id: 789,
      );
      final target = DeepLinkDispatcher.dispatch(resolved);
      expect(target?.routeName, '/votefollowup');
    });

    test('dispatch - group-order', () {
      final resolved = DeepLinkResolveResult(
        type: 'group-order',
        status: DeepLinkResolveStatus.ok,
        requiresAuth: false,
        id: 999,
      );
      final target = DeepLinkDispatcher.dispatch(resolved);
      expect(target?.routeName, '/group-order/followup');
    });

    test('dispatch - not_found status returns null', () {
      final resolved = DeepLinkResolveResult(
        type: 'restaurant',
        status: DeepLinkResolveStatus.notFound,
        requiresAuth: false,
        id: 999999,
      );
      final target = DeepLinkDispatcher.dispatch(resolved);
      expect(target, isNull);
    });

    test('dispatch - handles target field (restaurant vs supermarket)', () {
      final resolved = DeepLinkResolveResult(
        type: 'product',
        status: DeepLinkResolveStatus.ok,
        requiresAuth: false,
        id: 123,
        target: 'supermarket',
      );
      final target = DeepLinkDispatcher.dispatch(resolved);
      expect(target?.routeName, '/product');
    });
  });
}
```

### Integration Tests - Deep Link Service

**Location:** `test/core/deeplink/deep_link_service_test.dart`

```dart
void main() {
  group('DeepLinkService Integration', () {
    late DeepLinkService service;
    late MockDeepLinkRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockDeepLinkRemoteDataSource();
      service = DeepLinkService(mockDataSource);
    });

    test('handleIncomingUri - cold start', () async {
      final uri = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/1');
      final navigatorKey = GlobalKey<NavigatorState>();
      
      await service.init(navigatorKey: navigatorKey);
      await service.handleIncomingUri(uri);

      // Verify navigation happened
      expect(navigatorKey.currentState, isNotNull);
    });

    test('handleIncomingUri - deduplication', () async {
      final uri = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/1');
      final navigatorKey = GlobalKey<NavigatorState>();
      
      await service.init(navigatorKey: navigatorKey);
      
      // Call twice in rapid succession
      await service.handleIncomingUri(uri);
      await service.handleIncomingUri(uri); // Should be deduplicated
      
      // Verify only one navigation
      verify(mockDataSource.postDeepLinkEvent(
        action: 'link_received',
        url: any,
        source: any,
        medium: any,
        campaign: any,
        sharerId: any,
      )).called(1);
    });

    test('resumePendingIfAny - resumes saved link after login', () async {
      const url = 'https://dllni.mustafafares.com/api/v1/user/restaurants/1';
      
      // Save pending link
      await SharedPreferencesHelper.saveData(key: 'pending_deep_link_url', value: url);
      
      final navigatorKey = GlobalKey<NavigatorState>();
      await service.init(navigatorKey: navigatorKey);
      await service.resumePendingIfAny();
      
      // Verify link was processed
      // Verify pending link was cleared
      final saved = SharedPreferencesHelper.getData(key: 'pending_deep_link_url');
      expect(saved, isNull);
    });
  });
}
```

### Widget Tests - Fallback Screen

**Location:** `test/core/deeplink/deep_link_fallback_screen_test.dart`

```dart
void main() {
  group('DeepLinkFallbackScreen', () {
    testWidgets('displays error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeepLinkFallbackScreen(
            message: 'تعذر فتح هذا الرابط',
          ),
        ),
      );

      expect(find.text('رابط غير متاح'), findsOneWidget);
      expect(find.text('تعذر فتح هذا الرابط'), findsOneWidget);
    });

    testWidgets('displays fallback button when URL provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeepLinkFallbackScreen(
            message: 'المحتوى غير متوفر',
            fallbackUrl: 'https://example.com',
          ),
        ),
      );

      expect(find.text('فتح في المتصفح'), findsOneWidget);
    });

    testWidgets('does not display fallback button when URL is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DeepLinkFallbackScreen(
            message: 'خطأ',
            fallbackUrl: '',
          ),
        ),
      );

      expect(find.text('فتح في المتصفح'), findsNothing);
    });
  });
}
```

---

## Debugging & Logs

### Key Log Messages to Monitor

```
// Deep Link Service Initialization
[DeepLinkService] Initializing with navigator key
[DeepLinkService] Initial link detected: https://...

// URI Parsing
[DeepLinkParser] Parsing URL: https://...
[DeepLinkParser] Host validation passed
[DeepLinkParser] Path validation passed

// Resolver API Call
[DeepLinkRemoteDataSource] Calling /api/v1/deep-links/resolve
[DeepLinkRemoteDataSource] Resolver response: {...}

// Dispatch
[DeepLinkDispatcher] Dispatching type: restaurant, id: 1, target: null

// Navigation
[DeepLinkService] Navigating to route: /rs_store

// Error Handling
[DeepLinkService] Unsupported deep link received
[DeepLinkService] Resolver API failed: 422
[DeepLinkService] Navigation failed: route not found
```

### Enable Verbose Logging

Add to `main.dart`:

```dart
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  // ... existing code ...
  
  logger.level = Level.verbose;
  
  // ... rest of main ...
}
```

### Debug Provider State

Add temporary debug screen to monitor deep link state:

```dart
class DeepLinkDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last URL: ${service._lastUrl}'),
                  Text('Last Status: ${service._lastStatus}'),
                  Text('Last Error: ${service._lastError}'),
                  Text('Pending Link: ${service._pendingUrl}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      service.clearDebugInfo();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Known Issues & Workarounds

### Issue 1: iOS Universal Links Not Working After App Update

**Symptom:** Deep links work on initial install but fail after app update

**Cause:** Apple caches AASA file for several days

**Workaround:**
1. Delete app completely from device
2. Restart device
3. Reinstall app
4. Test deep link

**Solution:** Ensure AASA file has correct `Cache-Control: max-age=604800` headers

### Issue 2: Android App Links Not Verified

**Symptom:** Deep links open in Chrome instead of app, or "Open with" dialog shows

**Cause:** assetlinks.json not deployed or certificate mismatch

**Workaround:**
1. Verify assetlinks.json is accessible:
```bash
curl -v https://dllni.mustafafares.com/.well-known/assetlinks.json
```

2. Check app certificate SHA-256:
```bash
keytool -list -v -keystore key.jks -alias key
```

3. Compare with assetlinks.json

**Solution:** Deploy correct assetlinks.json with matching certificate

### Issue 3: Pending Link Not Resumed After Login

**Symptom:** User logs in but deep link doesn't navigate

**Cause:** `resumePendingIfAny()` not called after login

**Fix:** Add to login success callback:

```dart
// In login_screen.dart or auth_repository.dart
await getIt<DeepLinkService>().resumePendingIfAny();
```

### Issue 4: Deep Link Resolver API 422 Error

**Symptom:** Resolver returns 422 (Unprocessable Entity)

**Cause:** Malformed URL sent to resolver

**Solutions:**
- Verify URL encoding (especially for share tokens)
- Check URL format matches expected patterns
- Test with well-formed URL

### Issue 5: Excessive Deduplication

**Symptom:** Deep link navigation happens once but subsequent calls don't work

**Cause:** Deduplication window too long

**Workaround:** Wait 3+ seconds before opening same link again

**Note:** 2-second window is intentional to prevent duplicate navigation

### Issue 6: Web Not Recognizing Deep Links

**Symptom:** Web version doesn't handle deep links

**Expected Behavior:** Web should display content directly, not try to app deep link

**Solution:** Use `kIsWeb` flag:

```dart
if (kIsWeb) {
  // Handle web-specific behavior
  // Show content directly instead of using DeepLinkService
}
```

---

## Test Checklist

Use this checklist to verify all scenarios are tested:

- [ ] Scenario 1: Cold Start - Restaurant
- [ ] Scenario 2: Warm Start - Product
- [ ] Scenario 3: Auth-Gated Link (Not Logged In)
- [ ] Scenario 4: Supermarket Product
- [ ] Scenario 5: Supermarket Store
- [ ] Scenario 6: Group Order (Numeric ID)
- [ ] Scenario 7: Group Order (Share Token)
- [ ] Scenario 8: UTM Parameters & Analytics
- [ ] Scenario 9: Short Link Resolution
- [ ] Scenario 10: Non-Existent Content (not_found)
- [ ] Scenario 11: Forbidden Content (requires_auth)
- [ ] Scenario 12: Deduplication
- [ ] Scenario 13: Legacy URL Paths
- [ ] Scenario 14: WWW Subdomain
- [ ] Scenario 15: Browser Behavior (Web)
- [ ] Unit Tests - Parser
- [ ] Unit Tests - Dispatcher
- [ ] Integration Tests - Service
- [ ] Widget Tests - Fallback Screen

---

## Test Execution Report Template

```markdown
# Deep Linking Test Report

**Test Date:** YYYY-MM-DD
**Tester:** [Name]
**Environment:** [Android/iOS] [Device Model] [OS Version]
**App Version:** [Version]
**Build:** [Build Number]

## Summary
- **Total Tests:** 15
- **Passed:** ✅ X
- **Failed:** ❌ X
- **Skipped:** ⊘ X

## Test Results

### Cold Start - Restaurant
- Status: [PASS/FAIL]
- Notes: [Any observations]

### Warm Start - Product
- Status: [PASS/FAIL]
- Notes: [Any observations]

### ... (continue for all scenarios)

## Issues Found

1. **Issue Title**
   - Severity: [Critical/High/Medium/Low]
   - Description: [Details]
   - Steps to Reproduce: [Steps]
   - Expected: [Expected behavior]
   - Actual: [Actual behavior]
   - Workaround: [If applicable]

## Sign-Off
- Tester: _________________ Date: _________
- QA Lead: ________________ Date: _________
```

---

## References

- **Deep Link Reference:** `./deep_linking_urls_reference.md`
- **URL Generator Tool:** `./deep_linking_url_generator.html`
- **Source Code:** `lib/core/deeplink/`
- **Backend Docs:** `./backend-deep-links.md`

