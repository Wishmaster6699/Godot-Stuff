# Research: S03 - Player Controller

**Agent:** Claude Code Web (Tier 1)
**Date:** 2025-11-18
**Duration:** 45 minutes
**System:** Player Controller (CharacterBody2D-based movement and interaction)

---

## Research Summary

Comprehensive research into Godot 4.5 CharacterBody2D implementation, smooth movement physics, state machines, and interaction systems for top-down/platformer player characters.

---

## Godot 4.5 Official Documentation

### CharacterBody2D Core Documentation
**URL:** https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html

**Key Insights:**
- CharacterBody2D is designed for player-controlled characters with kinematic movement
- Velocity is now a property (not a parameter like in Godot 3.x)
- `move_and_slide()` is called without parameters - it uses the `velocity` property
- Two motion modes:
  - `MOTION_MODE_GROUNDED` (0): For platformers with gravity
  - `MOTION_MODE_FLOATING` (1): For top-down games
- Floor detection is automatic in grounded mode
- Collision is handled automatically during `move_and_slide()`

**Critical Godot 4.x Changes from 3.x:**
```gdscript
# Godot 3.x (OLD - DON'T USE)
velocity = move_and_slide(velocity, Vector2.UP)

# Godot 4.x (CORRECT)
velocity = target_velocity
move_and_slide()
```

### Using CharacterBody2D Tutorial
**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html

**Key Insights:**
- `_physics_process(delta)` is where movement should happen
- Delta time should be used for all movement calculations
- Collision layers and masks control what the character collides with
- `get_slide_collision()` can be used to detect what was hit
- `floor_snap_length` helps with smooth movement on slopes (platformers)

**Example Pattern:**
```gdscript
func _physics_process(delta):
    var input_dir = Input.get_vector("left", "right", "up", "down")
    velocity = input_dir * SPEED
    move_and_slide()
```

---

## Existing Godot 4.5 Projects

### GDQuest Character Controller
**URL:** https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/top_down_movement/character_controller

**Key Insights:**
- Smooth movement achieved with `velocity.move_toward(target, acceleration * delta)`
- Friction applied when no input: `velocity.move_toward(Vector2.ZERO, friction * delta)`
- This creates natural acceleration and deceleration
- Feels responsive and game-like (not instant movement)

**Code Pattern Extracted:**
```gdscript
func _physics_process(delta):
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if input_direction.length() > 0:
        # Accelerate towards target velocity
        var target_velocity = input_direction.normalized() * max_speed
        velocity = velocity.move_toward(target_velocity, acceleration * delta)
    else:
        # Apply friction to slow down
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

    move_and_slide()
```

### Kids Can Code - Top-Down Movement
**URL:** https://kidscancode.org/godot_recipes/4.x/2d/topdown_movement/

**Key Insights:**
- Recommends separating input handling from movement
- Deadzone filtering for analog sticks improves feel
- Animation should be driven by velocity magnitude and direction
- State machine pattern helps manage animation states

**Architecture Pattern:**
```gdscript
# Separate concerns:
# 1. Get input -> direction vector
# 2. Calculate target velocity
# 3. Interpolate current velocity to target
# 4. Apply movement
# 5. Update animation based on state
```

---

## State Machine Patterns

### GDQuest Finite State Machine
**URL:** https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/

**Key Insights:**
- States as enum vs. separate state nodes
- Enum approach is simpler for basic player states
- Signal-based state transitions allow other systems to react
- Each state can have enter/exit logic

**Recommended Pattern for Player:**
```gdscript
enum State { IDLE, WALKING, RUNNING, JUMPING, FALLING }

var current_state = State.IDLE

func change_state(new_state: State):
    if new_state == current_state:
        return

    # Exit current state
    match current_state:
        State.IDLE: _exit_idle()
        State.WALKING: _exit_walking()

    # Enter new state
    current_state = new_state
    match current_state:
        State.IDLE: _enter_idle()
        State.WALKING: _enter_walking()

    state_changed.emit(current_state)
```

