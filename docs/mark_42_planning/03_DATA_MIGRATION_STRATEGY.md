# MARK 42: Data Migration Strategy - 2D to 3D

**Document:** 03 - Preserving Customer Data  
**Last Updated:** November 20, 2025

---

## 🎯 CORE PRINCIPLE: ZERO DATA LOSS

**Absolute requirement:** Every existing 2D animation must:
1. ✅ Continue working in 2D mode (unchanged)
2. ✅ Be viewable in 3D mode (auto-converted)
3. ✅ Be editable in both modes
4. ✅ Never corrupt or lose data

---

## 📊 MIGRATION STRATEGY: ADDITIVE SCHEMA

### Concept: **"Add, Don't Replace"**

Instead of replacing 2D data with 3D data, we **add 3D data alongside** 2D data.

```javascript
// BEFORE (Pure 2D):
{
  "id": "scene_123",
  "components": [
    {
      "id": "player_1",
      "position": {"x": 100, "y": 200},  // 2D position
      "angle": 0
    }
  ],
  "trajectoryData": { /* 2D trajectories */ }
}

// AFTER (Hybrid 2D + 3D):
{
  "id": "scene_123",
  "renderMode": "2d",  // NEW: Defaults to 2D
  
  // KEEP: Original 2D data (untouched)
  "components": [
    {
      "id": "player_1",
      "position": {"x": 100, "y": 200},
      "angle": 0
    }
  ],
  "trajectoryData": { /* 2D trajectories */ },
  
  // ADD: New 3D data (optional)
  "components3D": [
    {
      "id": "player_1",
      "position2D": {"x": 100, "y": 200},  // Mirror of 2D
      "position3D": {"x": 100, "y": 0, "z": 200},  // NEW
      "rotation3D": {"x": 0, "y": 0, "z": 0, "w": 1},  // NEW
      "heightOffset": 0,  // NEW
      "collider": {"type": "capsule", "radius": 0.4}  // NEW
    }
  ],
  "trajectoryData3D": { /* 3D trajectories */ },  // NEW
  "cameraConfig": { /* Camera settings */ },  // NEW
  "physicsConfig": { /* Physics settings */ }  // NEW
}
```

**Key Benefits:**
- 📂 **Backward compatible** - Old apps can still read 2D data
- 🔄 **Bidirectional** - Can switch between 2D and 3D anytime
- 🛡️ **Safe** - If 3D fails, 2D always works
- 📦 **Gradual** - Only add 3D data when user enables 3D

---

## 🔄 CONVERSION ALGORITHMS

### 1. **2D → 3D Conversion (Automatic)**

When user first enables 3D mode:

```dart
// lib/app/helper/coordinate_converter.dart

class CoordinateConverter {
  /// Converts 2D board position to 3D world position
  static Vector3 convert2Dto3D(Vector2 position2D) {
    // Zporter board: 2D canvas with origin at top-left
    // Unity field: 3D space with origin at center, Y=up
    
    // Standard FIFA field dimensions (meters)
    const fieldLength = 105.0;  // X-axis
    const fieldWidth = 68.0;    // Z-axis
    
    // Normalize 2D position (0-1 range)
    // Assuming board size is stored in BoardState.fieldSize
    final normalizedX = position2D.x / BoardState.fieldSize.x;
    final normalizedY = position2D.y / BoardState.fieldSize.y;
    
    // Map to 3D field coordinates (centered at origin)
    final x3D = (normalizedX - 0.5) * fieldLength;
    final z3D = (normalizedY - 0.5) * fieldWidth;
    final y3D = 0.0;  // Ground level
    
    return Vector3(x3D, y3D, z3D);
  }
  
  /// Converts 3D world position back to 2D board position
  static Vector2 convert3Dto2D(Vector3 position3D) {
    const fieldLength = 105.0;
    const fieldWidth = 68.0;
    
    // Normalize 3D position (-0.5 to 0.5 range)
    final normalizedX = (position3D.x / fieldLength) + 0.5;
    final normalizedZ = (position3D.z / fieldWidth) + 0.5;
    
    // Map to 2D canvas coordinates
    final x2D = normalizedX * BoardState.fieldSize.x;
    final y2D = normalizedZ * BoardState.fieldSize.y;
    
    return Vector2(x2D, y2D);
  }
  
  /// Convert 2D angle (radians) to 3D rotation (quaternion)
  static Quaternion convert2DAngleTo3DRotation(double angle2D) {
    // 2D angle is rotation around Z-axis (top-down view)
    // 3D needs rotation around Y-axis (up)
    return Quaternion.fromAxisAngle(Vector3(0, 1, 0), angle2D);
  }
  
  /// Convert 3D rotation back to 2D angle
  static double convert3DRotationTo2DAngle(Quaternion rotation3D) {
    // Extract Y-axis rotation from quaternion
    final euler = rotation3D.toEulerAngles();
    return euler.y;
  }
}
```

