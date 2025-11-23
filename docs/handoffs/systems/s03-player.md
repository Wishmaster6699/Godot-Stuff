# HANDOFF: S03 - Player Controller

**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** CharacterBody2D-based player character with smooth movement, state machine, interaction detection, and animation management. Foundation for all player-driven gameplay mechanics.

**Type:** Scene Component (player.tscn)

**Dependencies:** S02 (InputManager for movement and interaction input)

---

## Files Created by Tier 1

### GDScript Files
- ✅ `src/systems/s03-player/player_controller.gd` - Complete Player CharacterBody2D implementation
  - State machine (Idle, Walking, Running)
  - Smooth movement with acceleration/deceleration
  - Integration with InputManager (S02)
  - Interaction area detection and management
  - Animation state management
  - Facing direction tracking
  - Full signal system for state changes and interactions

### JSON Data Files
- ✅ `res/data/player_config.json` - Complete player configuration
  - Movement parameters (walk speed, run speed, acceleration, friction)
  - Interaction settings (detection radius)
  - Animation configurations (idle, walk, run, jump, fall, land)
  - Collision settings (hitbox size, layers, masks)
  - Visual settings (sprite scale, shadow, debug drawing)
  - Stats (health, stamina)
  - Camera settings

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | GDScript 4.5 compliant ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Create Player Scene

```bash
# Create player scene with CharacterBody2D root
create_scene res://scenes/s03-player/player.tscn CharacterBody2D

# Add sprite node
add_node res://scenes/s03-player/player.tscn AnimatedSprite2D Sprite root

# Add collision shape for player hitbox
add_node res://scenes/s03-player/player.tscn CollisionShape2D Collision root

# Add interaction area for detecting nearby objects
add_node res://scenes/s03-player/player.tscn Area2D InteractionArea root

# Add collision shape for interaction detection radius
add_node res://scenes/s03-player/player.tscn CollisionShape2D InteractionCollision InteractionArea

# Add camera (optional but recommended)
add_node res://scenes/s03-player/player.tscn Camera2D Camera root
```

### Step 2: Attach Player Script

```bash
# Attach the player controller script to the root node
attach_script res://scenes/s03-player/player.tscn root src/systems/s03-player/player_controller.gd
```

### Step 3: Configure Node Properties

```bash
# Configure root CharacterBody2D
update_property res://scenes/s03-player/player.tscn root motion_mode 0
# motion_mode 0 = MOTION_MODE_FLOATING (for top-down)
# Use motion_mode 1 (MOTION_MODE_GROUNDED) for platformer

update_property res://scenes/s03-player/player.tscn root collision_layer 1
update_property res://scenes/s03-player/player.tscn root collision_mask 1

# Configure Collision (player hitbox)
# Create a RectangleShape2D with size 32x48 (from player_config.json)
update_property res://scenes/s03-player/player.tscn Collision shape RectangleShape2D
# Note: You'll need to create the shape resource and set its size to Vector2(32, 48)

# Configure InteractionArea
update_property res://scenes/s03-player/player.tscn InteractionArea monitoring true
update_property res://scenes/s03-player/player.tscn InteractionArea monitorable false
update_property res://scenes/s03-player/player.tscn InteractionArea collision_layer 0
update_property res://scenes/s03-player/player.tscn InteractionArea collision_mask 2
# Mask 2 = detects layer 2 (interactables)

# Configure InteractionCollision (interaction detection radius)
# Create a CircleShape2D with radius 64 (from player_config.json)
update_property res://scenes/s03-player/player.tscn InteractionCollision shape CircleShape2D
# Note: You'll need to create the shape resource and set its radius to 64.0

# Configure Camera (if added)
update_property res://scenes/s03-player/player.tscn Camera enabled true
update_property res://scenes/s03-player/player.tscn Camera zoom Vector2(2.0, 2.0)
update_property res://scenes/s03-player/player.tscn Camera position_smoothing_enabled true
update_property res://scenes/s03-player/player.tscn Camera position_smoothing_speed 5.0

# Configure Sprite (placeholder until proper animations)
# Create a SpriteFrames resource with placeholder animations
# Note: Tier 2 agent should create placeholder colored rectangle animations
# - idle: Green square (32x48)
# - walk: Blue square (32x48)
# - run: Red square (32x48)
```

### Step 4: Create Test Movement Scene

