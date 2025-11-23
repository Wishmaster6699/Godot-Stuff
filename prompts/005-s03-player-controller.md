<objective>
Implement the Player Controller (S03) - a CharacterBody2D-based player character with smooth movement, collision detection, interaction zones, and animation state management. Foundation for all player-driven mechanics.

DEPENDS ON: S02 (Controller Input) must be complete before starting.
CAN RUN IN PARALLEL WITH: S01 (Conductor)
</objective>

<context>
The Player Controller is the player's avatar in the game world. It handles movement physics, collision, interactions with NPCs/items/doors, and animation switching.

Will be extended by:
- **S04**: Combat (combat state)
- **S14**: Tool System (tool usage)
- **S15**: Vehicle System (vehicle mounting)

Reference:
@rhythm-rpg-implementation-guide.md (lines 354-467 for S03 specification)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S03")`
- [ ] Quality gates: `check_quality_gates("S03")`
- [ ] Checkpoint validation: `validate_checkpoint("S03")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S03", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**CRITICAL:** To enable parallel development, you MUST only modify files in your designated directory.

### Your Allowed Directory

**System ID:** S03
**System Name:** Player Controller

**✅ YOU MAY MODIFY:**
```
src/systems/s03-player/              ← ALL your .gd files go here
  player_controller.gd
  player_states.gd
  player_config.json
scenes/s03-player/                   ← ALL your .tscn files go here
  player.tscn
  test_movement.tscn
checkpoints/
  s03-player-checkpoint.md           ← Your checkpoint
research/
  s03-player-research.md             ← Your research
HANDOFF-S03-PLAYER.md                ← Your handoff document
```

**❌ YOU MUST NOT MODIFY:**
- Any other system's directory (`src/systems/s01-*`, `s02-*`, `s04-*`, etc.)
- Core shared files (`src/core/`, `project.godot`)
- Other systems' checkpoints or research files

### Verification Before Commit

```bash
# Check what files you modified
git status

# ✅ GOOD - All files in s03-player
modified:   src/systems/s03-player/player_controller.gd
modified:   HANDOFF-S03-PLAYER.md

# ❌ BAD - Modified other systems!
modified:   src/systems/s02-input/input_manager.gd  # VIOLATION!

# If violations found:
git checkout main -- src/systems/s02-input/  # Revert
```

### If You Need to Modify Shared Files

1. **STOP** - Don't modify the file
2. Post in `COORDINATION-DASHBOARD.md`:
   ```markdown
   ## 🚨 Shared File Modification Request
   **System:** S03 Player Controller
   **File:** src/core/game_manager.gd
   **Reason:** Need to register player with game manager
   ```
3. Wait for developer approval
4. Developer makes the change OR grants permission

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "Godot 4.5 CharacterBody2D best practices 2025"
- "Godot 4.5 smooth movement physics"
- "Godot 4.5 state machine character controller"

## Implementation Tasks

### 1. Player Scene Creation
Create `res://player/player.tscn`:
- Root: CharacterBody2D
- Children: AnimatedSprite2D, CollisionShape2D, InteractionArea (Area2D with CollisionShape2D)

### 2. Player Script
Create `res://player/player.gd`:
- State machine (Idle, Walking, Running, Jumping/if platformer)
- Smooth movement with acceleration/deceleration
- Connect to InputManager for movement input
- Animation switching based on movement state
- Facing direction tracking

### 3. Movement Configuration
Create `res://data/player_config.json`:
```json
{
  "player_config": {
    "movement": {
      "walk_speed": 200,
      "run_speed": 400,
      "acceleration": 800,
      "friction": 1000,
      "jump_force": -500,
      "gravity": 980
    },
    "interaction": {
      "detection_radius": 64
    },
    "animations": {
      "idle": { "frames": 4, "fps": 8 },
      "walk": { "frames": 6, "fps": 12 },
      "run": { "frames": 8, "fps": 16 },
      "jump": { "frames": 4, "fps": 10 }
    },
    "collision": {
      "hitbox_size": { "x": 32, "y": 48 }
    }
  }
}
```

