# Firestore Security Rules Update

## New Collection: `user_preferences`

Add the following rules to your Firestore Security Rules in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ... (your existing rules) ...
    
    // User preferences - each user has their own document
    match /user_preferences/{userId} {
      // Allow users to read/write their own preferences
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Note: Each document is identified by userId from the parent app
      // Structure: { homeTeamBorderColor: int, awayTeamBorderColor: int, lastUpdated: timestamp }
    }
  }
}
```

## Alternative: Allow All Users (Less Secure)

If you don't have authentication or want to allow all access:

```javascript
match /user_preferences/{userId} {
  // Any user can access any preferences (use with caution)
  allow read, write: if true;
}
```

## Instructions

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `zporter-board-dev`
3. Navigate to **Firestore Database** → **Rules** tab
4. Add the `user_preferences` rules above
5. Click **Publish**

## Collection Structure

**Collection:** `user_preferences`  
**Document ID:** User ID from parent app (e.g., `user123`, `abc-def-ghi-jkl`)

**Fields:**
- `homeTeamBorderColor` (number): RGB color value for home team
- `awayTeamBorderColor` (number): RGB color value for away team  
- `lastUpdated` (timestamp): Server timestamp of last update

## How It Works

1. **Parent app passes userId** to TacticboardScreen via constructor
2. **TacticboardScreen initialization** calls `UserPreferencesService.setUserId(userId)`
3. **Preferences are saved** under `user_preferences/{userId}` in Firestore
4. **True cross-device sync**: Same user, same preferences on all devices

## Benefits

✅ **True user association**: Preferences linked to actual user account  
✅ **Cross-device sync**: Same user = same settings everywhere  
✅ **Cloud backup**: Settings preserved across app reinstalls  
✅ **Offline support**: Local cache with Firestore sync when online  
✅ **Automatic fallback**: Uses local storage if Firestore is unavailable  
✅ **Package integration**: Works seamlessly with parent app's user system
