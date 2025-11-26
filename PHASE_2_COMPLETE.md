# Phase 2: Visual Trajectory Components - Implementation Complete ✅

## Overview
Phase 2 successfully implements all visual Flame components for trajectory path editing. These components provide an intuitive UI for creating and editing curved animation paths between scenes.

---

## 📁 Files Created

### 1. **ghost_component.dart**
**Purpose**: Shows semi-transparent preview of component's previous scene position

**Key Features**:
- Semi-transparent rendering (35% opacity)
- Dashed border to distinguish from real component
- Shows role/number text for players
- Same size and rotation as original component
- Cannot be interacted with (visual only)

**Visual Appearance**:
```
┌─ ─ ─ ─ ─ ─┐
│   [GF]    │  ← Semi-transparent with dashed border
│     10    │  ← Shows player details at 35% opacity
└─ ─ ─ ─ ─ ─┘
```

**Technical Details**:
```dart
class GhostComponent extends PositionComponent
    with HasGameReference<TacticBoardGame>
```
- Extends `PositionComponent` (lightweight, no interaction)
- Takes `FieldItemModel previousSceneItem` as input
- Renders at priority 0 (below real components)
- Custom dashed border rendering with Path API

---

### 2. **trajectory_path_component.dart**
**Purpose**: Renders the curved trajectory path between start and end positions

**Key Features**:
- Dashed line following calculated path curve
- Arrow head at end to indicate direction
- Color customization (yellow for selected, gray for others)
- Thicker line when selected (3px vs 2px)
- Small markers at control point positions
- Uses TrajectoryCalculator for smooth curves

**Visual Appearance**:
```
Start ●─ ─ ─╮
           │  ← Dashed curved path
           ╰─ ─ ─► End
                 ▲ Arrow head
```

**Technical Details**:
```dart
class TrajectoryPathComponent extends Component
    with HasGameReference<TacticBoardGame>
```
- Takes `TrajectoryPathModel`, `startPosition`, `endPosition`
- Caches calculated path points (50 samples default)
- Renders at priority 1 (above ghost, below real components)
- Methods:
  - `calculatePathLength()`: Total path distance
  - `getPositionAtProgress(t)`: Position at 0-1 along path
  - `updatePath()`: Recalculates when control points change

**Rendering Process**:
1. Call `TrajectoryCalculator.calculatePath()` to get smooth curve points
2. Build Path from Vector2 list
3. Draw as dashed line using PathMetrics
4. Calculate arrow direction from last two points
5. Draw filled arrow head
6. Optionally draw control point markers

---

### 3. **control_point_component.dart**
**Purpose**: Draggable handles for editing trajectory curve shape

**Key Features**:
- Three visual types (sharp, smooth, symmetric)
- Draggable with visual feedback
- Tap to cycle through control point types
- Size changes based on state (normal: 6px, selected: 8px, dragging: 9px)
- Color-coded by type:
  - Orange = Sharp angle
  - Blue = Smooth curve
  - Purple = Symmetric

**Visual Appearance**:
```
Sharp:      Smooth:     Symmetric:
   ■           ●            ◆
Orange      Blue        Purple
```

**Technical Details**:
```dart
class ControlPointComponent extends PositionComponent
    with DragCallbacks, TapCallbacks, HasGameReference<TacticBoardGame>
```
- Takes `ControlPoint` model and callbacks
- Implements drag handling:
  ```dart
  onDragUpdate(event) {
    position.add(event.canvasDelta);
    onDrag(controlPoint.id, position);
  }
  ```
- Implements tap handling:
  ```dart
  onTapUp(event) {
    onTap?.call(controlPoint.id); // Cycle type
  }
  ```
- Renders at priority 10 (on top of everything)
- Custom icon rendering based on ControlPointType

---

### 4. **trajectory_editor_manager.dart**
**Purpose**: Orchestrates all trajectory editing components and handles user interactions

**Key Responsibilities**:
1. Creates and manages ghost/path/control point components
2. Handles control point dragging
3. Updates trajectory model on changes
4. Provides API for UI (add/remove control points, toggle enabled)
5. Syncs changes back to animation model

**Public API**:
```dart
// Show trajectory editing for a component
await manager.showTrajectoryForComponent(
  componentId: 'player_1',
  currentItem: playerModel,
);

// Hide all trajectory UI
await manager.hideTrajectory();

// Add control point at path midpoint
await manager.addControlPoint();

// Remove last control point
await manager.removeControlPoint();

// Toggle trajectory on/off
manager.toggleTrajectoryEnabled();

// Update visual properties
manager.updatePathColor(Colors.yellow);
manager.updateSmoothness(0.7); // 0.0 to 1.0
```

