# Rhythm RPG - Project Status

**Last Updated:** 2025-11-17
**Current Phase:** Job 2 - Foundation Layer (Prompts Created, Ready for Execution)

---

## Quick Start for New Agents

### I'm a new LLM agent. What should I do?

**IMPORTANT**: This project uses a **two-tier workflow**. Understand which tier you are:

- **Tier 1 (Claude Code Web)**: Create .gd/.json files + HANDOFF.md
- **Tier 2 (Godot MCP Agent)**: Configure scenes + test in Godot

### For Claude Code Web (Tier 1):

1. **Read the guides** (use Read tool):
   - Read `PARALLEL-EXECUTION-GUIDE.md` - Understand two-tier workflow
   - Read `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md` - Framework requirements

2. **Check what's available to work on:**
   - See "Execution Status" section below
   - Find an unclaimed prompt in your wave

3. **Create your execution branch** (use Bash tool):
   ```bash
   git checkout -b claude/execute-wave[X]-agent-[your-id] origin/claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2
   ```

4. **Execute Tier 1 (File Creation):**
   - Read prompt: Use Read tool on `prompts/[prompt-number].md`
   - Follow `<two_tier_workflow>` section for Tier 1 tasks
   - Create all .gd files, .json files (use Write tool)
   - Create HANDOFF-[system-id].md with MCP agent instructions (use Write tool)
   - Commit and push your work (use Bash tool)

**Tools Available to You:**
- ✅ Read, Write, Edit tools for file operations
- ✅ Grep, Glob for searching codebase and knowledge-base/
- ✅ Bash for git operations
- ✅ WebSearch, WebFetch for research
- ❌ NO Godot MCP / GDAI tools (create_scene, add_node, etc.)
- ❌ NO Basic Memory MCP
- ❌ NO Godot editor access

### For Godot MCP Agents (Tier 2):

1. **Read the handoff** (use Read tool):
   - Read `HANDOFF-[system-id].md` created by Claude Code Web

2. **Execute Tier 2 (Scene Configuration):**
   - Use GDAI tools: create_scene, add_node, attach_script, update_property
   - Test in Godot: play_scene, get_godot_errors
   - Run quality gates: IntegrationTestSuite, PerformanceProfiler (in Godot)
   - Update COORDINATION-DASHBOARD.md when complete (use Edit tool)

**Tools Available to You:**
- ✅ All GDAI MCP tools (create_scene, add_node, attach_script, update_property, etc.)
- ✅ Godot editor access (play_scene, get_godot_errors, get_editor_screenshot, etc.)
- ✅ Basic Memory MCP (if configured for checkpoint saving)
- ✅ File operations (Read, Write, Edit, get_filesystem_tree, search_files, etc.)
- ✅ Bash for git operations

---

## Framework Setup Status

### CRITICAL: Framework Infrastructure (MUST BE DONE FIRST!)

**Status:** ⬜ NOT STARTED
**Priority:** HIGHEST - Blocks all other work
**Branch:** `claude/framework-setup`
**Duration:** ~2-3 hours

#### Framework Components Checklist

| Component | File/Directory | Status | Notes |
|-----------|----------------|--------|-------|
| Integration Tests | `tests/integration/integration_test_suite.gd` | ⬜ | Required for all system verification |
| Quality Gates | `quality-gates.json` | ⬜ | Defines quality criteria for all 26 systems |
| Coordination Dashboard | `COORDINATION-DASHBOARD.md` | ⬜ | Live status tracking for all agents |
| Knowledge Base | `knowledge-base/{solutions,patterns,gotchas,integration-recipes}/` | ⬜ | Persistent knowledge across sessions (use Read/Write/Grep tools) |
| Checkpoint Validation | `scripts/validate_checkpoint.gd` | ⬜ | Validates checkpoint completeness |
| Rollback System | `scripts/checkpoint_manager.gd` | ⬜ | Version control for checkpoints |
| Performance Profiler | `tests/performance/performance_profiler.gd` | ⬜ | Performance testing for all systems |
| Known Issues DB | `KNOWN-ISSUES.md` | ⬜ | Bug tracking database |
| Asset Pipeline | `ASSET-PIPELINE.md` + `scripts/generate_placeholders.gd` | ⬜ | Placeholder asset generation |
| CI Test Runner | `scripts/ci_runner.gd` | ⬜ | Continuous integration testing |

