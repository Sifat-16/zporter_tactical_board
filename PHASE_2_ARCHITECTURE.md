# Phase 2 Architecture Diagram

## Component Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                      TacticBoardGame (World)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │         TrajectoryEditorManager (Priority 5)              │ │
│  │                                                           │ │
│  │  Orchestrates all trajectory editing components          │ │
│  └───────────────────────────────────────────────────────────┘ │
│                        │                                        │
│           ┌────────────┼────────────┐                          │
│           │            │            │                          │
│           ▼            ▼            ▼                          │
│  ┌──────────────┐ ┌─────────┐ ┌───────────────┐              │
│  │GhostComponent│ │TrajectoryPathComponent│ControlPointComponent│
│  │(Priority 0)  │ │(Priority 1)│ │(Priority 10)│              │
│  └──────────────┘ └─────────┘ └───────────────┘              │
│   Semi-transparent Dashed curved  Draggable edit             │
│   previous position line with     handles for                │
│                     arrow         curve control              │
│                                                               │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌──────────────────────┐
│  User Interaction    │
│ (Drag control point) │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────┐
│  ControlPointComponent           │
│  onDragUpdate(event)             │
│  - Updates position              │
│  - Calls onDrag callback         │
└──────────┬───────────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  TrajectoryEditorManager         │
│  _onControlPointDrag()           │
│  - Updates ControlPoint in model │
│  - Triggers path recalculation   │
└──────────┬───────────────────────┘
           │
           ├─────────────────────┐
           │                     │
           ▼                     ▼
┌─────────────────────┐  ┌──────────────────┐
│TrajectoryPathComponent│  │onTrajectoryChanged│
│updatePath()         │  │callback          │
│- Recalculates curve │  │                  │
│- Re-renders path    │  └────────┬─────────┘
└─────────────────────┘           │
                                  ▼
                        ┌──────────────────────┐
                        │AnimationItemModel    │
                        │trajectoryData updated│
                        │                      │
                        │Persist to Firestore  │
                        └──────────────────────┘
```

## Visual Rendering Layers

```
┌─────────────────────────────────────────────────────────┐
│ Screen                                                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Layer 10: ●  ●  ● (Control Points) ← Top              │
│            │  │  │                                      │
│            │  │  │                                      │
│  Layer 5:  └──┴──┘ (Manager - invisible)               │
│                                                         │
│  Layer 2:  ┌────────┐                                  │
│            │ PLAYER │ (Real components)                │
│            └────────┘                                   │
│                                                         │
│  Layer 1:  ─ ─ ─ ─►  (Trajectory Path)                │
│                                                         │
│  Layer 0:  ┌ ─ ─ ─ ┐                                  │
│            │ GHOST │ (Previous position) ← Bottom      │
│            └ ─ ─ ─ ┘                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## State Management

```
AnimationItemModel
├── id: String
├── index: int
├── components: List<FieldItemModel>
├── sceneDuration: Duration
└── trajectoryData: AnimationTrajectoryData? ← NEW
    └── trajectories: Map<String, TrajectoryPathModel>
        └── [componentId]: TrajectoryPathModel
            ├── id: String
            ├── pathType: PathType (straight/catmullRom/bezier)
            ├── controlPoints: List<ControlPoint>
            │   └── ControlPoint
            │       ├── id: String
            │       ├── position: Vector2
            │       ├── type: ControlPointType (sharp/smooth/symmetric)
            │       └── tension: double (0.0-1.0)
            ├── enabled: bool
            ├── pathColor: Color
            ├── pathWidth: double
            ├── showControlPoints: bool
            └── smoothness: double (0.0-1.0)
```

