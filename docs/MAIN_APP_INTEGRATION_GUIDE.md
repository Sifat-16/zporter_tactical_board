# Zporter Tactical Board - Integration Guide for Main App

**Package Version:** 1.0.4+22  
**Date:** November 22, 2025  
**Critical:** Local-First Architecture Update

---

## ⚠️ BREAKING CHANGE: Async Initialization Required

The Zporter Tactical Board package has been updated to use a **local-first architecture**. This means Firebase initialization happens **asynchronously in the background** and no longer blocks app startup.

### What Changed:
- ✅ **Old:** Firebase initialized synchronously (blocking)
- ✅ **New:** Firebase initializes in background (non-blocking)
- ✅ **Benefit:** App starts instantly, works offline immediately

---

## 🚨 SYMPTOM: App Stuck at Logo/Splash Screen

If your main app is stuck at the logo after integrating the updated package, it's because:

1. Firebase is initializing asynchronously
2. Your main app is waiting for something that's now delayed
3. The tactical board package initialization completes immediately, but Firebase connects later

---

## ✅ SOLUTION: Update Your Main App Integration

### Step 1: Update Initialization Call

**BEFORE (Blocking - Don't use):**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ❌ OLD: This now returns immediately (non-blocking)
  await initializeTacticBoardDependencies();
  
  // Your app tries to use Firebase immediately → FAILS
  runApp(MyApp());
}
```

**AFTER (Non-Blocking - Use this):**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ NEW: Initialize package (returns immediately)
  await initializeTacticBoardDependencies();
  
  // ✅ IMPORTANT: Don't use Firebase immediately!
  // Firebase is initializing in background
  
  runApp(MyApp());
}
```

---

## 📱 Step 2: Add Splash Screen to Your Main App

Since Firebase initializes asynchronously, your main app should show a splash screen while waiting:

### Option A: Simple Splash (Recommended)

```dart
// lib/main.dart in YOUR main app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize tactical board package (instant return)
  await initializeTacticBoardDependencies();
  
  runApp(MyMainApp());
}

class MyMainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Show splash first
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Wait a moment for Firebase to initialize in background
    await Future.delayed(Duration(seconds: 1));
    
    // Now navigate to your main screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => YourMainScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.yellow),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Option B: Check Firebase Status (Advanced)

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isFirebaseReady = false;
  String _status = 'Initializing...';
  
  @override
  void initState() {
    super.initState();
    _waitForFirebase();
  }
  
  Future<void> _waitForFirebase() async {
    try {
      // Wait for Firebase to be ready (max 10 seconds)
      await Firebase.app().whenComplete().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('[MainApp] Firebase timed out - continuing in offline mode');
          setState(() {
            _status = 'Running in offline mode';
          });
        },
      );
      
      setState(() {
        _isFirebaseReady = true;
        _status = 'Connected!';
      });
      
      // Small delay to show success message
      await Future.delayed(Duration(milliseconds: 500));
      
    } catch (e) {
      print('[MainApp] Firebase error: $e - continuing anyway');
      setState(() {
        _status = 'Offline mode';
      });
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    // Navigate to main screen (works with or without Firebase)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => YourMainScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 24),
            if (!_isFirebaseReady)
              CircularProgressIndicator(color: Colors.yellow),
            if (_isFirebaseReady)
              Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 Step 3: Handle Firebase Dependencies Properly

### If Your Main App Uses Firebase Directly:

**BEFORE:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeTacticBoardDependencies();
  
  // ❌ PROBLEM: Firebase might not be ready yet!
  await FirebaseAnalytics.instance.logAppOpen();
  
  runApp(MyApp());
}
```

**AFTER:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeTacticBoardDependencies();
  
  // ✅ FIX: Run Firebase operations AFTER splash screen
  runApp(MyApp());
}

// In your splash screen or main screen:
@override
void initState() {
  super.initState();
  
  // Now it's safe to use Firebase
  _initializeFirebaseFeatures();
}

