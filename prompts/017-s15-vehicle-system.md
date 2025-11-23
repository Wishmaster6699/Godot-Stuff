<objective>
Implement Vehicle System (S15) - 4 vehicles (Mech Suit, Car, Airship, Boat) with unique physics, context-based activation, and vehicle-specific abilities.

DEPENDS ON: S03 (Player Controller)
CAN RUN IN PARALLEL WITH: S09, S11, S13, S14, S16, S18
</objective>

<context>
Vehicles provide alternative traversal and combat options. Each vehicle has unique physics and abilities. Vehicles are mounted/dismounted contextually.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S15")`
- [ ] Quality gates: `check_quality_gates("S15")`
- [ ] Checkpoint validation: `validate_checkpoint("S15")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S15", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Web Research
- "Godot vehicle physics"
- "Godot mount/dismount system"
- "Top-down vehicle movement"

## Implementation

### 1. Vehicle Base Class
Create `res://vehicles/vehicle_base.gd` (extends CharacterBody2D):
```gdscript
class_name Vehicle

var mounted = false
var max_speed = 300
var acceleration = 500
```

### 2. Mech Suit
Create `res://vehicles/mech_suit.gd`:
- Slow (speed: 100)
- High defense (+50)
- Can attack while mounted
- Stomp ability (AoE damage)

### 3. Car
Create `res://vehicles/car.gd`:
- Fast (speed: 400)
- Drifting mechanic (hold drift button)
- Cannot attack
- Nitro boost (stamina cost)

### 4. Airship
Create `res://vehicles/airship.gd`:
- Aerial movement (ignores ground collision)
- Altitude control (up/down)
- Cannot attack
- Landing pads required

### 5. Boat
Create `res://vehicles/boat.gd`:
- Water-only
- Wave physics (bob/tilt)
- Fishing ability
- Medium speed (200)

### 6. Mount/Dismount
- Proximity trigger (Area2D)
- Press interact button
- Player sprite hidden when mounted
- Vehicle controls override player controls

### 7. Vehicle Configuration
Create `res://data/vehicles_config.json`:
```json
{
  "vehicles": {
    "mech_suit": {
      "max_speed": 100,
      "defense_bonus": 50,
      "can_attack": true,
      "abilities": ["stomp_aoe"]
    },
    "car": {
      "max_speed": 400,
      "drift_coefficient": 0.8,
      "nitro_duration_s": 2.0
    }
  }
}
```

### 8. Test Scene
- One of each vehicle
- Test areas (roads, water, cliffs)
- Mount/dismount testing

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://vehicles/vehicle_base.gd` - Base vehicle class with mount/dismount logic
   - Individual vehicle scripts (mech_suit.gd, car.gd, airship.gd, boat.gd)
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Player (S03)

2. **Create all JSON data files** using the Write tool
   - `res://data/vehicles_config.json` - Vehicle parameters, abilities, physics
   - Valid JSON format with all required fields

3. **Create HANDOFF-S15.md** documenting:
   - Scene structures needed (vehicle scenes, test environment)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- Vehicle scripts (base class + 4 individual vehicles)
- `res://data/vehicles_config.json` - Configuration data
- `HANDOFF-S15.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S15.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create vehicle scenes, test_vehicles.tscn
   - `add_node` - Build node hierarchies (vehicle nodes, physics components, Area2D triggers)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set vehicle properties, physics parameters
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S15.md` with this structure:

```markdown
# HANDOFF: S15 - Vehicle System

## Files Created by Claude Code Web

### GDScript Files
- `res://vehicles/vehicle_base.gd` - Base vehicle class (CharacterBody2D)
- `res://vehicles/mech_suit.gd` - Mech suit vehicle with stomp ability
- `res://vehicles/car.gd` - Car vehicle with drifting and nitro
- `res://vehicles/airship.gd` - Airship with altitude control
- `res://vehicles/boat.gd` - Boat with wave physics

### Data Files
- `res://data/vehicles_config.json` - Vehicle parameters (speed, abilities, physics)

## MCP Agent Tasks

### 1. Create Vehicle Scenes

