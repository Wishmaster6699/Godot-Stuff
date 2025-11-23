# System S04 Handoff - Combat Prototype

**Created by:** Claude Code Web
**Date:** 2025-11-18
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- ✅ `src/systems/s04-combat/combatant.gd` - Base Combatant class with full damage formula, stats system, and combat actions
- ✅ `src/systems/s04-combat/combat_manager.gd` - Combat orchestration, state machine, rhythm integration, enemy AI

### Data Files
- ✅ `src/systems/s04-combat/combat_config.json` - Complete combat parameters, timing multipliers, dodge/block settings, balance values

### Research Files
- ✅ `research/s04-combat-research.md` - Research findings, design decisions, integration patterns

**All files validated:** Syntax ✓ | Type hints ✓ | GDScript 4.5 compatible ✓

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `scenes/s04-combat/combat_arena.tscn`

**Purpose:** Main combat arena container scene

**MCP Agent Commands:**
```bash
# Create combat arena scene
create_scene scenes/s04-combat/combat_arena.tscn Node2D

# Add combat manager
add_node scenes/s04-combat/combat_arena.tscn Node2D CombatManager root

# Add player spawn marker
add_node scenes/s04-combat/combat_arena.tscn Marker2D PlayerSpawn root

# Add enemy spawn marker
add_node scenes/s04-combat/combat_arena.tscn Marker2D EnemySpawn root

# Add combat camera
add_node scenes/s04-combat/combat_arena.tscn Camera2D CombatCamera root

# Attach combat manager script
attach_script scenes/s04-combat/combat_arena.tscn CombatManager src/systems/s04-combat/combat_manager.gd

# Configure spawn positions
update_property scenes/s04-combat/combat_arena.tscn PlayerSpawn position Vector2(200,300)
update_property scenes/s04-combat/combat_arena.tscn EnemySpawn position Vector2(600,300)

# Configure camera
update_property scenes/s04-combat/combat_arena.tscn CombatCamera position Vector2(400,300)
update_property scenes/s04-combat/combat_arena.tscn CombatCamera zoom Vector2(1.0,1.0)
update_property scenes/s04-combat/combat_arena.tscn CombatCamera enabled true
```

**Node Hierarchy:**
```
CombatArena (Node2D)
├── CombatManager (Node2D) [combat_manager.gd]
│   └── Handles combat state, turn management, rhythm integration
├── PlayerSpawn (Marker2D) - Position: (200, 300)
├── EnemySpawn (Marker2D) - Position: (600, 300)
└── CombatCamera (Camera2D) - Position: (400, 300), Zoom: 1.0
```

**Property Configurations:**
- PlayerSpawn: Left side of arena at (200, 300)
- EnemySpawn: Right side of arena at (600, 300)
- CombatCamera: Centered at (400, 300), fixed zoom 1.0
- CombatManager: No properties needed (loads from combat_config.json)

---

### Scene 2: `scenes/s04-combat/ui/health_bar.tscn`

**Purpose:** Reusable health bar UI component for combatants

**MCP Agent Commands:**
```bash
# Create health bar scene
create_scene scenes/s04-combat/ui/health_bar.tscn Control

# Add background panel
add_node scenes/s04-combat/ui/health_bar.tscn Panel Background root

# Add health bar progress
add_node scenes/s04-combat/ui/health_bar.tscn ProgressBar HealthBar Background

# Add HP text label
add_node scenes/s04-combat/ui/health_bar.tscn Label HPLabel Background

# Configure background
update_property scenes/s04-combat/ui/health_bar.tscn Background custom_minimum_size Vector2(200,30)

# Configure health bar
update_property scenes/s04-combat/ui/health_bar.tscn HealthBar min_value 0
update_property scenes/s04-combat/ui/health_bar.tscn HealthBar max_value 100
update_property scenes/s04-combat/ui/health_bar.tscn HealthBar value 100
update_property scenes/s04-combat/ui/health_bar.tscn HealthBar size Vector2(180,20)
update_property scenes/s04-combat/ui/health_bar.tscn HealthBar position Vector2(10,5)
update_property scenes/s04-combat/ui/health_bar.tscn HealthBar show_percentage false

# Configure HP label
update_property scenes/s04-combat/ui/health_bar.tscn HPLabel text "100 / 100"
update_property scenes/s04-combat/ui/health_bar.tscn HPLabel position Vector2(60,7)
update_property scenes/s04-combat/ui/health_bar.tscn HPLabel horizontal_alignment 1
```