### The Shaggy Dev - State Machines
**URL:** https://shaggydev.com/2023/10/08/godot-4-state-machines/

**Key Insights:**
- State transitions based on conditions (velocity, input, etc.)
- Can use simple if/elif chains for basic state machines
- More complex games benefit from state node hierarchy
- Player controller is simple enough for enum-based approach

---

## Movement Physics Best Practices

### Smooth Movement Implementation
**Source:** Multiple tutorials + official docs

**Key Parameters:**
- `walk_speed`: 150-250 px/s for slow movement
- `run_speed`: 300-500 px/s for fast movement
- `acceleration`: 600-1000 px/s² for responsive feel
- `friction`: 800-1200 px/s² for quick stopping

**Tuning Guide:**
- Higher acceleration = more responsive (arcade feel)
- Lower acceleration = more momentum (realistic feel)
- Friction > acceleration = quick stops
- Friction < acceleration = slidey feel

### Analog Stick Integration
**Source:** S02 InputManager research + SDL3 documentation

**Key Insights:**
- InputManager provides deadzone-filtered input
- Circular deadzone is better than rectangular
- Use `get_stick_input()` which returns normalized Vector2
- Magnitude can be used for walk vs. run detection

**Integration Pattern:**
```gdscript
var input_direction = InputManager.get_stick_input("left_stick")
# Already deadzone-filtered and normalized by InputManager

# Can also check magnitude for variable speed
var input_magnitude = input_direction.length()
var target_speed = lerp(0, max_speed, input_magnitude)
```

---

## Interaction System Design

### Area2D for Detection Radius
**Source:** Godot docs + community best practices

**Key Insights:**
- Use separate Area2D child node for interaction detection
- CircleShape2D for radial detection (64-128px typical)
- Area2D doesn't block movement (unlike collision shapes)
- Can detect both Area2D and PhysicsBody2D objects

**Architecture:**
```
Player (CharacterBody2D)
├── Sprite
├── CollisionShape2D (hitbox for movement collision)
└── InteractionArea (Area2D)
    └── CollisionShape2D (CircleShape2D for detection)
```

**Signal Pattern:**
```gdscript
func _ready():
    $InteractionArea.area_entered.connect(_on_area_entered)
    $InteractionArea.area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
    nearby_objects.append(area)
    interaction_detected.emit(area)

func _on_area_exited(area: Area2D):
    nearby_objects.erase(area)
    interaction_lost.emit(area)
```

### Nearest Object Tracking
**Pattern:** Custom implementation

**Key Insights:**
- Track all objects in range in an array
- Calculate nearest each frame or on detection change
- Emit signal when nearest changes
- Interact button triggers interaction with nearest only

---

## Animation System

### AnimatedSprite2D Best Practices
**Source:** Godot docs + GDQuest tutorials

**Key Insights:**
- Use SpriteFrames resource to organize animations
- Each animation can have different FPS
- Autoplay can be set for idle animation
- `animation_finished` signal useful for one-shot animations

**Animation States for Player:**
- `idle`: Looping, 4-8 frames, 6-10 FPS
- `walk`: Looping, 6-8 frames, 10-12 FPS
- `run`: Looping, 8-10 frames, 14-18 FPS
- `jump`: One-shot, 3-5 frames, 12-15 FPS
- `fall`: Looping, 2-3 frames, 8-10 FPS

**Direction Handling:**
```gdscript
# Flip sprite instead of separate left/right animations
if velocity.x < 0:
    sprite.flip_h = true
elif velocity.x > 0:
    sprite.flip_h = false
# Don't flip on vertical-only movement
```

---

## Godot 4.5 Specific Considerations

### Type Hints (Required in GDScript 4.5)
**Source:** GDScript documentation

