# Git Workflow - Parallel Agent Development
## Branch Strategy, Merge Protocol, and Conflict Resolution

**Version:** 1.0
**Date:** 2025-11-18
**Project:** Rhythm RPG - Godot 4.5
**Workflow:** Multi-Agent Parallel Development

---

## Table of Contents

1. [Branch Naming Convention](#branch-naming-convention)
2. [File Isolation Rules](#file-isolation-rules)
3. [Merge Strategy](#merge-strategy)
4. [Pre-Merge Testing Requirements](#pre-merge-testing-requirements)
5. [Conflict Resolution Protocol](#conflict-resolution-protocol)
6. [Wave-by-Wave Git Workflow](#wave-by-wave-git-workflow)
7. [Emergency Rollback Procedures](#emergency-rollback-procedures)

---

## Branch Naming Convention

### Framework Agents (F1, F2, F3)

**Format:** `claude/framework-setup`

**Why single branch:**
- Components have zero file overlap (see File Isolation below)
- Can safely commit/push to same branch
- Merge to main when all 10 components complete

**Example commits:**
```bash
git commit -m "Add Integration Test Suite (F1 Component 1)"
git commit -m "Add Performance Profiler (F2 Component 5)"
git commit -m "Add Known Issues DB (F3 Component 8)"
```

### System Agents (S01-S26)

**Format:** `claude/s{##}-{system-name}`

**Examples:**
```
claude/s01-conductor
claude/s02-input-system
claude/s03-player-controller
claude/s04-combat-system
claude/s05-inventory
claude/s11-enemy-ai
claude/s24-cooking
```

**Rules:**
- Use two-digit zero-padded numbers (s01, s02, not s1, s2)
- Use lowercase kebab-case for system names
- One branch per system (never reuse branches)
- Branch created from main at start of work

**Branch creation:**
```bash
# Create branch from main
git checkout main
git pull origin main
git checkout -b claude/s05-inventory

# Or create directly
git checkout -b claude/s05-inventory main
```

---

## File Isolation Rules

### 🚨 CRITICAL: Zero File Overlap Required

To enable parallel development without merge conflicts, **each agent may ONLY modify files in their designated directory**.

### Framework Agents (F1, F2, F3) - File Ownership

| Agent | Allowed Directories | Forbidden Directories |
|-------|---------------------|----------------------|
| **F1** | `tests/integration/`<br>`scripts/validate_checkpoint.gd`<br>`scripts/ci_runner.gd`<br>`quality-gates.json`<br>`checkpoints/framework-*` | ALL other files |
| **F2** | `tests/performance/`<br>`scripts/checkpoint_manager.gd`<br>`COORDINATION-DASHBOARD.md`<br>`.gitignore`<br>`checkpoints/framework-*` | ALL other files |
| **F3** | `KNOWN-ISSUES.md`<br>`knowledge-base/`<br>`ASSET-PIPELINE.md`<br>`assets/`<br>`checkpoints/framework-*` | ALL other files |

### System Agents (S01-S26) - File Isolation Rules

**EACH SYSTEM GETS ITS OWN DIRECTORY:**

```
src/
  systems/
    s01-conductor/
      conductor.gd
      beat_tracker.gd
      conductor_data.json
    s02-input/
      input_manager.gd
      input_config.json
    s03-player/
      player_controller.gd
      player_stats.gd
      player_data.json
    s04-combat/
      combat_manager.gd
      damage_calculator.gd
      combat_data.json
    [...etc for all 26 systems...]
```

**Rules for System Agents:**
1. ✅ **Allowed:** Modify ONLY `src/systems/s{##}-{your-system}/` directory
2. ✅ **Allowed:** Create your scene files in `scenes/s{##}-{your-system}/`
3. ✅ **Allowed:** Add assets to `assets/` in system-specific subdirectories
4. ✅ **Allowed:** Create checkpoints in `checkpoints/`
5. ✅ **Allowed:** Add knowledge base entries in `knowledge-base/`
6. ✅ **Allowed:** Add issues to `KNOWN-ISSUES.md` (atomic append-only operations)
7. ❌ **FORBIDDEN:** Modify ANY other system's directory
8. ❌ **FORBIDDEN:** Modify shared core files (see below)

### Shared Files - Special Handling

**These files require coordination:**

| File | Who Can Modify | Protocol |
|------|----------------|----------|
| `project.godot` | Tier 2 MCP agents | Autoload registration only, must coordinate in COORDINATION-DASHBOARD.md |
| `src/core/` | Developer only | No agent modifications allowed |
| `COORDINATION-DASHBOARD.md` | All agents | Status updates only (atomic operations) |
| `KNOWN-ISSUES.md` | All agents | Append-only (add issues, never modify existing) |

### What if I Need to Modify a Shared File?

**STOP and follow this protocol:**

1. **Post in COORDINATION-DASHBOARD.md:**
   ```markdown
   ## 🚨 Shared File Modification Request

   **Agent:** S05 (Inventory)
   **File:** src/core/game_manager.gd
   **Reason:** Need to register inventory with central save system
   **Proposed Change:** Add inventory_data to save_game() method
   ```

2. **Wait for developer approval**
3. **Developer makes the change** or grants explicit permission
4. **You document the integration** in your HANDOFF

**Why this rule exists:**
- Prevents merge conflicts across 7+ parallel branches
- Maintains architectural integrity
- Avoids "too many cooks" problems

---

## Merge Strategy

### Framework Setup (F1, F2, F3)

**Single merge when complete:**

```bash
# After all 10 framework components are done
git checkout main
git pull origin main
git merge claude/framework-setup
git push origin main
```

**Verification before merge:**
- [ ] All 10 components implemented
- [ ] All checkpoints created and valid
- [ ] All tests passing
- [ ] Quality gates met (80+ scores)

### System Agents (S01-S26) - Wave-Based Merging

**🚨 CRITICAL: Merge in Wave Order, Not Random Order**

**Why wave order matters:**
- Wave 2 depends on Wave 1
- Wave 4 depends on Wave 3
- Merging out of order breaks dependencies

**Merge Protocol:**

#### Step 1: Wave Completion Check

Before merging any wave, verify ALL systems in that wave are complete:

```markdown
## Wave 1 Completion Checklist
- [x] S01 Conductor (claude/s01-conductor)
- [x] S02 Input System (claude/s02-input-system)
```

#### Step 2: Merge Systems Within Wave (Any Order)

Within a wave, merge order doesn't matter (no dependencies):

```bash
# Wave 1 - merge in any order
git checkout main
git merge claude/s01-conductor
git push origin main

git checkout main
git merge claude/s02-input-system
git push origin main
```

**OR merge all at once if no conflicts:**

```bash
git checkout main
git merge claude/s01-conductor claude/s02-input-system
git push origin main
```

#### Step 3: Integration Test After Wave Merge

```bash
# After merging all systems in a wave
godot --headless --script scripts/ci_runner.gd
```

**If tests fail:**
- Rollback last merge
- Fix issues on feature branch
- Re-merge

#### Step 4: Start Next Wave

Only after previous wave is **fully merged and tested**, start next wave.

### Wave Merge Order

**Must follow this sequence:**

```
Wave 0 (Framework) → Wave 1 → Wave 2 → Wave 3 → Wave 4 → Wave 5 → Wave 6 → Wave 7 → Wave 8 → Wave 9 → Wave 10
```

**Within each wave (any order):**

- **Wave 1:** s01, s02 (any order)
- **Wave 2:** s03 (only 1 system)
- **Wave 3:** s04 (only 1 system)
- **Wave 4:** s05, s11, s13, s14, s15, s16, s18 (any order - 7 parallel!)
- **Wave 5:** s06, s07, s08, s12 (any order, but s07 before s08 recommended)
- **Wave 6:** s09, s17 (any order)
- **Wave 7:** s10, s24, s25, s26 (any order)
- **Wave 8:** s19, then s20 and s21 (s19 first, then s20/s21 in any order)
- **Wave 9:** s22, then s23 (must be sequential)
- **Wave 10:** s29 (only 1 system)

---

## Pre-Merge Testing Requirements

### 🚨 MANDATORY: Test Before Requesting Merge

**Never merge without testing first!**

### Tier 1 (Claude Code Web) - Pre-Merge Checklist

```bash
# 1. All code files created
ls -la src/systems/s05-inventory/
# Should show: *.gd files, *.json files

# 2. No syntax errors (basic check)
grep -r "TODO" src/systems/s05-inventory/
grep -r "FIXME" src/systems/s05-inventory/
grep -r "XXX" src/systems/s05-inventory/

# 3. HANDOFF document created
ls -la HANDOFF-S05-INVENTORY.md

# 4. Checkpoint created
ls -la checkpoints/s05-inventory-checkpoint.md

# 5. Research documented
ls -la research/s05-inventory-research.md

# 6. All files committed
git status  # Should be clean

# 7. Pushed to branch
git push -u origin claude/s05-inventory
```

### Tier 2 (Godot MCP) - Pre-Merge Checklist

```bash
# 1. Integration tests passing
godot --headless --script scripts/ci_runner.gd
# Exit code MUST be 0

# 2. No Godot errors
# In Godot console - no red errors

# 3. Play scene test
# Use play_scene to verify system works in-game

# 4. Performance check
ProfileHelper.report()
# System should be under 1ms per frame

# 5. Checkpoint validation
var validator = CheckpointValidator.new()
validator.validate_checkpoint("checkpoints/s05-inventory-checkpoint.md")
# Must pass validation

# 6. All files committed
git status  # Should be clean

# 7. Ready for merge
# Post in COORDINATION-DASHBOARD.md:
# "✅ S05 Inventory ready for merge - all tests passing"
```

### Automated Pre-Merge Test Script

Create `scripts/pre_merge_test.gd`:

```gdscript
# Godot 4.5 | GDScript 4.5
# Pre-Merge Test Runner
extends SceneTree

func _init() -> void:
    print("🧪 Running Pre-Merge Tests...")

    var all_passed := true

    # 1. Integration tests
    var suite = IntegrationTestSuite.new()
    var test_results = suite.run_all_tests()
    if test_results.failed_tests > 0:
        all_passed = false
        print("❌ Integration tests failed!")

    # 2. Checkpoint validation
    var validator = CheckpointValidator.new()
    var checkpoint_results = validator.validate_all_checkpoints()
    var failed_checkpoints := 0
    for result in checkpoint_results.values():
        if not result.passed:
            failed_checkpoints += 1

    if failed_checkpoints > 0:
        all_passed = false
        print("❌ Checkpoint validation failed!")

    # 3. Performance check
    var profiler = PerformanceProfiler.new()
    # Check if any system exceeds budget
    # (Implementation depends on profiler state)

    if all_passed:
        print("✅ All pre-merge tests passed! Ready to merge.")
        quit(0)
    else:
        print("❌ Pre-merge tests failed! Fix issues before merging.")
        quit(1)
```

**Run before merge:**
```bash
godot --headless --script scripts/pre_merge_test.gd
```

---

## Conflict Resolution Protocol

### Prevention is Key

**90% of conflicts are prevented by:**
1. ✅ Following file isolation rules
2. ✅ Merging in wave order
3. ✅ Testing before merge
4. ✅ Coordinating shared file changes

### If Conflicts Occur

**Most likely conflict scenarios:**

#### Scenario 1: COORDINATION-DASHBOARD.md Conflict

**Cause:** Multiple agents updating status simultaneously

**Resolution:**
```bash
# Accept both changes and manually merge
git checkout --ours COORDINATION-DASHBOARD.md  # Keep main version
# Then manually add your status update
# Edit file to include both updates
git add COORDINATION-DASHBOARD.md
git commit -m "Merge: Resolve COORDINATION-DASHBOARD.md conflict"
```

**Prevention:** Coordinate timing of status updates

#### Scenario 2: KNOWN-ISSUES.md Conflict

**Cause:** Multiple agents adding issues

**Resolution:**
```bash
# Accept both changes
git checkout --ours KNOWN-ISSUES.md
# Manually append your issue entry
# Edit to include both issue entries
git add KNOWN-ISSUES.md
git commit -m "Merge: Resolve KNOWN-ISSUES.md conflict - both issues added"
```

**Prevention:** Use atomic issue IDs (sequential numbering)

#### Scenario 3: project.godot Conflict

**Cause:** Multiple autoload registrations

**Resolution:**
```bash
# This is a critical file - developer resolves manually
git status  # Identify conflict
# Contact developer for manual resolution
# Developer will merge autoload entries
```

**Prevention:** Tier 2 agents coordinate autoload timing in COORDINATION-DASHBOARD.md

#### Scenario 4: File Isolation Rule Violated

**Cause:** Agent modified files outside their system directory

**Resolution:**
```bash
# REVERT the violating changes
git checkout main -- src/systems/s03-player/  # Restore other system's files
# Only keep your system's changes
git add src/systems/s05-inventory/  # Add only your files
git commit -m "Fix: Remove unauthorized changes to S03"
```

**Prevention:** Follow file isolation rules strictly!

### Developer Conflict Resolution

**When developer must intervene:**

1. Agent posts in `COORDINATION-DASHBOARD.md`:
   ```markdown
   ## 🚨 Merge Conflict - Developer Assistance Needed

   **Agent:** S05 (Inventory)
   **Branch:** claude/s05-inventory
   **Conflict:** project.godot autoload registration
   **Files:** project.godot (lines 45-48)
   ```

2. Developer resolves manually:
   ```bash
   git checkout main
   git merge claude/s05-inventory
   # Resolve conflicts in editor
   git add project.godot
   git commit -m "Merge S05: Resolve autoload conflict"
   git push origin main
   ```

3. Developer updates COORDINATION-DASHBOARD.md:
   ```markdown
   ✅ Resolved: S05 autoload conflict merged to main
   ```

---

## Wave-by-Wave Git Workflow

### Wave 0: Framework Setup

**Branches:** `claude/framework-setup` (single branch, 3 agents)

**Workflow:**
```bash
# F1, F2, F3 all work on same branch
git checkout -b claude/framework-setup
# Each agent commits their components
git commit -m "Add Integration Test Suite (F1)"
git push -u origin claude/framework-setup

# After all 10 components complete:
git checkout main
git merge claude/framework-setup
git push origin main
git tag v0.1.0-framework
```

### Wave 1: Foundation (S01, S02)

**Branches:**
- `claude/s01-conductor`
- `claude/s02-input-system`

**Workflow:**
```bash
# Create branches (can work in parallel)
git checkout -b claude/s01-conductor
git checkout -b claude/s02-input-system

# Each agent works independently
# S01 agent:
git checkout claude/s01-conductor
# ... implement S01 ...
git commit -m "Complete S01 Conductor system"
git push -u origin claude/s01-conductor

# S02 agent:
git checkout claude/s02-input-system
# ... implement S02 ...
git commit -m "Complete S02 Input System"
git push -u origin claude/s02-input-system

# Developer merges (any order)
git checkout main
git merge claude/s01-conductor
git merge claude/s02-input-system
git push origin main
git tag v0.2.0-wave1

# Run integration tests
godot --headless --script scripts/ci_runner.gd
```

### Wave 4: Maximum Parallelization (7 systems!)

**Branches:**
- `claude/s05-inventory`
- `claude/s11-enemy-ai`
- `claude/s13-vibe-bar`
- `claude/s14-tools`
- `claude/s15-vehicles`
- `claude/s16-grind-rails`
- `claude/s18-polyrhythm`

**Workflow:**
```bash
# All 7 agents create branches simultaneously
git checkout -b claude/s05-inventory
git checkout -b claude/s11-enemy-ai
# ... etc for all 7 ...

# All agents work in parallel
# Each commits and pushes independently

# Developer merges in any order (no dependencies!)
git checkout main
git merge claude/s05-inventory
git merge claude/s11-enemy-ai
git merge claude/s13-vibe-bar
git merge claude/s14-tools
git merge claude/s15-vehicles
git merge claude/s16-grind-rails
git merge claude/s18-polyrhythm
git push origin main
git tag v0.5.0-wave4

# CRITICAL: Run full integration test suite
godot --headless --script scripts/ci_runner.gd
```

### Wave 8: Staggered Start (S19 first, then S20/S21)

**Branches:**
- `claude/s19-dual-xp` (starts first)
- `claude/s20-evolution` (waits for S19)
- `claude/s21-alignment` (can start with S19)

**Workflow:**
```bash
# S19 starts first
git checkout -b claude/s19-dual-xp
# ... S19 agent implements ...
git push -u origin claude/s19-dual-xp

# Merge S19 first
git checkout main
git merge claude/s19-dual-xp
git push origin main

# NOW S20 can start (depends on S19)
git checkout -b claude/s20-evolution
# ... S20 agent implements ...

# S21 can work in parallel with S20
git checkout -b claude/s21-alignment
# ... S21 agent implements ...

# Merge S20 and S21 (any order)
git checkout main
git merge claude/s20-evolution
git merge claude/s21-alignment
git push origin main
git tag v0.8.0-wave8
```

---

## Emergency Rollback Procedures

### Using CheckpointManager (Godot Snapshots)

**Before risky merge:**
```gdscript
var manager = CheckpointManager.new()
manager.create_snapshot("before-wave4-merge")
```

**If merge causes issues:**
```gdscript
var manager = CheckpointManager.new()
manager.print_snapshots()
manager.rollback_to_snapshot("snapshot-20251118-143022")
```

### Using Git Reset

**Rollback last merge (not yet pushed):**
```bash
git reset --hard HEAD~1
```

**Rollback last merge (already pushed):**
```bash
# Create revert commit
git revert -m 1 HEAD
git push origin main
```

**Rollback to specific tag:**
```bash
git reset --hard v0.4.0-wave3
git push origin main --force  # ⚠️ DANGEROUS - coordinate with team!
```

### Integration Test After Rollback

```bash
# Always test after rollback
godot --headless --script scripts/ci_runner.gd
# Verify system is in good state
```

---

## Quick Reference

### Common Commands

```bash
# Create system branch
git checkout -b claude/s05-inventory

# Check branch status
git status

# Commit changes
git add .
git commit -m "Complete S05 Inventory system"

# Push branch
git push -u origin claude/s05-inventory

# Merge to main (developer only)
git checkout main
git pull origin main
git merge claude/s05-inventory
git push origin main

# Run pre-merge tests
godot --headless --script scripts/ci_runner.gd

# Create snapshot before merge
var manager = CheckpointManager.new()
manager.create_snapshot("before-s05-merge")

# Rollback if needed
git reset --hard HEAD~1
```

### File Isolation Quick Check

```bash
# Show what files you modified
git status

# If you see files outside src/systems/s{your-number}-{your-system}/:
# STOP - you've violated file isolation!
# Revert unauthorized changes:
git checkout main -- [unauthorized-file]
```

### Wave Merge Checklist

```markdown
## Before Merging Wave X

- [ ] All systems in wave complete (check COORDINATION-DASHBOARD.md)
- [ ] All pre-merge tests passing (run ci_runner.gd)
- [ ] All checkpoints valid (run CheckpointValidator)
- [ ] No file isolation violations (git status check)
- [ ] Snapshot created (CheckpointManager)
- [ ] Merge in wave order (not random order)
- [ ] Integration tests after merge
- [ ] Tag release (git tag vX.Y.Z-waveN)
```

---

**End of Git Workflow Guide** - Follow these rules for conflict-free parallel development! 🚀
