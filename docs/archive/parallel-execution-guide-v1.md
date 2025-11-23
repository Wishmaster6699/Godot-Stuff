# Parallel Execution Guide - Rhythm RPG Implementation

**Version:** 1.0
**Date:** 2025-11-17
**Purpose:** Enable multiple LLM agents to work in parallel without conflicts

---

## Overview

This repository contains **10 prompts** (001-010) for implementing the Rhythm RPG foundation layer (Job 2). To enable parallel execution without merge conflicts, we use a **branch-per-execution** strategy.

---

## Branch Strategy

### Prompt Library Branch (READ-ONLY for executors)
**Branch:** `claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2`
**Purpose:** Contains all prompt files (001-010)
**Status:** ✓ Complete - DO NOT MODIFY during execution

**Contents:**
- `prompts/001-foundation-vibe-philosophy-mcp-reference.md`
- `prompts/002-combat-specification.md`
- `prompts/003-s01-conductor-rhythm-system.md`
- `prompts/004-s02-controller-input-system.md`
- `prompts/005-s03-player-controller.md`
- `prompts/006-s04-combat-prototype.md`
- `prompts/007-s05-inventory-system.md`
- `prompts/008-s06-save-load-system.md`
- `prompts/009-s07-weapons-database.md`
- `prompts/010-s08-equipment-system.md`

### Execution Branches (ONE per agent/wave)
**Pattern:** `claude/execute-[wave]-[agent-id]`
**Purpose:** Each agent works on their own branch
**Merge target:** After completion, merge to `main` (or designated integration branch)

---

## Framework Setup (REQUIRED - Do This First!)

Before ANY agent starts executing prompts, the framework infrastructure must be set up. This provides quality gates, coordination, and knowledge persistence for the entire development process.

### Framework Setup Agent (ONE TIME ONLY)

Designate ONE agent to create all framework files:

**Branch:** `claude/framework-setup`
**Duration:** ~2-3 hours
**Priority:** CRITICAL - Blocks all other work

#### Framework Files to Create:

**1. Integration Test Suite**
```bash
mkdir -p tests/integration
# Create tests/integration/integration_test_suite.gd
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 39-76
```

**2. Quality Gates System**
```bash
# Create quality-gates.json
# Define quality gates for all 26 systems
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 84-139
```

**3. Coordination Dashboard**
```bash
# Create COORDINATION-DASHBOARD.md
# Template for live agent coordination
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 141-191
```

**4. Knowledge Base Structure**
```bash
mkdir -p knowledge-base/{solutions,patterns,gotchas,integration-recipes}
# Create knowledge-base/README.md with usage instructions
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 193-263
```

**5. Checkpoint Validation**
```bash
mkdir -p scripts
# Create scripts/validate_checkpoint.gd
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 265-318
```

**6. Rollback System**
```bash
# Create scripts/checkpoint_manager.gd
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 320-388
```

**7. Performance Profiler**
```bash
mkdir -p tests/performance
# Create tests/performance/performance_profiler.gd
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 390-438
```

**8. Known Issues Database**
```bash
# Create KNOWN-ISSUES.md
# Template for bug tracking
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 440-487
```

**9. Asset Pipeline**
```bash
# Create ASSET-PIPELINE.md
# Create scripts/generate_placeholders.gd
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 489-565
```

**10. CI Test Runner**
```bash
# Create scripts/ci_runner.gd
# See AI-VIBE-CODE-SUCCESS-FRAMEWORK.md lines 567-645
```

#### Framework Setup Steps:

1. **Create framework branch:**
```bash
git checkout -b claude/framework-setup origin/claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
```

2. **Read the framework guide:**
```bash
cat AI-VIBE-CODE-SUCCESS-FRAMEWORK.md
```

3. **Create all 10 framework components** (follow the exact code from the framework doc)

4. **Initialize COORDINATION-DASHBOARD.md** with empty status tables

5. **Commit framework setup:**
```bash
git add .
git commit -m "Add AI Development Success Framework

Created:
- Integration test suite
- Quality gates system
- Coordination dashboard
- Knowledge base structure
- Checkpoint validation
- Rollback system
- Performance profiler
- Known issues database
- Asset pipeline
- CI test runner

Status: Framework ready, agents can begin execution"
```

