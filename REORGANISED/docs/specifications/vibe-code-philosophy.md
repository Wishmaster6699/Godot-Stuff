# Vibe Code Philosophy: LLM Development Handbook

**Created:** 2025-11-18
**Version:** 1.0
**Project:** Rhythm RPG (Godot 4.5.1)
**Purpose:** Foundation principles for all LLM agents working on this project

---

## Table of Contents

1. [Web Search First Principle](#1-web-search-first-principle)
2. [Godot MCP Primary](#2-godot-mcp-primary)
3. [Token Efficiency](#3-token-efficiency)
4. [Memory Checkpoints](#4-memory-checkpoints)
5. [Data-Driven Development](#5-data-driven-development)
6. [Testing Protocol](#6-testing-protocol)

---

## 1. Web Search First Principle

### The Core Rule

**NEVER begin implementation based solely on cached knowledge from your training data.**

Every system implementation MUST start with current web research. This is non-negotiable for three critical reasons:

1. **API Evolution:** Godot 4.5 introduces breaking changes from Godot 3.x and even Godot 4.0-4.4
2. **Best Practices Shift:** Community patterns evolve; 2025 best practices differ from 2023
3. **MCP Tool Updates:** GDAI MCP tools may have new features or syntax changes

### When to Search

**Always search before:**
- Implementing any of the 26 game systems
- Writing GDScript code for a new feature
- Creating scene structures you haven't built in this session
- Using Godot nodes you're not 100% certain about
- Implementing performance-critical systems

**Example search queries:**

```
Good queries (specific, dated, version-aware):
✅ "Godot 4.5 CharacterBody2D best practices 2025"
✅ "Godot 4.5 AnimationPlayer GDScript control examples"
✅ "Godot 4.5 JSON data loading performance 2025"
✅ "Godot 4.5 Area2D collision detection tutorial"

Bad queries (vague, undated, version-agnostic):
❌ "Godot player movement"
❌ "how to use AnimationPlayer"
❌ "JSON in Godot"
❌ "collision detection tutorial"
```

### Research Integration Workflow

```xml
<research_workflow>
  <step id="1">Web search for "[System Name] Godot 4.5 2025"</step>
  <step id="2">Read official docs.godotengine.org/en/4.5/ documentation</step>
  <step id="3">Identify 2-3 key patterns/best practices</step>
  <step id="4">Document findings in brief notes (not full text copy)</step>
  <step id="5">Reference URLs in memory checkpoint, not content</step>
  <step id="6">Proceed to MCP implementation phase</step>
</research_workflow>
```

### Good vs Bad Research Approaches

**Good Research Example:**

```
Task: Implement S01 Player Movement system

Search: "Godot 4.5 CharacterBody2D input handling 2025"
Find: docs.godotengine.org/en/4.5/tutorials/physics/using_character_body_2d.html

Key takeaways noted:
- Use move_and_slide() for physics-based movement
- Input.get_vector() for 8-directional input
- Apply velocity *= friction for deceleration
- Handle is_on_floor() for jump logic

URLs saved: [doc link]
Proceed to: MCP create_script command
```

**Bad Research Example:**

```
Task: Implement S01 Player Movement system

Assume: "I know CharacterBody2D from training data"
Skip: Web search entirely
Result: Use deprecated Godot 3.x KinematicBody2D patterns
Outcome: Code fails, wasted tokens, requires rework
```

### Integration with Memory

After research, save to memory checkpoint:

```
RESEARCH_FINDINGS:
- System: S01 Player Movement
- Sources: [URL1], [URL2]
- Key Patterns: move_and_slide(), Input.get_vector()
- Godot Version: 4.5.1 confirmed compatible
- Date Researched: 2025-11-18
```

**Do NOT copy entire documentation into memory.** Reference URLs and summarize key patterns only.

---

## 2. Godot MCP Primary

### The Paradigm Shift

**MCP is not a fallback tool. MCP is the PRIMARY development method.**

Traditional workflow (WRONG):
```
Think → Write code manually → Test → Debug
```

Vibe Code workflow (CORRECT):
```
Research → MCP command → Verify → Checkpoint
```

### Why MCP First?

1. **Accuracy:** MCP generates syntactically correct .tscn files (manual editing is error-prone)
2. **Speed:** Create entire scene hierarchies in one command vs manual node-by-node
3. **Integration:** MCP commands update Godot editor in real-time, ensuring sync
4. **Verification:** Immediate feedback from Godot engine on errors

### MCP Operations by Task Type

**File Creation:**
- GDScript: Use `create_script(file_path, content)`
- Scene: Use `create_scene(scene_path, root_node_type)`
- JSON: Use standard file creation (JSON is data, not Godot-specific)

**Scene Setup:**
- Add nodes: Use `add_node(parent_path, node_type, node_name)`
- Attach scripts: Use `attach_script(node_path, script_path)`
- Set properties: Use `update_property(node_path, property_name, value)`
- Configure Control nodes: Use `set_anchor_preset(node_path, preset)`

**Testing:**
- Run scene: Use `play_scene(scene_path)` or `play_scene()` for current
- Check errors: Use `get_godot_errors()`
- Stop execution: Use `stop_running_scene()`
- Visual verification: Use `get_running_scene_screenshot()`

**Debugging:**
- View scene structure: Use `get_scene_tree()`
- Inspect files: Use `get_filesystem_tree(filter)`
- Read scene data: Use `get_scene_file_content(scene_path)`

### Workflow: Research → MCP → Verify → Checkpoint

**Complete Example (S08 UI Health Bar):**

```xml
<workflow_example system="S08_UI_HealthBar">

  <phase name="research">
    Search: "Godot 4.5 ProgressBar health UI 2025"
    Result: Use ProgressBar node, set max_value, update value property
    Pattern: TextureProgressBar for custom visuals
  </phase>

  <phase name="mcp_implementation">
    <!-- Create the UI scene -->
    MCP: create_scene("res://scenes/ui/health_bar.tscn", "Control")

    <!-- Add ProgressBar node -->
    MCP: add_node(".", "ProgressBar", "HealthBar")

    <!-- Configure ProgressBar -->
    MCP: update_property("HealthBar", "max_value", 100)
    MCP: update_property("HealthBar", "value", 100)
    MCP: update_property("HealthBar", "size", Vector2(200, 20))

    <!-- Create and attach script -->
    MCP: create_script("res://scripts/ui/health_bar.gd", [script_content])
    MCP: attach_script("HealthBar", "res://scripts/ui/health_bar.gd")
  </phase>

  <phase name="verify">
    MCP: get_scene_tree()
    Verify: HealthBar node exists with correct properties

    MCP: play_scene("res://scenes/ui/health_bar.tscn")
    MCP: get_godot_errors()
    Verify: No errors in output

    MCP: stop_running_scene()
  </phase>

  <phase name="checkpoint">
    Save to memory: "S08 complete - health_bar.tscn created with ProgressBar node, script attached, tested successfully"
  </phase>

</workflow_example>
```

### Error Handling: When MCP Fails

**If MCP command returns an error:**

1. **First:** Read the error message carefully
2. **Second:** Web search for the specific error (e.g., "Godot MCP add_node invalid parent path")
3. **Third:** Try alternative MCP approach (e.g., use absolute vs relative paths)
4. **Fourth:** Check GDAI MCP documentation for correct syntax
5. **Last Resort:** Manual file editing (then verify with MCP tools)

**Never assume manual editing is faster.** MCP errors usually indicate syntax mistakes, not tool limitations.

---

## 3. Token Efficiency

### The Economics of Development

You have a finite token budget. Every token spent on:
- Repeating documentation = wasted
- Verbose explanations = wasted
- Copying large code blocks = wasted

Every token spent on:
- Concise implementation steps = valuable
- URL references = valuable
- JSON templates = valuable
- Reusable patterns = valuable

### Strategy 1: JSON Over Prose

**Wasteful approach (500+ tokens):**

```
The enemy configuration system should include the following properties:
- Enemy name (a string representing the enemy type)
- Health points (an integer for total HP)
- Attack damage (an integer for damage dealt)
- Movement speed (a float for pixels per second)
...
[15 more lines of prose]
```

**Efficient approach (100 tokens):**

```json
{
  "enemy_template": {
    "name": "string",
    "hp": "int",
    "attack": "int",
    "speed": "float",
    "sprite_path": "string",
    "abilities": ["array"]
  }
}
```

**Token savings: 80%**

### Strategy 2: Reference URLs, Don't Copy

**Wasteful:**
```
[Paste 2000 words of Godot documentation about CharacterBody2D]
```

**Efficient:**
```
Reference: https://docs.godotengine.org/en/4.5/tutorials/physics/using_character_body_2d.html
Key takeaway: Use move_and_slide() for collision handling
```

**Token savings: 95%**

### Strategy 3: Concise Implementation Steps

**Wasteful (verbose):**
```
Step 1: First, you need to create a new scene file. This scene will contain the player character. To do this, you should use the MCP create_scene command with the appropriate parameters...
[10 lines per step]
```

**Efficient (directive):**
```
1. create_scene("res://scenes/player.tscn", "CharacterBody2D")
2. add_node(".", "Sprite2D", "PlayerSprite")
3. add_node(".", "CollisionShape2D", "Collision")
4. create_script("res://scripts/player.gd", [content])
5. attach_script(".", "res://scripts/player.gd")
```

**Token savings: 85%**

### Strategy 4: Maximum 10 Steps Per System

Each of the 26 game systems should be implementable in ≤10 clear steps. If you're writing more:
- You're being too verbose
- You're not using MCP effectively
- You're micro-managing instead of commanding

**Good system implementation (7 steps):**
```
S01 Player Movement:
1. Research CharacterBody2D patterns
2. Create player scene with CharacterBody2D root
3. Add Sprite2D + CollisionShape2D children
4. Create movement script with Input.get_vector()
5. Attach script to player
6. Test in test scene
7. Checkpoint completion
```

**Bad system implementation (20+ steps):**
```
S01 Player Movement:
1. Think about what player movement means
2. Consider different movement approaches
3. Research multiple tutorials
4. Summarize each tutorial
5. Decide on approach
6. Plan file structure
...
[14 more micro-steps]
```

### Expected Output Quality Per Token

**100 tokens:** One clear command with parameters
**500 tokens:** Complete system implementation steps
**1000 tokens:** System implementation + testing + checkpoint
**2000+ tokens:** Only for complex multi-system integration

If you're using 2000+ tokens for a single system, you're doing it wrong.

---

## 4. Memory Checkpoints

### Why Checkpoint?

1. **Continuity:** Future LLMs pick up where you left off
2. **Conflict Prevention:** Parallel agents know what's claimed/complete
3. **Pattern Sharing:** Discoveries benefit all agents
4. **Recovery:** Rollback capability if integration fails

### Standard Checkpoint Format

```xml
<checkpoint id="system_[NN]_[name]" date="YYYY-MM-DD">

  <system>
    <id>S[NN]</id>
    <name>[System Name]</name>
    <status>complete|in_progress|blocked</status>
  </system>

  <files_created>
    <file path="res://..." type="script|scene|data">Purpose of file</file>
    <file path="res://..." type="script|scene|data">Purpose of file</file>
  </files_created>

  <key_decisions>
    <decision>Why we chose approach X over Y</decision>
    <decision>Integration pattern discovered for Z</decision>
  </key_decisions>

  <integration_patterns>
    <pattern>How this system connects to S[other]</pattern>
    <pattern>Shared data structure: [description]</pattern>
  </integration_patterns>

  <dependencies>
    <depends_on>S[NN] - [reason]</depends_on>
    <blocks>S[NN] - [reason why blocked]</blocks>
  </dependencies>

  <testing_results>
    <test name="[test_name]" status="pass|fail">Details</test>
  </testing_results>

  <next_steps>
    <step>What future LLM should do next</step>
  </next_steps>

</checkpoint>
```

### Checkpoint Timing

**Checkpoint AFTER:**
- ✅ System implementation complete
- ✅ Tests pass successfully
- ✅ Files created and verified

**DON'T checkpoint BEFORE:**
- ❌ Tests passing
- ❌ Verifying files exist
- ❌ Integration confirmed

### Preventing Parallel Agent Conflicts

**Before starting work, query memory:**
```
Query: "system S[NN] status"
Check: Is this system claimed by another agent?
Check: Is this system blocked by dependencies?
```

**When claiming work, checkpoint immediately:**
```xml
<checkpoint id="system_05_inventory_manager" date="2025-11-18">
  <system>
    <id>S05</id>
    <name>Inventory Manager</name>
    <status>in_progress</status>
  </system>
  <claimed_by>Agent Session [ID]</claimed_by>
  <claimed_at>2025-11-18T14:30:00Z</claimed_at>
</checkpoint>
```

### What to Include vs Exclude

**INCLUDE:**
- File paths created
- Key integration patterns discovered
- Decisions made and why
- Test results (pass/fail)
- Blockers encountered
- Workarounds found

**EXCLUDE:**
- Full script contents (reference file paths instead)
- Complete documentation (reference URLs)
- Verbose explanations (concise notes only)
- Duplicate information (if it's in code, don't repeat in checkpoint)

### Checkpoint Naming Convention

```
Format: system_[NN]_[snake_case_name]

Examples:
✅ system_01_player_movement
✅ system_08_ui_health_bar
✅ system_15_enemy_spawner
✅ system_23_save_load_manager

❌ player_movement (missing system number)
❌ System01 (wrong format)
❌ s01-player-movement (use underscores, not hyphens)
```

### Querying Prior Work

**Future LLMs should query like this:**

```
Query: "system_01 integration patterns"
Goal: Understand how player movement connects to other systems

Query: "enemy spawner JSON structure"
Goal: Learn data format for creating new enemies

Query: "systems blocked status"
Goal: Find out which systems are waiting on dependencies
```

---

## 5. Data-Driven Development

### The Philosophy

**ZERO hardcoded game data in scripts.**

All game content (enemies, items, levels, abilities, dialogue) lives in JSON files. Scripts are logic engines that consume data.

### Why Data-Driven?

1. **Extensibility:** Add 100 enemies by editing JSON, not code
2. **Iteration:** Game designers can balance without touching GDScript
3. **Modularity:** Same script powers different content
4. **Debugging:** Easier to find "why enemy X has wrong HP" in JSON than code
5. **Collaboration:** Artists/designers work in JSON, programmers in GDScript

### The Template Approach

**Create one, extend to thousands:**

```json
// res://data/enemies/template.json
{
  "enemy_id": "goblin_warrior",
  "display_name": "Goblin Warrior",
  "stats": {
    "hp": 50,
    "attack": 12,
    "defense": 8,
    "speed": 100
  },
  "sprite": "res://assets/sprites/enemies/goblin_warrior.png",
  "abilities": ["melee_attack", "dodge"],
  "loot_table": {
    "gold": [10, 25],
    "items": [
      {"item_id": "rusty_sword", "chance": 0.15}
    ]
  },
  "ai_behavior": "aggressive"
}
```

**Now create variations:**

```json
// goblin_archer.json (copy template, change values)
{
  "enemy_id": "goblin_archer",
  "stats": { "hp": 35, "attack": 18, "defense": 5, "speed": 120 },
  "abilities": ["ranged_attack", "dodge"],
  ...
}

// orc_warrior.json
// dragon.json
// [98 more enemy types with zero code changes]
```

### Good vs Bad Data-Driven Design

**Bad (hardcoded):**

```gdscript
# enemies/goblin.gd
class_name Goblin extends Enemy

func _ready():
    hp = 50  # Hardcoded
    attack = 12  # Hardcoded
    sprite_path = "res://assets/goblin.png"  # Hardcoded
```

**Problem:** To create 10 enemy types, you write 10 scripts. To balance one enemy, you modify code.

**Good (data-driven):**

```gdscript
# enemies/enemy_base.gd
class_name EnemyBase extends CharacterBody2D

var enemy_data: Dictionary

func initialize(data_path: String) -> void:
    var file := FileAccess.open(data_path, FileAccess.READ)
    enemy_data = JSON.parse_string(file.get_as_text())

    hp = enemy_data.stats.hp
    attack = enemy_data.stats.attack
    $Sprite2D.texture = load(enemy_data.sprite)
```

**Benefit:** One script, infinite enemy types via JSON.

### Configuration Files, Not Constants

**Bad:**

```gdscript
# config/constants.gd
const PLAYER_SPEED = 200
const JUMP_FORCE = 500
const GRAVITY = 980
```

**Good:**

```json
// data/config/player_config.json
{
  "movement": {
    "speed": 200,
    "jump_force": 500,
    "gravity": 980
  }
}
```

```gdscript
# player.gd
var config: Dictionary

func _ready():
    var file := FileAccess.open("res://data/config/player_config.json", FileAccess.READ)
    config = JSON.parse_string(file.get_as_text())

    speed = config.movement.speed  # Now adjustable without code recompile
```

### Data Directory Structure

```
data/
├── config/
│   ├── player_config.json
│   ├── game_settings.json
│   └── balance_values.json
├── enemies/
│   ├── enemy_template.json
│   ├── goblin_warrior.json
│   ├── goblin_archer.json
│   └── [enemy_type].json
├── items/
│   ├── weapons.json
│   ├── armor.json
│   └── consumables.json
├── abilities/
│   └── ability_definitions.json
├── levels/
│   └── level_[NN].json
└── dialogue/
    └── npc_dialogue.json
```

### Loading Patterns

**Singleton manager approach:**

```gdscript
# autoload/data_manager.gd
extends Node

var enemies: Dictionary = {}
var items: Dictionary = {}

func _ready():
    _load_all_enemies()
    _load_all_items()

func _load_all_enemies() -> void:
    var dir := DirAccess.open("res://data/enemies/")
    for file in dir.get_files():
        if file.ends_with(".json"):
            var enemy_data = _load_json("res://data/enemies/" + file)
            enemies[enemy_data.enemy_id] = enemy_data

func get_enemy_data(enemy_id: String) -> Dictionary:
    return enemies.get(enemy_id, {})
```

**Usage:**

```gdscript
# enemy_spawner.gd
func spawn_enemy(enemy_id: String, position: Vector2) -> void:
    var enemy_scene = preload("res://scenes/enemies/enemy_base.tscn")
    var enemy_instance = enemy_scene.instantiate()

    var data = DataManager.get_enemy_data(enemy_id)
    enemy_instance.initialize(data)
    enemy_instance.position = position

    add_child(enemy_instance)
```

---

## 6. Testing Protocol

### The Rule

**Never assume it works. Always verify.**

Every system implementation MUST include:
1. Test scene creation
2. Test execution via MCP
3. Error checking
4. Results documentation

### Create Test Scene After Each System

**Format:**

```
System: S01 Player Movement
Test Scene: res://tests/test_s01_player_movement.tscn

Contents:
- Player character instance
- Test environment (ground platform)
- Debug labels showing velocity/state
- Instructions text node
```

**Why dedicated test scenes?**
- Isolated testing prevents breaking other systems
- Reproducible test conditions
- Easy to verify specific functionality
- Can be run by future LLMs to verify integration

### Run Tests Via Godot MCP

**NEVER just write code and move on.**

```xml
<test_workflow>

  <step id="1">Create test scene with MCP</step>

  <step id="2">
    MCP: play_scene("res://tests/test_s01_player_movement.tscn")
  </step>

  <step id="3">
    MCP: get_godot_errors()
    Check: Are there script errors? Parse errors? Runtime errors?
  </step>

  <step id="4">
    MCP: get_running_scene_screenshot()
    Verify: Visual confirmation that scene loaded correctly
  </step>

  <step id="5">
    MCP: stop_running_scene()
  </step>

  <step id="6">
    Document: Test results in checkpoint
  </step>

</test_workflow>
```

### What "Passing" Means

**A test passes when:**

✅ No script errors in Godot console
✅ Scene runs without crashes
✅ Expected behavior occurs (player moves, UI updates, etc.)
✅ No warning messages about missing resources
✅ Visual verification confirms correct appearance

**A test does NOT pass if:**

❌ "It probably works, I wrote the code correctly"
❌ "The script has no syntax errors" (runtime errors exist!)
❌ "I tested mentally by reading the code"
❌ "Similar code worked before"

### Document Test Results

**In checkpoint:**

```xml
<testing_results>

  <test name="s01_player_movement_basic" status="pass">
    Test scene: res://tests/test_s01_player_movement.tscn
    Verified: Player responds to WASD input, moves smoothly
    Verified: Collision detection works with ground
    Verified: No console errors
    Screenshot: [verified visually via MCP]
    Date: 2025-11-18
  </test>

  <test name="s01_player_jump" status="pass">
    Verified: Jump works with space bar
    Verified: Gravity applies correctly
    Verified: Can't double-jump (as designed)
  </test>

</testing_results>
```

### When to Checkpoint

**Checkpoint timing:**

```
❌ WRONG order:
1. Write code
2. Checkpoint "S01 complete"
3. Test

✅ CORRECT order:
1. Write code
2. Create test scene
3. Run tests via MCP
4. Verify all tests pass
5. Checkpoint "S01 complete - all tests passing"
```

**If tests fail:**
- Fix the issues
- Re-run tests
- Only checkpoint after tests pass

### Integration Testing

**After completing a system, test integration:**

```xml
<integration_test system="S05_Inventory">

  <test_case>
    Add item to inventory via S05
    Verify: UI updates via S08
    Result: Item appears in UI list
    Status: Pass
  </test_case>

  <test_case>
    Use item from inventory via S05
    Verify: Player stats update via S01
    Result: HP increases after consuming potion
    Status: Pass
  </test_case>

</integration_test>
```

### Testing Checklist

Before marking ANY system complete:

- [ ] Test scene created for this system
- [ ] Test scene run via `play_scene()`
- [ ] Errors checked via `get_godot_errors()`
- [ ] Visual verification via `get_running_scene_screenshot()`
- [ ] All expected behaviors confirmed
- [ ] Test results documented in checkpoint
- [ ] Integration points tested (if applicable)

**No exceptions. No assumptions. Test everything.**

---

## Summary: The Vibe Code Way

```xml
<workflow_summary>

  <principle id="1">
    Research first using web search for Godot 4.5 patterns
  </principle>

  <principle id="2">
    Use MCP as primary tool, not fallback
  </principle>

  <principle id="3">
    Maximize token efficiency: JSON > prose, URLs > copies
  </principle>

  <principle id="4">
    Checkpoint after every system with structured format
  </principle>

  <principle id="5">
    Design data-driven: JSON for content, GDScript for logic
  </principle>

  <principle id="6">
    Test via MCP before checkpointing completion
  </principle>

  <mantra>
    Research → MCP → Verify → Checkpoint
  </mantra>

</workflow_summary>
```

---

**Follow these six principles, and you will:**
- Build faster (MCP automation)
- Build better (research-driven patterns)
- Build smarter (data-driven extensibility)
- Build reliably (test-driven verification)
- Build collaboratively (checkpoint-driven coordination)

**This is the foundation. Everything else builds on this.**

---

**References:**
- GDAI MCP Documentation: https://gdaimcp.com/
- Basic Memory MCP: https://github.com/basicmachines-co/basic-memory
- Godot 4.5 Docs: https://docs.godotengine.org/en/4.5/
- Project Implementation Guide: rhythm-rpg-implementation-guide.md

**End of Document**
