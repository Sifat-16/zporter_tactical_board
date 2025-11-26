# MARK 42: Technical Architecture - Flutter + Unity Hybrid

**Document:** 01 - Detailed System Design  
**Last Updated:** November 20, 2025

---

## 🏗️ SYSTEM OVERVIEW

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUTTER APPLICATION                         │
│                  (Existing + Enhanced)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   UI Layer   │  │  State Mgmt  │  │   Services   │         │
│  │              │  │              │  │              │         │
│  │ • Toolbars   │  │ • Riverpod   │  │ • Firebase   │         │
│  │ • Settings   │  │ • Providers  │  │ • Sembast    │         │
│  │ • Navigation │  │ • Notifiers  │  │ • Sync Queue │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
│  ┌──────────────────────────────────────────────────┐         │
│  │        RENDERING MODE CONTROLLER                 │         │
│  │                                                  │         │
│  │  ┌────────────┐          ┌──────────────┐      │         │
│  │  │ 2D Mode    │   OR     │ 3D Mode      │      │         │
│  │  │ (Flame)    │◄────────►│ (Unity)      │      │         │
│  │  └────────────┘          └──────────────┘      │         │
│  └──────────────────────────────────────────────────┘         │
│                           │                                     │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            │ Platform Channel
                            │ (JSON Messages)
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    UNITY ENGINE                                 │
│                (3D Rendering Module)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Scene Manager│  │  Physics Sys │  │ Animation Sys│         │
│  │              │  │              │  │              │         │
│  │ • Field      │  │ • PhysX      │  │ • Player IK  │         │
│  │ • Players    │  │ • Ball       │  │ • Mecanim    │         │
│  │ • Equipment  │  │ • Collisions │  │ • Blending   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Camera System│  │ Render Pipeline│ │Flutter Bridge│         │
│  │              │  │              │  │              │         │
│  │ • Orbit      │  │ • URP        │  │ • Messages   │         │
│  │ • Follow     │  │ • Post FX    │  │ • Callbacks  │         │
│  │ • Replay     │  │ • Shadows    │  │ • Events     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 DATA FLOW ARCHITECTURE

### 1. User Creates Animation (3D Mode)

```
User Drags Player Icon
        │
        ▼
┌───────────────────────┐
│ Flutter UI (Toolbar)  │
│ Detects drag gesture  │
└───────────┬───────────┘
            │
            ▼
┌──────────────────────────────┐
│ BoardProvider (Riverpod)     │
│ addBoardComponent(player)    │
└──────────┬───────────────────┘
            │
            ├────────────────────┐
            │                    │
            ▼                    ▼
┌─────────────────────┐  ┌──────────────────────┐
│ 2D Mode (Flame)     │  │ 3D Mode (Unity)      │
│ PlayerComponent     │  │ UnityBridge.send()   │
│ adds to canvas      │  │ message: {           │
└─────────────────────┘  │   type: "ADD_PLAYER" │
                         │   id: "abc123"       │
                         │   position: [x,y,z]  │
                         │   team: "home"       │
                         │ }                    │
                         └──────────┬───────────┘
                                    │
                                    │ Platform Channel
                                    ▼
                         ┌──────────────────────┐
                         │ Unity Game Manager   │
                         │ HandleMessage()      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ PlayerFactory.cs     │
                         │ Instantiate(prefab)  │
                         │ SetPosition()        │
                         │ SetTeamColor()       │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ 3D Player appears    │
                         │ on Unity scene       │
                         └──────────────────────┘
```

### 2. Animation Playback (3D Mode)

