# Research: S22 - Complex NPC System
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 45 minutes

---

## Godot 4.5 Documentation

### Dialogue Manager Plugin (Nathan Hoad)
- **URL**: https://github.com/nathanhoad/godot_dialogue_manager
- **Version**: v3.7 (June 2025) - Latest for Godot 4.4+
- **Compatibility**: Godot 4.4+ required (v3.4+)
- **License**: Free (open source)
- **Features**:
  - Stateless branching dialogue editor
  - Visual editor within Godot engine
  - GDScript and C# support
  - Localization support (gettext, CSV)
  - Automatic POT generation support

### Dialogue Manager Syntax
- **Documentation**: https://github.com/nathanhoad/godot_dialogue_manager/blob/main/docs/
- **Key Files**:
  - Basic_Dialogue.md - Foundation syntax
  - Conditions_Mutations.md - Variables and logic
  - Using_Dialogue.md - Game integration
  - API.md - Technical reference

### Conditional Dialogue Syntax
```
# Basic conditional
if SomeGlobal.some_property >= 10
    Nathan: That property is greater than or equal to 10
elif SomeGlobal.some_other_property == "some value"
    Nathan: Or we might be in here.
else
    Nathan: If neither are true, I'll say this.

# Conditional responses
Nathan: What would you like?
- This one [if SomeGlobal.some_property == 0]
    Nathan: Ah, so you want this one?
- Another one [if SomeGlobal.some_method()]
    => another_title
- Nothing
    => END

# While loops
while SomeGlobal.some_property < 10
    Nathan: The property is still less than 10 - {{SomeGlobal.some_property}}.
    do SomeGlobal.some_property += 1
Nathan: Now, we can move on.
```

### Variable Interpolation
- Use `{{variable_name}}` to interpolate variables into dialogue text
- Can access autoload singletons (e.g., `ResonanceAlignment.get_alignment()`)
- Can call methods and access properties

---

## Existing Projects

### NPCScheduler Algorithm
- **URL**: https://github.com/JakeButf/NPCScheduler
- **Platform**: Unity/Godot 4.1+
- **Purpose**: Time-based NPC scheduling
- **Key Insight**: Takes current time, start time, finish time, and patrol points
- **Implementation**: Calculate NPC position based on time of day

### Community Approaches
From Godot Forums discussions:
1. **Signal-based scheduling**: NPCs receive signals at "in-game ticks" to move/act
2. **Fixed schedule pattern**:
   - 6 AM → Location A
   - 8 AM → Location B
   - 7 AM → Interpolate between A and B
3. **State machine approach**: Each time period = different state with location/activity

### Key Challenge
When player enters scene, NPC must be at correct location for current time. Solution: Calculate position on scene load based on current in-game time.

---

## Plugins/Addons

### Dialogue Manager (Nathan Hoad) ✓ RECOMMENDED
- **Installation**: AssetLib search "Dialogue Manager" OR GitHub clone
- **Asset Library URL**: https://godotengine.org/asset-library/asset/1207
- **Enable**: Project Settings → Plugins → Dialogue Manager
- **Why**: Industry standard, actively maintained, rich feature set
- **Godot 4.5 Compatible**: Yes (requires 4.4+)

### BehaviourToolkit
- **URL**: https://godotengine.org/asset-library/asset/2333
- **Purpose**: State machines and behavior trees for AI
- **Use Case**: Complex NPC AI behaviors (optional enhancement)
- **Note**: Not required for basic NPC system

---

## GDScript 4.5 Best Practices

