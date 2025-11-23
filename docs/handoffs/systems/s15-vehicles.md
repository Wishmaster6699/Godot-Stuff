# HANDOFF: S15 - Vehicle System
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** Complete vehicle system with 4 unique mountable vehicles (Mech Suit, Car, Airship, Boat), each with distinct physics and abilities.

**Type:** Scene Components + Player Integration

**Dependencies:** S03 (PlayerController)

**Key Features:**
- Mount/dismount system with Area2D triggers
- Unique physics for each vehicle type
- Vehicle-specific abilities (stomp, nitro, altitude, fishing)
- Player sprite hiding when mounted
- Context-based activation (water for boat, air for airship, etc.)

---

## Files Created by Tier 1

### GDScript Files
- ✅ `src/systems/s15-vehicle/vehicle_base.gd` - Base class for all vehicles (CharacterBody2D)
- ✅ `src/systems/s15-vehicle/mech_suit.gd` - Heavy combat mech with stomp AoE ability
- ✅ `src/systems/s15-vehicle/car.gd` - Fast car with drifting and nitro boost
- ✅ `src/systems/s15-vehicle/airship.gd` - Aerial vehicle with altitude control
- ✅ `src/systems/s15-vehicle/boat.gd` - Water vehicle with wave physics and fishing

### JSON Data Files
- ✅ `data/vehicles_config.json` - Complete vehicle parameters, abilities, physics configs

### Research Files
- ✅ `research/S15-vehicle-system-research.md` - Research findings and patterns

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | Godot 4.5 compatible ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Create Mech Suit Scene

```bash
# Create mech suit scene
create_scene res://scenes/s15-vehicle/mech_suit.tscn

# Add root node (CharacterBody2D)
add_node res://scenes/s15-vehicle/mech_suit.tscn CharacterBody2D MechSuit root

# Add visual components
add_node res://scenes/s15-vehicle/mech_suit.tscn Sprite2D Sprite MechSuit
add_node res://scenes/s15-vehicle/mech_suit.tscn CollisionShape2D CollisionShape2D MechSuit

# Add mount area for player interaction
add_node res://scenes/s15-vehicle/mech_suit.tscn Area2D MountArea MechSuit
add_node res://scenes/s15-vehicle/mech_suit.tscn CollisionShape2D MountCollision MountArea

# Attach script
attach_script res://scenes/s15-vehicle/mech_suit.tscn MechSuit src/systems/s15-vehicle/mech_suit.gd

# Configure properties
update_property res://scenes/s15-vehicle/mech_suit.tscn MechSuit max_speed 100.0
update_property res://scenes/s15-vehicle/mech_suit.tscn MechSuit acceleration 300.0
update_property res://scenes/s15-vehicle/mech_suit.tscn Sprite MechSuit modulate "Color(0.5, 0.5, 0.7, 1.0)"

# Configure collision shape
add_resource res://scenes/s15-vehicle/mech_suit.tscn CollisionShape2D shape CircleShape2D
update_property res://scenes/s15-vehicle/mech_suit.tscn CollisionShape2D shape:radius 32.0

# Configure mount area collision
add_resource res://scenes/s15-vehicle/mech_suit.tscn MountCollision shape CircleShape2D
update_property res://scenes/s15-vehicle/mech_suit.tscn MountCollision shape:radius 48.0
```

### Step 2: Create Car Scene

```bash
# Create car scene
create_scene res://scenes/s15-vehicle/car.tscn

# Add root node
add_node res://scenes/s15-vehicle/car.tscn CharacterBody2D Car root

# Add visual components
add_node res://scenes/s15-vehicle/car.tscn Sprite2D Sprite Car
add_node res://scenes/s15-vehicle/car.tscn CollisionShape2D CollisionShape2D Car

# Add mount area
add_node res://scenes/s15-vehicle/car.tscn Area2D MountArea Car
add_node res://scenes/s15-vehicle/car.tscn CollisionShape2D MountCollision MountArea

# Attach script
attach_script res://scenes/s15-vehicle/car.tscn Car src/systems/s15-vehicle/car.gd

# Configure properties
update_property res://scenes/s15-vehicle/car.tscn Car max_speed 400.0
update_property res://scenes/s15-vehicle/car.tscn Car acceleration 800.0
update_property res://scenes/s15-vehicle/car.tscn Car drift_coefficient 0.8
update_property res://scenes/s15-vehicle/car.tscn Sprite Car modulate "Color(0.9, 0.3, 0.3, 1.0)"

# Configure collision (rectangular for car)
add_resource res://scenes/s15-vehicle/car.tscn CollisionShape2D shape RectangleShape2D
update_property res://scenes/s15-vehicle/car.tscn CollisionShape2D shape:size "Vector2(48, 32)"

# Configure mount area
add_resource res://scenes/s15-vehicle/car.tscn MountCollision shape CircleShape2D
update_property res://scenes/s15-vehicle/car.tscn MountCollision shape:radius 48.0
```

