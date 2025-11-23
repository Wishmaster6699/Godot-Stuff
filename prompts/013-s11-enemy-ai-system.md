<objective>
Implement Enemy AI System (S11) using LimboAI behavior trees with states (Patrol, Chase, Attack, Retreat, Stun), telegraphed attacks, type-based variations, and difficulty scaling.

DEPENDS ON: S04 (Combat/Combatant base class)
CAN RUN IN PARALLEL WITH: S09, S13, S14, S15, S16, S18
</objective>

<context>
The Enemy AI uses LimboAI plugin for behavior trees. All enemies extend Combatant (from S04) and use behavior trees for decision-making.

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
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S11")`
- [ ] Quality gates: `check_quality_gates("S11")`
- [ ] Checkpoint validation: `validate_checkpoint("S11")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S11", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<file_isolation>

## 🚨 FILE ISOLATION RULES - PREVENT MERGE CONFLICTS

**System ID:** S11 | **System Name:** Enemy AI

**✅ YOU MAY MODIFY:**
```
src/systems/s11-enemyai/
scenes/s11-enemyai/
checkpoints/s11-enemyai-checkpoint.md
research/s11-enemyai-research.md
HANDOFF-S11-ENEMYAI.md
```

**❌ YOU MUST NOT MODIFY:** Other systems' directories, `src/core/`, `project.godot`

**See `GIT-WORKFLOW.md` for complete file isolation rules.**

</file_isolation>

<requirements>

## Web Research
- "LimboAI Godot 4.5 tutorial"
- "Godot behavior tree enemy AI"
- Visit: https://github.com/limbonaut/limboai

## Implementation

### 1. Install LimboAI Plugin
- Clone or download LimboAI
- Enable in Project Settings

### 2. Enemy Base Class
Create `res://enemies/enemy_base.gd` (extends Combatant from S04):
```gdscript
extends Combatant
class_name Enemy

@onready var behavior_tree = $BehaviorTree
var state = "patrol"  # patrol, chase, attack, retreat, stun
```

### 3. Behavior Tree Setup
States:
- **Patrol**: Wander random points
- **Chase**: Move toward player if detected
- **Attack**: Execute attack when in range
- **Retreat**: Low HP (<20%), run away
- **Stun**: Hit by stun effect, immobile

### 4. Telegraph System
Before attacks:
- Visual cue (red flash) 1 beat before
- Audio cue (charging sound)
- Telegraph duration from Conductor

### 5. AI Configuration
Create `res://data/enemy_ai_config.json`:
```json
{
  "ai_config": {
    "detection_range": 200,
    "attack_range": 64,
    "retreat_hp_threshold": 0.2,
    "telegraph_duration_beats": 1,
    "difficulty_modifiers": {
      "normal": { "reaction_time": 0.5, "accuracy": 0.7 },
      "hard": { "reaction_time": 0.3, "accuracy": 0.9 },
      "expert": { "reaction_time": 0.1, "accuracy": 1.0 }
    }
  }
}
```

### 6. Type-Based Behaviors
- **Aggressive**: Always chase, low retreat threshold
- **Defensive**: Block more, high retreat threshold
- **Ranged**: Keep distance, shoot projectiles
- **Swarm**: Call allies when damaged

### 7. Test Scene
- Enemy vs player
- AI state display
- Telegraph visualization
- Difficulty selector

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://enemies/enemy_base.gd` - Base enemy class extending Combatant
   - `res://enemies/behavior_trees/` - Behavior tree scripts for AI states
   - Complete implementations with full logic
   - Type hints, documentation, error handling
   - Integration with Combat (S04), LimboAI plugin

2. **Create all JSON data files** using the Write tool
   - `res://data/enemy_ai_config.json` - AI parameters, detection ranges, attack patterns
   - Valid JSON format with all required fields

3. **Create HANDOFF-S11.md** documenting:
   - Scene structures needed (enemy scenes, test arena)
   - MCP agent tasks (use GDAI tools)
   - LimboAI behavior tree setup
   - Testing steps for MCP agent

### Your Deliverables:
- `res://enemies/enemy_base.gd` - Complete enemy AI implementation
- Behavior tree scripts
- `res://data/enemy_ai_config.json` - AI configuration
- `HANDOFF-S11.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S11.md
2. Use GDAI tools to configure scenes:
   - Install and enable LimboAI plugin
   - `create_scene` - Create enemy.tscn, test_enemy_ai.tscn
   - `add_node` - Build node hierarchies (CharacterBody2D, AI components, animations)
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set AI parameters, detection ranges
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S11.md` with this structure:

```markdown
# HANDOFF: S11 - Enemy AI System

## Files Created by Claude Code Web

### GDScript Files
- `res://enemies/enemy_base.gd` - Base enemy class extending Combatant with behavior tree integration
- `res://enemies/behavior_trees/` - Behavior tree scripts for AI states (patrol, chase, attack, retreat, stun)

### Data Files
- `res://data/enemy_ai_config.json` - AI parameters, detection ranges, attack patterns, difficulty modifiers

## MCP Agent Tasks

### 1. Install LimboAI Plugin