```
User Clicks "Play"
        │
        ▼
┌──────────────────────────────┐
│ AnimationProvider            │
│ playAnimation()              │
└──────────┬───────────────────┘
            │
            ▼
┌──────────────────────────────┐
│ AnimationController3D        │
│ Prepares scene transitions   │
│ Scene 1 → Scene 2 → Scene 3  │
└──────────┬───────────────────┘
            │
            │ For each transition:
            ▼
┌──────────────────────────────┐
│ UnityBridge.send({           │
│   type: "PLAY_SCENE",        │
│   sceneData: {               │
│     duration: 2.5,           │
│     movements: [             │
│       {                      │
│         componentId: "p1",   │
│         startPos: [x,y,z],   │
│         endPos: [x2,y2,z2],  │
│         trajectory: {        │
│           type: "curve",     │
│           controlPoints: [], │
│           speed: 5.0         │
│         }                    │
│       }                      │
│     ],                       │
│     ballActions: [...]       │
│   }                          │
│ })                           │
└──────────┬───────────────────┘
            │
            ▼
┌──────────────────────────────┐
│ Unity AnimationController.cs │
│ ParseSceneData()             │
└──────────┬───────────────────┘
            │
            ├──────────────────┬─────────────────┐
            ▼                  ▼                 ▼
┌─────────────────┐ ┌──────────────┐ ┌────────────────┐
│ Player Movement │ │ Ball Physics │ │ Camera Control │
│ • NavMesh path  │ │ • Trajectory │ │ • Follow mode  │
│ • Run animation │ │ • Spin       │ │ • Smoothing    │
│ • IK for ground │ │ • Bounce     │ └────────────────┘
└─────────────────┘ └──────────────┘
            │                  │
            │     Events fired │
            └──────────┬────────┘
                       ▼
┌──────────────────────────────┐
│ Unity → Flutter Callback     │
│ {                            │
│   type: "SCENE_COMPLETE",    │
│   sceneIndex: 2,             │
│   timestamp: 12.5            │
│ }                            │
└──────────┬───────────────────┘
            │
            ▼
┌──────────────────────────────┐
│ AnimationProvider            │
│ onSceneComplete()            │
│ → Load next scene            │
└──────────────────────────────┘
```

---

## 🗂️ DATA MODEL CHANGES

### Existing Models (Backward Compatible)

```dart
// UNCHANGED - 2D models stay as-is
class AnimationItemModel {
  String id;
  int index;
  List<FieldItemModel> components;  // 2D positions (Vector2)
  AnimationTrajectoryData? trajectoryData;  // 2D curves
  Duration sceneDuration;
  // ... existing fields
}
```

### NEW: 3D Extension Models

```dart
// NEW FILE: lib/data/animation/model/animation_item_model_3d.dart

class AnimationItemModel3D extends AnimationItemModel {
  // All 2D fields inherited
  
  // NEW 3D-specific fields:
  List<FieldItemModel3D> components3D;  // 3D positions (Vector3)
  AnimationTrajectoryData3D? trajectoryData3D;  // 3D curves with height
  CameraConfig? cameraConfig;
  PhysicsConfig? physicsConfig;
  String renderMode;  // "2d" | "3d"
  
  AnimationItemModel3D({
    required super.id,
    required super.index,
    required super.components,
    required this.components3D,
    this.trajectoryData3D,
    this.cameraConfig,
    this.physicsConfig,
    this.renderMode = "2d",  // Default to 2D for backward compat
    // ... super fields
  });
  
  // Conversion methods
  static AnimationItemModel3D from2D(AnimationItemModel model2D) {
    return AnimationItemModel3D(
      // Copy all 2D fields
      id: model2D.id,
      components: model2D.components,
      // Convert 2D → 3D
      components3D: model2D.components.map((c) => 
        FieldItemModel3D.from2D(c)
      ).toList(),
      trajectoryData3D: AnimationTrajectoryData3D.from2D(
        model2D.trajectoryData
      ),
      renderMode: "2d",  // Start in 2D mode
    );
  }
  
  AnimationItemModel to2D() {
    // Project 3D back to 2D for fallback
    return AnimationItemModel(
      id: id,
      components: components3D.map((c) => c.to2D()).toList(),
      // ... flatten 3D → 2D
    );
  }
}

// NEW: 3D Position wrapper
class FieldItemModel3D {
  FieldItemModel item2D;  // Keep 2D data for compatibility
  Vector3 position3D;  // Unity Vector3 (x, y, z)
  Quaternion rotation3D;  // Unity rotation
  float heightOffset;  // For jumping, headers
  
  // Collision data
  ColliderType colliderType;
  float colliderRadius;
  
  static FieldItemModel3D from2D(FieldItemModel item) {
    return FieldItemModel3D(
      item2D: item,
      position3D: Vector3(
        item.offset!.x,
        0.0,  // Ground level
        item.offset!.y,  // Map 2D Y to 3D Z
      ),
      rotation3D: Quaternion.fromAngle(item.angle ?? 0),
      heightOffset: 0.0,
    );
  }
}

// NEW: 3D Trajectory with height
class AnimationTrajectoryData3D {
  Map<String, TrajectoryPathModel3D> componentTrajectories;
  
  // 3D-specific properties
  bool usePhysics;  // True = ball follows physics, False = scripted path
  float gravity;  // Custom gravity multiplier
  
  static AnimationTrajectoryData3D from2D(
    AnimationTrajectoryData? data2D
  ) {
    if (data2D == null) return AnimationTrajectoryData3D();
    
    return AnimationTrajectoryData3D(
      componentTrajectories: data2D.componentTrajectories.map(
        (id, path2D) => MapEntry(
          id,
          TrajectoryPathModel3D.from2D(path2D),
        ),
      ),
      usePhysics: false,  // Start with scripted paths
      gravity: 1.0,
    );
  }
}

class TrajectoryPathModel3D {
  List<ControlPoint3D> controlPoints;  // Now with height (y-axis)
  PathType pathType;
  float speedMultiplier;
  
  // 3D-specific
  AnimationType animationType;  // RUN, WALK, SPRINT, JUMP
  bool useIK;  // Inverse Kinematics for feet placement
}

// NEW: Camera configuration
class CameraConfig {
  CameraMode mode;  // ORBIT, FOLLOW, FIXED, REPLAY
  Vector3 targetPosition;
  float distance;
  float angle;
  float fov;
  
  CameraConfig({
    this.mode = CameraMode.ORBIT,
    this.distance = 30.0,
    this.angle = 45.0,
    this.fov = 60.0,
  });
}

enum CameraMode {
  ORBIT,      // User can rotate around field
  FOLLOW,     // Track specific player
  FIXED,      // TV camera angle
  REPLAY,     // Cinematic replay
  TACTICAL,   // Top-down (like 2D)
}

// NEW: Physics configuration
class PhysicsConfig {
  float ballMass;
  float ballDrag;
  float playerMass;
  float frictionCoefficient;
  bool enableCollisions;
  
  PhysicsConfig({
    this.ballMass = 0.45,  // FIFA regulation
    this.ballDrag = 0.05,
    this.playerMass = 75.0,  // Average player
    this.frictionCoefficient = 0.6,
    this.enableCollisions = true,
  });
}
```