### Step 3: Create Airship Scene

```bash
# Create airship scene
create_scene res://scenes/s15-vehicle/airship.tscn

# Add root node
add_node res://scenes/s15-vehicle/airship.tscn CharacterBody2D Airship root

# Add visual components
add_node res://scenes/s15-vehicle/airship.tscn Sprite2D Sprite Airship
add_node res://scenes/s15-vehicle/airship.tscn CollisionShape2D CollisionShape2D Airship

# Add mount area
add_node res://scenes/s15-vehicle/airship.tscn Area2D MountArea Airship
add_node res://scenes/s15-vehicle/airship.tscn CollisionShape2D MountCollision MountArea

# Attach script
attach_script res://scenes/s15-vehicle/airship.tscn Airship src/systems/s15-vehicle/airship.gd

# Configure properties
update_property res://scenes/s15-vehicle/airship.tscn Airship max_speed 250.0
update_property res://scenes/s15-vehicle/airship.tscn Airship max_altitude 500.0
update_property res://scenes/s15-vehicle/airship.tscn Airship current_altitude 100.0
update_property res://scenes/s15-vehicle/airship.tscn Sprite Airship modulate "Color(0.3, 0.7, 0.9, 1.0)"

# Configure collision
add_resource res://scenes/s15-vehicle/airship.tscn CollisionShape2D shape CircleShape2D
update_property res://scenes/s15-vehicle/airship.tscn CollisionShape2D shape:radius 40.0

# Configure mount area
add_resource res://scenes/s15-vehicle/airship.tscn MountCollision shape CircleShape2D
update_property res://scenes/s15-vehicle/airship.tscn MountCollision shape:radius 48.0

# Set collision layers for aerial vehicle (different from ground)
update_property res://scenes/s15-vehicle/airship.tscn Airship collision_layer 4
update_property res://scenes/s15-vehicle/airship.tscn Airship collision_mask 1
```

### Step 4: Create Boat Scene

```bash
# Create boat scene
create_scene res://scenes/s15-vehicle/boat.tscn

# Add root node
add_node res://scenes/s15-vehicle/boat.tscn CharacterBody2D Boat root

# Add visual components
add_node res://scenes/s15-vehicle/boat.tscn Sprite2D Sprite Boat
add_node res://scenes/s15-vehicle/boat.tscn CollisionShape2D CollisionShape2D Boat

# Add mount area
add_node res://scenes/s15-vehicle/boat.tscn Area2D MountArea Boat
add_node res://scenes/s15-vehicle/boat.tscn CollisionShape2D MountCollision MountArea

# Attach script
attach_script res://scenes/s15-vehicle/boat.tscn Boat src/systems/s15-vehicle/boat.gd

# Configure properties
update_property res://scenes/s15-vehicle/boat.tscn Boat max_speed 200.0
update_property res://scenes/s15-vehicle/boat.tscn Boat wave_amplitude 10.0
update_property res://scenes/s15-vehicle/boat.tscn Sprite Boat modulate "Color(0.6, 0.4, 0.2, 1.0)"

# Configure collision
add_resource res://scenes/s15-vehicle/boat.tscn CollisionShape2D shape RectangleShape2D
update_property res://scenes/s15-vehicle/boat.tscn CollisionShape2D shape:size "Vector2(64, 40)"

# Configure mount area
add_resource res://scenes/s15-vehicle/boat.tscn MountCollision shape CircleShape2D
update_property res://scenes/s15-vehicle/boat.tscn MountCollision shape:radius 48.0

# Set collision layers for water vehicle
update_property res://scenes/s15-vehicle/boat.tscn Boat collision_layer 5
update_property res://scenes/s15-vehicle/boat.tscn Boat collision_mask 1
```

