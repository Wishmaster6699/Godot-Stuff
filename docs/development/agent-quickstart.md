# Agent Quickstart Guide - Rhythm RPG
**Welcome, Agent!** This is your 5-minute onboarding to the Rhythm RPG project.

**Last Updated:** 2025-11-18
**Project Status:** All 26 Systems Implemented (Tier 1 Complete)
**Godot Version:** 4.5.1

---

## Your First 5 Minutes

### 1. Read This File (5 min) ← YOU ARE HERE

### 2. Understand Project Status
- ✅ **Tier 1 Complete:** All scripts (.gd) and data (.json) files implemented
- ✅ **Godot 4.5 Compatible:** 100% modern GDScript, no deprecated code
- ⏳ **Tier 2 Pending:** Scene files (.tscn) not yet created (MCP work)
- ✅ **Quality Gates:** Integration tests, performance profiling, frameworks in place

### 3. Know the Core Philosophy
**Mantra:** Research → MCP → Verify → Checkpoint

Read this immediately after this file:
- `@vibe-code-philosophy.md` (10 min) - **REQUIRED READING**

### 4. Locate Documentation
- **System Catalog:** `SYSTEM-REGISTRY.md` - Complete 26-system reference
- **Architecture:** `ARCHITECTURE-OVERVIEW.md` - High-level design
- **Knowledge Base:** `knowledge-base/README.md` - Master index
- **Development:** `DEVELOPMENT-GUIDE.md` - Workflow and patterns
- **Dependencies:** `PARALLEL-EXECUTION-GUIDE-V2.md` - System dependencies

---

## Common Agent Tasks

### "Create a New Monster"

**Quick Answer:**
1. Edit `/res/data/monsters.json`
2. Add new entry following template:
```json
{
  "monster_id": "fire_drake",
  "name": "Fire Drake",
  "stats": {"hp": 120, "attack": 45, "defense": 30, "speed": 25},
  "type": "fire",
  "ai_type": "aggressive",
  "abilities": ["flame_breath", "wing_attack"],
  "loot_table": [{"item_id": "drake_scale", "chance": 0.25}],
  "evolution_to": "inferno_wyrm",
  "evolution_level": 20
}
```

**Detailed Guide:** `knowledge-base/frameworks/monster-creation.md`

**Related Systems:**
- S12 Monster Database: `/src/systems/s12-monsters/`
- S11 Enemy AI: `/src/systems/s11-enemyai/`

---

### "Add a New Item"

**Quick Answer:**
1. Edit `/data/items.json`
2. Add new entry:
```json
{
  "item_id": "health_potion",
  "name": "Health Potion",
  "category": "consumable",
  "description": "Restores 50 HP",
  "effect": {"type": "heal", "amount": 50},
  "stack_limit": 99,
  "value": 50
}
```

**Detailed Guide:** `knowledge-base/frameworks/inventory-items.md`

**Related Systems:**
- S05 Inventory: `/src/systems/s05-inventory/`
- S24 Cooking: `/src/systems/s24-cooking/`
- S25 Crafting: `/src/systems/s25-crafting/`

---

### "Add a New Weapon"

**Quick Answer:**
1. Edit `/res/data/weapons.json`
2. Add new entry:
```json
{
  "id": "flame_sword",
  "name": "Flame Sword",
  "type": "sword",
  "tier": 3,
  "damage": 45,
  "speed": 1.2,
  "range": 64,
  "attack_pattern": "slash",
  "special_effects": ["fire_damage"],
  "value": 500
}
```

**Detailed Guide:** `knowledge-base/frameworks/inventory-items.md`

**Related Systems:**
- S07 Weapons: `/res/resources/weapon_resource.gd`, `/res/autoloads/item_database.gd`
- S08 Equipment: `/src/systems/s08-equipment/`

---

### "Modify Combat Mechanics"

**Quick Answer:**
1. Review combat specification: `combat-specification.md`
2. Combat core: `/src/systems/s04-combat/`
   - `combatant.gd` - Base class for all combat entities
   - `combat_manager.gd` - Turn management
   - `combat_config.json` - Damage formulas, timing windows

**Detailed Guide:** `knowledge-base/frameworks/combat-extension.md`

**Dependencies to Check:**
- S01 Conductor (rhythm timing)
- S02 InputManager (combat input)
- S03 Player (player as combatant)