### NPC Base Class Pattern
```gdscript
# Godot 4.5 | GDScript 4.5
# System: S22 - Complex NPC System
class_name NPCBase extends CharacterBody2D

# Signals with typed parameters
signal relationship_changed(npc_id: String, new_value: int)
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)
signal quest_triggered(quest_id: String)
signal schedule_changed(npc_id: String, location: String, activity: String)

# Type hints required
var npc_id: String = ""
var npc_name: String = ""
var relationship: int = 50  # 0-100 scale
var dialogue_state: Dictionary = {}
var schedule: Array[Dictionary] = []
var current_location: String = ""
var current_activity: String = ""
var alignment_preference: String = "neutral"  # authentic/algorithmic/neutral

# Method with type hints
func change_relationship(amount: int, reason: String) -> void:
    var old_value: int = relationship
    relationship = clamp(relationship + amount, 0, 100)
    relationship_changed.emit(npc_id, relationship)

# Time-based schedule check
func update_schedule(current_time: String) -> void:
    for entry: Dictionary in schedule:
        if entry["time"] == current_time:
            current_location = entry["location"]
            current_activity = entry["activity"]
            schedule_changed.emit(npc_id, current_location, current_activity)
            break
```

### JSON Configuration Pattern
```json
{
  "_schema_version": "1.0",
  "_godot_version": "4.5",
  "_system_id": "S22",

  "relationship_config": {
    "thresholds": {
      "stranger": 0,
      "acquaintance": 25,
      "friend": 50,
      "close_friend": 75,
      "best_friend": 100
    },
    "actions": {
      "complete_quest": 10,
      "give_gift": 5,
      "ignore_npc": -2,
      "insult_npc": -10,
      "help_in_combat": 15
    }
  },

  "npcs": {
    "elder": {
      "npc_name": "Village Elder",
      "starting_relationship": 50,
      "alignment_preference": "authentic",
      "dialogue_file": "res://src/systems/s22-npc-system/dialogue/elder.dialogue",
      "schedule": [
        { "time": "06:00", "location": "home", "activity": "sleep" },
        { "time": "08:00", "location": "town_square", "activity": "work" },
        { "time": "18:00", "location": "tavern", "activity": "socialize" },
        { "time": "22:00", "location": "home", "activity": "sleep" }
      ]
    }
  }
}
```

---

## Code Patterns Discovered

### Pattern 1: Dialogue Manager Integration
```gdscript
# In NPC script
@onready var dialogue_manager = DialogueManager  # Autoload

func start_dialogue() -> void:
    # Get dialogue resource
    var dialogue_resource = load(dialogue_file_path)

    # Start dialogue with state dictionary
    var state_dict: Dictionary = {
        "npc_relationship": relationship,
        "player_alignment": ResonanceAlignment.get_alignment(),
        "has_quest_item": false  # Example state
    }

    dialogue_manager.show_dialogue(dialogue_resource, "start", state_dict)
    dialogue_started.emit(npc_id)

# Connect to Dialogue Manager signals
func _ready() -> void:
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    DialogueManager.mutation.connect(_on_dialogue_mutation)

func _on_dialogue_mutation(mutation: Dictionary) -> void:
    # Handle mutations from dialogue (quest triggers, relationship changes)
    if mutation.has("relationship_change"):
        change_relationship(mutation["relationship_change"], "dialogue")
    if mutation.has("trigger_quest"):
        trigger_quest(mutation["trigger_quest"])
```

### Pattern 2: Time-Based Schedule System
```gdscript
# Schedule interpolation
func get_current_location_for_time(game_time: String) -> String:
    # Parse time string (e.g., "14:30")
    var parts: PackedStringArray = game_time.split(":")
    var hours: int = int(parts[0])
    var minutes: int = int(parts[1])
    var current_minutes: int = hours * 60 + minutes

    # Find schedule entry
    var last_entry: Dictionary = {}
    for entry: Dictionary in schedule:
        var entry_parts: PackedStringArray = entry["time"].split(":")
        var entry_minutes: int = int(entry_parts[0]) * 60 + int(entry_parts[1])

        if entry_minutes <= current_minutes:
            last_entry = entry
        else:
            break

    return last_entry.get("location", "unknown")
```

