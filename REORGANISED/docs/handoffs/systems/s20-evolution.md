# System S20 Handoff - Monster Evolution System

**Created by:** Claude Code Web
**Date:** 2025-11-18
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `src/systems/s20-evolution/evolution_system.gd` - Complete evolution manager with:
  - Level-based evolution (Pokemon-style)
  - Tool-based evolution (hold item + use)
  - Soul Shard temporary transformations
  - Hybrid stat growth influenced by S19 Dual XP ratios
  - Evolution animation state management
  - Full type hints, documentation, error handling

### Data Files
- `data/evolution_config.json` - Complete evolution configuration with:
  - Level evolutions (10 evolution chains)
  - Tool evolutions (10 tool-based evolutions)
  - Soul Shards (8 temporary boss forms)
  - Hybrid stat growth scaling
  - Evolution requirements and animations
  - Valid JSON format with all required fields

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_evolution.tscn`

**MCP Agent Commands:**

```gdscript
# Create test scene for evolution testing
create_scene("res://tests/test_evolution.tscn", "Node2D")

# Add UI container
add_node("TestEvolution", "VBoxContainer", "UIContainer")
update_property("TestEvolution/UIContainer", "position", Vector2(10, 10))
update_property("TestEvolution/UIContainer", "size", Vector2(400, 600))

# Add status labels
add_node("TestEvolution/UIContainer", "Label", "EvolutionStatus")
add_node("TestEvolution/UIContainer", "Label", "MonsterStats")
add_node("TestEvolution/UIContainer", "Label", "SoulShardStatus")
add_node("TestEvolution/UIContainer", "Label", "HybridStatsDisplay")

# Configure labels
update_property("TestEvolution/UIContainer/EvolutionStatus", "text", "Evolution Status: Ready")
update_property("TestEvolution/UIContainer/MonsterStats", "text", "Monster: None")
update_property("TestEvolution/UIContainer/SoulShardStatus", "text", "Soul Shard: None")
update_property("TestEvolution/UIContainer/HybridStatsDisplay", "text", "Hybrid Stats: N/A")

# Add test buttons
add_node("TestEvolution/UIContainer", "Button", "TriggerLevelEvolution")
add_node("TestEvolution/UIContainer", "Button", "TriggerToolEvolution")
add_node("TestEvolution/UIContainer", "Button", "TriggerSoulShard")
add_node("TestEvolution/UIContainer", "Button", "RevertSoulShard")
add_node("TestEvolution/UIContainer", "Button", "TestCombatHeavy")
add_node("TestEvolution/UIContainer", "Button", "TestKnowledgeHeavy")
add_node("TestEvolution/UIContainer", "Button", "TestBalanced")

# Configure buttons
update_property("TestEvolution/UIContainer/TriggerLevelEvolution", "text", "Test Level Evolution (Sparkle → Voltix)")
update_property("TestEvolution/UIContainer/TriggerToolEvolution", "text", "Test Tool Evolution (Thunder Stone)")
update_property("TestEvolution/UIContainer/TriggerSoulShard", "text", "Apply Soul Shard (Boss Thunder)")
update_property("TestEvolution/UIContainer/RevertSoulShard", "text", "Revert Soul Shard Early")
update_property("TestEvolution/UIContainer/TestCombatHeavy", "text", "Test Combat-Heavy Stats (80/20)")
update_property("TestEvolution/UIContainer/TestKnowledgeHeavy", "text", "Test Knowledge-Heavy Stats (20/80)")
update_property("TestEvolution/UIContainer/TestBalanced", "text", "Test Balanced Stats (50/50)")

# Attach test script (will be created by Tier 2)
# create_script("res://tests/test_evolution_scene.gd")
# attach_script("TestEvolution", "res://tests/test_evolution_scene.gd")
```

**Node Hierarchy:**
```
TestEvolution (Node2D)
└── UIContainer (VBoxContainer)
    ├── EvolutionStatus (Label)
    ├── MonsterStats (Label)
    ├── SoulShardStatus (Label)
    ├── HybridStatsDisplay (Label)
    ├── TriggerLevelEvolution (Button)
    ├── TriggerToolEvolution (Button)
    ├── TriggerSoulShard (Button)
    ├── RevertSoulShard (Button)
    ├── TestCombatHeavy (Button)
    ├── TestKnowledgeHeavy (Button)
    └── TestBalanced (Button)
```

### Scene 2: Test Script for Evolution Scene

The MCP agent should create `res://tests/test_evolution_scene.gd`:

```gdscript
extends Node2D

var evolution_system: MonsterEvolutionSystem
var current_monster_id := "001_sparkle"
var current_level := 16

func _ready() -> void:
	# Get evolution system reference
	evolution_system = MonsterEvolutionSystem.new()
	add_child(evolution_system)

	# Load config
	evolution_system._load_evolution_config()

	# Connect button signals
	$UIContainer/TriggerLevelEvolution.pressed.connect(_on_level_evolution_pressed)
	$UIContainer/TriggerToolEvolution.pressed.connect(_on_tool_evolution_pressed)
	$UIContainer/TriggerSoulShard.pressed.connect(_on_soul_shard_pressed)
	$UIContainer/RevertSoulShard.pressed.connect(_on_revert_soul_shard_pressed)
	$UIContainer/TestCombatHeavy.pressed.connect(_on_combat_heavy_pressed)
	$UIContainer/TestKnowledgeHeavy.pressed.connect(_on_knowledge_heavy_pressed)
	$UIContainer/TestBalanced.pressed.connect(_on_balanced_pressed)

	# Connect evolution signals
	evolution_system.evolution_triggered.connect(_on_evolution_triggered)
	evolution_system.evolution_complete.connect(_on_evolution_complete)
	evolution_system.soul_shard_applied.connect(_on_soul_shard_applied)
	evolution_system.soul_shard_reverted.connect(_on_soul_shard_reverted)

	_update_ui()

func _on_level_evolution_pressed() -> void:
	var xp_ratio := {"combat_ratio": 0.5, "knowledge_ratio": 0.5}
	var new_form := evolution_system.trigger_level_evolution(current_monster_id, current_level, xp_ratio)
	if not new_form.is_empty():
		current_monster_id = new_form
	_update_ui()

func _on_tool_evolution_pressed() -> void:
	var xp_ratio := {"combat_ratio": 0.5, "knowledge_ratio": 0.5}
	var success := evolution_system.trigger_tool_evolution(current_monster_id, "thunder_stone", xp_ratio)
	if success:
		current_monster_id = "004_lightning_king"
	_update_ui()

func _on_soul_shard_pressed() -> void:
	evolution_system.apply_soul_shard(current_monster_id, "boss_thunder")
	_update_ui()

func _on_revert_soul_shard_pressed() -> void:
	evolution_system._revert_soul_shard(current_monster_id)
	_update_ui()

func _on_combat_heavy_pressed() -> void:
	var xp_ratio := {"combat_ratio": 0.8, "knowledge_ratio": 0.2}
	var stats := evolution_system.calculate_hybrid_stats(current_monster_id, xp_ratio)
	_show_hybrid_stats(stats)

func _on_knowledge_heavy_pressed() -> void:
	var xp_ratio := {"combat_ratio": 0.2, "knowledge_ratio": 0.8}
	var stats := evolution_system.calculate_hybrid_stats(current_monster_id, xp_ratio)
	_show_hybrid_stats(stats)

func _on_balanced_pressed() -> void:
	var xp_ratio := {"combat_ratio": 0.5, "knowledge_ratio": 0.5}
	var stats := evolution_system.calculate_hybrid_stats(current_monster_id, xp_ratio)
	_show_hybrid_stats(stats)

func _on_evolution_triggered(monster_id: String, new_form: String, evo_type: String) -> void:
	$UIContainer/EvolutionStatus.text = "Evolution: %s → %s (%s)" % [monster_id, new_form, evo_type]

func _on_evolution_complete(monster_id: String) -> void:
	$UIContainer/EvolutionStatus.text = "Evolution Complete: " + monster_id

func _on_soul_shard_applied(monster_id: String, form: String, duration: int) -> void:
	$UIContainer/SoulShardStatus.text = "Soul Shard Active: %s (Battles: %d)" % [form, duration]

func _on_soul_shard_reverted(monster_id: String, original_form: String) -> void:
	$UIContainer/SoulShardStatus.text = "Soul Shard Reverted: " + original_form

func _update_ui() -> void:
	$UIContainer/MonsterStats.text = "Current Monster: %s (Level %d)" % [current_monster_id, current_level]

	var has_shard := evolution_system.has_active_soul_shard(current_monster_id)
	if has_shard:
		var shard_data := evolution_system.get_soul_shard_data(current_monster_id)
		$UIContainer/SoulShardStatus.text = "Soul Shard: %s (%d battles)" % [shard_data.get("temp_form", ""), shard_data.get("battles_remaining", 0)]
	else:
		$UIContainer/SoulShardStatus.text = "Soul Shard: None"

func _show_hybrid_stats(stats: Dictionary) -> void:
	var display := "Hybrid Stats:\n"
	display += "  ATK: %d | DEF: %d\n" % [stats.get("attack", 0), stats.get("defense", 0)]
	display += "  SPA: %d | SPD: %d\n" % [stats.get("special_attack", 0), stats.get("special_defense", 0)]
	display += "  Combat: %.0f%% | Knowledge: %.0f%%" % [stats.get("combat_ratio", 0) * 100, stats.get("knowledge_ratio", 0) * 100]
	$UIContainer/HybridStatsDisplay.text = display
```