### 4. Interaction System
- InteractionArea (Area2D, 64px radius) detects: NPCs, items, doors, interactables
- Emit signals: `interaction_detected(object)`, `interaction_lost(object)`
- Press interact button (from S02) to trigger interaction

### 5. Animation System
- AnimatedSprite2D with animation library
- Placeholder animations (colored rectangles) if no sprites yet
- States: idle, walk, run, jump (if platformer)
- Smooth transitions between animations

### 6. Test Scene
Create `res://tests/test_movement.tscn`:
- Player instance
- Test obstacles (walls, platforms)
- Test interactables (dummy NPC, dummy item)
- Visual feedback for interaction range

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://player/player.gd` - Complete Player character implementation
   - Full logic with movement, state machine, animations
   - Type hints, documentation, error handling
   - Integration with InputManager (S02)

2. **Create all JSON data files** using the Write tool
   - `res://data/player_config.json` - Movement speeds, stats, animation config
   - Valid JSON format with all required fields

3. **Create HANDOFF-S03.md** documenting:
   - Scene structures needed (player.tscn, test scene)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchy and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://player/player.gd` - Complete Player implementation
- `res://data/player_config.json` - Player configuration data
- `HANDOFF-S03.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S03.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create player.tscn and test_player.tscn
   - `add_node` - Build node hierarchies (AnimatedSprite2D, CollisionShape2D, etc.)
   - `attach_script` - Connect player.gd to player scene
   - `update_property` - Set collision shapes, sprite properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S03.md` with this structure:

```markdown
# System S03 Handoff - Player Controller

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://player/player.gd` - Player CharacterBody2D with state machine, movement physics, animation management, interaction detection

### Data Files
- `res://data/player_config.json` - Movement parameters, interaction radius, animation configuration, collision settings

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://player/player.tscn`

**MCP Agent Commands:**
```bash
# Create player scene
create_scene res://player/player.tscn

# Add player components
add_node res://player/player.tscn AnimatedSprite2D Sprite root
add_node res://player/player.tscn CollisionShape2D Collision root
add_node res://player/player.tscn Area2D InteractionArea root
add_node res://player/player.tscn CollisionShape2D InteractionCollision InteractionArea

# Attach player script
attach_script res://player/player.tscn res://player/player.gd

# Configure properties
update_property res://player/player.tscn root motion_mode 0
update_property res://player/player.tscn Collision shape "RectangleShape2D"
update_property res://player/player.tscn InteractionCollision shape "CircleShape2D"
```

**Node Hierarchy:**
```
Player (CharacterBody2D)
├── Sprite (AnimatedSprite2D) - Player animations
├── Collision (CollisionShape2D) - Hitbox (32x48 rectangle)
└── InteractionArea (Area2D)
    └── InteractionCollision (CollisionShape2D) - Interaction radius (64px circle)
```

**Property Configurations:**
- Player (root): motion_mode = 0 (floating), collision_layer = 1, collision_mask = 1
- Sprite: sprite_frames = [Create SpriteFrames resource with placeholder animations]
- Collision: shape = RectangleShape2D (32x48 from player_config.json)
- InteractionCollision: shape = CircleShape2D (radius 64px from player_config.json)
- InteractionArea: monitoring = true, monitorable = false

### Scene 2: `res://tests/test_movement.tscn`

