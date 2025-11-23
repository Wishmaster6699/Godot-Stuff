# Parallel Execution Guide V2 - Rhythm RPG
## Maximum Parallelization Strategy for 29-Prompt Multi-Agent Development

**Version:** 2.0
**Date:** 2025-11-17
**Target:** Godot 4.5.1 | GDScript 4.5 | Two-Tier AI Workflow
**Philosophy:** Research-First, Reusable Patterns, Maximum Parallel Efficiency

---

## Table of Contents

1. [Core Philosophy](#core-philosophy)
2. [Research-First Protocol](#research-first-protocol)
3. [Dependency Analysis & Optimal Wave Structure](#dependency-analysis--optimal-wave-structure)
4. [Two-Tier Workflow Execution](#two-tier-workflow-execution)
5. [Checkpoint Strategy (Dual-Track)](#checkpoint-strategy-dual-track)
6. [HANDOFF Protocol](#handoff-protocol)
7. [Wave-by-Wave Execution Guide](#wave-by-wave-execution-guide)
8. [Integration & Quality Gates](#integration--quality-gates)
9. [Troubleshooting & Rollback](#troubleshooting--rollback)

---

## Core Philosophy

### The Three Pillars

1. **Research Before Implementation**
   - Never reinvent what already exists in the Godot ecosystem
   - Always search for November 2025 resources first
   - **CRITICAL: All documentation MUST be Godot 4.5+ specific**
   - Godot 3.x code is incompatible - verify version before using any code

2. **Learn and Document Everything**
   - Every system is a learning opportunity
   - Create reusable patterns for future agents
   - Document "why" not just "what"
   - Build knowledge-base/ entries for non-trivial solutions

3. **Maximize Parallel Execution**
   - 29 prompts analyzed for true dependency chains
   - Optimal wave structure allows 5-7 agents simultaneously
   - Critical path: 19 days sequential → 12-14 days with parallelization
   - Each wave designed for maximum agent utilization

---

## Research-First Protocol

### FOR ALL AGENTS (BOTH TIERS): Research is NOT Optional

Every system implementation MUST begin with comprehensive research. This is built into the workflow.

### Tier 1 (Claude Code Web) Research Checklist

**BEFORE writing any code, you MUST:**

1. **Search Godot 4.5 Official Documentation**
   ```
   Use WebSearch: "Godot 4.5 [feature name] documentation"
   Use WebFetch: https://docs.godotengine.org/en/4.5/
   ```
   - ✅ Verify: Documentation says "Godot 4.x" or "Godot 4.5"
   - ❌ Reject: Any Godot 3.x documentation (incompatible!)
   - Focus: Classes, signals, built-in methods for your system

2. **Search for Existing Godot 4.5 Projects**
   ```
   Use WebSearch: "Godot 4.5 [system type] example github November 2025"
   Examples:
   - "Godot 4.5 rhythm game conductor github"
   - "Godot 4.5 turn-based combat system"
   - "Godot 4.5 inventory system gloot"
   ```
   - Look for: Recent repos (2024-2025), Godot 4.x compatibility
   - Extract: Architecture patterns, signal usage, autoload strategies

3. **Search for Godot 4.5 Plugins/Addons**
   ```
   Use WebSearch: "Godot 4.5 [feature] plugin asset library 2025"
   Use WebFetch: https://godotengine.org/asset-library/asset?filter=4.5
   ```
   - Priority: Officially maintained plugins (RhythmNotifier, GLoot, LimboAI, etc.)
   - Verify: Plugin is Godot 4.5 compatible
   - Document: In HANDOFF.md if plugin should be integrated

4. **Search for GDScript 4.5 Best Practices**
   ```
   Use WebSearch: "GDScript 4.5 best practices 2025"
   Use WebSearch: "Godot 4.5 [pattern] tutorial"
   ```
   - Focus: Type hints, signal patterns, autoload usage
   - Learn: Modern GDScript 2.0 syntax (not GDScript 1.0!)

5. **Document Research Findings**
   - Create `research/[system-id]-research.md` (use Write tool)
   - Include: URLs, key insights, code patterns discovered
   - Add to knowledge-base/ if reusable pattern found
   - Reference in HANDOFF.md for Tier 2 agent

### Tier 2 (Godot MCP Agent) Research Checklist

**BEFORE configuring scenes, you MUST:**

1. **Search Godot 4.5 Scene Architecture**
   ```
   Use WebSearch: "Godot 4.5 [scene type] best practices"
   Examples:
   - "Godot 4.5 UI scene structure"
   - "Godot 4.5 CharacterBody2D setup"
   - "Godot 4.5 autoload singleton pattern"
   ```

2. **Search for Godot 4.5 Node Configurations**
   ```
   Use WebSearch: "Godot 4.5 [node type] properties tutorial"
   ```
   - Learn: Property names (changed from Godot 3.x!)
   - Understand: Signal connections, node paths

3. **Search for Testing Patterns**
   ```
   Use WebSearch: "Godot 4.5 testing strategies 2025"
   Use WebSearch: "Godot 4.5 integration tests"
   ```

4. **Save Research to Basic Memory MCP**
   ```
   Save checkpoint: "system-[id]-research-findings"
   Include: URLs, patterns discovered, gotchas encountered
   ```

### Research Time Budget

**Expected research time per system:**
- Foundation systems (S01-S04): 30-45 minutes research
- Standard systems (S05-S20): 20-30 minutes research
- Content systems (S21-S26): 15-20 minutes research
- **Total research time across 26 systems: ~10-12 hours**

**This is time well spent** - research prevents:
- Reinventing existing solutions
- Using outdated Godot 3.x patterns
- Architectural mistakes requiring refactoring
- Missing official plugins that solve 80% of the problem

---

## Dependency Analysis & Optimal Wave Structure

### Complete Dependency Map (All 29 Prompts)

Based on comprehensive analysis of all `<dependencies>` sections:

#### Wave 0: Foundation Documentation (Job 1)
**Start:** Immediately
**Duration:** 2 days
**Agents:** 2 parallel

| Prompt | System | Dependencies | Blocks |
|--------|--------|--------------|--------|
| 001 | Foundation Docs | NONE | All systems (reference material) |
| 002 | Combat Spec | NONE | Combat systems (design doc) |

**Parallelization:** Both can run simultaneously
**Critical:** Complete BEFORE any code implementation begins

---

#### Wave 1: Core Foundation Systems (Job 2 - Part 1)
**Start:** After Wave 0
**Duration:** 2 days
**Agents:** 2 parallel

| Prompt | System | Dependencies | Blocks |
|--------|--------|--------------|--------|
| 003 | S01 Conductor | 001 | S04, S09, S10, S16, S18, S26 (7 systems!) |
| 004 | S02 Input | 001 | S03, S04, S09, S10, S14, S16 (6 systems!) |

**Parallelization:** Both can run simultaneously after 001 complete
**Critical Path Alert:** These are the highest-blocking systems

---

#### Wave 2: Player Foundation (Job 2 - Part 2)
**Start:** After Wave 1 complete
**Duration:** 1.5 days
**Agents:** 1

| Prompt | System | Dependencies | Blocks |
|--------|--------|--------------|--------|
| 005 | S03 Player | S02 | S04, S05, S14, S15, S16, S17 (6 systems!) |

**Parallelization:** Sequential (only 1 system)
**Critical Path Alert:** S03 is foundation for most gameplay systems

---

#### Wave 3: Combat Prototype (Job 2 - Part 3)
**Start:** After Wave 2 complete
**Duration:** 2 days
**Agents:** 1

| Prompt | System | Dependencies | Blocks |
|--------|--------|--------------|--------|
| 006 | S04 Combat | S01, S02, S03 | **15+ systems!** (Biggest blocker) |

**Parallelization:** Sequential (only 1 system)
**CRITICAL PATH BOTTLENECK:** This system blocks the most downstream work
**Strategy:** Prioritize quality - all future systems depend on this

---

#### Wave 4: Data Systems + Independent Features (Job 2 - Part 4)
**Start:** After Wave 3 complete
**Duration:** 3-4 days
**Agents:** 6 parallel (MAXIMUM PARALLELIZATION OPPORTUNITY!)

| Prompt | System | Dependencies | Can Start After | Notes |
|--------|--------|--------------|-----------------|-------|
| 007 | S05 Inventory | S03 | S03 ✓ | Blocks S06, S08, S24, S25 |
| 013 | S11 Enemy AI | S04 | S04 ✓ | Blocks S12 |
| 015 | S13 Vibe Bar | S04 | S04 ✓ | Visual polish, independent |
| 016 | S14 Tools | S03 | S03 ✓ | Blocks S17 |
| 017 | S15 Vehicles | S03 | S03 ✓ | Independent system |
| 018 | S16 Grind Rails | S01, S03 | S01 ✓, S03 ✓ | Independent system |
| 020 | S18 Polyrhythm | S01 | S01 ✓ | Independent system |

**Parallelization:** Up to 7 systems can run simultaneously!
**Optimization:** Assign fastest agents to systems that block others (007, 013, 016)

---

#### Wave 5: Equipment & Monster Database (Job 2 - Part 5)
**Start:** After Wave 4 systems complete (staggered starts)
**Duration:** 4 days
**Agents:** 4 parallel

| Prompt | System | Dependencies | Can Start After | Notes |
|--------|--------|--------------|-----------------|-------|
| 008 | S06 Save/Load | S03, S05 | S05 ✓ | All systems must integrate |
| 009 | S07 Weapons | S04, S05 | S04 ✓, S05 ✓ | Blocks S08, S10, S25 |
| 010 | S08 Equipment | S05, S07 | S07 ✓ | Blocks S09, S25 |
| 014 | S12 Monster DB | S04, S11 | S11 ✓ | 100+ monsters, blocks S20 |

**Parallelization:** 4 systems, some staggered starts
**Note:** S08 completes Job 2 (Foundation complete!)

---

#### Wave 6: Combat Depth (Job 3 - Part 1)
**Start:** After Wave 5 complete
**Duration:** 2 days
**Agents:** 2 parallel

| Prompt | System | Dependencies | Can Start After | Notes |
|--------|--------|--------------|-----------------|-------|
| 011 | S09 Dodge/Block | S01, S04, S08 | S08 ✓ | Blocks S10 |
| 019 | S17 Puzzles | S03, S14 | S14 ✓ | Blocks S19 |

**Parallelization:** 2 systems simultaneously

---

#### Wave 7: Special Moves + Content Systems (Job 3 - Part 2)
**Start:** After Wave 6 complete
**Duration:** 3 days
**Agents:** 4 parallel

| Prompt | System | Dependencies | Can Start After | Notes |
|--------|--------|--------------|-----------------|-------|
| 012 | S10 Special Moves | S01, S04, S07, S09 | S09 ✓ | Final combat system |
| 026 | S24 Cooking | S05, S12 | S12 ✓ | Independent content |
| 027 | S25 Crafting | S08, S12, S07 | S08 ✓, S12 ✓, S07 ✓ | Independent content |
| 028 | S26 Rhythm Mini | S01, S04 | S01 ✓, S04 ✓ | Independent content |

**Parallelization:** 4 systems simultaneously
**Job 3 Complete:** All combat and environment systems done!

---

#### Wave 8: Progression Systems (Job 4 - Part 1)
**Start:** After Wave 7 complete
**Duration:** 3 days
**Agents:** 3 parallel

| Prompt | System | Dependencies | Can Start After | Notes |
|--------|--------|--------------|-----------------|-------|
| 021 | S19 Dual XP | S04, S17 | S17 ✓ | Blocks S20 |
| 022 | S20 Evolution | S12, S04, S19 | S19 ✓ | Independent |
| 023 | S21 Alignment | S04, S12, S11 | S12 ✓, S11 ✓ | Blocks S22 |

**Parallelization:** S19 first, then S20 and S21 can run in parallel

---

#### Wave 9: Story & NPCs (Job 4 - Part 2)
**Start:** After Wave 8 complete
**Duration:** 4 days
**Agents:** 2 sequential

| Prompt | System | Dependencies | Can Start After | Notes |
|--------|--------|--------------|-----------------|-------|
| 024 | S22 NPCs | S21, S03, S04 | S21 ✓ | Blocks S23 |
| 025 | S23 Story | S22, S21, S04 | S22 ✓ | Final narrative system |

**Parallelization:** SEQUENTIAL - S22 must complete before S23
**Critical:** Story systems require completed world state

---

#### Wave 10: Meta-Documentation (Job 4 - Part 3)
**Start:** After all 26 systems defined
**Duration:** 1 day
**Agents:** 1

| Prompt | System | Dependencies | Notes |
|--------|--------|--------------|-------|
| 029 | Parallel Build Strategy | All 26 system specs | Meta-coordination document |

**Purpose:** Final orchestration documentation

---

### Execution Timeline Summary

**Optimal Parallelization (with 5-7 agents):**

| Wave | Days | Systems | Max Agents | Cumulative Days |
|------|------|---------|------------|-----------------|
| 0 | 2 | 2 | 2 | 2 |
| 1 | 2 | 2 | 2 | 4 |
| 2 | 1.5 | 1 | 1 | 5.5 |
| 3 | 2 | 1 | 1 | 7.5 |
| 4 | 3 | 7 | 7 | 10.5 |
| 5 | 4 | 4 | 4 | 14.5 |
| 6 | 2 | 2 | 2 | 16.5 |
| 7 | 3 | 4 | 4 | 19.5 |
| 8 | 3 | 3 | 3 | 22.5 |
| 9 | 4 | 2 | 1-2 | 26.5 |
| 10 | 1 | 1 | 1 | 27.5 |

**Total Project Duration: ~27-28 days with optimal parallelization**

**Critical Path (Sequential): ~38 days**
**Parallelization Savings: ~10-11 days (28% faster)**

---

## Two-Tier Workflow Execution

### Understanding the Two-Tier Split

#### Tier 1: Claude Code Web (File Creation Phase)

**Who:** Claude Code running in web browser
**What:** Creates all code files and documentation
**Cannot Access:** Godot MCP, Basic Memory MCP, Godot Editor

**Tools Available:**
- ✅ Read, Write, Edit (file operations)
- ✅ Grep, Glob (search)
- ✅ Bash (git operations)
- ✅ WebSearch, WebFetch (research)
- ❌ NO Godot MCP/GDAI tools
- ❌ NO Basic Memory MCP
- ❌ NO Godot editor

**Deliverables:**
1. All `.gd` (GDScript) files with complete implementations
2. All `.json` data files with complete schemas
3. `HANDOFF-[system-id].md` with scene configuration instructions
4. `research/[system-id]-research.md` with findings
5. Git commit + push to execution branch

#### Tier 2: Godot MCP Agent (Scene Configuration Phase)

**Who:** Claude with Godot MCP server running locally
**What:** Configures scenes, tests in Godot, runs quality gates
**Has Access To:** Everything (full GDAI toolset + editor)

**Tools Available:**
- ✅ All GDAI MCP tools (create_scene, add_node, attach_script, update_property, etc.)
- ✅ Godot editor (play_scene, get_godot_errors, get_editor_screenshot)
- ✅ Basic Memory MCP (checkpoint saving)
- ✅ File operations (Read, Write, Edit, get_filesystem_tree, search_files)
- ✅ Bash (git operations)

**Deliverables:**
1. All `.tscn` scene files configured
2. Autoloads registered in project.godot
3. Integration tests passing
4. Performance profiling complete
5. Checkpoint saved to Basic Memory MCP
6. Knowledge base entry (if non-trivial solution)
7. Git commit + push to execution branch

---

### Tier 1 Execution Protocol (Claude Code Web)

**Step-by-Step Workflow:**

#### 1. Pre-Implementation Research (30-45 min)

```markdown
# Research Checklist for [System Name]

## Godot 4.5 Official Documentation
- [ ] Search: "Godot 4.5 [feature] documentation"
- [ ] Read: Official docs for relevant nodes/classes
- [ ] Verify: Documentation is 4.5+, NOT 3.x
- [ ] Document: Key classes, signals, methods

## Existing Godot 4.5 Projects
- [ ] Search: "Godot 4.5 [system type] github 2025"
- [ ] Review: 2-3 recent examples
- [ ] Extract: Architecture patterns, best practices
- [ ] Document: URLs and key insights

## Godot 4.5 Plugins/Addons
- [ ] Search: Asset Library for relevant plugins
- [ ] Check: Compatibility with Godot 4.5
- [ ] Document: Which plugins to use (if any)

## GDScript 4.5 Patterns
- [ ] Search: "GDScript 4.5 [pattern] best practices"
- [ ] Learn: Modern GDScript 2.0 syntax
- [ ] Document: Code patterns to follow

## Save Research
- [ ] Create: research/[system-id]-research.md
- [ ] Include: All URLs, insights, code snippets
- [ ] Add to knowledge-base/ if reusable pattern
```

#### 2. Read Prompt & Dependencies

```bash
# Use Read tool
Read prompts/[prompt-number].md

# Check dependencies section
# Verify all upstream systems are complete
# Check COORDINATION-DASHBOARD.md for status
```

#### 3. Claim Work & Lock Resources

```bash
# Use Edit tool on COORDINATION-DASHBOARD.md
# Add your agent ID, system ID, status: IN_PROGRESS
# Lock any shared resources (files, systems)
```

#### 3.5. 🚨 FILE ISOLATION RULES (CRITICAL!)

**To enable parallel development without merge conflicts, you MUST follow strict file isolation rules.**

See `GIT-WORKFLOW.md` for complete details. Quick summary:

**✅ YOU MAY MODIFY:**
- `src/systems/s{##}-{your-system}/` - Your system directory ONLY
- `scenes/s{##}-{your-system}/` - Your scene files
- `assets/` - System-specific subdirectories
- `checkpoints/` - Your checkpoint files
- `research/` - Your research files
- `knowledge-base/` - Add new entries (atomic operations)
- `KNOWN-ISSUES.md` - Add issues (append-only, atomic)

**❌ YOU MUST NOT MODIFY:**
- `src/systems/s{other-##}-*/` - Other systems' directories
- `src/core/` - Shared core files (developer only)
- `project.godot` - Godot project settings (Tier 2 only, coordinated)
- Other agents' checkpoints or research

**🚨 IF YOU NEED TO MODIFY A SHARED FILE:**
1. STOP immediately
2. Post in COORDINATION-DASHBOARD.md requesting permission
3. Wait for developer approval
4. Developer makes the change OR grants explicit permission

**Directory Structure for Your System:**
```
src/
  systems/
    s{##}-{your-system}/
      {system}_manager.gd       ← Your main system script
      {feature}_controller.gd   ← Additional scripts
      {system}_data.json        ← System data
      [...other files...]

scenes/
  s{##}-{your-system}/
    {system}_scene.tscn         ← Created by Tier 2
    [...other scenes...]

checkpoints/
  s{##}-{your-system}-checkpoint.md  ← Your checkpoint

research/
  s{##}-{your-system}-research.md    ← Your research
```

**Example for S05 (Inventory):**
```
src/systems/s05-inventory/
  inventory_manager.gd
  item_controller.gd
  inventory_data.json
scenes/s05-inventory/
  inventory_ui.tscn
checkpoints/
  s05-inventory-checkpoint.md
research/
  s05-inventory-research.md
```

**Verification Before Commit:**
```bash
# Show what files you modified
git status

# ✅ GOOD - All files in your system directory
modified:   src/systems/s05-inventory/inventory_manager.gd
modified:   src/systems/s05-inventory/inventory_data.json

# ❌ BAD - Modified other systems or core files!
modified:   src/systems/s03-player/player_controller.gd  # VIOLATION!
modified:   src/core/game_manager.gd  # VIOLATION!

# If you see violations:
git checkout main -- src/systems/s03-player/  # Revert unauthorized changes
# Only commit your system's files
```

#### 4. Create All Code Files

**For each .gd file:**
```gdscript
# ALWAYS include at top of file:
# Godot 4.5 | GDScript 4.5
# System: [System ID] - [System Name]
# Created: [Date]
# Dependencies: [List]

# Use modern GDScript 2.0 syntax:
extends Node  # Godot 4.x base classes

# Type hints are REQUIRED
var health: int = 100
var player: CharacterBody2D  # Not KinematicBody2D (Godot 3.x!)

# Signals use typed parameters
signal health_changed(new_health: int, old_health: int)

# Functions use typed parameters and return types
func take_damage(amount: int) -> void:
    var old_health := health
    health -= amount
    health_changed.emit(health, old_health)
```

**Critical Godot 4.5 Differences:**
- `KinematicBody2D` → `CharacterBody2D`
- `move_and_slide(velocity)` → `move_and_slide()` (velocity is property)
- `yield()` → `await`
- `onready` → `@onready`
- `export` → `@export`
- Signals use `.emit()` not manual emission

#### 5. Create All Data Files

**For each .json file:**
```json
{
  "_schema_version": "1.0",
  "_godot_version": "4.5",
  "_system_id": "S01",
  "_created": "2025-11-17",

  "your_data_here": {
    "example": "value"
  }
}
```

#### 6. Create HANDOFF.md (Critical!)

See [HANDOFF Protocol](#handoff-protocol) section below for complete template.

#### 7. Update Progress & Commit

```bash
# Update COORDINATION-DASHBOARD.md at 25%, 50%, 75%, 100%
# Use Edit tool

# Validate all files
# Check GDScript syntax
# Check JSON validity

# Commit
git add res/ research/ HANDOFF-*.md
git commit -m "Complete [System Name] - Tier 1

Implemented:
- [List all .gd files]
- [List all .json files]
- HANDOFF-[system-id].md

Research:
- [Key findings from research phase]

Ready for Tier 2: Scene configuration and testing"

# Push
git push -u origin claude/execute-wave[X]-agent-[id]
```

---

### Tier 2 Execution Protocol (Godot MCP Agent)

**Step-by-Step Workflow:**

#### 1. Read HANDOFF & Verify Files

```bash
# Use Read tool
Read HANDOFF-[system-id].md
Read research/[system-id]-research.md

# Verify all Tier 1 files exist
# Use get_filesystem_tree to check
```

#### 2. Pre-Configuration Research (15-20 min)

```markdown
# Tier 2 Research Checklist

## Scene Architecture
- [ ] Search: "Godot 4.5 [scene type] structure tutorial"
- [ ] Learn: Best practices for node hierarchies

## Node Properties
- [ ] Search: "Godot 4.5 [node type] properties"
- [ ] Verify: Property names (changed from Godot 3.x)

## Testing Strategies
- [ ] Search: "Godot 4.5 integration testing"
- [ ] Plan: How to test this system
```

#### 3. Create Scenes Using GDAI Tools

```python
# Example scene creation workflow

# 1. Create scene with root node
create_scene("res://scenes/player.tscn", "CharacterBody2D")

# 2. Add child nodes
add_node("res://scenes/player.tscn", "Sprite2D", "PlayerSprite")
add_node("res://scenes/player.tscn", "CollisionShape2D", "Collision")
add_node("res://scenes/player.tscn", "Camera2D", "Camera")

# 3. Attach scripts
attach_script("res://scenes/player.tscn", "CharacterBody2D", "res://player/player.gd")

# 4. Configure properties
update_property("res://scenes/player.tscn", "PlayerSprite", "texture", "res://assets/player.png")
update_property("res://scenes/player.tscn", "Camera", "enabled", true)

# 5. Register autoload (if needed)
# This is done via project.godot or Godot MCP commands
```

#### 4. Test in Godot Editor

```python
# Run test scene
play_scene("res://tests/test_[system].tscn")

# Check for errors
errors = get_godot_errors()
if errors:
    # Fix issues
    # Re-test

# Get screenshots
screenshot = get_editor_screenshot()
# Visual verification
```

#### 5. Run Quality Gates

```python
# In Godot, run:
# IntegrationTestSuite.run_all_tests()
# PerformanceProfiler.profile_system("S01")
# check_quality_gates("S01")
# validate_checkpoint("S01")

# All must pass before marking complete
```

#### 6. Save Checkpoints (Dual-Track)

**A. Markdown Checkpoint (use Write tool):**
```bash
# Create checkpoints/[system-id]-checkpoint.md

## System: [System ID] - [System Name]
## Completed: [Date]
## Agent: [Agent ID]

### Files Created
- res://autoloads/conductor.gd
- res://data/rhythm_config.json
- res://scenes/rhythm_debug.tscn

### Integration Points
- Registered as autoload: Conductor
- Signals: beat, downbeat, measure
- Dependencies: None (foundation system)

### Testing Results
- All integration tests: PASS
- Performance: 0.01ms per frame
- Quality gates: PASS (5/5)

### Known Issues
- None

### Research Insights
- Used RhythmNotifier plugin (Godot 4.5 compatible)
- Signal pattern from [URL]

### Next Steps for Dependent Systems
- S04 Combat can now listen to beat signals
- S09 Dodge needs to sync with downbeat
```

**B. Basic Memory MCP Checkpoint (Tier 2 only):**
```python
# Save to Basic Memory MCP
save_to_memory(
    "system_S01_conductor_complete",
    {
        "system_id": "S01",
        "status": "complete",
        "files": ["conductor.gd", "rhythm_config.json"],
        "autoload": "Conductor",
        "signals": ["beat", "downbeat", "measure"],
        "integration_points": "Foundation rhythm system",
        "testing": "All tests pass",
        "performance": "0.01ms/frame",
        "dependencies_unblocked": ["S04", "S09", "S10", "S16", "S18", "S26"]
    }
)
```

#### 7. Create Knowledge Base Entry (if applicable)

```bash
# If you solved a non-trivial problem, create:
# knowledge-base/solutions/[system-id]-[problem-name].md

## Problem
[Describe the problem]

## Solution
[Describe your solution]

## Why This Works
[Explain the reasoning]

## Godot 4.5 Specifics
[Note any version-specific details]

## Reusable Pattern
[Can other systems use this?]

## References
[URLs to documentation, examples]
```

#### 8. Update Coordination & Commit

```bash
# Update COORDINATION-DASHBOARD.md
# Mark complete, release locks, unblock dependencies

# Commit
git add res/ checkpoints/ knowledge-base/
git commit -m "Complete [System Name] - Tier 2

Scene Configuration:
- [List all .tscn files]
- Autoloads registered
- Properties configured

Testing:
- Integration tests: PASS
- Performance: [metrics]
- Quality gates: PASS

Checkpoints:
- Markdown: checkpoints/[system-id]-checkpoint.md
- Memory MCP: system_[system-id]_complete

Unblocked systems: [List dependent systems]"

# Push
git push
```

---

## Checkpoint Strategy (Dual-Track)

### Why Dual Checkpoints?

1. **Markdown Files** (.md) - Both tiers can create
   - Human-readable
   - Version controlled in git
   - Searchable with Grep
   - Persistent across sessions
   - Work even if MCP unavailable

2. **Basic Memory MCP** - Tier 2 only
   - Structured data
   - Fast retrieval
   - Cross-session memory for MCP agents
   - Can be queried programmatically

### Checkpoint Types

#### 1. Research Checkpoint (Tier 1)

**File:** `research/[system-id]-research.md`

```markdown
# Research: [System ID] - [System Name]
**Agent:** [Agent ID]
**Date:** [Date]
**Duration:** [Time spent researching]

## Godot 4.5 Documentation
- [URL 1]: [Key insight]
- [URL 2]: [Key insight]

## Existing Projects
- [GitHub URL]: [What we learned]
- [Example URL]: [Architecture pattern]

## Plugins/Addons
- [Plugin name]: [Why we're using it / why not]

## Code Patterns
```gdscript
# Example pattern discovered
[Code snippet]
```

## Key Decisions
- Decision 1: [Why]
- Decision 2: [Why]

## Gotchas for Tier 2
- [Thing to watch out for]
```

**When:** After research phase, before implementation

#### 2. Implementation Checkpoint (Tier 1)

**File:** `HANDOFF-[system-id].md` (see HANDOFF Protocol section)

**When:** After all code files created, before Tier 2

#### 3. Completion Checkpoint (Tier 2)

**File:** `checkpoints/[system-id]-checkpoint.md`

**When:** After testing complete, all quality gates pass

#### 4. Memory MCP Checkpoint (Tier 2 only)

**When:** Same time as markdown checkpoint

**Format:**
```python
save_to_memory(
    f"system_{system_id}_complete",
    {
        "system_id": system_id,
        "status": "complete",
        "files": [list],
        "scenes": [list],
        "autoloads": [list],
        "signals": [list],
        "integration_points": "description",
        "testing_results": "summary",
        "performance_metrics": "metrics",
        "dependencies_unblocked": [list of system IDs],
        "known_issues": [list],
        "next_steps": "guidance"
    }
)
```

### Checkpoint Retrieval

**Tier 1 agents:**
```bash
# Use Grep to search research and checkpoints
Grep pattern="Conductor" path="research/"
Grep pattern="S01" path="checkpoints/"

# Use Read to view specific checkpoints
Read research/S01-research.md
Read checkpoints/S01-checkpoint.md
```

**Tier 2 agents:**
```python
# Query Basic Memory MCP
checkpoint = retrieve_from_memory("system_S01_conductor_complete")

# Also read markdown files
Read checkpoints/S01-checkpoint.md
```

---

## HANDOFF Protocol

### Purpose of HANDOFF.md

The HANDOFF file is the **contract** between Tier 1 and Tier 2. It must contain:
- Explicit scene configuration instructions
- Exact GDAI MCP commands to run
- Node hierarchies to build
- Property values to set
- Integration notes and gotchas
- Testing checklist

### HANDOFF Template

**File:** `HANDOFF-[system-id].md`

```markdown
# HANDOFF: [System ID] - [System Name]
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** [Date]
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** [1-2 sentence description]
**Type:** [Autoload / Scene / Component]
**Dependencies:** [List systems this integrates with]

---

## Files Created by Tier 1

### GDScript Files
- ✅ `res://autoloads/conductor.gd` - Main rhythm conductor singleton
- ✅ `res://autoloads/rhythm_notifier.gd` - Beat notification system

### JSON Data Files
- ✅ `res://data/rhythm_config.json` - Timing windows, BPM settings

### Test Files
- ✅ `res://tests/test_conductor.gd` - Unit tests (not scene yet)

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Register Autoloads

**Manual step required:**
Open `project.godot` and add (or use GDAI autoload registration if available):

```ini
[autoload]
Conductor="*res://autoloads/conductor.gd"
RhythmNotifier="*res://autoloads/rhythm_notifier.gd"
```

### Step 2: Create Test Scene

```python
# Create test scene
create_scene("res://tests/test_conductor.tscn", "Node2D")

# Add UI elements for debugging
add_node("res://tests/test_conductor.tscn", "Label", "BPMLabel")
add_node("res://tests/test_conductor.tscn", "Label", "BeatLabel")
add_node("res://tests/test_conductor.tscn", "ColorRect", "BeatFlash")

# Position UI elements
update_property("res://tests/test_conductor.tscn", "BPMLabel", "position", Vector2(10, 10))
update_property("res://tests/test_conductor.tscn", "BPMLabel", "text", "BPM: 120")

update_property("res://tests/test_conductor.tscn", "BeatLabel", "position", Vector2(10, 40))
update_property("res://tests/test_conductor.tscn", "BeatLabel", "text", "Beat: 0")

update_property("res://tests/test_conductor.tscn", "BeatFlash", "position", Vector2(100, 100))
update_property("res://tests/test_conductor.tscn", "BeatFlash", "size", Vector2(50, 50))
update_property("res://tests/test_conductor.tscn", "BeatFlash", "color", Color(1, 1, 0, 0.5))

# Attach test script
attach_script("res://tests/test_conductor.tscn", "Node2D", "res://tests/test_conductor.gd")
```

### Step 3: Create Debug Overlay (Optional)

```python
# Create debug overlay scene
create_scene("res://debug/rhythm_debug_overlay.tscn", "CanvasLayer")

# Add visualization nodes
add_node("res://debug/rhythm_debug_overlay.tscn", "Panel", "DebugPanel")
add_node("res://debug/rhythm_debug_overlay.tscn", "VBoxContainer", "InfoContainer")

# Configure panel
update_property("res://debug/rhythm_debug_overlay.tscn", "DebugPanel", "position", Vector2(10, 10))
update_property("res://debug/rhythm_debug_overlay.tscn", "DebugPanel", "size", Vector2(300, 200))
```

---

## Node Hierarchies

### Test Scene Structure
```
Node2D (test_conductor.tscn)
├── Label (BPMLabel)
├── Label (BeatLabel)
├── ColorRect (BeatFlash)
└── [Script: test_conductor.gd]
```

### Debug Overlay Structure
```
CanvasLayer (rhythm_debug_overlay.tscn)
└── Panel (DebugPanel)
    └── VBoxContainer (InfoContainer)
        ├── Label (BPM)
        ├── Label (CurrentBeat)
        └── Label (TimingOffset)
```

---

## Property Configurations

### Critical Properties

**Conductor (autoload):**
- `bpm`: 120 (default, loaded from JSON)
- `time_signature`: [4, 4]
- `latency_compensation_ms`: 50

**Test Scene Labels:**
- Font size: 16px (Godot 4.5 default)
- Theme: Default

**BeatFlash ColorRect:**
- Modulate: Animate alpha on beat signal
- Color: Yellow with 50% alpha

---

## Signal Connections

**The MCP agent should connect these signals in test scene:**

```gdscript
# In test_conductor.gd
func _ready():
    Conductor.beat.connect(_on_beat)
    Conductor.downbeat.connect(_on_downbeat)
    Conductor.measure.connect(_on_measure)

func _on_beat(beat_number: int):
    $BeatLabel.text = "Beat: %d" % beat_number
    # Flash animation

func _on_downbeat(measure_number: int):
    # Stronger flash on downbeat
    pass

func _on_measure(measure_number: int):
    # Update measure counter
    pass
```

**Note:** Code above is reference - actual script created by Tier 1 in `res://tests/test_conductor.gd`

---

## Integration Notes

### How Other Systems Should Use This

**Combat System (S04):**
```gdscript
# In combat scripts
func _ready():
    Conductor.beat.connect(_on_combat_beat)

func _on_combat_beat(beat_num: int):
    # Check if player action aligned with beat
    evaluate_rhythm_timing()
```

**Dodge/Block System (S09):**
```gdscript
# Perfect dodge = within timing window of beat
func _ready():
    Conductor.beat.connect(_check_dodge_timing)
```

### Plugin Integration

**RhythmNotifier Plugin:**
- Installed from: [GitHub URL or Asset Library]
- Version: 1.x (Godot 4.5 compatible)
- Documentation: [URL]
- Configuration: res://addons/rhythm_notifier/config.cfg

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

- [ ] Autoloads registered and accessible globally
- [ ] Test scene runs without errors: `play_scene("res://tests/test_conductor.tscn")`
- [ ] Beat signal emits every second at 60 BPM
- [ ] Downbeat signal emits every 4 beats
- [ ] Timing accuracy: ±10ms variance
- [ ] No audio drift over 5-minute test
- [ ] BPM changes work: Test 60, 120, 180 BPM
- [ ] Latency compensation works: Test with 0ms, 50ms, 100ms
- [ ] Debug overlay shows real-time BPM and beat count
- [ ] Integration tests pass: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S01")`
- [ ] Quality gates pass: `check_quality_gates("S01")`

**Expected Results:**
- Integration tests: 12/12 PASS
- Performance: <0.01ms per frame overhead
- Quality score: 95/100 (passing threshold: 80)

---

## Gotchas & Known Issues

**Godot 4.5 Specific:**
- Timer nodes use `timeout` signal (same as 3.x)
- AudioStreamPlayer has different property names than 3.x
- Use `Time.get_ticks_msec()` not `OS.get_ticks_msec()`

**System-Specific:**
- Latency compensation must be calibrated per-device
- Beat drift can occur if BPM changes mid-playback
- Thread safety: Conductor runs on main thread only

**Integration Warnings:**
- Systems listening to beat signal must disconnect on scene exit
- Changing BPM mid-game requires re-sync of all listeners
- Save/Load system must save current beat/measure state

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 Timer docs: [URL]
- Rhythm game architecture: [GitHub URL]
- RhythmNotifier plugin: [Asset Library URL]
- Beat detection algorithms: [Tutorial URL]

**Full research notes:** `research/S01-research.md`

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running (`get_editor_screenshot()`)
2. Error log output (`get_godot_errors()`) - should be empty
3. Performance profiler output
4. Integration test results

**Save to:** `evidence/S01-tier2-verification/`

---

## Completion Criteria

**System S01 is complete when:**
- ✅ All autoloads registered
- ✅ Test scene runs without errors
- ✅ All tests pass (unit + integration)
- ✅ Performance meets targets (<0.01ms/frame)
- ✅ Quality gates pass (score ≥80)
- ✅ Documentation complete (checkpoint.md)
- ✅ Unblocked systems notified: S04, S09, S10, S16, S18, S26

**Next Steps:**
- S04 Combat can begin implementation
- S09 Dodge/Block can access beat timing
- All rhythm-dependent systems can proceed

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 2-3 hours (scene config + testing)
**Priority:** HIGH (blocks 7 systems)

---

*Generated by: Claude Code Web Agent [Agent ID]*
*Date: 2025-11-17*
*Prompt: 003-s01-conductor-rhythm-system.md*
```

### HANDOFF Best Practices

1. **Be Explicit:** Don't assume - spell out every GDAI command
2. **Include Examples:** Show exact property values, not placeholders
3. **Reference Research:** Link to research findings
4. **List Gotchas:** Warn about version-specific issues
5. **Provide Tests:** Complete testing checklist
6. **Define Success:** Clear completion criteria
7. **Estimate Time:** Help Tier 2 agent plan work

---

## Wave-by-Wave Execution Guide

This section provides detailed execution instructions for each wave, including agent assignments, branch naming, and coordination protocols.

### Pre-Execution: Framework Setup (CRITICAL!)

**Before ANY wave execution begins:**

#### Framework Agent Assignment
- **Duration:** 3-4 days
- **Agents:** 2-3 parallel
- **Branch:** `claude/framework-setup`

**Components to Build:**

| Component | File/Path | Agent | Estimated Time |
|-----------|-----------|-------|----------------|
| Integration Tests | `tests/integration/integration_test_suite.gd` | Agent F1 | 1 day |
| Quality Gates | `quality-gates.json` | Agent F1 | 0.5 day |
| Performance Profiler | `tests/performance/performance_profiler.gd` | Agent F2 | 1 day |
| Coordination Dashboard | `COORDINATION-DASHBOARD.md` | Agent F2 | 0.5 day |
| Known Issues DB | `KNOWN-ISSUES.md` | Agent F3 | 0.25 day |
| Knowledge Base Dirs | `knowledge-base/` structure | Agent F3 | 0.25 day |
| Checkpoint Validation | `scripts/validate_checkpoint.gd` | Agent F1 | 0.5 day |
| Rollback System | `scripts/checkpoint_manager.gd` | Agent F2 | 0.5 day |
| Asset Pipeline | `ASSET-PIPELINE.md` + `scripts/generate_placeholders.gd` | Agent F3 | 1 day |
| CI Test Runner | `scripts/ci_runner.gd` | Agent F1 | 0.5 day |

**Deliverables:**
- All framework files created
- Documentation for each component
- Test all framework components work together
- Commit and merge to prompt library branch

**Completion Criteria:**
- All framework components marked ✅ in PROJECT-STATUS.md
- Integration test suite can run (even with 0 tests initially)
- COORDINATION-DASHBOARD.md template ready for agents to use
- Knowledge base directory structure created

**CRITICAL:** NO execution work starts until framework is complete and merged!

---

### Wave 0: Foundation Documentation (Job 1)

**Start:** Immediately after framework setup
**Duration:** 2 days
**Agents Required:** 2 parallel

#### Agent Assignments

| Agent ID | Prompt | System | Branch | Duration |
|----------|--------|--------|--------|----------|
| Doc-1 | 001 | Foundation Docs | `claude/execute-wave0-doc-1` | 2 days |
| Doc-2 | 002 | Combat Spec | `claude/execute-wave0-doc-2` | 2 days |

#### Execution Steps

**Agent Doc-1 (Prompt 001):**
1. Research Godot 4.5 MCP documentation (30 min)
2. Research AI agent handbook best practices (30 min)
3. Create `vibe-code-philosophy.md` - comprehensive LLM guide
4. Create `godot-mcp-command-reference.md` - GDAI tool reference
5. Research checkpoint: `research/001-research.md`
6. No HANDOFF needed (pure documentation)
7. Commit and push

**Agent Doc-2 (Prompt 002):**
1. Research Godot 4.5 combat systems (45 min)
2. Research rhythm-based combat mechanics (30 min)
3. Create `combat-specification.md` - complete design doc
4. Include: Combat flow, timing windows, damage calc, rhythm integration
5. Research checkpoint: `research/002-research.md`
6. No HANDOFF needed (pure documentation)
7. Commit and push

**Dependencies Unblocked:**
- All 26 systems can now reference these foundation docs
- Wave 1 can begin immediately after

**Success Criteria:**
- Both docs complete and merged
- All agents can read foundation philosophy
- Combat spec defines all combat mechanics

---

### Wave 1: Core Foundation Systems (Job 2 - Part 1)

**Start:** After Wave 0 complete
**Duration:** 2 days
**Agents Required:** 2 parallel (Tier 1) + 2 parallel (Tier 2)

#### Agent Assignments (Tier 1)

| Agent ID | Prompt | System | Branch | Duration |
|----------|--------|--------|--------|----------|
| A1-T1 | 003 | S01 Conductor | `claude/execute-wave1-a1` | 1.5 days (Tier 1) |
| B1-T1 | 004 | S02 Input | `claude/execute-wave1-b1` | 1.5 days (Tier 1) |

#### Tier 1 Execution

**Agent A1-T1 (S01 Conductor):**
1. **Research (45 min):**
   - "Godot 4.5 rhythm game conductor tutorial"
   - "Godot 4.5 Timer signal patterns"
   - "RhythmNotifier plugin Godot 4.5"
   - Document findings in `research/S01-research.md`

2. **Implementation (6 hours):**
   - Create `res://autoloads/conductor.gd`
   - Create `res://data/rhythm_config.json`
   - Create `res://tests/test_conductor.gd` (test script)
   - Full beat/downbeat/measure signal system
   - Latency compensation
   - BPM management

3. **HANDOFF Creation (1 hour):**
   - Create `HANDOFF-S01.md` with complete scene instructions
   - Include GDAI commands for test scene
   - Testing checklist for Tier 2

4. **Commit and Push**

**Agent B1-T1 (S02 Input):**
1. **Research (30 min):**
   - "Godot 4.5 Input class documentation"
   - "Godot 4.5 controller input handling"
   - "SDL3 gamepad support Godot 4.5"
   - Document findings in `research/S02-research.md`

2. **Implementation (5 hours):**
   - Create `res://autoloads/input_manager.gd`
   - Create `res://data/input_config.json`
   - Create `res://tests/test_input.gd`
   - Input buffering
   - Controller mapping
   - Input history tracking

3. **HANDOFF Creation (1 hour):**
   - Create `HANDOFF-S02.md`
   - Testing requirements

4. **Commit and Push**

#### Agent Assignments (Tier 2)

| Agent ID | System | Branch | Duration |
|----------|--------|--------|----------|
| A1-T2 | S01 Conductor | `claude/execute-wave1-a1` (same) | 0.5 days |
| B1-T2 | S02 Input | `claude/execute-wave1-b1` (same) | 0.5 days |

#### Tier 2 Execution

**Agent A1-T2 (S01 Conductor):**
1. Read `HANDOFF-S01.md`
2. Research Godot 4.5 autoload best practices (15 min)
3. Register autoloads in project.godot
4. Create `res://tests/test_conductor.tscn` using GDAI tools
5. Create `res://debug/rhythm_debug_overlay.tscn`
6. Test: `play_scene`, verify signals
7. Run integration tests
8. Performance profiling
9. Quality gates
10. Create checkpoints (both .md and Memory MCP)
11. Unblock systems: S04, S09, S10, S16, S18, S26
12. Commit and push

**Agent B1-T2 (S02 Input):**
1. Read `HANDOFF-S02.md`
2. Research Godot 4.5 input testing (15 min)
3. Register InputManager autoload
4. Create `res://tests/test_input.tscn`
5. Create debug overlay for input visualization
6. Test with controller and keyboard
7. Run integration tests
8. Quality gates
9. Checkpoints
10. Unblock systems: S03, S04, S09, S10, S14, S16
11. Commit and push

**Dependencies Unblocked:**
- S03 Player can start (depends on S02)
- S04 Combat can start AFTER S03 complete

**Success Criteria:**
- Both systems fully tested and integrated
- 7 systems unblocked for future waves
- Checkpoints saved
- Quality gates pass

---

### Wave 2: Player Foundation (Job 2 - Part 2)

**Start:** After Wave 1 Tier 2 complete
**Duration:** 1.5 days
**Agents Required:** 1 (Tier 1) + 1 (Tier 2)

#### Agent Assignments

| Agent ID | Prompt | System | Branch | Tier 1 | Tier 2 |
|----------|--------|--------|--------|--------|--------|
| C1 | 005 | S03 Player | `claude/execute-wave2-c1` | 1 day | 0.5 day |

#### Execution

**Tier 1:**
1. Research (30 min): "Godot 4.5 CharacterBody2D tutorial"
2. Create player controller with movement, states
3. Create `res://player/player.gd`, `res://data/player_config.json`
4. HANDOFF with scene structure requirements
5. Commit and push

**Tier 2:**
1. Read HANDOFF-S03.md
2. Create `res://player/player.tscn` with CharacterBody2D
3. Add sprites, collision, animation player
4. Configure properties
5. Test movement in test scene
6. Quality gates
7. Checkpoints
8. Unblock: S04, S05, S14, S15, S16, S17
9. Commit and push

**Dependencies Unblocked:**
- S04 Combat (CRITICAL - biggest blocker!)
- S05 Inventory
- S14 Tools, S15 Vehicles, S16 Grind Rails, S17 Puzzles

---

### Wave 3: Combat Prototype (Job 2 - Part 3)

**Start:** After Wave 2 complete
**Duration:** 2 days
**Agents Required:** 1 (Tier 1) + 1 (Tier 2)

#### Agent Assignments

| Agent ID | Prompt | System | Branch | Tier 1 | Tier 2 |
|----------|--------|--------|--------|--------|--------|
| D1 | 006 | S04 Combat | `claude/execute-wave3-d1` | 1.5 days | 0.5 day |

**CRITICAL SYSTEM - THIS BLOCKS 15+ DOWNSTREAM SYSTEMS!**

#### Execution

**Tier 1:**
1. **Research (1 hour):**
   - "Godot 4.5 turn-based combat rhythm"
   - "Godot 4.5 state machine combat"
   - Review Combat Spec (002) thoroughly
   - Review Conductor (S01) integration points
2. Create combat system with:
   - Combatant.gd (base class)
   - CombatManager.gd (turn management)
   - Rhythm timing integration
   - Damage calculation
   - Status effects
3. Create combat arena scene scripts
4. HANDOFF with extensive testing requirements
5. Commit and push

**Tier 2:**
1. Read HANDOFF-S04.md
2. Create `res://combat/combat_arena.tscn`
3. Create `res://combat/combatant.tscn` (base scene)
4. Configure UI (health bars, combat menu)
5. Test combat flow thoroughly
6. Integration with S01 Conductor
7. Performance profiling (critical!)
8. Quality gates
9. Checkpoints
10. **Unblock 15+ systems!**
11. Commit and push

**Dependencies Unblocked:**
- S05 Inventory
- S07 Weapons
- S09-S13 (All combat expansion)
- S19-S23 (Progression systems)
- S26 Rhythm Mini-Games

---

### Wave 4: Maximum Parallelization (Job 2 - Part 4 & Job 3 Start)

**Start:** After Wave 3 complete
**Duration:** 3-4 days
**Agents Required:** 7 parallel (Tier 1) + 7 parallel (Tier 2)

**THIS IS THE HIGHEST PARALLELIZATION OPPORTUNITY IN THE ENTIRE PROJECT!**

#### Agent Assignments

| Agent | Prompt | System | Branch | Priority |
|-------|--------|--------|--------|----------|
| E1 | 007 | S05 Inventory | `wave4-e1` | HIGH (blocks S06, S08, S24, S25) |
| E2 | 013 | S11 Enemy AI | `wave4-e2` | HIGH (blocks S12) |
| E3 | 016 | S14 Tools | `wave4-e3` | MEDIUM (blocks S17) |
| E4 | 015 | S13 Vibe Bar | `wave4-e4` | LOW (visual polish) |
| E5 | 017 | S15 Vehicles | `wave4-e5` | LOW (independent) |
| E6 | 018 | S16 Grind Rails | `wave4-e6` | LOW (independent) |
| E7 | 020 | S18 Polyrhythm | `wave4-e7` | LOW (independent) |

**Agent Priority Assignment Logic:**
- Fastest agents → High priority (E1, E2)
- Medium agents → Medium priority (E3)
- Slower agents → Low priority (E4-E7)

#### Coordination Protocol

**BEFORE starting work:**
1. All agents check COORDINATION-DASHBOARD.md
2. Each agent claims their system and locks resources
3. No resource conflicts (each system independent)

**DURING work:**
1. Update progress at 25%, 50%, 75%
2. Document blockers immediately
3. Complete high-priority systems first if possible

**Wave 4 completion triggers Wave 5 starts (staggered)**

---

### Wave 5-9: Remaining Systems

[For brevity, structure is similar to above waves]

**Wave 5:** S06, S07, S08, S12 (4 parallel)
**Wave 6:** S09, S17 (2 parallel)
**Wave 7:** S10, S24, S25, S26 (4 parallel)
**Wave 8:** S19, S20, S21 (3 parallel, some staggered)
**Wave 9:** S22, S23 (2 sequential)
**Wave 10:** Prompt 029 (1 agent)

---

## Integration & Quality Gates

### Integration Testing Protocol

**After each wave:**

1. **Run Integration Test Suite**
   ```gdscript
   # In Godot, run:
   var suite = IntegrationTestSuite.new()
   var results = suite.run_all_tests()
   print(results.summary())
   ```

2. **Check for Regressions**
   - Did new system break existing systems?
   - Are all previous tests still passing?

3. **Performance Profiling**
   ```gdscript
   var profiler = PerformanceProfiler.new()
   var metrics = profiler.profile_all_systems()
   # Check: No system >1ms per frame
   ```

4. **Quality Gates**
   ```gdscript
   var gates = QualityGateChecker.new()
   var scores = gates.check_all_systems()
   # All scores must be ≥80/100
   ```

### Quality Gate Criteria

Each system must meet:
- **Code Quality:** 80/100
  - Type hints: 100% coverage
  - Documentation: All public methods
  - No warnings
  - Consistent style

- **Testing:** 80/100
  - Unit tests: ≥80% coverage
  - Integration tests: All critical paths
  - No failing tests

- **Performance:** 80/100
  - Frame time: <1ms per system
  - Memory: No leaks
  - Load time: <100ms

- **Integration:** 80/100
  - All dependencies satisfied
  - No circular dependencies
  - Clean interfaces

- **Documentation:** 80/100
  - README per system
  - API documentation
  - HANDOFF complete
  - Checkpoint complete

**Failing Quality Gates:**
- System cannot be marked complete
- Dependent systems cannot start
- Must fix issues before proceeding

---

## Troubleshooting & Rollback

### Common Issues

#### Issue: Godot 3.x Code Used

**Symptoms:**
- Errors about `KinematicBody2D` not found
- `yield` syntax errors
- `export` keyword errors

**Solution:**
- Search and replace Godot 3.x patterns
- Review Godot 4.5 migration guide
- Use WebSearch: "Godot 3 to 4 migration [feature]"

#### Issue: Tier 2 Can't Find Files

**Symptoms:**
- MCP agent reports files not found
- Scenes can't be created

**Solution:**
- Verify Tier 1 committed and pushed
- Use `get_filesystem_tree()` to check
- Ensure absolute paths used (res://)

#### Issue: Integration Tests Fail

**Symptoms:**
- New system breaks existing tests
- Regression in previously working system

**Solution:**
1. Check COORDINATION-DASHBOARD.md for recent changes
2. Review checkpoints for affected systems
3. Use git to see recent commits
4. Isolate failing test
5. Fix and re-test

#### Issue: Performance Below Target

**Symptoms:**
- System takes >1ms per frame
- Frame drops

**Solution:**
1. Profile with PerformanceProfiler
2. Search: "Godot 4.5 performance optimization [feature]"
3. Review code for inefficiencies
4. Add caching/pooling
5. Re-profile

### Rollback Procedure

If a system implementation is fundamentally broken:

1. **Assess Damage:**
   ```bash
   # Check recent commits
   git log --oneline -10

   # Check affected systems
   grep -r "SystemID" COORDINATION-DASHBOARD.md
   ```

2. **Communicate:**
   - Update KNOWN-ISSUES.md
   - Mark system as BLOCKED in COORDINATION-DASHBOARD.md
   - Notify dependent agents

3. **Rollback:**
   ```bash
   # Revert to last known good commit
   git revert [commit-hash]

   # Or hard reset (if not pushed to shared branch yet)
   git reset --hard [last-good-commit]
   ```

4. **Checkpoint Restore:**
   - Read checkpoint from Basic Memory MCP
   - Review what was working
   - Identify what broke

5. **Fix and Re-implement:**
   - Research issue thoroughly
   - Create knowledge-base entry about the problem
   - Re-implement with fix
   - Extra testing before marking complete

---

## Success Metrics

### Overall Project Success

**The project is complete when:**

- ✅ All 29 prompts executed
- ✅ All 26 systems implemented and integrated
- ✅ All integration tests passing (target: 95%+ pass rate)
- ✅ All performance targets met (<1ms per system)
- ✅ All quality gates passing (≥80/100 all systems)
- ✅ Complete documentation (checkpoints, HANDOFF, knowledge base)
- ✅ No critical bugs in KNOWN-ISSUES.md
- ✅ Game playable end-to-end

### Job-Level Success

**Job 1 (Docs):**
- Foundation docs and combat spec complete
- All agents can reference philosophy
- Clear development guidelines

**Job 2 (S01-S08):**
- All foundation systems working
- Combat prototype playable
- Save/load functional
- v0.1.0 tagged

**Job 3 (S09-S18):**
- Combat depth complete
- All traversal systems working
- Environment systems tested
- v0.2.0 tagged

**Job 4 (S19-S26):**
- Progression systems complete
- All content systems functional
- Story and NPCs integrated
- v1.0.0 tagged

---

## Final Notes

### Research is Not Optional

Every system MUST begin with research. This is not "extra" - it's core to the workflow. Budget 15-45 minutes per system.

### Godot 4.5 Documentation First

Always verify documentation is for Godot 4.5+. Godot 3.x code will not work.

### Checkpoints Save Time

Creating checkpoints takes 10-15 minutes but saves hours when agents need to reference previous work.

### Quality Gates Prevent Technical Debt

Enforcing quality gates slows individual systems by 10% but prevents exponential slowdown from technical debt.

### Communication is Critical

Use COORDINATION-DASHBOARD.md religiously. A 2-minute update prevents 2-hour conflicts.

---

**END OF PARALLEL EXECUTION GUIDE V2**

*Version: 2.0*
*Last Updated: 2025-11-17*
*Optimized for: 5-7 parallel agents, Godot 4.5, Two-tier workflow*
