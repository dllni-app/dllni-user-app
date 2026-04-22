Handoff for backend / DevOps — host these at the production domain
===================================================================

Copy to exact URLs (HTTPS, 200 OK, no redirect to another host):

  https://dllni.mustafafares.com/.well-known/assetlinks.json
  https://dllni.mustafafares.com/.well-known/apple-app-site-association

Before deployment, replace placeholders in the JSON files:

1) assetlinks.json — sha256_cert_fingerprints
   - RELEASE: signing key used for Play Store / production AAB/APK.
     Example (PowerShell, path to your release keystore):
       keytool -list -v -keystore YOUR_RELEASE.keystore -alias YOUR_ALIAS
     Copy the "SHA256" line (colon-separated hex).

   - Optional DEBUG: only if you want verified links while sideloading debug builds.
       keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

   Remove the placeholder lines you do not use; Google expects valid SHA-256 entries.

2) apple-app-site-association — appID
   - Format: <Apple Team ID>.<bundle id>
   - Bundle ID for this app: com.dllni.userapp
   - Team ID: Apple Developer account → Membership (10 characters).

Serving notes
-------------
- assetlinks.json: Content-Type application/json is fine.
- apple-app-site-association: often served as application/json; file has NO .json extension.
- If you also use www.dllni.mustafafares.com, duplicate these files (or redirect) for that host.

Package / bundle IDs (from this Flutter project)
------------------------------------------------
- Android applicationId: com.dllni.userapp
- iOS PRODUCT_BUNDLE_IDENTIFIER: com.dllni.userapp
