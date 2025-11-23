<objective>
Implement Combat Prototype (S04) - a 1v1 real-time combat system with rhythm-based attacks, enemy telegraphs, dodge/block mechanics, health bars, and win/lose conditions. Foundation for all combat systems.

DEPENDS ON: S01 (Conductor), S02 (Input), S03 (Player) must be complete.
BLOCKS: S05, S06, S07, S08, S09, S10, S11, S12, S13, S19, S21
</objective>

<context>
This is the CORE combat system that all future combat features build upon. It implements:
- 1v1 real-time combat (player vs enemy)
- Rhythm-based attack timing (integrates with S01 Conductor)
- Basic dodge/block mechanics (refined in S09)
- Health system (visualized in S13)
- Combat state management

Reference Combat Specification (002) for exact combat rules.

Reference:
@rhythm-rpg-implementation-guide.md (lines 468-585 for S04 specification)
@combat-specification.md (once prompt 002 completes)
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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S04")`
- [ ] Quality gates: `check_quality_gates("S04")`
- [ ] Checkpoint validation: `validate_checkpoint("S04")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S04", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**CRITICAL:** To enable parallel development, you MUST only modify files in your designated directory.

### Your Allowed Directory

**System ID:** S04
**System Name:** Combat System

**✅ YOU MAY MODIFY:**
```
src/systems/s04-combat/              ← ALL your .gd files go here
  combat_manager.gd
  combatant.gd
  attack_system.gd
  combat_config.json
scenes/s04-combat/                   ← ALL your .tscn files go here
  combat_arena.tscn
  health_bar.tscn
checkpoints/
  s04-combat-checkpoint.md           ← Your checkpoint
research/
  s04-combat-research.md             ← Your research
HANDOFF-S04-COMBAT.md                ← Your handoff document
```

**❌ YOU MUST NOT MODIFY:**
- Any other system's directory (`src/systems/s01-*`, `s02-*`, `s03-*`, etc.)
- Core shared files (`src/core/`, `project.godot`)
- Other systems' checkpoints or research files

### Verification Before Commit

```bash
# Check what files you modified
git status

# ✅ GOOD - All files in s04-combat
modified:   src/systems/s04-combat/combat_manager.gd
modified:   HANDOFF-S04-COMBAT.md

# ❌ BAD - Modified other systems!
modified:   src/systems/s03-player/player_controller.gd  # VIOLATION!

# If violations found:
git checkout main -- src/systems/s03-player/  # Revert
```

### If You Need to Modify Shared Files

1. **STOP** - Don't modify the file
2. Post in `COORDINATION-DASHBOARD.md`:
   ```markdown
   ## 🚨 Shared File Modification Request
   **System:** S04 Combat System
   **File:** src/core/game_manager.gd
   **Reason:** Need to register combat with game manager
   ```
3. Wait for developer approval
4. Developer makes the change OR grants permission

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research First
- "Godot 4.5 combat system architecture 2025"
- "Godot 4.5 state machine combat"
- "Godot damage calculation system"

## Implementation Tasks

### 1. Combat Arena Scene
Create `res://combat/combat_arena.tscn`:
- Combat container scene
- Player spawn point
- Enemy spawn point
- Camera positioning

### 2. Combatant Base Class
Create `res://combat/combatant.gd` (base class for Player and Enemy):
```gdscript
extends CharacterBody2D
class_name Combatant

var stats = {
  "max_hp": 100,
  "current_hp": 100,
  "damage": 10,
  "defense": 5
}

func take_damage(amount: int, timing_quality: String = "good"):
  # Apply damage with timing multiplier
  pass

func heal(amount: int):
  # Restore HP
  pass
```

### 3. Attack System
- Listen for Conductor.downbeat signal (from S01)
- Listen for InputManager lane_pressed (from S02)
- Calculate damage: `(Attack - Defense) * weapon_modifier * timing_multiplier`
- Timing multipliers from Combat Specification (Perfect 2x, Good 1.5x, Miss 0.5x)

### 4. Enemy Telegraph System
- Visual cue appears 1 beat before enemy attacks
- Color flash or indicator above enemy
- Player must dodge/block when attack lands

### 5. Dodge/Block Placeholder
- Dodge button (from S02): 0.2s invulnerability window
- Block button (from S02): 50% damage reduction
- (Will be refined in S09)

### 6. Health Bars
Create `res://combat/ui/health_bar.tscn`:
- TextureProgressBar for visual HP
- Updates in real-time as damage taken
- (Color-shift will be added in S13)

