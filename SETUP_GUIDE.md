# Firebase Authentication Setup Guide

This Flutter app includes **Email/Password** authentication and **Google Sign-In** integration with Firebase.

## ✅ Already Configured

The following items have been set up for you:

1. ✅ Firebase dependencies added to `pubspec.yaml`
2. ✅ Android Gradle files configured with Firebase
3. ✅ Web Firebase configuration in `web/index.html`
4. ✅ Authentication screens (Login & Sign Up)
5. ✅ Google Sign-In button integration
6. ✅ Firebase initialization in `main.dart`

## 🔧 Important: Google Sign-In Setup

To enable **Google Sign-In**, you need to update your `google-services.json` file with OAuth client information.

### For Android:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **mlmlml-cdda8**
3. Go to **Authentication** → **Sign-in method**
4. Enable **Google** sign-in provider
5. Download the updated `google-services.json` file
6. Replace `android/app/google-services.json` with the new file

**Important:** The new `google-services.json` must include the `oauth_client` section for Google Sign-In to work.

### For Web:

The web configuration is already set up in `web/index.html`. Just make sure:
1. Google Sign-In is enabled in Firebase Console
2. Add your web app's domain to authorized domains in Firebase Console

### For iOS (Optional):

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to the `ios/Runner` folder in Xcode
3. Update `ios/Runner/Info.plist` to include Google Sign-In URL scheme

## 📱 Running the App

### For Android:
```bash
flutter run -d android
```

### For Web:
```bash
flutter run -d chrome
```

### For iOS:
```bash
flutter run -d ios
```

## 🔐 Firebase Configuration

Your Firebase project details:
- **Project ID:** mlmlml-cdda8
- **API Key:** AIzaSyByZ_Gh1dfJWQlhRoCVhRaEHldrdXdV7Gc
- **Auth Domain:** mlmlml-cdda8.firebaseapp.com
- **App ID:** 1:706392251844:web:ce1a6cda7e4de0da3e1891

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── services/
│   └── auth_service.dart     # Authentication service (Email & Google)
└── screens/
    ├── login_screen.dart     # Login UI with Google Sign-In button
    ├── signup_screen.dart    # Sign up UI with Google Sign-In button
    └── home_screen.dart      # Home screen after authentication
```

## 🎨 Features

- ✨ Beautiful gradient UI
- 🔐 Email/Password authentication
- 🔑 Google Sign-In
- 📱 Responsive design for mobile and web
- 🔄 Auto-login persistence
- 🚪 Secure sign-out

## 🐛 Troubleshooting

### Google Sign-In not working on Android:
1. Make sure you've downloaded the latest `google-services.json` from Firebase Console
2. Ensure Google Sign-In is enabled in Firebase Console
3. Add SHA-1 and SHA-256 fingerprints to your Firebase Android app:
   ```bash
   # Get debug SHA-1
   cd android
   ./gradlew signingReport
   ```
4. Add the fingerprints in Firebase Console → Project Settings → Your Android App

### Web Google Sign-In issues:
1. Make sure your domain is authorized in Firebase Console
2. For local testing, `localhost` should be in authorized domains
3. Clear browser cache and cookies

## 📞 Next Steps

1. Enable Google Sign-In in Firebase Console
2. Update `google-services.json` with OAuth client info
3. Add SHA-1/SHA-256 fingerprints for Android release builds
4. Test the app on your preferred platform
5. Customize the UI colors and branding as needed

## 🔒 Security Notes

- Never commit your `google-services.json` to public repositories
- Use environment variables for sensitive keys in production
- Enable App Check in Firebase for additional security
- Set up Firestore/Storage security rules

---

**Enjoy your new authentication system! 🎉**