### Pattern 3: Relationship-Based Dialogue Branches
```
# In .dialogue file
~ start

Elder: Hello, traveler.

# Check relationship threshold
if npc_relationship >= 75
    Elder: My dear friend! So good to see you!
    => close_friend_branch
elif npc_relationship >= 50
    Elder: Good to see you again.
    => friend_branch
elif npc_relationship >= 25
    Elder: I recognize you. What brings you here?
    => acquaintance_branch
else
    Elder: I don't believe we've met.
    => stranger_branch
```

### Pattern 4: Alignment-Based Dialogue
```
# In .dialogue file
~ start

Elder: I sense your resonance...

# Check player alignment using autoload
if ResonanceAlignment.get_alignment() > 50
    Elder: You have an authentic spirit. I appreciate that.
    do npc_relationship += 5
    => authentic_branch
elif ResonanceAlignment.get_alignment() < -50
    Elder: You seem rather... mechanical. That troubles me.
    do npc_relationship -= 3
    => algorithmic_branch
else
    Elder: You walk a balanced path. Interesting.
    => neutral_branch
```

---

## Key Decisions

### Decision 1: Use Dialogue Manager Plugin
**Why**: Industry standard, actively maintained, Godot 4.4+ compatible, rich feature set
**Alternative**: Custom dialogue system (more work, less features)
**Implementation**: Document installation in HANDOFF for MCP agent

### Decision 2: CharacterBody2D Base Class
**Why**: NPCs may need to move (schedule system), collision detection
**Alternative**: Node2D (static NPCs only)
**Implementation**: NPCBase extends CharacterBody2D

### Decision 3: JSON Configuration for All NPC Data
**Why**: Easy editing, no code changes for new NPCs, supports localization
**Alternative**: Hardcode NPC data in scripts (not maintainable)
**Implementation**: Load from `data/npc_config.json`

### Decision 4: Schedule as Array of Dictionaries
**Why**: Simple, JSON-compatible, easy to edit
**Alternative**: Custom Schedule resource (more complex)
**Implementation**: `[{"time": "08:00", "location": "town", "activity": "work"}]`

### Decision 5: Integration with S21 Alignment
**Why**: NPCs react to player's philosophical stance (thematic core)
**Implementation**: Check `ResonanceAlignment.get_alignment()` in dialogue conditions

---

## Gotchas for Tier 2

### Gotcha 1: Dialogue Manager Plugin Installation
**Issue**: Plugin must be installed before testing NPCs
**Solution**: Document clear installation steps in HANDOFF
**MCP Note**: May need manual installation via AssetLib or GitHub clone

### Gotcha 2: Autoload Registration Order
**Issue**: NPCs depend on ResonanceAlignment autoload
**Solution**: Ensure ResonanceAlignment registered before using in dialogue
**MCP Note**: Check project.godot autoload order

### Gotcha 3: Dialogue File Path Format
**Issue**: Must use `res://` absolute paths for .dialogue files
**Solution**: Store full path in npc_config.json
**Example**: `"dialogue_file": "res://src/systems/s22-npc-system/dialogue/elder.dialogue"`

### Gotcha 4: State Dictionary Typing
**Issue**: Dialogue Manager expects specific types in state dict
**Solution**: Ensure all state values are properly typed (int, float, bool, String)
**Example**: `{"npc_relationship": int(relationship)}`

### Gotcha 5: Time String Format
**Issue**: Schedule times must be consistent format
**Solution**: Use "HH:MM" 24-hour format (e.g., "14:30" not "2:30 PM")
**Validation**: Add format validation in load_config()

---

## Reusable Patterns for Future Systems

### Pattern: Dialogue-Driven Gameplay
**System**: S22 (NPC), S23 (Story)
**Insight**: Dialogue Manager can trigger game events via mutations
**Example**: `do trigger_quest("find_necklace")` in dialogue calls game method
**Reuse**: Any system needing branching narrative