### 7. Combat Configuration
Create `res://data/combat_config.json`:
```json
{
  "combat_config": {
    "base_damage": 10,
    "timing_damage_multipliers": {
      "perfect": 2.0,
      "good": 1.5,
      "miss": 0.5
    },
    "dodge": {
      "window_duration_s": 0.2,
      "invulnerability_frames": 10
    },
    "block": {
      "damage_reduction": 0.5
    },
    "health_bars": {
      "player_max_hp": 100,
      "enemy_max_hp": 50
    },
    "telegraph": {
      "display_duration_beats": 1,
      "visual_cue_color": "#FFFF00"
    }
  }
}
```

### 8. Win/Lose Conditions
- Win: Enemy HP <= 0
- Lose: Player HP <= 0
- Emit signals: `combat_ended(winner: String)`

### 9. Test Scene
Create `res://tests/test_combat.tscn`:
- Combat arena
- Player vs dummy enemy
- Visual feedback for attacks, damage, timing quality

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://combat/combatant.gd` - Base Combatant class with stats and damage calculations
   - `res://combat/combat_manager.gd` - Combat state management and signal coordination
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Conductor (S01), InputManager (S02), Player (S03)

2. **Create all JSON data files** using the Write tool
   - `res://data/combat_config.json` - Combat parameters, timing multipliers, dodge/block settings
   - Valid JSON format with all required fields

3. **Create HANDOFF-S04.md** documenting:
   - Scene structures needed (combat arena, health bars, test scene)
   - MCP agent tasks (use GDAI tools)
   - Node hierarchies and property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://combat/combatant.gd` - Complete Combatant base class
- `res://combat/combat_manager.gd` - Combat orchestration
- `res://data/combat_config.json` - Combat configuration data
- `HANDOFF-S04.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S04.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create combat_arena.tscn, health_bar.tscn, test_combat.tscn
   - `add_node` - Build node hierarchies (CharacterBody2D, CollisionShape2D, UI elements)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties, collision shapes, UI positions
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S04.md` with this structure:

```markdown
# System S04 Handoff - Combat Prototype

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://combat/combatant.gd` - Base Combatant class with stats, damage calculation, health management
- `res://combat/combat_manager.gd` - Combat orchestration, state management, signal coordination

### Data Files
- `res://data/combat_config.json` - Combat parameters, timing multipliers, dodge/block settings, health configuration

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://combat/combat_arena.tscn`

**MCP Agent Commands:**
```bash
# Create combat arena scene
create_scene res://combat/combat_arena.tscn

# Add combat manager
add_node res://combat/combat_arena.tscn Node2D CombatManager root

# Add spawn points
add_node res://combat/combat_arena.tscn Marker2D PlayerSpawn root
add_node res://combat/combat_arena.tscn Marker2D EnemySpawn root

# Add camera
add_node res://combat/combat_arena.tscn Camera2D CombatCamera root

# Attach combat manager script
attach_script res://combat/combat_arena.tscn/CombatManager res://combat/combat_manager.gd

# Configure properties
update_property res://combat/combat_arena.tscn PlayerSpawn position "Vector2(200, 300)"
update_property res://combat/combat_arena.tscn EnemySpawn position "Vector2(600, 300)"
update_property res://combat/combat_arena.tscn CombatCamera position "Vector2(400, 300)"
update_property res://combat/combat_arena.tscn CombatCamera zoom "Vector2(1.0, 1.0)"
```

**Node Hierarchy:**
```
CombatArena (Node2D)
├── CombatManager (Node2D) - Combat orchestration script
├── PlayerSpawn (Marker2D) - Player spawn position
├── EnemySpawn (Marker2D) - Enemy spawn position
└── CombatCamera (Camera2D) - Fixed combat camera
```

**Property Configurations:**
- PlayerSpawn: Position at left side of screen (200, 300)
- EnemySpawn: Position at right side of screen (600, 300)
- CombatCamera: Centered at (400, 300), zoom 1.0
- CombatManager: Handles combat state machine, listens to Conductor downbeat signals

### Scene 2: `res://combat/ui/health_bar.tscn`