6. **Push framework branch:**
```bash
git push -u origin claude/framework-setup
```

7. **Merge to prompt library branch** (so all execution branches inherit it):
```bash
git checkout claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
git merge claude/framework-setup
git push origin claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
```

### Framework Usage Protocol (For All Agents)

After framework setup completes, **EVERY AGENT** must follow this protocol:

**BEFORE starting work:**
- [ ] Read `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md`
- [ ] Check `COORDINATION-DASHBOARD.md` for blockers and resource locks
- [ ] Search `knowledge-base/` for related issues
- [ ] Review `KNOWN-ISSUES.md` for known problems
- [ ] Update `COORDINATION-DASHBOARD.md`: Claim work, lock resources

**DURING implementation:**
- [ ] Update `COORDINATION-DASHBOARD.md` at 25%, 50%, 75% progress
- [ ] Document issues in `KNOWN-ISSUES.md` as discovered
- [ ] Use placeholder assets (see `ASSET-PIPELINE.md`)

**BEFORE marking complete:**
- [ ] Run `IntegrationTestSuite.run_all_tests()`
- [ ] Run `PerformanceProfiler.profile_system(system_id)`
- [ ] Run `check_quality_gates(system_id)` - ALL gates must pass
- [ ] Run `validate_checkpoint(system_id)` - Must return valid
- [ ] Update `COORDINATION-DASHBOARD.md`: Mark complete, release locks
- [ ] Create `knowledge-base/` entry if solved non-trivial problem

**IF something goes wrong:**
- [ ] Add to `KNOWN-ISSUES.md` with severity
- [ ] Search `knowledge-base/` for solutions
- [ ] Consider `CheckpointManager.rollback_to_checkpoint()`
- [ ] Document solution in `knowledge-base/` when fixed

---

## 🔄 Two-Tier Execution Model

**Each prompt executes in TWO TIERS:**

### Tier 1: Claude Code Web (File Creation)
- **Agent Type**: Claude Code Web
- **Tasks**: Create all .gd files, .json files, HANDOFF-[system-id].md
- **Tools**: Write tool for file creation
- **Output**: Complete implementations + handoff instructions
- **Duration**: ~60-70% of total time

### Tier 2: Godot MCP Agent (Scene Configuration)
- **Agent Type**: Godot MCP-enabled agent
- **Tasks**: Read HANDOFF.md, configure scenes, test in Godot
- **Tools**: GDAI MCP tools (create_scene, add_node, attach_script, update_property, play_scene)
- **Output**: Configured scenes, tested system, updated coordination dashboard
- **Duration**: ~30-40% of total time

**Why Two Tiers?**
- Claude Code Web cannot use Godot MCP (no MCP support in web version)
- But Claude Code Web is excellent at file creation and code generation
- Godot MCP agents handle Godot-specific operations (scenes, testing)
- This maximizes efficiency: heavy lifting in Tier 1, Godot work in Tier 2

---

## Execution Waves (Dependency-Ordered)

**Note**: Each agent listed below executes in two tiers. Duration shown is TOTAL (Tier 1 + Tier 2).



### Wave 1: Foundation (3 agents in parallel)

**Agent A:**
```bash
Branch: claude/execute-wave1-agent-a
Prompt: 002-combat-specification.md
Output: combat-specification.md (design doc)
Dependencies: None
Duration: ~1-2 hours
```

**Agent B:**
```bash
Branch: claude/execute-wave1-agent-b
Prompt: 003-s01-conductor-rhythm-system.md
Output:
  - res://autoloads/conductor.gd
  - res://data/rhythm_config.json
  - res://tests/test_conductor.tscn
Dependencies: None
Duration: ~2-3 hours
```

**Agent C:**
```bash
Branch: claude/execute-wave1-agent-c
Prompt: 004-s02-controller-input-system.md
Output:
  - res://autoloads/input_manager.gd
  - res://data/input_config.json
  - res://tests/test_input.tscn
Dependencies: None
Duration: ~2-3 hours
```

### Wave 2: Player & Inventory (2 agents in parallel)

**WAIT FOR:** Wave 1 Agent C (S02 Controller Input) to complete