```bash
# Note: LimboAI must be installed manually via Godot Asset Library or GitHub
# Enable plugin in Project Settings > Plugins > LimboAI

# Verify plugin is enabled
get_project_setting addons/limboai/enabled
```

### 2. Create Enemy Scene

```bash
# Create base enemy scene
create_scene res://enemies/enemy.tscn
add_node res://enemies/enemy.tscn CharacterBody2D Enemy root
add_node res://enemies/enemy.tscn Sprite2D EnemySprite Enemy
add_node res://enemies/enemy.tscn CollisionShape2D EnemyCollision Enemy
add_node res://enemies/enemy.tscn Area2D DetectionZone Enemy
add_node res://enemies/enemy.tscn CollisionShape2D DetectionShape DetectionZone
add_node res://enemies/enemy.tscn Area2D AttackRange Enemy
add_node res://enemies/enemy.tscn CollisionShape2D AttackShape AttackRange

# Add LimboAI behavior tree node
add_node res://enemies/enemy.tscn BTPlayer BehaviorTree Enemy

# Add telegraph visual effect
add_node res://enemies/enemy.tscn Sprite2D TelegraphFlash Enemy
add_node res://enemies/enemy.tscn AnimationPlayer TelegraphAnim Enemy

# Attach enemy script
attach_script res://enemies/enemy.tscn Enemy res://enemies/enemy_base.gd
```

### 3. Configure Enemy Properties

```bash
# Enemy physics
update_property res://enemies/enemy.tscn Enemy motion_mode 0
update_property res://enemies/enemy.tscn EnemyCollision shape "CircleShape2D(radius=16)"

# Detection zone (200px radius from config)
update_property res://enemies/enemy.tscn DetectionShape shape "CircleShape2D(radius=200)"

# Attack range (64px from config)
update_property res://enemies/enemy.tscn AttackShape shape "CircleShape2D(radius=64)"

# Telegraph visual
update_property res://enemies/enemy.tscn TelegraphFlash modulate "Color(1, 0, 0, 0)"
update_property res://enemies/enemy.tscn TelegraphFlash visible false
```

### 4. Create Test Enemy AI Scene

```bash
create_scene res://tests/test_enemy_ai.tscn
add_node res://tests/test_enemy_ai.tscn Node2D TestEnemyAI root
add_node res://tests/test_enemy_ai.tscn TileMap Arena TestEnemyAI

# Add player (from S03)
add_node res://tests/test_enemy_ai.tscn CharacterBody2D Player TestEnemyAI
add_node res://tests/test_enemy_ai.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_enemy_ai.tscn CollisionShape2D PlayerCollision Player

# Add multiple enemies for testing
add_node res://tests/test_enemy_ai.tscn CharacterBody2D Enemy1 TestEnemyAI res://enemies/enemy.tscn
add_node res://tests/test_enemy_ai.tscn CharacterBody2D Enemy2 TestEnemyAI res://enemies/enemy.tscn
add_node res://tests/test_enemy_ai.tscn CharacterBody2D Enemy3 TestEnemyAI res://enemies/enemy.tscn

# Add UI for testing
add_node res://tests/test_enemy_ai.tscn CanvasLayer UI TestEnemyAI
add_node res://tests/test_enemy_ai.tscn Label Instructions UI
add_node res://tests/test_enemy_ai.tscn VBoxContainer AIStateDisplay UI
add_node res://tests/test_enemy_ai.tscn Label Enemy1State AIStateDisplay
add_node res://tests/test_enemy_ai.tscn Label Enemy2State AIStateDisplay
add_node res://tests/test_enemy_ai.tscn Label Enemy3State AIStateDisplay
add_node res://tests/test_enemy_ai.tscn HBoxContainer DifficultyButtons UI
add_node res://tests/test_enemy_ai.tscn Button NormalButton DifficultyButtons
add_node res://tests/test_enemy_ai.tscn Button HardButton DifficultyButtons
add_node res://tests/test_enemy_ai.tscn Button ExpertButton DifficultyButtons

# Configure test scene
update_property res://tests/test_enemy_ai.tscn Player position "Vector2(200, 300)"
update_property res://tests/test_enemy_ai.tscn PlayerCollision shape "CircleShape2D(radius=16)"
update_property res://tests/test_enemy_ai.tscn Enemy1 position "Vector2(400, 300)"
update_property res://tests/test_enemy_ai.tscn Enemy2 position "Vector2(600, 200)"
update_property res://tests/test_enemy_ai.tscn Enemy3 position "Vector2(600, 400)"

# UI setup
update_property res://tests/test_enemy_ai.tscn Instructions text "Test Enemy AI: Move player with WASD. Watch AI states change."
update_property res://tests/test_enemy_ai.tscn Instructions position "Vector2(10, 10)"
update_property res://tests/test_enemy_ai.tscn AIStateDisplay position "Vector2(10, 50)"
update_property res://tests/test_enemy_ai.tscn Enemy1State text "Enemy 1: Patrol"
update_property res://tests/test_enemy_ai.tscn Enemy2State text "Enemy 2: Patrol"
update_property res://tests/test_enemy_ai.tscn Enemy3State text "Enemy 3: Patrol"
update_property res://tests/test_enemy_ai.tscn DifficultyButtons position "Vector2(10, 150)"
update_property res://tests/test_enemy_ai.tscn NormalButton text "Normal"
update_property res://tests/test_enemy_ai.tscn HardButton text "Hard"
update_property res://tests/test_enemy_ai.tscn ExpertButton text "Expert"
```

