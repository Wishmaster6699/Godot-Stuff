<objective>
Create comprehensive Parallel Build Strategy document for coordinating multiple LLM agents building all 26 game systems (S01-S26) with optimal parallelization, dependency management, and conflict resolution.

This is a META-DOCUMENT that guides the overall build process.
</objective>

<context>
With 26 systems to build, sequential execution would take 26+ days. A parallel build strategy with 5-7 agents can complete in 12-14 days. This document provides the coordination framework.

Reference:
@rhythm-rpg-implementation-guide.md (all 26 systems)
@vibe-code-philosophy.md (workflow principles)
@PARALLEL-EXECUTION-GUIDE.md (execution mechanics)
</context>

<framework_integration>

## AI Development Success Framework

**BEFORE STARTING**, read and follow:
- @AI-VIBE-CODE-SUCCESS-FRAMEWORK.md (Complete quality/coordination framework)

### Pre-Work Checklist
- [ ] Check `COORDINATION-DASHBOARD.md` for blockers, active work, and resource locks
- [ ] Search `knowledge-base/` for related issues or solutions
- [ ] Review `KNOWN-ISSUES.md` for this system's known problems
- [ ] Update `COORDINATION-DASHBOARD.md`: Claim work, lock any shared resources

### During Implementation
- [ ] Update `COORDINATION-DASHBOARD.md` at 25%, 50%, 75% progress milestones
- [ ] Document any issues discovered in `KNOWN-ISSUES.md`
- [ ] Use placeholder assets (see `ASSET-PIPELINE.md`) - don't wait for final art

### Before Marking Complete
Run all quality gates (see expanded verification section below):
- [ ] Integration tests: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: Verify overall build coordination efficiency
- [ ] Quality gates: Ensure all 26 systems integrated successfully
- [ ] Checkpoint validation: Validate final build state
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: Review checkpoint history for affected systems
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Document Structure

Create `./parallel-build-strategy.md` with these sections:

### 1. Executive Summary
- Total systems: 26
- Sequential time: 26+ days (1 agent)
- Parallel time: 12-14 days (5-7 agents optimal)
- Critical path: S01→S02→S03→S04→(branches)
- Maximum parallelization: 7 agents in Stage 3

### 2. Build Stages (7 Stages Total)

**Stage 1: Foundation (Sequential) - Days 1-2**
```
CRITICAL: One agent only, blocks everything
- Agent A: 003 (S01 Conductor) → 004 (S02 Input) → 005 (S03 Player)
- Duration: 2 days
- Blocks: ALL other systems
```

**Stage 2: Core Systems (3 Parallel) - Days 3-4**
```
- Agent A: 006 (S04 Combat Prototype)
- Agent B: 007 (S05 Inventory) → 008 (S06 Save/Load)
- Agent C: 021 (S19 Dual XP - data only)
- Duration: 1.5 days
```

**Stage 3: Combat Expansion (7 PARALLEL!) - Days 5-8**
```
- Agent A: 009 (S07 Weapons) → 010 (S08 Equipment)
- Agent B: 011 (S09 Dodge/Block)
- Agent C: 012 (S10 Special Moves)
- Agent D: 013 (S11 Enemy AI) → 014 (S12 Monsters)
- Agent E: 015 (S13 Vibe Bar)
- Agent F: 026 (S24 Cooking)
- Agent G: 027 (S25 Crafting)
- Duration: 3.5 days
```

**Stage 4: Progression Systems (4 Parallel) - Days 9-11**
```
- Agent A: 022 (S20 Evolution)
- Agent B: 023 (S21 Alignment)
- Agent C: 028 (S26 Rhythm Mini-Games)
- Agent D: 016 (S14 Tools)
- Duration: 2.5 days
```

**Stage 5: World Interaction (5 Parallel) - Days 12-14**
```
- Agent A: 019 (S17 Puzzles) - needs S14 complete
- Agent B: 017 (S15 Vehicles)
- Agent C: 018 (S16 Grind Rails)
- Agent D: 020 (S18 Polyrhythm)
- Agent E: 024 (S22 NPCs) - needs S21 complete
- Duration: 2.5 days
```

**Stage 6: Story (1 Sequential) - Days 15-16**
```
- Agent A: 025 (S23 Player Progression/Story)
- Duration: 1.5 days
- Depends on: S22 (NPCs), S21 (Alignment)
```

**Stage 7: Final Integration - Days 17-18**
```
- All agents: Integration testing
- Merge all branches
- Resolve conflicts
- Final verification
- Duration: 1.5 days
```