### 2. **Trajectory Conversion**

```dart
// lib/app/helper/trajectory_converter.dart

class TrajectoryConverter {
  /// Convert 2D curved path to 3D path (ground level)
  static TrajectoryPathModel3D convert2Dto3D(TrajectoryPathModel path2D) {
    final controlPoints3D = path2D.controlPoints.map((cp2D) {
      final pos3D = CoordinateConverter.convert2Dto3D(cp2D.position);
      
      return ControlPoint3D(
        id: cp2D.id,
        position: pos3D,
        type: cp2D.type,  // Keep sharp/smooth mode
        heightOffset: 0.0,  // Start at ground level
      );
    }).toList();
    
    return TrajectoryPathModel3D(
      controlPoints: controlPoints3D,
      pathType: path2D.pathType,  // catmullRom, bezier, etc.
      speedMultiplier: _inferSpeedFromLineType(path2D),
      animationType: _inferAnimationType(path2D),
      useIK: true,  // Enable foot placement
    );
  }
  
  static AnimationType _inferAnimationType(TrajectoryPathModel path2D) {
    // Infer movement type from original line type
    if (path2D.lineType == LineType.SPRINT_ONE_WAY) {
      return AnimationType.SPRINT;
    } else if (path2D.lineType == LineType.JOG_ONE_WAY) {
      return AnimationType.JOG;
    } else if (path2D.lineType == LineType.WALK_ONE_WAY) {
      return AnimationType.WALK;
    }
    return AnimationType.RUN;  // Default
  }
  
  static double _inferSpeedFromLineType(TrajectoryPathModel path2D) {
    // FIFA average speeds (m/s)
    const speeds = {
      LineType.WALK_ONE_WAY: 2.0,
      LineType.JOG_ONE_WAY: 4.0,
      LineType.RUN_ONE_WAY: 6.0,
      LineType.SPRINT_ONE_WAY: 8.5,
    };
    return speeds[path2D.lineType] ?? 5.0;
  }
  
  /// Convert ball trajectory (add physics)
  static BallTrajectory3D convertBallTrajectory(
    LineModelV2 ballLine,
    AnimationItemModel scene,
  ) {
    final start3D = CoordinateConverter.convert2Dto3D(ballLine.start);
    final end3D = CoordinateConverter.convert2Dto3D(ballLine.end);
    
    // Infer trajectory type from line type
    BallTrajectoryType trajectoryType;
    if (ballLine.lineType == LineType.PASS_HIGH_CROSS) {
      trajectoryType = BallTrajectoryType.lofted;
    } else if (ballLine.lineType == LineType.SHOOT) {
      trajectoryType = BallTrajectoryType.driven;
    } else {
      trajectoryType = BallTrajectoryType.ground;
    }
    
    return BallTrajectory3D(
      startPosition: start3D,
      endPosition: end3D,
      trajectoryType: trajectoryType,
      power: _calculatePowerFromDistance(start3D, end3D),
      spin: 0.0,  // No spin data in 2D, user can edit in 3D
      height: trajectoryType == BallTrajectoryType.lofted ? 5.0 : 0.5,
    );
  }
  
  static double _calculatePowerFromDistance(Vector3 start, Vector3 end) {
    final distance = (end - start).length();
    // Rough estimation: power = distance / 10
    return (distance / 10.0).clamp(1.0, 10.0);
  }
}
```

### 3. **Scene Migration Pipeline**