**Agent A:**
```bash
Branch: claude/execute-wave2-agent-a
Prompt: 005-s03-player-controller.md
Output:
  - res://player/player.tscn
  - res://player/player.gd
  - res://data/player_config.json
  - res://tests/test_movement.tscn
Dependencies: S02 (Wave 1 Agent C)
Duration: ~2-3 hours
```

**Agent B:**
```bash
Branch: claude/execute-wave2-agent-b
Prompt: 007-s05-inventory-system.md
Output:
  - res://inventory/inventory.gd
  - res://data/items.json
  - res://items/item_pickup.tscn
  - res://ui/inventory_ui.tscn
Dependencies: S03 (Wave 2 Agent A) - can start in parallel but needs S03 for integration
Duration: ~2-3 hours
```

### Wave 3: Combat Prototype (1 agent)

**WAIT FOR:** Wave 1 (all agents) + Wave 2 Agent A complete

**Agent A:**
```bash
Branch: claude/execute-wave3-agent-a
Prompt: 006-s04-combat-prototype.md
Output:
  - res://combat/combat_arena.tscn
  - res://combat/combatant.gd
  - res://combat/ui/health_bar.tscn
  - res://data/combat_config.json
  - res://tests/test_combat.tscn
Dependencies: S01 (Wave 1 Agent B), S02 (Wave 1 Agent C), S03 (Wave 2 Agent A)
Duration: ~3-4 hours
```

### Wave 4: Save/Load & Weapons (2 agents in parallel)

**WAIT FOR:** Wave 2 (all agents) + Wave 3 complete

**Agent A:**
```bash
Branch: claude/execute-wave4-agent-a
Prompt: 008-s06-save-load-system.md
Output:
  - res://autoloads/save_manager.gd
  - res://tests/test_save_load.tscn
Dependencies: S03 (Wave 2 Agent A), S05 (Wave 2 Agent B)
Duration: ~2-3 hours
```

**Agent B:**
```bash
Branch: claude/execute-wave4-agent-b
Prompt: 009-s07-weapons-database.md
Output:
  - res://resources/weapon_resource.gd
  - res://resources/shield_resource.gd
  - res://autoloads/item_database.gd
  - res://data/weapons.json (50+ weapons)
  - res://data/shields.json (15+ shields)
  - res://tests/test_weapons.tscn
Dependencies: S04 (Wave 3), S05 (Wave 2 Agent B)
Duration: ~3-4 hours (lots of JSON data)
```

### Wave 5: Equipment System (1 agent)

**WAIT FOR:** Wave 4 (all agents) complete

**Agent A:**
```bash
Branch: claude/execute-wave5-agent-a
Prompt: 010-s08-equipment-system.md
Output:
  - res://player/equipment_manager.gd
  - res://data/equipment.json
  - res://ui/equipment_panel.tscn
  - res://tests/test_equipment.tscn
Dependencies: S05 (Wave 2 Agent B), S07 (Wave 4 Agent B)
Duration: ~2-3 hours
```

### Special: Foundation Docs (1 agent, can run anytime)

**Agent X:**
```bash
Branch: claude/execute-foundation-docs
Prompt: 001-foundation-vibe-philosophy-mcp-reference.md
Output:
  - vibe-code-philosophy.md
  - godot-mcp-command-reference.md
Dependencies: None (pure documentation)
Duration: ~2-3 hours (requires research)
Priority: HIGH (all other agents should read these docs first)
```

---

## Step-by-Step Execution Instructions

### For Each Agent

#### Step 1: Create Your Execution Branch
```bash
# Checkout from the prompt library branch
git fetch origin
git checkout -b claude/execute-[wave]-[agent-id] origin/claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2

# Example for Wave 1 Agent A:
git checkout -b claude/execute-wave1-agent-a origin/claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
```

#### Step 2: Read Your Assigned Prompt
```bash
# Read the prompt file
cat prompts/[your-prompt-number].md

# Example for Wave 1 Agent A:
cat prompts/002-combat-specification.md
```

#### Step 3: Follow Framework Protocol (REQUIRED)

**BEFORE implementation:**
- [ ] Read `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md`
- [ ] Check `COORDINATION-DASHBOARD.md` for blockers/locks
- [ ] Search `knowledge-base/` for related issues
- [ ] Update `COORDINATION-DASHBOARD.md`: Claim work, lock resources

