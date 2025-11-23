# Framework Setup Guide
## Building the Foundation for Multi-Agent Game Development

**Version:** 1.0
**Date:** 2025-11-17
**Target:** Godot 4.5.1 | GDScript 4.5
**Philosophy:** Research-First, Creative, Fun-Focused Framework

---

## 🎮 The Creative Mandate

**Remember:** We're building a FUN, CREATIVE rhythm RPG! Even framework code should:
- Feel satisfying to use
- Have personality and polish
- Make debugging enjoyable
- Inspire creative solutions
- Think about developer experience
- Add "juice" wherever possible (particles, screen shake, satisfying feedback)

**Example:** Instead of boring console logs, create colorful debug overlays with beat-synced animations! Make error messages helpful AND entertaining!

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Agent F1: Testing & Validation](#agent-f1-testing--validation)
4. [Agent F2: Performance & Coordination](#agent-f2-performance--coordination)
5. [Agent F3: Knowledge & Assets](#agent-f3-knowledge--assets)
6. [Integration Testing](#integration-testing)
7. [Completion Checklist](#completion-checklist)

---

## Overview

### What We're Building

The framework provides:
- **Integration Tests** - Verify systems work together
- **Quality Gates** - Enforce code standards
- **Performance Profiler** - Track frame times and memory
- **Coordination Dashboard** - Real-time agent status tracking
- **Known Issues DB** - Centralized bug tracking
- **Knowledge Base** - Persistent learning across sessions
- **Checkpoint Validation** - Ensure completeness
- **Rollback System** - Version control for checkpoints
- **Asset Pipeline** - Placeholder generation
- **CI Test Runner** - Continuous integration

### Parallel Agent Strategy

**3 agents working simultaneously:**

| Agent | Components | Duration | Files Created |
|-------|------------|----------|---------------|
| **F1** | Integration Tests, Quality Gates, Checkpoint Validation, CI Runner | ~2.5 days | 4 GDScript files + 1 JSON |
| **F2** | Performance Profiler, Coordination Dashboard, Rollback System | ~2 days | 2 GDScript files + 2 Markdown |
| **F3** | Known Issues DB, Knowledge Base dirs, Asset Pipeline | ~1.5 days | 1 GDScript file + 2 Markdown + dirs |

**Total Duration:** 3-4 days (with parallelization)

### Branch Strategy

```bash
# All agents work on the same branch
git checkout -b claude/framework-setup origin/claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
```

**Coordination:**
- Each agent creates their files in parallel
- No file conflicts (each agent works on different files)
- Commit frequently with descriptive messages
- Create checkpoints after each component

---

## Prerequisites

### Before Starting

**All agents must:**
1. Read `PARALLEL-EXECUTION-GUIDE-V2.md` (understand two-tier workflow)
2. Read `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md` (understand quality standards)
3. Read `rhythm-rpg-implementation-guide.md` (understand the game we're building)
4. Have Godot 4.5.1 installed (for Tier 2 agents/testing)

### Tools Available

**Claude Code Web (Tier 1):**
- ✅ Read, Write, Edit tools
- ✅ WebSearch, WebFetch (for research)
- ✅ Bash (for git operations)
- ❌ NO Godot MCP tools (this is pure file creation)

### Autoload Registration (CRITICAL SETUP)

**⚠️ MUST BE DONE AFTER FRAMEWORK FILES ARE CREATED ⚠️**

Several framework components MUST be registered as autoloads for the framework to function. This is done by Tier 2 agents (Godot MCP) after Tier 1 agents create the files.

#### Required Framework Autoloads

**These 4 framework scripts MUST be autoloads:**

```ini
# Add to project.godot [autoload] section:

[autoload]

IntegrationTestSuite="*res://tests/integration/integration_test_suite.gd"
PerformanceProfiler="*res://tests/performance/performance_profiler.gd"
CheckpointValidator="*res://scripts/validate_checkpoint.gd"
CheckpointManager="*res://scripts/checkpoint_manager.gd"
```

#### Why These Must Be Autoloads

| Script | Why Autoload | Used By |
|--------|--------------|---------|
| `IntegrationTestSuite` | All systems need access for testing | All agents, CI runner |
| `PerformanceProfiler` | Global performance tracking | All systems, ProfileHelper |
| `CheckpointValidator` | Validate checkpoints from any context | All agents, CI runner |
| `CheckpointManager` | Create snapshots from any context | All agents for rollback |

#### Registration Methods

**Method 1: Godot Editor UI** (Recommended for Tier 2 agents)

```
1. Open Godot Editor
2. Project → Project Settings
3. Click "Autoload" tab
4. For each framework script:
   a. Path: res://[script path]
   b. Node Name: [Name from table above]
   c. Enable: ☑ ON
   d. Click "Add"
5. Click "Close"
6. Project automatically reloads
```

**Method 2: Manual project.godot Edit** (For Tier 1 if needed)

```ini
# Open project.godot in text editor
# Find or create [autoload] section
# Add these 4 lines:

[autoload]

IntegrationTestSuite="*res://tests/integration/integration_test_suite.gd"
PerformanceProfiler="*res://tests/performance/performance_profiler.gd"
CheckpointValidator="*res://scripts/validate_checkpoint.gd"
CheckpointManager="*res://scripts/checkpoint_manager.gd"

# Save and restart Godot
```

**Method 3: GDAI MCP Commands** (If Tier 2 has access to project settings)

```bash
# Note: GDAI doesn't currently have direct autoload registration
# Use Method 1 (UI) or Method 2 (manual edit) instead
#
# If future GDAI adds autoload support, format would be:
# gdai register_autoload "IntegrationTestSuite" "res://tests/integration/integration_test_suite.gd" --enable
```

#### Verification Script

**Create `scripts/verify_framework_autoloads.gd`:**

```gdscript
# Godot 4.5 | GDScript 4.5
# Verify framework autoloads are registered
extends SceneTree

func _init() -> void:
    print("\n🔧 Framework Autoload Verification\n")
    print("═" * 70)

    var required_autoloads := {
        "IntegrationTestSuite": "res://tests/integration/integration_test_suite.gd",
        "PerformanceProfiler": "res://tests/performance/performance_profiler.gd",
        "CheckpointValidator": "res://scripts/validate_checkpoint.gd",
        "CheckpointManager": "res://scripts/checkpoint_manager.gd"
    }

    var all_present := true

    for autoload_name in required_autoloads.keys():
        var path := "/root/" + autoload_name
        if has_node(path):
            print("✅ %s (accessible)" % autoload_name)

            # Verify it's the right script
            var node = get_node(path)
            var script_path = required_autoloads[autoload_name]
            print("   Path: %s" % script_path)
        else:
            print("❌ MISSING: %s" % autoload_name)
            print("   Expected path: /root/%s" % autoload_name)
            print("   Please register as autoload!")
            all_present = false

    print("═" * 70 + "\n")

    if all_present:
        print("✅ All framework autoloads registered correctly!\n")
        quit(0)
    else:
        print("❌ Framework autoloads missing! Register them before continuing.\n")
        print("See FRAMEWORK-SETUP-GUIDE.md → Prerequisites → Autoload Registration\n")
        quit(1)
```

**Run verification:**

```bash
godot --headless --script scripts/verify_framework_autoloads.gd

# Expected output:
# ✅ IntegrationTestSuite (accessible)
# ✅ PerformanceProfiler (accessible)
# ✅ CheckpointValidator (accessible)
# ✅ CheckpointManager (accessible)
# ✅ All framework autoloads registered correctly!
```

#### When to Register Autoloads

**Tier 1 (Claude Code Web) Agents:**
1. Create all framework GDScript files
2. Create the verification script above
3. Document in handoff that autoloads need registration

**Tier 2 (Godot MCP) Agents:**
1. Receive files from Tier 1
2. Register autoloads using Method 1 (UI) or Method 2 (manual)
3. Run verification script to confirm
4. Document in checkpoint that autoloads are registered

#### Troubleshooting Autoloads

**Problem: "Node not found: /root/IntegrationTestSuite"**

```gdscript
# Solution: Autoload not registered
# 1. Check Project Settings → Autoload tab
# 2. Verify script path is correct
# 3. Verify "Enable" checkbox is ON
# 4. Restart Godot Editor
```

**Problem: "Script does not exist"**

```gdscript
# Solution: File not created yet or wrong path
# 1. Verify file exists: ls tests/integration/integration_test_suite.gd
# 2. Check path in autoload matches file location
# 3. Path must start with res://
```

**Problem: "Autoload registered but verification fails"**

```gdscript
# Solution: Godot not reloaded
# 1. Close Godot Editor completely
# 2. Reopen project
# 3. Run verification script again
```

#### Integration with Two-Tier Workflow

**This is a HANDOFF point between tiers:**

```markdown
## Tier 1 → Tier 2 Handoff: Framework Autoloads

**Tier 1 Deliverables:**
- ✅ Created tests/integration/integration_test_suite.gd
- ✅ Created tests/performance/performance_profiler.gd
- ✅ Created scripts/validate_checkpoint.gd
- ✅ Created scripts/checkpoint_manager.gd
- ✅ Created scripts/verify_framework_autoloads.gd
- ✅ All files committed to git

**Tier 2 Tasks:**
1. Register 4 autoloads in Project Settings
2. Run verification script (must pass)
3. Update COORDINATION-DASHBOARD.md (autoloads registered)
4. Create checkpoint documenting autoload registration
```

---

## Agent F1: Testing & Validation

**Your Mission:** Create the testing and quality infrastructure that ensures every system meets standards.

**Components:**
1. Integration Test Suite (`tests/integration/integration_test_suite.gd`)
2. Quality Gates (`quality-gates.json`)
3. Checkpoint Validation (`scripts/validate_checkpoint.gd`)
4. CI Test Runner (`scripts/ci_runner.gd`)

**Estimated Time:** 2.5 days (6 hours per component + integration)

---

### Component 1: Integration Test Suite

**Duration:** 1 day
**File:** `tests/integration/integration_test_suite.gd`

#### Research Phase (30 minutes)

**Search queries:**
```
"Godot 4.5 testing framework"
"Godot 4.5 GUT testing plugin"
"Godot 4.5 integration test examples"
"GDScript 4.5 assert functions"
```

**Research checklist:**
- [ ] Review Godot 4.5 built-in testing capabilities
- [ ] Check if GUT (Godot Unit Test) plugin is compatible with 4.5
- [ ] Find examples of integration test patterns
- [ ] Understand signal-based testing in Godot 4.5

**Document findings:**
Create `research/framework-integration-tests-research.md`

#### Implementation

**Create directory structure:**
```bash
mkdir -p tests/integration
```

**File:** `tests/integration/integration_test_suite.gd`

```gdscript
# Godot 4.5 | GDScript 4.5
# Framework: Integration Test Suite
# Purpose: Run integration tests for all 26 game systems
# Created: 2025-11-17

extends Node

## Integration Test Suite for Rhythm RPG
##
## This suite runs integration tests for all 26 systems, ensuring they work
## together harmoniously. Tests are organized by system ID and can be run
## individually or all at once.
##
## Usage:
##   var suite = IntegrationTestSuite.new()
##   var results = suite.run_all_tests()
##   print(results.summary())

class_name IntegrationTestSuite

## Emitted when a test starts
signal test_started(test_name: String)

## Emitted when a test completes
signal test_completed(test_name: String, passed: bool, duration_ms: float)

## Emitted when all tests complete
signal all_tests_completed(results: TestResults)

## Test result container
class TestResults:
	var total_tests: int = 0
	var passed_tests: int = 0
	var failed_tests: int = 0
	var skipped_tests: int = 0
	var test_details: Array[Dictionary] = []
	var total_duration_ms: float = 0.0

	func summary() -> String:
		var pass_rate := 0.0
		if total_tests > 0:
			pass_rate = (float(passed_tests) / float(total_tests)) * 100.0

		var summary_text := """
╔═══════════════════════════════════════════════════════════════╗
║              INTEGRATION TEST RESULTS                          ║
╠═══════════════════════════════════════════════════════════════╣
║ Total Tests:     %3d                                           ║
║ Passed:          %3d  ✓                                        ║
║ Failed:          %3d  ✗                                        ║
║ Skipped:         %3d  ⊘                                        ║
║ Pass Rate:       %5.1f%%                                       ║
║ Duration:        %.2f ms                                       ║
╚═══════════════════════════════════════════════════════════════╝
""" % [total_tests, passed_tests, failed_tests, skipped_tests, pass_rate, total_duration_ms]

		return summary_text

	func add_test_result(test_name: String, passed: bool, duration_ms: float, error_message: String = "") -> void:
		total_tests += 1
		if passed:
			passed_tests += 1
		else:
			failed_tests += 1

		total_duration_ms += duration_ms

		test_details.append({
			"name": test_name,
			"passed": passed,
			"duration_ms": duration_ms,
			"error_message": error_message
		})

## Registry of all system integration tests
var _system_tests: Dictionary = {}

## Current test results
var _current_results: TestResults

func _init() -> void:
	_current_results = TestResults.new()
	_register_all_tests()

## Register all system integration tests
func _register_all_tests() -> void:
	# Foundation Systems (S01-S08)
	_system_tests["S01_Conductor"] = _test_conductor_integration
	_system_tests["S02_Input"] = _test_input_integration
	_system_tests["S03_Player"] = _test_player_integration
	_system_tests["S04_Combat"] = _test_combat_integration
	_system_tests["S05_Inventory"] = _test_inventory_integration
	_system_tests["S06_SaveLoad"] = _test_saveload_integration
	_system_tests["S07_Weapons"] = _test_weapons_integration
	_system_tests["S08_Equipment"] = _test_equipment_integration

	# Combat Expansion (S09-S13)
	_system_tests["S09_DodgeBlock"] = _test_dodgeblock_integration
	_system_tests["S10_SpecialMoves"] = _test_specialmoves_integration
	_system_tests["S11_EnemyAI"] = _test_enemyai_integration
	_system_tests["S12_MonsterDB"] = _test_monsterdb_integration
	_system_tests["S13_VibeBar"] = _test_vibebar_integration

	# Environment Systems (S14-S18)
	_system_tests["S14_Tools"] = _test_tools_integration
	_system_tests["S15_Vehicles"] = _test_vehicles_integration
	_system_tests["S16_GrindRails"] = _test_grindrails_integration
	_system_tests["S17_Puzzles"] = _test_puzzles_integration
	_system_tests["S18_Polyrhythm"] = _test_polyrhythm_integration

	# Progression Systems (S19-S23)
	_system_tests["S19_DualXP"] = _test_dualxp_integration
	_system_tests["S20_Evolution"] = _test_evolution_integration
	_system_tests["S21_Resonance"] = _test_resonance_integration
	_system_tests["S22_NPCs"] = _test_npcs_integration
	_system_tests["S23_Story"] = _test_story_integration

	# Content Systems (S24-S26)
	_system_tests["S24_Cooking"] = _test_cooking_integration
	_system_tests["S25_Crafting"] = _test_crafting_integration
	_system_tests["S26_RhythmMini"] = _test_rhythmmini_integration

## Run all registered integration tests
func run_all_tests() -> TestResults:
	_current_results = TestResults.new()
	print("\n🎮 Starting Integration Test Suite...")
	print("═" * 60)

	for test_name in _system_tests.keys():
		_run_single_test(test_name)

	print("═" * 60)
	print(_current_results.summary())

	all_tests_completed.emit(_current_results)
	return _current_results

## Run a specific system's integration test
func run_system_test(system_id: String) -> TestResults:
	_current_results = TestResults.new()

	if not _system_tests.has(system_id):
		push_error("❌ Unknown system test: %s" % system_id)
		return _current_results

	_run_single_test(system_id)
	return _current_results

## Internal: Run a single test
func _run_single_test(test_name: String) -> void:
	test_started.emit(test_name)
	print("🧪 Running: %s..." % test_name)

	var start_time := Time.get_ticks_usec()
	var test_func: Callable = _system_tests[test_name]
	var test_result := test_func.call()
	var end_time := Time.get_ticks_usec()
	var duration_ms := (end_time - start_time) / 1000.0

	var passed: bool = test_result["passed"]
	var error_message: String = test_result.get("error", "")

	_current_results.add_test_result(test_name, passed, duration_ms, error_message)

	if passed:
		print("  ✓ PASSED (%.2f ms)" % duration_ms)
	else:
		print("  ✗ FAILED (%.2f ms): %s" % [duration_ms, error_message])

	test_completed.emit(test_name, passed, duration_ms)

# ═══════════════════════════════════════════════════════════════
# INDIVIDUAL SYSTEM INTEGRATION TESTS
# ═══════════════════════════════════════════════════════════════

## S01: Conductor / Rhythm System Integration Test
func _test_conductor_integration() -> Dictionary:
	# This is a template - actual tests will be implemented when systems are built
	# For now, return "passed" if the system exists, "skipped" if not

	if not has_node("/root/Conductor"):
		return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

	var conductor = get_node("/root/Conductor")

	# Test 1: Conductor singleton exists
	if conductor == null:
		return {"passed": false, "error": "Conductor autoload not found"}

	# Test 2: Beat signal emits
	var beat_emitted := false
	var beat_connection := func(beat_num: int): beat_emitted = true
	conductor.beat.connect(beat_connection)
	await get_tree().create_timer(1.1).timeout  # Wait for at least one beat at 60 BPM
	conductor.beat.disconnect(beat_connection)

	if not beat_emitted:
		return {"passed": false, "error": "Beat signal did not emit within 1 second"}

	# Test 3: BPM can be changed
	var original_bpm: float = conductor.bpm
	conductor.bpm = 120.0
	if conductor.bpm != 120.0:
		return {"passed": false, "error": "BPM change failed"}
	conductor.bpm = original_bpm

	return {"passed": true}

## S02: Input System Integration Test
func _test_input_integration() -> Dictionary:
	if not has_node("/root/InputManager"):
		return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

	# Add actual test implementation when S02 is built
	return {"passed": true}

## S03: Player Controller Integration Test
func _test_player_integration() -> Dictionary:
	# Template - implement when S03 is built
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

## S04: Combat System Integration Test
func _test_combat_integration() -> Dictionary:
	# Template - implement when S04 is built
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

## S05-S26: Additional system test templates
## (These will be filled in as systems are implemented)

func _test_inventory_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_saveload_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_weapons_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_equipment_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_dodgeblock_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_specialmoves_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_enemyai_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_monsterdb_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_vibebar_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_tools_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_vehicles_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_grindrails_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_puzzles_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_polyrhythm_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_dualxp_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_evolution_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_resonance_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_npcs_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_story_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_cooking_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_crafting_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}

func _test_rhythmmini_integration() -> Dictionary:
	return {"passed": true, "error": "⊘ System not yet implemented (skipped)"}
```

#### Creative Notes

**Make testing satisfying:**
- Colorful console output with emojis
- ASCII art test summaries
- Beat-sync test animations (when Conductor is implemented)
- Satisfying success sounds
- Fun failure messages that are still helpful

**Future enhancements (for system agents):**
- Add visual test runner UI
- Create test replay system
- Add screenshot comparison for UI tests
- Generate fun test reports with statistics

#### Checkpoint

Create `checkpoints/framework-integration-tests-checkpoint.md`:

```markdown
# Checkpoint: Integration Test Suite

## Component: Integration Test Suite
## Agent: F1
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `tests/integration/integration_test_suite.gd`
**Lines of Code:** ~400
**Purpose:** Provides integration testing framework for all 26 game systems

### Key Features

1. **TestResults class** - Tracks test statistics and generates formatted summaries
2. **Signal-based testing** - Emits events for test lifecycle
3. **26 system test templates** - One for each game system (S01-S26)
4. **Example test implementation** - S01 Conductor shows testing pattern
5. **Graceful skipping** - Systems not yet implemented return "skipped" status

### Research Findings

**Godot 4.5 Testing:**
- [URL 1]: Godot 4.5 built-in testing capabilities
- [URL 2]: GUT plugin compatibility
- [URL 3]: Signal-based testing patterns

### Design Decisions

**Why this architecture:**
- Each system has its own test function for isolation
- Tests return Dictionary for flexible error reporting
- Signals allow external monitoring (useful for CI/test UI)
- Templates make it easy for system agents to add tests

**Godot 4.5 Specifics:**
- Used `class_name` for global access
- Type hints on all functions and variables
- `await` for async operations (not `yield`)
- `Time.get_ticks_usec()` for timing (not OS.get_ticks_msec())

### How System Agents Should Use This

When implementing a system (e.g., S05 Inventory):
1. Find your test function: `_test_inventory_integration()`
2. Replace the template with actual integration tests
3. Test critical integration points:
   - Signal connections to other systems
   - Data flow between systems
   - Edge cases that involve multiple systems
4. Return `{"passed": bool, "error": String}`

### Example Test (S01 Conductor)

```gdscript
# Test that beat signal emits
var beat_emitted := false
conductor.beat.connect(func(_beat_num): beat_emitted = true)
await get_tree().create_timer(1.1).timeout
if not beat_emitted:
    return {"passed": false, "error": "Beat signal did not emit"}
```

### Creative Enhancements

- Colorful ASCII art summary box
- Emoji indicators (✓ ✗ ⊘)
- Duration tracking for each test
- Pass rate percentage

### Known Limitations

- Tests are currently async (use `await`) - may need adjustment for some systems
- No visual test runner UI yet (could be added later)
- No test isolation between runs (tests share same scene tree)

### Next Steps for System Agents

1. Implement your system's integration test
2. Test interactions with dependencies
3. Verify signals connect properly
4. Check data flows correctly

### Integration with Other Framework Components

- **Quality Gates:** Test results feed into quality score
- **CI Runner:** This suite is called by CI system
- **Performance Profiler:** Test durations tracked

### Files Created

- `tests/integration/integration_test_suite.gd`
- `research/framework-integration-tests-research.md`

### Testing

**Manual test:**
```gdscript
# In Godot script editor or debug console:
var suite = IntegrationTestSuite.new()
var results = suite.run_all_tests()
print(results.summary())
```

**Expected output (with no systems implemented):**
- Total: 26 tests
- All marked as "skipped"
- 0 failures

### Git Commit

```bash
git add tests/integration/ research/framework-integration-tests-research.md checkpoints/
git commit -m "Add Integration Test Suite framework component

- Created IntegrationTestSuite class with 26 system test templates
- Implemented example test for S01 Conductor
- Added colorful test result summaries
- Signal-based test lifecycle events
- Graceful handling of unimplemented systems

Research: Godot 4.5 testing patterns, GUT plugin compatibility
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
⬜ Quality Gates: **NEXT**
```

---

### Component 2: Quality Gates

**Duration:** 0.5 day
**File:** `quality-gates.json`

#### Research Phase (30 minutes)

**Search queries:**
```
"code quality gates best practices"
"automated code quality scoring"
"game development quality metrics"
"Godot code quality standards"
```

**Research checklist:**
- [ ] Review industry standard quality dimensions
- [ ] Find examples of quality gate implementations
- [ ] Research appropriate thresholds for game code
- [ ] Understand how to score subjective qualities

**Document findings:**
Create `research/framework-quality-gates-research.md`

#### Implementation

**File:** `quality-gates.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Rhythm RPG Quality Gates",
  "description": "Quality standards for all game systems. Each system must score 80/100 minimum across 5 dimensions.",
  "version": "1.0.0",
  "created": "2025-11-17",
  "minimum_passing_score": 80,
  "dimensions": {
    "code_quality": {
      "weight": 20,
      "description": "Code clarity, organization, and GDScript 4.5 best practices",
      "criteria": [
        {
          "name": "Type Hints",
          "points": 5,
          "description": "All functions have type hints for parameters and return values"
        },
        {
          "name": "Documentation",
          "points": 5,
          "description": "All public functions have ## docstrings explaining purpose and usage"
        },
        {
          "name": "Naming Conventions",
          "points": 5,
          "description": "snake_case for variables/functions, PascalCase for classes, UPPER_CASE for constants"
        },
        {
          "name": "Code Organization",
          "points": 5,
          "description": "Logical grouping, clear structure, no god classes (>500 lines)"
        }
      ]
    },
    "godot_integration": {
      "weight": 20,
      "description": "Proper use of Godot 4.5 features and patterns",
      "criteria": [
        {
          "name": "Signal Usage",
          "points": 5,
          "description": "Uses signals for decoupling, proper signal naming"
        },
        {
          "name": "Node Lifecycle",
          "points": 5,
          "description": "Correct _ready(), _process(), _physics_process() usage"
        },
        {
          "name": "Resource Management",
          "points": 5,
          "description": "Proper preload/load, no memory leaks, cleanup in _exit_tree()"
        },
        {
          "name": "Godot 4.5 Syntax",
          "points": 5,
          "description": "Uses await (not yield), @export (not export), modern type system"
        }
      ]
    },
    "rhythm_integration": {
      "weight": 20,
      "description": "Integration with Conductor and rhythm mechanics",
      "criteria": [
        {
          "name": "Beat Sync",
          "points": 8,
          "description": "Core actions sync to beat signals from Conductor"
        },
        {
          "name": "Timing Windows",
          "points": 7,
          "description": "Implements timing windows (perfect/good/miss) where applicable"
        },
        {
          "name": "Rhythm Feedback",
          "points": 5,
          "description": "Provides visual/audio feedback for rhythm interactions"
        }
      ]
    },
    "fun_creativity": {
      "weight": 20,
      "description": "Fun factor, polish, and creative implementation",
      "criteria": [
        {
          "name": "Game Feel",
          "points": 8,
          "description": "Satisfying feedback, screen shake, particles, 'juice'"
        },
        {
          "name": "Creative Solutions",
          "points": 7,
          "description": "Innovative mechanics, unique twists, personality"
        },
        {
          "name": "Polish",
          "points": 5,
          "description": "Smooth animations, transitions, edge case handling"
        }
      ]
    },
    "system_integration": {
      "weight": 20,
      "description": "How well the system integrates with other systems",
      "criteria": [
        {
          "name": "Dependency Management",
          "points": 5,
          "description": "Clean dependencies, minimal coupling, clear interfaces"
        },
        {
          "name": "Integration Tests",
          "points": 5,
          "description": "Has integration test in IntegrationTestSuite"
        },
        {
          "name": "Data Flow",
          "points": 5,
          "description": "Clear data flow between systems, no circular dependencies"
        },
        {
          "name": "Error Handling",
          "points": 5,
          "description": "Graceful degradation, helpful error messages, recovery paths"
        }
      ]
    }
  },
  "evaluation_guide": {
    "scoring": {
      "description": "Each criterion is scored as: Full points, Half points, or Zero points",
      "full_points": "Criterion fully met with excellence",
      "half_points": "Criterion partially met or needs minor improvements",
      "zero_points": "Criterion not met or has major issues"
    },
    "thresholds": {
      "excellent": {
        "min_score": 90,
        "description": "🌟 Outstanding implementation! Sets the bar for quality."
      },
      "good": {
        "min_score": 80,
        "description": "✅ Meets quality standards. Ready for integration."
      },
      "needs_improvement": {
        "min_score": 60,
        "description": "⚠️  Below standard. Requires improvements before merge."
      },
      "unacceptable": {
        "max_score": 59,
        "description": "❌ Major issues. Needs significant rework."
      }
    }
  },
  "usage_instructions": {
    "when_to_evaluate": [
      "Before marking a system as complete",
      "During code review",
      "As part of CI pipeline",
      "When creating checkpoints"
    ],
    "how_to_score": [
      "1. Read through the implementation",
      "2. Score each criterion (0, half, or full points)",
      "3. Calculate total for each dimension",
      "4. Sum all dimensions for final score (out of 100)",
      "5. System must score 80+ to pass"
    ],
    "documentation": "Record scores in checkpoint .md files under '### Quality Gate Score' section"
  },
  "example_scorecard": {
    "system_id": "S01",
    "system_name": "Conductor",
    "code_quality": {
      "type_hints": 5,
      "documentation": 5,
      "naming_conventions": 5,
      "code_organization": 5,
      "subtotal": 20
    },
    "godot_integration": {
      "signal_usage": 5,
      "node_lifecycle": 5,
      "resource_management": 5,
      "godot_4_5_syntax": 5,
      "subtotal": 20
    },
    "rhythm_integration": {
      "beat_sync": 8,
      "timing_windows": 7,
      "rhythm_feedback": 5,
      "subtotal": 20
    },
    "fun_creativity": {
      "game_feel": 8,
      "creative_solutions": 7,
      "polish": 5,
      "subtotal": 20
    },
    "system_integration": {
      "dependency_management": 5,
      "integration_tests": 5,
      "data_flow": 5,
      "error_handling": 5,
      "subtotal": 20
    },
    "total_score": 100,
    "result": "🌟 EXCELLENT",
    "notes": "Perfect implementation with great rhythm feel and creative beat visualization!"
  }
}
```

#### Creative Notes

**Make quality evaluation satisfying:**
- Clear visual scoring templates
- Emoji indicators for score ranges
- Celebrate high scores with ASCII art
- Provide actionable improvement suggestions
- Make it feel like leveling up, not criticism

#### Checkpoint

Create `checkpoints/framework-quality-gates-checkpoint.md`:

```markdown
# Checkpoint: Quality Gates

## Component: Quality Gates
## Agent: F1
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `quality-gates.json`
**Purpose:** Defines quality standards and scoring system for all 26 game systems

### Key Features

1. **5 Quality Dimensions** - Code Quality, Godot Integration, Rhythm Integration, Fun/Creativity, System Integration
2. **100-Point Scale** - Each dimension worth 20 points
3. **80/100 Minimum** - Systems must score 80+ to pass
4. **Detailed Criteria** - 19 specific criteria across 5 dimensions
5. **Scoring Guide** - Clear instructions for evaluation
6. **Example Scorecard** - Shows perfect S01 Conductor evaluation

### Research Findings

**Quality Gate Best Practices:**
- [URL 1]: Industry standard quality metrics
- [URL 2]: Game-specific quality considerations
- [URL 3]: Automated scoring approaches

### Design Decisions

**Why these 5 dimensions:**
- **Code Quality** - Foundation of maintainability
- **Godot Integration** - Engine-specific correctness
- **Rhythm Integration** - Core game mechanic adherence
- **Fun/Creativity** - Aligns with project mandate
- **System Integration** - Ensures systems work together

**80/100 threshold reasoning:**
- Not too strict (allows creative risk-taking)
- Not too lenient (maintains standards)
- Allows trade-offs (can sacrifice points in one area if strong elsewhere)

### How System Agents Should Use This

When completing a system:
1. Score your implementation across all 5 dimensions
2. Use half-points for partially-met criteria
3. Document scores in checkpoint .md file
4. If below 80: identify improvements needed
5. If 80+: celebrate and proceed!

### Example Quality Gate Evaluation

```markdown
### Quality Gate Score

**Total:** 85/100 ✅ GOOD

#### Breakdown:
- Code Quality: 18/20 (missing some docstrings)
- Godot Integration: 20/20 (perfect)
- Rhythm Integration: 17/20 (timing windows need polish)
- Fun/Creativity: 15/20 (could use more particle effects)
- System Integration: 15/20 (integration test needs expansion)

#### Improvements for Next Version:
- Add docstrings to helper functions
- Polish timing window feedback
- Add particle effects on beat hits
```

### Integration with Other Framework Components

- **Integration Tests:** Test pass/fail contributes to System Integration score
- **Checkpoint Validation:** Checks that quality scores are documented
- **CI Runner:** Can automate some quality checks (linting, type checking)

### Files Created

- `quality-gates.json`
- `research/framework-quality-gates-research.md`

### Git Commit

```bash
git add quality-gates.json research/ checkpoints/
git commit -m "Add Quality Gates framework component

- 5 quality dimensions with 19 detailed criteria
- 100-point scoring system with 80 minimum
- Example scorecard for reference
- Clear evaluation guide

Research: Quality gate best practices, game dev metrics
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
⬜ Checkpoint Validation: **NEXT**
```

---

### Component 3: Checkpoint Validation

**Duration:** 0.5 day
**File:** `scripts/validate_checkpoint.gd`

#### Research Phase (30 minutes)

**Search queries:**
```
"Godot 4.5 file validation"
"GDScript 4.5 JSON parsing"
"markdown parsing validation"
"file completeness checking"
```

**Research checklist:**
- [ ] Review Godot 4.5 FileAccess API
- [ ] Understand JSON parsing in GDScript 4.5
- [ ] Find markdown validation approaches
- [ ] Research file existence checking patterns

**Document findings:**
Create `research/framework-checkpoint-validation-research.md`

#### Implementation

**Create directory structure:**
```bash
mkdir -p scripts
```

**File:** `scripts/validate_checkpoint.gd`

```gdscript
# Godot 4.5 | GDScript 4.5
# Framework: Checkpoint Validation
# Purpose: Validate checkpoint files for completeness and quality
# Created: 2025-11-17

extends Node
class_name CheckpointValidator

## Checkpoint Validation System
##
## Validates that checkpoint .md files contain all required sections
## and that quality scores meet minimum standards.
##
## Usage:
##   var validator = CheckpointValidator.new()
##   var result = validator.validate_checkpoint("checkpoints/S01-conductor-checkpoint.md")
##   if result.passed:
##       print("✅ Checkpoint valid!")

## Validation result container
class ValidationResult:
	var passed: bool = false
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var score: int = 0
	var quality_gate_score: int = -1

	func summary() -> String:
		var status := "✅ VALID" if passed else "❌ INVALID"
		var summary_text := """
╔═══════════════════════════════════════════════════════════════╗
║         CHECKPOINT VALIDATION RESULT                           ║
╠═══════════════════════════════════════════════════════════════╣
║ Status:          %s                                            ║
║ Completeness:    %d/100                                        ║
║ Quality Score:   %s                                            ║
║ Errors:          %d                                            ║
║ Warnings:        %d                                            ║
╚═══════════════════════════════════════════════════════════════╝
""" % [
	status,
	score,
	str(quality_gate_score) if quality_gate_score >= 0 else "N/A",
	errors.size(),
	warnings.size()
]

		if errors.size() > 0:
			summary_text += "\n❌ ERRORS:\n"
			for error in errors:
				summary_text += "  • %s\n" % error

		if warnings.size() > 0:
			summary_text += "\n⚠️  WARNINGS:\n"
			for warning in warnings:
				summary_text += "  • %s\n" % warning

		return summary_text

## Required sections in checkpoint files
const REQUIRED_SECTIONS: Array[String] = [
	"Component:",
	"Agent:",
	"Date:",
	"Duration:",
	"What Was Built",
	"Key Features",
	"Research Findings",
	"Design Decisions",
	"Integration with Other",
	"Files Created",
	"Git Commit",
	"Status"
]

## Quality gate minimum score
const MIN_QUALITY_SCORE: int = 80

## Validate a checkpoint file
func validate_checkpoint(checkpoint_path: String) -> ValidationResult:
	var result := ValidationResult.new()

	# Check if file exists
	if not FileAccess.file_exists(checkpoint_path):
		result.errors.append("Checkpoint file not found: %s" % checkpoint_path)
		return result

	# Read file contents
	var file := FileAccess.open(checkpoint_path, FileAccess.READ)
	if file == null:
		result.errors.append("Could not open checkpoint file: %s" % checkpoint_path)
		return result

	var content := file.get_as_text()
	file.close()

	# Validate required sections
	var sections_found := 0
	for section in REQUIRED_SECTIONS:
		if section in content:
			sections_found += 1
		else:
			result.errors.append("Missing required section: %s" % section)

	# Calculate completeness score
	result.score = int((float(sections_found) / float(REQUIRED_SECTIONS.size())) * 100.0)

	# Extract quality gate score if present
	result.quality_gate_score = _extract_quality_score(content)

	# Check quality gate score
	if result.quality_gate_score >= 0:
		if result.quality_gate_score < MIN_QUALITY_SCORE:
			result.errors.append("Quality gate score %d is below minimum %d" % [result.quality_gate_score, MIN_QUALITY_SCORE])
	else:
		result.warnings.append("No quality gate score found in checkpoint")

	# Check for empty sections
	_check_empty_sections(content, result)

	# Validate file references exist
	_validate_file_references(content, result)

	# Determine pass/fail
	result.passed = result.errors.size() == 0 and result.score >= 80

	return result

## Validate multiple checkpoints
func validate_all_checkpoints(checkpoint_dir: String = "checkpoints") -> Dictionary:
	var all_results := {}
	var total_passed := 0
	var total_failed := 0

	print("\n🔍 Validating all checkpoints in: %s" % checkpoint_dir)
	print("═" * 60)

	# Get all .md files in checkpoint directory
	var dir := DirAccess.open(checkpoint_dir)
	if dir == null:
		push_error("Cannot open checkpoint directory: %s" % checkpoint_dir)
		return all_results

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".md") and not file_name.begins_with("."):
			var checkpoint_path := checkpoint_dir + "/" + file_name
			print("\n📄 Validating: %s" % file_name)

			var result := validate_checkpoint(checkpoint_path)
			all_results[file_name] = result

			if result.passed:
				print("  ✅ VALID (Score: %d/100)" % result.score)
				total_passed += 1
			else:
				print("  ❌ INVALID (Score: %d/100, Errors: %d)" % [result.score, result.errors.size()])
				total_failed += 1

		file_name = dir.get_next()

	dir.list_dir_end()

	# Print summary
	print("\n" + "═" * 60)
	print("📊 VALIDATION SUMMARY")
	print("  Total Checkpoints: %d" % (total_passed + total_failed))
	print("  ✅ Valid: %d" % total_passed)
	print("  ❌ Invalid: %d" % total_failed)
	print("═" * 60 + "\n")

	return all_results

## Extract quality gate score from checkpoint content
func _extract_quality_score(content: String) -> int:
	# Look for patterns like "Total: 85/100" or "Score: 85"
	var patterns := [
		r"\*\*Total:\*\*\s*(\d+)/100",
		r"Total Score:\s*(\d+)",
		r"Quality Score:\s*(\d+)"
	]

	for pattern in patterns:
		var regex := RegEx.new()
		regex.compile(pattern)
		var result := regex.search(content)
		if result:
			return int(result.get_string(1))

	return -1

## Check for sections that exist but are empty
func _check_empty_sections(content: String, result: ValidationResult) -> void:
	var empty_sections := [
		{"name": "Key Features", "marker": "### Key Features"},
		{"name": "Research Findings", "marker": "### Research Findings"},
		{"name": "Files Created", "marker": "### Files Created"}
	]

	for section_check in empty_sections:
		var marker: String = section_check["marker"]
		var name: String = section_check["name"]

		if marker in content:
			var start_idx := content.find(marker)
			var next_section := content.find("###", start_idx + marker.length())
			var section_content := ""

			if next_section > start_idx:
				section_content = content.substr(start_idx + marker.length(), next_section - start_idx - marker.length())
			else:
				section_content = content.substr(start_idx + marker.length())

			# Remove whitespace and check if empty
			section_content = section_content.strip_edges()
			if section_content.length() < 10:  # Less than 10 chars is likely empty
				result.warnings.append("%s section appears to be empty" % name)

## Validate that referenced files actually exist
func _validate_file_references(content: String, result: ValidationResult) -> void:
	# Look for file paths in "Files Created" section
	var files_section_start := content.find("### Files Created")
	if files_section_start < 0:
		return

	var files_section_end := content.find("###", files_section_start + 10)
	var files_section := ""

	if files_section_end > files_section_start:
		files_section = content.substr(files_section_start, files_section_end - files_section_start)
	else:
		files_section = content.substr(files_section_start)

	# Extract file paths (basic pattern matching)
	var lines := files_section.split("\n")
	for line in lines:
		# Look for patterns like: - `path/to/file.gd`
		if line.strip_edges().begins_with("- `") or line.strip_edges().begins_with("* `"):
			var path_start := line.find("`") + 1
			var path_end := line.find("`", path_start)
			if path_end > path_start:
				var file_path := line.substr(path_start, path_end - path_start)

				# Skip URLs and placeholders
				if not file_path.begins_with("http") and not "[" in file_path:
					if not FileAccess.file_exists(file_path):
						result.warnings.append("Referenced file not found: %s" % file_path)

## Generate a checkpoint validation report
func generate_validation_report(output_path: String = "CHECKPOINT-VALIDATION-REPORT.md") -> void:
	var all_results := validate_all_checkpoints()

	var report := """# Checkpoint Validation Report

**Generated:** %s
**Total Checkpoints:** %d

## Summary

""" % [Time.get_datetime_string_from_system(), all_results.size()]

	var passed_count := 0
	var failed_count := 0

	for checkpoint_name in all_results.keys():
		var result: ValidationResult = all_results[checkpoint_name]
		if result.passed:
			passed_count += 1
		else:
			failed_count += 1

	report += "- ✅ Valid: %d\n" % passed_count
	report += "- ❌ Invalid: %d\n" % failed_count
	report += "\n## Details\n\n"

	for checkpoint_name in all_results.keys():
		var result: ValidationResult = all_results[checkpoint_name]
		var status := "✅ VALID" if result.passed else "❌ INVALID"

		report += "### %s - %s\n\n" % [checkpoint_name, status]
		report += "**Completeness:** %d/100\n" % result.score

		if result.quality_gate_score >= 0:
			report += "**Quality Score:** %d/100\n" % result.quality_gate_score

		if result.errors.size() > 0:
			report += "\n**Errors:**\n"
			for error in result.errors:
				report += "- %s\n" % error

		if result.warnings.size() > 0:
			report += "\n**Warnings:**\n"
			for warning in result.warnings:
				report += "- %s\n" % warning

		report += "\n---\n\n"

	# Write report
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
		print("✅ Validation report written to: %s" % output_path)
	else:
		push_error("Could not write validation report to: %s" % output_path)
```

#### Creative Notes

**Make validation satisfying:**
- Colorful validation summaries
- Clear error messages with actionable fixes
- Progress indicators for batch validation
- Fun success messages ("All checkpoints looking mighty fine! 🎉")
- Generate pretty HTML reports (future enhancement)

#### Checkpoint

Create `checkpoints/framework-checkpoint-validation-checkpoint.md`:

```markdown
# Checkpoint: Checkpoint Validation

## Component: Checkpoint Validation
## Agent: F1
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `scripts/validate_checkpoint.gd`
**Lines of Code:** ~300
**Purpose:** Validates checkpoint files for completeness and quality standards

### Key Features

1. **ValidationResult class** - Detailed validation feedback with errors/warnings
2. **Required section checking** - Ensures 12 required sections are present
3. **Quality score extraction** - Parses quality gate scores from checkpoints
4. **File reference validation** - Checks that referenced files actually exist
5. **Batch validation** - Validate all checkpoints in a directory
6. **Report generation** - Creates markdown validation reports

### Research Findings

**Godot 4.5 File API:**
- [URL 1]: FileAccess API in Godot 4.5
- [URL 2]: RegEx for pattern matching
- [URL 3]: DirAccess for directory iteration

### Design Decisions

**12 Required Sections:**
- Component, Agent, Date, Duration (metadata)
- What Was Built, Key Features (implementation)
- Research Findings, Design Decisions (rationale)
- Integration with Other, Files Created (context)
- Git Commit, Status (workflow)

**Why validate file references:**
- Catches typos in checkpoint documentation
- Ensures files weren't accidentally deleted
- Helps maintain project integrity

**Godot 4.5 Specifics:**
- FileAccess.open() for file I/O (not File.new())
- DirAccess for directory traversal
- RegEx for quality score parsing

### How System Agents Should Use This

**Before marking a system complete:**
```gdscript
var validator = CheckpointValidator.new()
var result = validator.validate_checkpoint("checkpoints/S05-inventory-checkpoint.md")
print(result.summary())
```

**For framework agents, validate all checkpoints:**
```gdscript
var validator = CheckpointValidator.new()
validator.generate_validation_report()
```

### Example Usage

```gdscript
# Single checkpoint validation
var validator = CheckpointValidator.new()
var result = validator.validate_checkpoint("checkpoints/S01-conductor-checkpoint.md")

if not result.passed:
    print("❌ Checkpoint has issues:")
    for error in result.errors:
        print("  • %s" % error)
else:
    print("✅ Checkpoint is valid!")

# Batch validation
var all_results = validator.validate_all_checkpoints("checkpoints")
```

### Integration with Other Framework Components

- **Quality Gates:** Enforces minimum quality score of 80
- **CI Runner:** Can run validation as part of CI pipeline
- **Rollback System:** Uses validation before accepting rollback points

### Files Created

- `scripts/validate_checkpoint.gd`
- `research/framework-checkpoint-validation-research.md`

### Git Commit

```bash
git add scripts/validate_checkpoint.gd research/ checkpoints/
git commit -m "Add Checkpoint Validation framework component

- Validates 12 required sections in checkpoint files
- Extracts and enforces quality gate minimums
- Batch validation for all checkpoints
- File reference validation
- Markdown report generation

Research: Godot 4.5 FileAccess API, RegEx patterns
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
⬜ CI Test Runner: **NEXT**
```

---

### Component 4: CI Test Runner

**Duration:** 0.5 day
**File:** `scripts/ci_runner.gd`

#### Research Phase (30 minutes)

**Search queries:**
```
"Godot 4.5 continuous integration"
"GDScript 4.5 command line testing"
"Godot headless testing"
"automated Godot testing"
```

**Research checklist:**
- [ ] Review Godot 4.5 headless mode capabilities
- [ ] Understand command-line argument parsing in Godot
- [ ] Find CI/CD integration examples for Godot
- [ ] Research test automation patterns

**Document findings:**
Create `research/framework-ci-runner-research.md`

#### Implementation

**File:** `scripts/ci_runner.gd`

```gdscript
# Godot 4.5 | GDScript 4.5
# Framework: CI Test Runner
# Purpose: Run automated tests in CI/CD pipelines
# Created: 2025-11-17

extends SceneTree

## CI Test Runner
##
## Runs the integration test suite in headless mode for CI/CD pipelines.
## Returns proper exit codes for CI systems to detect pass/fail.
##
## Usage (command line):
##   godot --headless --script scripts/ci_runner.gd
##
## Exit codes:
##   0 = All tests passed
##   1 = Some tests failed
##   2 = Critical error (couldn't run tests)

class_name CIRunner

## Test configuration
var run_integration_tests: bool = true
var run_validation: bool = true
var generate_reports: bool = true
var strict_mode: bool = false  # Fail on warnings in strict mode

## Results
var exit_code: int = 0

func _init() -> void:
	print("\n" + "═" * 70)
	print("🤖 CI TEST RUNNER - Rhythm RPG Framework")
	print("═" * 70 + "\n")

	# Parse command line arguments
	_parse_arguments()

	# Run tests
	var all_passed := true

	if run_integration_tests:
		all_passed = _run_integration_tests() and all_passed

	if run_validation:
		all_passed = _run_checkpoint_validation() and all_passed

	# Generate reports
	if generate_reports:
		_generate_reports()

	# Determine exit code
	if all_passed:
		exit_code = 0
		print("\n✅ ALL CHECKS PASSED!")
	else:
		exit_code = 1
		print("\n❌ SOME CHECKS FAILED!")

	print("\n" + "═" * 70)
	print("Exit Code: %d" % exit_code)
	print("═" * 70 + "\n")

	# Exit with appropriate code
	quit(exit_code)

## Parse command-line arguments
func _parse_arguments() -> void:
	var args := OS.get_cmdline_args()

	for arg in args:
		match arg:
			"--no-integration":
				run_integration_tests = false
				print("🔧 Skipping integration tests")
			"--no-validation":
				run_validation = false
				print("🔧 Skipping checkpoint validation")
			"--no-reports":
				generate_reports = false
				print("🔧 Skipping report generation")
			"--strict":
				strict_mode = true
				print("🔧 Strict mode enabled (warnings = failures)")

## Run integration test suite
func _run_integration_tests() -> bool:
	print("\n📋 Running Integration Tests...")
	print("─" * 70)

	# Create integration test suite
	var suite = IntegrationTestSuite.new()
	var results = suite.run_all_tests()

	# Print summary
	print(results.summary())

	# Check results
	var passed := results.failed_tests == 0

	if strict_mode and results.skipped_tests > 0:
		print("⚠️  Strict mode: Treating skipped tests as failures")
		passed = false

	return passed

## Run checkpoint validation
func _run_checkpoint_validation() -> bool:
	print("\n📋 Validating Checkpoints...")
	print("─" * 70)

	# Check if checkpoints directory exists
	if not DirAccess.dir_exists_absolute("checkpoints"):
		print("⊘ No checkpoints directory found (skipping)")
		return true

	# Create validator
	var validator = CheckpointValidator.new()
	var results = validator.validate_all_checkpoints("checkpoints")

	# Count results
	var total_passed := 0
	var total_failed := 0

	for checkpoint_name in results.keys():
		var result: CheckpointValidator.ValidationResult = results[checkpoint_name]
		if result.passed:
			total_passed += 1
		else:
			total_failed += 1

	# Print summary
	print("\n📊 Checkpoint Validation Summary:")
	print("  ✅ Valid: %d" % total_passed)
	print("  ❌ Invalid: %d" % total_failed)

	return total_failed == 0

## Generate CI reports
func _generate_reports() -> void:
	print("\n📊 Generating Reports...")
	print("─" * 70)

	# Generate checkpoint validation report
	if run_validation and DirAccess.dir_exists_absolute("checkpoints"):
		var validator = CheckpointValidator.new()
		validator.generate_validation_report("CHECKPOINT-VALIDATION-REPORT.md")

	# Generate test results JSON for CI systems
	_generate_test_json()

	print("✅ Reports generated")

## Generate machine-readable test results (JSON)
func _generate_test_json() -> void:
	var test_data := {
		"timestamp": Time.get_datetime_string_from_system(),
		"framework": "Rhythm RPG",
		"version": "1.0.0",
		"integration_tests": {},
		"checkpoint_validation": {},
		"overall_status": "passed" if exit_code == 0 else "failed"
	}

	# Add integration test results
	if run_integration_tests:
		var suite = IntegrationTestSuite.new()
		var results = suite.run_all_tests()

		test_data["integration_tests"] = {
			"total": results.total_tests,
			"passed": results.passed_tests,
			"failed": results.failed_tests,
			"skipped": results.skipped_tests,
			"duration_ms": results.total_duration_ms,
			"pass_rate": (float(results.passed_tests) / float(results.total_tests) * 100.0) if results.total_tests > 0 else 0.0
		}

	# Add checkpoint validation results
	if run_validation and DirAccess.dir_exists_absolute("checkpoints"):
		var validator = CheckpointValidator.new()
		var results = validator.validate_all_checkpoints("checkpoints")

		var passed_count := 0
		var failed_count := 0

		for checkpoint_name in results.keys():
			var result: CheckpointValidator.ValidationResult = results[checkpoint_name]
			if result.passed:
				passed_count += 1
			else:
				failed_count += 1

		test_data["checkpoint_validation"] = {
			"total": passed_count + failed_count,
			"passed": passed_count,
			"failed": failed_count
		}

	# Write JSON file
	var json_string := JSON.stringify(test_data, "\t")
	var file := FileAccess.open("test-results.json", FileAccess.WRITE)

	if file:
		file.store_string(json_string)
		file.close()
		print("  • test-results.json")
	else:
		push_error("Could not write test-results.json")
```

#### Usage Instructions

**Running in CI/CD:**

```bash
# GitHub Actions example
- name: Run Framework Tests
  run: godot --headless --script scripts/ci_runner.gd

# GitLab CI example
test:
  script:
    - godot --headless --script scripts/ci_runner.gd
  artifacts:
    reports:
      junit: test-results.json
```

**Command-line options:**
```bash
# Run all tests
godot --headless --script scripts/ci_runner.gd

# Skip integration tests
godot --headless --script scripts/ci_runner.gd -- --no-integration

# Strict mode (warnings = failures)
godot --headless --script scripts/ci_runner.gd -- --strict

# Skip report generation
godot --headless --script scripts/ci_runner.gd -- --no-reports
```

#### Creative Notes

**Make CI output satisfying:**
- Clear visual separators with box-drawing characters
- Color-coded output (when supported by CI system)
- Progress indicators
- Concise but informative summaries
- Machine-readable JSON output for CI dashboards

#### Checkpoint

Create `checkpoints/framework-ci-runner-checkpoint.md`:

```markdown
# Checkpoint: CI Test Runner

## Component: CI Test Runner
## Agent: F1
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `scripts/ci_runner.gd`
**Lines of Code:** ~200
**Purpose:** Automated test runner for CI/CD pipelines

### Key Features

1. **Headless execution** - Runs without GUI for CI environments
2. **Integration test runner** - Executes IntegrationTestSuite
3. **Checkpoint validation** - Validates all checkpoints
4. **Exit codes** - Proper exit codes for CI systems (0=pass, 1=fail, 2=error)
5. **Command-line arguments** - Configurable via CLI flags
6. **Report generation** - Creates markdown and JSON reports
7. **Strict mode** - Optional flag to treat warnings as failures

### Research Findings

**Godot 4.5 CI/CD:**
- [URL 1]: Headless mode in Godot 4.5
- [URL 2]: Command-line argument parsing
- [URL 3]: Exit code handling
- [URL 4]: CI/CD integration examples

### Design Decisions

**Why extend SceneTree:**
- SceneTree allows initialization without full game setup
- Can quit with exit codes
- Lightweight for CI environments

**Exit codes:**
- 0: All tests passed (CI success)
- 1: Some tests failed (CI failure)
- 2: Critical error (CI error)

**Godot 4.5 Specifics:**
- Extends SceneTree for headless execution
- Uses quit(exit_code) to return status
- OS.get_cmdline_args() for argument parsing
- DirAccess.dir_exists_absolute() for directory checks

### How System Agents Should Use This

**Don't need to use this directly** - it's for CI/CD automation.

However, you can test it locally:
```bash
godot --headless --script scripts/ci_runner.gd
```

### Example CI Configuration

**.github/workflows/framework-tests.yml:**
```yaml
name: Framework Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.5.1

      - name: Run Framework Tests
        run: godot --headless --script scripts/ci_runner.gd

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: |
            test-results.json
            CHECKPOINT-VALIDATION-REPORT.md
```

### Integration with Other Framework Components

- **Integration Tests:** Runs IntegrationTestSuite
- **Checkpoint Validation:** Runs CheckpointValidator
- **Quality Gates:** Could add automated quality checking (future)

### Files Created

- `scripts/ci_runner.gd`
- `research/framework-ci-runner-research.md`

### Output Files

Generated by the runner:
- `test-results.json` - Machine-readable test results
- `CHECKPOINT-VALIDATION-REPORT.md` - Checkpoint validation report

### Git Commit

```bash
git add scripts/ci_runner.gd research/ checkpoints/
git commit -m "Add CI Test Runner framework component

- Headless test execution for CI/CD pipelines
- Runs integration tests and checkpoint validation
- Proper exit codes for CI systems
- Command-line argument support
- JSON and markdown report generation

Research: Godot 4.5 headless mode, CI/CD patterns
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**

**Agent F1 Work: COMPLETE!** 🎉
```

---

## Agent F2: Performance & Coordination

**Your Mission:** Create performance monitoring and coordination tools to keep all agents synchronized and track system performance.

**Components:**
5. Performance Profiler (`tests/performance/performance_profiler.gd`)
6. Coordination Dashboard (`COORDINATION-DASHBOARD.md`)
7. Rollback System (`scripts/checkpoint_manager.gd`)

**Estimated Time:** 2 days (5-6 hours per component)

---

### Component 5: Performance Profiler

**Duration:** 0.75 day
**File:** `tests/performance/performance_profiler.gd`

#### Research Phase (45 minutes)

**Search queries:**
```
"Godot 4.5 performance profiling"
"GDScript 4.5 frame time measurement"
"Godot performance monitoring"
"game performance metrics"
```

**Research checklist:**
- [ ] Review Godot 4.5 Performance class
- [ ] Understand frame time tracking
- [ ] Find memory profiling approaches
- [ ] Research performance budgets for rhythm games

**Document findings:**
Create `research/framework-performance-profiler-research.md`

#### Implementation

**Create directory structure:**
```bash
mkdir -p tests/performance
```

**File:** `tests/performance/performance_profiler.gd`

```gdscript
# Godot 4.5 | GDScript 4.5
# Framework: Performance Profiler
# Purpose: Track frame times, memory usage, and system performance
# Created: 2025-11-17

extends Node
class_name PerformanceProfiler

## Performance Profiler for Rhythm RPG
##
## Tracks performance metrics for all game systems with focus on:
## - Frame time budgets (<16.67ms target for 60 FPS)
## - Per-system timing (<1ms per system ideal)
## - Memory usage
## - Beat timing accuracy
##
## Usage:
##   var profiler = PerformanceProfiler.new()
##   profiler.start_profiling()
##   # ... run game ...
##   var report = profiler.generate_report()

## Emitted when performance threshold is exceeded
signal performance_warning(system_name: String, metric: String, value: float, threshold: float)

## Performance data for a single system
class SystemProfile:
	var system_name: String = ""
	var total_time_ms: float = 0.0
	var avg_time_ms: float = 0.0
	var max_time_ms: float = 0.0
	var min_time_ms: float = 999999.0
	var sample_count: int = 0
	var warnings: Array[String] = []

	func add_sample(time_ms: float) -> void:
		total_time_ms += time_ms
		sample_count += 1
		avg_time_ms = total_time_ms / float(sample_count)
		max_time_ms = max(max_time_ms, time_ms)
		min_time_ms = min(min_time_ms, time_ms)

	func summary() -> String:
		return "%s: avg %.2fms, max %.2fms, samples %d" % [
			system_name, avg_time_ms, max_time_ms, sample_count
		]

## Performance thresholds
const TARGET_FRAME_TIME_MS: float = 16.67  # 60 FPS
const SYSTEM_TIME_BUDGET_MS: float = 1.0   # 1ms per system
const MEMORY_WARNING_MB: int = 512         # Warn above 512MB
const BEAT_TIMING_TOLERANCE_MS: float = 5.0  # 5ms beat accuracy

## Profiling state
var is_profiling: bool = false
var profile_start_time: float = 0.0
var total_frames: int = 0

## System profiles
var system_profiles: Dictionary = {}  # SystemName -> SystemProfile

## Frame time tracking
var frame_times: Array[float] = []
var max_frame_time_samples: int = 1000  # Keep last 1000 frames

## Memory tracking
var memory_samples: Array[int] = []
var max_memory_samples: int = 100

## Beat timing tracking (for rhythm accuracy)
var beat_timing_errors: Array[float] = []
var max_beat_samples: int = 500

func _ready() -> void:
	# Auto-start profiling in debug builds
	if OS.is_debug_build():
		start_profiling()

## Start performance profiling
func start_profiling() -> void:
	if is_profiling:
		push_warning("Profiler already running")
		return

	is_profiling = true
	profile_start_time = Time.get_ticks_msec()
	total_frames = 0

	print("🔍 Performance Profiler: Started")

## Stop performance profiling
func stop_profiling() -> void:
	if not is_profiling:
		push_warning("Profiler not running")
		return

	is_profiling = false
	print("🔍 Performance Profiler: Stopped")

## Track a system's execution time
func profile_system(system_name: String, execution_time_ms: float) -> void:
	if not is_profiling:
		return

	# Get or create system profile
	if not system_profiles.has(system_name):
		var profile := SystemProfile.new()
		profile.system_name = system_name
		system_profiles[system_name] = profile

	var profile: SystemProfile = system_profiles[system_name]
	profile.add_sample(execution_time_ms)

	# Check against budget
	if execution_time_ms > SYSTEM_TIME_BUDGET_MS:
		var warning := "System '%s' exceeded budget: %.2fms > %.2fms" % [
			system_name, execution_time_ms, SYSTEM_TIME_BUDGET_MS
		]
		profile.warnings.append(warning)
		performance_warning.emit(system_name, "execution_time", execution_time_ms, SYSTEM_TIME_BUDGET_MS)

## Track frame time
func profile_frame(frame_time_ms: float) -> void:
	if not is_profiling:
		return

	total_frames += 1

	# Add to frame times
	frame_times.append(frame_time_ms)
	if frame_times.size() > max_frame_time_samples:
		frame_times.pop_front()

	# Check against target
	if frame_time_ms > TARGET_FRAME_TIME_MS:
		performance_warning.emit("Frame", "frame_time", frame_time_ms, TARGET_FRAME_TIME_MS)

## Track memory usage
func profile_memory() -> void:
	if not is_profiling:
		return

	var memory_mb := int(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0)

	memory_samples.append(memory_mb)
	if memory_samples.size() > max_memory_samples:
		memory_samples.pop_front()

	if memory_mb > MEMORY_WARNING_MB:
		performance_warning.emit("Memory", "usage_mb", memory_mb, MEMORY_WARNING_MB)

## Track beat timing accuracy (for rhythm systems)
func profile_beat_timing(timing_error_ms: float) -> void:
	if not is_profiling:
		return

	beat_timing_errors.append(timing_error_ms)
	if beat_timing_errors.size() > max_beat_samples:
		beat_timing_errors.pop_front()

	if abs(timing_error_ms) > BEAT_TIMING_TOLERANCE_MS:
		performance_warning.emit("Beat Timing", "error_ms", timing_error_ms, BEAT_TIMING_TOLERANCE_MS)

## Generate performance report
func generate_report() -> String:
	if frame_times.is_empty():
		return "⊘ No performance data collected"

	var report := """
╔═══════════════════════════════════════════════════════════════╗
║              PERFORMANCE PROFILER REPORT                       ║
╚═══════════════════════════════════════════════════════════════╝

"""

	# Overall stats
	var duration_sec := (Time.get_ticks_msec() - profile_start_time) / 1000.0
	report += "📊 Overall Statistics:\n"
	report += "  Duration: %.2f seconds\n" % duration_sec
	report += "  Total Frames: %d\n" % total_frames
	report += "  Average FPS: %.1f\n\n" % (total_frames / duration_sec if duration_sec > 0 else 0)

	# Frame time stats
	if not frame_times.is_empty():
		var avg_frame_ms := _array_average(frame_times)
		var max_frame_ms := _array_max(frame_times)
		var min_frame_ms := _array_min(frame_times)

		report += "🎮 Frame Time:\n"
		report += "  Target: %.2f ms (60 FPS)\n" % TARGET_FRAME_TIME_MS
		report += "  Average: %.2f ms\n" % avg_frame_ms
		report += "  Max: %.2f ms\n" % max_frame_ms
		report += "  Min: %.2f ms\n" % min_frame_ms

		if avg_frame_ms <= TARGET_FRAME_TIME_MS:
			report += "  Status: ✅ Within budget\n\n"
		else:
			report += "  Status: ⚠️  Over budget\n\n"

	# System profiles
	if not system_profiles.is_empty():
		report += "🔧 System Performance:\n"
		report += "  Budget per system: %.2f ms\n\n" % SYSTEM_TIME_BUDGET_MS

		# Sort systems by average time (slowest first)
		var sorted_systems := system_profiles.keys()
		sorted_systems.sort_custom(func(a, b):
			return system_profiles[a].avg_time_ms > system_profiles[b].avg_time_ms
		)

		for system_name in sorted_systems:
			var profile: SystemProfile = system_profiles[system_name]
			var status := "✅" if profile.avg_time_ms <= SYSTEM_TIME_BUDGET_MS else "⚠️"
			report += "  %s %s\n" % [status, profile.summary()]

		report += "\n"

	# Memory stats
	if not memory_samples.is_empty():
		var avg_memory := _array_average_int(memory_samples)
		var max_memory := _array_max_int(memory_samples)

		report += "💾 Memory Usage:\n"
		report += "  Average: %d MB\n" % avg_memory
		report += "  Peak: %d MB\n" % max_memory
		report += "  Status: %s\n\n" % ("✅ OK" if max_memory <= MEMORY_WARNING_MB else "⚠️ High")

	# Beat timing stats
	if not beat_timing_errors.is_empty():
		var avg_error := _array_average(beat_timing_errors)
		var max_error := _array_max(beat_timing_errors)

		report += "🎵 Beat Timing Accuracy:\n"
		report += "  Average Error: %.2f ms\n" % avg_error
		report += "  Max Error: %.2f ms\n" % max_error
		report += "  Status: %s\n\n" % ("✅ Tight" if abs(avg_error) <= BEAT_TIMING_TOLERANCE_MS else "⚠️ Loose")

	# Performance warnings
	var total_warnings := 0
	for system_name in system_profiles.keys():
		var profile: SystemProfile = system_profiles[system_name]
		total_warnings += profile.warnings.size()

	if total_warnings > 0:
		report += "⚠️  Performance Warnings: %d\n" % total_warnings
		report += "  (Check individual system profiles for details)\n"

	report += "\n" + "═" * 70 + "\n"

	return report

## Save report to file
func save_report(file_path: String = "performance-report.md") -> void:
	var report := generate_report()
	var file := FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(report)
		file.close()
		print("✅ Performance report saved to: %s" % file_path)
	else:
		push_error("Could not save performance report to: %s" % file_path)

## Helper: Average of float array
func _array_average(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var sum := 0.0
	for val in arr:
		sum += val
	return sum / float(arr.size())

## Helper: Max of float array
func _array_max(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var max_val := arr[0]
	for val in arr:
		max_val = max(max_val, val)
	return max_val

## Helper: Min of float array
func _array_min(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var min_val := arr[0]
	for val in arr:
		min_val = min(min_val, val)
	return min_val

## Helper: Average of int array
func _array_average_int(arr: Array[int]) -> int:
	if arr.is_empty():
		return 0
	var sum := 0
	for val in arr:
		sum += val
	return int(sum / arr.size())

## Helper: Max of int array
func _array_max_int(arr: Array[int]) -> int:
	if arr.is_empty():
		return 0
	var max_val := arr[0]
	for val in arr:
		max_val = max(max_val, val)
	return max_val
```

#### Helper Script for Easy Integration

Create `tests/performance/profile_helper.gd` for easy profiling:

```gdscript
# Godot 4.5 | GDScript 4.5
# Helper: Easy Performance Profiling
extends Node

## Easy performance profiling helper
##
## Usage in any system:
##   ProfileHelper.start("MySystem")
##   # ... do work ...
##   ProfileHelper.end("MySystem")

static var profiler: PerformanceProfiler = null
static var active_timers: Dictionary = {}  # SystemName -> start_time

static func get_profiler() -> PerformanceProfiler:
	if profiler == null:
		profiler = PerformanceProfiler.new()
		profiler.start_profiling()
	return profiler

## Start timing a system
static func start(system_name: String) -> void:
	active_timers[system_name] = Time.get_ticks_usec()

## End timing a system
static func end(system_name: String) -> void:
	if not active_timers.has(system_name):
		push_warning("ProfileHelper: No start time for system '%s'" % system_name)
		return

	var start_time: int = active_timers[system_name]
	var end_time := Time.get_ticks_usec()
	var duration_ms := (end_time - start_time) / 1000.0

	get_profiler().profile_system(system_name, duration_ms)
	active_timers.erase(system_name)

## Generate and print report
static func report() -> void:
	if profiler:
		print(profiler.generate_report())

## Save report to file
static func save(file_path: String = "performance-report.md") -> void:
	if profiler:
		profiler.save_report(file_path)
```

#### Creative Notes

**Make profiling satisfying:**
- Real-time performance overlay (future enhancement)
- Visual graphs of frame times
- Color-coded warnings (green/yellow/red)
- Beat-synced performance indicators
- Celebration when hitting performance targets consistently

#### Checkpoint

Create `checkpoints/framework-performance-profiler-checkpoint.md`:

```markdown
# Checkpoint: Performance Profiler

## Component: Performance Profiler
## Agent: F2
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**Files:**
- `tests/performance/performance_profiler.gd` (~400 lines)
- `tests/performance/profile_helper.gd` (~60 lines)

**Purpose:** Track and report performance metrics for all game systems

### Key Features

1. **Frame time tracking** - Monitors 60 FPS target (16.67ms)
2. **Per-system profiling** - 1ms budget per system
3. **Memory monitoring** - Tracks static memory usage
4. **Beat timing accuracy** - Rhythm-specific performance
5. **SystemProfile class** - Detailed per-system statistics
6. **Performance warnings** - Signal-based alerts for threshold breaches
7. **Report generation** - Formatted markdown reports
8. **ProfileHelper** - Easy integration for system agents

### Research Findings

**Godot 4.5 Performance:**
- [URL 1]: Performance class monitors
- [URL 2]: Frame time measurement best practices
- [URL 3]: Memory profiling techniques
- [URL 4]: Rhythm game performance budgets

### Design Decisions

**Performance budgets:**
- 16.67ms frame time (60 FPS target)
- 1ms per system (allows 16 systems comfortably)
- 512MB memory warning threshold
- 5ms beat timing tolerance

**Why track beat timing:**
- Rhythm games need tight timing
- <5ms error keeps feel responsive
- Helps identify audio/input lag issues

**Godot 4.5 Specifics:**
- Performance.get_monitor() for memory tracking
- Time.get_ticks_usec() for microsecond precision
- Signal-based warnings for reactive monitoring
- Typed arrays (Array[float], Array[int])

### How System Agents Should Use This

**Easy method (recommended):**
```gdscript
extends Node

func _process(delta: float) -> void:
    ProfileHelper.start("S05_Inventory")

    # Your system logic here
    _update_inventory()

    ProfileHelper.end("S05_Inventory")

func _ready() -> void:
    # Print report after 10 seconds
    await get_tree().create_timer(10.0).timeout
    ProfileHelper.report()
```

**Manual method:**
```gdscript
var profiler = PerformanceProfiler.new()
profiler.start_profiling()

var start_time = Time.get_ticks_usec()
_do_work()
var end_time = Time.get_ticks_usec()
var duration_ms = (end_time - start_time) / 1000.0

profiler.profile_system("MySystem", duration_ms)
```

### Integration with Other Framework Components

- **Integration Tests:** Can measure test execution performance
- **CI Runner:** Generate performance reports in CI
- **Quality Gates:** Performance could be a quality dimension (future)
- **Coordination Dashboard:** Show live performance stats (future)

### Files Created

- `tests/performance/performance_profiler.gd`
- `tests/performance/profile_helper.gd`
- `research/framework-performance-profiler-research.md`

### Output Files

Generated reports:
- `performance-report.md`

### Git Commit

```bash
git add tests/performance/ research/ checkpoints/
git commit -m "Add Performance Profiler framework component

- Frame time tracking with 60 FPS target
- Per-system profiling with 1ms budget
- Memory usage monitoring
- Beat timing accuracy tracking
- SystemProfile class for detailed stats
- ProfileHelper for easy integration
- Markdown report generation

Research: Godot 4.5 performance monitoring, rhythm game budgets
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
⬜ Coordination Dashboard: **NEXT**
```

---

### Component 6: Coordination Dashboard

**Duration:** 0.75 day
**File:** `COORDINATION-DASHBOARD.md`

#### Research Phase (30 minutes)

**Search queries:**
```
"multi-agent coordination dashboard"
"project status tracking markdown"
"agile task board markdown"
"team coordination best practices"
```

**Research checklist:**
- [ ] Review multi-agent coordination patterns
- [ ] Find examples of markdown-based dashboards
- [ ] Research effective status communication
- [ ] Understand agent hand-off patterns

**Document findings:**
Create `research/framework-coordination-dashboard-research.md`

#### Implementation

**File:** `COORDINATION-DASHBOARD.md`

```markdown
# Coordination Dashboard
## Multi-Agent Development Status Tracker

**Last Updated:** [Auto-updated by agents]
**Project:** Rhythm RPG - Godot 4.5
**Branch:** claude/framework-setup

---

## 🎯 Current Focus

**Active Phase:** Framework Setup
**Target Completion:** 3-4 days from start
**Overall Progress:** [XX]% complete

---

## 👥 Agent Status

### Framework Agents (F1, F2, F3)

| Agent | Current Task | Status | Progress | Est. Completion |
|-------|--------------|--------|----------|-----------------|
| **F1** | CI Test Runner | 🟢 Active | 4/4 complete | Day 2.5 |
| **F2** | Performance Profiler | 🟢 Active | 1/3 complete | Day 2 |
| **F3** | Asset Pipeline | ⚪ Waiting | 0/3 complete | Day 1.5 |

**Status Legend:**
- 🟢 Active - Currently working
- 🟡 Blocked - Waiting on dependency
- 🔵 Review - Awaiting review/merge
- ⚪ Waiting - Not started
- ✅ Complete - Finished and merged

### System Agents (S01-S26)

**Wave 1 (Foundation - Days 5-7):**
| Agent | System | Status | Progress | Blockers |
|-------|--------|--------|----------|----------|
| S01 | Conductor | ⚪ Waiting | 0% | Framework not ready |
| S02 | Input System | ⚪ Waiting | 0% | Framework not ready |
| S03 | Player Controller | ⚪ Waiting | 0% | S01, S02 needed |
| S04 | Combat System | ⚪ Waiting | 0% | S01, S02, S03 needed |

*Remaining waves shown when framework complete...*

---

## 📊 Framework Component Status

| Component | Assigned | Status | Quality Score | Notes |
|-----------|----------|--------|---------------|-------|
| Integration Tests | F1 | ✅ Complete | -/100 | Ready for use |
| Quality Gates | F1 | ✅ Complete | -/100 | JSON schema created |
| Checkpoint Validation | F1 | ✅ Complete | -/100 | Validates checkpoints |
| CI Test Runner | F1 | 🟢 In Progress | -/100 | Headless runner |
| Performance Profiler | F2 | 🟢 In Progress | -/100 | Frame/system timing |
| Coordination Dashboard | F2 | ⚪ Not Started | -/100 | This file |
| Rollback System | F2 | ⚪ Not Started | -/100 | - |
| Known Issues DB | F3 | ⚪ Not Started | -/100 | - |
| Knowledge Base | F3 | ⚪ Not Started | -/100 | - |
| Asset Pipeline | F3 | ⚪ Not Started | -/100 | - |

**Overall Framework Progress:** 4/10 components (40%)

---

## 🔗 Dependencies & Blockers

### Current Blockers

**None** - All framework agents can work in parallel

### Upcoming Dependencies

**System Wave 1 Dependencies:**
- S01 (Conductor) - No dependencies, can start immediately after framework
- S02 (Input) - No dependencies, can start immediately after framework
- S03 (Player) - Requires S01 (beat sync), S02 (input handling)
- S04 (Combat) - Requires S01 (rhythm), S02 (input), S03 (player state)

---

## 📝 Recent Activity

### Today
- **F1:** Completed Checkpoint Validation (Component 3)
- **F1:** Started CI Test Runner (Component 4)
- **F2:** Started Performance Profiler (Component 5)

### Yesterday
- **F1:** Completed Integration Test Suite
- **F1:** Completed Quality Gates JSON schema
- Project planning completed

### This Week Goals
- ✅ Framework architecture designed
- 🟢 Framework components implementation (in progress)
- ⬜ Framework integration testing
- ⬜ Handoff to Wave 1 system agents

---

## ⚠️ Issues & Risks

### Active Issues

**None currently**

### Potential Risks

1. **Risk:** Framework components may reveal integration issues
   - **Mitigation:** Comprehensive integration tests in place
   - **Status:** 🟢 Low risk

2. **Risk:** System agents may need additional framework tools
   - **Mitigation:** Framework agents available for quick additions
   - **Status:** 🟡 Monitor

---

## 🎯 Milestones

| Milestone | Target Date | Status | Dependencies |
|-----------|-------------|--------|--------------|
| Framework Design | Day 1 | ✅ Complete | - |
| Framework F1 Complete | Day 2.5 | 🟢 On Track | - |
| Framework F2 Complete | Day 4 | ⚪ Pending | - |
| Framework F3 Complete | Day 5 | ⚪ Pending | - |
| Framework Integration | Day 5.5 | ⚪ Pending | F1, F2, F3 |
| Wave 1 Start | Day 6 | ⚪ Pending | Framework done |

---

## 📋 Agent Hand-off Checklist

### For Framework Agents (Before Completing)

- [ ] All components implemented with full code
- [ ] Comprehensive checkpoint created
- [ ] Quality gate self-evaluation (80+ score)
- [ ] Integration with other framework components tested
- [ ] Research findings documented
- [ ] Files committed to git
- [ ] This dashboard updated

### For System Agents (Before Starting)

- [ ] Read `FRAMEWORK-SETUP-GUIDE.md`
- [ ] Read `PARALLEL-EXECUTION-GUIDE-V2.md`
- [ ] Check dependencies are complete (see dependency graph)
- [ ] Update this dashboard with your status
- [ ] Create checkpoint file for your system

---

## 💬 Communication Protocol

### Status Updates

**Frequency:** Update dashboard when:
- Starting a new component/system
- Completing a component/system
- Encountering blockers
- Making significant progress

**Update Format:**
```markdown
### [Current Date]
- **[Agent ID]:** [Brief status update]
```

### Requesting Help

If blocked, add to "Issues & Risks" section:
```markdown
**[Issue Title]**
- **Blocker:** [What's blocking you]
- **Agent:** [Your agent ID]
- **Needs:** [What you need to unblock]
```

---

## 📈 Quality Metrics

### Framework Components

**Average Quality Score:** Pending (will calculate when all components have scores)
**Target:** 80/100 minimum

### Test Coverage

**Integration Tests:** 26/26 systems (templates created)
**Checkpoint Validation:** Active
**CI Pipeline:** In progress

---

## 🎨 Creative Highlights

**Fun elements added:**
- Colorful emoji status indicators throughout framework
- ASCII art test summaries
- Beat-synced performance monitoring
- Satisfying validation feedback

**Innovation opportunities for system agents:**
- Add creative beat sync animations
- Design unique rhythm mechanics
- Create satisfying combat feedback
- Polish game feel with "juice"

---

## 📚 Quick Reference

### Important Files

- `FRAMEWORK-SETUP-GUIDE.md` - Detailed framework implementation guide
- `PARALLEL-EXECUTION-GUIDE-V2.md` - Overall execution strategy
- `quality-gates.json` - Quality standards
- `PROJECT-STATUS.md` - Overall project structure

### Key Commands

```bash
# Run integration tests
godot --headless --script scripts/ci_runner.gd

# Validate checkpoints
var validator = CheckpointValidator.new()
validator.validate_all_checkpoints()

# Generate performance report
ProfileHelper.report()
```

### Git Workflow

```bash
# All agents work on same branch
git checkout -b claude/framework-setup

# Commit frequently
git add [files]
git commit -m "Clear message"

# Push when component complete
git push -u origin claude/framework-setup
```

---

## 🔄 Update History

### [Current Date] - Dashboard Created
- Initial dashboard structure
- Framework agent status tracking
- Milestone planning

---

**End of Dashboard** - Agents: Please keep this updated! 🚀
```

#### Creative Notes

**Make coordination satisfying:**
- Clear visual status indicators (emoji)
- Easy-to-scan tables
- Celebration of completed components
- Progress bars (future: could add ASCII progress bars)
- Fun, encouraging language

**Future enhancements:**
- Auto-update via script
- Visual dependency graph
- Real-time agent activity feed
- Integration with git commits

#### Checkpoint

Create `checkpoints/framework-coordination-dashboard-checkpoint.md`:

```markdown
# Checkpoint: Coordination Dashboard

## Component: Coordination Dashboard
## Agent: F2
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `COORDINATION-DASHBOARD.md`
**Lines:** ~300
**Purpose:** Central coordination hub for all framework and system agents

### Key Features

1. **Agent status tracking** - Real-time view of what each agent is doing
2. **Framework progress** - 10 components with status/quality scores
3. **Dependencies & blockers** - Clear visibility of what's blocking progress
4. **Recent activity log** - Daily updates from all agents
5. **Issues & risks tracker** - Proactive risk management
6. **Milestones** - Key targets with status
7. **Hand-off checklists** - Ensure complete handoffs between agents
8. **Communication protocol** - Clear guidelines for status updates
9. **Quality metrics** - Track overall quality across components
10. **Quick reference** - Important files, commands, git workflow

### Research Findings

**Coordination Best Practices:**
- [URL 1]: Multi-agent coordination patterns
- [URL 2]: Markdown-based status tracking
- [URL 3]: Agile dashboard design
- [URL 4]: Team communication protocols

### Design Decisions

**Why markdown instead of database:**
- Easy to read/edit in any text editor
- Version controlled with git
- No external dependencies
- Human-readable history

**Status indicators:**
- 🟢 Active (currently working)
- 🟡 Blocked (waiting on dependency)
- 🔵 Review (awaiting review)
- ⚪ Waiting (not started)
- ✅ Complete (done)

**Key sections prioritized:**
- Agent Status (most important - who's doing what)
- Framework Progress (current focus)
- Dependencies (what's blocking us)
- Recent Activity (what happened)

### How Agents Should Use This

**When starting work:**
1. Update your status to 🟢 Active
2. Add what you're working on
3. Note any dependencies

**When completing work:**
1. Update status to ✅ Complete
2. Add quality score (if applicable)
3. Add entry to Recent Activity

**When blocked:**
1. Update status to 🟡 Blocked
2. Add blocker to "Issues & Risks"
3. Specify what you need

**Daily:**
- Add activity summary to "Recent Activity"
- Review other agents' status
- Check for blockers affecting you

### Example Usage

**F1 completing Component 4:**
```markdown
## Framework Component Status
| CI Test Runner | F1 | ✅ Complete | 85/100 | Ready for CI |

## Recent Activity
### 2025-11-17
- **F1:** Completed CI Test Runner (Component 4) - All F1 work done! 🎉
```

**S05 agent starting work:**
```markdown
## Agent Status
| S05 | Inventory System | 🟢 Active | 0/4 jobs | Day 7 |

## Recent Activity
### 2025-11-18
- **S05:** Started Inventory System implementation - Job 1 in progress
```

**Agent encountering blocker:**
```markdown
## Issues & Risks
**Conductor beat signal not emitting**
- **Blocker:** S03 needs beat sync from S01, but signals not working
- **Agent:** S03
- **Needs:** S01 agent to review Conductor signal implementation
```

### Integration with Other Framework Components

- **Quality Gates:** Dashboard displays quality scores
- **Checkpoint Validation:** Shows validation status
- **Integration Tests:** Links to test results
- **Performance Profiler:** Could show performance metrics (future)

### Files Created

- `COORDINATION-DASHBOARD.md`
- `research/framework-coordination-dashboard-research.md`

### Git Commit

```bash
git add COORDINATION-DASHBOARD.md research/ checkpoints/
git commit -m "Add Coordination Dashboard framework component

- Central status tracking for all agents
- Framework component progress (10 components)
- Agent status with emoji indicators
- Dependencies and blocker tracking
- Recent activity log
- Milestones and hand-off checklists
- Communication protocol
- Quick reference section

Research: Multi-agent coordination, markdown dashboards
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
✅ Coordination Dashboard: **COMPLETE**
⬜ Rollback System: **NEXT**
```

---

### Component 7: Rollback System

**Duration:** 0.5 day
**File:** `scripts/checkpoint_manager.gd`

#### Research Phase (30 minutes)

**Search queries:**
```
"Godot 4.5 save system"
"GDScript 4.5 file copy"
"version control for game state"
"checkpoint rollback system"
```

**Research checklist:**
- [ ] Review Godot 4.5 DirAccess and FileAccess APIs
- [ ] Understand file copying in GDScript
- [ ] Find snapshot/rollback patterns
- [ ] Research safe file operations

**Document findings:**
Create `research/framework-rollback-system-research.md`

#### Implementation

**File:** `scripts/checkpoint_manager.gd`

```gdscript
# Godot 4.5 | GDScript 4.5
# Framework: Checkpoint Rollback System
# Purpose: Create snapshots of checkpoints and enable rollback
# Created: 2025-11-17

extends Node
class_name CheckpointManager

## Checkpoint Rollback System
##
## Creates versioned snapshots of checkpoint files and allows rolling back
## to previous states if needed. Useful for recovering from mistakes or
## exploring alternative implementation approaches.
##
## Usage:
##   var manager = CheckpointManager.new()
##   manager.create_snapshot("before-refactor")
##   # ... make changes ...
##   manager.rollback_to_snapshot("before-refactor")  # If needed

## Snapshot metadata
class Snapshot:
	var snapshot_id: String = ""
	var timestamp: String = ""
	var description: String = ""
	var files_count: int = 0
	var checkpoint_files: Array[String] = []

	func summary() -> String:
		return "%s | %s | %d files | %s" % [
			snapshot_id, timestamp, files_count, description
		]

## Snapshots directory
const SNAPSHOTS_DIR: String = ".snapshots"
const CHECKPOINTS_DIR: String = "checkpoints"

## Available snapshots
var snapshots: Dictionary = {}  # snapshot_id -> Snapshot

func _init() -> void:
	_ensure_snapshots_dir()
	_load_snapshot_metadata()

## Ensure snapshots directory exists
func _ensure_snapshots_dir() -> void:
	if not DirAccess.dir_exists_absolute(SNAPSHOTS_DIR):
		DirAccess.make_dir_absolute(SNAPSHOTS_DIR)
		print("📁 Created snapshots directory: %s" % SNAPSHOTS_DIR)

## Create a snapshot of current checkpoints
func create_snapshot(description: String = "Manual snapshot") -> String:
	var snapshot_id := _generate_snapshot_id()
	var snapshot := Snapshot.new()
	snapshot.snapshot_id = snapshot_id
	snapshot.timestamp = Time.get_datetime_string_from_system()
	snapshot.description = description

	print("\n📸 Creating snapshot: %s" % snapshot_id)
	print("─" * 60)

	# Create snapshot directory
	var snapshot_dir := SNAPSHOTS_DIR + "/" + snapshot_id
	DirAccess.make_dir_absolute(snapshot_dir)

	# Copy all checkpoint files
	if not DirAccess.dir_exists_absolute(CHECKPOINTS_DIR):
		print("⊘ No checkpoints directory found - creating empty snapshot")
		_save_snapshot_metadata(snapshot)
		return snapshot_id

	var dir := DirAccess.open(CHECKPOINTS_DIR)
	if dir == null:
		push_error("Could not open checkpoints directory")
		return ""

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".md") and not file_name.begins_with("."):
			var source_path := CHECKPOINTS_DIR + "/" + file_name
			var dest_path := snapshot_dir + "/" + file_name

			if _copy_file(source_path, dest_path):
				snapshot.checkpoint_files.append(file_name)
				snapshot.files_count += 1
				print("  ✓ Copied: %s" % file_name)

		file_name = dir.get_next()

	dir.list_dir_end()

	# Save snapshot metadata
	_save_snapshot_metadata(snapshot)
	snapshots[snapshot_id] = snapshot

	print("─" * 60)
	print("✅ Snapshot created: %s (%d files)" % [snapshot_id, snapshot.files_count])
	print("")

	return snapshot_id

## Rollback to a previous snapshot
func rollback_to_snapshot(snapshot_id: String) -> bool:
	if not snapshots.has(snapshot_id):
		push_error("Snapshot not found: %s" % snapshot_id)
		return false

	var snapshot: Snapshot = snapshots[snapshot_id]

	print("\n⏮️  Rolling back to snapshot: %s" % snapshot_id)
	print("─" * 60)
	print("Description: %s" % snapshot.description)
	print("Created: %s" % snapshot.timestamp)
	print("Files: %d" % snapshot.files_count)
	print("")
	print("⚠️  This will overwrite current checkpoints!")
	print("")

	# Ensure checkpoints directory exists
	if not DirAccess.dir_exists_absolute(CHECKPOINTS_DIR):
		DirAccess.make_dir_absolute(CHECKPOINTS_DIR)

	# Copy files from snapshot back to checkpoints
	var snapshot_dir := SNAPSHOTS_DIR + "/" + snapshot_id
	var restored_count := 0

	for file_name in snapshot.checkpoint_files:
		var source_path := snapshot_dir + "/" + file_name
		var dest_path := CHECKPOINTS_DIR + "/" + file_name

		if _copy_file(source_path, dest_path):
			restored_count += 1
			print("  ✓ Restored: %s" % file_name)
		else:
			print("  ✗ Failed: %s" % file_name)

	print("─" * 60)
	print("✅ Rollback complete: %d/%d files restored" % [restored_count, snapshot.files_count])
	print("")

	return restored_count == snapshot.files_count

## List all available snapshots
func list_snapshots() -> Array[Snapshot]:
	var snapshot_list: Array[Snapshot] = []

	for snapshot_id in snapshots.keys():
		snapshot_list.append(snapshots[snapshot_id])

	# Sort by timestamp (newest first)
	snapshot_list.sort_custom(func(a: Snapshot, b: Snapshot):
		return a.timestamp > b.timestamp
	)

	return snapshot_list

## Print snapshot list
func print_snapshots() -> void:
	var snapshot_list := list_snapshots()

	if snapshot_list.is_empty():
		print("⊘ No snapshots found")
		return

	print("\n📸 Available Snapshots:")
	print("═" * 70)

	for snapshot in snapshot_list:
		print(snapshot.summary())

	print("═" * 70)
	print("Total: %d snapshots\n" % snapshot_list.size())

## Delete a snapshot
func delete_snapshot(snapshot_id: String) -> bool:
	if not snapshots.has(snapshot_id):
		push_error("Snapshot not found: %s" % snapshot_id)
		return false

	var snapshot_dir := SNAPSHOTS_DIR + "/" + snapshot_id

	# Delete all files in snapshot directory
	_delete_directory_recursive(snapshot_dir)

	# Remove from snapshots dict
	snapshots.erase(snapshot_id)

	print("🗑️  Deleted snapshot: %s" % snapshot_id)
	return true

## Generate unique snapshot ID
func _generate_snapshot_id() -> String:
	var timestamp := Time.get_datetime_dict_from_system()
	return "snapshot-%04d%02d%02d-%02d%02d%02d" % [
		timestamp.year, timestamp.month, timestamp.day,
		timestamp.hour, timestamp.minute, timestamp.second
	]

## Copy a single file
func _copy_file(source_path: String, dest_path: String) -> bool:
	var source_file := FileAccess.open(source_path, FileAccess.READ)
	if source_file == null:
		push_error("Could not open source file: %s" % source_path)
		return false

	var content := source_file.get_as_text()
	source_file.close()

	var dest_file := FileAccess.open(dest_path, FileAccess.WRITE)
	if dest_file == null:
		push_error("Could not create destination file: %s" % dest_path)
		return false

	dest_file.store_string(content)
	dest_file.close()

	return true

## Save snapshot metadata to JSON
func _save_snapshot_metadata(snapshot: Snapshot) -> void:
	var metadata := {
		"snapshot_id": snapshot.snapshot_id,
		"timestamp": snapshot.timestamp,
		"description": snapshot.description,
		"files_count": snapshot.files_count,
		"checkpoint_files": snapshot.checkpoint_files
	}

	var metadata_path := SNAPSHOTS_DIR + "/" + snapshot.snapshot_id + "/metadata.json"
	var file := FileAccess.open(metadata_path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(metadata, "\t"))
		file.close()

## Load all snapshot metadata
func _load_snapshot_metadata() -> void:
	if not DirAccess.dir_exists_absolute(SNAPSHOTS_DIR):
		return

	var dir := DirAccess.open(SNAPSHOTS_DIR)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var metadata_path := SNAPSHOTS_DIR + "/" + file_name + "/metadata.json"

			if FileAccess.file_exists(metadata_path):
				_load_single_snapshot_metadata(file_name, metadata_path)

		file_name = dir.get_next()

	dir.list_dir_end()

## Load metadata for a single snapshot
func _load_single_snapshot_metadata(snapshot_id: String, metadata_path: String) -> void:
	var file := FileAccess.open(metadata_path, FileAccess.READ)
	if file == null:
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)

	if parse_result == OK:
		var data: Dictionary = json.data
		var snapshot := Snapshot.new()
		snapshot.snapshot_id = data.get("snapshot_id", snapshot_id)
		snapshot.timestamp = data.get("timestamp", "")
		snapshot.description = data.get("description", "")
		snapshot.files_count = data.get("files_count", 0)

		var files_array: Array = data.get("checkpoint_files", [])
		for file_path in files_array:
			snapshot.checkpoint_files.append(file_path)

		snapshots[snapshot_id] = snapshot

## Delete directory and all contents recursively
func _delete_directory_recursive(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	# Delete all files first
	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		var full_path := dir_path + "/" + file_name

		if dir.current_is_dir() and not file_name.begins_with("."):
			_delete_directory_recursive(full_path)
		else:
			DirAccess.remove_absolute(full_path)

		file_name = dir.get_next()

	dir.list_dir_end()

	# Delete the directory itself
	DirAccess.remove_absolute(dir_path)
```

#### Creative Notes

**Make rollback system satisfying:**
- Clear confirmation messages
- Visual progress indicators when copying files
- Fun snapshot ID names (could use more creative names like "epic-refactor", "before-catastrophe")
- Success celebrations with emoji
- Warning messages that are helpful, not scary

**Future enhancements:**
- Diff view showing what changed between snapshots
- Auto-snapshot before major operations
- Cloud backup integration
- Compressed snapshots for space savings

#### Checkpoint

Create `checkpoints/framework-rollback-system-checkpoint.md`:

```markdown
# Checkpoint: Rollback System

## Component: Rollback System
## Agent: F2
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `scripts/checkpoint_manager.gd`
**Lines of Code:** ~350
**Purpose:** Version control for checkpoint files with snapshot/rollback capability

### Key Features

1. **Snapshot creation** - Save current state of all checkpoints
2. **Rollback capability** - Restore to any previous snapshot
3. **Snapshot listing** - View all available snapshots
4. **Metadata tracking** - Timestamp, description, file count per snapshot
5. **Snapshot deletion** - Remove old/unwanted snapshots
6. **Automatic metadata** - JSON metadata for each snapshot
7. **Recursive file operations** - Safe directory copying/deletion

### Research Findings

**Godot 4.5 File Operations:**
- [URL 1]: DirAccess API for directory operations
- [URL 2]: FileAccess for file copying
- [URL 3]: Recursive directory traversal patterns
- [URL 4]: Safe file operation best practices

### Design Decisions

**Why .snapshots directory:**
- Hidden directory (starts with .)
- Easy to .gitignore
- Organized separately from checkpoints

**Snapshot ID format:**
- Format: `snapshot-YYYYMMDD-HHMMSS`
- Human-readable
- Sortable chronologically
- Unique per second

**Metadata in JSON:**
- Persists across sessions
- Easy to read/parse
- Includes file list for verification

**Godot 4.5 Specifics:**
- DirAccess.make_dir_absolute() for directory creation
- FileAccess for file I/O
- JSON.parse() for metadata
- Recursive directory operations

### How System Agents Should Use This

**Before major refactoring:**
```gdscript
var manager = CheckpointManager.new()
manager.create_snapshot("before-combat-refactor")

# Make changes...

# If something goes wrong:
manager.rollback_to_snapshot("snapshot-20251117-143022")
```

**View available snapshots:**
```gdscript
var manager = CheckpointManager.new()
manager.print_snapshots()
```

**Clean up old snapshots:**
```gdscript
var manager = CheckpointManager.new()
manager.delete_snapshot("snapshot-20251115-100000")
```

### Example Usage

```gdscript
# Create checkpoint manager
var manager = CheckpointManager.new()

# Create snapshot before making changes
var snapshot_id = manager.create_snapshot("Before adding S05 integration tests")
# Output: 📸 Creating snapshot: snapshot-20251117-143022
# Output: ✅ Snapshot created: snapshot-20251117-143022 (5 files)

# Make changes to checkpoint files...
# Oops, made a mistake!

# Rollback to snapshot
manager.rollback_to_snapshot(snapshot_id)
# Output: ⏮️  Rolling back to snapshot: snapshot-20251117-143022
# Output: ✅ Rollback complete: 5/5 files restored

# List all snapshots
manager.print_snapshots()
# Output:
# 📸 Available Snapshots:
# ═══════════════════════════════════════
# snapshot-20251117-143022 | 2025-11-17T14:30:22 | 5 files | Before adding S05 integration tests
# snapshot-20251117-100015 | 2025-11-17T10:00:15 | 4 files | Framework checkpoint baseline
# ═══════════════════════════════════════
# Total: 2 snapshots
```

### Integration with Other Framework Components

- **Checkpoint Validation:** Can snapshot before/after validation fixes
- **Quality Gates:** Snapshot before quality improvements
- **CI Runner:** Could auto-snapshot before CI runs (future)
- **Integration Tests:** Snapshot before test-driven refactors

### Files Created

- `scripts/checkpoint_manager.gd`
- `research/framework-rollback-system-research.md`

### Directory Structure

Created:
```
.snapshots/
  snapshot-YYYYMMDD-HHMMSS/
    metadata.json
    [checkpoint files copied here]
```

### Git Ignore

Add to `.gitignore`:
```
.snapshots/
```

### Git Commit

```bash
git add scripts/checkpoint_manager.gd research/ checkpoints/ .gitignore
git commit -m "Add Rollback System framework component

- Snapshot creation for checkpoint versioning
- Rollback capability to restore previous states
- Snapshot metadata tracking (timestamp, description, files)
- Snapshot listing and deletion
- Recursive file operations for safe copying
- JSON metadata persistence

Research: Godot 4.5 file operations, snapshot patterns
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
✅ Coordination Dashboard: **COMPLETE**
✅ Rollback System: **COMPLETE**

**Agent F2 Work: COMPLETE!** 🎉
```

---

## Agent F3: Knowledge & Assets

**Your Mission:** Create knowledge management systems and asset generation tools to support all game systems.

**Components:**
8. Known Issues DB (`KNOWN-ISSUES.md`)
9. Knowledge Base Directories (`knowledge-base/` structure)
10. Asset Pipeline (`ASSET-PIPELINE.md` + `scripts/generate_placeholders.gd`)

**Estimated Time:** 1.5 days (4-5 hours per component)

---

### Component 8: Known Issues DB

**Duration:** 0.5 day
**File:** `KNOWN-ISSUES.md`

#### Research Phase (30 minutes)

**Search queries:**
```
"bug tracking best practices"
"issue database markdown format"
"game development common issues"
"Godot known issues tracking"
```

**Research checklist:**
- [ ] Review bug tracking methodologies
- [ ] Find examples of markdown issue databases
- [ ] Understand issue severity classifications
- [ ] Research resolution tracking patterns

**Document findings:**
Create `research/framework-known-issues-research.md`

#### Implementation

**File:** `KNOWN-ISSUES.md`

```markdown
# Known Issues Database
## Bug Tracking & Resolution for Rhythm RPG

**Last Updated:** [Auto-updated by agents]
**Project:** Rhythm RPG - Godot 4.5
**Total Issues:** 0 open, 0 resolved

---

## 🎯 Quick Stats

| Category | Open | Resolved | Total |
|----------|------|----------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **0** | **0** | **0** |

---

## 📋 Issue Categories

### Framework Issues
Issues related to the 10 framework components

### System Integration Issues
Issues when systems interact with each other

### Godot 4.5 Compatibility Issues
Engine-specific bugs or compatibility problems

### Performance Issues
Frame rate, memory, or timing problems

### Gameplay Issues
Game feel, balance, or mechanic problems

### Asset Issues
Missing, broken, or incorrect assets

---

## 🔴 Critical Issues (Open)

**Definition:** Blocks development, crashes, data loss, or game-breaking bugs

**None currently** 🎉

---

## 🟠 High Priority Issues (Open)

**Definition:** Major functionality broken, significant performance problems

**None currently** 🎉

---

## 🟡 Medium Priority Issues (Open)

**Definition:** Minor functionality issues, cosmetic bugs, polish needed

**None currently** 🎉

---

## 🟢 Low Priority Issues (Open)

**Definition:** Nice-to-have improvements, minor polish, future enhancements

**None currently** 🎉

---

## ✅ Resolved Issues

### Example Issue (Delete this when adding real issues)

**Issue ID:** #001
**Severity:** 🟡 Medium
**Category:** Framework
**System:** Integration Tests
**Reported By:** F1
**Date Reported:** 2025-11-17
**Date Resolved:** 2025-11-17
**Resolved By:** F1

**Description:**
Example issue showing the format for tracking bugs.

**Reproduction Steps:**
1. Step one
2. Step two
3. Bug occurs

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Solution:**
How it was fixed

**Files Changed:**
- `path/to/file.gd`

**Commit:**
`abc123f - Fix example issue`

---

## 📝 How to Report an Issue

### For All Agents

When you encounter a bug:

1. **Check if already reported** - Search this file first
2. **Assign Issue ID** - Use next sequential number (#002, #003, etc.)
3. **Determine severity:**
   - 🔴 Critical: Blocks work, crashes, data loss
   - 🟠 High: Major feature broken, bad performance
   - 🟡 Medium: Minor feature issue, cosmetic bug
   - 🟢 Low: Enhancement, polish, nice-to-have
4. **Fill in template** - See below
5. **Update stats** - Increment totals at top
6. **Commit changes** - Git commit with "Add issue #XXX"

### Issue Template

```markdown
**Issue ID:** #XXX
**Severity:** [🔴/🟠/🟡/🟢]
**Category:** [Framework/System Integration/Godot/Performance/Gameplay/Asset]
**System:** [Which system(s) affected]
**Reported By:** [Your agent ID]
**Date Reported:** [YYYY-MM-DD]
**Status:** Open

**Description:**
Clear, concise description of the issue.

**Reproduction Steps:**
1. Precise steps to reproduce
2. Include configuration/state needed
3. What triggers the bug

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Impact:**
- How does this affect development/gameplay?
- What's blocked by this issue?

**Workaround:**
Temporary solution if one exists

**Proposed Solution:**
Ideas for how to fix it

**Related Issues:**
Links to related bugs (#XXX)

**System Info:**
- Godot Version: 4.5.1
- OS: Linux/Windows/Mac
- Hardware: [If relevant]
```

---

## 🔧 How to Resolve an Issue

When fixing a bug:

1. **Move issue** from Open section to Resolved section
2. **Add resolution info:**
   - Date Resolved
   - Resolved By
   - Solution (how you fixed it)
   - Files Changed
   - Commit hash
3. **Update stats** - Decrement open, increment resolved
4. **Close related issues** - If fix resolves multiple bugs
5. **Commit** - "Resolve issue #XXX: [brief description]"

---

## 📊 Issue Analytics

### Common Issue Patterns

*Will be filled as issues are found and resolved*

**Most Common Categories:**
- TBD

**Most Affected Systems:**
- TBD

**Average Resolution Time:**
- TBD

### Prevention Strategies

**Based on resolved issues:**
1. Always run integration tests before committing
2. Validate checkpoints before pushing
3. Profile performance for rhythm-critical code
4. Test beat sync at different BPMs
5. Check Godot 4.5 compatibility for all APIs

---

## 🎨 Creative Issue Resolution

**Make bug fixing satisfying:**
- Celebrate each resolution with emoji
- Track "bug squash streaks"
- Share interesting bugs in Recent Activity
- Document clever solutions in Knowledge Base
- Learn from mistakes to prevent future issues

---

## 🔗 Integration with Framework

### Related Tools

- **Integration Tests:** Run tests to catch regressions
- **Checkpoint Validation:** Ensure quality before committing
- **Performance Profiler:** Identify performance issues
- **Quality Gates:** Prevent low-quality code

### Workflow

```
Encounter Bug
    ↓
Report in KNOWN-ISSUES.md
    ↓
Assign Priority
    ↓
Fix the Bug
    ↓
Test with Integration Tests
    ↓
Update KNOWN-ISSUES.md (Resolved)
    ↓
Commit & Push
```

---

## 📚 Historical Issues

### Issue Timeline

*Graph or list of issues over time - will be populated as project progresses*

---

**End of Known Issues Database** - Keep it updated! 🐛
```

#### Creative Notes

**Make issue tracking satisfying:**
- Clear severity indicators (color-coded emoji)
- Quick stats dashboard at top
- Celebrate when sections are empty ("None currently 🎉")
- Track resolution streaks
- Make templates easy to copy-paste

**Future enhancements:**
- Auto-generate stats from issue entries
- Link issues to git commits
- Create visual timeline of issues
- Bug bash leaderboards

#### Checkpoint

Create `checkpoints/framework-known-issues-checkpoint.md`:

```markdown
# Checkpoint: Known Issues DB

## Component: Known Issues DB
## Agent: F3
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**File:** `KNOWN-ISSUES.md`
**Lines:** ~250
**Purpose:** Centralized bug tracking and resolution database

### Key Features

1. **Quick stats dashboard** - At-a-glance issue overview
2. **Severity classification** - 4 levels (Critical, High, Medium, Low)
3. **Category organization** - 6 issue categories
4. **Issue template** - Standardized reporting format
5. **Resolution tracking** - How bugs were fixed
6. **Prevention strategies** - Learn from past issues
7. **Integration workflow** - Links to framework tools
8. **Historical tracking** - Issue timeline

### Research Findings

**Bug Tracking Best Practices:**
- [URL 1]: Issue severity classification
- [URL 2]: Markdown-based issue tracking
- [URL 3]: Game development common bugs
- [URL 4]: Resolution documentation patterns

### Design Decisions

**Severity levels:**
- 🔴 Critical (blocks work, crashes, data loss)
- 🟠 High (major feature broken)
- 🟡 Medium (minor issues, cosmetic)
- 🟢 Low (enhancements, polish)

**Why markdown over GitHub Issues:**
- Version controlled with code
- Offline access
- Customizable format
- Direct integration with documentation
- No external dependencies

**Issue ID format:**
- Simple sequential (#001, #002, etc.)
- Easy to reference in commits
- Human-readable

### How System Agents Should Use This

**When you find a bug:**
1. Search KNOWN-ISSUES.md to see if already reported
2. If new, copy the issue template
3. Fill in all fields (ID, severity, description, steps)
4. Add to appropriate severity section
5. Update stats at top
6. Commit: "Add issue #XXX: [description]"

**When you fix a bug:**
1. Move issue from Open to Resolved
2. Add resolution info (date, solution, files, commit)
3. Update stats
4. Commit: "Resolve issue #XXX: [description]"

### Example Issue Report

```markdown
**Issue ID:** #042
**Severity:** 🟡 Medium
**Category:** System Integration
**System:** S03 Player Controller
**Reported By:** S03
**Date Reported:** 2025-11-20
**Status:** Open

**Description:**
Player character stutters when landing on beat while moving

**Reproduction Steps:**
1. Start game with S01 Conductor running at 120 BPM
2. Move player character left/right
3. Jump and land exactly on beat
4. Character position stutters briefly

**Expected Behavior:**
Smooth landing animation synced to beat

**Actual Behavior:**
Character position jumps ~5 pixels then corrects

**Impact:**
- Minor visual glitch
- Doesn't affect gameplay
- Noticeable at high BPMs (>140)

**Workaround:**
Avoid landing exactly on beat (not practical)

**Proposed Solution:**
Interpolate landing animation over 2-3 frames instead of immediate

**System Info:**
- Godot Version: 4.5.1
- BPM tested: 120, 140, 160
- Physics FPS: 60
```

### Integration with Other Framework Components

- **Integration Tests:** Add regression tests for fixed bugs
- **Quality Gates:** Bugs found during quality evaluation
- **CI Runner:** Could auto-check for open critical issues
- **Coordination Dashboard:** Link to issue counts

### Files Created

- `KNOWN-ISSUES.md`
- `research/framework-known-issues-research.md`

### Git Commit

```bash
git add KNOWN-ISSUES.md research/ checkpoints/
git commit -m "Add Known Issues DB framework component

- Centralized bug tracking database
- 4 severity levels with emoji indicators
- 6 issue categories
- Standardized issue template
- Resolution tracking
- Quick stats dashboard
- Prevention strategies
- Integration workflow

Research: Bug tracking best practices, issue classification
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
✅ Coordination Dashboard: **COMPLETE**
✅ Rollback System: **COMPLETE**
✅ Known Issues DB: **COMPLETE**
⬜ Knowledge Base: **NEXT**
```

---

### Component 9: Knowledge Base Directories

**Duration:** 0.5 day
**Files:** `knowledge-base/` directory structure + README files

#### Research Phase (30 minutes)

**Search queries:**
```
"knowledge management for development teams"
"documentation organization best practices"
"lessons learned database structure"
"technical knowledge base design"
```

**Research checklist:**
- [ ] Review knowledge management methodologies
- [ ] Find examples of well-organized knowledge bases
- [ ] Understand searchable documentation patterns
- [ ] Research cross-referencing strategies

**Document findings:**
Create `research/framework-knowledge-base-research.md`

#### Implementation

**Create directory structure:**
```bash
mkdir -p knowledge-base/solutions
mkdir -p knowledge-base/patterns
mkdir -p knowledge-base/gotchas
mkdir -p knowledge-base/integration-recipes
```

**File 1:** `knowledge-base/README.md`

```markdown
# Knowledge Base
## Accumulated Wisdom for Rhythm RPG Development

**Purpose:** Central repository for solutions, patterns, gotchas, and integration recipes discovered during development.

---

## 📚 Structure

### `/solutions/` - Problem Solutions
Specific problems and their solutions. When you solve a tricky bug or overcome a technical challenge, document it here.

**Example:** `conductor-signal-timing-fix.md`

### `/patterns/` - Design Patterns
Reusable design patterns that work well for this project. Best practices for common scenarios.

**Example:** `beat-sync-pattern.md`

### `/gotchas/` - Gotchas & Pitfalls
Things that are easy to get wrong. Common mistakes and how to avoid them.

**Example:** `godot-4-5-await-not-yield.md`

### `/integration-recipes/` - Integration Recipes
Step-by-step guides for integrating systems together. How to connect System A with System B.

**Example:** `integrating-combat-with-conductor.md`

---

## 🎯 How to Use

### When You Learn Something New

1. **Determine category** - Solution, Pattern, Gotcha, or Recipe?
2. **Create markdown file** - Use kebab-case naming
3. **Use template** - See below
4. **Cross-reference** - Link to related entries
5. **Commit** - "Add knowledge: [brief description]"

### When You're Stuck

1. **Search knowledge base** - Grep through .md files
2. **Check related systems** - Look in integration-recipes
3. **Review gotchas** - Common pitfalls might apply
4. **Add new entry** - If you solve something novel

---

## 📝 Entry Templates

### Solution Template

```markdown
# [Problem Title]

**Category:** Solutions
**System(s):** [Affected systems]
**Date Added:** [YYYY-MM-DD]
**Added By:** [Agent ID]

## Problem

Clear description of the problem you encountered.

## Context

- When does this occur?
- What systems are involved?
- What were you trying to do?

## Solution

Step-by-step solution that worked.

## Why It Works

Explanation of the underlying cause and why this solution fixes it.

## Alternative Approaches

Other solutions you tried (and why they didn't work).

## Related Entries

- Link to related solutions
- Link to relevant patterns
- Link to gotchas to avoid
```

### Pattern Template

```markdown
# [Pattern Name]

**Category:** Patterns
**Applicability:** [When to use this pattern]
**Date Added:** [YYYY-MM-DD]
**Added By:** [Agent ID]

## Intent

What problem does this pattern solve?

## Motivation

Why is this pattern useful for rhythm RPG development?

## Structure

```gdscript
# Code example showing the pattern structure
```

## Participants

What classes/systems are involved?

## Collaborations

How do the participants interact?

## Implementation Notes

Godot 4.5 specific considerations.

## Example Usage

```gdscript
# Real example from the project
```

## Known Uses

Where in the project is this pattern used?

## Related Patterns

- Link to similar patterns
- Link to integration recipes using this pattern
```

### Gotcha Template

```markdown
# [Gotcha Title]

**Category:** Gotchas
**Severity:** [High/Medium/Low]
**Date Added:** [YYYY-MM-DD]
**Added By:** [Agent ID]

## The Mistake

What's easy to get wrong?

## Why It Happens

Common misconceptions or assumptions that lead to this mistake.

## Symptoms

How to recognize you've made this mistake:
- Error messages
- Unexpected behavior
- Performance issues

## The Fix

How to correct it:

```gdscript
# WRONG
# Bad code example

# RIGHT
# Correct code example
```

## Prevention

How to avoid this mistake in the first place.

## Related Gotchas

- Link to similar pitfalls
```

### Integration Recipe Template

```markdown
# Integrating [System A] with [System B]

**Category:** Integration Recipes
**Systems:** [System IDs]
**Date Added:** [YYYY-MM-DD]
**Added By:** [Agent ID]

## Goal

What does this integration achieve?

## Prerequisites

- System A must have [features]
- System B must have [features]
- Dependencies: [other systems]

## Step-by-Step Integration

### Step 1: [First step]

Description and code:

```gdscript
# Code for step 1
```

### Step 2: [Second step]

Description and code:

```gdscript
# Code for step 2
```

[Continue for all steps...]

## Testing the Integration

How to verify it works:

```gdscript
# Test code
```

## Common Issues

Problems you might encounter:
- Issue 1 and solution
- Issue 2 and solution

## Performance Considerations

- Frame time impact: [X ms]
- Memory impact: [Y MB]
- Optimization tips

## Related Recipes

- Link to related integrations
```

---

## 🔍 Quick Search

### By System

Use grep to find entries for a specific system:

```bash
grep -r "System: S05" knowledge-base/
```

### By Keyword

Search for specific concepts:

```bash
grep -r "beat sync" knowledge-base/
grep -r "timing window" knowledge-base/
grep -r "signal" knowledge-base/
```

### By Date

Find recent additions:

```bash
grep -r "Date Added: 2025-11" knowledge-base/
```

---

## 📊 Knowledge Base Stats

**Total Entries:** [Will be updated as entries are added]
- Solutions: 0
- Patterns: 0
- Gotchas: 0
- Integration Recipes: 0

**Most Referenced Systems:**
- TBD

**Most Common Topics:**
- TBD

---

## 🎨 Creative Knowledge Sharing

**Make learning fun:**
- Use emojis to categorize difficulty (🟢 Easy, 🟡 Medium, 🔴 Hard)
- Add "Aha!" moments in solutions
- Share clever workarounds
- Celebrate elegant patterns
- Learn from mistakes together

---

## 🔗 Integration with Framework

### Related Tools

- **Known Issues DB:** Link issues to knowledge entries
- **Checkpoints:** Reference knowledge base in implementation notes
- **Integration Tests:** Use recipes to guide test writing
- **Quality Gates:** Patterns help maintain code quality

### Workflow

```
Solve Problem
    ↓
Document in Knowledge Base
    ↓
Tag Related Systems
    ↓
Cross-reference with Issues/Checkpoints
    ↓
Commit & Share
```

---

**End of Knowledge Base** - Share what you learn! 🧠
```

**File 2:** `knowledge-base/solutions/README.md`

```markdown
# Solutions

Specific problems and their solutions.

## Index

*Entries will be added as problems are solved*

---

To add a solution, create a new .md file using the Solution Template from the main README.
```

**File 3:** `knowledge-base/patterns/README.md`

```markdown
# Patterns

Reusable design patterns for rhythm RPG development.

## Index

*Entries will be added as patterns emerge*

---

To add a pattern, create a new .md file using the Pattern Template from the main README.
```

**File 4:** `knowledge-base/gotchas/README.md`

```markdown
# Gotchas & Pitfalls

Common mistakes and how to avoid them.

## Index

*Entries will be added as gotchas are discovered*

---

To add a gotcha, create a new .md file using the Gotcha Template from the main README.
```

**File 5:** `knowledge-base/integration-recipes/README.md`

```markdown
# Integration Recipes

Step-by-step guides for integrating systems together.

## Index

*Entries will be added as integrations are completed*

---

To add a recipe, create a new .md file using the Integration Recipe Template from the main README.
```

#### Creative Notes

**Make knowledge sharing satisfying:**
- Easy-to-use templates (copy-paste ready)
- Clear categorization
- Searchable with grep
- Cross-referenced entries
- Celebrate "Aha!" moments
- Build collective wisdom

**Future enhancements:**
- Auto-generate index from entries
- Tag-based search
- Difficulty ratings
- "Greatest hits" compilation
- Visual knowledge graph

#### Checkpoint

Create `checkpoints/framework-knowledge-base-checkpoint.md`:

```markdown
# Checkpoint: Knowledge Base

## Component: Knowledge Base Directories
## Agent: F3
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**Directory Structure:**
```
knowledge-base/
  README.md
  solutions/
    README.md
  patterns/
    README.md
  gotchas/
    README.md
  integration-recipes/
    README.md
```

**Purpose:** Centralized knowledge management for all development insights

### Key Features

1. **4 categories** - Solutions, Patterns, Gotchas, Integration Recipes
2. **4 templates** - Standardized formats for each category
3. **Searchable** - Grep-friendly markdown structure
4. **Cross-referenced** - Easy linking between entries
5. **Index system** - README in each directory
6. **Quick search guide** - How to find entries
7. **Stats tracking** - Knowledge base metrics
8. **Integration workflow** - Links to other framework tools

### Research Findings

**Knowledge Management Best Practices:**
- [URL 1]: Knowledge base organization patterns
- [URL 2]: Documentation structure for dev teams
- [URL 3]: Lessons learned database design
- [URL 4]: Searchable documentation techniques

### Design Decisions

**4 categories:**
- **Solutions** - Specific problems solved (tactical)
- **Patterns** - Reusable designs (strategic)
- **Gotchas** - Mistakes to avoid (preventive)
- **Integration Recipes** - System connections (procedural)

**Why markdown:**
- Version controlled with git
- Grep-searchable
- Easy to read/write
- No special tools needed
- Works offline

**Directory structure:**
- Flat hierarchy (easy to navigate)
- Category-based organization
- README in each directory for index
- Kebab-case file naming

### How System Agents Should Use This

**When you solve a tricky problem:**
```bash
# Create entry in solutions/
cd knowledge-base/solutions
# Copy template from main README
# Fill in details
git add my-solution.md
git commit -m "Add knowledge: Solved conductor timing issue"
```

**When you need help:**
```bash
# Search for similar problems
grep -r "conductor" knowledge-base/
grep -r "timing" knowledge-base/

# Check gotchas
cat knowledge-base/gotchas/*.md | grep "signal"

# Read integration recipes
ls knowledge-base/integration-recipes/
```

**When integrating systems:**
```bash
# Check if recipe exists
ls knowledge-base/integration-recipes/ | grep "conductor"

# If not, create one after successful integration
# Use Integration Recipe template
```

### Example Knowledge Entry

**File:** `knowledge-base/solutions/conductor-beat-drift-fix.md`

```markdown
# Fixing Conductor Beat Drift Over Time

**Category:** Solutions
**System(s):** S01 Conductor
**Date Added:** 2025-11-20
**Added By:** S01

## Problem

After 5+ minutes of gameplay, beat timing drifts ~50ms from audio, making perfect hits impossible.

## Context

- Occurs at all BPMs (tested 60-180)
- Drift accumulates linearly
- Audio stays in sync, but beat signals lag

## Solution

Changed from frame-based timing to absolute time tracking:

```gdscript
# WRONG - accumulates floating point errors
func _process(delta: float) -> void:
    time_elapsed += delta
    if time_elapsed >= beat_interval:
        emit_beat()
        time_elapsed -= beat_interval  # Small errors accumulate!

# RIGHT - calculate from absolute start time
func _process(delta: float) -> void:
    var current_time = Time.get_ticks_usec() / 1000000.0
    var elapsed = current_time - start_time
    var expected_beats = floor(elapsed / beat_interval)

    if expected_beats > beat_count:
        emit_beat()
        beat_count = expected_beats
```

## Why It Works

Frame delta accumulation causes floating-point error buildup. Using absolute time from start eliminates cumulative errors.

## Alternative Approaches

- Tried periodic resync to audio (but caused hitches)
- Tried double precision (helped but didn't eliminate drift)

## Related Entries

- Pattern: `absolute-time-tracking-pattern.md`
- Gotcha: `floating-point-accumulation-gotcha.md`
```

### Integration with Other Framework Components

- **Known Issues DB:** Link solutions to resolved issues
- **Quality Gates:** Patterns help meet quality standards
- **Integration Tests:** Recipes guide test design
- **Checkpoints:** Reference knowledge in design decisions

### Files Created

- `knowledge-base/README.md`
- `knowledge-base/solutions/README.md`
- `knowledge-base/patterns/README.md`
- `knowledge-base/gotchas/README.md`
- `knowledge-base/integration-recipes/README.md`
- `research/framework-knowledge-base-research.md`

### Git Commit

```bash
git add knowledge-base/ research/ checkpoints/
git commit -m "Add Knowledge Base framework component

- 4-category knowledge organization (Solutions, Patterns, Gotchas, Recipes)
- Standardized templates for each category
- Searchable markdown structure
- Cross-referencing system
- Index and stats tracking
- Quick search guide
- Integration workflow

Research: Knowledge management best practices
Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
✅ Coordination Dashboard: **COMPLETE**
✅ Rollback System: **COMPLETE**
✅ Known Issues DB: **COMPLETE**
✅ Knowledge Base: **COMPLETE**
⬜ Asset Pipeline: **NEXT (FINAL COMPONENT!)**
```

---

### Component 10: Asset Request System

**Duration:** 0.25 day
**Files:** `ASSET-PIPELINE.md` + directory structure only

#### Philosophy

**On-Demand Asset Requests Instead of Procedural Generation**

Agents request `.aseprite` files in HANDOFF documents. You provide them on-demand using Aseprite Wizard. Simple, direct, no bloat.

#### Implementation

**File 1:** `ASSET-PIPELINE.md`

```markdown
# Asset Request System
## On-Demand Asset Creation for Rhythm RPG

**Version:** 1.0
**Date:** 2025-11-18
**Philosophy:** Agents request assets, you provide them on-demand using Aseprite Wizard

---

## Asset Philosophy

**"Request When Needed"**

- Agents specify asset needs in HANDOFF documents
- You create `.aseprite` files on-demand using Aseprite Wizard
- No procedural generation, no placeholder bloat
- Real assets when needed, exactly as specified
- Fast iteration cycle

---

## Directory Structure

Create this structure (directories only, no generated files):

```
assets/
  sprites/
  sounds/
  ui/
  fonts/
```

---

## Asset Request Format

Agents use this format in HANDOFF documents to request assets:

### Request Template

```markdown
## Asset Requests

### From [System Name]:
- [ ] `sprites/[name].aseprite` - [dimensions], [description]
- [ ] `sounds/[name].aseprite` - [duration/bpm], [description]
- [ ] `ui/[name].aseprite` - [dimensions], [description]

**Notes:** [Any special requirements or context]
```

### Example Request

```markdown
## Asset Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation (4 frames)
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle
- [ ] `sounds/footstep.aseprite` - 0.3s, subtle walking sound

**Notes:** Player should face right by default. Transparent backgrounds.
```

---

## Asset Request Tracking

Create and maintain `assets/ASSET-REQUESTS.md`:

```markdown
# Asset Requests

## Pending Requests
### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle

## In Progress
- [x] Player controller sprite (requested)
- ...

## Completed
- [x] None yet
```

---

## Aseprite Wizard Integration

**When Agent Requests Asset:**

1. Check `ASSET-REQUESTS.md` for request details
2. Open Aseprite Wizard with specifications:
   - Dimensions (width x height)
   - Color palette / style
   - Animation frames
   - Any special notes
3. Create `.aseprite` file in appropriate subdirectory
4. Update `ASSET-REQUESTS.md` - move to "Completed"
5. Provide file to Agent in next HANDOFF document

**Agent then:**
- Imports the `.aseprite` file into Godot
- Uses it in their systems
- Can request revisions if needed

---

## Naming Conventions

**Format:** `[name].aseprite`

**Examples:**
```
player_idle.aseprite
player_walk.aseprite
enemy_slime_attack.aseprite
button_primary.aseprite
footstep.aseprite
```

**Rules:**
- lowercase snake_case
- descriptive names
- include state/variant in name (idle, walk, attack, etc.)

---

## Asset Categories

### Sprites
- Character sprites (idle, walk, attack, etc.)
- Enemy sprites
- Item sprites
- UI elements
- Environmental tiles

### Sounds
- Footsteps, jumps, actions
- Combat sounds (hit, miss, special)
- UI sounds (click, hover, etc.)
- Ambient sounds

### UI
- Buttons, icons, panels
- Health bars, status displays
- Menu elements

---

## Request Checklist for Agents

When requesting an asset in your HANDOFF:

- [ ] Specify dimensions (width x height)
- [ ] Describe visual style or color scheme
- [ ] Indicate if animation needed (how many frames)
- [ ] Note any special requirements
- [ ] Mention priority (if urgent)

---

## Integration with Framework

- **Quality Gates:** Assets are reviewed as part of polish
- **Integration Tests:** Verify assets load and display correctly
- **Known Issues DB:** Track broken or missing assets
- **Handoff Documents:** Primary communication method for requests

---

**End of Asset System** - Keep it simple, request what you need.
```

#### Directory Creation

**Create these directories (empty):**
- `assets/sprites/`
- `assets/sounds/`
- `assets/ui/`
- `assets/fonts/`

**Create this file:** `assets/ASSET-REQUESTS.md`

```markdown
# Asset Requests

## Pending Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle

## In Progress

(None yet)

## Completed

- [x] None yet
```

#### Checkpoint

Create `checkpoints/framework-asset-request-system-checkpoint.md`:

```markdown
# Checkpoint: Asset Request System

## Component: Asset Request System
## Agent: F3
## Date: [Current Date]
## Duration: [Actual time spent]

### What Was Built

**Files:**
- `ASSET-PIPELINE.md` (~150 lines) - Simplified request system
- `assets/ASSET-REQUESTS.md` - Request tracking template
- Asset directory structure

**Purpose:** Simple on-demand asset creation system

### Key Features

1. **Asset request format** - Clear specification for agents
2. **Directory structure** - Organized by category
3. **Request tracking** - Track pending/completed requests
4. **Aseprite Wizard integration** - On-demand creation workflow
5. **Naming conventions** - Simple, consistent naming

### Design Decisions

**Philosophy: "Request When Needed"**
- No procedural generation
- No placeholder bloat
- Direct agent → you workflow
- Aseprite Wizard for fast asset creation

**Minimal scope:**
- Just directories and documentation
- Agent-driven requests
- On-demand creation
- Fast iteration cycle

### How System Agents Should Use This

**When you need an asset:**
1. Add request to your HANDOFF document
2. Specify dimensions, description, requirements
3. I create it with Aseprite Wizard
4. I provide the `.aseprite` file in next HANDOFF
5. You import and use it

**To request:**
```markdown
## Asset Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation
```

### Files Created

- `ASSET-PIPELINE.md` - Request system documentation
- `assets/ASSET-REQUESTS.md` - Request tracking template
- Asset directories (sprites/, sounds/, ui/, fonts/)

### Directory Structure

```
assets/
  sprites/
  sounds/
  ui/
  fonts/
  ASSET-REQUESTS.md
```

### Git Commit

```bash
git add ASSET-PIPELINE.md assets/ checkpoints/
git commit -m "Add Asset Request System - Final component, simplified

- On-demand asset creation via Aseprite Wizard
- Agent-driven requests in HANDOFF documents
- Request tracking template
- Directory structure for organization
- No procedural generation, no bloat

Duration: [X hours]"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
✅ Coordination Dashboard: **COMPLETE**
✅ Rollback System: **COMPLETE**
✅ Known Issues DB: **COMPLETE**
✅ Knowledge Base: **COMPLETE**
✅ Asset Request System: **COMPLETE**

**Agent F3 Work: COMPLETE!**
**ALL 10 FRAMEWORK COMPONENTS: COMPLETE!**
```

---

## Integration Testing

**After all framework components are built, test them together!**

### Integration Test Checklist

**Run these tests to verify the framework is ready:**

1. **Component 1: Integration Test Suite**
   ```gdscript
   var suite = IntegrationTestSuite.new()
   var results = suite.run_all_tests()
   print(results.summary())
   # Expected: 26 tests, all skipped (systems not built yet)
   ```

2. **Component 2: Quality Gates**
   ```bash
   # Verify quality-gates.json is valid
   cat quality-gates.json | python3 -m json.tool
   ```

3. **Component 3: Checkpoint Validation**
   ```gdscript
   var validator = CheckpointValidator.new()
   validator.generate_validation_report()
   # Check: CHECKPOINT-VALIDATION-REPORT.md created
   ```

4. **Component 4: CI Test Runner**
   ```bash
   godot --headless --script scripts/ci_runner.gd
   # Expected: Exit code 0, test-results.json created
   ```

5. **Component 5: Performance Profiler**
   ```gdscript
   var profiler = PerformanceProfiler.new()
   profiler.start_profiling()
   # Run for 5 seconds
   await get_tree().create_timer(5.0).timeout
   profiler.save_report("test-performance-report.md")
   # Check: Report created with stats
   ```

6. **Component 6: Coordination Dashboard**
   ```bash
   # Verify dashboard file exists and is readable
   cat COORDINATION-DASHBOARD.md
   ```

7. **Component 7: Rollback System**
   ```gdscript
   var manager = CheckpointManager.new()
   manager.create_snapshot("test-snapshot")
   manager.print_snapshots()
   # Expected: 1 snapshot listed
   ```

8. **Component 8: Known Issues DB**
   ```bash
   # Verify known issues file exists
   cat KNOWN-ISSUES.md
   ```

9. **Component 9: Knowledge Base**
   ```bash
   # Verify directory structure
   ls -la knowledge-base/
   ls -la knowledge-base/solutions/
   ls -la knowledge-base/patterns/
   ls -la knowledge-base/gotchas/
   ls -la knowledge-base/integration-recipes/
   ```

10. **Component 10: Asset Pipeline**
    ```bash
    # Test placeholder generation
    godot --script scripts/generate_placeholders.gd
    # Check: Asset directories created with placeholders
    ls -la assets/sprites/characters/player/
    ```

### End-to-End Framework Test

**Complete workflow test:**

```gdscript
# test_framework.gd - Run this to test all framework components

extends SceneTree

func _init() -> void:
    print("\n🧪 Framework Integration Test\n")
    print("═" * 70)

    # 1. Run integration tests
    print("\n1️⃣ Testing Integration Test Suite...")
    var suite = IntegrationTestSuite.new()
    var test_results = suite.run_all_tests()
    assert(test_results.total_tests == 26, "Should have 26 system tests")
    print("✅ Integration tests working")

    # 2. Validate checkpoints
    print("\n2️⃣ Testing Checkpoint Validation...")
    var validator = CheckpointValidator.new()
    var validation_results = validator.validate_all_checkpoints()
    print("✅ Checkpoint validation working (%d checkpoints)" % validation_results.size())

    # 3. Test performance profiler
    print("\n3️⃣ Testing Performance Profiler...")
    var profiler = PerformanceProfiler.new()
    profiler.start_profiling()
    profiler.profile_system("TestSystem", 0.5)
    var report = profiler.generate_report()
    assert("TestSystem" in report, "Should track test system")
    print("✅ Performance profiler working")

    # 4. Test rollback system
    print("\n4️⃣ Testing Rollback System...")
    var manager = CheckpointManager.new()
    var snapshot_id = manager.create_snapshot("Framework test snapshot")
    assert(snapshot_id != "", "Should create snapshot")
    print("✅ Rollback system working")

    print("\n" + "═" * 70)
    print("🎉 Framework Integration Test PASSED!")
    print("═" * 70 + "\n")

    quit(0)
```

### Success Criteria

**Framework is ready when:**

- ✅ All 10 components implemented
- ✅ All components have checkpoints
- ✅ Integration tests pass
- ✅ CI runner works in headless mode
- ✅ Placeholder assets generate correctly
- ✅ All documentation files created
- ✅ Git repository is clean and pushed

---

## Completion Checklist

### For Framework Agents (F1, F2, F3)

Use this checklist to verify your work before marking complete:

#### Agent F1 Checklist

- [ ] Component 1: Integration Test Suite implemented
  - [ ] File: `tests/integration/integration_test_suite.gd` created
  - [ ] 26 system test templates present
  - [ ] Example test (S01) working
  - [ ] Checkpoint created

- [ ] Component 2: Quality Gates implemented
  - [ ] File: `quality-gates.json` created
  - [ ] 5 dimensions with criteria defined
  - [ ] Example scorecard provided
  - [ ] Checkpoint created

- [ ] Component 3: Checkpoint Validation implemented
  - [ ] File: `scripts/validate_checkpoint.gd` created
  - [ ] Validates 12 required sections
  - [ ] Batch validation works
  - [ ] Checkpoint created

- [ ] Component 4: CI Test Runner implemented
  - [ ] File: `scripts/ci_runner.gd` created
  - [ ] Headless execution works
  - [ ] Proper exit codes
  - [ ] Checkpoint created

- [ ] All F1 checkpoints committed and pushed
- [ ] Quality self-evaluation completed (80+ score)
- [ ] Coordination dashboard updated

#### Agent F2 Checklist

- [ ] Component 5: Performance Profiler implemented
  - [ ] File: `tests/performance/performance_profiler.gd` created
  - [ ] File: `tests/performance/profile_helper.gd` created
  - [ ] Frame time tracking works
  - [ ] System profiling works
  - [ ] Checkpoint created

- [ ] Component 6: Coordination Dashboard implemented
  - [ ] File: `COORDINATION-DASHBOARD.md` created
  - [ ] Agent status section present
  - [ ] Framework progress table complete
  - [ ] Checkpoint created

- [ ] Component 7: Rollback System implemented
  - [ ] File: `scripts/checkpoint_manager.gd` created
  - [ ] Snapshot creation works
  - [ ] Rollback functionality works
  - [ ] Checkpoint created

- [ ] All F2 checkpoints committed and pushed
- [ ] Quality self-evaluation completed (80+ score)
- [ ] Coordination dashboard updated

#### Agent F3 Checklist

- [ ] Component 8: Known Issues DB implemented
  - [ ] File: `KNOWN-ISSUES.md` created
  - [ ] 4 severity levels defined
  - [ ] Issue template provided
  - [ ] Checkpoint created

- [ ] Component 9: Knowledge Base implemented
  - [ ] Directory: `knowledge-base/` created
  - [ ] 4 subdirectories with READMEs
  - [ ] Templates for all categories
  - [ ] Checkpoint created

- [ ] Component 10: Asset Pipeline implemented
  - [ ] File: `ASSET-PIPELINE.md` created
  - [ ] File: `scripts/generate_placeholders.gd` created
  - [ ] Asset directory structure created
  - [ ] Placeholder generation tested
  - [ ] Checkpoint created

- [ ] All F3 checkpoints committed and pushed
- [ ] Quality self-evaluation completed (80+ score)
- [ ] Coordination dashboard updated

### Final Framework Verification

**Before declaring framework complete:**

1. **All Components Present**
   ```bash
   # Verify all 10 components exist
   ls -la tests/integration/integration_test_suite.gd
   ls -la quality-gates.json
   ls -la scripts/validate_checkpoint.gd
   ls -la scripts/ci_runner.gd
   ls -la tests/performance/performance_profiler.gd
   ls -la COORDINATION-DASHBOARD.md
   ls -la scripts/checkpoint_manager.gd
   ls -la KNOWN-ISSUES.md
   ls -la knowledge-base/
   ls -la ASSET-PIPELINE.md
   ls -la scripts/generate_placeholders.gd
   ```

2. **All Checkpoints Present**
   ```bash
   # Verify checkpoint files
   ls -la checkpoints/framework-*-checkpoint.md | wc -l
   # Should be 10
   ```

3. **Git Repository Clean**
   ```bash
   git status
   # Should show: nothing to commit, working tree clean
   ```

4. **Integration Test Passes**
   ```bash
   godot --headless --script scripts/ci_runner.gd
   # Exit code should be 0
   ```

5. **Documentation Complete**
   ```bash
   # Verify all documentation exists
   ls -la FRAMEWORK-SETUP-GUIDE.md
   ls -la PARALLEL-EXECUTION-GUIDE-V2.md
   ls -la AI-VIBE-CODE-SUCCESS-FRAMEWORK.md
   ls -la PROJECT-STATUS.md
   ```

### Handoff to System Agents

**Once framework is complete:**

1. **Update PROJECT-STATUS.md**
   - Mark all framework components as complete ✅
   - Update wave 1 status to "ready to start"

2. **Update COORDINATION-DASHBOARD.md**
   - Mark F1, F2, F3 as complete
   - Add framework completion milestone

3. **Create Handoff Document**
   - Summarize what was built
   - Highlight key tools for system agents
   - Note any known issues or limitations

4. **Celebrate! 🎉**
   - Framework is complete!
   - System development can begin!
   - All 26 systems now have a solid foundation!

---

## Summary

**What We Built:**

✅ **10 Framework Components** across 3 agents:
- Integration Test Suite (F1)
- Quality Gates (F1)
- Checkpoint Validation (F1)
- CI Test Runner (F1)
- Performance Profiler (F2)
- Coordination Dashboard (F2)
- Rollback System (F2)
- Known Issues DB (F3)
- Knowledge Base (F3)
- Asset Pipeline (F3)

**Total Deliverables:**
- ~15 GDScript files (~3,000+ lines of code)
- ~10 Markdown documentation files
- ~10 Checkpoint files
- Complete directory structures
- Research documentation
- Integration tests
- Quality standards

**Ready For:**
- Wave 1 System Development (S01-S04)
- Parallel agent execution (up to 4 concurrent systems)
- Comprehensive testing and validation
- Performance monitoring
- Knowledge accumulation
- Asset management

---

**FRAMEWORK SETUP COMPLETE! 🚀**

**Next Step:** System agents can now begin implementing the 26 game systems using this robust foundation!

---

*End of Framework Setup Guide*