```dart
// lib/domain/animation/migration/scene_migrator.dart

class SceneMigrator {
  /// Migrate entire scene from 2D to 3D
  static Future<AnimationItemModel3D> migrateTo3D(
    AnimationItemModel scene2D,
  ) async {
    // Convert all components
    final components3D = <FieldItemModel3D>[];
    
    for (final component in scene2D.components) {
      final component3D = await _migrateComponent(component);
      components3D.add(component3D);
    }
    
    // Convert trajectories
    final trajectoryData3D = scene2D.trajectoryData != null
        ? await _migrateTrajectories(scene2D.trajectoryData!)
        : null;
    
    // Generate default camera config
    final cameraConfig = CameraConfig(
      mode: CameraMode.TACTICAL,  // Start with top-down (like 2D)
      distance: 50.0,
      angle: 90.0,  // Directly above
      fov: 60.0,
    );
    
    // Generate default physics config
    final physicsConfig = PhysicsConfig(
      ballMass: 0.45,
      enableCollisions: false,  // Disable initially for simple playback
    );
    
    return AnimationItemModel3D(
      // Copy 2D data
      id: scene2D.id,
      index: scene2D.index,
      components: scene2D.components,  // KEEP 2D data
      fieldColor: scene2D.fieldColor,
      sceneDuration: scene2D.sceneDuration,
      userId: scene2D.userId,
      createdAt: scene2D.createdAt,
      updatedAt: DateTime.now(),
      
      // Add 3D data
      components3D: components3D,
      trajectoryData3D: trajectoryData3D,
      cameraConfig: cameraConfig,
      physicsConfig: physicsConfig,
      renderMode: "2d",  // Start in 2D mode, user can toggle
    );
  }
  
  static Future<FieldItemModel3D> _migrateComponent(
    FieldItemModel component,
  ) async {
    final position3D = CoordinateConverter.convert2Dto3D(
      component.offset ?? Vector2.zero(),
    );
    
    final rotation3D = CoordinateConverter.convert2DAngleTo3DRotation(
      component.angle ?? 0.0,
    );
    
    return FieldItemModel3D(
      item2D: component,
      position3D: position3D,
      rotation3D: rotation3D,
      heightOffset: 0.0,
      colliderType: _getColliderType(component),
      colliderRadius: _getColliderRadius(component),
    );
  }
  
  static ColliderType _getColliderType(FieldItemModel component) {
    if (component is PlayerModel) return ColliderType.capsule;
    if (component is EquipmentModel) {
      if (component.name == "BALL") return ColliderType.sphere;
      return ColliderType.box;
    }
    return ColliderType.box;
  }
  
  static double _getColliderRadius(FieldItemModel component) {
    if (component is PlayerModel) return 0.4;  // 40cm radius
    if (component is EquipmentModel && component.name == "BALL") {
      return 0.11;  // Regulation ball radius
    }
    return 0.3;
  }
  
  static Future<AnimationTrajectoryData3D> _migrateTrajectories(
    AnimationTrajectoryData data2D,
  ) async {
    final trajectories3D = <String, TrajectoryPathModel3D>{};
    
    for (final entry in data2D.componentTrajectories.entries) {
      final componentId = entry.key;
      final path2D = entry.value;
      
      trajectories3D[componentId] = TrajectoryConverter.convert2Dto3D(path2D);
    }
    
    return AnimationTrajectoryData3D(
      componentTrajectories: trajectories3D,
      usePhysics: false,  // Start with scripted paths
      gravity: 1.0,
    );
  }
}
```

---

## 🔒 BACKWARD COMPATIBILITY

### Rule 1: **Always Write Both Formats**

When user edits in 3D mode, save both 2D and 3D:

```dart
class AnimationRepositoryImpl {
  @override
  Future<void> saveScene(AnimationItemModel3D scene) async {
    // Convert 3D → 2D (project down)
    final scene2D = scene.to2D();
    
    // Save to Firestore with both formats
    await _firestore.collection('scenes').doc(scene.id).set({
      // 2D data (for old clients)
      ...scene2D.toJson(),
      
      // 3D data (for new clients)
      'renderMode': scene.renderMode,
      'components3D': scene.components3D.map((c) => c.toJson()).toList(),
      'trajectoryData3D': scene.trajectoryData3D?.toJson(),
      'cameraConfig': scene.cameraConfig?.toJson(),
      'physicsConfig': scene.physicsConfig?.toJson(),
      
      // Version tracking
      'schemaVersion': 2,  // Incremented from v1 (2D only)
      'lastEditedIn': scene.renderMode,  // '2d' or '3d'
      'lastEditedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

### Rule 2: **Graceful Degradation**

Old app versions should still work:

```dart
class AnimationItemModel {
  factory AnimationItemModel.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'] as int? ?? 1;
    
    if (schemaVersion == 1) {
      // Old format (2D only)
      return AnimationItemModel(
        id: json['id'],
        components: _parseComponents(json['components']),
        // ... standard 2D parsing
      );
    } else if (schemaVersion >= 2) {
      // New format (2D + 3D)
      // OLD APPS: Ignore 3D data, just read 2D
      return AnimationItemModel(
        id: json['id'],
        components: _parseComponents(json['components']),  // Use 2D
        // 3D fields ignored in old app version
      );
    }
    
    throw Exception('Unsupported schema version: $schemaVersion');
  }
}
```

### Rule 3: **Version Detection**

```dart
// lib/app/config/version_info.dart