### Database Schema (Firestore)

```javascript
// collection: animation_collections/{collectionId}
{
  id: "col_123",
  name: "Set Pieces",
  userId: "user_456",
  animations: [
    {
      id: "anim_789",
      name: "Corner Kick Routine",
      scenes: [
        {
          id: "scene_1",
          index: 0,
          // BACKWARD COMPATIBLE - Keep 2D data
          components: [...],  // 2D FieldItemModel[]
          trajectoryData: {...},  // 2D trajectories
          
          // NEW - Add 3D data alongside
          renderMode: "3d",  // "2d" | "3d" | "hybrid"
          components3D: [
            {
              id: "player_1",
              position2D: {x: 100, y: 200},  // Keep 2D
              position3D: {x: 100, y: 0, z: 200},  // Add 3D
              rotation3D: {x: 0, y: 0, z: 0, w: 1},
              heightOffset: 0,
              collider: {type: "capsule", radius: 0.4}
            }
          ],
          trajectoryData3D: {...},
          cameraConfig: {
            mode: "orbit",
            distance: 30,
            angle: 45,
            fov: 60
          },
          physicsConfig: {
            ballMass: 0.45,
            enableCollisions: true
          }
        }
      ]
    }
  ]
}
```

**Key Points:**
- 🔒 **2D data always present** (backward compatibility)
- ✨ **3D data optional** (only when user enables 3D mode)
- 🔄 **Bi-directional conversion** (3D ↔ 2D)
- 📦 **Single document** (no data duplication in different collections)

---

## 🌉 FLUTTER ↔ UNITY BRIDGE

### Implementation: Platform Channels

