# Agent F2 Instructions - Performance & Coordination
## Framework Setup Components 5-7

**Agent Mission:** Create performance monitoring and coordination tools to keep all agents synchronized and track system performance.

**Estimated Time:** 2 days (5-6 hours per component)

**Branch:** `claude/framework-setup`

---

## 📋 Your Components

You will create:
1. **Component 5:** Performance Profiler (`tests/performance/performance_profiler.gd` + helper)
2. **Component 6:** Coordination Dashboard (`COORDINATION-DASHBOARD.md`)
3. **Component 7:** Rollback System (`scripts/checkpoint_manager.gd`)

---

## 📚 Prerequisites

### Required Reading

Before starting, read:
- `FRAMEWORK-SETUP-GUIDE.md` (lines 2059-3611 for your components)
- `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md` (Complete quality/coordination framework)
- `COORDINATION-DASHBOARD.md` (Check for blockers, update your status)
- `KNOWN-ISSUES.md` (Review for related issues)

### Autoload Registration (CRITICAL)

After creating Component 5, you MUST register autoload. See `FRAMEWORK-SETUP-GUIDE.md` lines 98-297 for detailed instructions.

**Required autoload:**
- `PerformanceProfiler` → `res://tests/performance/performance_profiler.gd`

**Note:** This is a Tier 2 task (Godot MCP agent will do this), but you must document it in your HANDOFF.

---

## 🎯 Component 5: Performance Profiler

**Duration:** 0.75 day
**File:** `tests/performance/performance_profiler.gd` + `tests/performance/profile_helper.gd`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 2072-2612

### Research Phase (45 minutes)

Search for:
- "Godot 4.5 performance profiling"
- "GDScript 4.5 frame time measurement"
- "Godot performance monitoring"
- "game performance metrics"

Document findings in `research/framework-performance-profiler-research.md`

### Implementation

Create `tests/performance/performance_profiler.gd` with:

**Key Features:**
- `SystemProfile` class for per-system statistics
- Frame time tracking (16.67ms target for 60 FPS)
- Per-system profiling (1ms budget per system)
- Memory usage monitoring
- Beat timing accuracy tracking (5ms tolerance)
- Performance warnings via signals
- Markdown report generation

**Performance Thresholds:**
- Frame time: 16.67ms (60 FPS)
- System time: 1ms per system
- Memory: 512MB warning threshold
- Beat timing: 5ms tolerance

**Important:** See full implementation in FRAMEWORK-SETUP-GUIDE.md lines 2104-2413

### Helper Script

Create `tests/performance/profile_helper.gd` for easy integration:

**Key Features:**
- Static helper class
- `ProfileHelper.start(system_name)` / `ProfileHelper.end(system_name)`
- `ProfileHelper.report()` to print results
- `ProfileHelper.save(file_path)` to save report

**Important:** See full implementation in FRAMEWORK-SETUP-GUIDE.md lines 2419-2466

### Checkpoint

Create `checkpoints/framework-performance-profiler-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 2479-2612

---

## 🎯 Component 6: Coordination Dashboard

**Duration:** 0.75 day
**File:** `COORDINATION-DASHBOARD.md`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 2616-3078

### Research Phase (30 minutes)

Search for:
- "multi-agent coordination dashboard"
- "project status tracking markdown"
- "agile task board markdown"
- "team coordination best practices"

Document findings in `research/framework-coordination-dashboard-research.md`

### Implementation

Create `COORDINATION-DASHBOARD.md` with:

**Key Sections:**
1. **Current Focus** - Active phase, target completion, overall progress
2. **Agent Status** - Table showing all agents (F1, F2, F3, S01-S26)
3. **Framework Component Status** - 10 components with status/quality scores
4. **Dependencies & Blockers** - What's blocking progress
5. **Recent Activity** - Daily updates from all agents
6. **Issues & Risks** - Proactive risk management
7. **Milestones** - Key targets with status
8. **Agent Hand-off Checklist** - Complete handoff requirements
9. **Communication Protocol** - Status update guidelines
10. **Quality Metrics** - Overall quality tracking
11. **Quick Reference** - Important files, commands, git workflow

**Status Indicators:**
- 🟢 Active (currently working)
- 🟡 Blocked (waiting on dependency)
- 🔵 Review (awaiting review)
- ⚪ Waiting (not started)
- ✅ Complete (finished)

**Important:** See full template in FRAMEWORK-SETUP-GUIDE.md lines 2644-2909

### Checkpoint

Create `checkpoints/framework-coordination-dashboard-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 2928-3078

---

## 🎯 Component 7: Rollback System

**Duration:** 0.5 day
**File:** `scripts/checkpoint_manager.gd`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 3083-3611

### Research Phase (30 minutes)

Search for:
- "Godot 4.5 save system"
- "GDScript 4.5 file copy"
- "version control for game state"
- "checkpoint rollback system"

Document findings in `research/framework-rollback-system-research.md`

### Implementation

Create `scripts/checkpoint_manager.gd` with:

**Key Features:**
- `Snapshot` class for metadata tracking
- Snapshot creation (copies all checkpoint files)
- Rollback capability (restore to any snapshot)
- Snapshot listing (view all available)
- Snapshot deletion (cleanup old snapshots)
- JSON metadata persistence
- Recursive file operations