**Setup Instructions:** See `PARALLEL-EXECUTION-GUIDE.md` → "Framework Setup" section

**⚠️ IMPORTANT:** NO execution agent should start work until framework setup is COMPLETE and merged to the prompt library branch.

---

## Current Status

### Job 1: Foundation Documentation
**Status:** ⚠️ IN PROGRESS (Conflict detected)
**Branch:** `claude/foundation-vibe-philosophy-mcp-01UVRBuogjNH7JNhDyspEf64` (Agent 2's branch)
**Files Expected:**
- `vibe-code-philosophy.md`
- `godot-mcp-command-reference.md`

**Issue:** Agent 2 created a different version of prompt 001. Need to resolve:
- Option A: Keep Agent 2's execution, discard my prompt
- Option B: Agent 2 re-executes using my prompt
- **Recommended:** Agent 2's branch should contain OUTPUT files (vibe-code-philosophy.md), not another prompt version

### Job 2: Core Combat + Foundation Systems (S01-S08)
**Status:** ✅ PROMPTS READY (10 prompts created)
**Branch:** `claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2` (Prompt Library - READ ONLY)

**Prompts Available:**
- ✅ 001-foundation-vibe-philosophy-mcp-reference.md (Foundation docs)
- ✅ 002-combat-specification.md (Combat design spec)
- ✅ 003-s01-conductor-rhythm-system.md (Rhythm system)
- ✅ 004-s02-controller-input-system.md (Controller input)
- ✅ 005-s03-player-controller.md (Player character)
- ✅ 006-s04-combat-prototype.md (Combat prototype)
- ✅ 007-s05-inventory-system.md (Inventory)
- ✅ 008-s06-save-load-system.md (Save/load)
- ✅ 009-s07-weapons-database.md (Weapons & shields)
- ✅ 010-s08-equipment-system.md (Equipment system)

### Job 3: Combat Depth + Environment Systems (S09-S18)
**Status:** ✅ PROMPTS READY (10 prompts created)
**Branch:** `claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2` (Prompt Library - READ ONLY)

**Prompts Available:**
- ✅ 011-s09-dodge-block-mechanics.md (Dodge & Block)
- ✅ 012-s10-special-moves-system.md (Special moves)
- ✅ 013-s11-enemy-ai-system.md (Enemy AI)
- ✅ 014-s12-monster-database.md (Monster database)
- ✅ 015-s13-color-shift-health-vibe-bar.md (Health & Vibe UI)
- ✅ 016-s14-tool-system.md (Tools)
- ✅ 017-s15-vehicle-system.md (Vehicles)
- ✅ 018-s16-grind-rail-traversal.md (Grind rails)
- ✅ 019-s17-puzzle-system.md (Puzzles)
- ✅ 020-s18-polyrhythmic-environment.md (Polyrhythmic environment)

### Job 4: Progression + RPG Systems (S19-S26) + Build Strategy
**Status:** ✅ PROMPTS READY (9 prompts created)
**Branch:** `claude/read-create-prompt-01KhYv66riXZsEpyKBZNkBN2` (Prompt Library - READ ONLY)

**Prompts Available:**
- ✅ 021-s19-dual-xp-system.md (XP & Leveling)
- ✅ 022-s20-monster-evolution.md (Monster evolution)
- ✅ 023-s21-resonance-alignment.md (Resonance & Alignment)
- ✅ 024-s22-npc-system.md (NPCs)
- ✅ 025-s23-player-progression-story.md (Story progression)
- ✅ 026-s24-cooking-system.md (Cooking)
- ✅ 027-s25-crafting-system.md (Crafting)
- ✅ 028-s26-rhythm-mini-games.md (Rhythm mini-games)
- ✅ 029-parallel-build-strategy.md (Parallel build orchestration)

---

## Execution Status

### Wave 1: Foundation (3 parallel agents)

| Agent ID | Prompt | System | Status | Branch | Started | Completed |
|----------|--------|--------|--------|--------|---------|-----------|
| Agent A  | 002    | Combat Spec | ⬜ NOT STARTED | - | - | - |
| Agent B  | 003    | S01 Conductor | ⬜ NOT STARTED | - | - | - |
| Agent C  | 004    | S02 Input | ⬜ NOT STARTED | - | - | - |

### Wave 2: Player & Inventory (2 parallel agents)
**Dependencies:** Wave 1 Agent C must complete before starting

| Agent ID | Prompt | System | Status | Branch | Dependencies | Started | Completed |
|----------|--------|--------|--------|--------|--------------|---------|-----------|
| Agent A  | 005    | S03 Player | ⬜ NOT STARTED | - | S02 (Wave 1C) | - | - |
| Agent B  | 007    | S05 Inventory | ⬜ NOT STARTED | - | S03 (Wave 2A) | - | - |

### Wave 3: Combat Prototype (1 agent)
**Dependencies:** Wave 1 (all) + Wave 2 Agent A must complete

| Agent ID | Prompt | System | Status | Branch | Dependencies | Started | Completed |
|----------|--------|--------|--------|--------|--------------|---------|-----------|
| Agent A  | 006    | S04 Combat | ⬜ NOT STARTED | - | S01, S02, S03 | - | - |

### Wave 4: Save/Load & Weapons (2 parallel agents)
**Dependencies:** Wave 2 (all) + Wave 3 must complete

| Agent ID | Prompt | System | Status | Branch | Dependencies | Started | Completed |
|----------|--------|--------|--------|--------|--------------|---------|-----------|
| Agent A  | 008    | S06 Save/Load | ⬜ NOT STARTED | - | S03, S05 | - | - |
| Agent B  | 009    | S07 Weapons | ⬜ NOT STARTED | - | S04, S05 | - | - |

### Wave 5: Equipment (1 agent)
**Dependencies:** Wave 4 (all) must complete

| Agent ID | Prompt | System | Status | Branch | Dependencies | Started | Completed |
|----------|--------|--------|--------|--------|--------------|---------|-----------|
| Agent A  | 010    | S08 Equipment | ⬜ NOT STARTED | - | S05, S07 | - | - |

### Special: Foundation Docs (1 agent, high priority)

| Agent ID | Prompt | Output | Status | Branch | Started | Completed |
|----------|--------|--------|--------|--------|---------|-----------|
| Agent X  | 001    | Foundation Docs | ⚠️ CONFLICT | claude/foundation-vibe-philosophy-mcp-01UVRBuogjNH7JNhDyspEf64 | ✓ | ⚠️ |

**Note:** This should complete FIRST so all other agents can read the vibe-code-philosophy.md before starting work.

---

## How to Claim a Prompt

### Step 0: Verify Framework Setup Complete
**CRITICAL:** Check that "Framework Setup Status" shows all components as ✅ COMPLETE. If not, DO NOT proceed with execution work.

### Step 1: Check Dependencies
Make sure all upstream dependencies are complete before claiming.

### Step 2: Follow Framework Protocol

**BEFORE starting implementation (applies to both tiers):**
- [ ] Read `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md` (use Read tool)
- [ ] Check `COORDINATION-DASHBOARD.md` for blockers and resource locks (use Read tool)
- [ ] Search `knowledge-base/` for related solutions (use Grep/Read tools)
- [ ] Review `KNOWN-ISSUES.md` for known problems (use Read tool)

**Note:** Claude Code Web agents can READ from knowledge-base/ but should document findings in HANDOFF.md for MCP agents to use.

### Step 3: Update Coordination Files

**(Both tiers - use Edit tool):**
- [ ] Update `COORDINATION-DASHBOARD.md`: Claim work, lock resources
- [ ] Update this `PROJECT-STATUS.md` file:
  - Set Status to `🔄 IN PROGRESS`
  - Add your branch name
  - Add started timestamp

### Step 4: Create Branch & Start Work
Follow the instructions in `PARALLEL-EXECUTION-GUIDE.md`

**DURING implementation (both tiers):**
- [ ] Update `COORDINATION-DASHBOARD.md` at 25%, 50%, 75% progress (use Edit tool)
- [ ] Document any issues in `KNOWN-ISSUES.md` (use Edit tool)

### Step 5: Run Quality Gates Before Completion

**For Claude Code Web (Tier 1):**
- [ ] Validate all .gd files (syntax, type hints, documentation)
- [ ] Validate all .json files (valid JSON format)
- [ ] Create HANDOFF-[system-id].md with complete MCP agent instructions (use Write tool)
- [ ] Document any discoveries or gotchas in HANDOFF.md for MCP agent

**For Godot MCP Agents (Tier 2) - BEFORE marking complete:**
- [ ] Run `IntegrationTestSuite.run_all_tests()` (in Godot)
- [ ] Run `PerformanceProfiler.profile_system(system_id)` (in Godot)
- [ ] Run `check_quality_gates(system_id)` - ALL must pass (in Godot)
- [ ] Run `validate_checkpoint(system_id)` - Must return valid (in Godot)
- [ ] Create `knowledge-base/` entry if solved non-trivial problem (use Write tool)
- [ ] Save checkpoint to Basic Memory MCP (if available)

### Step 6: Mark Complete

**For Claude Code Web (Tier 1):**
When all files are created and HANDOFF.md is complete:
- [ ] Update `COORDINATION-DASHBOARD.md`: Mark Tier 1 complete, ready for handoff (use Edit tool)
- [ ] Update this `PROJECT-STATUS.md` file: Note Tier 1 complete (use Edit tool)
- [ ] Commit and push your changes (use Bash tool)

**For Godot MCP Agents (Tier 2):**
When ALL quality gates pass:
- [ ] Update `COORDINATION-DASHBOARD.md`: Mark complete, release locks, unblock dependencies (use Edit tool)
- [ ] Update this `PROJECT-STATUS.md` file:
  - Set Status to `✅ COMPLETE`
  - Add completed timestamp (use Edit tool)
- [ ] Commit and push your changes (use Bash tool)

---

## Integration Plan

After all waves complete:

1. **Create integration branch:**
   ```bash
   git checkout main
   git checkout -b claude/integrate-job2-all-systems
   ```

2. **Merge in dependency order:**
   - Wave 1: 002, 003, 004
   - Wave 2: 005, 007
   - Wave 3: 006
   - Wave 4: 008, 009
   - Wave 5: 010

3. **Test integration:**
   - Run all test scenes
   - Verify all systems work together
   - Check for conflicts

4. **Merge to main:**
   ```bash
   git checkout main
   git merge claude/integrate-job2-all-systems
   git tag v0.1.0-job2-complete
   git push origin main --tags
   ```

---

## Files & Directory Structure

### Current Repository Structure
```
vibe-code-game/
├── README.md                               # Meta-prompting system docs
├── PROJECT-STATUS.md                       # This file (execution tracking)
├── PARALLEL-EXECUTION-GUIDE.md             # How to execute prompts in parallel
├── create-prompt.md                        # Prompt creation system
├── run-prompt.md                           # Prompt execution system
├── rhythm-rpg-implementation-guide.md      # Complete game specification (26 systems)
├── prompts/                                # All generated prompts (READ ONLY during execution)
│   ├── 001-foundation-vibe-philosophy-mcp-reference.md
│   ├── 002-combat-specification.md
│   ├── 003-s01-conductor-rhythm-system.md
│   ├── 004-s02-controller-input-system.md
│   ├── 005-s03-player-controller.md
│   ├── 006-s04-combat-prototype.md
│   ├── 007-s05-inventory-system.md
│   ├── 008-s06-save-load-system.md
│   ├── 009-s07-weapons-database.md
│   └── 010-s08-equipment-system.md
└── (Godot project files will be created during execution)
```

### Expected Structure After Execution
```
vibe-code-game/
├── (all the above files)
├── vibe-code-philosophy.md                 # OUTPUT from prompt 001
├── godot-mcp-command-reference.md          # OUTPUT from prompt 001
├── combat-specification.md                 # OUTPUT from prompt 002
├── project.godot                           # Godot project file
├── res/                                    # Godot resources
│   ├── autoloads/                          # S01, S02, S06, S07 autoloads
│   │   ├── conductor.gd
│   │   ├── input_manager.gd
│   │   ├── save_manager.gd
│   │   └── item_database.gd
│   ├── player/                             # S03, S08
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   └── equipment_manager.gd
│   ├── combat/                             # S04
│   │   ├── combat_arena.tscn
│   │   ├── combatant.gd
│   │   └── ui/health_bar.tscn
│   ├── inventory/                          # S05
│   │   └── inventory.gd
│   ├── items/                              # S05
│   │   └── item_pickup.tscn
│   ├── resources/                          # S07
│   │   ├── weapon_resource.gd
│   │   └── shield_resource.gd
│   ├── ui/                                 # S05, S08
│   │   ├── inventory_ui.tscn
│   │   └── equipment_panel.tscn
│   ├── data/                               # All JSON configs
│   │   ├── rhythm_config.json
│   │   ├── input_config.json
│   │   ├── player_config.json
│   │   ├── combat_config.json
│   │   ├── items.json
│   │   ├── weapons.json
│   │   ├── shields.json
│   │   └── equipment.json
│   ├── tests/                              # All test scenes
│   │   ├── test_conductor.tscn
│   │   ├── test_input.tscn
│   │   ├── test_movement.tscn
│   │   ├── test_combat.tscn
│   │   ├── test_inventory.tscn
│   │   ├── test_save_load.tscn
│   │   ├── test_weapons.tscn
│   │   └── test_equipment.tscn
│   └── debug/                              # Debug overlays (optional)
│       ├── rhythm_debug_overlay.tscn
│       └── input_debug_overlay.tscn
└── addons/                                 # Godot plugins
    ├── rhythm_notifier/                    # S01
    ├── gloot/                              # S05
    └── (others as needed)
```

---

## Next Steps

### Immediate (Wave 1)
1. **Resolve prompt 001 conflict** (Agent 2)
2. **Start Wave 1 execution** (3 agents can start immediately)
   - Prompt 002: Combat Specification
   - Prompt 003: S01 Conductor/Rhythm System
   - Prompt 004: S02 Controller Input System

### After Wave 1 Completes
3. **Start Wave 2 execution** (2 agents)
   - Prompt 005: S03 Player Controller
   - Prompt 007: S05 Inventory System

### After Wave 2 Completes
4. **Start Wave 3 execution** (1 agent)
   - Prompt 006: S04 Combat Prototype

### After Wave 3 Completes
5. **Start Wave 4 execution** (2 agents)
   - Prompt 008: S06 Save/Load System
   - Prompt 009: S07 Weapons Database

### After Wave 4 Completes
6. **Start Wave 5 execution** (1 agent)
   - Prompt 010: S08 Equipment System

### After Job 2 Complete (All 5 Waves)
7. **Integration & Testing for Job 2**
8. **Tag release: v0.1.0-job2-complete**
9. **Begin Job 3** (Prompts 011-020, Systems S09-S18)

### Job 3 Execution
10. **Execute Job 3 in parallel waves** (10 prompts, Systems S09-S18)
    - Combat depth: Dodge/Block (S09), Special Moves (S10)
    - Enemy AI (S11), Monster Database (S12)
    - Health/Vibe UI (S13)
    - Tools (S14), Vehicles (S15), Grind Rails (S16)
    - Puzzles (S17), Polyrhythmic Environment (S18)

### After Job 3 Complete
11. **Integration & Testing for Job 3**
12. **Tag release: v0.2.0-job3-complete**
13. **Begin Job 4** (Prompts 021-029, Systems S19-S26 + Build Strategy)

### Job 4 Execution
14. **Execute Job 4 in parallel waves** (9 prompts, Systems S19-S26)
    - XP & Leveling (S19), Monster Evolution (S20)
    - Resonance & Alignment (S21), NPCs (S22)
    - Story Progression (S23)
    - Cooking (S24), Crafting (S25)
    - Rhythm Mini-Games (S26)
    - Parallel Build Orchestration (029)

### After ALL Jobs Complete
15. **Final Integration & Testing** (All 26 systems)
16. **Tag release: v1.0.0-all-systems-complete**
17. **Polish & Optimization Phase**

---

## Questions?

- See `PARALLEL-EXECUTION-GUIDE.md` for detailed execution instructions
- See `rhythm-rpg-implementation-guide.md` for complete game specification
- See individual prompt files in `prompts/` for system-specific details

---

**Status Legend:**
- ⬜ NOT STARTED
- 🔄 IN PROGRESS
- ✅ COMPLETE
- ⚠️ BLOCKED/ISSUE

---

**Last Status Update:** 2025-11-17 (Prompts created, ready for execution)
