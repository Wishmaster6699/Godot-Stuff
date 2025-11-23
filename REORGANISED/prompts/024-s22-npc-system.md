<objective>
Implement Complex NPC System (S22) - Dialogue Manager integration, branching dialogue with state tracking, relationship meters (0-100), quest triggers, NPC schedules, alignment-based dialogue branches.

DEPENDS ON: S21 (Alignment for dialogue), S03 (Player), S04 (Combat)
WAVE 3 - Sequential (needs S21 complete first)
</objective>

<context>
NPCs are the world's characters. They have dialogue trees, relationships, schedules, and react to player alignment.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S22")`
- [ ] Quality gates: `check_quality_gates("S22")`
- [ ] Checkpoint validation: `validate_checkpoint("S22")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S22", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Install Dialogue Manager Plugin
- Visit: https://github.com/nathanhoad/godot_dialogue_manager
- Install via AssetLib or GitHub
- Enable in Project Settings

### 2. NPC Base Class
Create `res://npcs/npc_base.gd`:
```gdscript
var npc_id: String
var relationship = 50  # 0-100
var dialogue_state = {}
var schedule = []  # [(time, location), ...]
```

### 3. Dialogue Trees
Create `.dialogue` files using Dialogue Manager syntax:
```
~ start
NPC: Hello, traveler!
[if player.alignment > 50]
  - I appreciate your authentic approach. => authentic_branch
[else]
  - You seem... efficient. => algorithm_branch
```

### 4. Relationship System
```json
{
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
      "ignore_npc": -2
    }
  }
}
```

### 5. NPC Schedules
```json
{
  "npc_elder": {
    "schedule": [
      { "time": "06:00", "location": "home", "activity": "sleep" },
      { "time": "08:00", "location": "town_square", "activity": "work" },
      { "time": "18:00", "location": "tavern", "activity": "socialize" }
    ]
  }
}
```

### 6. Quest Triggers
Dialogue can trigger quests:
```
NPC: Can you find my lost necklace?
- Yes, I'll help. => trigger_quest("find_necklace")
- No, sorry. => relationship -= 5
```

### 7. Test Scene
- NPC with dialogue tree
- Relationship changes from player choices
- Schedule moves NPC between locations
- Alignment-based branches

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://npcs/npc_base.gd` - Complete NPC base class with relationship tracking, dialogue state, schedules
   - Dialogue integration with Dialogue Manager plugin
   - Relationship system (0-100 scale)
   - NPC schedule system with time-based locations
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/npc_config.json` - Complete NPC configuration with relationship thresholds, schedules, quest triggers
   - Valid JSON format with all required fields

3. **Create sample .dialogue files** using the Write tool
   - `res://npcs/dialogue/elder.dialogue` - Sample dialogue tree with alignment-based branches
   - Dialogue Manager syntax with conditional branches

4. **Create HANDOFF-S22.md** documenting:
   - Dialogue Manager plugin installation steps
   - Scene structures needed (test NPC scene)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://npcs/npc_base.gd` - Complete NPC base class implementation
- `res://data/npc_config.json` - NPC configuration data
- `res://npcs/dialogue/elder.dialogue` - Sample dialogue tree
- `HANDOFF-S22.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)
- Install plugins directly (document installation for MCP agent)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S22.md
2. Install Dialogue Manager plugin (via AssetLib or GitHub)
3. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_npc.tscn
   - `add_node` - Build node hierarchies for test scenes
   - `attach_script` - Connect npc_base.gd to nodes
   - `update_property` - Set node properties
4. Test in Godot editor using `play_scene` and `get_godot_errors`
5. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S22.md` with this structure:

```markdown
# System S22 Handoff - Complex NPC System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://npcs/npc_base.gd` - NPC base class with relationship tracking, dialogue state, schedules

### Data Files
- `res://data/npc_config.json` - NPC configuration with relationship thresholds, schedules, quest triggers