**Snapshot Format:**
- ID: `snapshot-YYYYMMDD-HHMMSS`
- Location: `.snapshots/[snapshot-id]/`
- Metadata: `metadata.json` with timestamp, description, file list

**Important:** See full implementation in FRAMEWORK-SETUP-GUIDE.md lines 3111-3422

### .gitignore Update

Add to `.gitignore`:
```
.snapshots/
```

### Checkpoint

Create `checkpoints/framework-rollback-system-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 3441-3611

**Must include:**
- Autoload registration note (CheckpointManager needs registration)

---

## 📤 Final Deliverable: HANDOFF-FRAMEWORK-F2.md

After completing all 3 components, create `HANDOFF-FRAMEWORK-F2.md`:

```markdown
# HANDOFF: Framework F2 - Performance & Coordination

## Components Completed

### Component 5: Performance Profiler
- ✅ `tests/performance/performance_profiler.gd` - Performance tracking
- ✅ `tests/performance/profile_helper.gd` - Easy integration helper
- ✅ `research/framework-performance-profiler-research.md`
- ✅ `checkpoints/framework-performance-profiler-checkpoint.md`

### Component 6: Coordination Dashboard
- ✅ `COORDINATION-DASHBOARD.md` - Multi-agent status tracking
- ✅ `research/framework-coordination-dashboard-research.md`
- ✅ `checkpoints/framework-coordination-dashboard-checkpoint.md`

### Component 7: Rollback System
- ✅ `scripts/checkpoint_manager.gd` - Snapshot/rollback capability
- ✅ `.gitignore` - Updated with .snapshots/
- ✅ `research/framework-rollback-system-research.md`
- ✅ `checkpoints/framework-rollback-system-checkpoint.md`

## MCP Agent Tasks (Tier 2)

### Autoload Registration

**CRITICAL:** The following autoloads MUST be registered in Godot Project Settings:

```bash
# Method 1: Via Godot UI
# Project → Project Settings → Autoload tab
# Add each autoload with "Enable" checkbox ON

# Method 2: Manual project.godot edit
# Add to [autoload] section:
PerformanceProfiler="*res://tests/performance/performance_profiler.gd"
CheckpointManager="*res://scripts/checkpoint_manager.gd"

# Verify with verification script
```

See FRAMEWORK-SETUP-GUIDE.md lines 98-297 for detailed instructions.

### Verification Checklist

- [ ] All GDScript files have no syntax errors
- [ ] Autoloads registered and verified
- [ ] PerformanceProfiler can track system performance
- [ ] ProfileHelper static methods work
- [ ] Coordination Dashboard formatted correctly
- [ ] CheckpointManager can create snapshots
- [ ] Rollback functionality works
- [ ] .snapshots/ directory created and gitignored
- [ ] All checkpoints created and valid

## Testing Commands

```bash
# Test performance profiler
# (In Godot console or script)
var profiler = PerformanceProfiler.new()
profiler.start_profiling()
# ... run some systems ...
print(profiler.generate_report())

# Using ProfileHelper
ProfileHelper.start("TestSystem")
# ... do work ...
ProfileHelper.end("TestSystem")
ProfileHelper.report()

# Test checkpoint manager
var manager = CheckpointManager.new()
manager.create_snapshot("test snapshot")
manager.print_snapshots()
manager.rollback_to_snapshot("snapshot-20251117-143022")
```

## Integration Points

### With F1 Components:
- Integration Tests can measure execution performance
- Quality Gates define performance quality standards
- CI Runner can generate performance reports

### With F3 Components:
- Known Issues DB tracks performance issues
- Knowledge Base stores performance patterns
- Asset Pipeline (assets may affect performance)

## Status

✅ **All F2 components complete!**

**Ready for:**
- F3 to continue (Components 8-10)
- System agents to monitor performance
- Agents to coordinate via dashboard
- Safe rollback if needed
```

---

## ✅ Completion Checklist

Before marking your work complete:

- [ ] All 3 components implemented with complete code
- [ ] All 3 research documents created
- [ ] All 3 checkpoint files created
- [ ] Quality gate self-evaluation (80+ score for each component)
- [ ] Integration between components tested
- [ ] HANDOFF-FRAMEWORK-F2.md created
- [ ] COORDINATION-DASHBOARD.md updated with your completion
- [ ] .gitignore updated
- [ ] All files committed to git
- [ ] Git pushed to `claude/framework-setup` branch

---

## 🎨 Creative Notes

**Make monitoring satisfying:**
- Colorful performance indicators
- Clear visual status in dashboard
- Fun snapshot names (could use creative IDs)
- Celebration when performance targets met
- Helpful warnings (not scary)

---

## 📞 Need Help?

If blocked:
1. Search `knowledge-base/` for solutions
2. Check `KNOWN-ISSUES.md` for similar problems
3. Add blocker to COORDINATION-DASHBOARD.md
4. Document issue in KNOWN-ISSUES.md if novel

---

**Good luck, Agent F2! You're building the coordination and performance foundation! ⚡📊**