### Step 5: Create Test Scene

```bash
# Create comprehensive test scene
create_scene res://tests/test_vehicles.tscn

# Add root node
add_node res://tests/test_vehicles.tscn Node2D TestVehicles root

# Add camera for viewing
add_node res://tests/test_vehicles.tscn Camera2D Camera TestVehicles
update_property res://tests/test_vehicles.tscn Camera Camera enabled true
update_property res://tests/test_vehicles.tscn Camera Camera zoom "Vector2(0.5, 0.5)"

# Add terrain/ground (TileMap or placeholder)
add_node res://tests/test_vehicles.tscn TileMap Terrain TestVehicles
update_property res://tests/test_vehicles.tscn Terrain TestVehicles modulate "Color(0.3, 0.5, 0.3, 1.0)"

# Add water area for boat testing
add_node res://tests/test_vehicles.tscn Area2D WaterArea TestVehicles
add_node res://tests/test_vehicles.tscn CollisionShape2D WaterCollision WaterArea
add_resource res://tests/test_vehicles.tscn WaterCollision shape RectangleShape2D
update_property res://tests/test_vehicles.tscn WaterCollision shape:size "Vector2(400, 300)"
update_property res://tests/test_vehicles.tscn WaterArea position "Vector2(700, 250)"

# Add vehicles to scene
add_scene res://tests/test_vehicles.tscn res://scenes/s15-vehicle/mech_suit.tscn MechSuit TestVehicles
add_scene res://tests/test_vehicles.tscn res://scenes/s15-vehicle/car.tscn Car TestVehicles
add_scene res://tests/test_vehicles.tscn res://scenes/s15-vehicle/airship.tscn Airship TestVehicles
add_scene res://tests/test_vehicles.tscn res://scenes/s15-vehicle/boat.tscn Boat TestVehicles

# Position vehicles
update_property res://tests/test_vehicles.tscn MechSuit position "Vector2(100, 300)"
update_property res://tests/test_vehicles.tscn Car position "Vector2(300, 300)"
update_property res://tests/test_vehicles.tscn Airship position "Vector2(500, 200)"
update_property res://tests/test_vehicles.tscn Boat position "Vector2(700, 250)"

# Add player instance for testing
add_scene res://tests/test_vehicles.tscn res://scenes/s03-player/player.tscn Player TestVehicles
update_property res://tests/test_vehicles.tscn Player position "Vector2(200, 300)"

# Add labels for instructions
add_node res://tests/test_vehicles.tscn CanvasLayer UI TestVehicles
add_node res://tests/test_vehicles.tscn Label Instructions UI
update_property res://tests/test_vehicles.tscn Instructions text "Vehicle Test Scene\nMove to vehicle and press INTERACT to mount\nPress CANCEL to dismount\nPress ACCEPT to use ability"
update_property res://tests/test_vehicles.tscn Instructions position "Vector2(10, 10)"
update_property res://tests/test_vehicles.tscn Instructions add_theme_font_size_override 16
```

### Step 6: Configure Water Area for Boat

```bash
# Make water area detectable by boat
execute_editor_script "
var water_area = get_node('res://tests/test_vehicles.tscn::WaterArea')
if water_area:
    water_area.add_to_group('water')
    print('Water area added to water group')
"
```

---

## Node Hierarchies

### Mech Suit Structure
```
CharacterBody2D (MechSuit) [Script: mech_suit.gd]
├── Sprite2D (Sprite)
├── CollisionShape2D (CollisionShape2D) [CircleShape2D radius=32]
├── Area2D (MountArea)
│   └── CollisionShape2D (MountCollision) [CircleShape2D radius=48]
└── Area2D (StompArea) [Created by script]
    └── CollisionShape2D (StompCollision) [CircleShape2D radius=100]
```

### Car Structure
```
CharacterBody2D (Car) [Script: car.gd]
├── Sprite2D (Sprite)
├── CollisionShape2D (CollisionShape2D) [RectangleShape2D 48x32]
└── Area2D (MountArea)
    └── CollisionShape2D (MountCollision) [CircleShape2D radius=48]
```