**Node Hierarchy:**
```
HealthBar (Control)
└── Background (Panel)
    ├── HealthBar (ProgressBar) - Visual HP bar (green → yellow → red transitions in S13)
    └── HPLabel (Label) - "100 / 100" text display
```

**Property Configurations:**
- Background: 200x30 panel container
- HealthBar: min=0, max=100, value=100, size=(180,20), position=(10,5)
- HPLabel: Shows "current_hp / max_hp" centered text

**Note:** Health bar color transitions (green → yellow → red) will be implemented in S13 (Health/Stamina Visualization)

---

### Scene 3: `scenes/s04-combat/test_combat.tscn`

**Purpose:** Test scene for 1v1 combat with player vs dummy enemy

**MCP Agent Commands:**
```bash
# Create test combat scene
create_scene scenes/s04-combat/test_combat.tscn Node2D

# Add combat arena instance
add_scene scenes/s04-combat/test_combat.tscn scenes/s04-combat/combat_arena.tscn Arena root

# Add player combatant
add_node scenes/s04-combat/test_combat.tscn CharacterBody2D Player root
add_node scenes/s04-combat/test_combat.tscn CollisionShape2D PlayerCollision Player
add_node scenes/s04-combat/test_combat.tscn Sprite2D PlayerSprite Player

# Add enemy combatant
add_node scenes/s04-combat/test_combat.tscn CharacterBody2D Enemy root
add_node scenes/s04-combat/test_combat.tscn CollisionShape2D EnemyCollision Enemy
add_node scenes/s04-combat/test_combat.tscn Sprite2D EnemySprite Enemy

# Add telegraph indicator above enemy
add_node scenes/s04-combat/test_combat.tscn ColorRect TelegraphIndicator Enemy

# Add combat UI layer
add_node scenes/s04-combat/test_combat.tscn CanvasLayer CombatUI root

# Add health bars to UI
add_scene scenes/s04-combat/test_combat.tscn scenes/s04-combat/ui/health_bar.tscn PlayerHealthBar CombatUI
add_scene scenes/s04-combat/test_combat.tscn scenes/s04-combat/ui/health_bar.tscn EnemyHealthBar CombatUI

# Add combat feedback labels
add_node scenes/s04-combat/test_combat.tscn Label TimingQualityLabel CombatUI
add_node scenes/s04-combat/test_combat.tscn Label CombatStateLabel CombatUI
add_node scenes/s04-combat/test_combat.tscn Label DamageLabel CombatUI
add_node scenes/s04-combat/test_combat.tscn Label InstructionsLabel CombatUI

# Attach combatant scripts
attach_script scenes/s04-combat/test_combat.tscn Player src/systems/s04-combat/combatant.gd
attach_script scenes/s04-combat/test_combat.tscn Enemy src/systems/s04-combat/combatant.gd

# Configure player position and appearance
update_property scenes/s04-combat/test_combat.tscn Player position Vector2(200,300)
update_property scenes/s04-combat/test_combat.tscn PlayerSprite modulate Color(0.2,0.5,1.0)
update_property scenes/s04-combat/test_combat.tscn PlayerSprite texture "res://icon.svg"

# Configure enemy position and appearance
update_property scenes/s04-combat/test_combat.tscn Enemy position Vector2(600,300)
update_property scenes/s04-combat/test_combat.tscn EnemySprite modulate Color(1.0,0.2,0.2)
update_property scenes/s04-combat/test_combat.tscn EnemySprite texture "res://icon.svg"

# Configure telegraph indicator (yellow flash warning)
update_property scenes/s04-combat/test_combat.tscn TelegraphIndicator size Vector2(80,20)
update_property scenes/s04-combat/test_combat.tscn TelegraphIndicator position Vector2(-40,-60)
update_property scenes/s04-combat/test_combat.tscn TelegraphIndicator color Color(1,1,0,0)

# Configure UI positions
update_property scenes/s04-combat/test_combat.tscn PlayerHealthBar position Vector2(10,10)
update_property scenes/s04-combat/test_combat.tscn EnemyHealthBar position Vector2(590,10)

# Configure feedback labels
update_property scenes/s04-combat/test_combat.tscn TimingQualityLabel position Vector2(350,550)
update_property scenes/s04-combat/test_combat.tscn TimingQualityLabel text "Timing: --"
update_property scenes/s04-combat/test_combat.tscn TimingQualityLabel horizontal_alignment 1

update_property scenes/s04-combat/test_combat.tscn CombatStateLabel position Vector2(10,550)
update_property scenes/s04-combat/test_combat.tscn CombatStateLabel text "State: Idle"

update_property scenes/s04-combat/test_combat.tscn DamageLabel position Vector2(350,50)
update_property scenes/s04-combat/test_combat.tscn DamageLabel text ""
update_property scenes/s04-combat/test_combat.tscn DamageLabel horizontal_alignment 1

update_property scenes/s04-combat/test_combat.tscn InstructionsLabel position Vector2(10,500)
update_property scenes/s04-combat/test_combat.tscn InstructionsLabel text "[SPACE] Attack  [SHIFT] Dodge  [CTRL] Block"
```

