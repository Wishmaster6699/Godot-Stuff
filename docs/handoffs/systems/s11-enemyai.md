# HANDOFF: S11 - Enemy AI System

**Status:** Ready for MCP Agent (Tier 2)
**Created by:** Claude Code Web (Tier 1)
**System:** S11 - Enemy AI System
**Dependencies:** S04 (Combat/Combatant), S01 (Conductor), LimboAI plugin

---

## Overview

The Enemy AI System (S11) provides intelligent, rhythm-synced enemy behavior using LimboAI behavior trees. All enemies extend the `Combatant` base class (from S04) and use behavior trees for decision-making with states: Patrol, Chase, Attack, Retreat, and Stun.

---

## Files Created by Claude Code Web (Tier 1)

### Core GDScript Files

**Base Enemy Class:**
- `src/systems/s11-enemyai/enemy_base.gd` - Base enemy class extending Combatant with behavior tree integration, telegraph system, state management, and fallback AI

**Type-Specific Enemy Classes:**
- `src/systems/s11-enemyai/enemy_aggressive.gd` - Aggressive type (high damage, low retreat threshold)
- `src/systems/s11-enemyai/enemy_defensive.gd` - Defensive type (high defense, high retreat threshold)
- `src/systems/s11-enemyai/enemy_ranged.gd` - Ranged type (long attack range, keep distance)
- `src/systems/s11-enemyai/enemy_swarm.gd` - Swarm type (low HP, fast, calls allies)

**LimboAI Behavior Tree Tasks:**
- `src/systems/s11-enemyai/tasks/bt_check_player_detected.gd` - Condition: Check if player detected
- `src/systems/s11-enemyai/tasks/bt_check_in_attack_range.gd` - Condition: Check if in attack range
- `src/systems/s11-enemyai/tasks/bt_check_should_retreat.gd` - Condition: Check if should retreat
- `src/systems/s11-enemyai/tasks/bt_scan_for_player.gd` - Action: Scan for player in range
- `src/systems/s11-enemyai/tasks/bt_patrol_move.gd` - Action: Move to patrol waypoints
- `src/systems/s11-enemyai/tasks/bt_chase_player.gd` - Action: Chase the player
- `src/systems/s11-enemyai/tasks/bt_attack_player.gd` - Action: Attack with telegraph
- `src/systems/s11-enemyai/tasks/bt_retreat.gd` - Action: Retreat from player

### Data Files

- `src/systems/s11-enemyai/enemy_ai_config.json` - AI parameters, detection ranges, attack patterns, difficulty modifiers, enemy type configurations

---

## MCP Agent Tasks

### Prerequisites

**CRITICAL:** Before starting, verify the following:

1. ✅ S04 (Combat) is complete - Combatant class exists at `src/systems/s04-combat/combatant.gd`
2. ✅ S01 (Conductor) is complete - Conductor autoload exists at `src/systems/s01-conductor-rhythm-system/conductor.gd`
3. ✅ LimboAI plugin will be installed in this handoff

---

### Task 1: Install and Configure LimboAI Plugin

**Note:** LimboAI must be installed from the Godot Asset Library or GitHub.

#### Option A: Install from Asset Library (Recommended)

1. Open Godot editor
2. Click **AssetLib** tab at the top
3. Search for "LimboAI"
4. Download "LimboAI: Behavior Trees & State Machines (Godot 4.4+)"
5. Click **Install** and confirm
6. Enable plugin in **Project > Project Settings > Plugins > LimboAI** (check the box)
7. Restart Godot editor

#### Option B: Manual Installation from GitHub

```bash
# Clone LimboAI into addons directory
cd /home/user/vibe-code-game
mkdir -p addons
cd addons
git clone https://github.com/limbonaut/limboai.git limboai

# Enable plugin in project.godot
# Add this line to project.godot under [editor_plugins]:
# enabled=PackedStringArray("res://addons/limboai/plugin.cfg")
```

#### Verify Installation

Use GDAI tool to verify:

```bash
get_project_info
```

Check that LimboAI appears in enabled plugins list.

---

### Task 2: Create Base Enemy Scene

Create the base enemy scene that all enemy types will inherit from.