Future<void> _initializeFirebaseFeatures() async {
  try {
    await Firebase.app().whenComplete();
    await FirebaseAnalytics.instance.logAppOpen();
    // ... other Firebase operations
  } catch (e) {
    print('Firebase not available: $e');
    // App continues working with local data
  }
}
```

---

## 🎯 Step 4: Update TacticBoard Widget Integration

### Opening the Tactical Board from Your App:

**BEFORE:**
```dart
// ❌ OLD: Immediate navigation might fail
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => TacticboardScreen(userId: userId),
  ),
);
```

**AFTER:**
```dart
// ✅ NEW: Check if tactical board is ready
Future<void> _openTacticBoard() async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(child: CircularProgressIndicator()),
  );
  
  // Small delay to ensure package is initialized
  await Future.delayed(Duration(milliseconds: 500));
  
  // Close loading
  Navigator.pop(context);
  
  // Now open tactical board
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TacticboardScreen(
        userId: userId,
        collectionId: collectionId, // optional
        animationId: animationId,   // optional
      ),
    ),
  );
}
```

---

## 🔍 Step 5: Debug Logging

Add these logs to track initialization in your main app:

```dart
void main() async {
  print('[MainApp] ===== App Starting =====');
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[MainApp] Initializing Zporter Tactical Board package...');
  await initializeTacticBoardDependencies();
  print('[MainApp] Package initialized (local-first mode)');
  
  print('[MainApp] Launching UI...');
  runApp(MyApp());
  print('[MainApp] ===== App UI Launched =====');
}
```

**Expected Console Output:**
```
[MainApp] ===== App Starting =====
[MainApp] Initializing Zporter Tactical Board package...
[Init] Starting Firebase initialization in background...
[Init] Sembast database initialized at: ...
[Init] ===== App initialization complete - Showing UI =====
[MainApp] Package initialized (local-first mode)
[MainApp] Launching UI...
[MainApp] ===== App UI Launched =====
[TacticPage] ===== initState called - Widget is initializing =====
[TacticPage] ===== build() called - Rendering UI =====
[Init] Firebase initialized successfully  ← Happens AFTER UI shows
[Init] Firebase services configured
```

---

## ⚡ Step 6: Offline-First Behavior

The tactical board package now works **offline-first**:

### What This Means for Your App:

1. **First Launch (No Internet):**
   - ✅ App starts immediately
   - ✅ Local Sembast database works
   - ✅ Users can create tactics
   - ⏳ Firebase sync pending (will sync when online)

2. **With Internet:**
   - ✅ App starts immediately
   - ✅ Local data available instantly
   - 🌐 Firebase syncs in background (3-5 seconds)
   - ✅ Cloud backup automatic

3. **Offline → Online Transition:**
   - ✅ Automatic sync when connection restored
   - ✅ No data loss
   - ✅ Queue-based synchronization

### No Changes Needed:
Your app doesn't need to handle sync logic. The package manages it automatically.

---

## 🐛 Troubleshooting

### Issue 1: "App still stuck at logo"

**Diagnosis:**
```dart
// Add this in your main.dart
void main() async {
  print('[DEBUG] Step 1: Before WidgetsFlutterBinding');
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[DEBUG] Step 2: Before tactical board init');
  await initializeTacticBoardDependencies();
  
  print('[DEBUG] Step 3: Before runApp');
  runApp(MyApp());
  
  print('[DEBUG] Step 4: After runApp');
}
```

**If logs stop at "Step 2":** The package initialization is hanging. Check your Flutter version and dependencies.

**If logs stop at "Step 3":** Your `MyApp` widget has issues. Check `build()` method.

**If logs complete but UI doesn't show:** Check your splash screen implementation.

---

### Issue 2: "Firebase errors after update"

**Error:** `MissingPluginException` or `Firebase not initialized`

**Fix:**
```dart
// Wrap Firebase calls in try-catch
try {
  await Firebase.app(); // Check if initialized
  await FirebaseAnalytics.instance.logEvent(name: 'app_open');
} catch (e) {
  print('[MainApp] Firebase not ready: $e');
  // Continue without Firebase (offline mode)
}
```

---

### Issue 3: "Tactical board shows black screen"

**Fix:** Ensure you're passing required parameters:

```dart
TacticboardScreen(
  userId: 'your_user_id', // REQUIRED
  collectionId: null,      // Optional
  animationId: null,       // Optional
)
```

---

## 📋 Complete Integration Checklist

Use this checklist when updating your main app:

- [ ] Updated `main()` to NOT wait for Firebase synchronously
- [ ] Added splash screen (1-2 seconds minimum)
- [ ] Moved Firebase operations to after splash
- [ ] Added debug logging
- [ ] Tested app launch (with internet)
- [ ] Tested app launch (without internet)
- [ ] Tested tactical board navigation
- [ ] Verified Firebase sync happens in background
- [ ] Removed any hardcoded Firebase waits/delays
- [ ] Updated error handling for offline scenarios

---

## 🎯 Minimal Integration Example

If you want the absolute minimum changes:

```dart
// YOUR MAIN APP: lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize package (instant return)
  await initializeTacticBoardDependencies();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashThenMain(),
    );
  }
}

class SplashThenMain extends StatefulWidget {
  @override
  _SplashThenMainState createState() => _SplashThenMainState();
}

class _SplashThenMainState extends State<SplashThenMain> {
  @override
  void initState() {
    super.initState();
    // Wait 1 second then show main screen
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => YourActualMainScreen()),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

---

## 📞 Support

If you're still experiencing issues:

1. **Check package version:** Ensure you have `zporter_tactical_board: 1.0.4+22` or later
2. **Clean build:** Run `flutter clean && flutter pub get`
3. **Check Flutter version:** Requires Flutter 3.4.3+
4. **Review logs:** Look for `[Init]` and `[MainApp]` prefixed messages
5. **Contact:** Provide console logs showing the hang point

---

## ✅ Success Indicators

Your integration is successful when:

1. ✅ App shows splash screen within 1 second
2. ✅ Console shows `[Init] ===== App initialization complete - Showing UI =====`
3. ✅ Main screen appears within 2 seconds
4. ✅ Tactical board opens without delay
5. ✅ App works offline (create tactics without internet)
6. ✅ Data syncs automatically when online

---

## 🔄 Migration Timeline

**Recommended approach:**

1. **Day 1:** Update your main app with splash screen
2. **Day 2:** Test offline functionality
3. **Day 3:** Deploy to beta testers
4. **Day 4-5:** Monitor for issues
5. **Day 6:** Deploy to production

**Total migration time:** 1 week (with testing)

---

## 📖 Related Documentation

- Zporter Tactical Board Package Docs: `/docs/PHASE_2_ARCHITECTURE.md`
- Offline-First Architecture: `/docs/ARCHITECTURE_PHASES.md`
- Sync System: `/docs/PHASE_2_COMPLETE.md`

---

**Last Updated:** November 22, 2025  
**Package Version:** 1.0.4+22  
**Architecture:** Local-First with Background Firebase Sync