**Technical Details**:
```dart
class TrajectoryEditorManager extends Component
    with HasGameReference<TacticBoardGame>
```

**Component Lifecycle**:
```
showTrajectoryForComponent()
  ├─ Find previous scene position
  ├─ Get/create trajectory data
  ├─ Create GhostComponent → add to world
  ├─ Create TrajectoryPathComponent → add to world
  └─ Create ControlPointComponents → add to world

hideTrajectory()
  ├─ Remove GhostComponent from world
  ├─ Remove TrajectoryPathComponent from world
  └─ Remove all ControlPointComponents from world
```

**Callback Flow**:
```
User drags control point
  ↓
ControlPointComponent.onDragUpdate()
  ↓
TrajectoryEditorManager._onControlPointDrag()
  ↓
Update ControlPoint position in model
  ↓
TrajectoryPathComponent.updatePath() (recalculate)
  ↓
onTrajectoryChanged callback
  ↓
Parent updates AnimationItemModel.trajectoryData
```

---

### 5. **trajectory_components.dart**
**Purpose**: Barrel file for easy importing

```dart
export 'ghost_component.dart';
export 'trajectory_path_component.dart';
export 'control_point_component.dart';
export 'trajectory_editor_manager.dart';
```

Usage:
```dart
import 'package:zporter_tactical_board/presentation/tactic/view/component/animation/trajectory_components.dart';
```

---

## 🎨 Visual Workflow

### Scenario: User edits curved path for player movement

**Step 1: Select Player in Scene 2**
```
Scene 1: Player at position A
Scene 2: Player at position B (SELECTED)
```

**Step 2: Manager Shows Trajectory UI**
```
┌─ ─ ─ ─ ─ ─┐
│   [GF]    │ ← Ghost at Scene 1 position
└─ ─ ─ ─ ─ ─┘
     │
     │ ─ ─ ─╮
     ●       │ ← Control points (draggable)
            ●
            │
            ╰─ ─ ─►
               ┌───────────┐
               │   [GF]   │ ← Real player at Scene 2
               └───────────┘
```

**Step 3: User Drags Control Point**
```
Drag handle → Path recalculates → Smooth curve updates in real-time
```

**Step 4: User Taps Control Point**
```
Tap → Cycle type: Sharp (■) → Smooth (●) → Symmetric (◆)
      Path recalculates with new curve properties
```

**Step 5: Animation Playback**
```
Ghost/Path/Controls hidden → Player follows calculated curve
```

---

## 🔧 Integration Points

### How to Use in Your App

**1. Create Manager in Animation Edit Mode**
```dart
final trajectoryManager = TrajectoryEditorManager(
  currentScene: animationScenes[currentIndex],
  previousScene: currentIndex > 0 ? animationScenes[currentIndex - 1] : null,
  onTrajectoryChanged: (componentId, trajectory) {
    // Update animation model
    final updatedScene = currentScene.copyWith(
      trajectoryData: currentScene.trajectoryData?.setTrajectory(
        componentId,
        trajectory,
      ) ?? AnimationTrajectoryData()..setTrajectory(componentId, trajectory),
    );
    // Save to state
  },
);

await game.world.add(trajectoryManager);
```

**2. Show Trajectory When Component Selected**
```dart
void onPlayerSelected(PlayerModel player) {
  trajectoryManager.showTrajectoryForComponent(
    componentId: player.id,
    currentItem: player,
  );
}
```

**3. Hide When Deselected**
```dart
void onSelectionCleared() {
  trajectoryManager.hideTrajectory();
}
```

**4. UI Controls (from Design Toolbar)**
```dart
// Add control point button
onPressed: () => trajectoryManager.addControlPoint(),

// Remove control point button
onPressed: () => trajectoryManager.removeControlPoint(),

// Enable toggle
onChanged: (enabled) => trajectoryManager.toggleTrajectoryEnabled(),

// Smoothness slider
onChanged: (value) => trajectoryManager.updateSmoothness(value / 100),

// Color picker
onColorChanged: (color) => trajectoryManager.updatePathColor(color),
```

---

## 📊 Performance Considerations

### Optimizations Implemented

1. **Path Caching**:
   - Calculated path points cached in `_cachedPathPoints`
   - Only recalculated when control points change
   - Prevents redundant calculations on every frame

2. **Component Priority Layering**:
   ```
   Priority 0: GhostComponent (background)
   Priority 1: TrajectoryPathComponent (mid)
   Priority 5: TrajectoryEditorManager (mid-high)
   Priority 10: ControlPointComponent (foreground)
   ```