#### Step 4: Execute Tier 1 (Claude Code Web - File Creation)

**If you are Claude Code Web**, execute the Tier 1 portion of the prompt:

1. **Web research** (as specified in prompt)
   - Search for latest Godot 4.5 best practices
   - Find relevant examples and patterns

2. **Create all .gd files** using Write tool
   - Complete implementations with type hints and documentation
   - No TODOs or placeholders
   - Full integration logic

3. **Create all .json files** using Write tool
   - Valid JSON with complete schemas
   - All required fields populated

4. **Update `COORDINATION-DASHBOARD.md`** at 25%, 50%, 75% progress (use Edit tool)
   - Mark current status
   - Update progress percentage

5. **Create HANDOFF-[system-id].md** with (use Write tool):
   - Files created list
   - MCP agent tasks (GDAI commands: create_scene, add_node, etc.)
   - Node hierarchies to build
   - Property configurations needed
   - Testing checklist for Godot editor
   - Integration notes and gotchas

6. **Update `COORDINATION-DASHBOARD.md`** (use Edit tool): Mark Tier 1 complete, ready for handoff

**Tools Available to Claude Code Web:**
- ✅ Read, Write, Edit tools for file operations
- ✅ Grep, Glob for searching
- ✅ Bash for git operations
- ✅ WebSearch, WebFetch for research
- ❌ NO Godot MCP / GDAI tools
- ❌ NO Basic Memory MCP

---

#### Step 5: Execute Tier 2 (Godot MCP Agent - Scene Configuration)

**If you are a Godot MCP agent**, execute the Tier 2 portion:

1. **Read HANDOFF-[system-id].md** created by Claude Code Web
   - Understand all files that were created
   - Review scene structure requirements
   - Note all MCP commands to run

2. **Verify Tier 1 files exist** (use get_filesystem_tree)
   - Check all .gd files are present
   - Check all .json files are present

3. **Configure scenes** using GDAI tools:
   - `create_scene` - Create .tscn files with root nodes
   - `add_node` - Build complete node hierarchies
   - `attach_script` - Connect .gd scripts to nodes
   - `update_property` - Set all node properties (positions, colors, etc.)
   - Register autoloads (if specified in HANDOFF.md)

4. **Update `COORDINATION-DASHBOARD.md`** at 25%, 50%, 75% progress
   - Mark scene configuration progress

5. **Test in Godot editor**:
   - `play_scene` - Run test scenes
   - `get_godot_errors` - Check for errors
   - Verify all functionality works as specified

6. **Run quality gates** (in Godot):
   - `IntegrationTestSuite.run_all_tests()` - Run integration tests
   - `PerformanceProfiler.profile_system(system_id)` - Profile performance
   - `check_quality_gates(system_id)` - Verify quality standards met
   - `validate_checkpoint(system_id)` - Validate checkpoint data

7. **Save checkpoint** to Basic Memory MCP (if available)
   - Document files created, integration points, testing results

8. **Update `COORDINATION-DASHBOARD.md`**: Mark complete, release locks, unblock dependencies

**Tools Available to Godot MCP Agents:**
- ✅ All GDAI MCP tools (create_scene, add_node, attach_script, update_property, etc.)
- ✅ Godot editor access (play_scene, get_godot_errors, get_editor_screenshot, etc.)
- ✅ Basic Memory MCP (if configured)
- ✅ File operations (Read, Write, Edit, get_filesystem_tree, search_files, etc.)
- ✅ Git operations (Bash)

---

#### Step 6: Commit Your Work

**Both Tiers** should commit their changes:
```bash
# Stage your changes (DO NOT include the prompts folder in changes)
git add res/
git add *.md  # Only if you created output documentation

# Commit with descriptive message
git commit -m "Complete [System Name] - [Brief Description]

Implemented:
- File 1
- File 2
- etc.

Verified:
- Criteria 1
- Criteria 2

Status: Ready for dependent systems"

# Example:
git commit -m "Complete S01 Conductor/Rhythm System

Implemented:
- res://autoloads/conductor.gd
- res://data/rhythm_config.json
- res://tests/test_conductor.tscn

Verified:
- Downbeat signal emits every 4 beats
- Timing quality evaluation accurate
- No audio drift over 5 minutes

Status: Ready for S04, S09, S10"
```