### Airship Structure
```
CharacterBody2D (Airship) [Script: airship.gd]
├── Sprite2D (Sprite)
├── CollisionShape2D (CollisionShape2D) [CircleShape2D radius=40]
├── Area2D (MountArea)
│   └── CollisionShape2D (MountCollision) [CircleShape2D radius=48]
└── Sprite2D (AltitudeShadow) [Created by script]
```

### Boat Structure
```
CharacterBody2D (Boat) [Script: boat.gd]
├── Sprite2D (Sprite)
├── CollisionShape2D (CollisionShape2D) [RectangleShape2D 64x40]
├── Area2D (MountArea)
│   └── CollisionShape2D (MountCollision) [CircleShape2D radius=48]
└── Area2D (WaterCheckArea) [Created by script]
    └── CollisionShape2D (WaterCheckCollision) [CircleShape2D radius=32]
```

### Test Scene Structure
```
Node2D (TestVehicles)
├── Camera2D (Camera)
├── TileMap (Terrain)
├── Area2D (WaterArea) [group: water]
│   └── CollisionShape2D (WaterCollision)
├── MechSuit (instance)
├── Car (instance)
├── Airship (instance)
├── Boat (instance)
├── Player (instance)
└── CanvasLayer (UI)
    └── Label (Instructions)
```

---

## Property Configurations

### Critical Properties

**Mech Suit:**
- `max_speed`: 100.0 (slow, heavy)
- `acceleration`: 300.0
- `defense_bonus`: 50.0
- `can_attack`: true
- `stomp_damage`: 50
- `stomp_radius`: 100.0
- Collision layer: 3 (ground vehicles)

**Car:**
- `max_speed`: 400.0 (fast)
- `acceleration`: 800.0
- `drift_coefficient`: 0.8
- `nitro_speed_multiplier`: 1.5
- `can_attack`: false
- Collision layer: 3 (ground vehicles)

**Airship:**
- `max_speed`: 250.0
- `max_altitude`: 500.0
- `current_altitude`: 100.0
- `can_attack`: false
- Collision layer: 4 (aerial - ignores ground)
- Collision mask: 1 (only world boundaries)

**Boat:**
- `max_speed`: 200.0
- `wave_amplitude`: 10.0
- `wave_frequency`: 1.0
- `fishing_success_chance`: 0.7
- `can_attack`: false
- Collision layer: 5 (water vehicles)
- Must be in water area (group: "water") to move

---

## Integration Notes

### Player Controller Integration (S03)

**Mount System:**
```gdscript
# Player approaches vehicle with MountArea
# Player presses interact button (ui_accept)
# Vehicle.interact(player) is called
# Vehicle mounts player:
  - Hides player sprite ($Sprite.visible = false)
  - Disables player physics (set_physics_process(false))
  - Transfers control to vehicle
```

**Dismount System:**
```gdscript
# Player presses dismount button (ui_cancel) while mounted
# OR calls Vehicle.dismount()
# Vehicle dismounts player:
  - Shows player sprite ($Sprite.visible = true)
  - Re-enables player physics (set_physics_process(true))
  - Positions player next to vehicle (offset 64px)
```

**Integration Code Example:**
```gdscript
# In PlayerController, the interact() method calls:
func interact() -> void:
    if nearest_interactable != null:
        if nearest_interactable.has_method("interact"):
            nearest_interactable.call("interact", self)

# Vehicles implement:
func interact(player: Node) -> void:
    if not mounted:
        mount(player)
    else:
        dismount()
```

### Configuration Data

All vehicle parameters are loaded from `data/vehicles_config.json`:
- Physics values (speed, acceleration, friction)
- Ability parameters (damage, cooldown, duration)
- Combat stats (health, defense)
- Special mechanics (drift, altitude, waves)

---

## Testing Checklist for Tier 2

**Use Godot MCP tools to test:**

```bash
# Run test scene
play_scene res://tests/test_vehicles.tscn

# Check for errors
get_godot_errors

# Take screenshots for verification
get_running_scene_screenshot
```

### Verify Each Vehicle:

**Mech Suit:**
- [ ] Slow movement (speed ~100)
- [ ] Can attack while mounted
- [ ] Stomp ability (ui_accept) damages enemies in radius
- [ ] Ability cooldown (3 seconds)
- [ ] Defense bonus applied to player
- [ ] Heavy momentum (slow acceleration/deceleration)