**What Depends on Combat:**
- S09 Dodge/Block, S10 Special Moves, S11 Enemy AI, S12 Monsters, S13 Vibe Bar
- S19 XP, S20 Evolution, S21 Alignment, S26 Mini-Games

**⚠️ CAUTION:** Combat is the highest-blocking system (15+ dependents). Test thoroughly!

---

### "Add a New Tool or Vehicle"

**Tools (S14):**
- Location: `/src/systems/s14-tool-system/`
- Pattern: Extend base class, add to `data/tools_config.json`
- Examples: `grapple_hook.gd`, `roller_blades.gd`, `surfboard.gd`, `laser.gd`

**Vehicles (S15):**
- Location: `/src/systems/s15-vehicle/`
- Pattern: Extend `vehicle_base.gd`, add to `data/vehicles_config.json`
- Examples: `car.gd`, `boat.gd`, `airship.gd`, `mech_suit.gd`

**Detailed Guide:** `knowledge-base/frameworks/world-building.md`

---

### "Add a New Recipe (Cooking or Crafting)"

**Cooking (S24):**
```json
// data/recipes.json
{
  "recipe_id": "fire_stew",
  "name": "Blazing Stew",
  "ingredients": [
    {"item_id": "fire_pepper", "quantity": 3},
    {"item_id": "drake_meat", "quantity": 1}
  ],
  "buff": {"stat": "attack", "amount": 20, "duration": 300}
}
```

**Crafting (S25):**
```json
// data/crafting_recipes.json
{
  "recipe_id": "iron_sword",
  "result": {"item_id": "iron_sword", "quantity": 1},
  "materials": [
    {"item_id": "iron_ore", "quantity": 5},
    {"item_id": "wood", "quantity": 2}
  ],
  "required_tool": "anvil",
  "skill_required": 10
}
```

**Detailed Guide:** `knowledge-base/frameworks/content-systems.md`

---

### "Create a New Puzzle"

**Quick Answer:**
1. Extend puzzle base: `/src/systems/s17-puzzle-system/puzzle_base.gd`
2. Or use existing types:
   - `rhythm_puzzle.gd` - Beat-based challenges
   - `tool_puzzle.gd` - Requires specific tool
   - `physics_puzzle.gd` - Push/pull mechanics
   - `item_puzzle.gd` - Use specific item
   - `multi_stage_puzzle.gd` - Complex sequences

3. Define in `/data/puzzles.json`

**Detailed Guide:** `knowledge-base/frameworks/world-building.md`

---

### "Add a New Special Move"

**Quick Answer:**
```json
// data/special_moves.json
{
  "move_id": "flame_strike",
  "name": "Flame Strike",
  "input_sequence": ["up", "down", "attack"],
  "damage_multiplier": 3.0,
  "resource_cost": 25,
  "weapon_requirement": "sword",
  "unlock_condition": "level >= 5"
}
```

**Detailed Guide:** `knowledge-base/frameworks/combat-extension.md`

**Related System:**
- S10 Special Moves: `/src/systems/s10-specialmoves/`

---

## File Structure Quick Reference

```
vibe-code-game/
├── src/systems/              # Most system implementations
│   ├── s01-conductor-rhythm-system/
│   ├── s03-player/
│   ├── s04-combat/
│   ├── s05-inventory/
│   └── ... (20 systems)
├── res/                      # Resources, autoloads, scenes
│   ├── autoloads/           # S02, S06 singletons
│   │   ├── input_manager.gd
│   │   └── save_manager.gd
│   ├── resources/           # S07 weapon/shield resources
│   ├── traversal/           # S16 grind rails
│   ├── environment/         # S18 polyrhythm
│   ├── story/               # S23 story manager
│   └── data/                # JSON data files
├── data/                    # Additional JSON data
│   ├── items.json
│   ├── recipes.json
│   ├── crafting_recipes.json
│   └── ... (many config files)
├── checkpoints/             # System completion checkpoints
├── research/                # System research notes
├── knowledge-base/          # Agent documentation
│   ├── README.md           # Master index
│   ├── quick-reference/
│   ├── frameworks/
│   ├── integration-patterns/
│   ├── godot-specifics/
│   ├── agent-guides/
│   └── implementation-notes/
├── HANDOFF-*.md            # Tier 1 → Tier 2 handoff docs
├── SYSTEM-REGISTRY.md      # Complete system catalog
├── ARCHITECTURE-OVERVIEW.md
├── AGENT-QUICKSTART.md     ← YOU ARE HERE
├── DEVELOPMENT-GUIDE.md
├── vibe-code-philosophy.md
└── PARALLEL-EXECUTION-GUIDE-V2.md
```

