# System Registry - Complete Catalog
**Project:** Rhythm RPG (Godot 4.5.1)
**Last Updated:** 2025-11-18
**Status:** All 26 Systems Implemented (Tier 1 Complete)
**Godot Compatibility:** ✅ 100% Godot 4.5 Compatible

---

## Table of Contents
1. [System Overview](#system-overview)
2. [Foundation Systems (S01-S04)](#foundation-systems-s01-s04)
3. [Core Gameplay Systems (S05-S10)](#core-gameplay-systems-s05-s10)
4. [AI & Monster Systems (S11-S13)](#ai--monster-systems-s11-s13)
5. [Traversal & Tools (S14-S18)](#traversal--tools-s14-s18)
6. [Progression Systems (S19-S21)](#progression-systems-s19-s21)
7. [Narrative & Content (S22-S26)](#narrative--content-s22-s26)
8. [System Dependency Map](#system-dependency-map)
9. [Integration Points Reference](#integration-points-reference)

---

## System Overview

| System | Name | Status | Location | Type | Dependencies |
|--------|------|--------|----------|------|--------------|
| S01 | Conductor/Rhythm | ✅ Complete | `src/systems/s01-conductor-rhythm-system/` | Autoload | None |
| S02 | Input Manager | ✅ Complete | `res/autoloads/input_manager.gd` | Autoload | None |
| S03 | Player Controller | ✅ Complete | `src/systems/s03-player/` | Scene | S02 |
| S04 | Combat System | ✅ Complete | `src/systems/s04-combat/` | Manager | S01, S02, S03 |
| S05 | Inventory | ✅ Complete | `src/systems/s05-inventory/` | Manager + UI | S03 |
| S06 | Save/Load | ✅ Complete | `res/autoloads/save_manager.gd` | Autoload | S03, S05 |
| S07 | Weapons | ✅ Complete | `res/resources/weapon_resource.gd` | Resource | S04, S05 |
| S08 | Equipment | ✅ Complete | `src/systems/s08-equipment/` | Manager | S05, S07 |
| S09 | Dodge/Block | ✅ Complete | `src/systems/s09-dodgeblock/` | Combat Extension | S01, S04, S08 |
| S10 | Special Moves | ✅ Complete | `src/systems/s10-specialmoves/` | Combat Extension | S01, S04, S07, S09 |
| S11 | Enemy AI | ✅ Complete | `src/systems/s11-enemyai/` | AI System | S04 |
| S12 | Monster Database | ✅ Complete | `src/systems/s12-monsters/` | Data System | S04, S11 |
| S13 | Vibe Bar | ✅ Complete | `src/systems/s13-vibebar/` | UI System | S04 |
| S14 | Tool System | ✅ Complete | `src/systems/s14-tool-system/` | Traversal | S03 |
| S15 | Vehicles | ✅ Complete | `src/systems/s15-vehicle/` | Traversal | S03 |
| S16 | Grind Rails | ✅ Complete | `res/traversal/grind_rail.gd` | Traversal | S01, S03 |
| S17 | Puzzles | ✅ Complete | `src/systems/s17-puzzle-system/` | Environmental | S03, S14 |
| S18 | Polyrhythm | ✅ Complete | `res/environment/polyrhythm_*.gd` | Environmental | S01 |
| S19 | Dual XP System | ✅ Complete | `src/systems/s19-dual-xp/` | Progression | S04, S17 |
| S20 | Evolution | ✅ Complete | `src/systems/s20-evolution/` | Progression | S12, S04, S19 |
| S21 | Alignment | ✅ Complete | `src/systems/s21-resonance-alignment/` | Progression | S04, S12, S11 |
| S22 | NPC System | ✅ Complete | `src/systems/s22-npc-system/` | Narrative | S21, S03, S04 |
| S23 | Story System | ✅ Complete | `res/story/story_manager.gd` | Narrative | S22, S21, S04 |
| S24 | Cooking | ✅ Complete | `src/systems/s24-cooking/` | Content | S05, S12 |
| S25 | Crafting | ✅ Complete | `src/systems/s25-crafting/` | Content | S08, S12, S07 |
| S26 | Rhythm Mini-Games | ✅ Complete | `src/systems/s26-rhythm-mini-games/` | Content | S01, S04 |

---

## Foundation Systems (S01-S04)

### S01 - Conductor/Rhythm System
**Purpose:** Core rhythm engine providing beat/downbeat/measure timing for all rhythm-based mechanics
**Type:** Autoload Singleton
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s01-conductor-rhythm-system/conductor.gd` - Main conductor singleton
- `src/systems/s01-conductor-rhythm-system/rhythm_config.json` - BPM, timing windows
- `src/systems/s01-conductor-rhythm-system/test_conductor.gd` - Test scene script
- `src/systems/s01-conductor-rhythm-system/rhythm_debug_overlay.gd` - Debug UI

**Dependencies:**
- None (foundation system)

**Dependents:** (7 systems)
- S04 (Combat timing)
- S09 (Dodge/block timing)
- S10 (Special move timing)
- S16 (Grind rail balance)
- S18 (Polyrhythm platforms)
- S26 (Rhythm mini-games)

**Integration Points:**
- **Signals:** `beat(beat_number: int)`, `downbeat(measure_number: int)`, `measure(measure_number: int)`
- **Autoload Name:** `Conductor`
- **Global Access:** All systems connect to Conductor signals for rhythm-based actions

**Extensibility:**
- BPM changes: `Conductor.set_bpm(new_bpm: int)`
- Time signature changes: `Conductor.set_time_signature(beats: int, note_value: int)`
- Latency compensation: Configure in JSON

**Godot 4.5 Features:**
- Modern signal typing with parameters
- Time.get_ticks_msec() for accurate timing
- @export decorators for configuration

---

### S02 - Input Manager
**Purpose:** Centralized input handling with 4-lane rhythm support, deadzone filtering, input buffering
**Type:** Autoload Singleton
**Status:** ✅ Complete

**Key Files:**
- `res/autoloads/input_manager.gd` - Main input manager singleton
- `res/data/input_config.json` - Rhythm lanes, deadzones, action mappings
- `res/tests/test_input.gd` - Input testing scene

**Dependencies:**
- None (foundation system)

**Dependents:** (6 systems)
- S03 (Player movement input)
- S04 (Combat input)
- S09 (Dodge/block input)
- S10 (Special move input)
- S14 (Tool activation)
- S16 (Grind rail balance input)

**Integration Points:**
- **Signals:** `lane_pressed(lane_id: int, timestamp: float)`, `button_pressed(action: String)`, `stick_moved(stick: String, direction: Vector2, magnitude: float)`
- **Autoload Name:** `InputManager`
- **Global Access:** All systems use InputManager for input detection

**Extensibility:**
- Add new actions: Edit `input_config.json` action_mappings
- Configure deadzones: Adjust deadzone values in JSON
- Custom input buffer: Modify input_buffer_config

**Key Features:**
- 4-lane rhythm input (Face buttons: ▲■●✖)
- Input buffering (configurable window)
- Analog stick deadzone filtering
- Controller hotplug support

---

### S03 - Player Controller
**Purpose:** CharacterBody2D-based player character with movement, states, interaction system
**Type:** Scene Component
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s03-player/player_controller.gd` - Main player script
- `res/data/player_config.json` - Movement speeds, stats, interaction radius

**Dependencies:**
- S02 (InputManager for movement input)

**Dependents:** (6 systems)
- S04 (Player as combatant)
- S05 (Inventory owner)
- S14 (Tool user)
- S15 (Vehicle pilot)
- S16 (Grind rail rider)
- S17 (Puzzle solver)

**Integration Points:**
- **Signals:** `movement_state_changed(old_state: String, new_state: String)`, `interaction_detected(object: Node)`, `player_interacted(object: Node)`
- **Base Class:** CharacterBody2D
- **Key Properties:** `walk_speed`, `run_speed`, `facing_direction`, `nearby_interactables`

**Extensibility:**
- Add new states: Extend State enum
- Modify movement: Adjust config JSON values
- Custom interactions: Connect to interaction signals

**State Machine:**
- IDLE: Standing still
- WALKING: Moving at walk_speed
- RUNNING: Moving at run_speed

---

### S04 - Combat System
**Purpose:** Turn-based rhythm combat with damage formula, status effects, combatant base class
**Type:** Manager + Base Classes
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s04-combat/combatant.gd` - Base class for all combat entities
- `src/systems/s04-combat/combat_manager.gd` - Turn management, battle orchestration
- `src/systems/s04-combat/combat_config.json` - Damage formulas, timing windows, status effects

**Dependencies:**
- S01 (Conductor for rhythm timing)
- S02 (InputManager for combat input)
- S03 (Player as combatant)

**Dependents:** (15+ systems - highest blocker!)
- S07 (Weapons modify combat stats)
- S08 (Equipment modifies stats)
- S09 (Dodge/block mechanics)
- S10 (Special moves)
- S11 (Enemy AI)
- S12 (Monster stats)
- S13 (Vibe bar UI)
- S19 (XP gain from combat)
- S20 (Evolution from combat)
- S21 (Alignment from combat choices)
- S22 (NPC combat encounters)
- S23 (Story combat events)
- S26 (Combat mini-games)

**Integration Points:**
- **Base Class:** `Combatant` extends CharacterBody2D
- **Signals:** `damage_taken`, `damage_dealt`, `health_changed`, `defeated`, `attack_executed`
- **Core Stats:** max_hp, attack, defense, special_attack, special_defense, speed, level
- **Combat States:** IDLE, READY, ATTACKING, DODGING, BLOCKING, STUNNED, DEFEATED

**Damage Formula:**
```gdscript
base_damage = (move_power * (attacker.attack / target.defense) * (attacker.level / 5) + 2)
timing_multiplier = 2.0 (Perfect), 1.5 (Good), 1.0 (OK), 0.5 (Miss)
final_damage = base_damage * timing_multiplier * type_effectiveness
```

**Extensibility:**
- New combatant types: Extend Combatant class
- New status effects: Add to combat_config.json
- Custom damage formulas: Override calculate_damage()

**Godot 4.5 Features:**
- CharacterBody2D base (not deprecated KinematicBody2D)
- Typed signal parameters
- Modern enum declarations

---

## Core Gameplay Systems (S05-S10)

### S05 - Inventory System
**Purpose:** Item management, pickup, use, drop with categorization and stacking
**Type:** Manager + UI Components
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s05-inventory/inventory_manager.gd` - Core inventory logic
- `src/systems/s05-inventory/inventory_ui.gd` - UI display and interaction
- `src/systems/s05-inventory/item_pickup.gd` - Pickup area component
- `src/systems/s05-inventory/test_inventory.gd` - Test scene
- `data/inventory_config.json` - Inventory size, categories
- `data/items.json` - Item database

**Dependencies:**
- S03 (Player has inventory)

**Dependents:** (4 systems)
- S06 (Save inventory state)
- S08 (Equipment from inventory)
- S24 (Cooking ingredients from inventory)
- S25 (Crafting materials from inventory)

**Integration Points:**
- **Signals:** `item_added(item_id: String, quantity: int)`, `item_removed`, `item_used`, `inventory_full`
- **Methods:** `add_item()`, `remove_item()`, `has_item()`, `get_item_count()`
- **Data Structure:** Array of {item_id, quantity, metadata}

**Item Categories:**
- Weapons (equippable)
- Armor (equippable)
- Consumables (usable)
- Materials (crafting)
- Key Items (quest)

**Extensibility:**
- Add new categories: Extend categories in config
- Custom item types: Add to items.json
- Stack limits: Configure per-item in JSON

---

### S06 - Save/Load System
**Purpose:** Game state persistence with multiple save slots using JSON serialization
**Type:** Autoload Singleton
**Status:** ✅ Complete

**Key Files:**
- `res/autoloads/save_manager.gd` - Save/load manager singleton
- Save files: `user://saves/save_slot_[1-3].json`

**Dependencies:**
- S03 (Player state)
- S05 (Inventory state)

**Dependents:**
- All systems must integrate with save/load (register with SaveManager)

**Integration Points:**
- **Signals:** `save_completed(slot_id: int)`, `load_completed(slot_id: int)`, `save_failed`, `load_failed`
- **Methods:** `save_game(slot_id: int)`, `load_game(slot_id: int)`, `delete_save(slot_id: int)`
- **Registration:** Systems call `SaveManager.register_system(name, node)` to be included in saves

**Save Data Structure:**
```json
{
  "game_version": "0.1.0",
  "save_timestamp": "2025-11-18T10:30:00Z",
  "play_time": 7200.5,
  "player_data": {...},
  "inventory_data": {...},
  "story_flags": [...],
  "systems": {
    "s05_inventory": {...},
    "s19_xp": {...}
  }
}
```

**Extensibility:**
- New saveable systems: Call register_system()
- Custom serialization: Implement serialize() / deserialize()
- Cloud saves: Extend to upload to backend

---

### S07 - Weapons & Shields
**Purpose:** Weapon/shield resource definitions with stats for combat
**Type:** Resource Definitions + Database
**Status:** ✅ Complete

**Key Files:**
- `res/resources/weapon_resource.gd` - WeaponResource class
- `res/resources/shield_resource.gd` - ShieldResource class
- `res/autoloads/item_database.gd` - Runtime weapon/shield loader
- `res/data/weapons.json` - Weapon definitions
- `res/data/shields.json` - Shield definitions

**Dependencies:**
- S04 (Combat stats)
- S05 (Inventory items)

**Dependents:** (3 systems)
- S08 (Equipment slots)
- S10 (Special move requirements)
- S25 (Crafting recipes)

**Integration Points:**
- **Resource Class:** Extends Resource
- **Autoload:** `ItemDatabase.get_weapon(id)`, `ItemDatabase.get_shield(id)`
- **Properties:** damage, speed, range, attack_pattern, special_effects, tier

**Weapon Types:**
- Swords (balanced)
- Axes (high damage, slow)
- Spears (long range)
- Bows (ranged)
- Staffs (special attack)

**Extensibility:**
- Add weapons: Edit weapons.json
- New weapon types: Extend weapon_resource.gd
- Special effects: Add effect handlers in combat system

---

### S08 - Equipment System
**Purpose:** Equip weapons, shields, armor with stat modifications and visual updates
**Type:** Manager
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s08-equipment/equipment_manager.gd` - Equipment slot management
- `src/systems/s08-equipment/test_equipment_scene.gd` - Test scene
- `data/equipment.json` - Equipment definitions (armor, accessories)

**Dependencies:**
- S05 (Items from inventory)
- S07 (Weapons to equip)

**Dependents:** (3 systems)
- S09 (Shield for blocking)
- S10 (Weapon for special moves)
- S25 (Crafting equipment)

**Integration Points:**
- **Signals:** `equipment_changed(slot: String, item_id: String)`, `stats_recalculated(new_stats: Dictionary)`
- **Methods:** `equip_item(slot, item_id)`, `unequip_slot(slot)`, `get_equipped(slot)`
- **Equipment Slots:** weapon, shield, helmet, chest, legs, accessory_1, accessory_2

**Stat Modifications:**
- Weapons: +attack, +special_attack
- Shields: +defense, +block_power
- Armor: +max_hp, +defense, +special_defense
- Accessories: Various bonuses

**Extensibility:**
- New slots: Add to equipment_slots array
- Set bonuses: Implement set_bonus_check()
- Visual updates: Connect to sprite changes

---

### S09 - Dodge/Block System
**Purpose:** Rhythm-based dodge with i-frames, shield blocking with damage reduction
**Type:** Combat Extension
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s09-dodgeblock/dodge_system.gd` - Dodge mechanics and i-frames
- `src/systems/s09-dodgeblock/block_system.gd` - Block mechanics and damage reduction
- `src/systems/s09-dodgeblock/dodge_block_config.json` - Timing windows, damage reduction

**Dependencies:**
- S01 (Conductor for rhythm timing)
- S04 (Combat system integration)
- S08 (Shield for blocking)

**Dependents:**
- S10 (Special moves require successful dodges/blocks)

**Integration Points:**
- **Signals:** `dodge_executed(timing_quality: String)`, `block_executed(damage_reduction: float)`, `iframe_started`, `iframe_ended`
- **Methods:** `attempt_dodge()`, `attempt_block()`, `is_invulnerable()`
- **Timing Windows:** Perfect (±50ms), Good (±100ms), OK (±150ms), Miss (>150ms)

**Dodge Mechanics:**
- Input: Circle button (Face Right)
- Perfect dodge: 0.3s i-frames, no damage
- Good dodge: 0.2s i-frames, 10% damage
- OK dodge: 0.1s i-frames, 25% damage
- Miss: No i-frames, full damage

**Block Mechanics:**
- Requires shield equipped
- Perfect block: 90% damage reduction
- Good block: 75% reduction
- OK block: 50% reduction
- Shield durability cost per block

**Extensibility:**
- Modify timing windows: Edit config JSON
- Add dodge types: Implement in dodge_system.gd
- Custom block animations: Connect to animation signals

---

### S10 - Special Moves System
**Purpose:** Unlockable special attacks with rhythm input sequences and resource costs
**Type:** Combat Extension
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s10-specialmoves/special_moves_system.gd` - Special move manager
- `src/systems/s10-specialmoves/special_moves_config.json` - Move definitions
- `data/special_moves.json` - Move database

**Dependencies:**
- S01 (Conductor for rhythm timing)
- S04 (Combat damage)
- S07 (Weapon requirements)
- S09 (Combo chains from dodges/blocks)

**Dependents:**
- None (terminal combat system)

**Integration Points:**
- **Signals:** `special_move_started(move_id: String)`, `special_move_completed(move_id: String, success: bool)`, `sequence_input_received(input: String)`
- **Methods:** `unlock_move(move_id)`, `can_use_move(move_id)`, `execute_move(move_id)`
- **Input Sequences:** Array of button presses on beat (e.g., ["up", "up", "down", "attack"])

**Special Move Structure:**
```gdscript
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

**Extensibility:**
- New moves: Add to special_moves.json
- Custom sequences: Define input arrays
- Resource systems: MP, SP, or custom gauges

---

## AI & Monster Systems (S11-S13)

### S11 - Enemy AI System
**Purpose:** LimboAI behavior trees for enemy decision-making with attack telegraphing
**Type:** AI System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s11-enemyai/enemy_base.gd` - Base enemy class with AI
- `src/systems/s11-enemyai/enemy_aggressive.gd` - Aggressive behavior variant
- `src/systems/s11-enemyai/enemy_defensive.gd` - Defensive behavior variant
- `src/systems/s11-enemyai/enemy_ranged.gd` - Ranged behavior variant
- `src/systems/s11-enemyai/enemy_swarm.gd` - Swarm behavior variant
- `src/systems/s11-enemyai/tasks/*.gd` - LimboAI behavior tree tasks
- `src/systems/s11-enemyai/enemy_ai_config.json` - AI parameters

**Dependencies:**
- S04 (Combatant base class)
- LimboAI plugin (Godot 4.5 compatible)

**Dependents:**
- S12 (Monsters use enemy AI)

**Integration Points:**
- **Base Class:** EnemyBase extends Combatant
- **AI States:** PATROL, CHASE, ATTACK, RETREAT, STUN
- **Signals:** `player_detected(player)`, `attack_telegraph_started(duration)`, `state_changed`
- **Behavior Tree:** BTPlayer node integration

**Enemy Types:**
- AGGRESSIVE: Always chase, low retreat threshold
- DEFENSIVE: Block more, high retreat threshold
- RANGED: Keep distance, shoot projectiles
- SWARM: Call allies when damaged

**LimboAI Tasks:**
- bt_scan_for_player.gd
- bt_patrol_move.gd
- bt_chase_player.gd
- bt_check_in_attack_range.gd
- bt_attack_player.gd
- bt_retreat.gd

**Extensibility:**
- New AI types: Create enemy_[type].gd
- Custom behaviors: Add LimboAI tasks
- Difficulty modifiers: Adjust reaction_time, accuracy in config

---

### S12 - Monster Database
**Purpose:** 100+ monster definitions with stats, abilities, loot tables, evolution chains
**Type:** Data System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s12-monsters/evolution_system.gd` - Evolution logic (overlaps with S20)
- `res/data/monsters.json` - Monster database (100+ entries)
- `res/data/type_effectiveness.json` - Type matchup chart

**Dependencies:**
- S04 (Combat stats)
- S11 (Enemy AI behaviors)

**Dependents:** (3 systems)
- S20 (Evolution chains)
- S24 (Cooking with monster drops)
- S25 (Crafting with monster materials)

**Integration Points:**
- **Data Access:** `MonsterDatabase.get_monster(monster_id)`
- **Monster Structure:**
```json
{
  "monster_id": "fire_drake",
  "name": "Fire Drake",
  "stats": {"hp": 120, "attack": 45, "defense": 30},
  "type": "fire",
  "ai_type": "aggressive",
  "abilities": ["flame_breath", "wing_attack"],
  "loot_table": [{"item_id": "drake_scale", "chance": 0.25}],
  "evolution_to": "inferno_wyrm",
  "evolution_level": 20
}
```

**Type System:**
- Fire, Water, Earth, Air, Light, Dark, Electric, Nature
- Type effectiveness chart (2x, 0.5x, 0x damage)

**Extensibility:**
- Add monsters: Edit monsters.json
- New types: Add to type_effectiveness.json
- Custom abilities: Reference S10 special moves

---

### S13 - Vibe Bar (Visual Polish)
**Purpose:** UI visualization of rhythm combo meter and performance feedback
**Type:** UI System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s13-vibebar/vibe_bar.gd` - Vibe meter UI component
- `data/vibe_bar_config.json` - Thresholds, colors, bonuses

**Dependencies:**
- S04 (Combat performance tracking)

**Dependents:**
- None (visual polish system)

**Integration Points:**
- **Signals:** `vibe_level_changed(level: int)`, `combo_broken`, `max_vibe_reached`
- **Methods:** `increase_vibe(amount)`, `decrease_vibe(amount)`, `reset_vibe()`
- **Vibe Levels:** 0-25 (Low), 26-50 (Medium), 51-75 (High), 76-100 (MAX)

**Bonuses:**
- Low: 0% damage bonus
- Medium: +10% damage
- High: +25% damage
- MAX: +50% damage, special move cost -50%

**Extensibility:**
- Visual effects: Particle systems on level changes
- Audio feedback: Sound triggers
- Custom thresholds: Edit config JSON

---

## Traversal & Tools (S14-S18)

### S14 - Tool System
**Purpose:** Equippable traversal tools (grapple hook, roller blades, surfboard, laser)
**Type:** Tool Manager + Tool Components
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s14-tool-system/tool_manager.gd` - Tool switching and management
- `src/systems/s14-tool-system/grapple_hook.gd` - Grappling hook mechanics
- `src/systems/s14-tool-system/roller_blades.gd` - Speed boost traversal
- `src/systems/s14-tool-system/surfboard.gd` - Water traversal
- `src/systems/s14-tool-system/laser.gd` - Obstacle destruction
- `data/tools_config.json` - Tool stats and requirements

**Dependencies:**
- S03 (Player as tool user)

**Dependents:**
- S17 (Puzzles require tools)

**Integration Points:**
- **Signals:** `tool_equipped(tool_id: String)`, `tool_activated`, `tool_deactivated`
- **Methods:** `equip_tool(tool_id)`, `activate_current_tool()`, `can_use_tool(tool_id)`

**Tools:**
1. **Grapple Hook** - Swing from grapple points, Spider-Man style
2. **Roller Blades** - Speed boost, jump enhancement
3. **Surfboard** - Water traversal, wave riding
4. **Laser** - Destroy metal obstacles, activate machines

**Godot 4.5 Features:**
- move_and_slide() without parameters (velocity as property)
- Modern physics integration

**Extensibility:**
- New tools: Create tool_[name].gd extending base
- Tool upgrades: Add tiers to config
- Custom mechanics: Override tool activate/deactivate

---

### S15 - Vehicle System
**Purpose:** Driveable/pilotable vehicles (car, boat, airship, mech suit)
**Type:** Vehicle Manager + Vehicle Components
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s15-vehicle/vehicle_base.gd` - Base vehicle class
- `src/systems/s15-vehicle/car.gd` - Ground vehicle
- `src/systems/s15-vehicle/boat.gd` - Water vehicle
- `src/systems/s15-vehicle/airship.gd` - Air vehicle
- `src/systems/s15-vehicle/mech_suit.gd` - Combat vehicle
- `data/vehicles_config.json` - Vehicle stats

**Dependencies:**
- S03 (Player as pilot)

**Dependents:**
- None (independent traversal)

**Integration Points:**
- **Signals:** `player_entered_vehicle(vehicle_type)`, `player_exited_vehicle`, `vehicle_damaged`
- **Methods:** `enter_vehicle()`, `exit_vehicle()`, `control_vehicle(input)`

**Vehicles:**
1. **Car** - Fast ground travel, drifting
2. **Boat** - Water navigation, fishing mini-game
3. **Airship** - Flying, exploration
4. **Mech Suit** - Combat enhancement, heavy lifting

**Vehicle Properties:**
- Speed, handling, fuel/energy
- Special abilities per vehicle
- Damage/durability system

**Extensibility:**
- New vehicles: Extend vehicle_base.gd
- Custom controls: Override _update_input()
- Vehicle upgrades: Tier system in config

---

### S16 - Grind Rail System
**Purpose:** Jet Set Radio-style rail grinding with rhythm-based balance mechanics
**Type:** Traversal Component
**Status:** ✅ Complete

**Key Files:**
- `res/traversal/grind_rail.gd` - Grind rail path component
- `res/data/grind_rail_config.json` - Balance mechanics, speeds

**Dependencies:**
- S01 (Conductor for rhythm balance)
- S03 (Player as grinder)

**Dependents:**
- None (independent traversal)

**Integration Points:**
- **Base Class:** Extends Path2D
- **Signals:** `player_entered_rail(player)`, `player_exited_rail(reason)`, `balance_changed(balance, safe_zone)`, `jump_executed`
- **Mechanics:** Balance oscillates, player presses Left/Right on beat to maintain

**Balance System:**
- Balance value: -100 to +100
- Safe zone: -30 to +30
- Fall if outside safe zone too long
- Discord penalty: -20% stats for 5s if fall

**Jump Mechanics:**
- Can only jump on upbeat (Conductor signal)
- Perfect timing: 500 jump force
- Missed timing: 250 jump force

**Extensibility:**
- Rail paths: Place Path2D in scene
- Difficulty: Adjust oscillation speed
- Trick system: Add combo inputs

---

### S17 - Puzzle System
**Purpose:** Environmental puzzles (rhythm, tool-based, physics, multi-stage)
**Type:** Puzzle Framework
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s17-puzzle-system/puzzle_base.gd` - Base puzzle class
- `src/systems/s17-puzzle-system/rhythm_puzzle.gd` - Beat-based puzzles
- `src/systems/s17-puzzle-system/tool_puzzle.gd` - Tool-required puzzles
- `src/systems/s17-puzzle-system/physics_puzzle.gd` - Physics-based puzzles
- `src/systems/s17-puzzle-system/environmental_puzzle.gd` - World interaction puzzles
- `src/systems/s17-puzzle-system/item_puzzle.gd` - Item-based puzzles
- `src/systems/s17-puzzle-system/multi_stage_puzzle.gd` - Complex multi-part puzzles
- `data/puzzles.json` - Puzzle definitions

**Dependencies:**
- S03 (Player as solver)
- S14 (Tool puzzles)

**Dependents:**
- S19 (Puzzle XP rewards)

**Integration Points:**
- **Base Class:** PuzzleBase extends Node
- **Signals:** `puzzle_started`, `puzzle_completed`, `puzzle_failed`, `puzzle_reset`
- **Methods:** `start_puzzle()`, `check_solution()`, `reset_puzzle()`

**Puzzle Types:**
1. **Rhythm Puzzles** - Match beat patterns
2. **Tool Puzzles** - Use correct tool on obstacle
3. **Physics Puzzles** - Push/pull objects
4. **Environmental** - Interact with world elements
5. **Item Puzzles** - Use specific inventory items
6. **Multi-Stage** - Complex sequences

**Extensibility:**
- New puzzle types: Extend puzzle_base.gd
- Puzzle chains: Use multi_stage_puzzle.gd
- Rewards: Connect to XP/item systems

---

### S18 - Polyrhythm Environment
**Purpose:** Moving platforms/hazards with multiple simultaneous rhythm patterns
**Type:** Environmental System
**Status:** ✅ Complete

**Key Files:**
- `res/environment/polyrhythm_controller.gd` - Multi-rhythm coordinator
- `res/environment/polyrhythm_light.gd` - Rhythm-synced lights
- `res/environment/polyrhythm_machinery.gd` - Rhythm-synced machines
- `res/environment/timing_platform.gd` - Rhythm-based platforms
- `res/data/polyrhythm_config.json` - Rhythm patterns

**Dependencies:**
- S01 (Conductor as base rhythm)

**Dependents:**
- None (environmental flavor)

**Integration Points:**
- **Signals:** `polyrhythm_phase_changed(pattern_id)`, `platform_activated`, `hazard_triggered`
- **Methods:** `set_polyrhythm_pattern(pattern_id)`, `sync_to_conductor()`

**Polyrhythm Patterns:**
- 3:4 (3 beats over 4 beats)
- 5:4 (quintuplets)
- 7:8 (septuplets)
- Custom ratios

**Use Cases:**
- Timing platforms (jump on correct beat)
- Machinery that operates on offset rhythms
- Environmental hazards synced to music

**Extensibility:**
- New patterns: Add to config
- Visual sync: Particle effects
- Audio layers: Multi-track music

---

## Progression Systems (S19-S21)

### S19 - Dual XP System
**Purpose:** Separate Combat XP and Puzzle XP with dual leveling tracks
**Type:** Progression Manager
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s19-dual-xp/xp_manager.gd` - XP tracking and leveling
- `src/systems/s19-dual-xp/level_up_panel.gd` - Level up UI
- `src/systems/s19-dual-xp/xp_config.json` - XP curves, level caps

**Dependencies:**
- S04 (Combat XP source)
- S17 (Puzzle XP source)

**Dependents:**
- S20 (Evolution requires levels)

**Integration Points:**
- **Signals:** `xp_gained(xp_type: String, amount: int)`, `level_up(xp_type: String, new_level: int)`, `stat_increased(stat_name: String, amount: int)`
- **Methods:** `add_combat_xp(amount)`, `add_puzzle_xp(amount)`, `get_combat_level()`, `get_puzzle_level()`

**XP Tracks:**
1. **Combat XP** → Combat Level (1-50)
   - Grants: +attack, +defense, +HP
   - Sources: Defeating enemies, boss battles
2. **Puzzle XP** → Puzzle Level (1-50)
   - Grants: +special_attack, +special_defense, +tool efficiency
   - Sources: Solving puzzles, exploration

**XP Curve:**
```gdscript
xp_required = 100 * (level ^ 1.5)
```

**Extensibility:**
- More tracks: Add rhythm_xp, exploration_xp
- Custom curves: Edit xp_config.json
- Level rewards: Define in config

---

### S20 - Evolution System
**Purpose:** Monster evolution mechanics (level-based, item-based, condition-based)
**Type:** Progression System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s20-evolution/evolution_system.gd` - Evolution manager
- `data/evolution_config.json` - Evolution chains and conditions

**Dependencies:**
- S12 (Monster database)
- S04 (Combat system)
- S19 (Level requirements)

**Dependents:**
- None (terminal progression feature)

**Integration Points:**
- **Signals:** `evolution_available(monster_id: String, evolution_id: String)`, `evolution_started`, `evolution_completed`
- **Methods:** `can_evolve(monster_id)`, `evolve_monster(monster_id, evolution_id)`, `get_evolution_chain(monster_id)`

**Evolution Types:**
1. **Level Evolution** - Reach specific level
2. **Item Evolution** - Use evolution item
3. **Condition Evolution** - Meet special conditions (time of day, location, alignment)
4. **Branch Evolution** - Multiple evolution paths

**Example Chain:**
```
Spark Lizard (Level 1)
  → Lightning Drake (Level 15)
    → Thunder Wyrm (Level 30 + Thunder Stone)
    → Storm Phoenix (Level 30 + high Authentic alignment)
```

**Extensibility:**
- New evolution types: Extend evolution_system.gd
- Complex conditions: Add condition checks
- Visual effects: Evolution animations

---

### S21 - Resonance Alignment System
**Purpose:** Authentic vs Algorithm alignment based on combat/story choices affecting endings
**Type:** Progression/Narrative System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s21-resonance-alignment/resonance_alignment.gd` - Alignment tracker
- `data/alignment_config.json` - Alignment thresholds and effects

**Dependencies:**
- S04 (Combat choices)
- S12 (Monster interactions)
- S11 (Enemy AI behavior affects alignment)

**Dependents:** (2 systems)
- S22 (NPC relationships affected by alignment)
- S23 (Story endings based on alignment)

**Integration Points:**
- **Signals:** `alignment_changed(new_value: float)`, `alignment_threshold_crossed(threshold: String)`, `resonance_bonus_updated(bonus: Dictionary)`
- **Methods:** `shift_alignment(direction: String, amount: float)`, `get_alignment()`, `get_alignment_tier()`

**Alignment Scale:**
```
-100 (Pure Algorithm) ←→ 0 (Neutral) ←→ +100 (Pure Authentic)
```

**Alignment Tiers:**
- Algorithm III: -100 to -66
- Algorithm II: -65 to -33
- Algorithm I: -32 to -11
- Neutral: -10 to +10
- Authentic I: +11 to +33
- Authentic II: +34 to +66
- Authentic III: +67 to +100

**Alignment Shifts:**
- Spare enemy: +5 Authentic
- Execute enemy: +5 Algorithm
- Help NPC: +3 Authentic
- Ignore NPC: +3 Algorithm
- Use special moves: +1 Algorithm
- Use basic attacks: +1 Authentic

**Resonance Bonuses:**
- Authentic: +special_defense, +charm (NPC relationships)
- Algorithm: +special_attack, +critical_chance

**Extensibility:**
- New alignment axes: Add dimensions
- Custom bonuses: Define in config
- Visual indicators: Aura effects based on alignment

---

## Narrative & Content (S22-S26)

### S22 - NPC System
**Purpose:** Complex NPCs with dialogue, relationships, quests, and dynamic reactions to alignment
**Type:** Narrative System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s22-npc-system/npc_base.gd` - Base NPC class
- `src/systems/s22-npc-system/dialogue/` - Dialogue trees
- `data/npc_config.json` - NPC definitions and relationship thresholds

**Dependencies:**
- S21 (Alignment affects NPC reactions)
- S03 (Player interaction)
- S04 (Combat with/for NPCs)

**Dependents:**
- S23 (Story progression through NPCs)

**Integration Points:**
- **Signals:** `dialogue_started(npc_id: String)`, `dialogue_choice_made(choice_id: String)`, `relationship_changed(npc_id: String, delta: int)`, `quest_given(quest_id: String)`
- **Methods:** `start_dialogue(npc_id)`, `give_gift(npc_id, item_id)`, `complete_quest(quest_id)`

**NPC Relationship System:**
- Relationship value: 0-100
- Tiers: Stranger (0-20), Acquaintance (21-40), Friend (41-60), Close Friend (61-80), Best Friend (81-100)
- Relationship affects: Dialogue options, quest availability, shop prices, special rewards

**Dialogue System:**
- Branching dialogue trees
- Choices affect relationship and alignment
- Conditional dialogue based on story flags
- Voice line triggers (placeholder for future)

**Quest Types:**
- Fetch quests (bring items)
- Combat quests (defeat enemies)
- Escort quests (protect NPC)
- Puzzle quests (solve challenges)

**Extensibility:**
- New NPCs: Add to npc_config.json
- Dialogue trees: Create dialogue JSON files
- Relationship bonuses: Special perks at thresholds

---

### S23 - Story System
**Purpose:** Branching story paths with multiple endings based on alignment and choices
**Type:** Narrative Manager
**Status:** ✅ Complete

**Key Files:**
- `res/story/story_manager.gd` - Story state and branch management
- `res/data/story_config.json` - Chapter definitions, endings, hidden paths

**Dependencies:**
- S22 (NPCs for story)
- S21 (Alignment for endings)
- S04 (Story combat events)

**Dependents:**
- None (terminal narrative system)

**Integration Points:**
- **Signals:** `story_flag_set(flag: String)`, `chapter_complete(chapter_id: int)`, `ending_reached(ending_type: String)`, `branch_changed(branch: String)`
- **Methods:** `set_story_flag(flag)`, `has_story_flag(flag)`, `advance_chapter()`, `determine_ending()`

**Story Structure:**
- 10 Chapters
- 3 Main Branches: Authentic Path, Neutral Path, Algorithm Path
- 8 Possible Endings (including hidden paths)

**Story Flags:**
- Persistent flags track player choices
- Example flags: "met_elder", "saved_village", "discovered_truth", "chose_mercy"

**Endings:**
1. **True Authentic** - High Authentic alignment + all NPC relationships maxed
2. **Authentic** - High Authentic alignment
3. **Neutral Good** - Neutral + high NPC relationships
4. **Neutral** - Pure neutral path
5. **Algorithm** - High Algorithm alignment
6. **True Algorithm** - High Algorithm + all NPCs hostile
7. **Hidden: Ascension** - Perfect Authentic + secret quest chain
8. **Hidden: Singularity** - Perfect Algorithm + secret quest chain

**Extensibility:**
- New chapters: Add to story_config.json
- New endings: Define requirements
- Hidden paths: Complex flag combinations

---

### S24 - Cooking System
**Purpose:** Cook recipes using monster drops for stat boosts and buffs
**Type:** Content System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s24-cooking/cooking_system.gd` - Cooking manager and UI
- `data/recipes.json` - Recipe definitions
- `data/ingredients.json` - Ingredient database

**Dependencies:**
- S05 (Inventory for ingredients)
- S12 (Monster drops as ingredients)

**Dependents:**
- None (optional content)

**Integration Points:**
- **Signals:** `recipe_cooked(recipe_id: String, quality: String)`, `buff_applied(buff_id: String, duration: float)`, `new_recipe_learned(recipe_id: String)`
- **Methods:** `cook_recipe(recipe_id)`, `learn_recipe(recipe_id)`, `get_known_recipes()`

**Cooking Mechanics:**
- Mini-game: Rhythm-based cooking inputs
- Quality tiers: Burnt, Poor, Good, Great, Perfect
- Higher quality = stronger buffs

**Recipe Structure:**
```json
{
  "recipe_id": "fire_stew",
  "name": "Blazing Stew",
  "ingredients": [
    {"item_id": "fire_pepper", "quantity": 3},
    {"item_id": "drake_meat", "quantity": 1}
  ],
  "buff": {
    "stat": "attack",
    "amount": 20,
    "duration": 300
  }
}
```

**Buff Types:**
- Stat buffs (+attack, +defense, +speed)
- HP/MP regeneration
- Resistance to status effects
- XP gain multiplier

**Extensibility:**
- New recipes: Add to recipes.json
- Custom buffs: Define buff effects
- Cooking upgrades: Better equipment for easier cooking

---

### S25 - Crafting System
**Purpose:** Craft weapons, equipment, items using materials and recipes
**Type:** Content System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s25-crafting/crafting_system.gd` - Crafting manager and UI
- `data/crafting_recipes.json` - Crafting recipes

**Dependencies:**
- S08 (Equipment to craft)
- S12 (Monster materials)
- S07 (Weapons to craft)

**Dependents:**
- None (optional content)

**Integration Points:**
- **Signals:** `item_crafted(item_id: String, tier: int)`, `recipe_unlocked(recipe_id: String)`, `crafting_failed`
- **Methods:** `craft_item(recipe_id)`, `can_craft(recipe_id)`, `unlock_recipe(recipe_id)`

**Crafting Mechanics:**
- Requires materials from inventory
- Some recipes require specific tools/stations
- Success chance based on player level
- Higher tier recipes need better equipment

**Recipe Structure:**
```json
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

**Craftable Categories:**
- Weapons (swords, bows, staffs)
- Armor (helmets, chest, legs)
- Tools (grapple hook upgrades, etc.)
- Consumables (potions, throwables)

**Extensibility:**
- New recipes: Add to crafting_recipes.json
- Upgrade systems: Tier progression
- Material farming: Monster hunting loops

---

### S26 - Rhythm Mini-Games
**Purpose:** Standalone rhythm challenges for rewards (DDR-style, Simon Says, Chord Hold)
**Type:** Content System
**Status:** ✅ Complete

**Key Files:**
- `src/systems/s26-rhythm-mini-games/rhythm_game.gd` - Mini-game controller
- `src/systems/s26-rhythm-mini-games/rhythm_patterns.json` - Pattern definitions
- `src/systems/s26-rhythm-mini-games/difficulty_config.json` - Difficulty settings

**Dependencies:**
- S01 (Conductor for rhythm)
- S04 (Combat system for rewards)

**Dependents:**
- None (optional content)

**Integration Points:**
- **Signals:** `mini_game_started(game_type: String)`, `mini_game_completed(score: int, grade: String)`, `pattern_hit(accuracy: String)`, `pattern_missed`
- **Methods:** `start_mini_game(game_type, difficulty)`, `submit_input(lane: int, timestamp: float)`, `get_high_score(game_type)`

**Mini-Game Types:**
1. **DDR Mode** - 4-lane rhythm inputs
2. **Simon Says** - Repeat pattern sequences
3. **Chord Hold** - Hold multiple buttons on beat
4. **Freestyle** - Create custom rhythm patterns

**Scoring:**
- Perfect: ±16ms
- Great: ±50ms
- Good: ±100ms
- OK: ±150ms
- Miss: >150ms

**Grades:**
- S: 95-100% accuracy
- A: 85-94%
- B: 75-84%
- C: 65-74%
- D: 50-64%
- F: <50%

**Rewards:**
- XP based on grade
- Unlock cosmetics
- High score leaderboards (local)

**Extensibility:**
- New game modes: Extend rhythm_game.gd
- Custom patterns: Create pattern JSON files
- Multiplayer: Add competitive modes

---

## System Dependency Map

```
Foundation Layer (No Dependencies):
├── S01 Conductor/Rhythm
├── S02 Input Manager
└── (Framework systems)

Player Layer (Depends on S02):
└── S03 Player Controller

Combat Core (Depends on S01, S02, S03):
└── S04 Combat System
    ├── S07 Weapons (S04, S05)
    ├── S08 Equipment (S05, S07)
    ├── S09 Dodge/Block (S01, S04, S08)
    ├── S10 Special Moves (S01, S04, S07, S09)
    ├── S11 Enemy AI (S04)
    ├── S12 Monster Database (S04, S11)
    └── S13 Vibe Bar (S04)

Data Systems (Depends on S03):
├── S05 Inventory (S03)
└── S06 Save/Load (S03, S05)

Traversal Systems (Depends on S03):
├── S14 Tools (S03)
├── S15 Vehicles (S03)
└── S16 Grind Rails (S01, S03)

Environmental Systems:
├── S17 Puzzles (S03, S14)
└── S18 Polyrhythm (S01)

Progression Systems:
├── S19 Dual XP (S04, S17)
├── S20 Evolution (S12, S04, S19)
└── S21 Alignment (S04, S12, S11)

Narrative Systems:
├── S22 NPCs (S21, S03, S04)
└── S23 Story (S22, S21, S04)

Content Systems:
├── S24 Cooking (S05, S12)
├── S25 Crafting (S08, S12, S07)
└── S26 Rhythm Mini-Games (S01, S04)
```

---

## Integration Points Reference

### Autoload Singletons
- `Conductor` (S01) - res://src/systems/s01-conductor-rhythm-system/conductor.gd
- `InputManager` (S02) - res://res/autoloads/input_manager.gd
- `SaveManager` (S06) - res://res/autoloads/save_manager.gd
- `ItemDatabase` (S07) - res://res/autoloads/item_database.gd
- `ResonanceAlignment` (S21) - Registered as autoload
- `StoryManager` (S23) - res://res/story/story_manager.gd

### Signal Architecture

**Most Connected Systems:**
1. **S01 Conductor** - Beat signals used by 7 systems
2. **S04 Combat** - Combat events propagate to 15+ systems
3. **S03 Player** - Movement and interaction signals

**Critical Signal Chains:**
```
Conductor.beat
  → Combat timing check
    → Vibe Bar update
      → Damage multiplier
        → XP gain
          → Level up
            → Evolution check
```

### Data Flow Patterns

**JSON → GDScript Loading:**
- All systems load configuration from JSON files
- Pattern: FileAccess.open() → JSON.parse() → Dictionary access
- Centralized in data/ directory

**Manager Pattern:**
- Singleton managers (autoloads) manage system state
- Components reference managers for shared data
- Example: InventoryManager controls all inventory operations

**Resource Pattern:**
- Weapons, shields use Resource class
- Loaded at startup by ItemDatabase
- Efficient memory sharing

---

## Extensibility Summary

### How to Add a New Monster
1. Edit `res/data/monsters.json`
2. Add new entry with stats, type, abilities
3. Optionally add evolution chain
4. Monster automatically available in combat

### How to Add a New Item
1. Edit `data/items.json`
2. Define item properties
3. Optionally add to crafting recipes
4. Item automatically available in inventory

### How to Add a New Special Move
1. Edit `data/special_moves.json`
2. Define input sequence and damage
3. Set unlock conditions
4. Move automatically available when unlocked

### How to Add a New Puzzle
1. Extend `puzzle_base.gd` or use existing type
2. Define puzzle logic in new script
3. Add to `data/puzzles.json`
4. Place in scene

### How to Create a New System (S27+)
1. Create `src/systems/s##-system-name/` directory
2. Implement core logic in manager.gd
3. Create data JSON file in `data/`
4. Write HANDOFF-S##.md for Tier 2
5. Update PARALLEL-EXECUTION-GUIDE-V2.md dependencies
6. Register with SaveManager if persistence needed
7. Create research document and checkpoint

---

**End of System Registry**

**Next Steps:**
- For quick onboarding: See `AGENT-QUICKSTART.md`
- For architecture overview: See `ARCHITECTURE-OVERVIEW.md`
- For development workflow: See `DEVELOPMENT-GUIDE.md`
- For framework guides: See `knowledge-base/frameworks/`
