# Research: S12 - Monster Database
**Agent:** Claude Code Web (Tier 1)
**Date:** 2025-11-18
**Duration:** 30 minutes

## Godot 4.5 Official Documentation

### Custom Resources
- **URL:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Key Insight:** Custom Resources in Godot 4 are first-class citizens with proper type support
- **Implementation:** Use `extends Resource` and `class_name` to create typed resource classes
- **Advantages:** Built-in serialization, inspector integration, type safety

### JSON Parsing
- **URL:** https://docs.godotengine.org/en/4.4/classes/class_json.html
- **Key Methods:**
  - `FileAccess.open()` to read files
  - `JSON.parse_string()` to parse JSON
  - Returns parsed data as Dictionary/Array
- **Pattern:** Load JSON → Parse → Convert to Resource instances

## Existing Godot 4.5 Projects

### ResourceDatabases Plugin
- **URL:** https://github.com/DarthPapalo/ResourceDatabases
- **Architecture Pattern:** Resource-based data management with custom editor
- **Key Insight:** Resources can be nested and chained for complex structures
- **Applicability:** We'll use pure Resources without plugin for simplicity

### Monster/Creature Systems
- **Pattern:** Monster data as Resources, database as singleton autoload
- **Best Practice:** Separate data (JSON) from logic (GDScript)
- **Caching:** Load all monsters at startup, cache by ID in Dictionary

## Pokemon Type Effectiveness System

### Core Mechanics
- **URL:** https://bulbapedia.bulbagarden.net/wiki/Type/Type_chart
- **Effectiveness Values:**
  - Super Effective: 2.0x damage
  - Neutral: 1.0x damage
  - Not Very Effective: 0.5x damage
  - Immune: 0.0x damage (no effect)

### Dual-Type Calculation
- If defender has 2 types, multiply both effectiveness values
- Example: Fire vs Bug/Grass = 2.0 × 2.0 = 4.0x damage
- Example: Ground vs Flying/Electric = 2.0 × 0.0 = 0.0x (immune wins)

### 12 Types Implementation
- Types: Normal, Fire, Water, Grass, Electric, Ice, Fighting, Poison, Ground, Flying, Psychic, Dark
- Matrix: 12×12 = 144 effectiveness relationships
- Storage: Nested Dictionary in JSON for easy lookup

## GDScript 4.5 Patterns

### Type Hints Best Practices
```gdscript
# ALWAYS use explicit types
var monsters: Dictionary = {}  # ID → MonsterResource
var types: Array[String] = []

# Functions must have type hints
func get_monster(id: String) -> MonsterResource:
    return monsters.get(id)
```

### Resource Pattern
```gdscript
extends Resource
class_name MonsterResource

@export var id: String = ""
@export var monster_name: String = ""
@export var types: Array[String] = []
# etc...
```

### Singleton Autoload Pattern
```gdscript
extends Node
class_name MonsterDatabaseImpl  # Avoid naming conflict with autoload

var monsters: Dictionary = {}

func _ready() -> void:
    _load_monsters()
    _load_type_chart()
```

## Evolution System Design

### Evolution Types
1. **Level-based:** Evolve at specific level (most common)
2. **Item-based:** Use item to trigger evolution
3. **Soul Shard:** Special currency from S20

### Data Structure
```json
"evolution_requirements": {
  "type": "level",  // "level", "item", "soul_shard"
  "value": 16,      // level number or item ID
  "evolves_into": "002_voltix"
}
```

## Integration with S11 (Enemy AI)

### AI Behavior Types
From S11 research, we have 4 behavior types:
- aggressive
- defensive
- ranged
- swarm

### Monster → AI Mapping
Each monster gets assigned a behavior type based on stats/characteristics:
- High attack, low defense → aggressive
- High defense → defensive
- Long-range moves → ranged
- Low-tier, group encounters → swarm

## Key Decisions

### Decision 1: JSON vs .tres Resources
**Choice:** JSON for data, instantiate Resources at runtime
**Why:**
- JSON easier to edit and generate (100+ monsters)
- Can version control and merge easily
- Runtime conversion adds minimal overhead (one-time load)

### Decision 2: Type Storage Format
**Choice:** Array[String] for types (not enums)
**Why:**
- More flexible for dual-types
- JSON-friendly
- Easy string comparison

### Decision 3: Evolution Chain Structure
**Choice:** Each monster knows its evolution target (forward-only)
**Why:**
- Simple lookup
- No circular references
- Easy to visualize evolution trees

### Decision 4: Loot Table Design
**Choice:** Dictionary with rarity tiers and drop chance
**Why:**
- Integrates with S05 Inventory
- Flexible for balancing
- Supports multiple drops

## Gotchas for Tier 2

### GDScript 4.5 Syntax
- ❌ NO `"═" * 60` (string multiplication)
- ✅ YES `"═".repeat(60)` (use .repeat() method)
- Always use explicit return types
- class_name required for all custom classes

### JSON Loading
- Use `res://` paths, not relative paths
- Check for null after `FileAccess.open()`
- Validate JSON parse result before using

### Type Effectiveness Lookup
- Store as nested Dict: `type_chart[attacker_type][defender_type]`
- Default to 1.0 if relationship not defined
- Handle dual types with multiplication

### Performance
- Load all monsters at _ready(), not on-demand
- Cache type effectiveness lookups
- Use Dictionary[id] for O(1) monster lookup

## Code Patterns Discovered

### Safe JSON Loading Pattern
```gdscript
func _load_json(path: String) -> Variant:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Failed to load: " + path)
        return null

    var json_text := file.get_as_text()
    file.close()

    var json := JSON.new()
    var parse_result := json.parse(json_text)
    if parse_result != OK:
        push_error("JSON parse error in " + path)
        return null

    return json.data
```

### Type Effectiveness Calculation
```gdscript
func calculate_type_effectiveness(attacker_types: Array[String], defender_types: Array[String]) -> float:
    var effectiveness := 1.0

    for atk_type in attacker_types:
        for def_type in defender_types:
            var modifier := _get_type_modifier(atk_type, def_type)
            effectiveness *= modifier

    return effectiveness
```

## Reusable Patterns

### Resource Database Pattern
This pattern can be reused for:
- Move database (S10 Special Moves)
- Item database (S05 Inventory)
- NPC database (S22)
- Recipe database (S24 Cooking, S25 Crafting)

**Template:**
1. Create Resource class (extends Resource, class_name)
2. Create JSON data file
3. Create autoload Database singleton
4. Load JSON → instantiate Resources → cache in Dictionary
5. Provide query methods (get_by_id, get_by_type, etc.)

## References

- Godot 4.5 Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Godot 4.5 JSON: https://docs.godotengine.org/en/4.4/classes/class_json.html
- Pokemon Type Chart: https://bulbapedia.bulbagarden.net/wiki/Type/Type_chart
- Custom Resources Tutorial: https://simondalvai.org/blog/godot-custom-resources/
- Godot File I/O: https://kidscancode.org/godot_recipes/4.x/basics/file_io/

## Next Steps for Tier 1

1. Create `res/resources/monster_resource.gd` - MonsterResource class
2. Create `res/autoloads/monster_database.gd` - MonsterDatabase singleton
3. Create `src/systems/s12-monsters/evolution_system.gd` - Evolution logic
4. Generate `res/data/monsters.json` - 100+ monster definitions
5. Generate `res/data/type_effectiveness.json` - 12×12 type matrix
6. Create `HANDOFF-S12.md` - Complete instructions for Tier 2
