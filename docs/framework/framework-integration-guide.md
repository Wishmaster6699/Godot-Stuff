# Framework Integration Guide
## How to Use Framework Tools in Your System Development

**Version:** 1.0
**Date:** 2025-11-17
**Target:** System Agents (S01-S26)
**Purpose:** Practical guide for using framework tools daily

---

## 🎯 Quick Reference

**"I need to..."**

| Task | Use This Tool | See Section |
|------|---------------|-------------|
| Add integration test for my system | Integration Test Suite | [Section 1](#1-integration-test-suite) |
| Check if my code meets quality standards | Quality Gates | [Section 2](#2-quality-gates) |
| Validate my checkpoint before pushing | Checkpoint Validator | [Section 3](#3-checkpoint-validator) |
| Profile my system's performance | Performance Profiler | [Section 5](#5-performance-profiler) |
| Update my agent status | Coordination Dashboard | [Section 6](#6-coordination-dashboard) |
| Save a snapshot before refactoring | Rollback System | [Section 7](#7-rollback-system) |
| Report a bug I found | Known Issues DB | [Section 8](#8-known-issues-db) |
| Document a solution I discovered | Knowledge Base | [Section 9](#9-knowledge-base) |
| Generate placeholder assets | Asset Pipeline | [Section 10](#10-asset-pipeline) |

---

## 📋 Prerequisites

### Required Autoloads

These framework components MUST be registered as autoloads (see [Autoload Setup](#autoload-setup)):

```gdscript
# project.godot should contain:
[autoload]
IntegrationTestSuite="*res://tests/integration/integration_test_suite.gd"
PerformanceProfiler="*res://tests/performance/performance_profiler.gd"
CheckpointValidator="*res://scripts/validate_checkpoint.gd"
CheckpointManager="*res://scripts/checkpoint_manager.gd"
```

### Verify Autoloads

```gdscript
# In any script, verify autoloads are accessible:
func _ready() -> void:
    if has_node("/root/IntegrationTestSuite"):
        print("✅ Framework autoloads ready!")
    else:
        push_error("❌ Framework autoloads not configured!")
```

---

## 1. Integration Test Suite

### Purpose
Test that your system integrates correctly with other systems.

### When to Use
- After implementing core functionality
- When connecting to other systems
- Before marking system as complete
- As part of checkpoint creation

### How to Add Your Test

**Step 1: Find your test function**

```gdscript
# In tests/integration/integration_test_suite.gd
# Find your system's test function (already created as template)

# For S05 Inventory, find:
func _test_inventory_integration() -> Dictionary:
    # This is currently just a placeholder
    return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}
```

**Step 2: Replace template with real test**

```gdscript
# Replace the placeholder with actual integration tests
func _test_inventory_integration() -> Dictionary:
    # Test 1: Verify autoload exists
    if not has_node("/root/InventoryManager"):
        return {"passed": false, "error": "InventoryManager autoload not found"}

    var inventory = get_node("/root/InventoryManager")

    # Test 2: Verify integration with Conductor (S01)
    if not has_node("/root/Conductor"):
        return {"passed": false, "error": "Conductor dependency not found"}

    var conductor = get_node("/root/Conductor")

    # Test 3: Test that inventory responds to beats
    var beat_received := false
    var beat_handler := func(_beat_num: int): beat_received = true

    conductor.beat.connect(beat_handler)
    await get_tree().create_timer(1.1).timeout  # Wait for beat
    conductor.beat.disconnect(beat_handler)

    if not beat_received:
        return {"passed": false, "error": "Inventory not receiving beat signals"}

    # Test 4: Test inventory operations
    var test_item := {"id": "test_sword", "name": "Test Sword"}
    inventory.add_item(test_item)

    if not inventory.has_item("test_sword"):
        return {"passed": false, "error": "add_item() failed"}

    # All tests passed!
    return {"passed": true}
```

**Step 3: Run your test**

```gdscript
# Method 1: Run all tests
var suite = IntegrationTestSuite.new()
var results = suite.run_all_tests()
print(results.summary())

# Method 2: Run only your test
var suite = IntegrationTestSuite.new()
var result = suite.run_system_test("S05_Inventory")
print(result.summary())
```

**Step 4: Verify test passes**

```bash
# Run via CI runner
godot --headless --script scripts/ci_runner.gd

# Check output for:
# ✓ PASSED: S05_Inventory
```

### Test Pattern Template

```gdscript
func _test_<your_system>_integration() -> Dictionary:
    # 1. Verify your autoload exists
    if not has_node("/root/YourSystem"):
        return {"passed": false, "error": "System autoload missing"}

    var your_system = get_node("/root/YourSystem")

    # 2. Verify dependencies exist
    var required_systems := ["/root/Conductor", "/root/InputManager"]
    for system_path in required_systems:
        if not has_node(system_path):
            return {"passed": false, "error": "%s dependency missing" % system_path}

    # 3. Test signal connections
    # Test that your system connects to other systems

    # 4. Test data flow
    # Test that data passes correctly between systems

    # 5. Test edge cases
    # Test what happens when dependencies fail

    return {"passed": true}
```

### Common Integration Points to Test

**For systems that use Conductor (S01):**
```gdscript
# Test beat synchronization
var conductor = get_node("/root/Conductor")
var beat_count := 0
var handler := func(_beat): beat_count += 1

conductor.beat.connect(handler)
await get_tree().create_timer(2.0).timeout
conductor.beat.disconnect(handler)

if beat_count < 1:
    return {"passed": false, "error": "Not receiving beat signals"}
```

**For systems that use Input (S02):**
```gdscript
# Test input handling
var input_mgr = get_node("/root/InputManager")
if not input_mgr.has_signal("action_pressed"):
    return {"passed": false, "error": "Input manager signals missing"}
```

**For systems that save data (S06):**
```gdscript
# Test save/load integration
var save_system = get_node("/root/SaveLoadManager")
var test_data := {"test_key": "test_value"}

save_system.save_data("test", test_data)
var loaded = save_system.load_data("test")

if loaded != test_data:
    return {"passed": false, "error": "Save/load data mismatch"}
```

---

## 2. Quality Gates

### Purpose
Evaluate if your system meets the 80/100 minimum quality standard across 5 dimensions.

### When to Use
- Before creating final checkpoint
- Before marking system as complete
- During self-review

### How to Evaluate Your System

**Step 1: Read the criteria**

```bash
# View quality gates criteria
cat quality-gates.json
```

**Step 2: Score each dimension**

Create a quality evaluation in your checkpoint file:

```markdown
### Quality Gate Score

**Total:** 85/100 ✅ GOOD

#### Code Quality (18/20)
- ✅ Type Hints: 5/5 - All functions typed
- ✅ Documentation: 4/5 - Most functions documented (missing 2 helpers)
- ✅ Naming Conventions: 5/5 - Consistent snake_case
- ✅ Code Organization: 4/5 - Well organized, one file could be split

#### Godot Integration (20/20)
- ✅ Signal Usage: 5/5 - Proper signal decoupling
- ✅ Node Lifecycle: 5/5 - Correct _ready, _process usage
- ✅ Resource Management: 5/5 - No memory leaks, proper cleanup
- ✅ Godot 4.5 Syntax: 5/5 - Uses await, @export correctly

#### Rhythm Integration (17/20)
- ✅ Beat Sync: 7/8 - Core actions sync (minor drift at 180BPM)
- ✅ Timing Windows: 7/7 - Perfect/good/miss implemented
- ⚠️  Rhythm Feedback: 3/5 - Basic feedback, needs more visual polish

#### Fun/Creativity (15/20)
- ✅ Game Feel: 6/8 - Satisfying, needs screen shake
- ✅ Creative Solutions: 5/7 - Unique mechanics, could be more creative
- ✅ Polish: 4/5 - Smooth, minor edge cases remain

#### System Integration (15/20)
- ✅ Dependency Management: 4/5 - Clean deps, one circular ref
- ✅ Integration Tests: 5/5 - Full test coverage
- ⚠️  Data Flow: 3/5 - Clear flow, some unnecessary coupling
- ✅ Error Handling: 3/5 - Basic handling, needs better recovery

#### Improvements Needed for 90+:
1. Add screen shake on perfect hits
2. Add more helper function documentation
3. Fix timing drift at high BPMs
4. Improve visual feedback particles
5. Decouple item selection from UI
```

**Step 3: Address issues if below 80**

```markdown
### If Score < 80:

**Critical Improvements:**
1. [List specific fixes needed]
2. [Each fix should target a specific criterion]
3. [Re-score after fixing]

**Timeline:**
- Fix 1: [X hours]
- Fix 2: [X hours]
- Target: 80+ score before checkpoint
```

### Self-Evaluation Checklist

**Before marking system complete:**

- [ ] All functions have type hints
- [ ] All public functions have docstrings
- [ ] Code follows naming conventions
- [ ] No files > 500 lines
- [ ] Signals used for decoupling
- [ ] Proper lifecycle methods
- [ ] No memory leaks
- [ ] Uses Godot 4.5 syntax (await, @export)
- [ ] Core actions sync to beat
- [ ] Timing windows implemented (if applicable)
- [ ] Visual/audio rhythm feedback
- [ ] Satisfying game feel (juice)
- [ ] Creative implementation
- [ ] Smooth animations
- [ ] Clean dependencies
- [ ] Integration test added
- [ ] Clear data flow
- [ ] Error handling

---

## 3. Checkpoint Validator

### Purpose
Verify your checkpoint file contains all required sections before pushing.

### When to Use
- Before creating git commit
- Before marking task as complete
- During checkpoint review

### How to Validate

**Method 1: Validate single checkpoint**

```gdscript
# In Godot script console or test script
var validator = CheckpointValidator.new()
var result = validator.validate_checkpoint("checkpoints/S05-inventory-checkpoint.md")

if result.passed:
    print("✅ Checkpoint is valid!")
else:
    print("❌ Checkpoint has issues:")
    for error in result.errors:
        print("  • %s" % error)
```

**Method 2: Validate all checkpoints**

```gdscript
var validator = CheckpointValidator.new()
var results = validator.validate_all_checkpoints()

# Shows validation summary for all checkpoints
```

**Method 3: Generate validation report**

```gdscript
var validator = CheckpointValidator.new()
validator.generate_validation_report()

# Creates: CHECKPOINT-VALIDATION-REPORT.md
# Review this before pushing
```

**Method 4: Use CI runner** (Recommended)

```bash
# Validates checkpoints as part of CI
godot --headless --script scripts/ci_runner.gd

# Check exit code:
# 0 = all valid
# 1 = validation failed
```

### Required Sections Checklist

Your checkpoint MUST include:

- [ ] `Component:` [Your system name]
- [ ] `Agent:` [Your agent ID]
- [ ] `Date:` [YYYY-MM-DD]
- [ ] `Duration:` [Actual time spent]
- [ ] `### What Was Built` section
- [ ] `### Key Features` section
- [ ] `### Research Findings` section
- [ ] `### Design Decisions` section
- [ ] `### Integration with Other` section
- [ ] `### Files Created` section
- [ ] `### Git Commit` section
- [ ] `### Status` section
- [ ] Quality Gate Score (must be 80+)

### Common Validation Errors

**Error: "Missing required section: Quality Gate Score"**
```markdown
# Fix: Add quality evaluation
### Quality Gate Score

**Total:** 85/100 ✅ GOOD

[Full breakdown here]
```

**Error: "Quality gate score 75 is below minimum 80"**
```markdown
# Fix: Improve your implementation to reach 80+
# Then update the score in checkpoint
```

**Error: "Referenced file not found: systems/inventory.gd"**
```markdown
# Fix: Either create the missing file or fix the path in checkpoint
### Files Created
- `systems/inventory_manager.gd` (not systems/inventory.gd)
```

---

## 4. CI Test Runner

### Purpose
Run all framework tests automatically (used by CI/CD).

### When to Use
- Before pushing to git
- As part of CI pipeline
- To verify framework health

### How to Run

**Local execution:**

```bash
# Run all tests
godot --headless --script scripts/ci_runner.gd

# Skip integration tests
godot --headless --script scripts/ci_runner.gd -- --no-integration

# Strict mode (warnings = failures)
godot --headless --script scripts/ci_runner.gd -- --strict
```

**Check results:**

```bash
# Exit code
echo $?
# 0 = all passed
# 1 = some failed

# View report
cat test-results.json
cat CHECKPOINT-VALIDATION-REPORT.md
```

### System Agents: When to Run

**Run CI tests:**
- ✅ Before creating checkpoint
- ✅ Before pushing code
- ✅ After adding integration test
- ✅ After major refactoring

**Don't run CI tests:**
- ❌ During active development (too slow)
- ❌ After every small change (use regular testing)

---

## 5. Performance Profiler

### Purpose
Track frame times and identify performance bottlenecks.

### When to Use
- During development (continuous profiling)
- When optimizing performance
- Before marking system complete

### How to Profile Your System

**Method 1: Using ProfileHelper (Easiest)**

```gdscript
# In your system's _process() or _physics_process()
extends Node

func _process(delta: float) -> void:
    ProfileHelper.start("S05_Inventory")

    # Your system logic here
    _update_inventory_ui()
    _check_item_interactions()

    ProfileHelper.end("S05_Inventory")

func _ready() -> void:
    # Generate report after 10 seconds
    await get_tree().create_timer(10.0).timeout
    ProfileHelper.report()
    ProfileHelper.save("performance-S05.md")
```

**Method 2: Manual profiling**

```gdscript
var profiler: PerformanceProfiler

func _ready() -> void:
    profiler = PerformanceProfiler.new()
    profiler.start_profiling()

func _process(delta: float) -> void:
    var start_time = Time.get_ticks_usec()

    # Your system logic
    _update_inventory()

    var end_time = Time.get_ticks_usec()
    var duration_ms = (end_time - start_time) / 1000.0

    profiler.profile_system("S05_Inventory", duration_ms)

func _exit_tree() -> void:
    profiler.save_report("performance-S05.md")
```

**Method 3: Profile specific functions**

```gdscript
func expensive_operation() -> void:
    ProfileHelper.start("S05_Inventory_Sort")

    # Expensive sorting algorithm
    _sort_inventory_by_rarity()

    ProfileHelper.end("S05_Inventory_Sort")
```

### Understanding Performance Budgets

**Target performance:**
- **Frame time:** <16.67ms (60 FPS)
- **Per-system:** <1ms per system
- **Total systems:** 26 systems × 1ms = 26ms budget (leaves 10ms buffer)

**If your system exceeds 1ms average:**
1. Profile individual functions
2. Identify bottlenecks
3. Optimize hot paths
4. Consider caching
5. Move work to background threads

### Performance Report Example

```
╔═══════════════════════════════════════════════════════════════╗
║              PERFORMANCE PROFILER REPORT                       ║
╚═══════════════════════════════════════════════════════════════╝

📊 Overall Statistics:
  Duration: 10.00 seconds
  Total Frames: 600
  Average FPS: 60.0

🎮 Frame Time:
  Target: 16.67 ms (60 FPS)
  Average: 14.23 ms
  Max: 18.45 ms
  Min: 12.10 ms
  Status: ✅ Within budget

🔧 System Performance:
  Budget per system: 1.00 ms

  ⚠️  S05_Inventory: avg 1.45ms, max 3.21ms, samples 600
  ✅ S01_Conductor: avg 0.32ms, max 0.89ms, samples 600
  ✅ S02_Input: avg 0.15ms, max 0.42ms, samples 600
```

**Action items:**
- S05_Inventory exceeds budget (1.45ms average)
- Peak of 3.21ms is concerning
- Profile S05_Inventory functions to find bottleneck

---

## 6. Coordination Dashboard

### Purpose
Track agent status and coordinate work across parallel agents.

### When to Use
- Starting work on system
- Completing work
- Encountering blockers
- Daily status updates

### How to Update Dashboard

**Step 1: Open dashboard**

```bash
nano COORDINATION-DASHBOARD.md
# or use your preferred editor
```

**Step 2: Update your agent status**

```markdown
## 👥 Agent Status

| Agent | Current Task | Status | Progress | Est. Completion |
|-------|--------------|--------|----------|-----------------|
| S05 | Inventory System | 🟢 Active | 2/4 jobs | Day 7 |
```

**Step 3: Update component status (if applicable)**

```markdown
## 📊 System Component Status

| System | Status | Quality Score | Notes |
|--------|--------|---------------|-------|
| S05 Inventory | 🟢 In Progress | -/100 | Job 2 complete |
```

**Step 4: Add to recent activity**

```markdown
## 📝 Recent Activity

### 2025-11-20
- **S05:** Completed Job 2 (Add Item UI) - Item selection working
- **S05:** Started Job 3 (Remove Item Functionality)
```

**Step 5: Report blockers (if any)**

```markdown
## ⚠️ Issues & Risks

**Inventory Grid Sizing Issue**
- **Blocker:** Can't determine optimal grid size
- **Agent:** S05
- **Needs:** Design decision on max inventory size
```

### Status Indicators

- 🟢 **Active** - Currently working
- 🟡 **Blocked** - Waiting on dependency
- 🔵 **Review** - Awaiting review
- ⚪ **Waiting** - Not started
- ✅ **Complete** - Finished

### Update Frequency

**Update dashboard:**
- When starting new job/task
- When completing job/task
- When encountering blockers
- End of each work session

---

## 7. Rollback System

### Purpose
Save snapshots of checkpoints before major changes, rollback if needed.

### When to Use
- Before major refactoring
- Before risky changes
- Before merging branches
- Before implementing experimental features

### How to Create Snapshot

```gdscript
var manager = CheckpointManager.new()

# Create snapshot before changes
var snapshot_id = manager.create_snapshot("Before refactoring inventory sorting")

# Output: snapshot-20251120-143022
print("Snapshot created: %s" % snapshot_id)
```

**From command line:**

```gdscript
# Create scripts/snapshot.gd
extends SceneTree

func _init() -> void:
    var args = OS.get_cmdline_args()
    var description = "Manual snapshot"

    if args.size() > 0:
        description = args[0]

    var manager = CheckpointManager.new()
    var snapshot_id = manager.create_snapshot(description)

    print("Created snapshot: %s" % snapshot_id)
    quit(0)
```

```bash
# Usage
godot --script scripts/snapshot.gd -- "Before combat refactor"
```

### How to Rollback

```gdscript
var manager = CheckpointManager.new()

# List available snapshots
manager.print_snapshots()

# Output:
# 📸 Available Snapshots:
# snapshot-20251120-143022 | 2025-11-20T14:30:22 | 5 files | Before refactoring
# snapshot-20251120-100015 | 2025-11-20T10:00:15 | 4 files | Checkpoint baseline

# Rollback to specific snapshot
manager.rollback_to_snapshot("snapshot-20251120-143022")

# Output:
# ⏮️  Rolling back to snapshot: snapshot-20251120-143022
# ✅ Rollback complete: 5/5 files restored
```

### Snapshot Management

**List snapshots:**
```gdscript
var manager = CheckpointManager.new()
var snapshots = manager.list_snapshots()

for snapshot in snapshots:
    print(snapshot.summary())
```

**Delete old snapshots:**
```gdscript
var manager = CheckpointManager.new()
manager.delete_snapshot("snapshot-20251115-100000")
```

### Best Practices

**Create snapshot:**
- ✅ Before refactoring code
- ✅ Before trying experimental approach
- ✅ Before merging branches
- ✅ After completing major milestone

**Don't create snapshot:**
- ❌ After every small change (too many snapshots)
- ❌ For backup (use git instead)
- ❌ Mid-edit (finish your changes first)

---

## 8. Known Issues DB

### Purpose
Track and resolve bugs centrally.

### When to Use
- Found a bug
- Fixed a bug
- Checking if bug is known

### How to Report Bug

**Step 1: Check if already reported**

```bash
# Search known issues
grep -r "inventory crash" KNOWN-ISSUES.md
```

**Step 2: Assign issue ID**

```markdown
# Next sequential number
# If last issue was #042, use #043
```

**Step 3: Add issue using template**

```markdown
## 🟡 Medium Priority Issues (Open)

**Issue ID:** #043
**Severity:** 🟡 Medium
**Category:** System Integration
**System:** S05 Inventory
**Reported By:** S05
**Date Reported:** 2025-11-20
**Status:** Open

**Description:**
Inventory crashes when adding item while sort animation playing

**Reproduction Steps:**
1. Open inventory (I key)
2. Click "Sort by Rarity" button
3. Immediately press Q to quick-add item
4. Crash occurs

**Expected Behavior:**
Item should queue until sort finishes, then add

**Actual Behavior:**
Access violation - trying to modify array during iteration

**Impact:**
- Crashes game
- Only happens during specific timing window
- Rare but possible during gameplay

**Workaround:**
Wait for sort animation to finish before adding items

**Proposed Solution:**
Use deferred call or queue items during sort

**System Info:**
- Godot Version: 4.5.1
- Occurs at all frame rates
```

**Step 4: Update stats**

```markdown
## 🎯 Quick Stats

| Category | Open | Resolved | Total |
|----------|------|----------|-------|
| 🟡 Medium | 3 | 2 | 5 |  <!-- Increment open count -->
```

**Step 5: Commit**

```bash
git add KNOWN-ISSUES.md
git commit -m "Add issue #043: Inventory crash during sort"
```

### How to Resolve Bug

**Step 1: Fix the bug**

```gdscript
# Fix the code
func add_item(item: Dictionary) -> void:
    if _is_sorting:
        _queued_items.append(item)  # Queue instead of immediate add
        return

    _inventory.append(item)
```

**Step 2: Update issue in KNOWN-ISSUES.md**

```markdown
## ✅ Resolved Issues

**Issue ID:** #043
**Severity:** 🟡 Medium
**Category:** System Integration
**System:** S05 Inventory
**Reported By:** S05
**Date Reported:** 2025-11-20
**Date Resolved:** 2025-11-20
**Resolved By:** S05

[... previous issue details ...]

**Solution:**
Added item queue for operations during sort animation. Items are queued
and added after sort completes using call_deferred().

**Files Changed:**
- `systems/inventory_manager.gd` (add_item function)

**Commit:**
`abc123f - Resolve issue #043: Queue items during sort`
```

**Step 3: Update stats**

```markdown
| 🟡 Medium | 2 | 3 | 5 |  <!-- Decrement open, increment resolved -->
```

### Severity Guidelines

**🔴 Critical:**
- Crashes game
- Data loss
- Blocks development
- Security issues

**🟠 High:**
- Major feature broken
- Bad performance (<30 FPS)
- Gameplay breaking

**🟡 Medium:**
- Minor feature issue
- Cosmetic bugs
- Polish needed

**🟢 Low:**
- Enhancements
- Nice-to-haves
- Future improvements

---

## 9. Knowledge Base

### Purpose
Document solutions, patterns, gotchas, and integration recipes.

### When to Use
- Solved a tricky problem
- Discovered a useful pattern
- Found a common mistake
- Integrated two systems successfully

### How to Add Knowledge Entry

**Step 1: Choose category**

- `solutions/` - Specific problems you solved
- `patterns/` - Reusable design patterns
- `gotchas/` - Common mistakes
- `integration-recipes/` - System integration guides

**Step 2: Create markdown file**

```bash
cd knowledge-base/solutions
nano conductor-beat-drift-fix.md
```

**Step 3: Use appropriate template**

For a **solution:**

```markdown
# Fixing Conductor Beat Drift Over Time

**Category:** Solutions
**System(s):** S01 Conductor
**Date Added:** 2025-11-20
**Added By:** S01

## Problem

After 5+ minutes, beat timing drifts ~50ms from audio.

## Context

- Occurs at all BPMs (60-180)
- Drift accumulates linearly
- Audio stays in sync, beat signals lag

## Solution

Changed from frame-delta to absolute time:

```gdscript
# WRONG - accumulates errors
func _process(delta: float) -> void:
    time_elapsed += delta  # Float errors accumulate!
    if time_elapsed >= beat_interval:
        emit_beat()
        time_elapsed -= beat_interval

# RIGHT - absolute time
func _process(delta: float) -> void:
    var current_time = Time.get_ticks_usec() / 1000000.0
    var elapsed = current_time - start_time
    var expected_beats = floor(elapsed / beat_interval)

    if expected_beats > beat_count:
        emit_beat()
        beat_count = expected_beats
```

## Why It Works

Frame delta accumulates floating-point errors. Absolute time
eliminates cumulative errors by calculating from fixed start point.

## Alternative Approaches

- Tried periodic resync (caused hitches)
- Tried double precision (helped but didn't eliminate)

## Related Entries

- Pattern: `absolute-time-tracking-pattern.md`
- Gotcha: `floating-point-accumulation-gotcha.md`
```

**Step 4: Commit**

```bash
git add knowledge-base/solutions/conductor-beat-drift-fix.md
git commit -m "Add knowledge: Fixed conductor beat drift with absolute time"
```

### Searching Knowledge Base

**By system:**
```bash
grep -r "System: S05" knowledge-base/
```

**By keyword:**
```bash
grep -r "beat sync" knowledge-base/
grep -r "timing" knowledge-base/
```

**By date:**
```bash
grep -r "Date Added: 2025-11" knowledge-base/
```

### Integration Recipe Example

```markdown
# Integrating Inventory (S05) with Equipment (S08)

**Category:** Integration Recipes
**Systems:** S05, S08
**Date Added:** 2025-11-21
**Added By:** S08

## Goal

Allow players to equip items from inventory.

## Prerequisites

- S05 Inventory must be complete
- S08 Equipment system must have equip slots defined
- Both systems must be autoloads

## Step-by-Step Integration

### Step 1: Add equip signal to Inventory

```gdscript
# In inventory_manager.gd
signal item_equipped(item: Dictionary, slot: String)

func equip_item(item_id: String, slot: String) -> bool:
    if not has_item(item_id):
        return false

    var item = get_item(item_id)
    item_equipped.emit(item, slot)
    return true
```

### Step 2: Connect Equipment to signal

```gdscript
# In equipment_manager.gd
func _ready() -> void:
    var inventory = get_node("/root/InventoryManager")
    inventory.item_equipped.connect(_on_item_equipped)

func _on_item_equipped(item: Dictionary, slot: String) -> void:
    equip_to_slot(item, slot)
```

[... rest of recipe ...]
```

---

## 10. Asset Pipeline

### Purpose
Generate placeholder assets so development isn't blocked.

### When to Use
- At start of system development
- When you need temp art/audio
- When waiting for real assets

### How to Generate Placeholders

**Generate all placeholders:**

```bash
godot --script scripts/generate_placeholders.gd
```

**Output:**
```
🎨 PLACEHOLDER ASSET GENERATOR
════════════════════════════════════════
📁 Creating asset directories...
  ✓ Created: assets/sprites/characters/player
🎨 Generating sprite placeholders...
  ✓ Created sprite: Player Idle (32x32)
  ✓ Created sprite: Player Walk (32x32)
🎵 Generating audio placeholders...
  ✓ Created audio marker: Battle Theme 120 BPM
✅ Placeholder generation complete!
```

### Using Placeholders in Your System

```gdscript
# Load placeholder sprite
var sprite = Sprite2D.new()
sprite.texture = load("res://assets/sprites/characters/player/idle.png")

# It will be a bright blue rectangle - obviously a placeholder!
```

### Replacing Placeholders

**Step 1: Create real asset**

```bash
# Create in external tool (Aseprite, Blender, etc.)
# Follow naming convention: player-idle-front.png
```

**Step 2: Replace file**

```bash
# Keep same filename
cp player-idle-animated.png assets/sprites/characters/player/idle.png

# Godot auto-reimports, no code changes needed
```

**Step 3: Update asset registry**

```markdown
# In ASSET-PIPELINE.md

| Asset | Size | Format | Status | Notes |
|-------|------|--------|--------|-------|
| player-idle | 32x32 | PNG | ✅ Final | 4-frame animation |
```

### Asset Naming Conventions

```
# Format: [category]-[name]-[variant].[ext]

player-idle-front.png           # Player idle animation front view
enemy-slime-attack-01.png       # Enemy slime attack frame 1
sfx-hit-perfect.ogg             # Perfect hit sound effect
music-battle-theme-120bpm.ogg   # Battle music at 120 BPM
ui-button-primary.png           # Primary UI button
```

---

## 🔧 Autoload Setup

### Required Autoloads

**For framework to work, these MUST be autoloads:**

```gdscript
# Open project.godot or use Project Settings UI

[autoload]

# Framework Components (Required)
IntegrationTestSuite="*res://tests/integration/integration_test_suite.gd"
PerformanceProfiler="*res://tests/performance/performance_profiler.gd"
CheckpointValidator="*res://scripts/validate_checkpoint.gd"
CheckpointManager="*res://scripts/checkpoint_manager.gd"

# Your Game Systems (Add as you build them)
Conductor="*res://systems/conductor/conductor.gd"
InputManager="*res://systems/input/input_manager.gd"
SaveLoadManager="*res://systems/save_load/save_load_manager.gd"
# ... etc
```

### Using GDAI MCP to Register Autoloads

**If using Godot MCP tools:**

```bash
# Note: GDAI doesn't have direct autoload registration
# You need to manually edit project.godot or use Project Settings UI

# After creating your system script:
# 1. Open Godot Editor
# 2. Project → Project Settings → Autoload tab
# 3. Path: res://systems/conductor/conductor.gd
# 4. Name: Conductor
# 5. Enable: ON
# 6. Click Add
```

### Verifying Autoloads

```gdscript
# Create scripts/verify_autoloads.gd
extends SceneTree

func _init() -> void:
    print("\n🔧 Autoload Verification\n")
    print("═" * 60)

    var required_autoloads := [
        "IntegrationTestSuite",
        "PerformanceProfiler",
        "CheckpointValidator",
        "CheckpointManager"
    ]

    var all_present := true

    for autoload_name in required_autoloads:
        var path := "/root/" + autoload_name
        if has_node(path):
            print("✓ %s" % autoload_name)
        else:
            print("✗ MISSING: %s" % autoload_name)
            all_present = false

    print("═" * 60)

    if all_present:
        print("✅ All framework autoloads present!")
        quit(0)
    else:
        print("❌ Some framework autoloads missing!")
        quit(1)
```

```bash
# Run verification
godot --script scripts/verify_autoloads.gd
```

---

## 📚 Quick Command Reference

### Daily Workflow Commands

```bash
# Start your work session
1. Update COORDINATION-DASHBOARD.md status to 🟢 Active
2. Create snapshot before major changes
   godot --script scripts/snapshot.gd -- "Before refactoring"

# During development
3. Profile your system (add ProfileHelper calls)
4. Add integration test (update _test_<your_system>_integration)

# Before checkpoint
5. Validate checkpoint
   godot --script scripts/validate_checkpoint.gd checkpoints/S05-*.md
6. Run CI tests
   godot --headless --script scripts/ci_runner.gd
7. Generate performance report
   ProfileHelper.save("performance-S05.md")

# After checkpoint
8. Update COORDINATION-DASHBOARD.md status to ✅ Complete
9. Commit and push
```

### Emergency Commands

```bash
# Something broke - rollback
godot --script scripts/rollback.gd -- snapshot-20251120-143022

# Need to find a solution
grep -r "your problem" knowledge-base/

# Check if bug is known
grep -r "your bug" KNOWN-ISSUES.md

# Verify framework is working
godot --script scripts/verify_autoloads.gd
godot --headless --script scripts/ci_runner.gd
```

---

## ✅ Pre-Development Checklist

**Before starting system development, verify:**

- [ ] All plugins installed (see PLUGIN-SETUP.md)
- [ ] Framework autoloads registered
- [ ] Autoload verification passes
- [ ] CI runner works
- [ ] Can create snapshots
- [ ] Can validate checkpoints
- [ ] Can generate placeholders
- [ ] Read your system's prompt files (001-004 or similar)
- [ ] Checked dependencies in PROJECT-STATUS.md
- [ ] Updated COORDINATION-DASHBOARD.md to 🟢 Active

---

**END OF FRAMEWORK INTEGRATION GUIDE**

**You now know HOW TO USE all framework tools!** 🚀

**Next:** Read your system-specific prompts and start building!