```dart
// NEW FILE: lib/app/services/unity_bridge_service.dart

import 'package:flutter/services.dart';
import 'dart:convert';

class UnityBridgeService {
  static const MethodChannel _channel = MethodChannel('unity_bridge');
  
  // Singleton
  static final UnityBridgeService _instance = UnityBridgeService._internal();
  factory UnityBridgeService() => _instance;
  UnityBridgeService._internal();
  
  // Callbacks from Unity
  final Map<String, Function(dynamic)> _messageHandlers = {};
  
  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleUnityMessage);
    await sendMessage({'type': 'INITIALIZE', 'version': '1.0'});
  }
  
  // Flutter → Unity
  Future<void> sendMessage(Map<String, dynamic> message) async {
    try {
      await _channel.invokeMethod('sendToUnity', jsonEncode(message));
    } catch (e) {
      zlog(level: Level.error, data: "Unity bridge error: $e");
    }
  }
  
  // Unity → Flutter
  Future<void> _handleUnityMessage(MethodCall call) async {
    if (call.method == 'sendToFlutter') {
      final data = jsonDecode(call.arguments as String);
      final messageType = data['type'] as String;
      
      if (_messageHandlers.containsKey(messageType)) {
        _messageHandlers[messageType]!(data);
      }
    }
  }
  
  void registerHandler(String messageType, Function(dynamic) handler) {
    _messageHandlers[messageType] = handler;
  }
  
  // High-level API
  Future<void> addPlayer({
    required String id,
    required Vector3 position,
    required String team,
    String? customModelPath,
  }) async {
    await sendMessage({
      'type': 'ADD_PLAYER',
      'id': id,
      'position': {'x': position.x, 'y': position.y, 'z': position.z},
      'team': team,
      'customModel': customModelPath,
    });
  }
  
  Future<void> movePlayer({
    required String id,
    required Vector3 targetPosition,
    required double duration,
    required AnimationType animation,
    List<Vector3>? waypoints,
  }) async {
    await sendMessage({
      'type': 'MOVE_PLAYER',
      'id': id,
      'target': {'x': targetPosition.x, 'y': targetPosition.y, 'z': targetPosition.z},
      'duration': duration,
      'animation': animation.name,
      'waypoints': waypoints?.map((w) => {'x': w.x, 'y': w.y, 'z': w.z}).toList(),
    });
  }
  
  Future<void> kickBall({
    required String ballId,
    required Vector3 direction,
    required double power,
    required double spin,
    BallTrajectoryType type = BallTrajectoryType.ground,
  }) async {
    await sendMessage({
      'type': 'KICK_BALL',
      'ballId': ballId,
      'direction': {'x': direction.x, 'y': direction.y, 'z': direction.z},
      'power': power,
      'spin': spin,
      'trajectoryType': type.name,
    });
  }
  
  Future<void> setCamera({
    required CameraMode mode,
    Vector3? target,
    double? distance,
    double? angle,
  }) async {
    await sendMessage({
      'type': 'SET_CAMERA',
      'mode': mode.name,
      if (target != null) 'target': {'x': target.x, 'y': target.y, 'z': target.z},
      if (distance != null) 'distance': distance,
      if (angle != null) 'angle': angle,
    });
  }
  
  Future<void> playScene(AnimationItemModel3D scene) async {
    await sendMessage({
      'type': 'PLAY_SCENE',
      'sceneData': scene.toUnityJSON(),
    });
  }
}

enum AnimationType {
  IDLE, WALK, JOG, RUN, SPRINT, JUMP, KICK, HEADER, SLIDE
}

enum BallTrajectoryType {
  ground, lofted, chip, driven, knuckleball
}
```

### Unity Side (C#)

```csharp
// Unity: Assets/Scripts/FlutterBridge/UnityMessageHandler.cs

using System;
using System.Collections.Generic;
using UnityEngine;
using Newtonsoft.Json;

public class UnityMessageHandler : MonoBehaviour
{
    private static UnityMessageHandler _instance;
    
    // Unity → Flutter callback
    public delegate void FlutterMessageDelegate(string message);
    public static FlutterMessageDelegate OnSendToFlutter;
    
    void Awake()
    {
        if (_instance == null)
        {
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }
    }
    
    // Called from Flutter via Platform Channel
    public void OnFlutterMessage(string jsonMessage)
    {
        var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonMessage);
        string messageType = data["type"].ToString();
        
        switch (messageType)
        {
            case "ADD_PLAYER":
                HandleAddPlayer(data);
                break;
            case "MOVE_PLAYER":
                HandleMovePlayer(data);
                break;
            case "KICK_BALL":
                HandleKickBall(data);
                break;
            case "SET_CAMERA":
                HandleSetCamera(data);
                break;
            case "PLAY_SCENE":
                HandlePlayScene(data);
                break;
        }
    }
    
    void HandleAddPlayer(Dictionary<string, object> data)
    {
        string id = data["id"].ToString();
        var posData = (Dictionary<string, object>)data["position"];
        Vector3 position = new Vector3(
            Convert.ToSingle(posData["x"]),
            Convert.ToSingle(posData["y"]),
            Convert.ToSingle(posData["z"])
        );
        string team = data["team"].ToString();
        
        PlayerManager.Instance.SpawnPlayer(id, position, team);
        
        // Send confirmation back to Flutter
        SendToFlutter(new {
            type = "PLAYER_ADDED",
            id = id,
            success = true
        });
    }
    
    void HandleMovePlayer(Dictionary<string, object> data)
    {
        string id = data["id"].ToString();
        // ... parse movement data
        
        var player = PlayerManager.Instance.GetPlayer(id);
        if (player != null)
        {
            player.MoveTo(targetPosition, duration, animationType, waypoints);
        }
    }
    
    void HandleKickBall(Dictionary<string, object> data)
    {
        // Apply physics to ball
        var ball = BallManager.Instance.GetBall(data["ballId"].ToString());
        // ... apply force, spin, trajectory
    }
    
    public static void SendToFlutter(object data)
    {
        string json = JsonConvert.SerializeObject(data);
        OnSendToFlutter?.Invoke(json);
    }
}
```

