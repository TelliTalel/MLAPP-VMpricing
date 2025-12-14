# Google Sign-In Configuration Guide

## 🔴 IMPORTANT: Required Steps for Google Sign-In

Google Sign-In requires additional configuration in the Firebase Console. Follow these steps carefully:

## Step 1: Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **mlmlml-cdda8**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** in the providers list
5. Click **Enable**
6. Enter your support email
7. Click **Save**

## Step 2: Configure Android App

### Get Your SHA-1 and SHA-256 Fingerprints

**For Debug Build:**
```bash
cd android
./gradlew signingReport
```

Or use keytool directly:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Build:**
```bash
keytool -list -v -keystore path/to/your/keystore.jks -alias your-alias
```

### Add Fingerprints to Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll to **Your apps** section
3. Find your Android app (com.example.untitled)
4. Click on the Android app
5. Scroll to **SHA certificate fingerprints**
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Add fingerprint** again
9. Paste your SHA-256 fingerprint
10. Click **Save**

### Download Updated google-services.json

1. After adding fingerprints, click **Download google-services.json**
2. Replace the file at `android/app/google-services.json`
3. The new file will include OAuth client credentials

**Example of what the oauth_client section should look like:**
```json
"oauth_client": [
  {
    "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.example.untitled",
      "certificate_hash": "YOUR_SHA1_HASH"
    }
  },
  {
    "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

## Step 3: Configure Web App

The web configuration is already in `web/index.html`, but you need to:

1. In Firebase Console, go to **Authentication** → **Settings** → **Authorized domains**
2. Make sure these domains are listed:
   - `localhost` (for development)
   - Your production domain (if deploying)

## Step 4: Configure iOS App (Optional)

If you want to support iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. Open Xcode and add the file to `ios/Runner`
3. Update `ios/Runner/Info.plist`:

```xml
<!-- Add this inside the main <dict> -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

## Step 5: Test the Integration

1. Clean and rebuild your project:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

2. Try signing in with Google
3. Check the console for any error messages

## Common Issues

### "PlatformException (sign_in_failed)"
- **Solution:** Make sure SHA-1/SHA-256 are added to Firebase Console
- Download the latest `google-services.json` file

### "ApiException: 10"
- **Solution:** This means the Google Sign-In is not properly configured
- Check that `google-services.json` has the `oauth_client` section
- Verify SHA fingerprints are correct

### "Developer Error"
- **Solution:** OAuth client mismatch
- Make sure the package name matches: `com.example.untitled`
- Regenerate and download `google-services.json`

### Web: "popup_closed_by_user"
- **Solution:** User canceled the sign-in
- This is normal behavior, not an error

### Web: "unauthorized_client"
- **Solution:** Domain not authorized
- Add your domain to Firebase Console → Authentication → Settings → Authorized domains

## Verification Checklist

Before running the app, verify:

- [ ] Google Sign-In is enabled in Firebase Console
- [ ] SHA-1 fingerprint added to Firebase Android app
- [ ] SHA-256 fingerprint added to Firebase Android app
- [ ] Downloaded and replaced `google-services.json`
- [ ] `oauth_client` section exists in `google-services.json`
- [ ] Package name is `com.example.untitled` everywhere
- [ ] For web: `localhost` is in authorized domains
- [ ] Ran `flutter clean && flutter pub get`

## Testing Commands

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on Web
flutter run -d chrome

# Check for issues
flutter doctor -v
```

## Support

If you continue having issues:
1. Check the Flutter console output for error messages
2. Verify all steps in this guide
3. Make sure Firebase billing is enabled (required for some features)
4. Check Firebase Console → Authentication → Users to see if users are being created

---

**After completing these steps, Google Sign-In should work perfectly! 🎉**