```bash
# Create test scene
create_scene res://tests/test_movement.tscn Node2D

# Add player instance
add_node res://tests/test_movement.tscn Player TestPlayer root

# Add test floor/walls (StaticBody2D)
add_node res://tests/test_movement.tscn StaticBody2D Floor root
add_node res://tests/test_movement.tscn CollisionShape2D FloorCollision Floor
add_node res://tests/test_movement.tscn ColorRect FloorVisual Floor

add_node res://tests/test_movement.tscn StaticBody2D Wall1 root
add_node res://tests/test_movement.tscn CollisionShape2D Wall1Collision Wall1
add_node res://tests/test_movement.tscn ColorRect Wall1Visual Wall1

add_node res://tests/test_movement.tscn StaticBody2D Wall2 root
add_node res://tests/test_movement.tscn CollisionShape2D Wall2Collision Wall2
add_node res://tests/test_movement.tscn ColorRect Wall2Visual Wall2

# Add test interactables
add_node res://tests/test_movement.tscn Area2D DummyNPC root
add_node res://tests/test_movement.tscn CollisionShape2D NPCCollision DummyNPC
add_node res://tests/test_movement.tscn Sprite2D NPCSprite DummyNPC

add_node res://tests/test_movement.tscn Area2D DummyItem root
add_node res://tests/test_movement.tscn CollisionShape2D ItemCollision DummyItem
add_node res://tests/test_movement.tscn Sprite2D ItemSprite DummyItem

# Add UI for debugging
add_node res://tests/test_movement.tscn CanvasLayer UI root
add_node res://tests/test_movement.tscn Label StateLabel UI
add_node res://tests/test_movement.tscn Label VelocityLabel UI
add_node res://tests/test_movement.tscn Label InteractionLabel UI
add_node res://tests/test_movement.tscn Label PositionLabel UI
```

### Step 5: Configure Test Scene Properties

```bash
# Position player at center
update_property res://tests/test_movement.tscn TestPlayer position Vector2(400, 300)

# Configure floor (bottom of screen)
update_property res://tests/test_movement.tscn Floor position Vector2(400, 550)
update_property res://tests/test_movement.tscn FloorCollision shape RectangleShape2D
# FloorCollision shape size: Vector2(800, 50)
update_property res://tests/test_movement.tscn FloorVisual size Vector2(800, 50)
update_property res://tests/test_movement.tscn FloorVisual color Color(0.3, 0.3, 0.3)
update_property res://tests/test_movement.tscn FloorVisual position Vector2(-400, -25)

# Configure walls
update_property res://tests/test_movement.tscn Wall1 position Vector2(100, 300)
update_property res://tests/test_movement.tscn Wall1Collision shape RectangleShape2D
# Wall1Collision shape size: Vector2(50, 400)
update_property res://tests/test_movement.tscn Wall1Visual size Vector2(50, 400)
update_property res://tests/test_movement.tscn Wall1Visual color Color(0.5, 0.5, 0.5)
update_property res://tests/test_movement.tscn Wall1Visual position Vector2(-25, -200)

update_property res://tests/test_movement.tscn Wall2 position Vector2(700, 300)
update_property res://tests/test_movement.tscn Wall2Collision shape RectangleShape2D
# Wall2Collision shape size: Vector2(50, 400)
update_property res://tests/test_movement.tscn Wall2Visual size Vector2(50, 400)
update_property res://tests/test_movement.tscn Wall2Visual color Color(0.5, 0.5, 0.5)
update_property res://tests/test_movement.tscn Wall2Visual position Vector2(-25, -200)

# Configure dummy NPC (green)
update_property res://tests/test_movement.tscn DummyNPC position Vector2(400, 150)
update_property res://tests/test_movement.tscn DummyNPC collision_layer 2
update_property res://tests/test_movement.tscn DummyNPC collision_mask 0
update_property res://tests/test_movement.tscn NPCCollision shape CircleShape2D
# NPCCollision shape radius: 20.0
update_property res://tests/test_movement.tscn NPCSprite modulate Color(0, 1, 0)
# Note: Need to set NPCSprite texture to a 40x40 white square or similar

# Configure dummy item (yellow)
update_property res://tests/test_movement.tscn DummyItem position Vector2(500, 400)
update_property res://tests/test_movement.tscn DummyItem collision_layer 2
update_property res://tests/test_movement.tscn DummyItem collision_mask 0
update_property res://tests/test_movement.tscn ItemCollision shape CircleShape2D
# ItemCollision shape radius: 15.0
update_property res://tests/test_movement.tscn ItemSprite modulate Color(1, 1, 0)
# Note: Need to set ItemSprite texture to a 30x30 white square or similar

# Configure UI labels
update_property res://tests/test_movement.tscn StateLabel position Vector2(10, 10)
update_property res://tests/test_movement.tscn StateLabel text "State: Idle"
update_property res://tests/test_movement.tscn StateLabel add_theme_font_size_override 16

update_property res://tests/test_movement.tscn VelocityLabel position Vector2(10, 40)
update_property res://tests/test_movement.tscn VelocityLabel text "Velocity: (0, 0)"
update_property res://tests/test_movement.tscn VelocityLabel add_theme_font_size_override 16

update_property res://tests/test_movement.tscn InteractionLabel position Vector2(10, 70)
update_property res://tests/test_movement.tscn InteractionLabel text "Near: None"
update_property res://tests/test_movement.tscn InteractionLabel add_theme_font_size_override 16

update_property res://tests/test_movement.tscn PositionLabel position Vector2(10, 100)
update_property res://tests/test_movement.tscn PositionLabel text "Position: (0, 0)"
update_property res://tests/test_movement.tscn PositionLabel add_theme_font_size_override 16
```