**Car:**
- [ ] Fast movement (speed ~400)
- [ ] Drifting activates when turning at speed
- [ ] Nitro boost (ui_accept) increases speed temporarily
- [ ] Nitro consumes stamina if player has stamina system
- [ ] Cooldown between nitro uses (5 seconds)
- [ ] Cannot attack while mounted

**Airship:**
- [ ] Medium speed (~250)
- [ ] Altitude controls work (Page Up/Down or Space/Ctrl)
- [ ] Shadow scales with altitude
- [ ] Z-index changes with altitude (visual layering)
- [ ] Cannot dismount unless landed (altitude < 10 or on landing pad)
- [ ] Ignores ground collisions when airborne
- [ ] Quick ascend ability works

**Boat:**
- [ ] Medium speed (~200)
- [ ] Wave bobbing animation active
- [ ] Tilts when turning
- [ ] Only moves when in water area (group: "water")
- [ ] Fishing ability (ui_accept) stops boat and starts timer
- [ ] Fishing success/failure after duration
- [ ] Cannot dismount while fishing
- [ ] Shows warning when leaving water

### General Mount/Dismount:
- [ ] Player can approach any vehicle (MountArea detection)
- [ ] Player presses interact (ui_accept near vehicle) to mount
- [ ] Player sprite hidden when mounted
- [ ] Player physics disabled when mounted
- [ ] Vehicle controls override player input
- [ ] Player presses dismount (ui_cancel) to dismount
- [ ] Player sprite shown when dismounted
- [ ] Player positioned safely next to vehicle
- [ ] Each vehicle feels unique and responsive

### Integration Points:
- [ ] Player Controller (S03): Mount/dismount integration works
- [ ] Vehicle Config JSON: Data loaded correctly
- [ ] Each vehicle has appropriate collision layers
- [ ] Water area detection works for boat
- [ ] Abilities use correct input keys

---

## Gotchas & Known Issues

### Godot 4.5 Specific:

**CharacterBody2D:**
- `velocity` is a property, not a parameter to `move_and_slide()`
- Use `move_and_slide()` with no arguments
- Velocity persists between frames automatically

**Area2D Signals:**
- `body_entered` and `body_exited` are reliable for CharacterBody2D detection
- Ensure Area2D is not on the same layer as the vehicle itself

**Collision Layers:**
- Layer 1: World/Ground
- Layer 2: Enemies
- Layer 3: Ground Vehicles (Mech, Car)
- Layer 4: Aerial Vehicles (Airship)
- Layer 5: Water Vehicles (Boat)
- Layer 6: Water Areas

### System-Specific:

**Mech Suit:**
- Stomp ability creates temporary Area2D for damage detection
- Uses `await get_tree().create_timer()` for brief delay
- Knockback requires enemies to have `CharacterBody2D.velocity` property

**Car:**
- Drifting requires lateral friction calculation
- Drift coefficient 0.8 = preserve 80% of sideways velocity
- Nitro boost checks for player stamina system (optional)

**Airship:**
- Altitude is visual only (uses z_index for layering)
- Shadow node is created dynamically in script
- Landing requires altitude < 10 OR detection of landing pad area
- Different collision layer prevents ground collisions

**Boat:**
- MUST be in area with group "water" to move
- Wave physics uses sine wave for bobbing
- Tilt angle affects sprite rotation (visual only)
- Fishing stops all movement during animation

### Integration Warnings:

**Player Sprite Access:**
- Player sprite is `$Sprite` (AnimatedSprite2D)
- Must check if node exists before hiding/showing
- Store original visibility state

**Input Conflicts:**
- ui_accept used for abilities (may conflict with player interact)
- ui_cancel used for dismount
- Consider custom action maps for vehicle controls

**Physics Process:**
- Disable player's `_physics_process` when mounted
- Re-enable on dismount
- Vehicle handles all movement when mounted

**Dismount Safety:**
- Calculate safe dismount position (64px offset)
- Check for collisions before placing player
- Special cases: Airship requires landing, Boat requires water exit

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 CharacterBody2D patterns
- Car steering and drifting mechanics (KidsCanCode)
- 2D Overhead Car Physics: https://github.com/37Rb/godot-overhead-car-2d
- Mount/dismount system patterns (Godot Forums)
- Area2D interaction detection