```bash
# Create base enemy scene
create_scene res://src/systems/s11-enemyai/enemy_base.tscn

# Add root node (CharacterBody2D)
add_node res://src/systems/s11-enemyai/enemy_base.tscn CharacterBody2D Enemy root

# Attach enemy_base.gd script
attach_script res://src/systems/s11-enemyai/enemy_base.tscn Enemy res://src/systems/s11-enemyai/enemy_base.gd

# Add visual sprite (placeholder - will be replaced by art assets)
add_node res://src/systems/s11-enemyai/enemy_base.tscn Sprite2D EnemySprite Enemy
update_property res://src/systems/s11-enemyai/enemy_base.tscn EnemySprite self_modulate "Color(1, 0.3, 0.3, 1)"

# Add collision shape
add_node res://src/systems/s11-enemyai/enemy_base.tscn CollisionShape2D EnemyCollision Enemy

# Add detection zone (Area2D for player detection)
add_node res://src/systems/s11-enemyai/enemy_base.tscn Area2D DetectionZone Enemy
add_node res://src/systems/s11-enemyai/enemy_base.tscn CollisionShape2D DetectionShape DetectionZone

# Add attack range zone (Area2D for attack range)
add_node res://src/systems/s11-enemyai/enemy_base.tscn Area2D AttackRange Enemy
add_node res://src/systems/s11-enemyai/enemy_base.tscn CollisionShape2D AttackShape AttackRange

# Add LimboAI BTPlayer node
add_node res://src/systems/s11-enemyai/enemy_base.tscn BTPlayer BTPlayer Enemy

# Add telegraph visual effect (Sprite2D for red flash)
add_node res://src/systems/s11-enemyai/enemy_base.tscn Sprite2D TelegraphFlash Enemy

# Add AnimationPlayer for telegraph animations
add_node res://src/systems/s11-enemyai/enemy_base.tscn AnimationPlayer TelegraphAnim Enemy
```

#### Configure Enemy Base Properties

```bash
# Enemy physics (CharacterBody2D)
update_property res://src/systems/s11-enemyai/enemy_base.tscn Enemy motion_mode 0

# Enemy collision (16px radius circle)
update_property res://src/systems/s11-enemyai/enemy_base.tscn EnemyCollision shape.radius 16

# Enemy sprite (32x32 placeholder square)
# Note: Will use add_resource for texture in production
update_property res://src/systems/s11-enemyai/enemy_base.tscn EnemySprite texture null

# Detection zone (200px radius from config)
update_property res://src/systems/s11-enemyai/enemy_base.tscn DetectionShape shape.radius 200

# Attack range (64px from config)
update_property res://src/systems/s11-enemyai/enemy_base.tscn AttackShape shape.radius 64

# Telegraph flash (initially invisible)
update_property res://src/systems/s11-enemyai/enemy_base.tscn TelegraphFlash modulate "Color(1, 0, 0, 0)"
update_property res://src/systems/s11-enemyai/enemy_base.tscn TelegraphFlash visible false
update_property res://src/systems/s11-enemyai/enemy_base.tscn TelegraphFlash scale "Vector2(2, 2)"
```

---

### Task 3: Create Behavior Tree for Enemy AI

LimboAI behavior trees are created in the Godot editor using the BehaviorTree resource and BTPlayer node.

**Manual Steps (in Godot Editor):**

1. Open `enemy_base.tscn` in Godot editor
2. Select the `BTPlayer` node
3. In the Inspector, click the "Behavior Tree" property dropdown
4. Select "New BehaviorTree"
5. Click the new BehaviorTree resource to edit it
6. The LimboAI behavior tree editor will open at the bottom of the screen

**Behavior Tree Structure:**

Create this tree structure in the LimboAI editor:

```
BTSelector (Root)
├── BTSequence (Retreat Branch)
│   ├── BTCheckShouldRetreat (Condition)
│   └── BTRetreat (Action)
├── BTSequence (Attack Branch)
│   ├── BTCheckPlayerDetected (Condition)
│   ├── BTCheckInAttackRange (Condition)
│   └── BTAttackPlayer (Action)
├── BTSequence (Chase Branch)
│   ├── BTCheckPlayerDetected (Condition)
│   └── BTChasePlayer (Action)
└── BTSequence (Patrol Branch - Default)
    ├── BTScanForPlayer (Action)
    └── BTPatrolMove (Action)
```

