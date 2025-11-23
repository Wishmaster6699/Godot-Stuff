# Research: S07 - Weapons & Shields Database
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 30 minutes

## Godot 4.5 Documentation

### Custom Resources
- **URL:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Key Insight:** Resources extend from the Resource base class and use `class_name` for registration
- **Type Safety:** Use `@export` annotation (NOT `export` keyword from Godot 3.x)
- **Memory:** Resources are loaded once and shared across all instances - very efficient
- **Serialization:** Built-in serialization to .tres (text) or .res (binary) files

### GDScript @export Properties
- **URL:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
- **Key Insight:** Godot 4.x uses `@export` annotation, not `export` keyword
- **Best Practice:** Always specify type hints for exported variables
- **Arrays:** Use typed arrays like `Array[String]` for type safety

### JSON Parsing in Godot 4
- **URL:** https://docs.godotengine.org/en/4.4/classes/class_json.html
- **Key Pattern:**
  ```gdscript
  var json = JSON.new()
  var error = json.parse(json_string)
  if error == OK:
      var data = json.data  # Dictionary or Array
  else:
      push_error("JSON Parse Error: %s" % json.get_error_message())
  ```
- **File Loading:** Use `FileAccess.open()` with `FileAccess.READ`
- **Error Handling:** Always check `FileAccess.file_exists()` first
- **Get Content:** Use `FileAccess.get_as_text()` to read entire file

## Existing Projects

### GameDev Academy - JSON in Godot Complete Guide
- **URL:** https://gamedevacademy.org/json-in-godot-complete-guide/
- **Architecture Pattern:**
  - Use autoload singleton for database management
  - Cache all loaded resources at startup
  - Provide getter methods for O(1) access
- **Data Structure:** Store items in dictionary with ID as key for fast lookup

### Ezcha - Custom Resources are OP
- **URL:** https://ezcha.net/news/3-1-23-custom-resources-are-op-in-godot-4
- **Pattern:** Custom resources can be nested and contain methods, signals, properties
- **Use Case:** Perfect for game item databases with varied stats

## Code Patterns

### Custom Resource Class Pattern
```gdscript
extends Resource
class_name WeaponResource

@export var id: String = ""
@export var name: String = ""
@export var damage: int = 0
@export var speed: float = 1.0
# ... more properties
```

### JSON Loading Pattern
```gdscript
func load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("File not found: %s" % path)
        return {}

    var file = FileAccess.open(path, FileAccess.READ)
    var content = file.get_as_text()
    file.close()

    var json = JSON.new()
    var error = json.parse(content)
    if error != OK:
        push_error("JSON Parse Error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
        return {}

    return json.data
```

### Autoload Singleton Pattern
```gdscript
extends Node

var weapons: Dictionary = {}  # id -> WeaponResource
var shields: Dictionary = {}  # id -> ShieldResource

func _ready() -> void:
    _load_weapons()
    _load_shields()

func get_weapon(id: String) -> WeaponResource:
    if id in weapons:
        return weapons[id]
    push_warning("Weapon not found: %s" % id)
    return null
```

## Key Decisions

### Decision 1: Use Custom Resources (Not Plain Dictionaries)
**Why:**
- Type safety with GDScript type hints
- Editor integration (can edit in inspector)
- Better IDE autocomplete
- Built-in serialization if needed later
- Can add methods to resources if needed

### Decision 2: JSON for Data Storage (Not .tres files)
**Why:**
- Human-readable and easy to edit
- Easy to generate/modify with external tools
- Version control friendly (text diff)
- Industry standard format
- Easy for content creators to edit

### Decision 3: Dictionary-Based Cache with ID Lookup
**Why:**
- O(1) lookup time by ID
- Memory efficient (shared resource instances)
- Simple API: `get_weapon(id)`
- Easy to iterate over all items

### Decision 4: Load All Data at Startup
**Why:**
- Small dataset (50+ weapons, 15+ shields)
- Avoids runtime loading delays
- Simpler error handling
- Ensures all data is valid at startup

## Gotchas for Tier 2

### Godot 4.5 Specific
- JSON parsing changed from Godot 3.x - must use JSON.new() pattern
- FileAccess API changed - use FileAccess.open() not File.new()
- @export syntax, not export keyword
- Use `FileAccess.file_exists()` not `File.file_exists()`