---

## Integration Points

### Signals Exposed:

**Permanent Evolution Signals:**
- `evolution_triggered(monster_id: String, new_form: String, evolution_type: String)` - Emitted when evolution starts
- `evolution_complete(monster_id: String)` - Emitted when evolution finishes
- `evolution_prevented(monster_id: String, reason: String)` - Emitted when evolution fails

**Soul Shard Signals:**
- `soul_shard_applied(monster_id: String, form: String, duration: int)` - Emitted when temporary form applied
- `soul_shard_reverted(monster_id: String, original_form: String)` - Emitted when temporary form reverts

### Public Methods:

**Level-Based Evolution:**
- `check_level_evolution(monster_id: String, level: int) -> bool` - Check if monster can evolve
- `trigger_level_evolution(monster_id: String, level: int, xp_ratio: Dictionary) -> String` - Trigger level evolution
- `get_level_requirement(monster_id: String) -> int` - Get required level

**Tool-Based Evolution:**
- `check_tool_evolution(monster_id: String, tool_id: String) -> bool` - Check if tool can evolve monster
- `trigger_tool_evolution(monster_id: String, tool_id: String, xp_ratio: Dictionary) -> bool` - Trigger tool evolution
- `get_tool_evolution_target(monster_id: String, tool_id: String) -> String` - Get evolution target

**Soul Shard (Temporary):**
- `apply_soul_shard(monster_id: String, shard_id: String) -> bool` - Apply temporary transformation
- `decrement_soul_shard_duration(monster_id: String)` - Call after each battle
- `has_active_soul_shard(monster_id: String) -> bool` - Check for active shard
- `get_soul_shard_data(monster_id: String) -> Dictionary` - Get shard info

**Hybrid Stats:**
- `calculate_hybrid_stats(monster_id: String, xp_ratio: Dictionary) -> Dictionary` - Calculate evolved stats based on playstyle

**Utility:**
- `get_available_evolutions(monster_id: String, level: int, inventory_items: Array) -> Array` - Get all possible evolutions
- `get_evolution_stats() -> Dictionary` - Get system statistics

### Dependencies:

**Depends on:**
- S12 (Monster Database) - Base monster stats and data
- S04 (Combat) - Battle integration for XP and Soul Shard duration
- S19 (Dual XP) - XP ratios for hybrid stat growth

**Depended on by:**
- S22 (NPCs) - NPCs can gift evolution items and Soul Shards
- Future systems using monster progression

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

### Level-Based Evolution Tests:
- [ ] Sparkle (001) evolves to Voltix (002) at level 16
- [ ] Evolution triggers correctly after level check
- [ ] Hybrid stats calculated based on XP ratio
- [ ] Combat-heavy ratio (80/20) boosts attack/defense
- [ ] Knowledge-heavy ratio (20/80) boosts special attack/defense
- [ ] Balanced ratio (50/50) gives even distribution
- [ ] Evolution animation state tracked
- [ ] Evolution signals emit correctly

### Tool-Based Evolution Tests:
- [ ] Sparkle + Thunder Stone → Lightning King
- [ ] Tool requirement checked correctly
- [ ] Evolution triggered only with correct tool
- [ ] Hybrid stats apply to tool evolutions
- [ ] Tool evolution signals emit correctly
- [ ] Multiple tool evolutions configured (10 total)

### Soul Shard Tests:
- [ ] Soul Shard (boss_thunder) grants temporary form
- [ ] Duration set correctly (3 battles for boss_thunder)
- [ ] Original stats saved before transformation
- [ ] Temporary form reverts after duration
- [ ] Can revert early if needed
- [ ] Soul Shard signals emit correctly
- [ ] Multiple Soul Shards configured (8 total)
- [ ] Cannot stack Soul Shards (one at a time)

### Hybrid Stat Growth Tests:
- [ ] Combat XP ratio increases physical stats (attack, defense)
- [ ] Knowledge XP ratio increases special stats (special_attack, special_defense)
- [ ] Balanced ratio gives even distribution
- [ ] Stat bonuses scale up to +50% for specialized builds
- [ ] Hybrid stats integrate with S19 Dual XP system
- [ ] Stats calculated correctly for evolved forms