---

## Node Hierarchies

### Player Scene Structure
```
Player (CharacterBody2D) [Script: player_controller.gd]
├── Sprite (AnimatedSprite2D) - Player animations
├── Collision (CollisionShape2D) - Player hitbox (RectangleShape2D 32x48)
├── InteractionArea (Area2D) - Interaction detection zone
│   └── InteractionCollision (CollisionShape2D) - Interaction radius (CircleShape2D radius 64)
└── Camera (Camera2D) - Player camera (optional)
```

### Test Scene Structure
```
TestMovement (Node2D)
├── TestPlayer (Player) - Instance of player.tscn at (400, 300)
├── Floor (StaticBody2D) - Test floor at bottom
│   ├── FloorCollision (CollisionShape2D)
│   └── FloorVisual (ColorRect) - Gray visual
├── Wall1 (StaticBody2D) - Left wall obstacle
│   ├── Wall1Collision (CollisionShape2D)
│   └── Wall1Visual (ColorRect) - Gray visual
├── Wall2 (StaticBody2D) - Right wall obstacle
│   ├── Wall2Collision (CollisionShape2D)
│   └── Wall2Visual (ColorRect) - Gray visual
├── DummyNPC (Area2D) - Test NPC at (400, 150)
│   ├── NPCCollision (CollisionShape2D)
│   └── NPCSprite (Sprite2D) - Green circle
├── DummyItem (Area2D) - Test item at (500, 400)
│   ├── ItemCollision (CollisionShape2D)
│   └── ItemSprite (Sprite2D) - Yellow circle
└── UI (CanvasLayer)
    ├── StateLabel (Label) - "State: Idle"
    ├── VelocityLabel (Label) - "Velocity: (0, 0)"
    ├── InteractionLabel (Label) - "Near: None"
    └── PositionLabel (Label) - "Position: (0, 0)"
```

---

## Property Configurations

### Critical Properties

**Player (CharacterBody2D):**
- `motion_mode`: 0 (MOTION_MODE_FLOATING for top-down) or 1 (MOTION_MODE_GROUNDED for platformer)
- `collision_layer`: 1 (player layer)
- `collision_mask`: 1 (collides with world)
- Script: `src/systems/s03-player/player_controller.gd`

**Sprite (AnimatedSprite2D):**
- `sprite_frames`: Create SpriteFrames resource with placeholder animations:
  - **idle**: 4 frames, 8 fps, loop, green 32x48 rectangle
  - **walk**: 6 frames, 12 fps, loop, blue 32x48 rectangle
  - **run**: 8 frames, 16 fps, loop, red 32x48 rectangle
- `animation`: "idle"
- `playing`: true

**Collision (CollisionShape2D):**
- `shape`: RectangleShape2D with size Vector2(32, 48) from player_config.json