### 3. Coordination Rules

**Rule 1: Memory-Based Dependency Checking**
Before starting any system:
```gdscript
func check_dependencies(system_id: String) -> bool:
  var deps = get_dependencies(system_id)
  for dep in deps:
    var status = query_memory("system_" + dep + "_status")
    if status != "complete":
      return false
  return true
```

**Rule 2: Signal-Only Communication**
Systems communicate via Godot signals, never direct calls:
```gdscript
# BAD (direct call)
CombatSystem.apply_damage(10)

# GOOD (signal)
damage_requested.emit(10)
```

**Rule 3: Shared Resource Locking**
When editing shared files (Player, Conductor):
```
1. Check memory: is_file_locked("res://player/player.gd")
2. If locked, wait or work on different system
3. If available: lock_file("res://player/player.gd", "Agent_A", "S04")
4. Make edits
5. Unlock: unlock_file("res://player/player.gd")
```

**Rule 4: Checkpoint Format**
```json
{
  "system_id": "S04",
  "status": "complete",
  "agent": "Agent_A",
  "completion_date": "2025-11-20",
  "files_created": [
    "res://combat/combat_arena.tscn",
    "res://combat/combatant.gd"
  ],
  "signals_exposed": [
    "combat_started",
    "damage_taken(amount)",
    "combat_ended(winner)"
  ],
  "integration_points": {
    "uses": ["S01_Conductor", "S02_Input", "S03_Player"],
    "used_by": ["S09_Dodge", "S10_Special", "S19_XP"]
  },
  "next_systems_unblocked": ["S07", "S08", "S09", "S10", "S11", "S13", "S19"]
}
```

**Rule 5: Test-Then-Checkpoint**
Only mark "complete" after ALL verification criteria pass:
```
1. Implement system
2. Run test scene
3. Verify all criteria (8+ checks)
4. If all pass: checkpoint with status="complete"
5. If any fail: debug, retry, don't checkpoint yet
```

### 4. Conflict Resolution

**Scenario 1: Two agents edit same file**
- Use Git branches (one per agent)
- Merge conflicts: Later agent merges earlier agent's changes
- Critical files (Player, Conductor): Use locking system

**Scenario 2: Dependency not ready**
- Check memory before starting
- If dependency incomplete: work on different system or wait
- Don't implement stubs (causes integration issues)

**Scenario 3: System blocks multiple others**
- S04 Combat blocks 10+ systems
- Prioritize blockers in early stages
- Assign most experienced agent to blocker systems

### 5. Stage Transition Protocol

When transitioning between stages:
```
1. All agents: Complete current stage systems
2. Lead agent: Verify all checkpoints marked "complete"
3. Integration test: Quick test of stage systems together
4. If tests pass: Proceed to next stage
5. If tests fail: Debug collectively, don't proceed
```

### 6. Daily Stand-Up Format

Each agent reports:
```
- System I'm working on: S0X
- Progress: X% (based on implementation steps completed)
- Blocked by: [dependency or resource lock]
- Will complete by: [date/time]
- Next system: S0Y (if current finishes early)
```

### 7. Critical Path Analysis

The critical path (longest dependency chain):
```
S01 (2d) → S02 (0.5d) → S03 (1d) → S04 (1.5d) → S11 (1d) → S12 (2.5d) →
S20 (1d) → S21 (1d) → S22 (1.5d) → S23 (1.5d)

Total Critical Path: ~13 days
```

All other systems can run in parallel off this path.

### 8. Optimization Strategies

**Early Parallelization:**
- Stage 3 has 7 parallel agents (maximum)
- Reduces build time by 4+ days vs sequential

**Smart Agent Assignment:**
- Blocker systems (S04, S11, S21): Assign to fastest agents
- Content systems (S24, S25): Can be slower, less critical

**Overlap Stages:**
- Don't wait for entire stage to complete
- If S04 completes early in Stage 2, start Stage 3 immediately

### 9. Final Integration Checklist

Before declaring build complete:
- [ ] All 26 systems have checkpoints marked "complete"
- [ ] Integration test scene runs all systems together
- [ ] No merge conflicts remaining
- [ ] All test scenes pass
- [ ] Save/Load works with all systems
- [ ] Performance acceptable (60fps target)
- [ ] Memory usage reasonable (<500MB)
- [ ] Documentation complete (all checkpoints have notes)

### 10. Time Estimates by Agent Count