**Full research notes:** `research/S15-vehicle-system-research.md`

**Key Insights:**
1. Arcade physics preferred over realistic simulation
2. CharacterBody2D works well for all vehicle types
3. Area2D reliable for mount detection
4. Each vehicle needs unique feel through different physics parameters
5. Player integration requires careful state management

---

## Verification Evidence Required

**Tier 2 must provide:**

1. **Screenshots:**
   - Test scene running with all 4 vehicles visible
   - Player mounted in each vehicle type
   - Abilities being used (stomp, nitro, altitude change, fishing)

2. **Error Log:**
   - Output from `get_godot_errors()` - should be empty or only warnings

3. **Gameplay Video/GIF (if possible):**
   - Mount/dismount cycle for each vehicle
   - Each vehicle's unique ability in action
   - Vehicle physics demonstrations (drift, altitude, waves)

4. **Performance Metrics:**
   - Frame time with all vehicles active
   - Memory usage
   - Physics step timing

**Save to:** `evidence/S15-tier2-verification/`

---

## Completion Criteria

**System S15 is complete when:**

✅ **All Scenes Created:**
- mech_suit.tscn with stomp ability
- car.tscn with drifting and nitro
- airship.tscn with altitude control
- boat.tscn with wave physics and fishing
- test_vehicles.tscn with all vehicles and player

✅ **All Scripts Attached:**
- Each vehicle scene has correct script
- Scripts load without errors
- All vehicle types initialize properly

✅ **Mount/Dismount Works:**
- Player can mount any vehicle via interact
- Player sprite hidden when mounted
- Vehicle controls override player
- Dismount works correctly (with special cases)

✅ **Unique Physics Verified:**
- Mech: Slow, heavy movement
- Car: Fast, drifting mechanics
- Airship: Aerial, altitude control
- Boat: Water-only, wave physics

✅ **Abilities Function:**
- Mech stomp damages enemies
- Car nitro boosts speed
- Airship quick ascend works
- Boat fishing catches items

✅ **Integration Complete:**
- Player Controller integration seamless
- Config JSON loads correctly
- Collision layers configured properly
- Water detection works for boat

✅ **Testing Passed:**
- All integration tests pass
- Performance targets met (<1ms per vehicle)
- No critical errors in Godot
- Quality gates score ≥80

✅ **Documentation Complete:**
- Checkpoint markdown created
- Evidence screenshots captured
- Known issues documented (if any)

---

## Next Steps

**After S15 Complete:**

1. **Update COORDINATION-DASHBOARD.md:**
   - Mark S15 as "complete"
   - Release any resource locks
   - Update status for dependent systems

2. **Run Framework Quality Gates:**
   - `IntegrationTestSuite.run_all_tests()`
   - `PerformanceProfiler.profile_system("S15")`
   - `check_quality_gates("S15")`
   - `validate_checkpoint("S15")`

3. **Create Knowledge Base Entry (if applicable):**
   - Document any non-trivial solutions
   - Share patterns for future vehicle types
   - Document integration patterns with player

4. **Unblock Dependent Systems:**
   - Vehicle system is independent (S15)
   - Can run in parallel with: S09, S11, S13, S14, S16, S18
   - No systems blocked by this

5. **Optional Enhancements (Future):**
   - Add more vehicle types (motorcycle, jetpack, submarine)
   - Vehicle damage/repair system
   - Vehicle customization/upgrades
   - Multi-passenger vehicles
   - Vehicle-specific combat moves

---

**HANDOFF STATUS: ✅ READY FOR TIER 2**

**Estimated Tier 2 Time:** 4-5 hours
- Scene creation: 2 hours
- Property configuration: 1 hour
- Testing and debugging: 1.5 hours
- Documentation: 0.5 hour

**Priority:** MEDIUM (independent system, can run in parallel)

**Complexity:** MEDIUM (4 unique vehicles, complex physics interactions)

**Risk Level:** LOW (well-isolated system, no cross-dependencies)

---

*Generated by: Claude Code Web (Tier 1)*
*Date: 2025-11-18*
*Prompt: 017-s15-vehicle-system.md*
*System: S15 - Vehicle System*
*Dependencies: S03 (Player Controller)*
