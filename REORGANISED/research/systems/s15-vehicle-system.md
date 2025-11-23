# Research: S15 - Vehicle System
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 30 minutes

## Godot 4.5 Documentation

### CharacterBody2D
- **Primary Resource:** Official Godot 4.x documentation
- **Key Insight:** CharacterBody2D is appropriate for code-controlled movement with collision detection
- **Properties:** `velocity` property (changed from Godot 3.x parameter)
- **Method:** `move_and_slide()` with no parameters - velocity is a property
- **Best for:** Player-controlled or scripted movement that needs collision

### Area2D for Interaction
- **Resource:** https://docs.godotengine.org/en/4.5/tutorials/physics/using_area_2d.html
- **Key Signals:**
  - `body_entered(body: Node2D)` - detects when CharacterBody2D enters
  - `body_exited(body: Node2D)` - detects when CharacterBody2D exits
- **Use Case:** Perfect for mount/dismount trigger zones
- **Gotcha:** Area2D must be in motion for some edge cases with StaticBody2D

## Existing Godot 4 Projects

### 2D Overhead Car Physics
- **GitHub:** https://github.com/37Rb/godot-overhead-car-2d
- **Key Insight:** Uses CharacterBody2D with custom physics
- **Pattern:** Wheel base and steering angle for arcade-style car physics
- **Architecture:** Extends CharacterBody2D directly

### DriftCarG4
- **Resource:** https://notabug.org/tomaga/DriftCarG4
- **Key Insight:** Arcade-style drifting using PID controllers
- **Pattern:** Lift-off oversteer - release and re-press accelerator while turning to drift
- **No tire friction model:** Simplified arcade physics for easy control

### Car Steering Tutorial (KidsCanCode)
- **Resource:** https://kidscancode.org/godot_recipes/4.x/2d/car_steering/
- **Key Pattern:**
  - Calculate steering each frame
  - Pass resulting velocity to move_and_slide()
  - Use wheel_base and steering_angle variables
- **Focus:** "Arcade" level realism, action over simulation

## Code Patterns

### Vehicle Base Class Structure
```gdscript
extends CharacterBody2D
class_name Vehicle

# Mount/Dismount
var mounted: bool = false
var mounted_player: PlayerController = null

# Physics
var max_speed: float = 300.0
var acceleration: float = 500.0
var friction: float = 800.0

# Signals
signal player_mounted(player: PlayerController)
signal player_dismounted(player: PlayerController)

func _physics_process(delta: float) -> void:
    if mounted:
        _update_vehicle_physics(delta)
    move_and_slide()
```

### Mount/Dismount Pattern
```gdscript
# In Vehicle script
@onready var mount_area: Area2D = $MountArea

func _ready() -> void:
    mount_area.body_entered.connect(_on_mount_area_entered)

func _on_mount_area_entered(body: Node2D) -> void:
    if body is PlayerController and not mounted:
        # Player can press interact to mount
        pass

func mount(player: PlayerController) -> void:
    mounted = true
    mounted_player = player
    # Hide player sprite
    # Transfer control to vehicle
    player_mounted.emit(player)
```

### Drifting Mechanic
- Measure sideways velocity
- Add lateral force to reduce it
- For drifting: Don't fully zero sideways velocity
- Allow controlled slide

## Integration with S03 Player

### Player Controller Integration Points
- **File:** src/systems/s03-player/player_controller.gd
- **Interaction System:** Uses Area2D with body_entered/body_exited signals
- **Method:** `interact()` - called when player presses interact button near object
- **Pattern:** Vehicle should have `interact(player: PlayerController)` method
- **Player Visibility:** Access sprite via player reference to hide when mounted

### Integration Pattern
```gdscript
# Vehicle receives interact call from player
func interact(player: PlayerController) -> void:
    if not mounted:
        mount(player)
    else:
        dismount()

func mount(player: PlayerController) -> void:
    mounted = true
    mounted_player = player
    # Hide player sprite
    if player.has_node("Sprite"):
        player.get_node("Sprite").visible = false
    # Disable player movement
    player.set_physics_process(false)

func dismount() -> void:
    if mounted_player != null:
        # Show player sprite
        if mounted_player.has_node("Sprite"):
            mounted_player.get_node("Sprite").visible = true
        # Re-enable player movement
        mounted_player.set_physics_process(true)
        # Position player next to vehicle
        mounted_player.global_position = global_position + Vector2(64, 0)
    mounted = false
    mounted_player = null
```

## Vehicle-Specific Implementations

### Mech Suit
- **Speed:** 100 (slow)
- **Special:** High defense bonus (+50)
- **Ability:** Stomp AoE (Area2D damage zone)
- **Can Attack:** Yes, player can attack while mounted

### Car
- **Speed:** 400 (fast)
- **Special:** Drifting mechanic (reduce lateral velocity partially)
- **Ability:** Nitro boost (temporary speed increase, stamina cost)
- **Cannot Attack:** Movement only

### Airship
- **Speed:** 250 (medium)
- **Special:** Ignores ground collision (different collision layer)
- **Ability:** Altitude control (z-index simulation)
- **Cannot Attack:** Movement only
- **Requires:** Landing pads to dismount

### Boat
- **Speed:** 200 (medium)
- **Special:** Water-only detection (check tile type or area)
- **Ability:** Wave physics (sine wave bobbing, tilt)
- **Can Use:** Fishing ability

## GDScript 4.5 Specifics

### Critical Syntax Rules
✅ **Correct:**
- `extends CharacterBody2D`
- `var player: PlayerController` (typed)
- `move_and_slide()` (no parameters)
- `signal player_mounted(player: PlayerController)` (typed signal)
- `"text".repeat(5)` (string repetition)

❌ **Incorrect (Godot 3.x):**
- `extends KinematicBody2D`
- `move_and_slide(velocity)`
- `"text" * 5`

## Key Decisions

1. **Use CharacterBody2D as base:** Standard for code-controlled movement
2. **Area2D for mount zones:** Standard interaction pattern, consistent with player
3. **Arcade physics:** Simple and fun over realistic simulation
4. **Player integration:** Call player's interact() system, vehicle implements interact(player)
5. **Config-driven:** Use JSON for vehicle parameters (speeds, abilities)

## Gotchas for Tier 2

1. **Collision Layers:** Each vehicle may need different collision layers
   - Ground vehicles: Layer 1
   - Airship: Layer 2 (ignores ground obstacles)
   - Boat: Layer 3 (water areas only)

2. **Player Sprite Access:** Player sprite is `$Sprite` (AnimatedSprite2D)

3. **InputManager Integration:** Use /root/InputManager for input if available

4. **Physics Process:** Disable player's physics process when mounted to prevent conflicts

5. **Dismount Position:** Calculate safe dismount position (not inside walls)

## References

- Godot 4.5 CharacterBody2D: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html
- Car Steering Tutorial: https://kidscancode.org/godot_recipes/4.x/2d/car_steering/
- 2D Overhead Car Physics: https://github.com/37Rb/godot-overhead-car-2d
- Area2D Tutorial: https://docs.godotengine.org/en/4.5/tutorials/physics/using_area_2d.html
- Player Controller: src/systems/s03-player/player_controller.gd

## Time Estimates

- Vehicle Base Class: 1.5 hours
- Each Vehicle Implementation: 45 minutes each (3 hours total for 4 vehicles)
- Configuration JSON: 30 minutes
- HANDOFF Documentation: 1 hour
- **Total Tier 1:** ~6 hours