| Agents | Duration | Strategy |
|--------|----------|----------|
| 1 | 26+ days | Sequential, no parallelization |
| 3 | 16-18 days | Limited parallelization (max 3 in Stage 3) |
| 5 | 12-14 days | Good parallelization (5 in Stage 3) |
| 7 | 11-13 days | Optimal parallelization (7 in Stage 3) |
| 10+ | 11-13 days | No benefit (dependency bottleneck) |

**Recommendation:** 5-7 agents is optimal cost/time balance.

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create the comprehensive parallel build strategy document.

### Your Tasks:
1. **Create documentation file** using the Write tool
   - `./parallel-build-strategy.md` - Complete parallel build strategy document
   - All sections: Executive Summary, 7 Build Stages, Coordination Rules, etc.
   - Detailed agent assignments, dependency graphs, time estimates
   - Conflict resolution protocols and optimization strategies

2. **Create HANDOFF-029.md** documenting:
   - Confirmation that this is a meta-document (no scenes needed)
   - Verification steps (document completeness check)
   - Review checklist for strategy document

### Your Deliverables:
- `./parallel-build-strategy.md` - Complete parallel build strategy
- `HANDOFF-029.md` - Brief handoff noting this is documentation only

### You Do NOT:
- Create .tscn files (this is pure documentation)
- Create .gd files (this is strategy documentation, not code)
- Use MCP commands (no Godot integration needed)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-029.md
2. Verify document completeness (no scene configuration needed)
3. Update COORDINATION-DASHBOARD.md with completion status
4. Note: This is a meta-document - no Godot testing required

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-029.md` with this structure:

```markdown
# System 029 Handoff - Parallel Build Strategy (Meta-Document)

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Documentation Complete

---

## Files Created (Tier 1 Complete)

### Documentation Files
- `./parallel-build-strategy.md` - Complete parallel build strategy document

**Note:** This is a meta-document about build coordination, not a game system implementation.

---

## No Scene Configuration Needed

This prompt creates strategic documentation for coordinating parallel development.
No Godot scenes, scripts, or testing required.

---

## Verification Checklist (MCP Agent)

Verify documentation completeness:

- [ ] parallel-build-strategy.md exists and is readable
- [ ] Executive Summary present (total systems, timelines, critical path)
- [ ] All 7 build stages documented with agent assignments
- [ ] 5 coordination rules documented with code examples
- [ ] Conflict resolution scenarios covered (3+ scenarios)
- [ ] Stage transition protocol documented
- [ ] Daily stand-up format provided
- [ ] Critical path analysis included (13-day chain identified)
- [ ] Optimization strategies explained
- [ ] Final integration checklist comprehensive (9+ items)
- [ ] Time estimates table included (1, 3, 5, 7 agents)
- [ ] Document is actionable (agents can follow it)

---

## Integration Points

This document coordinates the entire 26-system build process.

### Dependencies:
- Depends on: All 26 system specifications (S01-S26)
- Depended on by: None (final meta-document)

---

## Notes / Gotchas

- **This is Documentation Only**: No code, scenes, or Godot testing
- **Purpose**: Coordinate multi-agent parallel development of all 26 systems
- **Usage**: Teams of 1-7 agents can use this to parallelize work
- **Critical Path**: 13 days (S01→S02→S03→S04→S11→S12→S20→S21→S22→S23)

---

**Next Steps:** MCP agent should verify document completeness, then update COORDINATION-DASHBOARD.md to mark 029 complete.

**ALL 29 PROMPTS NOW COMPLETE WITH TWO-TIER WORKFLOW!**
```

</handoff_requirements>

<output_format>

The final document should be structured as:

```markdown
# Parallel Build Strategy - Rhythm RPG (26 Systems)

## Executive Summary
[High-level overview, timelines, recommendations]

## Stage Breakdown
[7 stages with agent assignments, durations, dependencies]

## Coordination Framework
[5 coordination rules with code examples]

## Conflict Resolution
[3 common scenarios with solutions]

## Stage Transition Protocol
[How to move between stages safely]

## Daily Stand-Up Format
[Agent reporting template]

## Critical Path Analysis
[Longest dependency chain, timeline]

## Optimization Strategies
[How to minimize build time]

## Final Integration Checklist
[Pre-release verification]

## Time Estimates
[Table of agent count vs duration]

## Appendix: System Dependency Graph
[Visual dependency tree for all 26 systems]

