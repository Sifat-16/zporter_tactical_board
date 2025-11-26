# MARK 42: Unity Integration Guide - Step by Step

**Document:** 02 - Flutter + Unity Bridge Setup  
**Last Updated:** November 20, 2025  
**Estimated Time:** 2-3 days for POC

---

## 🎯 PHASE 1: PROOF OF CONCEPT (Week 1)

### Goal: Spinning 3D ball inside Flutter app

By end of this phase, you'll have:
- ✅ Unity embedded in Flutter app
- ✅ Bidirectional communication working
- ✅ 3D ball rotating on screen
- ✅ Button in Flutter that controls Unity

---

## 📦 PREREQUISITES

### Software Requirements:
```bash
# Flutter (already have)
flutter --version  # Should be 3.16+

# Unity Hub & Unity Editor
Download from: https://unity.com/download
Install Unity 2022.3 LTS (Long Term Support)

# Android Studio (for Android builds)
# Xcode (for iOS builds - macOS only)
```

### Unity License:
- **Free Personal License** is fine for POC
- **Unity Pro** required for production ($185/month - removes splash screen)

### Flutter Package:
```bash
flutter pub add flutter_unity_widget
```

---

## 🔧 STEP-BY-STEP INTEGRATION

### **Step 1: Create Unity Project** (30 mins)

1. **Open Unity Hub** → **New Project**
2. **Template:** 3D (URP - Universal Render Pipeline)
3. **Project Name:** `ZporterTacticalUnity`
4. **Location:** `~/UnityProjects/ZporterTacticalUnity`
5. Click **Create Project**

6. **Wait for Unity to open** (first time takes 5-10 mins)

7. **Configure for Mobile:**
   - File → Build Settings
   - Switch Platform to **Android** (or iOS)
   - Click **Switch Platform** (takes 2-3 mins)

---

### **Step 2: Install Unity Packages** (15 mins)

1. **Window → Package Manager**
2. Install these packages:
   - **Universal RP** (should be installed)
   - **AI Navigation** (for NavMesh pathfinding)
   - **Cinemachine** (for camera controls)

3. **Create URP Asset:**
   - Right-click in Project → Create → Rendering → URP Asset
   - Name it `ZporterURPSettings`
   - Edit → Project Settings → Graphics → Set as Scriptable Render Pipeline

---

### **Step 3: Create Simple 3D Scene** (30 mins)