#### Step 7: Push Your Branch
```bash
git push -u origin claude/execute-[wave]-[agent-id]

# Example:
git push -u origin claude/execute-wave1-agent-a
```

#### Step 8: Create Pull Request (Optional)
After pushing, you can create a PR to main for review, or continue to Wave 2 if you're doing multiple waves.

---

## Dependency Resolution

### How to Handle Dependencies

If your prompt depends on another system (e.g., S03 depends on S02):

**Option A: Wait for upstream agent to complete**
```bash
# Wait for Wave 1 Agent C to push their branch
# Then pull their changes before starting
git fetch origin
git merge origin/claude/execute-wave1-agent-c
```

**Option B: Stub out dependencies temporarily**
```bash
# Create placeholder implementations
# Example: If S03 needs S02 but S02 isn't ready yet:
# - Create a stub InputManager with minimal functionality
# - Implement S03 using the stub
# - Replace stub when S02 is ready
```

**Option C: Coordinate with upstream agent**
- Use shared memory checkpoints
- Read their checkpoint to understand interface
- Implement based on their documented API

### Resolving Merge Conflicts

If you get a merge conflict when pulling upstream changes:

```bash
# Identify conflicting files
git status

# Manually resolve conflicts in each file
# Look for conflict markers: <<<<<<<, =======, >>>>>>>

# After resolving, stage the files
git add [resolved-files]

# Continue the merge
git commit -m "Merge wave1-agent-c changes into wave2-agent-a"
```

---

## Parallel Execution Timeline

### Maximum Parallelization (5 agents available)

| Time     | Agent A            | Agent B            | Agent C             | Agent D | Agent E |
|----------|--------------------|--------------------|---------------------|---------|---------|
| Hour 0-2 | 002 (Combat Spec)  | 003 (S01 Conductor)| 004 (S02 Input)     | 001 (Docs) | -    |
| Hour 2-4 | 005 (S03 Player)   | 007 (S05 Inventory)| 006 (S04 Combat)    | -       | -       |
| Hour 4-6 | 008 (S06 Save/Load)| 009 (S07 Weapons)  | -                   | -       | -       |
| Hour 6-8 | 010 (S08 Equipment)| -                  | -                   | -       | -       |

**Total Duration:** ~8 hours with 5 agents working in parallel

### Conservative Estimate (3 agents available)

| Time      | Agent A            | Agent B            | Agent C             |
|-----------|--------------------|--------------------|--------------------|
| Hour 0-2  | 002 (Combat Spec)  | 003 (S01 Conductor)| 004 (S02 Input)    |
| Hour 2-5  | 005 (S03 Player)   | 007 (S05 Inventory)| 001 (Docs)         |
| Hour 5-8  | 006 (S04 Combat)   | -                  | -                  |
| Hour 8-11 | 008 (S06 Save/Load)| 009 (S07 Weapons)  | -                  |
| Hour 11-14| 010 (S08 Equipment)| -                  | -                  |

**Total Duration:** ~14 hours with 3 agents

---

## Integration After All Waves Complete

### Final Integration Branch

Once all waves are complete:

```bash
# Create integration branch from main
git checkout main
git pull origin main
git checkout -b claude/integrate-job2-all-systems

# Merge all execution branches in dependency order
git merge origin/claude/execute-wave1-agent-a  # 002 Combat Spec
git merge origin/claude/execute-wave1-agent-b  # 003 S01
git merge origin/claude/execute-wave1-agent-c  # 004 S02
git merge origin/claude/execute-wave2-agent-a  # 005 S03
git merge origin/claude/execute-wave2-agent-b  # 007 S05
git merge origin/claude/execute-wave3-agent-a  # 006 S04
git merge origin/claude/execute-wave4-agent-a  # 008 S06
git merge origin/claude/execute-wave4-agent-b  # 009 S07
git merge origin/claude/execute-wave5-agent-a  # 010 S08

# Resolve any conflicts
# Test integration
# Push and create PR to main
git push -u origin claude/integrate-job2-all-systems
```

---

## Quick Reference

### Agent Assignment Matrix