---

## 🎮 UNITY PROJECT STRUCTURE

```
Unity Project/
├── Assets/
│   ├── Scenes/
│   │   └── TacticalBoard.unity (Main scene)
│   │
│   ├── Scripts/
│   │   ├── FlutterBridge/
│   │   │   ├── UnityMessageHandler.cs
│   │   │   └── FlutterCommunicator.cs
│   │   │
│   │   ├── Managers/
│   │   │   ├── GameManager.cs (Scene orchestration)
│   │   │   ├── PlayerManager.cs (Player spawning/pooling)
│   │   │   ├── BallManager.cs (Ball physics)
│   │   │   ├── CameraManager.cs (Camera controls)
│   │   │   └── AnimationManager.cs (Playback logic)
│   │   │
│   │   ├── Entities/
│   │   │   ├── Player/
│   │   │   │   ├── PlayerController.cs
│   │   │   │   ├── PlayerAnimator.cs
│   │   │   │   └── PlayerIK.cs
│   │   │   │
│   │   │   ├── Ball/
│   │   │   │   ├── BallPhysics.cs
│   │   │   │   ├── BallTrajectory.cs
│   │   │   │   └── BallEffects.cs (spin, curve)
│   │   │   │
│   │   │   └── Field/
│   │   │       ├── FieldRenderer.cs
│   │   │       └── FieldColliders.cs
│   │   │
│   │   ├── AI/
│   │   │   ├── PathfindingAgent.cs (NavMesh)
│   │   │   └── TrajectoryFollower.cs
│   │   │
│   │   └── Utilities/
│   │       ├── Vector3Extensions.cs
│   │       └── MathHelpers.cs
│   │
│   ├── Prefabs/
│   │   ├── Players/
│   │   │   ├── PlayerHome.prefab
│   │   │   └── PlayerAway.prefab
│   │   ├── Ball.prefab
│   │   ├── Equipment/
│   │   │   ├── Cone.prefab
│   │   │   └── Marker.prefab
│   │   └── Field/
│   │       └── SoccerField.prefab
│   │
│   ├── Materials/
│   │   ├── FieldGrass.mat
│   │   ├── PlayerSkinHome.mat
│   │   └── PlayerSkinAway.mat
│   │
│   ├── Animations/
│   │   ├── PlayerAnimController.controller
│   │   └── Clips/
│   │       ├── Idle.anim
│   │       ├── Walk.anim
│   │       ├── Run.anim
│   │       ├── Sprint.anim
│   │       ├── Kick.anim
│   │       └── Jump.anim
│   │
│   └── Models/
│       ├── Player_Rigged.fbx (From Asset Store)
│       ├── Ball.fbx
│       └── Field.fbx
│
└── Packages/
    ├── com.unity.ugui
    ├── com.unity.ai.navigation (NavMesh)
    └── com.unity.render-pipelines.universal (URP)
```

---

## 🔌 INTEGRATION POINTS

### 1. Board Provider Integration