### System-Specific
- Resource instances are shared - don't modify weapon stats at runtime (create a copy if needed)
- JSON must be valid - syntax errors will crash at startup
- IDs must be unique - no duplicate checking implemented (could add later)
- Icon paths are placeholders - actual assets come later from asset pipeline

### Integration Notes
- S04 Combat will need to access weapon damage for calculations
- S05 Inventory will need weapon/shield icon paths
- S08 Equipment will equip/unequip weapons
- S10 Special Moves will filter by weapon type
- S25 Crafting will create new weapon instances

## Weapon Balancing Research

### Tier System (1-5)
- **Tier 1:** Starter weapons (damage: 5-10, value: 10-50)
- **Tier 2:** Basic weapons (damage: 10-20, value: 50-150)
- **Tier 3:** Advanced weapons (damage: 20-30, value: 150-500)
- **Tier 4:** Elite weapons (damage: 30-40, value: 500-1500)
- **Tier 5:** Legendary weapons (damage: 40-50, value: 1500+)

### Weapon Types & Characteristics
- **Swords:** Balanced damage and speed (damage: medium, speed: medium, range: short)
- **Axes:** High damage, slow speed (damage: high, speed: low, range: short)
- **Spears:** Long range, medium damage (damage: medium, speed: medium, range: long)
- **Bows:** Long range, lower damage (damage: low-medium, speed: fast, range: very long)
- **Staves:** Magic damage, varied effects (damage: medium, speed: slow, range: medium, special effects)

### Shield Types & Characteristics
- **Small Shields:** Low defense, high mobility (defense: 5-10, block: 20-40%, weight: 1.0-2.0)
- **Medium Shields:** Balanced defense and mobility (defense: 10-20, block: 40-60%, weight: 2.0-3.5)
- **Large Shields:** High defense, low mobility (defense: 20-30, block: 60-80%, weight: 3.5-5.0)

## References

### Documentation
- Godot 4.5 Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Godot 4.4 JSON Class: https://docs.godotengine.org/en/4.4/classes/class_json.html
- GDScript Exports: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html

### Tutorials
- JSON in Godot: https://gamedevacademy.org/json-in-godot-complete-guide/
- Custom Resources: https://ezcha.net/news/3-1-23-custom-resources-are-op-in-godot-4
- GDQuest Save/Load: https://www.gdquest.com/library/save_game_godot4/

### Community
- Godot Forums: Multiple threads on JSON loading and custom resources
- Stack Overflow: Godot 4 export syntax questions

## Extensibility Plan

### Adding New Weapons
Simply add new JSON entry to weapons.json - no code changes needed:
```json
{
  "id": "new_sword",
  "name": "New Sword",
  "type": "sword",
  "tier": 3,
  "damage": 25,
  "speed": 1.0,
  "range": 32,
  "attack_pattern": "slash",
  "special_effects": ["fire_damage"],
  "icon_path": "res://assets/icons/weapons/new_sword.png",
  "value": 300
}
```

### Future Integration Points
- **S08 Equipment:** Add equipped weapon tracking
- **S10 Special Moves:** Filter weapons by type for special attacks
- **S25 Crafting:** Create weapon upgrade/enhancement system
- **S20 Evolution:** Weapon evolution for monster-based weapons

## Testing Strategy

### Unit Tests (Tier 2)
- Load weapons.json without errors
- Load shields.json without errors
- Verify 50+ weapons loaded
- Verify 15+ shields loaded
- Test get_weapon() with valid ID
- Test get_weapon() with invalid ID
- Test get_all_weapons() returns Array

### Integration Tests (Tier 2)
- ItemDatabase autoload accessible globally
- Combat system can access weapon damage
- Inventory can access weapon icons
- All JSON IDs are unique

### Data Quality Tests
- All weapons have required fields
- All shields have required fields
- No missing or null values
- Stat ranges are reasonable (no damage: 9999)

## Research Complete

**Status:** Research phase complete, ready for implementation
**Next Step:** Create WeaponResource and ShieldResource classes
**Estimated Implementation Time:** 4-5 hours (Tier 1)