| Agent ID | Wave 1    | Wave 2    | Wave 3    | Wave 4    | Wave 5    |
|----------|-----------|-----------|-----------|-----------|-----------|
| Agent A  | 002 (Spec)| 005 (S03) | 006 (S04) | 008 (S06) | 010 (S08) |
| Agent B  | 003 (S01) | 007 (S05) | -         | 009 (S07) | -         |
| Agent C  | 004 (S02) | -         | -         | -         | -         |
| Agent X  | 001 (Docs)| -         | -         | -         | -         |

### Prompt-to-Output Mapping

| Prompt | System | Output Files |
|--------|--------|--------------|
| 001    | Foundation Docs | vibe-code-philosophy.md, godot-mcp-command-reference.md |
| 002    | Combat Spec | combat-specification.md |
| 003    | S01 Conductor | conductor.gd, rhythm_config.json |
| 004    | S02 Input | input_manager.gd, input_config.json |
| 005    | S03 Player | player.tscn, player.gd, player_config.json |
| 006    | S04 Combat | combat_arena.tscn, combatant.gd, combat_config.json |
| 007    | S05 Inventory | inventory.gd, items.json, item_pickup.tscn |
| 008    | S06 Save/Load | save_manager.gd |
| 009    | S07 Weapons | weapons.json, shields.json, item_database.gd |
| 010    | S08 Equipment | equipment_manager.gd, equipment.json |

---

## Troubleshooting

### "I can't find the prompt file"
Make sure you checked out from the prompt library branch:
```bash
git checkout -b your-branch origin/claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
```

### "Merge conflict when pulling upstream dependencies"
1. Identify conflicting files with `git status`
2. Open each file and look for `<<<<<<<` markers
3. Manually resolve (choose one version or merge both)
4. `git add [resolved-files]`
5. `git commit`

### "My dependency isn't ready yet"
- Check the dependency's execution branch status
- Coordinate with that agent
- Or create a stub implementation temporarily

### "I modified the prompt file by accident"
- Don't commit changes to `prompts/` folder
- If you did: `git checkout prompts/` to revert

---

## Success Criteria

**Job 2 is complete when:**
- [ ] All 10 prompts (001-010) executed successfully
- [ ] All 8 systems (S01-S08) implemented and tested
- [ ] All execution branches merged to integration branch
- [ ] Integration tests pass
- [ ] Documentation complete (001 Foundation Docs)
- [ ] Combat specification finalized (002)

**Job 3 is complete when:**
- [ ] All 10 prompts (011-020) executed successfully
- [ ] All 10 systems (S09-S18) implemented and tested
- [ ] Combat depth systems working (Dodge, Block, Special Moves)
- [ ] Enemy AI and Monster Database integrated
- [ ] Environment systems functional (Tools, Vehicles, Grind Rails, Puzzles)
- [ ] Polyrhythmic environment system tested

**Job 4 is complete when:**
- [ ] All 9 prompts (021-029) executed successfully
- [ ] All 8 systems (S19-S26) implemented and tested
- [ ] Progression systems complete (XP, Monster Evolution, Resonance)
- [ ] RPG systems integrated (NPCs, Story, Cooking, Crafting)
- [ ] Rhythm mini-games functional
- [ ] Parallel build strategy document complete

**Full Project is complete when:**
- [ ] All 29 prompts executed successfully
- [ ] All 26 systems (S01-S26) implemented, integrated, and tested
- [ ] All integration tests passing across all systems
- [ ] Performance profiling complete for all systems
- [ ] All quality gates passing
- [ ] Documentation complete

---

## Next Steps After Each Job

**After Job 2 Complete:**
1. Merge integration branch to `main`
2. Tag release: `v0.1.0-job2-foundation-complete`
3. Begin Job 3 (Prompts 011-020, Systems S09-S18)
4. Repeat parallel execution strategy for Job 3

**After Job 3 Complete:**
1. Merge integration branch to `main`
2. Tag release: `v0.2.0-job3-combat-depth-complete`
3. Begin Job 4 (Prompts 021-029, Systems S19-S26)
4. Repeat parallel execution strategy for Job 4

**After Job 4 Complete:**
1. Merge integration branch to `main`
2. Tag release: `v1.0.0-all-systems-complete`
3. Begin polish and optimization phase

---

**End of Parallel Execution Guide**