### Integration Tests:
- [ ] Integration with S12 Monster Database works
- [ ] Integration with S19 Dual XP works (XP ratios)
- [ ] Integration with S04 Combat works (battle tracking)
- [ ] evolution_config.json loads correctly
- [ ] All evolution types configurable from JSON
- [ ] No hardcoded evolution data in code

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

### Hybrid Stat Growth Details:
- **Combat XP Ratio** (from S19): Influences physical stats (attack, defense, HP)
  - 100% combat → +50% physical stats
  - 0% combat → base physical stats
- **Knowledge XP Ratio** (from S19): Influences special stats (special_attack, special_defense, MP)
  - 100% knowledge → +50% special stats
  - 0% knowledge → base special stats
- **Balanced Play**: 50/50 ratio gives 10% bonus to all stats (from config)

### Soul Shard Duration:
- Temporary forms revert automatically after specified number of battles
- Call `decrement_soul_shard_duration()` after each battle in combat system
- Can revert early with `_revert_soul_shard()` if needed
- Soul Shards are NOT stackable (only one active at a time)

### Tool Evolution:
- Requires both monster AND tool item in inventory
- Tool is consumed on evolution (unless specified otherwise)
- Provides alternate evolution paths with different stat distributions

### Level Evolution:
- Check after every battle when monster gains XP (integrate with S04 Combat)
- Player choice to evolve or cancel (not automatic)
- Can delay evolution indefinitely

### Evolution Config Structure:
- **level_evolutions**: Pokemon-style level-based evolutions
- **tool_evolutions**: Item-based evolutions (alternative paths)
- **soul_shards**: Temporary boss forms (revert after battles)
- **hybrid_stat_growth**: Scaling configuration for XP ratios
- **evolution_requirements**: Behavior settings for each type
- **evolution_animations**: Visual and audio settings

---

## Integration with Existing Systems

### S12 Monster Database:
```gdscript
# Set Monster Database reference
evolution_system.set_monster_database(MonsterDatabase)
```

### S19 Dual XP System:
```gdscript
# Get XP ratios from S19 XP Manager
var xp_ratio := {
	"combat_ratio": xp_manager.combat_xp / (xp_manager.combat_xp + xp_manager.knowledge_xp),
	"knowledge_ratio": xp_manager.knowledge_xp / (xp_manager.combat_xp + xp_manager.knowledge_xp)
}

# Use for evolution
evolution_system.trigger_level_evolution(monster_id, level, xp_ratio)
```

### S04 Combat System:
```gdscript
# After battle ends
func _on_battle_end():
	# Decrement Soul Shard duration
	for monster in active_monsters:
		evolution_system.decrement_soul_shard_duration(monster.id)

	# Check for level-up evolutions
	if monster.level_increased:
		if evolution_system.check_level_evolution(monster.id, monster.level):
			# Show evolution prompt to player
			show_evolution_prompt(monster)
```

---

## Quality Gates

Before marking S20 complete, verify:

### Tier 2 Framework Tests:
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S20")`
- [ ] Quality gates passed: `check_quality_gates("S20")`
- [ ] Checkpoint validated: `validate_checkpoint("S20")`

### System-Specific Verification:
- [ ] All three evolution types work (level, tool, Soul Shard)
- [ ] Hybrid stat growth reflects playstyle correctly
- [ ] Soul Shard temporary forms revert properly
- [ ] Evolution config loads without errors
- [ ] All signals emit at correct times
- [ ] No evolution data hardcoded in scripts
- [ ] Integration with S12, S19, S04 documented

---

## Next Steps for MCP Agent

1. **Create test scene** using GDAI commands above
2. **Create test script** for evolution scene
3. **Test all evolution types** thoroughly
4. **Verify hybrid stat growth** with different XP ratios
5. **Test Soul Shard duration** and reversion
6. **Run framework quality gates**
7. **Update COORDINATION-DASHBOARD.md**:
   - Mark S20 as "complete"
   - Release any resource locks
   - Unblock dependent systems (S22)
8. **Create checkpoint** with completion status
9. **Add knowledge base entry** if non-trivial solutions discovered

---

**HANDOFF STATUS: READY FOR TIER 2**

**Estimated Tier 2 Time:** 2-3 hours (scene config + comprehensive testing)

**Priority:** MEDIUM (Wave 2 of Job 4, can run parallel with S21)

---

*Generated by: Claude Code Web*
*Date: 2025-11-18*
*System: S20 - Monster Evolution System*
*Prompt: 022-s20-monster-evolution.md*