**MCP Agent Commands:**
```bash
# Create health bar UI component
create_scene res://combat/ui/health_bar.tscn

# Add UI elements
add_node res://combat/ui/health_bar.tscn Panel Background root
add_node res://combat/ui/health_bar.tscn TextureProgressBar HealthBar Background
add_node res://combat/ui/health_bar.tscn Label HPLabel Background

# Configure properties
update_property res://combat/ui/health_bar.tscn Background custom_minimum_size "Vector2(200, 30)"
update_property res://combat/ui/health_bar.tscn HealthBar min_value 0
update_property res://combat/ui/health_bar.tscn HealthBar max_value 100
update_property res://combat/ui/health_bar.tscn HealthBar value 100
update_property res://combat/ui/health_bar.tscn HealthBar size "Vector2(180, 20)"
update_property res://combat/ui/health_bar.tscn HealthBar position "Vector2(10, 5)"
update_property res://combat/ui/health_bar.tscn HealthBar tint_progress "Color(0, 1, 0)"
update_property res://combat/ui/health_bar.tscn HPLabel text "100 / 100"
update_property res://combat/ui/health_bar.tscn HPLabel position "Vector2(60, 7)"
```

**Node Hierarchy:**
```
HealthBar (Control)
└── Background (Panel)
    ├── HealthBar (TextureProgressBar) - Visual HP bar (green → yellow → red)
    └── HPLabel (Label) - "100 / 100" text display
```

**Property Configurations:**
- HealthBar: min=0, max=100, value=100, tint_progress=green
- HPLabel: Shows "current_hp / max_hp" text
- Background: 200x30 panel container

### Scene 3: `res://tests/test_combat.tscn`

**MCP Agent Commands:**
```bash
# Create test combat scene
create_scene res://tests/test_combat.tscn

# Instantiate combat arena
add_node res://tests/test_combat.tscn Node2D Arena root

# Add player combatant
add_node res://tests/test_combat.tscn CharacterBody2D Player Arena
add_node res://tests/test_combat.tscn CollisionShape2D PlayerCollision Player
add_node res://tests/test_combat.tscn Sprite2D PlayerSprite Player

# Add enemy combatant
add_node res://tests/test_combat.tscn CharacterBody2D Enemy Arena
add_node res://tests/test_combat.tscn CollisionShape2D EnemyCollision Enemy
add_node res://tests/test_combat.tscn Sprite2D EnemySprite Enemy

# Add UI layer
add_node res://tests/test_combat.tscn CanvasLayer CombatUI root
add_node res://tests/test_combat.tscn Control PlayerHealthBar CombatUI
add_node res://tests/test_combat.tscn Control EnemyHealthBar CombatUI

# Add telegraph indicator
add_node res://tests/test_combat.tscn ColorRect TelegraphIndicator Enemy

# Add combat feedback
add_node res://tests/test_combat.tscn Label TimingQualityLabel CombatUI
add_node res://tests/test_combat.tscn Label CombatStateLabel CombatUI
add_node res://tests/test_combat.tscn Label DamageLabel CombatUI

# Attach combatant scripts
attach_script res://tests/test_combat.tscn/Arena/Player res://combat/combatant.gd
attach_script res://tests/test_combat.tscn/Arena/Enemy res://combat/combatant.gd

# Configure properties
update_property res://tests/test_combat.tscn Player position "Vector2(200, 300)"
update_property res://tests/test_combat.tscn PlayerSprite modulate "Color(0, 0, 1)"
update_property res://tests/test_combat.tscn Enemy position "Vector2(600, 300)"
update_property res://tests/test_combat.tscn EnemySprite modulate "Color(1, 0, 0)"
update_property res://tests/test_combat.tscn TelegraphIndicator size "Vector2(80, 20)"
update_property res://tests/test_combat.tscn TelegraphIndicator position "Vector2(-40, -60)"
update_property res://tests/test_combat.tscn TelegraphIndicator color "Color(1, 1, 0, 0)"
update_property res://tests/test_combat.tscn PlayerHealthBar position "Vector2(10, 10)"
update_property res://tests/test_combat.tscn EnemyHealthBar position "Vector2(590, 10)"
update_property res://tests/test_combat.tscn TimingQualityLabel position "Vector2(350, 550)"
update_property res://tests/test_combat.tscn CombatStateLabel position "Vector2(10, 550)"
update_property res://tests/test_combat.tscn DamageLabel position "Vector2(350, 50)"
```