**MCP Agent Commands:**
```bash
# Create test scene
create_scene res://tests/test_movement.tscn

# Add test environment
add_node res://tests/test_movement.tscn TileMap Ground root
add_node res://tests/test_movement.tscn StaticBody2D Wall1 root
add_node res://tests/test_movement.tscn CollisionShape2D WallCollision Wall1
add_node res://tests/test_movement.tscn StaticBody2D Wall2 root
add_node res://tests/test_movement.tscn CollisionShape2D Wall2Collision Wall2

# Add player instance
add_node res://tests/test_movement.tscn Player TestPlayer root

# Add test interactables
add_node res://tests/test_movement.tscn Area2D DummyNPC root
add_node res://tests/test_movement.tscn CollisionShape2D NPCCollision DummyNPC
add_node res://tests/test_movement.tscn Sprite2D NPCSprite DummyNPC
add_node res://tests/test_movement.tscn Area2D DummyItem root
add_node res://tests/test_movement.tscn CollisionShape2D ItemCollision DummyItem
add_node res://tests/test_movement.tscn Sprite2D ItemSprite DummyItem

# Add UI feedback
add_node res://tests/test_movement.tscn CanvasLayer UI root
add_node res://tests/test_movement.tscn Label StateLabel UI
add_node res://tests/test_movement.tscn Label VelocityLabel UI
add_node res://tests/test_movement.tscn Label InteractionLabel UI

# Configure properties
update_property res://tests/test_movement.tscn TestPlayer position "Vector2(400, 300)"
update_property res://tests/test_movement.tscn Wall1 position "Vector2(200, 300)"
update_property res://tests/test_movement.tscn WallCollision shape "RectangleShape2D"
update_property res://tests/test_movement.tscn Wall2 position "Vector2(600, 300)"
update_property res://tests/test_movement.tscn Wall2Collision shape "RectangleShape2D"
update_property res://tests/test_movement.tscn DummyNPC position "Vector2(400, 150)"
update_property res://tests/test_movement.tscn NPCSprite modulate "Color(0, 1, 0)"
update_property res://tests/test_movement.tscn DummyItem position "Vector2(500, 400)"
update_property res://tests/test_movement.tscn ItemSprite modulate "Color(1, 1, 0)"
update_property res://tests/test_movement.tscn StateLabel position "Vector2(10, 10)"
update_property res://tests/test_movement.tscn VelocityLabel position "Vector2(10, 40)"
update_property res://tests/test_movement.tscn InteractionLabel position "Vector2(10, 70)"
```

**Node Hierarchy:**
```
TestMovement (Node2D)
├── Ground (TileMap) - Test floor/platform
├── Wall1 (StaticBody2D) - Collision test obstacle
│   └── WallCollision (CollisionShape2D)
├── Wall2 (StaticBody2D) - Collision test obstacle
│   └── Wall2Collision (CollisionShape2D)
├── TestPlayer (Player) - Player instance from player.tscn
├── DummyNPC (Area2D) - Test interactable NPC
│   ├── NPCCollision (CollisionShape2D)
│   └── NPCSprite (Sprite2D) - Green square placeholder
├── DummyItem (Area2D) - Test interactable item
│   ├── ItemCollision (CollisionShape2D)
│   └── ItemSprite (Sprite2D) - Yellow square placeholder
└── UI (CanvasLayer)
    ├── StateLabel (Label) - "State: Idle"
    ├── VelocityLabel (Label) - "Velocity: (0, 0)"
    └── InteractionLabel (Label) - "Near: None"
```

**Property Configurations:**
- TestPlayer: Spawns at center of screen
- Wall1/Wall2: Static obstacles to test collision
- DummyNPC: Green square at (400, 150) to test interaction detection
- DummyItem: Yellow square at (500, 400) to test interaction detection
- StateLabel: Display current player state (Idle/Walking/Running)
- VelocityLabel: Display current velocity vector
- InteractionLabel: Display nearby interactables when in range

---

## Integration Points

### Signals Exposed:
- `movement_state_changed(old_state: String, new_state: String)` - State machine transitions
- `interaction_detected(object: Node)` - Object entered interaction range
- `interaction_lost(object: Node)` - Object left interaction range
- `player_interacted(object: Node)` - Interact button pressed while near object

### Public Methods:
- `set_velocity(velocity: Vector2)` - Manually set player velocity
- `change_state(new_state: String)` - Force state change (for cutscenes, etc.)
- `get_current_state() -> String` - Get current state machine state
- `interact()` - Trigger interaction with nearest object
- `get_facing_direction() -> Vector2` - Get normalized facing direction