---

## How to Search This Project

### By System Number
**Example:** "What does S12 do?"
→ Search `SYSTEM-REGISTRY.md` for "S12"
→ Jump to Monster Database section

### By Feature
**Example:** "How does combat work?"
→ Search `SYSTEM-REGISTRY.md` for "combat"
→ Find S04, S09, S10 sections
→ Check `knowledge-base/frameworks/combat-extension.md`

### By File Type
**Example:** "Where are all the JSON files?"
```bash
# Use Glob tool
find . -name "*.json"
```

### By Keyword
**Example:** "Find all files mentioning 'rhythm'"
```bash
# Use Grep tool
grep -r "rhythm" src/ data/
```

---

## Before You Start ANY Task

### Checklist:
1. **Search Knowledge Base:** Does this feature already exist?
   - Check `SYSTEM-REGISTRY.md`
   - Check `knowledge-base/README.md`

2. **Check Dependencies:** What systems are involved?
   - See `SYSTEM-REGISTRY.md` dependency columns
   - See `PARALLEL-EXECUTION-GUIDE-V2.md` dependency map

3. **Read Relevant Framework Guide:**
   - Monster creation? → `knowledge-base/frameworks/monster-creation.md`
   - Combat changes? → `knowledge-base/frameworks/combat-extension.md`
   - Items/inventory? → `knowledge-base/frameworks/inventory-items.md`

4. **Verify Godot 4.5 Compatibility:**
   - Read `knowledge-base/godot-specifics/version-compatibility.md`
   - Ensure no deprecated patterns (KinematicBody2D, yield, old export)

5. **Plan Integration Points:**
   - What signals do you need to connect to?
   - What autoloads will you access?
   - What systems will be affected?

---

## Godot 4.5 Quick Reference

### ✅ USE (Godot 4.5):
```gdscript
extends CharacterBody2D          # Not KinematicBody2D
@onready var sprite = $Sprite    # Not onready
@export var speed: float = 200.0 # Not export
await some_signal                # Not yield
signal_name.emit(args)           # Not emit_signal()
move_and_slide()                 # Not move_and_slide(velocity)
FileAccess.open(path, mode)      # Not File.new()
Time.get_ticks_msec()            # Not OS.get_ticks_msec()
```

### ❌ AVOID (Godot 3.x - DEPRECATED):
```gdscript
extends KinematicBody2D          # DEPRECATED
onready var sprite = $Sprite     # DEPRECATED
export var speed = 200.0         # DEPRECATED
yield(get_tree(), "idle_frame")  # DEPRECATED
emit_signal("signal_name", args) # OLD SYNTAX
move_and_slide(velocity)         # OLD SYNTAX
```

**Full Compatibility Guide:** `knowledge-base/godot-specifics/version-compatibility.md`

---

## Common MCP Commands (Tier 2 Work)

**Note:** Tier 2 (scene configuration) is pending. When you do Tier 2:

```python
# Create scene
create_scene("res://scenes/player.tscn", "CharacterBody2D")

# Add nodes
add_node("res://scenes/player.tscn", "Sprite2D", "PlayerSprite")
add_node("res://scenes/player.tscn", "CollisionShape2D", "Collision")

# Attach script
attach_script("res://scenes/player.tscn", "CharacterBody2D", "res://scripts/player.gd")

# Set properties
update_property("res://scenes/player.tscn", "PlayerSprite", "texture", "res://assets/player.png")

# Test scene
play_scene("res://scenes/player.tscn")
get_godot_errors()
stop_running_scene()
```

**Full MCP Guide:** `vibe-code-philosophy.md` (Section 2: Godot MCP Primary)

---

## Testing Your Changes

### 1. Check for Errors
```bash
# Search for syntax errors
grep -r "ERROR" project/logs/
```

### 2. Verify JSON Validity
```bash
# Test JSON files
python3 -m json.tool data/your_file.json
```

### 3. Integration Testing (Tier 2)
```gdscript
# Run integration test suite
var suite = IntegrationTestSuite.new()
var results = suite.run_all_tests()
print(results.summary())
```

### 4. Performance Profiling (Tier 2)
```gdscript
# Profile system performance
var profiler = PerformanceProfiler.new()
var metrics = profiler.profile_system("S04")
# Target: <1ms per frame per system
```