**Node Hierarchy:**
```
TestCombat (Node2D)
├── Arena (Instance: combat_arena.tscn)
│   └── Contains CombatManager, spawns, camera
├── Player (CharacterBody2D) [combatant.gd]
│   ├── PlayerCollision (CollisionShape2D)
│   └── PlayerSprite (Sprite2D) - Blue tinted
├── Enemy (CharacterBody2D) [combatant.gd]
│   ├── EnemyCollision (CollisionShape2D)
│   ├── EnemySprite (Sprite2D) - Red tinted
│   └── TelegraphIndicator (ColorRect) - Yellow flash warning
└── CombatUI (CanvasLayer)
    ├── PlayerHealthBar (Instance: health_bar.tscn) - Top left
    ├── EnemyHealthBar (Instance: health_bar.tscn) - Top right
    ├── TimingQualityLabel (Label) - Shows "Perfect!" / "Good" / "Miss"
    ├── CombatStateLabel (Label) - Shows current combat state
    ├── DamageLabel (Label) - Shows damage numbers when attacks land
    └── InstructionsLabel (Label) - Control instructions
```

**Property Configurations:**
- Player: Blue combatant at (200, 300), max_hp=100, damage=10
- Enemy: Red combatant at (600, 300), max_hp=50, damage=8
- TelegraphIndicator: Starts transparent, flashes yellow 1 beat before enemy attacks
- TimingQualityLabel: Updates to show "Perfect!" / "Good" / "Okay" / "Miss" based on attack timing
- CombatStateLabel: Shows current combat state ("Idle" / "Player Turn" / "Enemy Turn" / etc.)
- DamageLabel: Shows damage numbers when attacks land (e.g., "20 damage!")
- InstructionsLabel: Shows control scheme for testing

---

### Scene 4: `scenes/s04-combat/test_combat_controller.gd` (Script for Test Scene)

**Purpose:** Connect test scene UI to combat system

**Create this script and attach to test_combat.tscn root:**