### Dependencies:
- Depends on: S02 (InputManager for movement input)
- Depended on by: S04, S14, S15

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```bash
# Play test scene
play_scene res://tests/test_movement.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Player moves smoothly in all 4 directions (or 8-directional if using stick)
- [ ] Acceleration feels responsive (0 to max speed in <1 second)
- [ ] Deceleration feels smooth (max speed to 0 when stick released)
- [ ] Player cannot walk through walls (collision detection works)
- [ ] InteractionArea detects DummyNPC when player within 64px
- [ ] InteractionArea detects DummyItem when player within 64px
- [ ] interaction_detected signal emits when entering range
- [ ] interaction_lost signal emits when leaving range
- [ ] Animations switch correctly (idle when stopped, walk when moving slowly, run when moving fast)
- [ ] Facing direction updates based on movement direction
- [ ] State machine transitions correctly (Idle ↔ Walking ↔ Running)
- [ ] Player stops correctly when input released (no sliding)
- [ ] Works with InputManager (S02) for all movement input
- [ ] UI labels update in real-time showing state/velocity/interactions

---

## Notes / Gotchas

- **CharacterBody2D**: Using floating mode (motion_mode = 0) - adjust for platformer vs top-down
- **Interaction Radius**: 64px is configurable in player_config.json - tune for game feel
- **State Machine**: Basic states (Idle, Walking, Running) - S04 will add combat states
- **Animation Placeholders**: Use colored rectangles if no sprites yet (green for idle, blue for walk, red for run)
- **Jump Implementation**: If platformer, add jump state and gravity from player_config.json
- **Integration with S04**: Combat state will be added when S04 (Combat Prototype) integrates

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S03 complete and unblock S04, S14, S15.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S03.md, verify:

### Code Quality
- [ ] player.gd created with complete implementation (no TODOs or placeholders)
- [ ] player_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] State machine logic implemented
- [ ] Movement physics implemented
- [ ] Integration with InputManager (S02) documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (player/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S03.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All movement parameters configurable from player_config.json
- [ ] Animation configurations in JSON
- [ ] State machine states documented
- [ ] Signal parameters documented

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] player.tscn created using `create_scene`
- [ ] All nodes added using `add_node` (AnimatedSprite2D, CollisionShape2D, InteractionArea)
- [ ] player.gd attached using `attach_script`
- [ ] Properties configured using `update_property`
- [ ] test_player.tscn created for testing

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S03")`
- [ ] Quality gates passed: `check_quality_gates("S03")`
- [ ] Checkpoint validated: `validate_checkpoint("S03")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Player moves smoothly in all directions
- [ ] Acceleration/deceleration feels responsive
- [ ] Animations switch correctly based on movement state
- [ ] InteractionArea detects objects within configured radius
- [ ] Collision prevents walking through obstacles
- [ ] Jump feels weighted (if platformer)
- [ ] Player stops correctly when input released
- [ ] Integrates with InputManager (S02) for all input

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ player.gd complete with state machine and movement physics
- ✅ player_config.json complete with all movement parameters
- ✅ All code documented with type hints and comments
- ✅ Integration with InputManager implemented
- ✅ HANDOFF-S03.md provides clear MCP agent instructions
- ✅ All parameters configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Player scene configured correctly in Godot editor
- ✅ Player moves smoothly and responsively
- ✅ State machine transitions work correctly
- ✅ Animations sync with movement
- ✅ Collision and interaction detection work
- ✅ System ready for dependent systems (S04, S14, S15)

</success_criteria>

<memory_checkpoint_format>
```
System S03 (Player Controller) Complete

FILES CREATED:
- res://player/player.tscn (Player CharacterBody2D scene)
- res://player/player.gd (Player controller script)
- res://data/player_config.json (Movement parameters, animations)
- res://tests/test_movement.tscn (Movement test scene)

STATE MACHINE:
- Idle, Walking, Running, Jumping (if platformer)

MOVEMENT PARAMETERS:
- Walk speed: 200px/s
- Run speed: 400px/s
- Acceleration: 800
- Friction: 1000
- Interaction radius: 64px

SIGNALS EXPOSED:
- interaction_detected(object)
- interaction_lost(object)
- movement_state_changed(state)

INTEGRATION:
- Uses InputManager (S02) for movement input
- Ready for S04 (Combat) to extend with combat state
- Ready for S05 (Inventory) to add item pickup
- Ready for S14 (Tools) to add tool usage

STATUS: Ready for S04, S05, S14, S15
```
</memory_checkpoint_format>