## Appendix: Agent Assignment Matrix
[Which agent works on which systems per stage]
```

</output_format>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-029.md, verify:

### Documentation Quality
- [ ] parallel-build-strategy.md created with complete content (no TODOs or placeholders)
- [ ] Executive Summary included (total systems, timelines, critical path)
- [ ] All 7 build stages documented with agent assignments and durations
- [ ] 5 coordination rules documented with code examples
- [ ] Conflict resolution scenarios covered (minimum 3 scenarios)
- [ ] Stage transition protocol documented
- [ ] Daily stand-up format provided
- [ ] Critical path analysis included (13-day chain identified)
- [ ] Optimization strategies explained
- [ ] Final integration checklist comprehensive (9+ items)
- [ ] Time estimates table included (1, 3, 5, 7 agents)
- [ ] Appendices included (dependency graph, agent assignment matrix)

### Framework Quality Gates (Documentation Phase)
- [ ] Document follows markdown best practices
- [ ] All sections clearly organized and readable
- [ ] Code examples properly formatted
- [ ] HANDOFF-029.md created noting this is documentation only
- [ ] Knowledge base entry created if coordination patterns are novel

### System-Specific Verification (Documentation Completeness)
- [ ] Document is actionable (agents can follow it to coordinate work)
- [ ] Agent assignments clear for each stage
- [ ] Dependency chains explicit
- [ ] Conflict resolution protocols practical
- [ ] Time estimates realistic and justified

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Documentation Verification
- [ ] parallel-build-strategy.md exists and is readable
- [ ] All required sections present and complete
- [ ] No broken formatting or incomplete tables
- [ ] Document serves its purpose (coordination guide)

### Framework Quality Gates (Documentation Review Phase)
- [ ] Document quality verified (no major omissions)
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete"
- [ ] Knowledge base entry created if coordination insights documented

### System-Specific Verification (Meta-Document Review)
- [ ] All 7 stages clearly defined
- [ ] Agent assignments practical and optimal
- [ ] Critical path accurately identified
- [ ] Time estimates reasonable
- [ ] Coordination rules clear and enforceable
- [ ] Conflict scenarios realistic
- [ ] Document can be used by teams immediately

**Note:** No code testing, scene configuration, or Godot integration required. This is pure documentation verification.

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ parallel-build-strategy.md complete with all required sections
- ✅ Executive Summary with total systems, timelines, and critical path
- ✅ All 7 build stages documented with durations and agent assignments
- ✅ 5 coordination rules with practical code examples
- ✅ Conflict resolution scenarios (3+) with solutions
- ✅ Stage transition protocol clear
- ✅ Daily stand-up format provided
- ✅ Critical path identified (13 days: S01→S02→S03→S04→S11→S12→S20→S21→S22→S23)
- ✅ Optimization strategies explained
- ✅ Final integration checklist comprehensive
- ✅ Time estimates table (1, 3, 5, 7+ agents)
- ✅ Document is actionable and clear
- ✅ HANDOFF-029.md notes this is documentation only

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Documentation verified as complete
- ✅ All sections present and readable
- ✅ Document serves its coordination purpose
- ✅ Teams can use this to parallelize development
- ✅ COORDINATION-DASHBOARD.md updated (029 complete)
- ✅ ALL 29 PROMPTS WITH TWO-TIER WORKFLOW COMPLETE

This meta-document enables efficient parallel development of all 26 game systems.

**FINAL STATUS: All 29 prompts now have complete two-tier workflow integration!**

</success_criteria>

<success_criteria>

Success means:
1. **Any team of N agents** can use this document to build the game
2. **Coordination is clear** - no ambiguity about who does what when
3. **Conflicts are preventable** - rules prevent most issues
4. **Timeline is accurate** - estimates match reality ±2 days
5. **Critical path is optimized** - no unnecessary bottlenecks

This document is the final piece enabling distributed development of the Rhythm RPG.

</success_criteria>

<memory_checkpoint_format>

When complete, this prompt will have created:

```
Parallel Build Strategy Complete

FILE CREATED:
- ./parallel-build-strategy.md

CONTENTS:
- 7 build stages (1-2 days to 17-18 days)
- Agent assignments per stage
- 5 coordination rules
- Conflict resolution protocols
- Checkpoint format (JSON schema)
- Critical path: 13 days
- Time estimates: 1 agent (26d), 5 agents (12-14d), 7 agents (11-13d)

FINAL DELIVERABLE:
Complete framework for multi-agent parallel development of all 26 systems.

JOB 4 COMPLETE
ALL 4 JOBS COMPLETE
STATUS: Rhythm RPG fully specified, ready for distributed implementation!
```

</memory_checkpoint_format>
