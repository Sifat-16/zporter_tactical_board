# Phase 3: On-Canvas Trajectory Editing UI - Implementation Plan

## Overview
Phase 3 integrates trajectory editing into the main game canvas as a **floating toolbar overlay**. This provides users with a large, intuitive workspace to edit curved animation paths.

---

## ✅ Completed: Floating Trajectory Toolbar

### File Created: `trajectory_editing_toolbar.dart`

**Visual Design:**
```
┌─────────────────────────────────────┐
│ ⏱ Animation Path            ✕    ▼ │ ← Header (collapsible)
├─────────────────────────────────────┤
│ ☑ Enable Custom Path               │ ← Toggle
│                                     │
│ Path Type: Curved                   │ ← Info
│                                     │
│ Control Points: [3]                 │ ← Count badge
│ [+ Add Point]  [- Remove]          │ ← Action buttons
│ Tip: Drag control points on canvas │ ← Helper text
│                                     │
│ Smoothness          50%             │
│ ─────●──────────────                │ ← Slider
│                                     │
│ Path Color                          │
│ ● ● ● ● ● ● ● ● ● ●                │ ← Color picker
└─────────────────────────────────────┘
```

**Position:** Top-right corner of game canvas (overlays the field)

**Features:**
- ✅ Collapsible/expandable with animation
- ✅ Enable/disable custom path toggle
- ✅ Add/remove control points buttons
- ✅ Smoothness slider (0-100%)
- ✅ 10 pre-defined path colors
- ✅ Visual feedback (selected color has glow effect)
- ✅ Tooltips and helper text
- ✅ Semi-transparent background (doesn't obstruct view)
- ✅ Close button to dismiss

---

## 🔄 Integration Steps (TODO)

### Step 1: Add TrajectoryEditorManager to TacticBoardGame

**File:** `tactic_board_game.dart`

**Add field:**
```dart
class TacticBoard extends TacticBoardGame {
  // ... existing fields ...
  
  /// Trajectory editor manager for animation path editing
  TrajectoryEditorManager? trajectoryManager;
}
```

**Initialize manager when entering animation mode:**
```dart
Future<void> initializeTrajectoryEditor() async {
  final animationProvider = ref.read(animationProviderRef);
  final currentScene = animationProvider.selectedScene;
  final scenes = animationProvider.selectedAnimationModel?.scenes;
  
  if (currentScene == null || scenes == null) return;
  
  final currentIndex = scenes.indexWhere((s) => s.id == currentScene.id);
  final previousScene = currentIndex > 0 ? scenes[currentIndex - 1] : null;
  
  trajectoryManager = TrajectoryEditorManager(
    currentScene: currentScene,
    previousScene: previousScene,
    onTrajectoryChanged: _handleTrajectoryChanged,
  );
  
  await world.add(trajectoryManager!);
}

void _handleTrajectoryChanged(String componentId, TrajectoryPathModel trajectory) {
  // Update animation model
  // ... (see integration example)
}
```

### Step 2: Add Toolbar to GameScreen Stack

**File:** `game_screen.dart`

**Add state variables:**
```dart
class _GameScreenState extends ConsumerState<GameScreen> {
  // ... existing fields ...
  
  /// Whether trajectory editing toolbar is visible
  bool _showTrajectoryToolbar = false;
  
  /// Current trajectory being edited
  TrajectoryPathModel? _currentTrajectory;
  
  /// Currently selected component ID
  String? _selectedComponentId;
}
```

**Add toolbar to Stack (after FormSpeedDialComponent):**
```dart
Widget build(BuildContext context) {
  return Stack(
    children: [
      // ... existing widgets (GameWidget, AnimationControls, etc.) ...
      
      // Trajectory editing toolbar
      if (_showTrajectoryToolbar && !isBoardBusy(bp))
        TrajectoryEditingToolbar(
          currentTrajectory: _currentTrajectory,
          isVisible: _showTrajectoryToolbar,
          onToggleEnabled: _onToggleTrajectoryEnabled,
          onAddControlPoint: _onAddControlPoint,
          onRemoveControlPoint: _onRemoveControlPoint,
          onSmoothnessChanged: _onSmoothnessChanged,
          onColorChanged: _onPathColorChanged,
          onClose: _onCloseTrajectoryToolbar,
        ),
    ],
  );
}
```

### Step 3: Wire Up Toolbar Callbacks

**File:** `game_screen.dart`

```dart
// Show toolbar when component selected in animation mode
void _onComponentSelected(String componentId, FieldItemModel component) {
  final ap = ref.read(animationProvider);
  final animationModel = ap.selectedAnimationModel;
  
  // Only show toolbar if we have an animation with multiple scenes
  if (animationModel == null || animationModel.scenes.length < 2) return;
  
  // Get current scene index
  final currentScene = ap.selectedScene;
  if (currentScene == null) return;
  
  final sceneIndex = animationModel.scenes.indexWhere((s) => s.id == currentScene.id);
  
  // Don't show for first scene (no previous scene to create trajectory from)
  if (sceneIndex == 0) return;
  
  setState(() {
    _selectedComponentId = componentId;
    _currentTrajectory = currentScene.trajectoryData?.getTrajectory(componentId);
    _showTrajectoryToolbar = true;
  });
  
  // Show trajectory visualization on canvas
  tacticBoardGame?.trajectoryManager?.showTrajectoryForComponent(
    componentId: componentId,
    currentItem: component,
  );
}

// Hide toolbar when selection cleared
void _onSelectionCleared() {
  setState(() {
    _showTrajectoryToolbar = false;
    _selectedComponentId = null;
    _currentTrajectory = null;
  });
  
  // Hide trajectory visualization
  tacticBoardGame?.trajectoryManager?.hideTrajectory();
}

// Toolbar action handlers
void _onToggleTrajectoryEnabled() {
  tacticBoardGame?.trajectoryManager?.toggleTrajectoryEnabled();
}

void _onAddControlPoint() {
  tacticBoardGame?.trajectoryManager?.addControlPoint();
}

void _onRemoveControlPoint() {
  tacticBoardGame?.trajectoryManager?.removeControlPoint();
}

void _onSmoothnessChanged(double smoothness) {
  tacticBoardGame?.trajectoryManager?.updateSmoothness(smoothness);
}

void _onPathColorChanged(Color color) {
  tacticBoardGame?.trajectoryManager?.updatePathColor(color);
}

void _onCloseTrajectoryToolbar() {
  _onSelectionCleared();
}
```

### Step 4: Listen to Selection Changes from BoardProvider

**File:** `game_screen.dart`

**Add listener in initState:**
```dart
@override
void initState() {
  super.initState();
  
  // ... existing init code ...
  
  // Listen to selection changes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.listen<BoardState>(boardProvider, (previous, next) {
      // Check if selection changed
      if (next.selectedComponent != null) {
        _onComponentSelected(
          next.selectedComponent!.id,
          next.selectedComponent!,
        );
      } else if (previous?.selectedComponent != null && next.selectedComponent == null) {
        _onSelectionCleared();
      }
    });
  });
}
```

### Step 5: Persist Trajectory Changes to Firestore

**File:** `trajectory_editor_manager.dart` (already implemented)

The `onTrajectoryChanged` callback fires whenever user modifies trajectory:
- Drags control point
- Adds/removes control point
- Changes smoothness
- Changes color
- Toggles enabled

**Handler in TacticBoardGame:**
```dart
void _handleTrajectoryChanged(String componentId, TrajectoryPathModel trajectory) {
  final animationProvider = ref.read(animationProviderRef);
  final currentScene = animationProvider.selectedScene;
  
  if (currentScene == null) return;
  
  // Update trajectory data
  final trajectoryData = currentScene.trajectoryData ?? AnimationTrajectoryData();
  trajectoryData.setTrajectory(componentId, trajectory);
  
  // Update scene
  final updatedScene = currentScene.copyWith(
    trajectoryData: trajectoryData,
  );
  
  // Save to Firestore (via animation provider)
  animationProvider.notifier.updateScene(updatedScene);
}
```

---

## 📱 User Workflow

### Scenario: Creating a Curved Run Around Defenders

**Step 1: User creates Scene 1**
```
Place striker at starting position A
Save scene
```

**Step 2: User creates Scene 2**
```
Add new scene
Move striker to end position B (around 3 defenders)
→ Toolbar appears automatically!
```

**Step 3: User sees trajectory UI**
```
┌─────────────────────────────┐
│ Ghost component at position A│ ← Semi-transparent, shows where player was
└─────────────────────────────┘
     │
     │ ─ ─ ─╮ ← Straight line by default
     │      │
     │      ╰─ ─ ─►
     │            ┌─────────────────────────┐
     │            │ Current player position B│
     │            └─────────────────────────┘
     │
     └─ [Trajectory Toolbar appears top-right]
```

**Step 4: User enables custom path**
```
Clicks "Enable Custom Path" toggle
→ 2 default control points appear on the line
→ Path becomes editable
```

**Step 5: User drags control points**
```
Drag first control point left (around defender 1)
→ Path recalculates in real-time
→ Smooth curve appears

Drag second control point right (around defender 2)
→ Path curves more
→ Shows realistic running path
```

**Step 6: User adjusts smoothness**
```
Moves smoothness slider to 70%
→ Path becomes smoother
→ More natural movement
```

**Step 7: User changes color**
```
Taps purple color circle
→ Path changes to purple
→ Easier to distinguish multiple player movements
```

**Step 8: Animation playback**
```
User clicks play button
→ Toolbar hides automatically
→ Player follows curved path (not straight line!)
→ Smooth, professional animation
```

---

## 🎯 Benefits of On-Canvas Editing

### ✅ Large Workspace
- Full field view
- Can see all players and context
- Easy to plan movements around obstacles

### ✅ Immediate Visual Feedback
- Drag control point → see curve update instantly
- Change smoothness → see effect immediately
- Change color → visualize multiple paths at once

### ✅ Non-Intrusive
- Toolbar is collapsible
- Semi-transparent background
- Can be dismissed with close button
- Hides during animation playback

### ✅ Touch-Friendly
- Large touch targets for control points
- Drag gestures feel natural
- Works great on tablets/mobile

### ✅ Context-Aware
- Only appears when relevant (animation mode + scene 2+)
- Auto-shows when component selected
- Auto-hides when selection cleared

---

## 🚀 Next Steps

1. **Integrate TrajectoryEditorManager into TacticBoardGame**
   - Add manager field
   - Initialize when animation mode active
   - Wire up onTrajectoryChanged callback

2. **Add Toolbar to GameScreen Stack**
   - Add state variables
   - Add toolbar widget to Stack
   - Position at top-right

3. **Wire Up Selection Events**
   - Listen to boardProvider selection changes
   - Show/hide toolbar based on selection
   - Show/hide trajectory visualization

4. **Test User Flow**
   - Create multi-scene animation
   - Select player in Scene 2
   - Verify toolbar appears
   - Test all toolbar controls
   - Verify persistence to Firestore

5. **Polish & Refinements**
   - Add keyboard shortcuts (optional)
   - Add undo/redo support for trajectory edits
   - Add preset curve templates (future)
   - Performance optimization

---

## 📝 Implementation Checklist

- [x] Create TrajectoryEditingToolbar widget
- [ ] Add TrajectoryEditorManager to TacticBoardGame
- [ ] Wire manager to GameScreen
- [ ] Add toolbar to GameScreen Stack
- [ ] Listen to selection events
- [ ] Implement toolbar callbacks
- [ ] Test trajectory editing workflow
- [ ] Test persistence to Firestore
- [ ] Test animation playback with trajectories
- [ ] Polish UI animations and transitions

---

**Status:** Toolbar UI complete, ready for integration!
