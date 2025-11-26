# Device Capability Detection Implementation

## Overview
This implementation addresses crashes and performance issues on older iPads during animation recording by detecting device capabilities and warning users before attempting resource-intensive operations.

## Problem Statement
- Animation recording on older iPads (especially those with low RAM) causes flickering and crashes
- Video recording uses FFmpeg which is memory-intensive
- Auto-save during recording exacerbates memory pressure
- Users were not warned about potential issues on low-capability devices

## Solution Components

### 1. Device Capability Checker (`lib/app/helper/device_capability_checker.dart`)

#### Features
- Detects device capabilities on iOS, Android, and Web
- Returns comprehensive device information including:
  - Device capability level (high/medium/low/unknown)
  - OS version
  - Device model
  - Low RAM detection
  - Old OS detection
  - Specific warnings and recommendations

#### Device Capability Levels
- **High**: Modern devices with good performance (no warnings)
- **Medium**: Mid-range devices (may show warnings based on context)
- **Low**: Older/budget devices that may struggle (always show warnings)
- **Unknown**: Cannot determine capabilities (no warnings)

#### iOS Detection Logic
```dart
- RAM < 2 GB → Low capability, low RAM warning
- iOS < 13.0 → Low capability, old OS warning
- RAM < 3 GB → Medium capability
- RAM ≥ 3 GB and iOS ≥ 13.0 → High capability
```

#### Android Detection Logic
```dart
- RAM < 2 GB → Low capability, low RAM warning
- Android < 7.0 → Low capability, old OS warning
- RAM < 3 GB → Medium capability
- RAM ≥ 3 GB and Android ≥ 7.0 → High capability
```

### 2. User Warning System

#### Warning Dialog (`_showDeviceCapabilityWarning` in game_screen.dart)
- Shows before video recording starts
- Displays device information:
  - Device model
  - OS version
  - Memory status
  - Capability warnings
- Provides actionable recommendations
- Allows user to:
  - Cancel and avoid the operation
  - Proceed anyway (informed decision)

#### Warning Appearance
- **Low capability devices**: Orange warning icon
- **Critical devices** (low RAM + old OS): Red error icon
- Clear messaging about potential issues
- Device-specific information displayed

### 3. Integration Points

#### Video Export Flow
The device capability check is integrated at **two locations** before video recording starts:

1. **Share Animation** (line ~709 in game_screen.dart)
   ```dart
   AnimationShareType.video selected
   → Check device capabilities
   → Show warning if needed
   → User decides to proceed or cancel
   → Start video recording
   ```

2. **Download Animation** (line ~818 in game_screen.dart)
   ```dart
   AnimationShareType.video selected
   → Check device capabilities
   → Show warning if needed
   → User decides to proceed or cancel
   → Start video recording
   ```

## User Experience Flow

### High Capability Device
1. User selects "Video/GIF (Animation)" option
2. **No warning shown** - proceeds directly to recording
3. Normal recording flow continues

### Low Capability Device
1. User selects "Video/GIF (Animation)" option
2. **Warning dialog appears** with:
   - Device performance warning
   - Specific device information
   - Recommendations (e.g., "Use image export instead")
3. User chooses:
   - **Cancel**: Returns to previous screen, no recording started
   - **Proceed Anyway**: Continues with recording (user is informed of risks)

## Recommendations Provided

### For Low RAM Devices
- "Your device has limited memory. Video recording may cause the app to slow down or crash."
- "Consider using image export instead for better reliability."
- "If proceeding with video, expect longer processing times."

### For Old OS Versions
- "Your device is running an older OS version. Video recording may not be fully optimized."
- "Consider updating your device OS for better performance."
- "Some features may not work as expected."

### For Critical Devices (Low RAM + Old OS)
- "Your device has very limited resources. Video recording may fail or cause crashes."
- "We strongly recommend using image export instead."
- "Video recording is not recommended on this device."

## Technical Implementation Details

### Auto-Save Prevention
The existing `isRecordingAnimation` flag (already implemented) prevents auto-save during recording:

```dart
// In tactic_board_game.dart update() method
if (animationState.isPerformingUndo || 
    animationState.skipHistorySave || 
    animationState.isRecordingAnimation) {
  return; // Skip auto-save
}
```

### Memory Optimization
- History limited to 30 items (`_maxHistorySize` in animation_provider.dart)
- Video recording uses widget_capture_x_plus with FFmpeg
- Recording state properly managed with try-finally blocks

## Testing Recommendations

### Manual Testing
1. **Test on newer devices** (iPhone 12+, iPad Pro):
   - Should NOT show warning
   - Recording should work smoothly

2. **Test on older devices** (iPad Air 2, iPad mini 4):
   - SHOULD show warning
   - User can still proceed if desired
   - Monitor for crashes/performance issues

3. **Test on low-memory devices** (< 2GB RAM):
   - SHOULD show critical warning
   - Recording may still work but with limitations

### Edge Cases
- User dismisses warning by tapping outside (currently disabled with barrierDismissible: false)
- User cancels mid-recording (handled by existing error handling)
- Device capability check fails (returns 'unknown' capability, no warning shown)

## Future Enhancements

### Possible Improvements
1. **Adaptive Quality Settings**: Automatically reduce video quality on low-capability devices
2. **Frame Rate Adjustment**: Lower FPS for struggling devices
3. **Resolution Scaling**: Reduce video resolution based on device capabilities
4. **Progress Monitoring**: Show remaining memory during recording
5. **Graceful Degradation**: Automatically switch to image export if recording fails

### Performance Monitoring
Consider adding analytics to track:
- Warning display frequency
- User proceed vs. cancel rates
- Crash rates on different device types
- Recording success rates by device capability

## Dependencies

### Required Packages
- `flutter/foundation.dart` - Platform detection
- `flutter/services.dart` - Method channel for native calls (future use)
- `device_info_plus` - Device information retrieval (if needed for more detailed info)

### Existing Integrations
- Works with existing `isRecordingAnimation` flag
- Integrates with `AnimationShareType` enum
- Uses existing `ColorManager` for theming

## Migration Notes

### Breaking Changes
None - This is an additive feature

### Backward Compatibility
- Existing code continues to work
- Warning is only shown on low-capability devices
- High-capability devices see no change in behavior

## Maintenance

### Code Locations
- Device capability logic: `lib/app/helper/device_capability_checker.dart`
- Warning dialog: `game_screen.dart` (_showDeviceCapabilityWarning method)
- Integration: `game_screen.dart` (lines ~709 and ~818)

### Updating Thresholds
To adjust what constitutes "low capability", modify the constants in `device_capability_checker.dart`:
- iOS RAM threshold: Currently 2 GB for low, 3 GB for medium
- iOS version threshold: Currently iOS 13.0
- Android RAM threshold: Currently 2 GB for low, 3 GB for medium
- Android version threshold: Currently Android 7.0

## Summary

This implementation provides a user-friendly way to warn users about potential performance issues before they encounter crashes or slowdowns. It's non-intrusive for modern devices while providing valuable guidance for users with older hardware.

**Key Benefits:**
✅ Prevents unexpected crashes by setting user expectations
✅ Reduces support burden from confused users on older devices
✅ Allows informed users to still attempt recording if they wish
✅ Provides specific, actionable recommendations
✅ Maintains excellent UX for modern device users (no unnecessary warnings)