**Critical Rules:**
```gdscript
# All function parameters must have types
func move_player(direction: Vector2, speed: float) -> void:
    pass

# Variables should have explicit types where possible
var velocity: Vector2 = Vector2.ZERO
var current_state: State = State.IDLE
var nearby_objects: Array[Node] = []

# Use typed arrays for better performance
var interactables: Array[Area2D] = []  # Not just Array!
```

### Signal Syntax (Changed from Godot 3.x)
**Source:** Godot 4.x migration guide

**Godot 4.x signal usage:**
```gdscript
# Define signal with typed parameters
signal state_changed(old_state: String, new_state: String)

# Emit signal
state_changed.emit("idle", "walking")

# Connect signal
player.state_changed.connect(_on_player_state_changed)
```

### String Repetition (CRITICAL - GDScript 4.5 Syntax)
**Source:** GDScript 4.5 documentation

**WRONG (Godot 3.x):**
```gdscript
var line = "=" * 60  # SYNTAX ERROR in GDScript 4.5!
```

**CORRECT (GDScript 4.5):**
```gdscript
var line = "=".repeat(60)  # Use .repeat() method
```

---

## Integration with S02 InputManager

### InputManager API Review
**Source:** res/autoloads/input_manager.gd

**Available Methods:**
```gdscript
# Get analog stick input (deadzone-filtered, normalized)
InputManager.get_stick_input("left_stick") -> Vector2

# Check if action button is pressed
InputManager.is_action_pressed("interact") -> bool

# Signals available
InputManager.button_pressed.connect(_on_button_pressed)
InputManager.stick_moved.connect(_on_stick_moved)
```

**Integration Pattern:**
```gdscript
# In player controller
func _physics_process(delta):
    var input_dir = Vector2.ZERO

    if has_node("/root/InputManager"):
        input_dir = InputManager.get_stick_input("left_stick")
    else:
        # Fallback to keyboard
        input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    # Rest of movement logic...
```

---

## Key Decisions Made

### 1. Motion Mode: Floating vs. Grounded
**Decision:** Use `MOTION_MODE_FLOATING` for top-down game
**Reasoning:**
- No gravity needed for top-down movement
- Allows free 8-directional movement
- Can switch to MOTION_MODE_GROUNDED if platformer sections added later

### 2. State Machine: Enum vs. Node-based
**Decision:** Use simple enum-based state machine
**Reasoning:**
- Only 3-4 basic states (Idle, Walking, Running, [Jumping])
- Enum approach is simpler and more performant
- Can refactor to node-based if complexity increases with S04 Combat

### 3. Acceleration Model: Instant vs. Smooth
**Decision:** Use smooth acceleration with `velocity.move_toward()`
**Reasoning:**
- Feels more polished and game-like
- Allows tuning for different game feels
- More responsive than physics-based approach
- Industry standard for character controllers

### 4. Interaction Detection: Raycast vs. Area2D
**Decision:** Use Area2D with CircleShape2D
**Reasoning:**
- Detects all nearby objects automatically
- No need to manually raycast each frame
- Can track multiple objects in range
- Easy to visualize in editor

### 5. Animation: Directional vs. Flip
**Decision:** Use flip_h for left/right, separate animations for up/down if needed
**Reasoning:**
- Reduces animation asset requirements by 50%
- Standard practice in 2D games
- Easy to change if 4-directional assets become available

---

## Gotchas for Tier 2 Agent