**Instructions for Creating Tree:**

1. Click "Add Task" button in behavior tree editor
2. Search for "BTSelector" and add it as root
3. Add child tasks by right-clicking on the BTSelector node
4. For each custom task (BTCheckPlayerDetected, etc.), you'll need to assign the script:
   - Right-click the task node
   - "Extend Script"
   - Navigate to `res://src/systems/s11-enemyai/tasks/bt_*.gd`
   - Select the appropriate script

**Blackboard Variables:**

In the BehaviorTree resource, set up these blackboard variables:

- `enemy` (Node) - Reference to enemy instance (set by enemy_base.gd)
- `target` (Node) - Current target (player)
- `detection_range` (Float) - 200.0
- `attack_range` (Float) - 64.0
- `retreat_hp_threshold` (Float) - 0.2

**Note:** These are initialized in `enemy_base.gd` in the `_initialize_blackboard()` method.

---

### Task 4: Create Enemy Type Scenes

Create inherited scenes for each enemy type.

#### Aggressive Enemy

```bash
# Create aggressive enemy scene (inherits from enemy_base.tscn)
create_scene res://src/systems/s11-enemyai/enemy_aggressive.tscn
# Note: Set this scene to inherit from enemy_base.tscn in Godot editor
# Scene > Change Root Type > Inherited Scene > Select enemy_base.tscn

# Attach aggressive script
attach_script res://src/systems/s11-enemyai/enemy_aggressive.tscn Enemy res://src/systems/s11-enemyai/enemy_aggressive.gd

# Customize appearance (reddish tint)
update_property res://src/systems/s11-enemyai/enemy_aggressive.tscn EnemySprite self_modulate "Color(1, 0.5, 0.5, 1)"
```

#### Defensive Enemy

```bash
# Create defensive enemy scene
create_scene res://src/systems/s11-enemyai/enemy_defensive.tscn
# Inherit from enemy_base.tscn (manual step in editor)

# Attach defensive script
attach_script res://src/systems/s11-enemyai/enemy_defensive.tscn Enemy res://src/systems/s11-enemyai/enemy_defensive.gd

# Customize appearance (bluish tint)
update_property res://src/systems/s11-enemyai/enemy_defensive.tscn EnemySprite self_modulate "Color(0.5, 0.5, 1, 1)"
```

#### Ranged Enemy

```bash
# Create ranged enemy scene
create_scene res://src/systems/s11-enemyai/enemy_ranged.tscn
# Inherit from enemy_base.tscn (manual step in editor)

# Attach ranged script
attach_script res://src/systems/s11-enemyai/enemy_ranged.tscn Enemy res://src/systems/s11-enemyai/enemy_ranged.gd

# Customize appearance (greenish tint)
update_property res://src/systems/s11-enemyai/enemy_ranged.tscn EnemySprite self_modulate "Color(0.5, 1, 0.5, 1)"
```

#### Swarm Enemy

```bash
# Create swarm enemy scene
create_scene res://src/systems/s11-enemyai/enemy_swarm.tscn
# Inherit from enemy_base.tscn (manual step in editor)

# Attach swarm script
attach_script res://src/systems/s11-enemyai/enemy_swarm.tscn Enemy res://src/systems/s11-enemyai/enemy_swarm.gd

# Customize appearance (yellowish tint, smaller scale)
update_property res://src/systems/s11-enemyai/enemy_swarm.tscn EnemySprite self_modulate "Color(1, 1, 0.5, 1)"
update_property res://src/systems/s11-enemyai/enemy_swarm.tscn Enemy scale "Vector2(0.8, 0.8)"
```

---

### Task 5: Create Test Scene for Enemy AI

Create a comprehensive test scene to verify all enemy AI functionality.