```gdscript
# Godot 4.5 | GDScript 4.5
# Test Combat Controller - Connects UI to combat system
extends Node2D

@onready var combat_manager: CombatManager = $Arena/CombatManager
@onready var player: Combatant = $Player
@onready var enemy: Combatant = $Enemy
@onready var conductor: Node = get_node("/root/Conductor")

@onready var timing_label: Label = $CombatUI/TimingQualityLabel
@onready var state_label: Label = $CombatUI/CombatStateLabel
@onready var damage_label: Label = $CombatUI/DamageLabel
@onready var telegraph_indicator: ColorRect = $Enemy/TelegraphIndicator

@onready var player_health_bar: Control = $CombatUI/PlayerHealthBar
@onready var enemy_health_bar: Control = $CombatUI/EnemyHealthBar

func _ready() -> void:
	# Start conductor
	if conductor:
		conductor.start()

	# Connect combat manager signals
	combat_manager.combat_state_changed.connect(_on_combat_state_changed)
	combat_manager.attack_landed.connect(_on_attack_landed)
	combat_manager.enemy_telegraph_started.connect(_on_enemy_telegraph_started)
	combat_manager.enemy_telegraph_ended.connect(_on_enemy_telegraph_ended)
	combat_manager.combat_ended.connect(_on_combat_ended)

	# Connect combatant signals to health bars
	player.health_changed.connect(_on_player_health_changed)
	enemy.health_changed.connect(_on_enemy_health_changed)

	# Initialize player stats
	player.set_stats({
		"max_hp": 100,
		"current_hp": 100,
		"attack": 10,
		"defense": 5,
		"special_attack": 10,
		"special_defense": 5,
		"speed": 10,
		"level": 1
	})

	# Initialize enemy stats
	enemy.set_stats({
		"max_hp": 50,
		"current_hp": 50,
		"attack": 8,
		"defense": 4,
		"special_attack": 8,
		"special_defense": 4,
		"speed": 8,
		"level": 1
	})

	# Start combat after short delay
	await get_tree().create_timer(1.0).timeout
	combat_manager.start_combat(player, enemy)

func _input(event: InputEvent) -> void:
	# Player attack (SPACE or ui_accept)
	if event.is_action_pressed("ui_accept"):
		var timestamp: float = Time.get_ticks_msec() / 1000.0
		combat_manager.player_attack(timestamp)

	# Player dodge (SHIFT)
	if event.is_action_pressed("ui_shift") or event.is_action_pressed("dodge"):
		var timestamp: float = Time.get_ticks_msec() / 1000.0
		combat_manager.player_dodge(timestamp)

	# Player block (CTRL)
	if event.is_action_pressed("ui_control") or event.is_action_pressed("block"):
		combat_manager.player_block()

func _on_combat_state_changed(old_state: String, new_state: String) -> void:
	state_label.text = "State: " + new_state

func _on_attack_landed(attacker: Combatant, target: Combatant, damage: int, timing: String) -> void:
	# Show timing quality
	var timing_text: String = timing.capitalize()
	timing_label.text = "Timing: " + timing_text

	# Show damage number
	damage_label.text = str(damage) + " damage!"

	# Clear damage label after delay
	await get_tree().create_timer(1.0).timeout
	damage_label.text = ""

func _on_enemy_telegraph_started(attack_type: String, target: Combatant) -> void:
	# Flash telegraph indicator yellow
	telegraph_indicator.color = Color(1, 1, 0, 0.8)

	# Animate flash
	var tween: Tween = create_tween()
	tween.set_loops(4)
	tween.tween_property(telegraph_indicator, "color:a", 0.0, 0.25)
	tween.tween_property(telegraph_indicator, "color:a", 0.8, 0.25)

func _on_enemy_telegraph_ended() -> void:
	# Hide telegraph indicator
	telegraph_indicator.color = Color(1, 1, 0, 0)

func _on_player_health_changed(current_hp: int, max_hp: int, delta: int) -> void:
	# Update player health bar
	var health_bar: ProgressBar = player_health_bar.get_node("Background/HealthBar")
	var hp_label: Label = player_health_bar.get_node("Background/HPLabel")

	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp

	if hp_label:
		hp_label.text = str(current_hp) + " / " + str(max_hp)

func _on_enemy_health_changed(current_hp: int, max_hp: int, delta: int) -> void:
	# Update enemy health bar
	var health_bar: ProgressBar = enemy_health_bar.get_node("Background/HealthBar")
	var hp_label: Label = enemy_health_bar.get_node("Background/HPLabel")

	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp

	if hp_label:
		hp_label.text = str(current_hp) + " / " + str(max_hp)

func _on_combat_ended(winner: String, victory_data: Dictionary) -> void:
	if winner == "player":
		state_label.text = "VICTORY! You Win!"
	else:
		state_label.text = "DEFEAT! You Lose!"

	# Show combat stats
	var accuracy: float = combat_manager.get_rhythm_accuracy()
	timing_label.text = "Rhythm Accuracy: %.1f%%" % accuracy
```

**MCP Command to Attach:**
```bash
# Create the controller script first (use edit_file or create_script MCP command)
# Then attach it
attach_script scenes/s04-combat/test_combat.tscn root res://scenes/s04-combat/test_combat_controller.gd
```

---

## Integration Points

### Signals Exposed:

**Combatant Signals:**
- `damage_taken(amount: int, source: Combatant, timing_quality: String)` - Combatant took damage
- `damage_dealt(amount: int, target: Combatant, timing_quality: String)` - Combatant dealt damage
- `health_changed(current_hp: int, max_hp: int, delta: int)` - HP changed
- `defeated(killer: Combatant)` - Combatant HP reached 0
- `attack_executed(target: Combatant, move_power: int)` - Attack started
- `dodge_activated(invulnerability_duration: float)` - Dodge i-frames active
- `block_activated(damage_reduction: float)` - Block active
- `status_effect_applied(effect_name: String, duration: float)` - Status applied
- `status_effect_expired(effect_name: String)` - Status expired