3. **Conditional Rendering**:
   - Path only renders if `pathModel.enabled == true`
   - Control points hidden during animation playback
   - Ghost only created if previous scene exists

4. **Efficient Dashed Line Rendering**:
   - Uses `PathMetrics.extractPath()` instead of individual line segments
   - Minimal draw calls per frame

---

## 🧪 Testing Checklist

### Visual Tests
- [ ] Ghost appears at correct previous scene position
- [ ] Ghost shows correct semi-transparency (35% opacity)
- [ ] Ghost dashed border renders correctly
- [ ] Path follows smooth curve through control points
- [ ] Path arrow points in correct direction
- [ ] Control points are draggable
- [ ] Control points change size when dragged/selected
- [ ] Control point icons match their type (square/circle/diamond)

### Interaction Tests
- [ ] Dragging control point updates path in real-time
- [ ] Tapping control point cycles through types
- [ ] Adding control point inserts at midpoint
- [ ] Removing control point updates path
- [ ] Manager cleans up components when hidden

### Integration Tests
- [ ] Trajectory data syncs to AnimationItemModel
- [ ] Changes persist when switching scenes
- [ ] No memory leaks when creating/destroying components
- [ ] Works with both players and equipment

---

## 🚀 Next Steps (Phase 3)

### Design Toolbar Integration

**Location**: `design_toolbar_component.dart`

**New Section to Add**:
```dart
// Animation Path Section (collapsible)
if (isAnimationMode && selectedComponent != null) {
  AnimationPathSection(
    enabled: trajectoryEnabled,
    pathType: currentPathType,
    smoothness: smoothness,
    pathColor: pathColor,
    onEnabledChanged: (value) => manager.toggleTrajectoryEnabled(),
    onAddControlPoint: () => manager.addControlPoint(),
    onRemoveControlPoint: () => manager.removeControlPoint(),
    onSmoothnessChanged: (value) => manager.updateSmoothness(value),
    onColorChanged: (color) => manager.updatePathColor(color),
  )
}
```

**UI Mockup**:
```
┌─────────────────────────────────────┐
│ Animation Path                    ▼ │
├─────────────────────────────────────┤
│ ☑ Enable Custom Path               │
│                                     │
│ Path Type: [Curved ▼]              │
│                                     │
│ Smoothness: ─●─────────── 50%      │
│                                     │
│ Color: [⬤ Yellow ▼]                │
│                                     │
│ [+ Add Point]  [- Remove Point]    │
└─────────────────────────────────────┘
```

---

## 📝 Architecture Summary

### Data Flow
```
User Action (drag/tap)
  ↓
ControlPointComponent (Flame event)
  ↓
TrajectoryEditorManager (callback)
  ↓
Update TrajectoryPathModel
  ↓
TrajectoryPathComponent.updatePath() (recalculate)
  ↓
onTrajectoryChanged callback
  ↓
Parent updates AnimationItemModel
  ↓
Persist to Firestore
```

### Component Hierarchy
```
TacticBoardGame (world)
  └─ TrajectoryEditorManager
      ├─ GhostComponent (previous position)
      ├─ TrajectoryPathComponent (curved line)
      └─ ControlPointComponent[] (draggable handles)
```

### State Management
```
AnimationItemModel
  └─ trajectoryData: AnimationTrajectoryData?
      └─ trajectories: Map<String, TrajectoryPathModel>
          └─ controlPoints: List<ControlPoint>
```

---

## 🎉 Phase 2 Complete!

All visual components are implemented and ready for integration. The system provides:

✅ **Ghost visualization** of previous positions  
✅ **Curved path rendering** with arrows  
✅ **Draggable control points** with type indicators  
✅ **Real-time path updates** on drag  
✅ **Manager orchestration** with clean API  
✅ **Zero errors** - all files compile successfully  
✅ **Follows Flame patterns** - consistent with existing codebase  

**Ready for Phase 3**: Design toolbar integration to expose these features to users!

---

## 📚 Key Takeaways

1. **Component Pattern**: All components follow Flame's `PositionComponent` pattern with mixins
2. **Event Handling**: Uses `DragCallbacks` and `TapCallbacks` for interactions
3. **Priority System**: Layered rendering with explicit priority values
4. **Manager Pattern**: Central coordinator handles component lifecycle
5. **Callback Architecture**: Clean separation between UI and data updates
6. **Performance**: Caching and conditional rendering for smooth 60fps

---

**Phase 1**: Data models ✅  
**Phase 2**: Visual components ✅  
**Phase 3**: Design toolbar integration (NEXT)  
**Phase 4**: Animation playback  
**Phase 5**: Testing & polish