---

## When You Get Stuck

### 1. Check Existing Examples
Every system has similar patterns. Look at existing implementations:
- Need a manager? See S05 InventoryManager
- Need a base class? See S04 Combatant or S11 EnemyBase
- Need data loading? See any system's `_load_config()`

### 2. Read HANDOFF Documents
- `HANDOFF-S##.md` files explain system implementation details
- Written by Tier 1 agents for Tier 2 agents
- Include exact MCP commands and integration notes

### 3. Check Research Documents
- `research/s##-[system]-research.md` files document research findings
- Links to Godot docs, examples, best practices

### 4. Consult Knowledge Base
- `knowledge-base/` has 25+ articles
- Searchable by topic, system, pattern

### 5. Review Checkpoints
- `checkpoints/s##-[system]-checkpoint.md` show completed work
- Include testing results, known issues, next steps

---

## Project Philosophy Recap

### 1. Web Search First
**Never code from memory.** Always search for current Godot 4.5 best practices.

### 2. MCP Primary
**MCP is not a fallback, it's the main tool.** Use GDAI commands for scene work.

### 3. Token Efficiency
**JSON > Prose.** Reference URLs, don't copy docs. Be concise.

### 4. Checkpoint Everything
**Track progress.** Save checkpoints after completing work.

### 5. Data-Driven
**Zero hardcoded game data.** Everything in JSON files.

### 6. Test Before Checkpoint
**Never assume it works.** Always verify via MCP testing.

**Full Philosophy:** `vibe-code-philosophy.md` (REQUIRED READING)

---

## Quick Wins (Easy Tasks to Start)

### Easy (5-15 min):
- Add a new item to `data/items.json`
- Add a new monster to `res/data/monsters.json`
- Add a new recipe to `data/recipes.json`
- Modify player speed in `res/data/player_config.json`

### Medium (30-60 min):
- Create a new weapon in `res/data/weapons.json`
- Create a new special move in `data/special_moves.json`
- Add a new NPC to `data/npc_config.json`
- Create a new puzzle definition in `data/puzzles.json`

### Advanced (2-4 hours):
- Implement a new enemy AI variant extending `enemy_base.gd`
- Create a new tool extending tool system base classes
- Implement a new combat mechanic extending combatant
- Create a new content system (S27+)

---

## Success Criteria

**You're ready to contribute when you can:**
1. ✅ Find any system's files in under 2 minutes
2. ✅ Understand system dependencies from SYSTEM-REGISTRY.md
3. ✅ Add a new monster or item without guidance
4. ✅ Know when to use JSON vs code changes
5. ✅ Understand the Research → MCP → Verify → Checkpoint workflow

---

## Next Steps

### Immediate (Next 30 Minutes):
1. ✅ Read `vibe-code-philosophy.md` (10 min)
2. ✅ Skim `SYSTEM-REGISTRY.md` (15 min) - Don't memorize, just familiarize
3. ✅ Browse `knowledge-base/README.md` (5 min)

### When Starting a Task:
1. Search `SYSTEM-REGISTRY.md` for relevant systems
2. Read related `HANDOFF-S##.md` if modifying existing system
3. Check `knowledge-base/frameworks/` for extension guides
4. Review `vibe-code-philosophy.md` workflow

### If Implementing New System (S27+):
1. Read `DEVELOPMENT-GUIDE.md` (comprehensive workflow)
2. Review `PARALLEL-EXECUTION-GUIDE-V2.md` (dependency analysis)
3. Check existing systems for patterns
4. Follow Research → MCP → Verify → Checkpoint

---

## Contact & Support

**Documentation Issues:**
- Missing information? Check `knowledge-base/README.md` for additional articles
- Unclear instructions? Consult `DEVELOPMENT-GUIDE.md`
- Integration questions? See `ARCHITECTURE-OVERVIEW.md`

**Godot 4.5 Questions:**
- Official Docs: https://docs.godotengine.org/en/4.5/
- Compatibility: `knowledge-base/godot-specifics/version-compatibility.md`

---

**Welcome to the team! You've got this. 🎮🎵**

**Remember:** Research → MCP → Verify → Checkpoint

---

**End of Quickstart Guide**

**Next Reading:**
1. `vibe-code-philosophy.md` ← Read this NEXT
2. `SYSTEM-REGISTRY.md` ← Reference as needed
3. `knowledge-base/README.md` ← Browse when stuck
