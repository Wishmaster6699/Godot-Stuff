# Architecture Overview - Rhythm RPG
**Project:** Godot 4.5.1 | GDScript 4.5
**Last Updated:** 2025-11-18
**Status:** Tier 1 Complete (All 26 Systems Implemented)

---

## Table of Contents
1. [High-Level Architecture](#high-level-architecture)
2. [System Organization](#system-organization)
3. [Autoload Architecture](#autoload-architecture)
4. [Data Flow Patterns](#data-flow-patterns)
5. [Signal Architecture](#signal-architecture)
6. [Scene Composition](#scene-composition)
7. [Critical Paths](#critical-paths)
8. [Technology Stack](#technology-stack)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    RHYTHM RPG ARCHITECTURE                       │
│                      (Godot 4.5.1)                              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   AUTOLOAD LAYER (Singletons)                   │
│  Conductor | InputManager | SaveManager | ItemDatabase          │
│  ResonanceAlignment | StoryManager                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    FOUNDATION SYSTEMS                            │
│  S01 Conductor (Rhythm) | S02 Input | S03 Player | S04 Combat   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────┬────────────────────┬─────────────────────┐
│   CORE GAMEPLAY      │    TRAVERSAL       │    PROGRESSION      │
│  S05 Inventory       │  S14 Tools         │  S19 Dual XP        │
│  S07 Weapons         │  S15 Vehicles      │  S20 Evolution      │
│  S08 Equipment       │  S16 Grind Rails   │  S21 Alignment      │
│  S09 Dodge/Block     │  S17 Puzzles       │                     │
│  S10 Special Moves   │  S18 Polyrhythm    │                     │
│  S11 Enemy AI        │                    │                     │
│  S12 Monsters        │                    │                     │
│  S13 Vibe Bar        │                    │                     │
└──────────────────────┴────────────────────┴─────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   NARRATIVE & CONTENT LAYER                      │
│  S22 NPCs | S23 Story | S24 Cooking | S25 Crafting | S26 Mini   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    DATA PERSISTENCE LAYER                        │
│               S06 Save/Load (user://saves/)                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## System Organization

### By Category

**Foundation Systems** (S01-S04)
Core mechanics that all other systems depend on:
- **S01 Conductor:** Global rhythm timing (BPM, beats, measures)
- **S02 Input:** Centralized input handling (rhythm lanes, controller support)
- **S03 Player:** Player character controller (movement, interactions)
- **S04 Combat:** Turn-based rhythm combat (damage, stats, combatants)

**Data Systems** (S05-S08)
Inventory, persistence, and equipment:
- **S05 Inventory:** Item management (stack, use, drop)
- **S06 Save/Load:** Game state persistence (JSON serialization, 3 slots)
- **S07 Weapons:** Weapon/shield database (combat stats, special effects)
- **S08 Equipment:** Equip system (slots, stat modifications)

**Combat Extensions** (S09-S13)
Advanced combat mechanics:
- **S09 Dodge/Block:** Rhythm-based defense (i-frames, damage reduction)
- **S10 Special Moves:** Special attacks (input sequences, resource costs)
- **S11 Enemy AI:** LimboAI behavior trees (patrol, chase, attack, retreat)
- **S12 Monster Database:** 100+ monsters (stats, abilities, loot, evolution)
- **S13 Vibe Bar:** Combo meter (performance tracking, damage bonuses)

**Traversal & Tools** (S14-S18)
World navigation mechanics:
- **S14 Tools:** Traversal tools (grapple hook, roller blades, surfboard, laser)
- **S15 Vehicles:** Driveable vehicles (car, boat, airship, mech suit)
- **S16 Grind Rails:** Rail grinding (rhythm balance, Jet Set Radio style)
- **S17 Puzzles:** Environmental puzzles (rhythm, tool-based, physics, multi-stage)
- **S18 Polyrhythm:** Multi-rhythm platforms (3:4, 5:4 patterns)

**Progression** (S19-S21)
Player growth mechanics:
- **S19 Dual XP:** Separate Combat/Puzzle leveling tracks
- **S20 Evolution:** Monster evolution (level-based, item-based, conditional)
- **S21 Alignment:** Authentic vs Algorithm moral system (affects endings)

**Narrative & Content** (S22-S26)
Story, NPCs, and optional content:
- **S22 NPCs:** Complex NPCs (dialogue, relationships, quests)
- **S23 Story:** Branching narrative (10 chapters, 8 endings, hidden paths)
- **S24 Cooking:** Recipe system (monster drops, stat buffs)
- **S25 Crafting:** Item creation (weapons, equipment, materials)
- **S26 Rhythm Mini-Games:** Standalone challenges (DDR mode, Simon Says, Chord Hold)

### By Dependency Tier

**Tier 0** (No dependencies):
- S01 Conductor, S02 Input

**Tier 1** (Depends on Tier 0):
- S03 Player (→ S02)

**Tier 2** (Depends on Tier 0-1):
- S04 Combat (→ S01, S02, S03)
- S05 Inventory (→ S03)

**Tier 3** (Depends on Tier 0-2):
- S06 Save/Load, S07 Weapons, S08 Equipment, S09 Dodge/Block, S11 Enemy AI, S13 Vibe Bar, S14 Tools, S15 Vehicles, S16 Grind Rails, S18 Polyrhythm

**Tier 4** (Depends on Tier 0-3):
- S10 Special Moves, S12 Monsters, S17 Puzzles

**Tier 5** (Depends on Tier 0-4):
- S19 Dual XP, S21 Alignment, S24 Cooking, S25 Crafting, S26 Rhythm Mini-Games

**Tier 6** (Depends on Tier 0-5):
- S20 Evolution, S22 NPCs

**Tier 7** (Depends on Tier 0-6):
- S23 Story

---

## Autoload Architecture

Godot 4.5 autoloads (global singletons) registered in `project.godot`:

### Active Autoloads

| Name | Script | Purpose | Access Pattern |
|------|--------|---------|----------------|
| **Conductor** | `src/systems/s01-conductor-rhythm-system/conductor.gd` | Global rhythm timing | `Conductor.beat.connect(...)` |
| **InputManager** | `res/autoloads/input_manager.gd` | Input handling | `InputManager.lane_pressed.connect(...)` |
| **SaveManager** | `res/autoloads/save_manager.gd` | Game persistence | `SaveManager.save_game(slot_id)` |
| **ItemDatabase** | `res/autoloads/item_database.gd` | Weapon/shield loader | `ItemDatabase.get_weapon(id)` |
| **ResonanceAlignment** | `src/systems/s21-resonance-alignment/resonance_alignment.gd` | Alignment tracker | `ResonanceAlignment.shift_alignment(...)` |
| **StoryManager** | `res/story/story_manager.gd` | Story state | `StoryManager.set_story_flag(flag)` |

### Autoload Initialization Order

1. **Conductor** (no dependencies)
2. **InputManager** (no dependencies)
3. **ItemDatabase** (loads JSON data)
4. **SaveManager** (no dependencies)
5. **ResonanceAlignment** (no dependencies)
6. **StoryManager** (references ResonanceAlignment)

**Critical:** Autoloads initialize in registration order. Systems depending on others must be registered later.

---

## Data Flow Patterns

### Pattern 1: JSON → Manager → Runtime

**Used by:** All systems with configuration

```
data/[system]_config.json
    ↓ (FileAccess.open + JSON.parse)
[System]Manager.gd
    ↓ (config Dictionary)
Runtime Components
```

**Example (S05 Inventory):**
```
data/inventory_config.json
data/items.json
    ↓
InventoryManager._load_config()
    ↓
inventory_slots: Array[Dictionary]
item_database: Dictionary
```

### Pattern 2: Autoload → Component → Signal

**Used by:** Rhythm-based mechanics

```
Conductor (autoload)
    ↓ beat.emit(beat_number)
Component._on_beat(beat_number)
    ↓
Component logic (timing check, action execution)
    ↓
Component.signal_name.emit(...)
```

**Example (S09 Dodge):**
```
Conductor.beat.emit(4)
    ↓
DodgeSystem._on_beat(4)
    ↓
Check player input timing
    ↓
If perfect: dodge_executed.emit("Perfect")
```

### Pattern 3: Manager → Scene Instance

**Used by:** Spawning, instantiation

```
Manager holds preloaded scene
    ↓
Manager.spawn_[entity]()
    ↓
scene.instantiate()
    ↓
configure_instance(data)
    ↓
add_child(instance)
```

**Example (S12 Monster Spawning):**
```
MonsterDatabase.get_monster("fire_drake")
    ↓
EnemySpawner.spawn_enemy("fire_drake", position)
    ↓
enemy_scene.instantiate()
    ↓
enemy.initialize(monster_data)
    ↓
add_child(enemy)
```

### Pattern 4: Save/Load Registration

**Used by:** All persistent systems

```
System._ready()
    ↓
SaveManager.register_system("system_name", self)
    ↓
SaveManager.save_game()
    ↓
for each registered_system:
    data[system_name] = system.serialize()
    ↓
JSON.stringify(data)
    ↓
FileAccess.open("user://saves/slot_1.json", WRITE)
```

---

## Signal Architecture

### Global Signal Hubs

**Conductor (S01)** - Rhythm timing signals:
```gdscript
signal beat(beat_number: int)           # Every beat
signal downbeat(measure_number: int)    # First beat of measure
signal measure(measure_number: int)     # Every measure
```

**Listeners:** S04 Combat, S09 Dodge/Block, S10 Special Moves, S16 Grind Rails, S18 Polyrhythm, S26 Mini-Games

**InputManager (S02)** - Input event signals:
```gdscript
signal lane_pressed(lane_id: int, timestamp: float)   # Rhythm lane input
signal button_pressed(action: String)                  # General button
signal stick_moved(stick: String, direction: Vector2, magnitude: float)
```

**Listeners:** S03 Player, S04 Combat, S09 Dodge/Block, S14 Tools

**Combat System (S04)** - Combat event signals:
```gdscript
# Combatant signals:
signal damage_taken(amount: int, source: Combatant, timing: String)
signal damage_dealt(amount: int, target: Combatant, timing: String)
signal health_changed(current_hp: int, max_hp: int, delta: int)
signal defeated(killer: Combatant)
```

**Listeners:** S13 Vibe Bar, S19 Dual XP, S21 Alignment

### Signal Flow Example: Combat Hit

```
1. Player presses attack button
    ↓
2. InputManager.button_pressed.emit("attack")
    ↓
3. CombatManager receives button press
    ↓
4. Check timing against Conductor.beat
    ↓
5. Calculate damage (perfect/good/ok/miss)
    ↓
6. Enemy.damage_taken.emit(damage, player, "Perfect")
    ↓
7. Multiple listeners react:
   - VibeBar.increase_vibe()
   - XPManager.add_combat_xp()
   - CombatUI.show_damage_popup()
```

---

## Scene Composition

### Scene Hierarchy Patterns

**Pattern A: Autoload (No Scene)**
```
# Script only, registered as autoload in project.godot
# Example: Conductor, InputManager, SaveManager
```

**Pattern B: Component Scene**
```
Root Node (CharacterBody2D, Area2D, etc.)
├── Sprite2D / AnimatedSprite2D
├── CollisionShape2D
├── [Gameplay Components]
└── [Script attached to root]
```

**Example: Player (S03)**
```
CharacterBody2D (player.tscn)
├── AnimatedSprite2D (Sprite)
├── CollisionShape2D (Collision)
├── Area2D (InteractionArea)
│   └── CollisionShape2D (InteractionRadius)
├── Camera2D (FollowCamera)
└── [player_controller.gd attached]
```

**Pattern C: Manager + UI Scene**
```
Manager Script (autoload or singleton)
    ↓ manages
UI Scene (CanvasLayer)
├── Panel / Control
└── [UI elements]
```

**Example: Inventory (S05)**
```
InventoryManager (script, referenced globally)
    ↓
inventory_ui.tscn (CanvasLayer)
├── Panel
├── GridContainer (ItemGrid)
└── [inventory_ui.gd]
```

**Pattern D: Path-Based Scene**
```
Path2D / Path3D
├── PathFollow2D / PathFollow3D
└── [Visual / Collision children]
```

**Example: Grind Rail (S16)**
```
Path2D (grind_rail.tscn)
├── PathFollow2D (RailFollower)
├── Line2D (RailVisual)
└── [grind_rail.gd]
```

---

## Critical Paths

### Path 1: Rhythm Gameplay Loop

```
Conductor (S01)
    ↓ beat signal
Combat System (S04)
    ↓ timing check
Player Input (S02)
    ↓ execute action
Dodge/Block (S09) OR Special Move (S10)
    ↓ damage calculation
Vibe Bar (S13) update
    ↓ vibe bonus
XP Gain (S19)
    ↓ level up
Stat Increase
```

**Performance Target:** <2ms total latency from beat to action execution

### Path 2: Combat → Progression Loop

```
Defeat Enemy (S04)
    ↓
Drop Loot (S12)
    ↓
Add to Inventory (S05)
    ↓
Gain XP (S19)
    ↓
Level Up
    ↓
Unlock Evolution (S20)
    ↓
Shift Alignment (S21)
    ↓
Affect NPC Relationships (S22)
    ↓
Influence Story Branch (S23)
```

### Path 3: Save/Load Critical Path

```
Player triggers save
    ↓
SaveManager.save_game(slot_id)
    ↓
For each registered system:
    system.serialize() → Dictionary
    ↓
Aggregate all system data
    ↓
JSON.stringify(save_data)
    ↓
FileAccess.open("user://saves/slot_X.json", WRITE)
    ↓
write JSON string
    ↓
SaveManager.save_completed.emit(slot_id)
```

**Systems Registered for Save:**
- S03 Player state
- S05 Inventory
- S19 XP/levels
- S21 Alignment
- S22 NPC relationships
- S23 Story flags

### Path 4: Startup Initialization

```
1. Engine starts
2. Autoloads initialize (Conductor, InputManager, ItemDatabase, SaveManager, etc.)
3. ItemDatabase loads weapons.json, shields.json, monsters.json
4. Main menu scene loads
5. Player clicks "Load Game"
6. SaveManager.load_game(slot_id)
7. Each system.deserialize(data)
8. Game scene loads with restored state
```

---

## Technology Stack

### Core Engine
- **Godot 4.5.1** - Game engine
- **GDScript 4.5** - Scripting language (100% Godot 4.x compatible)

### Language Features Used
- ✅ CharacterBody2D (not deprecated KinematicBody2D)
- ✅ @export and @onready decorators
- ✅ Typed variables and signals
- ✅ Modern FileAccess, DirAccess, JSON.new() APIs
- ✅ Signal .emit() syntax
- ✅ Typed arrays: Array[Dictionary], Array[int]
- ✅ Class_name declarations

### Plugins & Dependencies
- **LimboAI** (Godot 4.5 compatible) - Behavior trees for enemy AI (S11)

### Data Format
- **JSON** - All configuration and data files (100% of data)
  - Configuration: `*_config.json`
  - Data: `monsters.json`, `weapons.json`, `items.json`, etc.
  - Save files: `user://saves/save_slot_[1-3].json`

### File Organization
```
project_root/
├── src/systems/           # System implementations (most systems)
│   ├── s01-conductor-rhythm-system/
│   ├── s03-player/
│   ├── s04-combat/
│   └── ... (20 systems)
├── res/                   # Resources and scenes
│   ├── autoloads/         # Singleton scripts (S02, S06, S07)
│   ├── resources/         # Resource classes (S07)
│   ├── traversal/         # Traversal components (S16)
│   ├── environment/       # Environmental systems (S18)
│   ├── story/             # Story system (S23)
│   └── data/              # JSON data files
├── data/                  # Additional JSON data
├── checkpoints/           # System completion records
├── research/              # Research documentation
├── knowledge-base/        # Agent documentation
├── HANDOFF-*.md           # Tier 1 → Tier 2 handoff docs
├── SYSTEM-REGISTRY.md     # Complete system catalog
├── ARCHITECTURE-OVERVIEW.md (this file)
├── AGENT-QUICKSTART.md
├── DEVELOPMENT-GUIDE.md
└── project.godot          # Godot project configuration
```

---

## Architecture Principles

### 1. Data-Driven Design
- **Zero hardcoded game data** - All content in JSON
- Scripts are logic engines, JSON defines content
- Easy balance changes without code modification

### 2. Singleton Manager Pattern
- Core systems as autoload singletons
- Centralized state management
- Global accessibility for cross-system communication

### 3. Signal-Based Communication
- Systems communicate via typed signals
- Loose coupling between components
- Event-driven architecture

### 4. Composition Over Inheritance
- Use components attached to nodes
- Extend base classes sparingly
- Favor scene composition

### 5. Godot 4.5 Best Practices
- Modern GDScript 2.0 syntax throughout
- Type hints for performance and safety
- CharacterBody2D for character movement
- FileAccess/DirAccess for file operations

---

## Performance Considerations

### Frame Budget Allocation
- **Conductor:** <0.01ms per frame (timing critical)
- **Combat System:** <1ms per frame
- **Input Manager:** <0.5ms per frame
- **Each Other System:** <1ms per frame target

### Memory Patterns
- **Resource Sharing:** Weapon/Shield resources loaded once, shared
- **Autoload Persistence:** Singletons persist across scenes
- **Scene Instancing:** Monsters/enemies instantiated from preloaded scenes
- **JSON Caching:** Configuration loaded once at startup

### Optimization Strategies
- **Object Pooling:** Enemy instances (S11/S12)
- **Lazy Loading:** Load data only when needed
- **Signal Disconnection:** Disconnect signals on scene exit to prevent leaks
- **Batched Updates:** Vibe bar updates on beat, not every frame

---

## Scalability & Extensibility

### Adding New Content
- **New Monster:** Edit `monsters.json` (no code changes)
- **New Weapon:** Edit `weapons.json` (no code changes)
- **New Recipe:** Edit `recipes.json` or `crafting_recipes.json`
- **New NPC:** Edit `npc_config.json` and dialogue JSON

### Adding New Systems (S27+)
1. Create `src/systems/s##-system-name/` directory
2. Implement manager script following existing patterns
3. Create `data/system_config.json`
4. Register with SaveManager if persistent
5. Connect to relevant signals (Conductor, InputManager, Combat, etc.)
6. Update dependency maps in PARALLEL-EXECUTION-GUIDE-V2.md

### Architectural Limits
- **Max Autoloads:** ~10-15 (current: 6, room for growth)
- **JSON File Size:** Tested up to 10MB (monsters.json with 100+ entries)
- **Signal Connections:** Unlimited (Godot handles efficiently)
- **Save File Size:** ~1-5MB typical (JSON compression possible)

---

## Integration Checklist for New Systems

When creating a new system S##:

- [ ] Create system directory in `src/systems/s##-system-name/`
- [ ] Implement core logic following existing patterns
- [ ] Create `data/system_config.json` for configuration
- [ ] Document in HANDOFF-S##.md for Tier 2 work
- [ ] If persistent, implement `serialize()` and `deserialize()`
- [ ] If persistent, register with SaveManager in `_ready()`
- [ ] Connect to Conductor signals if rhythm-based
- [ ] Connect to InputManager if player-controlled
- [ ] Connect to Combat signals if combat-related
- [ ] Test integration with existing systems
- [ ] Update SYSTEM-REGISTRY.md
- [ ] Update this ARCHITECTURE-OVERVIEW.md dependency map
- [ ] Create checkpoint document
- [ ] Create research document

---

## Next Steps

**For Agents:**
- Quick start: See `AGENT-QUICKSTART.md`
- System details: See `SYSTEM-REGISTRY.md`
- Development workflow: See `DEVELOPMENT-GUIDE.md`
- Framework guides: See `knowledge-base/frameworks/`

**For Future Development:**
- All systems implement Tier 1 (scripts/data)
- Tier 2 work pending (scene configuration via MCP)
- Testing framework in place (integration tests, quality gates)
- Ready for scene configuration and testing phase

---

**End of Architecture Overview**