1. **Delete Main Camera** (we'll use Cinemachine)

2. **Create Soccer Ball:**
   ```
   GameObject → 3D Object → Sphere
   Name: "SoccerBall"
   Position: (0, 0, 0)
   Scale: (0.22, 0.22, 0.22)  // Regulation ball size in meters
   ```

3. **Add Material:**
   ```
   Right-click → Create → Material → "BallMaterial"
   Set Albedo color to white
   Drag onto SoccerBall
   ```

4. **Add Ground Plane:**
   ```
   GameObject → 3D Object → Plane
   Name: "Ground"
   Position: (0, -1, 0)
   Scale: (10, 1, 10)
   Color: Green
   ```

5. **Add Light:**
   ```
   GameObject → Light → Directional Light
   Rotation: (50, -30, 0)
   Intensity: 1
   ```

6. **Add Camera:**
   ```
   GameObject → Cinemachine → Virtual Camera
   Name: "MainCamera"
   Position: (0, 5, -10)
   Look at: (0, 0, 0)
   ```

7. **Test:** Press **Play** button - You should see a white ball on green ground

---

### **Step 4: Add Rotation Script** (20 mins)

1. **Create Script:**
   ```
   Right-click in Assets → Create → C# Script
   Name: "BallRotator"
   ```

2. **Double-click to open in Visual Studio / Rider**

3. **Write Code:**
   ```csharp
   using UnityEngine;
   
   public class BallRotator : MonoBehaviour
   {
       public float rotationSpeed = 50f;
       private bool isRotating = false;
       
       void Update()
       {
           if (isRotating)
           {
               transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
           }
       }
       
       // Called from Flutter
       public void SetRotationSpeed(float speed)
       {
           rotationSpeed = speed;
       }
       
       public void StartRotation()
       {
           isRotating = true;
           Debug.Log("Ball rotation started");
       }
       
       public void StopRotation()
       {
           isRotating = false;
           Debug.Log("Ball rotation stopped");
       }
   }
   ```

4. **Attach to Ball:**
   - Select SoccerBall in Hierarchy
   - Drag `BallRotator` script onto it (or Add Component → BallRotator)

5. **Test:** Press Play, ball should now rotate continuously

---

### **Step 5: Create Flutter Bridge** (45 mins)

1. **Create Bridge Script:**
   ```
   Assets → Create → C# Script → "FlutterBridge"
   ```

2. **Implement Bridge:**
   ```csharp
   using System;
   using UnityEngine;
   using Newtonsoft.Json.Linq;
   
   public class FlutterBridge : MonoBehaviour
   {
       private static FlutterBridge _instance;
       public static FlutterBridge Instance
       {
           get
           {
               if (_instance == null)
               {
                   GameObject go = new GameObject("FlutterBridge");
                   _instance = go.AddComponent<FlutterBridge>();
                   DontDestroyOnLoad(go);
               }
               return _instance;
           }
       }
       
       // Reference to ball
       private BallRotator ballRotator;
       
       void Start()
       {
           ballRotator = FindObjectOfType<BallRotator>();
       }
       
       // Called from Flutter via flutter_unity_widget
       public void OnFlutterMessage(string message)
       {
           Debug.Log($"Received from Flutter: {message}");
           
           try
           {
               JObject json = JObject.Parse(message);
               string type = json["type"].ToString();
               
               switch (type)
               {
                   case "START_ROTATION":
                       ballRotator?.StartRotation();
                       SendToFlutter("ROTATION_STARTED");
                       break;
                       
                   case "STOP_ROTATION":
                       ballRotator?.StopRotation();
                       SendToFlutter("ROTATION_STOPPED");
                       break;
                       
                   case "SET_SPEED":
                       float speed = float.Parse(json["speed"].ToString());
                       ballRotator?.SetRotationSpeed(speed);
                       break;
               }
           }
           catch (Exception e)
           {
               Debug.LogError($"Error parsing Flutter message: {e.Message}");
           }
       }
       
       // Send message to Flutter
       public void SendToFlutter(string message)
       {
           Debug.Log($"Sending to Flutter: {message}");
           UnityMessageManager.Instance.SendMessageToFlutter(message);
       }
   }
   ```

3. **Create GameObject for Bridge:**
   - GameObject → Create Empty
   - Name: "FlutterBridge"
   - Add Component → FlutterBridge script

---

### **Step 6: Export Unity Project** (30 mins)

#### For Android:

1. **File → Build Settings**
2. **Platform:** Android
3. Check **"Export Project"** ✅
4. **Export Path:** `<your_flutter_project>/android/unityLibrary`
5. Click **Export**

6. **Update android/build.gradle:**
   ```gradle
   // Add to repositories
   flatDir {
       dirs "${project(':unityLibrary').projectDir}/libs"
   }
   ```

7. **Update android/settings.gradle:**
   ```gradle
   include ':unityLibrary'
   ```

#### For iOS:

1. **File → Build Settings**
2. **Platform:** iOS
3. Check **"Export Project"** ✅
4. **Export Path:** `<your_flutter_project>/ios/UnityLibrary`
5. Click **Export**

6. **Update ios/Podfile:**
   ```ruby
   target 'Runner' do
     # ... existing pods
     
     # Unity
     pod 'UnityFramework', :path => 'UnityLibrary/Unity-iPhone.xcodeproj'
   end
   ```

---

### **Step 7: Flutter Integration** (60 mins)

1. **Install Package:**
   ```yaml
   # pubspec.yaml
   dependencies:
     flutter_unity_widget: ^2022.2.0
   ```

2. **Create Unity Widget Screen:**
   ```dart
   // lib/presentation/tactic/view/component/unity/unity_3d_view.dart
   
   import 'package:flutter/material.dart';
   import 'package:flutter_unity_widget/flutter_unity_widget.dart';
   import 'dart:convert';
   
   class Unity3DView extends StatefulWidget {
     const Unity3DView({Key? key}) : super(key: key);
     
     @override
     State<Unity3DView> createState() => _Unity3DViewState();
   }
   
   class _Unity3DViewState extends State<Unity3DView> {
     UnityWidgetController? _unityController;
     bool isRotating = false;
     double rotationSpeed = 50.0;
     
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('3D View'),
           backgroundColor: Colors.black,
         ),
         body: Column(
           children: [
             // Unity Viewport
             Expanded(
               child: UnityWidget(
                 onUnityCreated: _onUnityCreated,
                 onUnityMessage: _onUnityMessage,
                 fullscreen: false,
               ),
             ),
             
             // Controls
             Container(
               padding: EdgeInsets.all(16),
               color: Colors.black87,
               child: Column(
                 children: [
                   // Start/Stop Button
                   ElevatedButton(
                     onPressed: _toggleRotation,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: isRotating ? Colors.red : Colors.green,
                     ),
                     child: Text(isRotating ? 'Stop Rotation' : 'Start Rotation'),
                   ),
                   
                   SizedBox(height: 16),
                   
                   // Speed Slider
                   Row(
                     children: [
                       Text('Speed:', style: TextStyle(color: Colors.white)),
                       Expanded(
                         child: Slider(
                           value: rotationSpeed,
                           min: 0,
                           max: 200,
                           divisions: 20,
                           label: rotationSpeed.round().toString(),
                           onChanged: (value) {
                             setState(() {
                               rotationSpeed = value;
                             });
                             _sendSpeedToUnity(value);
                           },
                         ),
                       ),
                       Text('${rotationSpeed.round()}', 
                            style: TextStyle(color: Colors.white)),
                     ],
                   ),
                 ],
               ),
             ),
           ],
         ),
       );
     }
     
     void _onUnityCreated(UnityWidgetController controller) {
       _unityController = controller;
       print('Unity initialized successfully!');
     }
     
     void _onUnityMessage(dynamic message) {
       print('Message from Unity: $message');
       // Handle Unity callbacks
       if (message == 'ROTATION_STARTED') {
         setState(() => isRotating = true);
       } else if (message == 'ROTATION_STOPPED') {
         setState(() => isRotating = false);
       }
     }
     
     void _toggleRotation() {
       final message = isRotating ? 'STOP_ROTATION' : 'START_ROTATION';
       _sendToUnity({'type': message});
     }
     
     void _sendSpeedToUnity(double speed) {
       _sendToUnity({
         'type': 'SET_SPEED',
         'speed': speed,
       });
     }
     
     void _sendToUnity(Map<String, dynamic> message) {
       if (_unityController != null) {
         final jsonMessage = jsonEncode(message);
         _unityController!.postMessage(
           'FlutterBridge',
           'OnFlutterMessage',
           jsonMessage,
         );
       }
     }
     
     @override
     void dispose() {
       _unityController?.dispose();
       super.dispose();
     }
   }
   ```

3. **Add to Navigation:**
   ```dart
   // lib/presentation/tactic/view/component/righttoolbar/settings_toolbar_component.dart
   
   // Add button to settings toolbar
   ElevatedButton(
     onPressed: () {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (_) => Unity3DView()),
       );
     },
     child: Text('Switch to 3D View'),
   ),
   ```

---

### **Step 8: Build & Test** (45 mins)

1. **Android:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **iOS:**
   ```bash
   cd ios
   pod install
   cd ..
   flutter run
   ```

3. **Expected Result:**
   - Tap "Switch to 3D View"
   - See white ball on green ground
   - Tap "Start Rotation" → Ball spins
   - Move slider → Speed changes
   - Tap "Stop Rotation" → Ball stops

---

## 🐛 TROUBLESHOOTING

### Issue: "Unity not found"
```
Solution:
1. Check android/settings.gradle includes :unityLibrary
2. Verify export path is correct
3. Rebuild: flutter clean && flutter run
```

### Issue: "Method channel error"
```
Solution:
1. Ensure FlutterBridge GameObject exists in Unity scene
2. Check UnityMessageManager is in Unity project
3. Verify flutter_unity_widget package is latest version
```

### Issue: "Black screen in Unity view"
```
Solution:
1. Check camera is positioned correctly
2. Verify lighting exists in scene
3. Check URP settings are applied
4. Try building in Development Mode for better error logs
```

### Issue: "Gradle build fails"
```
Solution:
1. Update android/gradle.properties:
   android.useAndroidX=true
   android.enableJetifier=true
2. Update minSdkVersion to 21 in android/app/build.gradle
3. Clear Gradle cache: cd android && ./gradlew clean
```

### Issue: "iOS build fails"
```
Solution:
1. Check Podfile syntax is correct
2. Run: cd ios && pod deintegrate && pod install
3. Open .xcworkspace (not .xcodeproj) in Xcode
4. Clean build folder: Cmd+Shift+K
```

---

## 📊 PERFORMANCE OPTIMIZATION

### Reduce App Size:
```
Unity Build Settings:
- Compression: LZ4 (faster) or LZ4HC (smaller)
- Strip Engine Code: Yes
- IL2CPP Code Generation: Faster Runtime
- Target API Level: Auto
```

### Improve FPS:
```
Unity Project Settings:
- Quality: Medium (for mobile)
- Anti-Aliasing: 2x or disabled
- Shadows: Soft Shadows (or hard)
- Texture Quality: Full Res
- V-Sync: Off (let Flutter handle)
```

### Memory Management:
```csharp
// In Unity scripts
void OnDestroy()
{
    // Clean up resources
    Resources.UnloadUnusedAssets();
}
```

---

## ✅ POC SUCCESS CRITERIA

After completing this guide, you should have:

- [x] Unity embedded in Flutter app
- [x] 3D ball rendering correctly
- [x] Flutter button controls Unity
- [x] Unity sends messages back to Flutter
- [x] Builds successfully on Android/iOS
- [x] No crashes or black screens
- [x] 60 FPS on test device

**If all checkboxes pass → Proceed to Phase 2 (Full 3D Engine)**

---

## 🎯 NEXT STEPS

1. **Show POC to stakeholders**
2. **Gather feedback from 5 beta users**
3. **Estimate full feature development**
4. **Read Document 03: Data Migration Strategy**
5. **Read Document 04: Physics Requirements**

---

## 📚 HELPFUL RESOURCES

- Flutter Unity Widget Docs: https://pub.dev/packages/flutter_unity_widget
- Unity Scripting API: https://docs.unity3d.com/ScriptReference/
- Unity Learn: https://learn.unity.com/
- Community: Unity Forums, Stack Overflow

---

## 🤝 GETTING HELP

If stuck:
1. Check Unity Console for errors (Window → Console)
2. Check Flutter logs: `flutter run --verbose`
3. Search Unity Asset Store for "Flutter Bridge" examples
4. Ask on Unity Forums: https://forum.unity.com/
5. Flutter Discord: https://discord.gg/flutter

---

**Time Investment:**
- Setup: 3-4 hours
- Learning: 1-2 days
- POC Polish: 1-2 days
- **Total: 3-5 days for working prototype**

**Budget:**
- Unity Personal: Free
- flutter_unity_widget: Free
- Developer time: $500-1500
- **Total: Under $2K for POC**

You now have a complete roadmap to get Unity running inside your Flutter app! 🚀

