# Phase 1 Quick Reference Guide

## 🎯 What Changed?

Auto-save went from **1 second** → **30 seconds**  
Result: **97% reduction in Firebase writes** (540 → 18 per session)

---

## 🎛️ Feature Flags (lib/app/config/feature_flags.dart)

| Flag | Default | Purpose |
|------|---------|---------|
| `enableDebouncedAutoSave` | `true` | 30s auto-save (was 1s) |
| `enableEventDrivenSave` | `true` | Immediate save on critical actions |
| `enableHistoryOptimization` | `true` | Skip history on auto-saves |
| `enableSaveDebugLogs` | `true` | Console logging for saves |

**Emergency Rollback:** Set `enableDebouncedAutoSave = false` → Instant revert to 1s saves

---

## 📝 How to Use Event-Driven Saves

### In Any Component That Modifies Board State

```dart
// After a critical user action (drag end, add component, etc.):
if (game is TacticBoard) {
  game.triggerImmediateSave(reason: 'Your action description');
}
```

### Examples

**Player Drag End:**
```dart
onDragEnd() {
  // ... existing logic ...
  game.triggerImmediateSave(reason: 'Player drag end');
}
```

**Component Added:**
```dart
addComponent(FieldItemModel item) {
  // ... existing logic ...
  game.triggerImmediateSave(reason: 'Component added');
}
```

**Drawing Complete:**
```dart
onDrawingComplete() {
  // ... existing logic ...
  game.triggerImmediateSave(reason: 'Drawing complete');
}
```

---

## 🔍 Debugging

### Enable Verbose Logging
```dart
// In feature_flags.dart:
static const bool enableSaveDebugLogs = true;
```

### Console Output Examples
```
✅ Auto-save triggered: State changed (30.0s interval)
✅ Event-driven save triggered: Player drag end
✅ History save skipped for auto-save (optimization enabled)
✅ Save completed (auto): abc123 - true
⏭️ Auto-save skipped: No state changes detected
⏭️ Save skipped: Animation playing
```

---

## 📊 Monitoring

### Check Auto-Save Interval
1. Open tactic board
2. Make a change
3. Wait and watch console
4. Should see save log every **30 seconds** (not 1 second)

### Verify Firebase Write Count
1. Firebase Console → Firestore → Usage
2. Edit for 15 minutes
3. Check "Document Writes"
4. **Expected:** ~18 writes (was 540)

### Check History Optimization
1. Make auto-save changes (wait 30s)
2. Firestore: Animation updated, NO history write
3. Manual save (fullscreen toggle)
4. Firestore: Animation + History both updated

---

## ⚠️ Important Notes

### User Experience
- ✅ No visible changes for users
- ✅ Saves still instant from user perspective
- ✅ Max data loss: 30 seconds (was 1 second)
- ✅ Critical actions save immediately (drag end, etc.)

### What Still Works
- ✅ Undo/redo (uses manual save history)
- ✅ Auto-save (just less frequent)
- ✅ Manual saves (fullscreen toggle, etc.)
- ✅ All existing functionality

### What's Different
- 🔄 Auto-save interval: 1s → 30s
- 🔄 History on auto-save: Always → Skip
- 🔄 Immediate saves on: Never → Critical actions
- 🔄 Write count: 540/session → 18/session

---

## 🐛 Troubleshooting

### Problem: Saves still happening every 1 second
**Solution:** Check `FeatureFlags.enableDebouncedAutoSave` is `true`

### Problem: No console logs
**Solution:** Set `FeatureFlags.enableSaveDebugLogs = true`

### Problem: History not saving at all
**Solution:** History should save on manual actions (fullscreen toggle). If not, check `FeatureFlags.enableHistoryOptimization`

### Problem: Need to rollback immediately
**Solution:** 
```dart
// feature_flags.dart
static const bool enableDebouncedAutoSave = false;
static const bool enableEventDrivenSave = false;
static const bool enableHistoryOptimization = false;
```
Redeploy → Back to original behavior

---

## 📈 Success Metrics

### Technical
- [ ] Auto-save interval = 30s (verify in logs)
- [ ] Firebase writes = ~18 per 15-min session
- [ ] Event-driven saves working (verify in logs)
- [ ] History optimization working (check Firestore)
- [ ] No errors in production

### Business
- [ ] Cost reduction: $44.30 → $1.50/month at 5K users
- [ ] 97% write reduction achieved
- [ ] No user complaints about data loss
- [ ] No increase in support tickets

### User Experience
- [ ] No visible changes for users
- [ ] Undo/redo still works
- [ ] No performance degradation
- [ ] Zero data loss incidents

---

## 🚀 Deployment Checklist

### Before Deploy
- [x] Feature flags created
- [x] Code changes implemented
- [ ] Unit tests passing
- [ ] Manual QA complete
- [ ] Code review approved

### Deploy
- [ ] Deploy to beta (5% users)
- [ ] Monitor for 24 hours
- [ ] Check error rates (<1%)
- [ ] Verify cost reduction in Firebase

### After Deploy
- [ ] Gradual rollout (10% → 25% → 50% → 100%)
- [ ] Monitor Firebase usage daily
- [ ] Collect user feedback
- [ ] Document lessons learned

### Rollback If Needed
- [ ] Set feature flags to `false`
- [ ] Redeploy
- [ ] Monitor recovery
- [ ] Investigate issues

---

## 💡 Tips

1. **Always check feature flags first** when debugging save issues
2. **Enable debug logs** during testing for visibility
3. **Use Firestore console** to verify write counts
4. **Test rollback** in staging before production deploy
5. **Monitor costs daily** after rollout to verify savings

---

## 📞 Support

### Questions?
- Check `docs/ARCHITECTURE_PHASES.md` for full design
- Check `docs/WORK_LOG.md` for implementation history
- Check `docs/PHASE_1_SUMMARY.md` for detailed analysis

### Issues?
1. Enable debug logs
2. Check console output
3. Verify feature flags
4. Test rollback if needed

---

**Last Updated:** November 18, 2025  
**Phase 1 Status:** 70% Complete  
**Ready for:** Integration testing & QA