**InteractionArea (Area2D):**
- `monitoring`: true (detects objects entering)
- `monitorable`: false (player doesn't get detected)
- `collision_layer`: 0 (not on any layer)
- `collision_mask`: 2 (detects layer 2 = interactables)

**InteractionCollision (CollisionShape2D):**
- `shape`: CircleShape2D with radius 64.0 from player_config.json

**Camera (Camera2D):**
- `enabled`: true
- `zoom`: Vector2(2.0, 2.0)
- `position_smoothing_enabled`: true
- `position_smoothing_speed`: 5.0

---

## Signal Connections

**The player controller exposes these signals (already connected in script):**

```gdscript
# State changes
signal movement_state_changed(old_state: String, new_state: String)
signal facing_direction_changed(direction: Vector2)

# Interactions
signal interaction_detected(object: Node)
signal interaction_lost(object: Node)
signal player_interacted(object: Node)
```

**For test scene debugging, create a test script:**

```gdscript
# res://tests/test_movement_ui.gd
extends Node2D

@onready var player = $TestPlayer
@onready var state_label = $UI/StateLabel
@onready var velocity_label = $UI/VelocityLabel
@onready var interaction_label = $UI/InteractionLabel
@onready var position_label = $UI/PositionLabel

func _ready():
    if player:
        player.movement_state_changed.connect(_on_state_changed)
        player.interaction_detected.connect(_on_interaction_detected)
        player.interaction_lost.connect(_on_interaction_lost)

func _process(_delta):
    if player:
        velocity_label.text = "Velocity: (%.0f, %.0f)" % [player.velocity.x, player.velocity.y]
        position_label.text = "Position: (%.0f, %.0f)" % [player.global_position.x, player.global_position.y]

func _on_state_changed(old_state: String, new_state: String):
    state_label.text = "State: %s" % new_state

func _on_interaction_detected(object: Node):
    interaction_label.text = "Near: %s" % object.name

func _on_interaction_lost(object: Node):
    interaction_label.text = "Near: None"
```

---

## Integration Points

### Dependencies

**Requires S02 InputManager:**
- Player uses `InputManager.get_stick_input("left_stick")` for movement
- Player uses `InputManager.is_action_pressed("interact")` for interactions
- Fallback to keyboard input if InputManager not available

### Signals Exposed for Other Systems

**Movement state changes:**
```gdscript
player.movement_state_changed.connect(_on_player_state_changed)
# old_state and new_state: "Idle", "Walking", or "Running"
```

**Interaction detection:**
```gdscript
player.interaction_detected.connect(_on_interaction_detected)
player.interaction_lost.connect(_on_interaction_lost)
player.player_interacted.connect(_on_player_interacted)
```

**Facing direction:**
```gdscript
player.facing_direction_changed.connect(_on_facing_changed)
# direction: Vector2 normalized
```

### Public Methods for Other Systems

```gdscript
# Movement control
player.set_velocity_external(Vector2(100, 0))  # For knockback, cutscenes
player.is_moving() -> bool
player.get_speed() -> float

# State control
player.change_state_external("idle")  # Force state change
player.get_current_state() -> String

# Interaction
player.interact()  # Manually trigger interaction
player.get_nearest_interactable() -> Node
player.get_all_nearby_interactables() -> Array[Node]

# Facing
player.get_facing_direction() -> Vector2
```

### Integration with Future Systems

**S04 Combat:**
- Will add combat state to state machine
- Will use `set_velocity_external()` for knockback
- Will check `is_moving()` for movement-based attacks

**S05 Inventory:**
- Will listen to `player_interacted` signal
- Will check if interacted object is an item

**S14 Tools:**
- Will extend state machine with tool usage states
- Will use facing direction for tool aim

**S15 Vehicles:**
- Will use `change_state_external()` to disable movement when mounted
- Will listen to interaction signals for vehicle mounting

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

### Scene Configuration
- [ ] player.tscn created with CharacterBody2D root
- [ ] All nodes added (Sprite, Collision, InteractionArea, Camera)
- [ ] player_controller.gd attached to root
- [ ] All properties configured correctly
- [ ] Collision shapes created and sized properly
- [ ] SpriteFrames resource created with placeholder animations
- [ ] test_movement.tscn created with complete test environment

### Functionality Testing
- [ ] Test scene runs without errors: `play_scene("res://tests/test_movement.tscn")`
- [ ] Player spawns at center of screen (400, 300)
- [ ] Player moves smoothly in all 4 directions with left stick
- [ ] Movement has responsive acceleration (0 to walk speed in <1 second)
- [ ] Movement has smooth deceleration when stick released
- [ ] Player cannot move through walls (collision detection works)
- [ ] State changes correctly: Idle when stopped, Walking when moving
- [ ] UI labels update in real-time (state, velocity, position)
- [ ] InteractionArea detects DummyNPC when player within 64px
- [ ] InteractionArea detects DummyItem when player within 64px
- [ ] `interaction_detected` signal emits when entering range
- [ ] `interaction_lost` signal emits when leaving range
- [ ] Animations switch based on state (idle/walk/run placeholders visible)
- [ ] Sprite flips horizontally based on movement direction
- [ ] Camera follows player smoothly
- [ ] Player integrates with InputManager (S02) for all movement input
- [ ] Keyboard fallback works if InputManager unavailable

### Quality Gates
- [ ] No Godot errors: `get_godot_errors()`
- [ ] Integration tests pass: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S03")`
- [ ] Quality gates pass: `check_quality_gates("S03")`
- [ ] Checkpoint validated: `validate_checkpoint("S03")`

**Expected Results:**
- Integration tests: All player tests pass
- Performance: <0.5ms per frame overhead
- Quality score: ≥80/100 (passing threshold)
- No console errors or warnings

---

## Gotchas & Known Issues

### Godot 4.5 Specific

**CharacterBody2D differences from Godot 3.x:**
- `velocity` is now a property, not a parameter to `move_and_slide()`
- `move_and_slide()` takes no parameters
- `motion_mode` property: 0 = floating (top-down), 1 = grounded (platformer)

**Type hints required:**
- All functions must have parameter and return type hints
- Variables should have explicit types where Variant could cause issues

**Signal syntax:**
- Use `.emit()` method: `signal_name.emit(args)`
- Not `emit_signal("signal_name", args)`

### System-Specific

**InputManager integration:**
- Player checks for `/root/InputManager` node
- Falls back to keyboard input if not found
- This allows testing without full S02 integration

**Interaction system:**
- Objects must be on collision layer 2 to be detected
- Objects can be Area2D or any Node2D with collision
- Nearest object is automatically tracked and updated

**State machine:**
- Currently only Idle/Walking/Running states
- S04 Combat will extend this with combat states
- Speed thresholds: <10 = idle, <walk_speed*0.8 = walking, else running

**Animation placeholders:**
- Use colored rectangles until proper sprites available
- Green = idle, Blue = walk, Red = run
- Each frame should be 32x48 to match collision box

### Integration Warnings

**Camera setup:**
- Camera is optional but recommended for testing
- Position smoothing helps with feel testing
- Zoom level 2.0 good for testing movement

**Collision layers:**
- Player is on layer 1
- World obstacles should be on layer 1
- Interactables should be on layer 2
- This prevents interactables from blocking player movement

**Performance:**
- `_physics_process` runs at 60 FPS by default
- All movement calculations use delta time
- Acceleration/friction values tuned for 60 FPS

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 CharacterBody2D docs: https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html
- Using CharacterBody2D tutorial: https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html
- State machine pattern: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
- Smooth movement: https://kidscancode.org/godot_recipes/4.x/2d/topdown_movement/
- GDQuest character controller: https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/top_down_movement/character_controller

**Full research notes:** Will be in `research/s03-player-research.md`

**Key Learnings:**
1. CharacterBody2D uses `move_and_slide()` without parameters in Godot 4.x
2. Smooth movement achieved with `velocity.move_toward()` using acceleration/friction
3. State machines work well with signal-based architecture
4. Circular deadzone filtering provides better analog stick feel
5. Interaction systems benefit from separate Area2D for detection radius

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of test scene running (`get_editor_screenshot()`)
2. Screenshot showing player near DummyNPC with interaction detected
3. Screenshot showing UI labels with live data
4. Error log output (`get_godot_errors()`) - should be empty
5. Performance profiler output
6. Integration test results

**Save to:** `evidence/s03-player-tier2-verification/`

---

## Completion Criteria

**System S03 is complete when:**
- ✅ player.tscn created and configured correctly
- ✅ test_movement.tscn runs without errors
- ✅ All movement functionality working (smooth, responsive, collision)
- ✅ All interaction functionality working (detection, signals, nearest tracking)
- ✅ State machine transitions correctly
- ✅ Animations sync with state (placeholders acceptable)
- ✅ Camera follows player smoothly
- ✅ InputManager integration working
- ✅ All tests pass (unit + integration)
- ✅ Performance meets targets (<0.5ms/frame)
- ✅ Quality gates pass (score ≥80)
- ✅ Documentation complete (checkpoint.md)
- ✅ Unblocked systems notified: S04, S05, S14, S15, S16, S17

**Next Steps:**
- S04 Combat can extend player with combat states
- S05 Inventory can listen to player interaction signals
- S14 Tools can add tool usage states
- S15 Vehicles can add mounting/dismounting
- S16 Grind Rails can add rail grinding state
- S17 Puzzles can use interaction system

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 3-4 hours (scene config + testing + placeholder animations)
**Priority:** HIGH (blocks 6 systems: S04, S05, S14, S15, S16, S17)

---

*Generated by: Claude Code Web (Tier 1)*
*Date: 2025-11-18*
*Prompt: 005-s03-player-controller.md*
*Branch: claude/implement-player-controller-01UHjs3FJwBnBRCDaDus4hr7*