```bash
# Create test scene
create_scene res://scenes/s11-enemyai/test_enemy_ai.tscn

# Add root node
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Node2D TestEnemyAI root

# Add TileMap for arena
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn TileMap Arena TestEnemyAI
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Arena position "Vector2(0, 0)"

# Add player (simple placeholder - actual player from S03)
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn CharacterBody2D Player TestEnemyAI
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Sprite2D PlayerSprite Player
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn CollisionShape2D PlayerCollision Player
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Player position "Vector2(200, 300)"
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn PlayerSprite self_modulate "Color(0.3, 0.8, 1, 1)"
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn PlayerCollision shape.radius 16

# Add enemy group label to player
# Manual step: In Godot editor, select Player node > Node tab > Groups > Add to group "player"

# Add enemies of different types
add_scene res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy1 TestEnemyAI res://src/systems/s11-enemyai/enemy_aggressive.tscn
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy1 position "Vector2(400, 300)"

add_scene res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy2 TestEnemyAI res://src/systems/s11-enemyai/enemy_defensive.tscn
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy2 position "Vector2(600, 200)"

add_scene res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy3 TestEnemyAI res://src/systems/s11-enemyai/enemy_ranged.tscn
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy3 position "Vector2(600, 400)"

add_scene res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy4 TestEnemyAI res://src/systems/s11-enemyai/enemy_swarm.tscn
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy4 position "Vector2(500, 150)"

add_scene res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy5 TestEnemyAI res://src/systems/s11-enemyai/enemy_swarm.tscn
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy5 position "Vector2(550, 150)"

# Add enemy group label to all enemies
# Manual step: In Godot editor, select each Enemy node > Node tab > Groups > Add to group "enemy"

# Add UI layer for testing
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn CanvasLayer UI TestEnemyAI

# Add instructions label
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Label Instructions UI
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Instructions text "Test Enemy AI: Move player with WASD. Watch enemy states change. Press Space to attack."
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Instructions position "Vector2(10, 10)"

# Add AI state display
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn VBoxContainer AIStateDisplay UI
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn AIStateDisplay position "Vector2(10, 50)"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Label Enemy1State AIStateDisplay
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy1State text "Enemy 1 (Aggressive): Patrol"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Label Enemy2State AIStateDisplay
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy2State text "Enemy 2 (Defensive): Patrol"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Label Enemy3State AIStateDisplay
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy3State text "Enemy 3 (Ranged): Patrol"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Label Enemy4State AIStateDisplay
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy4State text "Enemy 4 (Swarm): Patrol"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Label Enemy5State AIStateDisplay
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn Enemy5State text "Enemy 5 (Swarm): Patrol"

# Add difficulty selector
add_node res://scenes/s11-enemyai/test_enemy_ai.tscn HBoxContainer DifficultyButtons UI
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn DifficultyButtons position "Vector2(10, 200)"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Button NormalButton DifficultyButtons
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn NormalButton text "Normal"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Button HardButton DifficultyButtons
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn HardButton text "Hard"

add_node res://scenes/s11-enemyai/test_enemy_ai.tscn Button ExpertButton DifficultyButtons
update_property res://scenes/s11-enemyai/test_enemy_ai.tscn ExpertButton text "Expert"
```

---

### Task 6: Create Test Controller Script

Create a simple test controller script to move the player and display enemy states.

**Manual Step (Create via Godot Editor):**

1. Create new script: `res://scenes/s11-enemyai/test_controller.gd`
2. Attach to `TestEnemyAI` root node
3. Add this code:

```gdscript
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var enemy1: Node = $Enemy1
@onready var enemy2: Node = $Enemy2
@onready var enemy3: Node = $Enemy3
@onready var enemy4: Node = $Enemy4
@onready var enemy5: Node = $Enemy5

@onready var enemy1_label: Label = $UI/AIStateDisplay/Enemy1State
@onready var enemy2_label: Label = $UI/AIStateDisplay/Enemy2State
@onready var enemy3_label: Label = $UI/AIStateDisplay/Enemy3State
@onready var enemy4_label: Label = $UI/AIStateDisplay/Enemy4State
@onready var enemy5_label: Label = $UI/AIStateDisplay/Enemy5State

var player_speed: float = 150.0

func _ready() -> void:
	# Connect difficulty buttons
	$UI/DifficultyButtons/NormalButton.pressed.connect(_on_difficulty_changed.bind("normal"))
	$UI/DifficultyButtons/HardButton.pressed.connect(_on_difficulty_changed.bind("hard"))
	$UI/DifficultyButtons/ExpertButton.pressed.connect(_on_difficulty_changed.bind("expert"))

func _physics_process(delta: float) -> void:
	# Simple player movement for testing
	var direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	direction = direction.normalized()
	player.velocity = direction * player_speed
	player.move_and_slide()

	# Update enemy state labels
	_update_state_labels()

func _update_state_labels() -> void:
	if enemy1:
		var state: String = enemy1.get("current_state")
		enemy1_label.text = "Enemy 1 (Aggressive): " + _get_state_name(state)

	if enemy2:
		var state: String = enemy2.get("current_state")
		enemy2_label.text = "Enemy 2 (Defensive): " + _get_state_name(state)

	if enemy3:
		var state: String = enemy3.get("current_state")
		enemy3_label.text = "Enemy 3 (Ranged): " + _get_state_name(state)

	if enemy4:
		var state: String = enemy4.get("current_state")
		enemy4_label.text = "Enemy 4 (Swarm): " + _get_state_name(state)

	if enemy5:
		var state: String = enemy5.get("current_state")
		enemy5_label.text = "Enemy 5 (Swarm): " + _get_state_name(state)

func _get_state_name(state: Variant) -> String:
	if typeof(state) == TYPE_INT:
		match state:
			0: return "Patrol"
			1: return "Chase"
			2: return "Attack"
			3: return "Retreat"
			4: return "Stun"
	return "Unknown"

func _on_difficulty_changed(difficulty: String) -> void:
	# Apply difficulty to all enemies
	for enemy in [enemy1, enemy2, enemy3, enemy4, enemy5]:
		if enemy and enemy.has_method("set"):
			enemy.set("difficulty", difficulty)
			if enemy.has_method("_apply_difficulty_modifiers"):
				enemy._apply_difficulty_modifiers()

	print("Difficulty changed to: ", difficulty)
```

---

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://scenes/s11-enemyai/test_enemy_ai.tscn