```dart
// lib/presentation/tactic/view_model/board/board_provider_3d.dart

class BoardProvider3D extends BoardController {
  final UnityBridgeService _unityBridge = UnityBridgeService();
  bool _is3DMode = false;
  
  @override
  Future<void> addBoardComponent({required FieldItemModel fieldItemModel}) async {
    // Always update 2D state first
    await super.addBoardComponent(fieldItemModel: fieldItemModel);
    
    // If 3D mode, send to Unity
    if (_is3DMode) {
      final item3D = FieldItemModel3D.from2D(fieldItemModel);
      
      if (fieldItemModel is PlayerModel) {
        await _unityBridge.addPlayer(
          id: item3D.item2D.id,
          position: item3D.position3D,
          team: (fieldItemModel as PlayerModel).playerType.name,
        );
      } else if (fieldItemModel is EquipmentModel) {
        // Handle equipment
      }
    }
  }
  
  Future<void> toggle3DMode() async {
    _is3DMode = !_is3DMode;
    
    if (_is3DMode) {
      // Initialize Unity scene with current 2D state
      await _initializeUnityScene();
    } else {
      // Fall back to 2D
      await _unityBridge.sendMessage({'type': 'CLEAR_SCENE'});
    }
    
    state = state.copyWith(renderMode: _is3DMode ? '3d' : '2d');
  }
  
  Future<void> _initializeUnityScene() async {
    // Send all current board components to Unity
    for (var player in state.players) {
      final player3D = FieldItemModel3D.from2D(player);
      await _unityBridge.addPlayer(
        id: player.id,
        position: player3D.position3D,
        team: player.playerType.name,
      );
    }
    
    for (var equipment in state.equipments) {
      // ... add equipment
    }
  }
}
```

### 2. Animation Provider Integration

```dart
// lib/presentation/tactic/view_model/animation/animation_provider_3d.dart

class AnimationProvider3D extends AnimationController {
  final UnityBridgeService _unityBridge = UnityBridgeService();
  
  @override
  Future<void> playAnimation() async {
    final selectedAnimation = state.selectedAnimationModel;
    if (selectedAnimation == null) return;
    
    // Check render mode
    final firstScene = selectedAnimation.animationScenes.first;
    final renderMode = (firstScene as AnimationItemModel3D?)?.renderMode ?? '2d';
    
    if (renderMode == '3d') {
      await _playAnimation3D(selectedAnimation);
    } else {
      await super.playAnimation(); // Use existing 2D playback
    }
  }
  
  Future<void> _playAnimation3D(AnimationModel animation) async {
    state = state.copyWith(isPlaying: true);
    
    for (int i = 0; i < animation.animationScenes.length - 1; i++) {
      final currentScene = animation.animationScenes[i] as AnimationItemModel3D;
      final nextScene = animation.animationScenes[i + 1] as AnimationItemModel3D;
      
      // Send scene to Unity
      await _unityBridge.playScene(nextScene);
      
      // Wait for Unity callback
      final completer = Completer<void>();
      _unityBridge.registerHandler('SCENE_COMPLETE', (data) {
        if (data['sceneIndex'] == i + 1) {
          completer.complete();
        }
      });
      
      await completer.future;
    }
    
    state = state.copyWith(isPlaying: false);
  }
}
```

---

## 📊 PERFORMANCE OPTIMIZATION

### Flutter Side:
- **Lazy load Unity**: Only initialize when user toggles 3D
- **Message batching**: Combine multiple commands into single message
- **Texture streaming**: Load high-res models on-demand

### Unity Side:
- **Object pooling**: Reuse player/ball GameObjects
- **LOD (Level of Detail)**: Lower poly models at distance
- **Occlusion culling**: Don't render what camera can't see
- **Mobile optimization**: Use URP (Universal Render Pipeline)
- **Target**: 60 FPS on iPhone 12 / Samsung Galaxy S21

---

## 🧪 TESTING STRATEGY

### Unit Tests (Flutter):
- Bridge message serialization/deserialization
- 2D ↔ 3D conversion accuracy
- State synchronization

### Integration Tests:
- Flutter → Unity → Flutter round-trip
- Animation playback completeness
- Error handling (Unity crash recovery)

### Performance Tests:
- FPS benchmarks (30, 60, 120 FPS targets)
- Memory usage (< 300MB on mobile)
- Load testing (22 players + ball + equipment)

---

This architecture gives you the **best of both worlds**: Keep your proven Flutter app, add world-class 3D when users want it, and maintain backward compatibility throughout.

**Next:** Read `02_UNITY_INTEGRATION_GUIDE.md` for step-by-step Unity setup instructions.

