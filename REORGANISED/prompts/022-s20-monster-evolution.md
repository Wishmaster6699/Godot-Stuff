<objective>
Implement Monster Evolution System (S20) - layered evolution with level-based (Pokemon-style), tool-based (hold item), Soul Shard (temporary boss forms), and hybrid stat growth influenced by player playstyle.

DEPENDS ON: S12 (Monster Database), S04 (Combat), S19 (Dual XP for leveling)
WAVE 2 - Can run in parallel with S21
</objective>

<context>
Evolution extends the Monster Database (S12) with multiple evolution triggers and stat customization.

Reference:
@rhythm-rpg-implementation-guide.md
@vibe-code-philosophy.md @godot-mcp-command-reference.md
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S20")`
- [ ] Quality gates: `check_quality_gates("S20")`
- [ ] Checkpoint validation: `validate_checkpoint("S20")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S20", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Evolution System
Create `res://systems/evolution_system.gd`:
- Level-based: Check after battle, evolve at specific level
- Tool-based: Hold item + use triggers permanent evolution
- Soul Shard: Temporary form during combat (reverts after)

### 2. Evolution Configuration
```json
{
  "evolution_config": {
    "level_evolutions": {
      "001_sparkle": { "level": 16, "evolves_into": "002_voltix" }
    },
    "tool_evolutions": {
      "001_sparkle": { "tool": "thunder_stone", "evolves_into": "003_thunderlord" }
    },
    "soul_shards": {
      "boss_thunder": { "grants_form": "thunder_soul_form", "duration_battles": 3 }
    }
  }
}
```

### 3. Hybrid Stat Growth
Player playstyle influences evolved stats:
- Combat-heavy → Higher Attack
- Puzzle-heavy → Higher Special Attack
- Balanced → Even distribution

### 4. Test Scene
- Level-based evolution trigger
- Tool evolution with thunder stone
- Soul shard temporary transformation

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://systems/evolution_system.gd` - Complete evolution manager with level-based, tool-based, and Soul Shard evolution triggers
   - Hybrid stat growth influenced by XP type ratio (from S19)
   - Evolution animations and state management
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/evolution_config.json` - Complete evolution configuration with level evolutions, tool evolutions, and Soul Shard forms
   - Valid JSON format with all required fields

3. **Create HANDOFF-S20.md** documenting:
   - Scene structures needed (test scene for evolution triggers)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://systems/evolution_system.gd` - Complete evolution system implementation
- `res://data/evolution_config.json` - Evolution configuration data
- `HANDOFF-S20.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S20.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_evolution.tscn
   - `add_node` - Build node hierarchies for test scenes
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S20.md` with this structure:

```markdown
# System S20 Handoff - Monster Evolution System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://systems/evolution_system.gd` - Evolution manager with level-based, tool-based, and Soul Shard triggers

### Data Files
- `res://data/evolution_config.json` - Evolution configuration with level evolutions, tool evolutions, Soul Shard forms

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_evolution.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_evolution.tscn", "Node2D", "TestEvolution")

# Add UI elements for testing
add_node("TestEvolution", "Label", "EvolutionStatus")
add_node("TestEvolution", "Label", "MonsterStats")
add_node("TestEvolution", "Button", "TriggerLevelEvolution")
add_node("TestEvolution", "Button", "TriggerToolEvolution")
add_node("TestEvolution", "Button", "TriggerSoulShard")