class VersionInfo {
  static const appVersion = '2.0.0';  // Bump for 3D release
  static const minSupportedVersion = '1.5.0';  // Oldest compatible version
  static const supports3D = true;  // Feature flag
  
  static bool canRead3DData(String documentVersion) {
    // Check if current app can handle document
    final docVer = Version.parse(documentVersion);
    final minVer = Version.parse(minSupportedVersion);
    return docVer >= minVer;
  }
}
```

---

## 🚀 MIGRATION PHASES

### Phase 1: **Shadow Migration** (Weeks 1-2)

Start writing 3D data alongside 2D (invisible to users):

```dart
// Feature flag: ENABLE_3D_SHADOW_WRITES = true

@override
Future<void> saveScene(AnimationItemModel scene) async {
  // Always save 2D (existing behavior)
  await _save2DData(scene);
  
  // NEW: Also save 3D data (shadow write)
  if (FeatureFlags.ENABLE_3D_SHADOW_WRITES) {
    final scene3D = await SceneMigrator.migrateTo3D(scene);
    await _save3DData(scene3D);
  }
}
```

**Benefits:**
- No user-facing changes
- Start building 3D data corpus
- Test migration algorithms
- Validate data consistency

### Phase 2: **Opt-In Beta** (Weeks 3-6)

Allow beta users to enable 3D:

```dart
// Feature flag: ENABLE_3D_BETA = true (for beta users only)

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userIsBetaTester = ref.watch(authProvider).isBetaTester;
    
    return Column(
      children: [
        if (userIsBetaTester)
          SwitchListTile(
            title: Text('Enable 3D Mode (Beta)'),
            subtitle: Text('Switch between 2D and 3D tactical views'),
            value: ref.watch(boardProvider).renderMode == '3d',
            onChanged: (value) {
              ref.read(boardProvider.notifier).toggle3DMode();
            },
          ),
      ],
    );
  }
}
```

### Phase 3: **General Availability** (Weeks 7-10)

Roll out to all users with education:

```dart
// Show onboarding dialog
void _show3DIntroDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('🎉 New: 3D Tactical View'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Experience your tactics in realistic 3D!'),
          SizedBox(height: 16),
          Image.asset('assets/images/3d_preview.gif'),
          SizedBox(height: 16),
          Text('Try it now in Settings → Enable 3D Mode'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _navigateToSettings();
          },
          child: Text('Try Now'),
        ),
      ],
    ),
  );
}
```

### Phase 4: **3D by Default** (Weeks 11+)

After 90% adoption:

```dart
// NEW users: 3D by default
// EXISTING users: 2D by default (can opt-in)

class UserPreferences {
  static Future<void> setDefaultRenderMode(String userId) async {
    final user = await _userRepository.getUser(userId);
    
    if (user.createdAt.isAfter(DateTime(2025, 12, 1))) {
      // New users get 3D by default
      user.defaultRenderMode = '3d';
    } else {
      // Existing users keep 2D (can switch manually)
      user.defaultRenderMode = '2d';
    }
    
    await _userRepository.updateUser(user);
  }
}
```

---

## 🧪 TESTING STRATEGY

### 1. **Data Integrity Tests**

```dart
void main() {
  group('Migration Tests', () {
    test('2D → 3D → 2D round-trip preserves data', () async {
      // Start with 2D scene
      final scene2D = AnimationItemModel(/* ... */);
      
      // Convert to 3D
      final scene3D = await SceneMigrator.migrateTo3D(scene2D);
      
      // Convert back to 2D
      final scene2DRestored = scene3D.to2D();
      
      // Assert positions match (within tolerance)
      for (int i = 0; i < scene2D.components.length; i++) {
        final original = scene2D.components[i];
        final restored = scene2DRestored.components[i];
        
        expect(
          (original.offset! - restored.offset!).length(),
          lessThan(0.01),  // 1cm tolerance
        );
      }
    });
    
    test('Old app can read new 3D-enhanced documents', () {
      final json = {
        'id': 'scene_123',
        'schemaVersion': 2,
        'components': [/* 2D data */],
        'components3D': [/* 3D data */],  // Ignored by old apps
      };
      
      // Old parser should not crash
      expect(
        () => AnimationItemModel.fromJson(json),
        returnsNormally,
      );
    });
  });
}
```

### 2. **Migration Validation**

```dart
class MigrationValidator {
  /// Validate migrated scene
  static List<String> validate(AnimationItemModel3D scene) {
    final errors = <String>[];
    
    // Check all 2D components have 3D equivalents
    if (scene.components.length != scene.components3D.length) {
      errors.add('Component count mismatch: ${scene.components.length} vs ${scene.components3D.length}');
    }
    
    // Check IDs match
    for (int i = 0; i < scene.components.length; i++) {
      final id2D = scene.components[i].id;
      final id3D = scene.components3D[i].item2D.id;
      
      if (id2D != id3D) {
        errors.add('ID mismatch at index $i: $id2D vs $id3D');
      }
    }
    
    // Check positions are reasonable
    for (final component3D in scene.components3D) {
      final pos = component3D.position3D;
      
      // FIFA field: 105m x 68m
      if (pos.x.abs() > 60 || pos.z.abs() > 40) {
        errors.add('Component ${component3D.item2D.id} out of bounds: $pos');
      }
      
      if (pos.y < -1 || pos.y > 10) {
        errors.add('Component ${component3D.item2D.id} unrealistic height: ${pos.y}');
      }
    }
    
    return errors;
  }
}
```

### 3. **Batch Migration Script**

For migrating existing data in bulk:

```dart
// tools/migrate_existing_data.dart