**Node Hierarchy:**
```
TestCombat (Node2D)
├── Arena (Node2D)
│   ├── Player (CharacterBody2D) - Blue player combatant
│   │   ├── PlayerCollision (CollisionShape2D)
│   │   └── PlayerSprite (Sprite2D)
│   └── Enemy (CharacterBody2D) - Red enemy combatant
│       ├── EnemyCollision (CollisionShape2D)
│       ├── EnemySprite (Sprite2D)
│       └── TelegraphIndicator (ColorRect) - Yellow flash warning
└── CombatUI (CanvasLayer)
    ├── PlayerHealthBar (Control) - Player HP bar (top left)
    ├── EnemyHealthBar (Control) - Enemy HP bar (top right)
    ├── TimingQualityLabel (Label) - "Perfect! 2x Damage"
    ├── CombatStateLabel (Label) - "State: Player Turn"
    └── DamageLabel (Label) - "20 damage dealt!"
```

**Property Configurations:**
- Player: Blue combatant at (200, 300), max_hp=100, damage=10
- Enemy: Red combatant at (600, 300), max_hp=50, damage=8
- TelegraphIndicator: Flashes yellow 1 beat before enemy attacks
- TimingQualityLabel: Shows "Perfect!" / "Good" / "Miss" based on timing
- CombatStateLabel: Shows current combat state (Idle/PlayerTurn/EnemyTurn/Ended)
- DamageLabel: Shows damage numbers when attacks land

---

## Integration Points

### Signals Exposed:
- `attack_landed(damage: int, timing_quality: String)` - Attack successfully hit target
- `damage_taken(amount: int)` - Combatant took damage
- `health_changed(current_hp: int, max_hp: int)` - HP changed
- `combat_ended(winner: String)` - Combat finished ("player" or "enemy")
- `telegraph_started()` - Enemy telegraph warning displayed
- `dodge_activated()` - Dodge i-frames activated
- `block_activated()` - Block damage reduction active

### Public Methods (Combatant):
- `take_damage(amount: int, timing_quality: String = "good")` - Apply damage with timing multiplier
- `heal(amount: int)` - Restore HP
- `attack(target: Combatant)` - Execute attack on target
- `dodge()` - Activate dodge i-frames (0.2s invulnerability)
- `block()` - Activate block (50% damage reduction)
- `get_stats() -> Dictionary` - Get current stats (hp, damage, defense)

### Public Methods (CombatManager):
- `start_combat(player: Combatant, enemy: Combatant)` - Initialize combat
- `end_combat(winner: String)` - End combat and emit results
- `get_combat_state() -> String` - Get current combat state