### Pattern: Time-Based Behavior
**System**: S22 (NPC schedules)
**Insight**: Calculate state based on game time, not real-time updates
**Example**: On scene load, calculate where NPC should be for current time
**Reuse**: Day/night cycle, shop hours, event scheduling

### Pattern: Relationship Meters
**System**: S22 (NPC relationships)
**Insight**: 0-100 scale with threshold tiers, action-based changes
**Example**: Stranger (0-25), Friend (50-75), Best Friend (75-100)
**Reuse**: Faction reputation, party member affection, monster taming

### Pattern: Alignment-Affected Interactions
**System**: S22 (NPC dialogue), S21 (Alignment)
**Insight**: Game state affects NPC reactions and available options
**Example**: High authentic alignment → special dialogue options
**Reuse**: S23 (Story endings), S12 (Monster recruitment), S24 (Cooking recipes)

---

## Integration with Existing Systems

### S21 Resonance Alignment (DEPENDENCY)
- **File**: `src/systems/s21-resonance-alignment/resonance_alignment.gd`
- **Autoload**: `ResonanceAlignment`
- **Usage**: Check `ResonanceAlignment.get_alignment()` in dialogue
- **Impact**: NPCs have alignment preferences, react differently to player
- **Example**: Authentic-aligned elder gives better rewards to authentic players

### S03 Player (DEPENDENCY)
- **File**: `src/systems/s03-player/player_controller.gd`
- **Usage**: Player interacts with NPCs (collision, input)
- **Integration**: Player script calls `npc.start_dialogue()` on interaction
- **Example**: Press "E" near NPC → trigger dialogue

### S04 Combat (DEPENDENCY)
- **File**: `src/systems/s04-combat/combat_manager.gd`
- **Usage**: Quest combat encounters, NPC assistance
- **Integration**: NPCs can trigger combat via dialogue choices
- **Example**: "Defend the village!" → start_combat("bandit_encounter")

### S06 Save/Load (FUTURE)
- **Usage**: Persist relationship values, dialogue state, NPC locations
- **Methods**: `get_save_data()`, `load_save_data()`
- **Data**: `{"relationships": {"elder": 65}, "dialogue_flags": {"met_elder": true}}`

### S23 Story (FUTURE)
- **Usage**: Story progression through NPC dialogues
- **Integration**: Quest triggers, story flags, ending requirements
- **Example**: Talk to all main NPCs → unlock final quest

---

## References

### Official Documentation
- Dialogue Manager: https://github.com/nathanhoad/godot_dialogue_manager
- Dialogue Manager Docs: https://github.com/nathanhoad/godot_dialogue_manager/tree/main/docs
- Godot 4.5 CharacterBody2D: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html
- Godot 4.5 Signal: https://docs.godotengine.org/en/4.5/classes/class_signal.html

### Community Resources
- NPCScheduler Algorithm: https://github.com/JakeButf/NPCScheduler
- Evenrift Dialogue Tutorial: https://evenrift.substack.com/p/creating-a-dialogue-system-in-godot
- Godot Forums NPC Discussion: https://godotforums.org/d/38234-how-to-implement-intelligent-npcs

### Example Projects
- Dialogue Manager Examples: https://github.com/nathanhoad/godot_dialogue_manager/tree/main/examples
- Asset Library: https://godotengine.org/asset-library/asset/1207

---

## Next Steps

1. ✅ Research complete
2. ⏭️ Create `npc_base.gd` with full implementation
3. ⏭️ Create `npc_config.json` with elder NPC example
4. ⏭️ Create `elder.dialogue` with alignment-based branches
5. ⏭️ Create `HANDOFF-S22.md` with Dialogue Manager installation steps
6. ⏭️ Commit and push to branch

---

**Research Complete**
**Time Spent**: 45 minutes
**Confidence Level**: High
**Ready for Implementation**: Yes ✓