```bash
# Create mech suit scene
create_scene res://vehicles/mech_suit.tscn
add_node res://vehicles/mech_suit.tscn CharacterBody2D MechSuit root
add_node res://vehicles/mech_suit.tscn Sprite2D Sprite MechSuit
add_node res://vehicles/mech_suit.tscn CollisionShape2D Collision MechSuit
add_node res://vehicles/mech_suit.tscn Area2D MountArea MechSuit
add_node res://vehicles/mech_suit.tscn CollisionShape2D TriggerShape MountArea
attach_script res://vehicles/mech_suit.tscn MechSuit res://vehicles/mech_suit.gd

# Create car scene
create_scene res://vehicles/car.tscn
add_node res://vehicles/car.tscn CharacterBody2D Car root
add_node res://vehicles/car.tscn Sprite2D Sprite Car
add_node res://vehicles/car.tscn CollisionShape2D Collision Car
add_node res://vehicles/car.tscn Area2D MountArea Car
add_node res://vehicles/car.tscn CollisionShape2D TriggerShape MountArea
attach_script res://vehicles/car.tscn Car res://vehicles/car.gd

# Create airship scene
create_scene res://vehicles/airship.tscn
add_node res://vehicles/airship.tscn CharacterBody2D Airship root
add_node res://vehicles/airship.tscn Sprite2D Sprite Airship
add_node res://vehicles/airship.tscn CollisionShape2D Collision Airship
add_node res://vehicles/airship.tscn Area2D MountArea Airship
add_node res://vehicles/airship.tscn CollisionShape2D TriggerShape MountArea
attach_script res://vehicles/airship.tscn Airship res://vehicles/airship.gd

# Create boat scene
create_scene res://vehicles/boat.tscn
add_node res://vehicles/boat.tscn CharacterBody2D Boat root
add_node res://vehicles/boat.tscn Sprite2D Sprite Boat
add_node res://vehicles/boat.tscn CollisionShape2D Collision Boat
add_node res://vehicles/boat.tscn Area2D MountArea Boat
add_node res://vehicles/boat.tscn CollisionShape2D TriggerShape MountArea
attach_script res://vehicles/boat.tscn Boat res://vehicles/boat.gd
```

### 2. Configure Vehicle Properties

```bash
# Mech suit properties
update_property res://vehicles/mech_suit.tscn MechSuit max_speed 100
update_property res://vehicles/mech_suit.tscn MechSuit defense_bonus 50
update_property res://vehicles/mech_suit.tscn Collision shape "CircleShape2D(radius=32)"

# Car properties
update_property res://vehicles/car.tscn Car max_speed 400
update_property res://vehicles/car.tscn Car drift_coefficient 0.8
update_property res://vehicles/car.tscn Collision shape "RectangleShape2D(size=Vector2(48,32))"

# Airship properties
update_property res://vehicles/airship.tscn Airship max_speed 250
update_property res://vehicles/airship.tscn Airship max_altitude 500
update_property res://vehicles/airship.tscn Collision shape "CircleShape2D(radius=40)"

# Boat properties
update_property res://vehicles/boat.tscn Boat max_speed 200
update_property res://vehicles/boat.tscn Boat wave_amplitude 10
update_property res://vehicles/boat.tscn Collision shape "RectangleShape2D(size=Vector2(64,40))"

# Mount areas for all vehicles
update_property res://vehicles/mech_suit.tscn TriggerShape shape "CircleShape2D(radius=48)"
update_property res://vehicles/car.tscn TriggerShape shape "CircleShape2D(radius=48)"
update_property res://vehicles/airship.tscn TriggerShape shape "CircleShape2D(radius=48)"
update_property res://vehicles/boat.tscn TriggerShape shape "CircleShape2D(radius=48)"
```

### 3. Create Test Scene