### Dependencies:
- Depends on: S01 (Conductor for downbeat timing), S02 (InputManager for combat input), S03 (Player as combatant)
- Depended on by: S05, S06, S07, S08, S09, S10, S11, S12, S13, S19, S21

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```bash
# Play test scene
play_scene res://tests/test_combat.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] Combat arena loads without errors
- [ ] Player and Enemy combatants spawn at correct positions
- [ ] Health bars display correctly (100/100 for player, 50/50 for enemy)
- [ ] Conductor downbeat signal triggers combat turns
- [ ] Player can attack by pressing lane button on downbeat
- [ ] Attack damage scaled by timing quality (Perfect=2x, Good=1.5x, Miss=0.5x)
- [ ] Timing quality label shows "Perfect!"/"Good"/"Miss" based on input timing
- [ ] Enemy telegraphs attacks 1 beat before execution (yellow flash appears)
- [ ] Player can dodge enemy attacks (press dodge button during telegraph)
- [ ] Dodge grants 0.2s invulnerability (i-frames work correctly)
- [ ] Player can block enemy attacks (press block button during telegraph)
- [ ] Block reduces damage by 50%
- [ ] Health bars decrease visually when damage taken
- [ ] Damage numbers display when attacks land
- [ ] Combat ends when player HP <= 0 or enemy HP <= 0
- [ ] combat_ended signal emits with correct winner ("player" or "enemy")
- [ ] Win/lose conditions trigger correctly
- [ ] System handles rapid input (no timing exploits or double-hits)
- [ ] Integrates with Conductor (S01) for rhythm timing
- [ ] Integrates with InputManager (S02) for combat input
- [ ] Works with Player (S03) as combatant

---

## Notes / Gotchas

- **Rhythm Timing Integration**: Attacks must land on downbeat - use Conductor.downbeat signal
- **Timing Multipliers**: Perfect window = ±50ms, Good window = ±100ms from beat (configurable in combat_config.json)
- **Telegraph System**: Enemy attacks must warn 1 beat before execution - critical for player reaction time
- **Dodge i-frames**: 0.2s invulnerability = ~12 frames at 60fps - tune if too forgiving/punishing
- **Damage Formula**: `(Attack - Defense) * weapon_modifier * timing_multiplier` - ensure Defense doesn't negate all damage
- **Health Bar Color**: Will shift from green → yellow → red in S13 (Health/Stamina Visualization)
- **Enemy AI**: Currently dummy/scripted - S11 (Enemy AI) will add behavior trees
- **Combat State Machine**: Idle → PlayerTurn → EnemyTurn → Ended (basic loop for now)
- **Integration with S07**: Weapons system will extend damage calculation with weapon modifiers
- **Integration with S09**: Dodge/Block system will refine mechanics with stamina costs and better timing windows

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S04 complete and unblock S05, S06, S07, S08, S09, S10, S11, S12, S13, S19, S21.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S04.md, verify:

### Code Quality
- [ ] All .gd files created with complete implementations (no TODOs or placeholders)
- [ ] combat_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (combat/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S04.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] Combatant base class with stats, take_damage(), heal()
- [ ] Combat manager with state machine (idle, player_turn, enemy_turn, ended)
- [ ] Damage formula implemented with timing multipliers
- [ ] Telegraph system logic implemented
- [ ] Dodge/block mechanics implemented
- [ ] Win/lose condition logic implemented
- [ ] All combat parameters configurable from combat_config.json

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties set using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S04")`
- [ ] Quality gates passed: `check_quality_gates("S04")`
- [ ] Checkpoint validated: `validate_checkpoint("S04")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Player can attack by pressing lane button on downbeat
- [ ] Attack damage scaled by timing quality (Perfect/Good/Miss)
- [ ] Enemy telegraphs attacks 1 beat before execution
- [ ] Player can dodge enemy attacks (i-frames work)
- [ ] Health bars decrease when damage taken
- [ ] Combat ends when HP <= 0
- [ ] Win/lose conditions trigger correctly
- [ ] System handles rapid input (no timing exploits)
- [ ] Integrates with Conductor (S01) for rhythm timing
- [ ] Integrates with InputManager (S02) for input

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ All GDScript implementations complete and documented
- ✅ combat_config.json complete with all combat parameters
- ✅ HANDOFF-S04.md provides clear MCP agent instructions
- ✅ Damage formula and timing multipliers implemented
- ✅ Integration patterns documented for S01, S02, S03

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Combat arena scenes configured correctly in Godot editor
- ✅ 1v1 combat works with rhythm-based attacks
- ✅ Enemy telegraph system warns 1 beat before attacks
- ✅ Dodge/block mechanics reduce/prevent damage
- ✅ Health bars update correctly
- ✅ Win/lose conditions trigger appropriately
- ✅ All verification criteria pass
- ✅ System ready for dependent systems (S05-S13, S19, S21)

</success_criteria>

<memory_checkpoint_format>
```
System S04 (Combat Prototype) Complete

FILES CREATED:
- res://combat/combat_arena.tscn (Combat container scene)
- res://combat/combatant.gd (Base class for Player and Enemy)
- res://combat/ui/health_bar.tscn (Health bar UI)
- res://data/combat_config.json (Combat parameters)
- res://tests/test_combat.tscn (Combat test scene)

COMBAT FEATURES:
- 1v1 real-time combat
- Rhythm-based attacks (downbeat synchronization)
- Enemy telegraph system (1 beat warning)
- Dodge (0.2s i-frames)
- Block (50% damage reduction)
- Win/lose conditions

DAMAGE FORMULA:
Damage = (Attack - Defense) * weapon_modifier * timing_multiplier

TIMING MULTIPLIERS:
- Perfect: 2.0x
- Good: 1.5x
- Miss: 0.5x

SIGNALS EXPOSED:
- attack_landed(damage, timing_quality)
- damage_taken(amount)
- combat_ended(winner)

INTEGRATION:
- Uses Conductor (S01) for downbeat timing
- Uses InputManager (S02) for combat input
- Uses Player (S03) as combatant
- Ready for S07 (Weapons) to extend damage calculation
- Ready for S08 (Equipment) to add stat bonuses
- Ready for S09 (Dodge/Block) to refine mechanics
- Ready for S11 (Enemy AI) to add behavior trees

STATUS: Ready for S07, S08, S09, S10, S11, S12, S13
```
</memory_checkpoint_format>