# Configure properties
update_property("TestEvolution/EvolutionStatus", "position", Vector2(10, 10))
update_property("TestEvolution/MonsterStats", "position", Vector2(10, 40))
update_property("TestEvolution/TriggerLevelEvolution", "position", Vector2(10, 100))
update_property("TestEvolution/TriggerLevelEvolution", "text", "Trigger Level Evolution")
update_property("TestEvolution/TriggerToolEvolution", "position", Vector2(10, 140))
update_property("TestEvolution/TriggerToolEvolution", "text", "Trigger Tool Evolution")
update_property("TestEvolution/TriggerSoulShard", "position", Vector2(10, 180))
update_property("TestEvolution/TriggerSoulShard", "text", "Trigger Soul Shard")
```

**Node Hierarchy:**
```
TestEvolution (Node2D)
├── EvolutionStatus (Label)
├── MonsterStats (Label)
├── TriggerLevelEvolution (Button)
├── TriggerToolEvolution (Button)
└── TriggerSoulShard (Button)
```

---

## Integration Points

### Signals Exposed:
- `evolution_triggered(monster_id: String, new_form: String)` - Emitted when evolution starts
- `evolution_complete(monster_id: String)` - Emitted when evolution finishes
- `soul_shard_applied(monster_id: String, form: String, duration: int)` - Emitted for temporary forms

### Public Methods:
- `check_level_evolution(monster_id: String, level: int) -> bool` - Check if monster can evolve
- `trigger_tool_evolution(monster_id: String, tool_id: String) -> bool` - Trigger tool-based evolution
- `apply_soul_shard(monster_id: String, shard_id: String)` - Apply temporary Soul Shard form
- `calculate_hybrid_stats(monster_id: String, xp_ratio: Dictionary) -> Dictionary` - Calculate evolved stats based on playstyle

### Dependencies:
- Depends on: S12 (Monster Database), S04 (Combat), S19 (Dual XP)
- Depended on by: S22 (NPCs can gift evolution items)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_evolution.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] Level-based evolution triggers at correct level
- [ ] Tool + monster = permanent evolution
- [ ] Soul Shard grants temporary form (reverts after battles)
- [ ] Hybrid stats influenced by XP type ratio (S19)
- [ ] Evolution animation plays
- [ ] Evolved monster has updated stats
- [ ] Integration with S12 Monster Database works
- [ ] Integration with S19 Dual XP works
- [ ] evolution_config.json loads correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Hybrid Stat Growth**: Use XP type ratios from S19 to influence evolved stats (combat XP → physical, knowledge XP → special)
- **Soul Shard Duration**: Temporary forms revert after specified number of battles
- **Tool Evolution**: Requires both monster and tool item in inventory
- **Level Evolution**: Check after every battle when monster gains XP

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S20 complete and unblock S22.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S20.md, verify:

### Code Quality
- [ ] evolution_system.gd created with complete implementation (no TODOs or placeholders)
- [ ] evolution_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Level-based evolution logic implemented
- [ ] Tool-based evolution logic implemented
- [ ] Soul Shard temporary form logic implemented
- [ ] Hybrid stat growth calculation implemented
- [ ] Integration with S12 and S19 documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (systems/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S20.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All evolution types configurable from evolution_config.json
- [ ] No hardcoded evolution data in evolution_system.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] test_evolution.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S20")`
- [ ] Quality gates passed: `check_quality_gates("S20")`
- [ ] Checkpoint validated: `validate_checkpoint("S20")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Level-based evolution triggers at correct level
- [ ] Tool + monster = permanent evolution
- [ ] Soul Shard grants temporary form (reverts after battles)
- [ ] Hybrid stats influenced by XP type ratio (S19)
- [ ] Evolution animation plays
- [ ] Evolved monster has updated stats
- [ ] Integration with S12 Monster Database works
- [ ] Integration with S19 Dual XP works
- [ ] evolution_config.json loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ evolution_system.gd complete with all evolution triggers (level, tool, Soul Shard)
- ✅ evolution_config.json complete with all evolution data
- ✅ Hybrid stat growth logic based on XP type ratios
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S20.md provides clear MCP agent instructions
- ✅ All evolution data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Level-based evolution triggers correctly after battles
- ✅ Tool-based evolution requires both monster and item
- ✅ Soul Shard temporary forms revert after specified battles
- ✅ Hybrid stat growth reflects player playstyle (combat vs knowledge XP)
- ✅ Evolution animations play smoothly
- ✅ Integrates with S12 Monster Database for base stats
- ✅ Integrates with S19 Dual XP for stat growth influence
- ✅ System ready for S22 (NPCs can gift evolution items)

</success_criteria>

<memory_checkpoint_format>
```
System S20 (Monster Evolution) Complete

FILES:
- res://systems/evolution_system.gd
- res://data/evolution_config.json

EVOLUTION TYPES:
1. Level-based (Pokemon-style)
2. Tool-based (hold item to evolve)
3. Soul Shard (temporary boss forms)

HYBRID STAT GROWTH:
- Combat XP ratio → Physical stats
- Knowledge XP ratio → Special stats

STATUS: Ready for S22 (NPCs can gift evolution items)
```
</memory_checkpoint_format>