```bash
create_scene res://tests/test_vehicles.tscn
add_node res://tests/test_vehicles.tscn Node2D TestVehicles root
add_node res://tests/test_vehicles.tscn TileMap Terrain TestVehicles
add_node res://tests/test_vehicles.tscn MechSuit MechSuit TestVehicles res://vehicles/mech_suit.tscn
add_node res://tests/test_vehicles.tscn Car Car TestVehicles res://vehicles/car.tscn
add_node res://tests/test_vehicles.tscn Airship Airship TestVehicles res://vehicles/airship.tscn
add_node res://tests/test_vehicles.tscn Boat Boat TestVehicles res://vehicles/boat.tscn

# Position vehicles in test scene
update_property res://tests/test_vehicles.tscn MechSuit position "Vector2(100, 100)"
update_property res://tests/test_vehicles.tscn Car position "Vector2(300, 100)"
update_property res://tests/test_vehicles.tscn Airship position "Vector2(500, 100)"
update_property res://tests/test_vehicles.tscn Boat position "Vector2(700, 100)"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_vehicles.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] All vehicle scenes load without errors
- [ ] Mech suit: Slow movement, stomp ability works
- [ ] Car: Fast movement, drifting and nitro work
- [ ] Airship: Altitude controls work, ignores ground collision
- [ ] Boat: Water detection works, wave physics active
- [ ] Mount/dismount works for all vehicles (proximity trigger + interact)
- [ ] Player sprite hidden when mounted
- [ ] Vehicle controls override player input correctly
- [ ] Each vehicle has unique physics feel

### Integration Points:
- **S03 (Player Controller)**: Mount/dismount, control override
- **Vehicle Config**: JSON data loaded correctly
- **Physics**: Each vehicle has appropriate physics behavior

## Completion

When testing passes:
1. Update `COORDINATION-DASHBOARD.md`:
   - Mark S15 as "complete"
   - Release any resource locks
   - Unblock dependent systems
2. Run framework quality gates:
   - `IntegrationTestSuite.run_all_tests()`
   - `PerformanceProfiler.profile_system("S15")`
   - `check_quality_gates("S15")`
   - `validate_checkpoint("S15")`
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S15.md, verify:

### Code Quality
- [ ] vehicle_base.gd created with complete implementation (no TODOs or placeholders)
- [ ] All vehicle scripts created (mech_suit.gd, car.gd, airship.gd, boat.gd)
- [ ] vehicles_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling for mount/dismount and vehicle control

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (vehicles/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S15.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used

### System-Specific Verification (File Creation)
- [ ] Vehicle base class with mount/dismount logic
- [ ] Mech suit with stomp ability implementation
- [ ] Car with drifting and nitro boost mechanics
- [ ] Airship with altitude control logic
- [ ] Boat with wave physics implementation
- [ ] Vehicle configuration data complete in JSON
- [ ] Integration with Player (S03) documented

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S15")`
- [ ] Quality gates passed: `check_quality_gates("S15")`
- [ ] Checkpoint validated: `validate_checkpoint("S15")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Vehicle base class instantiates correctly
- [ ] Mech Suit: Slow movement (100 speed), high defense (+50), stomp ability works
- [ ] Car: Fast movement (400 speed), drifting works, nitro boost activates
- [ ] Airship: Aerial movement works, altitude control up/down, ignores ground collision
- [ ] Boat: Water-only detection works, wave physics bob/tilt active
- [ ] Mount/dismount on interact button (proximity trigger)
- [ ] Player sprite hidden when mounted
- [ ] Vehicle controls override player input correctly
- [ ] Integration with Player (S03) works correctly
- [ ] Each vehicle has unique physics feel

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ vehicle_base.gd complete with mount/dismount system
- ✅ mech_suit.gd complete with stomp ability
- ✅ car.gd complete with drifting and nitro mechanics
- ✅ airship.gd complete with altitude control
- ✅ boat.gd complete with wave physics
- ✅ vehicles_config.json complete with all vehicle parameters
- ✅ HANDOFF-S15.md provides clear MCP agent instructions
- ✅ Integration patterns documented for S03 (Player)
- ✅ All vehicle types implemented with unique mechanics

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ All vehicle scenes configured correctly in Godot editor
- ✅ Mech suit physics and stomp ability work
- ✅ Car drifting and nitro boost work correctly
- ✅ Airship altitude control and aerial movement work
- ✅ Boat water detection and wave physics work
- ✅ Mount/dismount system works for all vehicles
- ✅ Player sprite visibility toggle works
- ✅ Vehicle control override works correctly
- ✅ Integration with Player (S03) works
- ✅ All verification criteria pass
- ✅ Each vehicle feels unique and responsive

</success_criteria>

<memory_checkpoint_format>
```
System S15 (Vehicle System) Complete

FILES:
- res://vehicles/vehicle_base.gd
- res://vehicles/mech_suit.gd
- res://vehicles/car.gd
- res://vehicles/airship.gd
- res://vehicles/boat.gd
- res://data/vehicles_config.json
- res://tests/test_vehicles.tscn

VEHICLES:
- Mech Suit: Slow, combat-capable, stomp AoE
- Car: Fast, drifting, nitro boost
- Airship: Aerial, altitude control
- Boat: Water traversal, wave physics

MOUNT/DISMOUNT:
- Context-based (proximity trigger)
- Player sprite hidden when mounted

STATUS: Traversal vehicles complete
```
</memory_checkpoint_format>