**CombatManager Signals:**
- `combat_started(player: Combatant, enemy: Combatant)` - Combat initialized
- `combat_ended(winner: String, victory_data: Dictionary)` - Combat finished
- `combat_state_changed(old_state: String, new_state: String)` - State transition
- `player_turn_started()` - Player can act
- `enemy_turn_started()` - Enemy acting
- `enemy_telegraph_started(attack_type: String, target: Combatant)` - Enemy warning (1 beat before)
- `enemy_telegraph_ended()` - Enemy attack executes
- `attack_landed(attacker: Combatant, target: Combatant, damage: int, timing: String)` - Attack hit

### Public Methods (Combatant):
- `attack_target(target: Combatant, move_power: int = 60, is_special: bool = false, input_timestamp: float = 0.0) -> int` - Execute attack
- `take_damage(amount: int, source: Combatant = null, timing_quality: String = "okay")` - Take damage
- `heal(amount: int)` - Restore HP
- `dodge(input_timestamp: float = 0.0)` - Activate dodge i-frames
- `block(duration: float = 0.0)` - Activate block
- `apply_status_effect(effect_name: String, duration: float)` - Apply status
- `remove_status_effect(effect_name: String)` - Remove status
- `get_stats() -> Dictionary` - Get all stats
- `set_stats(stats: Dictionary)` - Set stats from dictionary
- `get_hp_percentage() -> float` - Get HP ratio (0.0-1.0)
- `is_alive() -> bool` - Check if alive
- `can_act() -> bool` - Check if can perform actions
- `reset_for_combat()` - Reset to full HP, clear status effects

### Public Methods (CombatManager):
- `start_combat(player_combatant: Combatant, enemy_combatant: Combatant)` - Initialize combat
- `end_combat(winner: String)` - End combat
- `player_attack(input_timestamp: float = 0.0)` - Player attacks (call from input)
- `player_dodge(input_timestamp: float = 0.0)` - Player dodges
- `player_block()` - Player blocks
- `get_combat_state() -> String` - Get current state
- `is_combat_active() -> bool` - Check if combat running
- `get_combat_stats() -> Dictionary` - Get combat statistics
- `get_rhythm_accuracy() -> float` - Get rhythm accuracy percentage

### Dependencies:
- **Depends on:**
  - S01 (Conductor) - Rhythm timing evaluation, beat signals
  - S02 (InputManager) - Player input actions (fallback to Input class if unavailable)
  - S03 (Player) - Player character (can be a Combatant)

- **Depended on by:**
  - S05 (Inventory) - Item usage during combat
  - S06 (Save/Load) - Combat state saving
  - S07 (Weapons) - Weapon damage bonuses
  - S08 (Equipment) - Equipment stat bonuses
  - S09 (Dodge/Block) - Refined dodge/block mechanics
  - S10 (Special Moves) - Special attack integration
  - S11 (Enemy AI) - Advanced enemy behavior
  - S12 (Monster Database) - Monster combatants
  - S13 (Health/Stamina) - Vibe bar integration
  - S19 (Dual XP) - Combat XP rewards
  - S21 (Alignment) - Resonance/Type system

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```bash
# Play test scene
play_scene scenes/s04-combat/test_combat.tscn

# Check for errors
get_godot_errors
```

### Verify:

#### Core Combat Flow
- [ ] Combat arena loads without errors
- [ ] Player and Enemy combatants spawn at correct positions (200,300) and (600,300)
- [ ] Health bars display correctly at start (Player: 100/100, Enemy: 50/50)
- [ ] CombatManager starts combat automatically after 1 second delay
- [ ] Combat state transitions: Idle → Initializing → Player Turn → Enemy Turn → Victory/Defeat
- [ ] State label updates to show current combat state

#### Rhythm Integration (S01 Conductor)
- [ ] Conductor.start() is called and beat signals are emitting
- [ ] Conductor debug overlay (S01) shows beats visually
- [ ] Player attacks on downbeat show "Perfect!" timing
- [ ] Player attacks slightly off-beat show "Good" timing
- [ ] Player attacks way off-beat show "Miss" timing
- [ ] Timing quality label updates to display timing quality