## Component Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1: Initialization                                     │
├─────────────────────────────────────────────────────────────┤
│ 1. Create TrajectoryEditorManager                           │
│ 2. Add to game.world                                        │
│ 3. Manager.onLoad() called                                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2: Show Trajectory UI                                 │
├─────────────────────────────────────────────────────────────┤
│ 1. User selects component                                   │
│ 2. manager.showTrajectoryForComponent()                     │
│ 3. Create GhostComponent → add to world                     │
│ 4. Create TrajectoryPathComponent → add to world            │
│ 5. Create ControlPointComponents → add to world             │
│ 6. All components.onLoad() called                           │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3: User Interaction                                   │
├─────────────────────────────────────────────────────────────┤
│ Loop:                                                       │
│   1. User drags/taps control point                          │
│   2. Component handles event                                │
│   3. Callback to manager                                    │
│   4. Manager updates model                                  │
│   5. Path recalculates and re-renders                       │
│   6. onTrajectoryChanged fires                              │
│   7. Parent updates AnimationItemModel                      │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4: Hide Trajectory UI                                 │
├─────────────────────────────────────────────────────────────┤
│ 1. User deselects component or changes scene                │
│ 2. manager.hideTrajectory()                                 │
│ 3. Remove GhostComponent from world                         │
│ 4. Remove TrajectoryPathComponent from world                │
│ 5. Remove all ControlPointComponents from world             │
│ 6. Components cleaned up by Flame                           │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5: Cleanup                                            │
├─────────────────────────────────────────────────────────────┤
│ 1. Exit animation edit mode                                 │
│ 2. Remove TrajectoryEditorManager from world                │
│ 3. Manager cleaned up by Flame                              │
└─────────────────────────────────────────────────────────────┘
```

## Event Handling Flow

```
┌─────────────────────────┐
│ Flame Game Engine       │
│ (Touch/Mouse Input)     │
└────────┬────────────────┘
         │
         ├─── onDragStart ───┐
         ├─── onDragUpdate ──┤
         ├─── onDragEnd ─────┤
         ├─── onTapDown ─────┤
         └─── onTapUp ───────┤
                             │
                             ▼
         ┌────────────────────────────────┐
         │ ControlPointComponent          │
         │ (with DragCallbacks/TapCallbacks)│
         └────────┬───────────────────────┘
                  │
                  ├─ Drag: position.add(event.canvasDelta)
                  ├─ Drag: onDrag(id, newPosition)
                  └─ Tap: onTap(id) → cycle type
                  │
                  ▼
         ┌────────────────────────────────┐
         │ TrajectoryEditorManager        │
         │ _onControlPointDrag()          │
         │ _onControlPointTap()           │
         └────────┬───────────────────────┘
                  │
                  ├─ Update TrajectoryPathModel
                  ├─ Call pathComponent.updatePath()
                  └─ Fire onTrajectoryChanged(id, model)
                  │
                  ▼
         ┌────────────────────────────────┐
         │ Parent (Animation Editor)      │
         │ Updates AnimationItemModel     │
         │ Persists to Firestore          │
         └────────────────────────────────┘
```

## Files Created in Phase 2

```
lib/presentation/tactic/view/component/animation/
├── ghost_component.dart                 (226 lines)
│   └── Shows semi-transparent previous position
│
├── trajectory_path_component.dart       (248 lines)
│   └── Renders curved path with arrow
│
├── control_point_component.dart         (207 lines)
│   └── Draggable handles for editing curve
│
├── trajectory_editor_manager.dart       (360 lines)
│   └── Orchestrates all components
│
├── trajectory_components.dart           (10 lines)
│   └── Barrel file for easy importing
│
└── trajectory_integration_example.dart  (260 lines)
    └── Complete integration guide
```

## Integration Points for Phase 3

```
┌──────────────────────────────────────────────────────────┐
│ Design Toolbar UI (Phase 3)                              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ [Animation Path Section]                                │
│   ├─ Enable Toggle ──────► manager.toggleTrajectoryEnabled()
│   ├─ Path Type Dropdown ─► (future: switch pathType)
│   ├─ Smoothness Slider ──► manager.updateSmoothness()
│   ├─ Color Picker ────────► manager.updatePathColor()
│   ├─ Add Point Button ───► manager.addControlPoint()
│   └─ Remove Point Button ► manager.removeControlPoint()
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Performance Characteristics

```
┌────────────────────────────────────────────────────────┐
│ Operation          │ Complexity  │ Frequency          │
├────────────────────┼─────────────┼────────────────────┤
│ Path Calculation   │ O(n×m)      │ On control point   │
│ (n=samples, m=cp)  │             │ drag only          │
├────────────────────┼─────────────┼────────────────────┤
│ Path Rendering     │ O(n)        │ Every frame        │
│ (cached points)    │             │ (60fps)            │
├────────────────────┼─────────────┼────────────────────┤
│ Control Point Drag │ O(1)        │ During drag        │
│                    │             │ (~30fps while drag)│
├────────────────────┼─────────────┼────────────────────┤
│ Component Creation │ O(m)        │ On selection       │
│ (m=control points) │             │ (once per select)  │
└────────────────────────────────────────────────────────┘

Optimization: Path cached, only recalculated on control point change
Result: Smooth 60fps performance even with complex curves
```