### Collision Layer Setup
- Player should be on layer 1
- World geometry on layer 1 (so player collides)
- Interactables on layer 2 (so InteractionArea detects but player doesn't collide)

### Shape Resource Creation
- RectangleShape2D for player hitbox needs to be created as separate resource
- CircleShape2D for interaction area needs to be created as separate resource
- Set sizes in inspector after creation

### Placeholder Animations
- Until proper sprites available, use ColorRect or simple shapes
- Different colors for different states help with debugging
- Should be 32x48 to match collision box

### InputManager Autoload
- S02 should have registered InputManager as autoload
- Player checks for `/root/InputManager` node
- Falls back to keyboard if not found (for testing)

### Signal Connections
- InteractionArea signals must be connected in `_ready()`
- Player exposes signals but doesn't require connections
- Test script should connect to signals for UI updates

---

## Reusable Patterns Identified

### Pattern 1: Smooth Kinematic Movement
**Reusable for:** Any character controller (enemies, NPCs, vehicles)

```gdscript
# Configurable smooth movement
var target_velocity = direction * speed
velocity = velocity.move_toward(target_velocity, acceleration * delta)
move_and_slide()
```

### Pattern 2: Nearest Object Tracking
**Reusable for:** AI target selection, pickup systems, quest objectives

```gdscript
# Track and find nearest from array
var nearest = null
var nearest_distance = INF
for obj in candidates:
    var dist = global_position.distance_to(obj.global_position)
    if dist < nearest_distance:
        nearest_distance = dist
        nearest = obj
```

### Pattern 3: Signal-based State Machine
**Reusable for:** Enemy AI, UI states, game manager

```gdscript
signal state_changed(old_state, new_state)

func change_state(new_state):
    var old = current_state
    current_state = new_state
    state_changed.emit(old, new_state)
```

---

## Performance Considerations

### Frame Budget
- Player controller should use <0.5ms per frame
- `_physics_process` runs at 60 FPS by default
- Movement calculations are simple math (very fast)
- Collision detection handled by Godot engine (optimized)

### Optimization Opportunities
- Cache InputManager reference in `_ready()` instead of `has_node()` each frame
- Only update nearest interactable when nearby_objects changes
- Animation updates can be less frequent than movement (30 FPS is fine)

### Memory Usage
- Player is singleton (one instance)
- nearby_interactables array typically small (<10 objects)
- No dynamic allocations in hot path
- Total memory footprint: <1KB

---

## Testing Strategy

### Unit Tests (Tier 1 - Conceptual)
- State transitions work correctly
- Velocity calculations are accurate
- Interaction detection radius is correct
- Signals emit at correct times

### Integration Tests (Tier 2 - In Engine)
- Player moves smoothly in all directions
- Collision with walls prevents movement
- Interaction area detects objects at correct distance
- InputManager integration works
- Camera follows player
- Animations sync with state

### Manual Test Checklist (Tier 2)
- Movement feels responsive
- Stopping feels natural (not too slidey)
- Interaction detection radius is visible and correct
- UI updates in real-time
- No jittering or stuttering
- Works with controller and keyboard

---

## References

### Documentation
- https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html
- https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html
- https://docs.godotengine.org/en/4.4/classes/class_area2d.html

### Tutorials
- https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
- https://kidscancode.org/godot_recipes/4.x/2d/topdown_movement/
- https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/top_down_movement/character_controller
- https://shaggydev.com/2023/10/08/godot-4-state-machines/

### Community Resources
- https://github.com/ExpressoBits/character-controller (Godot 4 reference)
- https://godotengine.org/asset-library/ (For plugins and examples)

---

## Next Steps for Implementation

1. ✅ Create `player_controller.gd` with complete implementation
2. ✅ Create `player_config.json` with all configuration
3. ✅ Create `HANDOFF-S03.md` for Tier 2 agent
4. ⏳ Tier 2: Create player.tscn scene
5. ⏳ Tier 2: Create test_movement.tscn
6. ⏳ Tier 2: Configure all properties
7. ⏳ Tier 2: Create placeholder animations
8. ⏳ Tier 2: Test and validate
9. ⏳ Tier 2: Run quality gates
10. ⏳ Tier 2: Create checkpoint

---

**Research Complete**
**Time Spent:** 45 minutes
**Confidence Level:** High - All patterns validated against Godot 4.5 documentation
**Ready for Implementation:** Yes