# Check for errors
get_godot_errors
```

### Verify the Following:

#### Plugin Installation
- [ ] LimboAI plugin installed and enabled in Project Settings
- [ ] BTPlayer node available in Add Node dialog
- [ ] BehaviorTree resource type available

#### Scene Structure
- [ ] `enemy_base.tscn` created with all required nodes
- [ ] BTPlayer node attached to enemy
- [ ] All enemy type scenes (aggressive, defensive, ranged, swarm) created
- [ ] Test scene created with multiple enemy types

#### Behavior Tree
- [ ] Behavior tree created in BTPlayer
- [ ] All custom task scripts attached to tree nodes
- [ ] Blackboard variables configured
- [ ] Tree structure matches specification (Selector > Sequences > Tasks)

#### AI States
- [ ] **Patrol**: Enemies wander around spawn point when no player detected
- [ ] **Chase**: Enemies follow player when detected (within detection range)
- [ ] **Attack**: Enemies attack when in range (64px for most types)
- [ ] **Retreat**: Enemies retreat when HP < 20%
- [ ] **Stun**: Enemies stop moving when stunned (test with status effect)

#### Telegraph System
- [ ] Red flash appears 1 beat before attack
- [ ] Telegraph syncs with Conductor beat (if S01 available)
- [ ] Telegraph visible indicator pulsates
- [ ] Attack executes after telegraph completes

#### Enemy Types
- [ ] **Aggressive**: Fast chase, low retreat threshold (10% HP)
- [ ] **Defensive**: High retreat threshold (40% HP), increased defense
- [ ] **Ranged**: Long attack range (150px), long detection (250px)
- [ ] **Swarm**: Fast movement, calls nearby allies when damaged

#### Difficulty Scaling
- [ ] **Normal**: 0.5s reaction time, 70% accuracy
- [ ] **Hard**: 0.3s reaction time, 90% accuracy
- [ ] **Expert**: 0.1s reaction time, 100% accuracy
- [ ] Difficulty buttons in test scene change enemy behavior

#### Integration
- [ ] Enemies extend Combatant (S04) correctly
- [ ] Combat methods work (take_damage, attack_target)
- [ ] Conductor integration for telegraph timing (if S01 active)
- [ ] Enemy group set for all enemies
- [ ] Player group set for player

#### No Errors
- [ ] No errors in console when running test scene
- [ ] No script errors or missing method warnings
- [ ] Behavior tree executes without errors
- [ ] All GDScript files parse correctly

---

## Integration Points

### With S04 (Combat System)
- **Enemy extends Combatant**: All combat functionality (HP, stats, damage calculation) inherited
- **Attack execution**: Enemies use `attack_target()` method from Combatant
- **Status effects**: Stun state triggered by "stun" status effect

### With S01 (Conductor/Rhythm System)
- **Telegraph timing**: Telegraph duration calculated from beat duration
- **Attack timing**: Attacks can be synced to rhythm beats
- **Visual feedback**: Telegraph pulses in sync with beat

### With S12 (Monster Database) - Future
- **Enemy data**: Monster stats loaded from database
- **Type assignment**: Behavior types assigned to specific monsters
- **Spawning**: Enemies instantiated from database entries

---

## Known Limitations & Future Work

### Current Limitations
1. **No Projectiles**: Ranged enemies currently use same attack as melee (projectiles in future system)
2. **Simple Patrol**: Patrol is random wandering (could be improved with waypoint paths)
3. **Placeholder Art**: Using colored squares instead of sprites
4. **No Audio**: Telegraph audio cues not implemented yet

### Future Enhancements (Not in S11 Scope)
- Projectile system for ranged enemies (S13 or later)
- Advanced pathfinding with Navigation2D
- Formation behavior for swarms
- Boss-specific behavior trees
- Dynamic difficulty adjustment
- Alert states (hearing sounds, investigating)

---

## Completion Criteria

### Tier 2 (MCP Agent) Success

✅ **Mark S11 complete when ALL of the following are verified:**

1. LimboAI plugin installed and functional
2. All enemy scenes created and configured
3. Behavior tree created with all custom tasks
4. Test scene runs without errors
5. All AI states work correctly (Patrol, Chase, Attack, Retreat, Stun)
6. Telegraph system shows 1-beat warning before attacks
7. All enemy types have distinct behaviors
8. Difficulty scaling works as expected
9. Integration with S04 (Combat) verified
10. No console errors when running test

### Post-Completion Actions

After verification:

1. **Update COORDINATION-DASHBOARD.md**:
   - Mark S11 as "Complete"
   - Unblock S12 (Monster Database)
   - Release any resource locks

2. **Document Issues**:
   - Add any discovered issues to `KNOWN-ISSUES.md`
   - Document solutions in `knowledge-base/` if non-trivial

3. **Create Checkpoint**:
   - Document final state in `checkpoints/s11-enemyai-checkpoint.md`

---

## Support & Troubleshooting

### Common Issues

**Issue:** BTPlayer doesn't recognize custom task scripts
**Solution:** Ensure all task scripts extend correct LimboAI base class (BTAction or BTCondition) and have `class_name` declaration

**Issue:** Behavior tree doesn't execute
**Solution:** Check that BTPlayer has a valid BehaviorTree resource assigned and blackboard variables are initialized

**Issue:** Enemies don't detect player
**Solution:** Ensure player node is in "player" group (Node tab > Groups > "player")

**Issue:** Telegraph doesn't show
**Solution:** Verify TelegraphFlash node exists and is child of Enemy node with correct name

**Issue:** LimboAI plugin not found
**Solution:** Install from Asset Library (search "LimboAI") or manually clone from GitHub to `addons/limboai/`

### Debug Commands

```bash
# Check for script errors
get_godot_errors

# View scene tree
get_scene_tree

# Check project settings
get_project_info

# Take screenshot of editor
get_editor_screenshot

# Take screenshot of running game
get_running_scene_screenshot
```

---

## Handoff Complete

**Created by:** Claude Code Web (Tier 1)
**Timestamp:** 2025-11-18
**Status:** Ready for MCP Agent execution

All code files are complete and validated. The MCP agent should now execute the tasks above to configure scenes, behavior trees, and verify functionality in the Godot editor.

**Next System:** S12 (Monster Database) - depends on S11 completion