### Dialogue Files
- `res://npcs/dialogue/elder.dialogue` - Sample dialogue tree with alignment-based branches

---

## Plugin Installation Required (MCP Agent)

**Dialogue Manager Plugin:**
1. Visit: https://github.com/nathanhoad/godot_dialogue_manager
2. Install via AssetLib search "Dialogue Manager" OR clone from GitHub
3. Enable in Project Settings → Plugins → Dialogue Manager
4. Verify plugin loads without errors

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_npc.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_npc.tscn", "Node2D", "TestNPC")

# Add NPC node with script
add_node("TestNPC", "CharacterBody2D", "TestNPCCharacter")
attach_script("TestNPC/TestNPCCharacter", "res://npcs/npc_base.gd")

# Add UI elements for testing
add_node("TestNPC", "Label", "RelationshipDisplay")
add_node("TestNPC", "Label", "NPCScheduleDisplay")
add_node("TestNPC", "Label", "DialogueStateDisplay")
add_node("TestNPC", "Button", "TalkToNPC")
add_node("TestNPC", "Button", "GiveGift")
add_node("TestNPC", "Button", "AdvanceTime")

# Configure properties
update_property("TestNPC/TestNPCCharacter", "position", Vector2(400, 300))
update_property("TestNPC/RelationshipDisplay", "position", Vector2(10, 10))
update_property("TestNPC/NPCScheduleDisplay", "position", Vector2(10, 40))
update_property("TestNPC/DialogueStateDisplay", "position", Vector2(10, 70))
update_property("TestNPC/TalkToNPC", "position", Vector2(10, 120))
update_property("TestNPC/TalkToNPC", "text", "Talk to NPC")
update_property("TestNPC/GiveGift", "position", Vector2(10, 160))
update_property("TestNPC/GiveGift", "text", "Give Gift (+5 Relationship)")
update_property("TestNPC/AdvanceTime", "position", Vector2(10, 200))
update_property("TestNPC/AdvanceTime", "text", "Advance Time (Test Schedule)")
```

**Node Hierarchy:**
```
TestNPC (Node2D)
├── TestNPCCharacter (CharacterBody2D) [npc_base.gd attached]
├── RelationshipDisplay (Label)
├── NPCScheduleDisplay (Label)
├── DialogueStateDisplay (Label)
├── TalkToNPC (Button)
├── GiveGift (Button)
└── AdvanceTime (Button)
```

---

## Integration Points

### Signals Exposed:
- `relationship_changed(npc_id: String, new_value: int)` - Emitted when relationship changes
- `dialogue_started(npc_id: String)` - Emitted when dialogue begins
- `dialogue_ended(npc_id: String)` - Emitted when dialogue ends
- `quest_triggered(quest_id: String)` - Emitted when dialogue triggers quest
- `schedule_changed(npc_id: String, location: String, activity: String)` - Emitted when NPC moves per schedule

### Public Methods:
- `change_relationship(amount: int, reason: String)` - Change relationship value
- `start_dialogue()` - Start dialogue with this NPC
- `get_current_location() -> String` - Get NPC current location based on schedule
- `trigger_quest(quest_id: String)` - Trigger quest from dialogue

### Dependencies:
- Depends on: S21 (Alignment for dialogue branches), S03 (Player), S04 (Combat)
- Depended on by: S23 (Story uses NPCs)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_npc.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] Dialogue Manager plugin installed and enabled
- [ ] NPC dialogue trees work (elder.dialogue loads)
- [ ] Alignment affects dialogue options (check branches)
- [ ] Relationship meter increases/decreases (0-100 range)
- [ ] Quest triggers from dialogue choices
- [ ] NPC schedule moves NPC correctly (time-based)
- [ ] State persistence (dialogue doesn't repeat inappropriately)
- [ ] Integration with S21 Alignment works (dialogue branches)
- [ ] Integration with S06 Save/Load ready (state can be saved)
- [ ] npc_config.json loads correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Dialogue Manager Plugin**: Must be installed before testing NPCs
- **Relationship Scale**: 0-100 (stranger to best friend)
- **Schedule System**: Time-based location changes (06:00, 08:00, 18:00, etc.)
- **Alignment Branches**: Use [if player.alignment > 50] syntax in .dialogue files
- **State Persistence**: Track dialogue flags to prevent repeating one-time dialogues

---

**Next Steps:** MCP agent should install plugin, execute all commands above, then update COORDINATION-DASHBOARD.md to mark S22 complete and unblock S23.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S22.md, verify:

### Code Quality
- [ ] npc_base.gd created with complete implementation (no TODOs or placeholders)
- [ ] npc_config.json created with valid JSON (no syntax errors)
- [ ] elder.dialogue created with valid Dialogue Manager syntax
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Relationship system implemented (0-100 scale)
- [ ] Dialogue state tracking implemented
- [ ] NPC schedule system implemented
- [ ] Integration with S21 Alignment documented
- [ ] Dialogue Manager plugin integration documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (npcs/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S22.md created with all required sections including plugin installation
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All NPC data configurable from npc_config.json
- [ ] No hardcoded NPC data in npc_base.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included
- [ ] Dialogue Manager plugin installation steps clear

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] Dialogue Manager plugin installed and enabled
- [ ] test_npc.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] npc_base.gd attached using `attach_script`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S22")`
- [ ] Quality gates passed: `check_quality_gates("S22")`
- [ ] Checkpoint validated: `validate_checkpoint("S22")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Dialogue Manager plugin loaded successfully
- [ ] NPC dialogue trees work (elder.dialogue loads)
- [ ] Alignment affects dialogue options (branches work)
- [ ] Relationship meter increases/decreases (0-100 range)
- [ ] Quest triggers from dialogue choices
- [ ] NPC schedule moves NPC correctly (time-based)
- [ ] State persistence works (dialogue doesn't repeat inappropriately)
- [ ] Integration with S21 Alignment works (dialogue branches)
- [ ] Integration with S06 Save/Load ready (state can be saved)
- [ ] npc_config.json loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ npc_base.gd complete with relationship tracking, dialogue state, schedules
- ✅ npc_config.json complete with all NPC configuration data
- ✅ elder.dialogue complete with alignment-based dialogue branches
- ✅ Dialogue Manager plugin integration documented
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S22.md provides clear MCP agent instructions including plugin installation
- ✅ All NPC data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Dialogue Manager plugin installed and working
- ✅ Test scene configured correctly in Godot editor
- ✅ NPC dialogue trees work with conditional branches
- ✅ Relationship system tracks player interactions (0-100 scale)
- ✅ Alignment affects dialogue options (Authentic vs Algorithmic branches)
- ✅ Quest triggers work from dialogue choices
- ✅ NPC schedules move NPCs to correct locations by time
- ✅ Dialogue state persists (doesn't repeat one-time conversations)
- ✅ Integrates with S21 Alignment for dialogue branches
- ✅ Integrates with S06 Save/Load for state persistence
- ✅ System ready for S23 (Story system uses NPCs for narrative)

NPCs are the heart of the game's social system and story delivery.

</success_criteria>

<memory_checkpoint_format>
```
System S22 (NPC System) Complete

FILES:
- res://npcs/npc_base.gd
- res://npcs/dialogue/[npc_id].dialogue
- res://data/npc_config.json

DIALOGUE MANAGER: Installed and configured

RELATIONSHIP SYSTEM:
- Range: 0-100
- Thresholds: Stranger/Acquaintance/Friend/Close/Best

NPC SCHEDULES:
- Time-based location changes
- Activity states

ALIGNMENT INTEGRATION:
- Dialogue branches based on Resonance Alignment (S21)
- NPCs react to player alignment

STATUS: Ready for S23 (Story uses NPCs)
```
</memory_checkpoint_format>
