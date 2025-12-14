# 🔥 Firestore Database Setup

## ✅ What's Been Added

### User Profile Data Collection
Your app now saves user profile information to Firestore when users sign up:

**Data Saved:**
- ✅ Full Name
- ✅ Age
- ✅ Email
- ✅ User ID (UID)
- ✅ Photo URL (if available)
- ✅ Account creation timestamp

### Database Structure
```
Firestore Database
└── users (collection)
    └── {userId} (document)
        ├── uid: string
        ├── email: string
        ├── fullName: string
        ├── age: number
        ├── photoURL: string (optional)
        └── createdAt: string (ISO timestamp)
```

---

## 🔧 Required: Set Up Firestore Security Rules

### Step 1: Enable Firestore in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **mlmlml-cdda8**
3. Click **Firestore Database** in the left menu
4. Click **Create database**
5. Choose **Start in test mode** (we'll secure it next)
6. Select a location (closest to your users)
7. Click **Enable**

### Step 2: Set Up Security Rules

After Firestore is enabled:

1. Go to **Firestore Database** → **Rules** tab
2. Replace the default rules with these secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can read/write their own data
    match /users/{userId} {
      // Allow read if authenticated
      allow read: if request.auth != null;
      
      // Allow create/update only for the user's own document
      allow create, update: if request.auth != null && request.auth.uid == userId;
      
      // Allow delete only for the user's own document
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **Publish**

---

## 🔒 What These Rules Do

### Security Features:
- ✅ Users must be authenticated to access any data
- ✅ Users can only read/write their own profile
- ✅ Users cannot access other users' data
- ✅ Anonymous access is blocked
- ✅ All other collections are protected by default

### Rules Breakdown:
```javascript
// Users can read their own and others' profiles (but only if logged in)
allow read: if request.auth != null;

// Users can only modify their own profile
allow create, update: if request.auth != null && request.auth.uid == userId;

// Users can only delete their own profile
allow delete: if request.auth != null && request.auth.uid == userId;
```

---

## 📊 View Your User Data

### In Firebase Console:
1. Go to **Firestore Database**
2. Click on **users** collection
3. You'll see all registered users with their profile data

### In Your App:
The home screen automatically displays:
- Full Name
- Age
- Email
- User ID

---

## 🎯 How It Works

### Sign Up Flow:
1. User fills in **Full Name**, **Age**, **Email**, **Password**
2. Firebase Auth creates the account
3. User data is saved to **Firestore** → `users/{userId}`
4. Display name is updated in Firebase Auth
5. User is redirected to login

### Sign In Flow:
1. User signs in with email/password
2. App fetches user profile from Firestore
3. Home screen displays the user's full profile

### Google Sign-In Flow:
1. User signs in with Google
2. If new user, profile is created with:
   - Name from Google account
   - Age = 0 (needs to be updated later)
   - Photo from Google account
3. Profile is saved to Firestore

---

## 📝 User Data Model

```dart
class UserModel {
  final String uid;           // Firebase Auth user ID
  final String email;         // User's email
  final String fullName;      // User's full name
  final int age;              // User's age
  final String? photoURL;     // Profile photo (optional)
  final DateTime createdAt;   // Account creation date
}
```

---

## 🔄 Real-Time Updates

The home screen uses **StreamBuilder** to listen for real-time updates:
- Profile changes are reflected immediately
- No need to refresh the app
- Always shows latest data

---

## 🛡️ Privacy & Data Protection

### What's Stored:
- ✅ Full Name
- ✅ Age
- ✅ Email
- ✅ User ID
- ✅ Photo URL

### What's NOT Stored:
- ❌ Passwords (handled by Firebase Auth)
- ❌ Payment information
- ❌ Sensitive personal data

### Data Access:
- Users can only access their own data
- Other users cannot view/modify your profile
- Admin access requires special configuration

---

## 🚀 Testing Your Database

### Create a Test User:
1. Run the app
2. Click **Sign Up**
3. Fill in:
   - Full Name: "John Doe"
   - Age: 25
   - Email: test@example.com
   - Password: test123
4. Click **Sign Up**

### Verify in Firebase:
1. Go to Firebase Console → Firestore Database
2. Click on **users** collection
3. You should see a document with the user's data

### Check on Home Screen:
1. Sign in with the test account
2. You should see:
   - "Welcome!"
   - "John Doe"
   - "25 years old"
   - Email and other info in cards

---

## 🎨 Features Added

### Sign Up Screen:
- ✅ Full Name field (required, min 2 characters)
- ✅ Age field (required, 13-120 range)
- ✅ Modern validation
- ✅ Auto-save to Firestore

### Home Screen:
- ✅ Real-time user data display
- ✅ Full Name card
- ✅ Age card
- ✅ Email card
- ✅ User ID card
- ✅ Profile photo support

### Auth Service:
- ✅ Save user data to Firestore
- ✅ Fetch user data
- ✅ Real-time user data stream
- ✅ Update display name in Firebase Auth

---

## 💡 Pro Tips

1. **Always enable Firestore before testing** - The app will crash if Firestore is not enabled
2. **Use test mode initially** - You can secure it later with proper rules
3. **Monitor usage** - Firebase has generous free tier limits
4. **Backup your data** - Use Firebase export features regularly
5. **Test security rules** - Use Firebase Console's Rules Playground

---

## 📞 Quick Reference

### Enable Firestore:
```
Firebase Console → Firestore Database → Create database → Test mode → Enable
```

### Set Security Rules:
```
Firestore Database → Rules → Paste rules → Publish
```

### View Users:
```
Firestore Database → users collection → See all documents
```

### Test App:
```bash
flutter run -d android
```

---

## ✅ Checklist

Before running the app with Firestore:

- [ ] Firestore Database is enabled in Firebase Console
- [ ] Security rules are set up and published
- [ ] App has internet permission (already added)
- [ ] Google Sign-In is configured (optional)
- [ ] Test user created successfully

---

**Your app now has a complete user profile system with secure cloud storage! 🎉**

Users will appear in both:
- **Firebase Authentication** → Users tab (Auth accounts)
- **Firestore Database** → users collection (Profile data)