Future<void> main() async {
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  final collections = await firestore.collection('animation_collections').get();
  
  int totalScenes = 0;
  int migratedScenes = 0;
  int failedScenes = 0;
  
  for (final collectionDoc in collections.docs) {
    final collection = AnimationCollectionModel.fromJson(collectionDoc.data());
    
    for (final animation in collection.animations) {
      for (final scene in animation.animationScenes) {
        totalScenes++;
        
        try {
          // Migrate scene
          final scene3D = await SceneMigrator.migrateTo3D(scene);
          
          // Validate
          final errors = MigrationValidator.validate(scene3D);
          if (errors.isNotEmpty) {
            print('Validation errors for scene ${scene.id}:');
            errors.forEach(print);
            failedScenes++;
            continue;
          }
          
          // Save (dry run - only log, don't actually write)
          print('Would migrate scene ${scene.id}: ${scene.components.length} components');
          migratedScenes++;
          
          // UNCOMMENT TO ACTUALLY MIGRATE:
          // await _saveScene3D(scene3D);
          
        } catch (e) {
          print('Failed to migrate scene ${scene.id}: $e');
          failedScenes++;
        }
      }
    }
  }
  
  print('\n=== Migration Summary ===');
  print('Total scenes: $totalScenes');
  print('Migrated: $migratedScenes');
  print('Failed: $failedScenes');
  print('Success rate: ${(migratedScenes / totalScenes * 100).toStringAsFixed(1)}%');
}
```

---

## 📊 MONITORING & ROLLBACK

### Metrics to Track:

```dart
class MigrationMetrics {
  // Firestore document
  static Future<void> trackMigration(String sceneId, bool success) async {
    await FirebaseFirestore.instance
        .collection('migration_metrics')
        .doc(sceneId)
        .set({
      'migratedAt': FieldValue.serverTimestamp(),
      'success': success,
      'appVersion': VersionInfo.appVersion,
    });
  }
  
  static Future<Map<String, dynamic>> getMigrationStats() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('migration_metrics')
        .get();
    
    int total = snapshot.docs.length;
    int successful = snapshot.docs.where((d) => d['success'] == true).length;
    
    return {
      'total': total,
      'successful': successful,
      'failed': total - successful,
      'successRate': (successful / total * 100).toStringAsFixed(1) + '%',
    };
  }
}
```

### Rollback Plan:

```dart
// If migration causes issues, rollback to 2D-only mode

class EmergencyRollback {
  static Future<void> disableOn3DForAllUsers() async {
    // Set remote config flag
    await FirebaseRemoteConfig.instance.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    
    await FirebaseRemoteConfig.instance.setDefaults({
      'enable_3d_mode': false,  // KILL SWITCH
    });
    
    // Notify all users
    await FirebaseMessaging.instance.send(
      '3D mode temporarily disabled due to technical issues. Your data is safe.',
    );
  }
}
```

---

## ✅ SUCCESS CRITERIA

Migration is successful when:

- [x] 100% of 2D animations load in 2D mode (unchanged)
- [x] 95%+ of 2D animations convert to 3D without errors
- [x] Round-trip conversion (2D → 3D → 2D) maintains accuracy
- [x] No data loss reported by users
- [x] Old app versions can still read new documents
- [x] < 5% of users report conversion issues

---

## 🎯 KEY TAKEAWAYS

1. **Never delete 2D data** - It's your safety net
2. **Always validate conversions** - Automated testing is critical
3. **Gradual rollout** - Shadow writes → Beta → GA
4. **Monitor everything** - Track success rates, errors
5. **Have a rollback plan** - Remote config kill switch

This strategy ensures you can innovate with 3D while never putting your customers' existing work at risk. 🛡️