#### Damage System
- [ ] Player attack deals damage to enemy (base ~10-15 damage)
- [ ] Perfect timing attack deals 1.5x damage (verify with damage numbers)
- [ ] Good timing attack deals 1.25x damage
- [ ] Miss timing attack deals 0.85x damage
- [ ] Damage numbers display when attacks land (e.g., "14 damage!")
- [ ] Health bars decrease visually when damage taken
- [ ] HP text updates (e.g., "50 / 100" after taking damage)

#### Enemy AI & Telegraph
- [ ] Enemy telegraphs attack 1 beat before execution
- [ ] Telegraph indicator flashes yellow above enemy head
- [ ] Telegraph lasts exactly 1 beat (at 120 BPM = 500ms)
- [ ] Enemy attack executes after telegraph ends
- [ ] Enemy deals damage to player (base ~6-10 damage)
- [ ] Telegraph indicator disappears after attack executes

#### Dodge Mechanics
- [ ] Player can dodge by pressing SHIFT or dodge action
- [ ] Dodge grants 0.2s invulnerability (i-frames)
- [ ] On-beat dodge extends i-frames to 0.35s
- [ ] Dodging during enemy attack prevents damage (HP doesn't change)
- [ ] Dodge signal emits (`dodge_activated`)

#### Block Mechanics
- [ ] Player can block by pressing CTRL or block action
- [ ] Block reduces incoming damage by 50%
- [ ] Blocking during enemy attack reduces damage (HP changes by half expected amount)
- [ ] Block lasts 0.5s (configurable in combat_config.json)
- [ ] Block signal emits (`block_activated`)

#### Win/Lose Conditions
- [ ] Combat ends when enemy HP <= 0 (player victory)
- [ ] Combat ends when player HP <= 0 (enemy victory)
- [ ] `combat_ended` signal emits with correct winner ("player" or "enemy")
- [ ] State label shows "VICTORY! You Win!" or "DEFEAT! You Lose!"
- [ ] Timing label shows final rhythm accuracy percentage (e.g., "Rhythm Accuracy: 85.0%")
- [ ] Combat statistics are tracked (perfect hits, good hits, misses, damage dealt/taken)

#### Integration Tests
- [ ] System integrates with Conductor (S01) for rhythm timing - no errors
- [ ] System falls back gracefully if InputManager (S02) not available
- [ ] Player CharacterBody2D compatible with PlayerController (S03)
- [ ] No circular dependencies or autoload conflicts
- [ ] No script errors in Godot console (`get_godot_errors` returns empty)

#### Performance Tests
- [ ] Combat runs at 60 FPS with no frame drops
- [ ] Damage calculation takes <0.5ms per attack (profile with `PerformanceProfiler`)
- [ ] No memory leaks after 10 consecutive combat encounters
- [ ] Status effect updates take <0.2ms per frame (with 5 active effects)

#### Edge Cases
- [ ] Cannot attack when not player's turn (warning message in console)
- [ ] Cannot dodge while already dodging (cooldown works)
- [ ] Minimum 1 damage even if defense > attack
- [ ] Combat handles rapid input (no double-hits or timing exploits)
- [ ] Telegraph system handles BPM changes (if Conductor BPM changes mid-combat)

---

## Notes / Gotchas

### CRITICAL - Conductor Integration

**Conductor MUST be running before starting combat:**
```gdscript
func _ready():
    var conductor = get_node("/root/Conductor")
    if conductor:
        conductor.start()  # START CONDUCTOR FIRST!

    await get_tree().create_timer(1.0).timeout
    combat_manager.start_combat(player, enemy)
```

**If Conductor not running:**
- Beat signals won't emit
- Enemy telegraphs won't count down
- Turn timing won't work
- Combat will appear frozen

### Timing Quality Evaluation

**Input timestamp MUST be captured at input time:**
```gdscript
# CORRECT
func _input(event):
    if event.is_action_pressed("attack"):
        var timestamp = Time.get_ticks_msec() / 1000.0  # Capture NOW
        combat_manager.player_attack(timestamp)

# WRONG
func _input(event):
    if event.is_action_pressed("attack"):
        combat_manager.player_attack(0.0)  # Timing evaluation will fail!
```

### Telegraph Visual Feedback

**Telegraph indicator starts transparent:**
- Initial color: `Color(1, 1, 0, 0)` (yellow, alpha=0)
- On telegraph start: Animate to `Color(1, 1, 0, 0.8)` (yellow, alpha=0.8)
- Flash frequency: 3 Hz (from combat_config.json)
- On telegraph end: Return to `Color(1, 1, 0, 0)` (transparent)

**Use Tween for animation:**
```gdscript
var tween = create_tween()
tween.set_loops(4)  # 4 loops at 3 Hz = ~1.3 seconds
tween.tween_property(indicator, "color:a", 0.0, 0.25)
tween.tween_property(indicator, "color:a", 0.8, 0.25)
```

### Damage Formula Validation

**Test these damage scenarios:**

1. **Level 1, ATK=10, Enemy DEF=4, Move Power=60, Perfect Timing:**
   - Base: ~14 damage
   - With 1.5x timing: ~21 damage
   - Verify damage label shows ~21

2. **Same scenario, Miss Timing (0.85x):**
   - Base: ~14 damage
   - With 0.85x timing: ~11-12 damage
   - Verify damage label shows ~11-12

3. **Critical Hit (random, ~6.25% chance):**
   - Should see 1.5x damage multiplier occasionally
   - Higher damage number appears (e.g., 30+ instead of 20)

### Health Bar Color Shifts

**NOT implemented in S04 (placeholder for S13):**
- Current: ProgressBar with default green tint
- S13 will add: Color transitions based on HP percentage
  - Green: HP > 66%
  - Yellow: HP 33%-66%
  - Red: HP < 33%
- Thresholds defined in combat_config.json: `health_bars.color_thresholds`

### Status Effects (Partial Implementation)

**S04 includes basic status effect framework:**
- Poison: Deals 5% max HP per second
- Burn: Deals 8% max HP per second
- Stun: Prevents actions

**NOT fully integrated in S04:**
- No UI indicators for active status effects
- No status effect application in combat (enemies don't inflict status)
- Full implementation in S13 (Health/Stamina Visualization)

**Testing Status Effects:**
```gdscript
# In test scene, manually apply status
player.apply_status_effect("poison", 5.0)  # Poison for 5 seconds
# Observe HP slowly decreasing
```

### Enemy AI (Simplified for Prototype)

**S04 Enemy AI:**
- Always telegraphs before attacking (100% telegraph chance)
- Fixed attack power range (40-80)
- No pattern variation or behavior trees

**Future S11 (Enemy AI) will add:**
- Behavior trees
- Attack patterns (sequences, combos)
- Conditional AI (low HP = heal, player low HP = aggressive)
- Difficulty scaling

### Combat Statistics Tracking

**Stats tracked automatically:**
```gdscript
{
    "total_damage_dealt": 0,
    "total_damage_taken": 0,
    "perfect_hits": 0,
    "good_hits": 0,
    "missed_hits": 0,
    "dodges_successful": 0,
    "blocks_successful": 0,
    "turns_elapsed": 0,
    "combat_duration": 0.0  # in seconds
}
```

**Access via:**
```gdscript
var stats = combat_manager.get_combat_stats()
print("Perfect hits: ", stats["perfect_hits"])

var accuracy = combat_manager.get_rhythm_accuracy()  # Returns 0.0-100.0
print("Rhythm accuracy: %.1f%%" % accuracy)
```

### Victory Bonus Objectives (Defined, Not Rewarded Yet)

**Bonus objectives in combat_config.json:**
- Perfect Victory: No damage taken (reward_multiplier: 1.5x)
- Rhythm Master: 90%+ on-beat (reward_multiplier: 1.25x)
- Speed Demon: Win in <30 seconds (reward_multiplier: 1.3x)

**S04 tracks these, but doesn't award bonuses:**
- S19 (Dual XP System) will use these for XP multipliers
- S06 (Save/Load) will use these for save data

**Check bonus eligibility:**
```gdscript
var stats = combat_manager.get_combat_stats()
var perfect_victory = stats["total_damage_taken"] == 0
var rhythm_master = combat_manager.get_rhythm_accuracy() >= 90.0
var speed_demon = stats["combat_duration"] < 30.0

print("Perfect Victory: ", perfect_victory)
print("Rhythm Master: ", rhythm_master)
print("Speed Demon: ", speed_demon)
```

### Godot 4.5 Specific Issues

**Collision Shapes:**
- CollisionShape2D needs a Shape2D resource
- Default test scene uses CircleShape2D (radius: 32)
- Create shape via MCP: `add_resource` command

**ProgressBar vs TextureProgressBar:**
- S04 uses ProgressBar (simple, no texture needed)
- S13 will upgrade to TextureProgressBar (custom bar textures)

**Tween API (Godot 4.x):**
- Use `create_tween()` (not `Tween.new()`)
- Tween properties with `tween_property(object, "property", value, duration)`
- Set loops with `tween.set_loops(count)`

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 CharacterBody2D: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html
- Godot 4.5 Signals: https://docs.godotengine.org/en/4.5/getting_started/step_by_step/signals.html
- GDQuest FSM Tutorial: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
- Combat Specification: `combat-specification.md` (damage formula, timing windows, balance)
- S01 Conductor: `src/systems/s01-conductor-rhythm-system/conductor.gd`
- S03 Player: `src/systems/s03-player/player_controller.gd`

**Full research notes:** `research/s04-combat-research.md`

---

## Verification Evidence Required

**Tier 2 must provide:**

1. **Screenshot of test scene running:**
   ```bash
   get_editor_screenshot
   # Save to: evidence/S04-tier2-verification/test_combat_running.png
   ```

2. **Error log output (should be empty):**
   ```bash
   get_godot_errors
   # Save output to: evidence/S04-tier2-verification/error_log.txt
   ```

3. **Performance profiler output:**
   ```bash
   # In Godot console
   PerformanceProfiler.profile_system("S04")
   # Save output to: evidence/S04-tier2-verification/performance.txt
   ```

4. **Combat statistics after test battle:**
   ```gdscript
   # After combat ends
   var stats = combat_manager.get_combat_stats()
   print(stats)
   # Save output to: evidence/S04-tier2-verification/combat_stats.json
   ```

**Save to:** `evidence/S04-tier2-verification/`

---

## Completion Criteria

**System S04 is complete when:**

### Tier 2 Technical Requirements
- ✅ All scenes created and configured correctly
- ✅ Test scene runs without errors (`get_godot_errors` returns empty)
- ✅ All tests pass (unit + integration)
- ✅ Performance meets targets (<0.5ms/frame for combat system)
- ✅ Quality gates pass (score ≥80)
- ✅ Documentation complete (checkpoint.md)

### Functional Requirements
- ✅ 1v1 combat works: Player vs Enemy
- ✅ Rhythm-based attacks with timing evaluation (Perfect/Good/Okay/Miss)
- ✅ Enemy telegraph system warns 1 beat before attacks
- ✅ Dodge grants invulnerability (0.2s, extends to 0.35s on-beat)
- ✅ Block reduces damage by 50%
- ✅ Health bars update in real-time
- ✅ Damage formula produces correct values
- ✅ Win/lose conditions trigger appropriately
- ✅ Combat statistics tracked accurately

### Integration Requirements
- ✅ Integrates with Conductor (S01) for rhythm timing
- ✅ Integrates with InputManager (S02) or falls back to Input class
- ✅ Compatible with Player (S03) as combatant
- ✅ Signals exposed for dependent systems (S05-S21)

### Unblocked Systems
After S04 complete, these systems can begin:
- ✅ S05 (Inventory) - Item usage during combat
- ✅ S07 (Weapons) - Weapon damage bonuses
- ✅ S09 (Dodge/Block) - Refined mechanics
- ✅ S10 (Special Moves) - Special attacks
- ✅ S11 (Enemy AI) - Advanced behavior
- ✅ S12 (Monster Database) - Monster combatants
- ✅ S13 (Health/Stamina) - Vibe bar integration
- ✅ S19 (Dual XP) - Combat XP rewards
- ✅ S21 (Alignment) - Type effectiveness
- ✅ **15+ systems unblocked!**

---

**HANDOFF STATUS: READY FOR TIER 2**

**Estimated Tier 2 Time:** 3-4 hours (scene configuration + testing + verification)

**Priority:** **CRITICAL** (blocks 15+ downstream systems - highest priority after S01-S03)

---

*Generated by: Claude Code Web*
*Date: 2025-11-18*
*Prompt: 006-s04-combat-prototype.md*
*Branch: claude/implement-combat-prototype-016mKvahkRXEpQUcJ7XrmV3G*