## Testing Checklist

Use Godot MCP tools to test:

```bash
# Run test scene
play_scene res://tests/test_enemy_ai.tscn

# Check for errors
get_godot_errors
```

### Verify:
- [ ] LimboAI plugin installed and enabled in project
- [ ] Enemy scene created with CharacterBody2D and BehaviorTree
- [ ] Detection zone (200px radius) detects player
- [ ] Attack range (64px radius) triggers attacks
- [ ] AI states work: Patrol (wander), Chase (follow player), Attack (in range)
- [ ] Retreat state activates below 20% HP
- [ ] Stun state works when hit by stun effect
- [ ] Telegraph system shows red flash 1 beat before attack
- [ ] Telegraph syncs with Conductor (S01)
- [ ] Type-based behaviors work (aggressive, defensive, ranged, swarm)
- [ ] Difficulty scaling: Normal (0.5s reaction, 70% accuracy)
- [ ] Difficulty scaling: Hard (0.3s reaction, 90% accuracy)
- [ ] Difficulty scaling: Expert (0.1s reaction, 100% accuracy)
- [ ] State transitions smooth and responsive
- [ ] No errors in console when running test scene

### Integration Points:
- **S04 (Combat)**: Enemy extends Combatant base class
- **S01 (Conductor)**: Telegraph timing uses beat signals
- **LimboAI Plugin**: Behavior tree execution
- **S12 (Monster Database)**: AI behavior types assigned to monsters

## Completion

Update COORDINATION-DASHBOARD.md:
- Mark S11 as complete
- Unblock S12 (Monster Database)
- Release any resource locks
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S11.md, verify:

### Code Quality
- [ ] All .gd files created with complete implementations (no TODOs or placeholders)
- [ ] enemy_ai_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Integration patterns documented (signals, method calls)

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (enemies/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S11.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] EnemyBase extends Combatant (S04)
- [ ] Behavior tree scripts for all states (Patrol, Chase, Attack, Retreat, Stun)
- [ ] Telegraph system logic implemented
- [ ] Type-based behavior variations implemented
- [ ] Difficulty scaling logic implemented
- [ ] All AI parameters configurable from enemy_ai_config.json

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] LimboAI plugin installed and enabled
- [ ] All scenes created using `create_scene`
- [ ] All nodes added using `add_node` in correct hierarchy
- [ ] All scripts attached using `attach_script`
- [ ] All properties set using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S11")`
- [ ] Quality gates passed: `check_quality_gates("S11")`
- [ ] Checkpoint validated: `validate_checkpoint("S11")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] LimboAI plugin installed and working
- [ ] Enemy extends Combatant (S04)
- [ ] Behavior tree switches states correctly
- [ ] Patrol state: Enemy wanders
- [ ] Chase state: Enemy follows player
- [ ] Attack state: Enemy attacks in range
- [ ] Retreat state: Enemy runs at low HP
- [ ] Telegraph system shows 1 beat warning
- [ ] Type-based behaviors work (aggressive/defensive/etc)
- [ ] Difficulty scaling applies correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ enemy_base.gd complete with behavior tree integration
- ✅ All behavior tree scripts complete (Patrol, Chase, Attack, Retreat, Stun)
- ✅ enemy_ai_config.json complete with AI parameters
- ✅ HANDOFF-S11.md provides clear MCP agent instructions
- ✅ Telegraph system implemented
- ✅ Integration patterns documented for S04

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ LimboAI plugin installed and configured
- ✅ Enemy scenes configured correctly in Godot editor
- ✅ Behavior tree executes all states correctly
- ✅ Telegraph system warns before attacks
- ✅ Type-based behaviors work correctly
- ✅ Difficulty scaling works
- ✅ All verification criteria pass
- ✅ System ready for Monster Database (S12)

</success_criteria>

<memory_checkpoint_format>
```
System S11 (Enemy AI) Complete

FILES:
- res://enemies/enemy_base.gd
- res://data/enemy_ai_config.json
- res://enemies/behavior_trees/[type]_ai.tres
- res://tests/test_enemy_ai.tscn

LIMBOAI INTEGRATION:
- Plugin installed and enabled
- Behavior tree states: Patrol, Chase, Attack, Retreat, Stun

TELEGRAPH SYSTEM:
- Visual/audio cue 1 beat before attack
- Integrates with Conductor (S01)

AI TYPES:
- Aggressive, Defensive, Ranged, Swarm

DIFFICULTY SCALING:
- Normal: 0.5s reaction, 70% accuracy
- Hard: 0.3s reaction, 90% accuracy
- Expert: 0.1s reaction, 100% accuracy

STATUS: Ready for S12 (Monster Database)
```
</memory_checkpoint_format>
