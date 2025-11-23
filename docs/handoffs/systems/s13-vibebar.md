# HANDOFF: S13 - Color-Shift Health/Vibe Bar
**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** Visual health indicator using shader-based color shifting to communicate player/enemy health state through dynamic color transitions (Blue → Yellow → Red)

**Type:** UI Component with shader effects and particle systems

**Dependencies:**
- S04 (Combat) - Integrates with Combatant.health_changed signal
- S01 (Conductor) - Syncs defeat animation with downbeat signal

---

## Files Created by Tier 1

### GDScript Files
- ✅ `src/systems/s13-vibebar/vibe_bar.gd` - Main vibe bar controller with shader parameter updates, particle triggers, and combatant tracking

### Shader Files
- ✅ `shaders/color_shift_health.gdshader` - Color-shifting shader with smooth transitions (blue → yellow → red)

### Data Files
- ✅ `data/vibe_bar_config.json` - Color thresholds, particle effects config, transition speeds, pulse settings

### Research Files
- ✅ `research/s13-vibebar-research.md` - Complete research findings, code patterns, integration notes

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | GDScript 4.5 ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Create Vibe Bar UI Component Scene

```bash
# Create the main vibe bar scene
create_scene res://src/systems/s13-vibebar/vibe_bar.tscn Control

# Add container control node as root
add_node res://src/systems/s13-vibebar/vibe_bar.tscn Control VibeBar root

# Add background panel
add_node res://src/systems/s13-vibebar/vibe_bar.tscn Panel Background VibeBar

# Add health bar (TextureProgressBar with shader)
add_node res://src/systems/s13-vibebar/vibe_bar.tscn ColorRect HealthBar VibeBar

# Add health percentage text
add_node res://src/systems/s13-vibebar/vibe_bar.tscn Label HealthText VibeBar

# Add particle effects
add_node res://src/systems/s13-vibebar/vibe_bar.tscn GPUParticles2D YellowSparkles VibeBar
add_node res://src/systems/s13-vibebar/vibe_bar.tscn GPUParticles2D RedWarning VibeBar
add_node res://src/systems/s13-vibebar/vibe_bar.tscn GPUParticles2D DefeatExplosion VibeBar

# Add pulse animation player
add_node res://src/systems/s13-vibebar/vibe_bar.tscn AnimationPlayer PulseAnimation VibeBar

# Attach vibe bar script to root
attach_script res://src/systems/s13-vibebar/vibe_bar.tscn VibeBar res://src/systems/s13-vibebar/vibe_bar.gd
```

### Step 2: Configure Vibe Bar Properties

```bash
# Root Control node setup
update_property res://src/systems/s13-vibebar/vibe_bar.tscn VibeBar custom_minimum_size "Vector2(200, 30)"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn VibeBar size "Vector2(200, 30)"

# Background panel
update_property res://src/systems/s13-vibebar/vibe_bar.tscn Background anchor_preset 15
update_property res://src/systems/s13-vibebar/vibe_bar.tscn Background offset_left 0.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn Background offset_top 0.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn Background offset_right 0.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn Background offset_bottom 0.0

# Health bar ColorRect (will have shader applied)
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar anchor_preset 15
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar offset_left 2.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar offset_top 2.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar offset_right -2.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar offset_bottom -2.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar color "Color(0, 0.5, 1, 1)"

# Health text label
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText text "100%"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText horizontal_alignment 1
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText vertical_alignment 1
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText anchor_preset 15
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText offset_left 0.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText offset_top 0.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText offset_right 0.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthText offset_bottom 0.0

# Yellow sparkle particles (trigger at 50% threshold)
update_property res://src/systems/s13-vibebar/vibe_bar.tscn YellowSparkles position "Vector2(100, 15)"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn YellowSparkles emitting false
update_property res://src/systems/s13-vibebar/vibe_bar.tscn YellowSparkles amount 20
update_property res://src/systems/s13-vibebar/vibe_bar.tscn YellowSparkles lifetime 0.5
update_property res://src/systems/s13-vibebar/vibe_bar.tscn YellowSparkles one_shot true
update_property res://src/systems/s13-vibebar/vibe_bar.tscn YellowSparkles explosiveness 1.0

# Red warning particles (trigger at 10% threshold)
update_property res://src/systems/s13-vibebar/vibe_bar.tscn RedWarning position "Vector2(100, 15)"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn RedWarning emitting false
update_property res://src/systems/s13-vibebar/vibe_bar.tscn RedWarning amount 30
update_property res://src/systems/s13-vibebar/vibe_bar.tscn RedWarning lifetime 0.3
update_property res://src/systems/s13-vibebar/vibe_bar.tscn RedWarning one_shot true
update_property res://src/systems/s13-vibebar/vibe_bar.tscn RedWarning explosiveness 1.0

# Defeat explosion particles (trigger at 0% on downbeat)
update_property res://src/systems/s13-vibebar/vibe_bar.tscn DefeatExplosion position "Vector2(100, 15)"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn DefeatExplosion emitting false
update_property res://src/systems/s13-vibebar/vibe_bar.tscn DefeatExplosion amount 50
update_property res://src/systems/s13-vibebar/vibe_bar.tscn DefeatExplosion lifetime 1.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn DefeatExplosion one_shot true
update_property res://src/systems/s13-vibebar/vibe_bar.tscn DefeatExplosion explosiveness 1.0
```

### Step 3: Apply Shader Material to HealthBar

**CRITICAL: This step requires manual setup in Godot editor**

1. Open scene: `res://src/systems/s13-vibebar/vibe_bar.tscn`
2. Select the `HealthBar` ColorRect node
3. In Inspector, find **CanvasItem > Material**
4. Click the dropdown, select **New ShaderMaterial**
5. Click on the newly created ShaderMaterial
6. In the **ShaderMaterial** section, find **Shader** property
7. Click the dropdown, select **Load**
8. Navigate to and select: `res://shaders/color_shift_health.gdshader`
9. Verify shader uniforms appear in Inspector:
   - `health_percent` (float, 0.0-1.0)
   - `color_high` (Color, blue)
   - `color_mid` (Color, yellow)
   - `color_low` (Color, red)
   - `brightness` (float)
   - `use_gradient` (bool)
10. Set initial values:
    - `health_percent` = 1.0
    - `color_high` = RGB(0, 128, 255) or #0080FF
    - `color_mid` = RGB(255, 255, 0) or #FFFF00
    - `color_low` = RGB(255, 0, 0) or #FF0000
    - `brightness` = 1.0
    - `use_gradient` = true
11. Save scene

**Alternative (if MCP supports creating resources):**
```bash
# If add_resource or create_shader_material command exists:
add_resource res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar material ShaderMaterial
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar material.shader "res://shaders/color_shift_health.gdshader"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar material.shader_parameter/health_percent 1.0
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar material.shader_parameter/color_high "Color(0, 0.5, 1, 1)"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar material.shader_parameter/color_mid "Color(1, 1, 0, 1)"
update_property res://src/systems/s13-vibebar/vibe_bar.tscn HealthBar material.shader_parameter/color_low "Color(1, 0, 0, 1)"
```

### Step 4: Create Pulse Animation

**In Godot Editor:**
1. Select `PulseAnimation` AnimationPlayer node
2. Create new animation called "pulse"
3. Set animation length: 0.5 seconds
4. Set loop mode: enabled
5. Add track for `HealthBar:scale`
6. Add keyframes:
   - Frame 0.0: scale = Vector2(1.0, 1.0)
   - Frame 0.25: scale = Vector2(1.05, 1.05)
   - Frame 0.5: scale = Vector2(1.0, 1.0)
7. Set easing to Ease In-Out
8. Save animation
9. Set `PulseAnimation.autoplay` to "" (empty, controlled by script)

### Step 5: Create Test Scene

```bash
# Create test scene for vibe bar demonstration
create_scene res://src/systems/s13-vibebar/test_vibe_bar.tscn Node2D

# Add root node
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Node2D TestVibeBar root

# Add player combatant for testing
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn CharacterBody2D Player TestVibeBar
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Sprite2D PlayerSprite Player
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn CollisionShape2D PlayerCollision Player

# Add player vibe bar (instance the vibe bar scene)
# Note: This should instance the scene, not add a node
# add_scene syntax: add_scene <scene_path> <instance_name> <parent_node>
add_scene res://src/systems/s13-vibebar/vibe_bar.tscn PlayerVibeBar Player

# Add enemy combatant for testing
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn CharacterBody2D Enemy TestVibeBar
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Sprite2D EnemySprite Enemy
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn CollisionShape2D EnemyCollision Enemy

# Add enemy vibe bar
add_scene res://src/systems/s13-vibebar/vibe_bar.tscn EnemyVibeBar Enemy

# Add UI layer for controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn CanvasLayer UI TestVibeBar
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Panel ControlPanel UI
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn VBoxContainer Controls ControlPanel

# Instructions
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label Instructions Controls

# Player controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label PlayerLabel Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn HBoxContainer PlayerButtons Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button PlayerDamage10 PlayerButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button PlayerDamage25 PlayerButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button PlayerDamage50 PlayerButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button PlayerHeal50 PlayerButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button PlayerReset PlayerButtons

# Enemy controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label EnemyLabel Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn HBoxContainer EnemyButtons Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button EnemyDamage10 EnemyButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button EnemyDamage25 EnemyButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button EnemyDamage50 EnemyButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button EnemyHeal50 EnemyButtons
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Button EnemyReset EnemyButtons

# Color guide
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label Separator Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label ColorGuide Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label BlueInfo Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label YellowInfo Controls
add_node res://src/systems/s13-vibebar/test_vibe_bar.tscn Label RedInfo Controls
```

### Step 6: Configure Test Scene Properties

```bash
# Player setup
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn Player position "Vector2(200, 300)"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerVibeBar position "Vector2(-100, -60)"

# Enemy setup
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn Enemy position "Vector2(600, 300)"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyVibeBar position "Vector2(-100, -60)"

# UI panel setup
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn ControlPanel anchor_preset 0
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn ControlPanel position "Vector2(10, 10)"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn ControlPanel size "Vector2(400, 400)"

update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn Controls anchor_preset 15

# Instructions
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn Instructions text "Test Vibe Bar: Watch color transitions (Blue → Yellow → Red)"

# Player controls
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerLabel text "Player Health Controls:"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerDamage10 text "-10 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerDamage25 text "-25 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerDamage50 text "-50 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerHeal50 text "+50 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn PlayerReset text "Reset"

# Enemy controls
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyLabel text "Enemy Health Controls:"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyDamage10 text "-10 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyDamage25 text "-25 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyDamage50 text "-50 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyHeal50 text "+50 HP"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn EnemyReset text "Reset"

# Color guide
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn Separator text "─────────────────────"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn ColorGuide text "Color Transitions:"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn BlueInfo text "  Blue: 100% - 51% HP (Groovin')"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn YellowInfo text "  Yellow: 50% - 11% HP (Shaky) + Sparks"
update_property res://src/systems/s13-vibebar/test_vibe_bar.tscn RedInfo text "  Red: 10% - 0% HP (Off-Beat) + Warning + Pulse"
```

### Step 7: Create Test Script (Manual Step)

Create `res://src/systems/s13-vibebar/test_vibe_bar.gd`:

```gdscript
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var enemy: CharacterBody2D = $Enemy
@onready var player_vibe_bar: VibeBar = $Player/PlayerVibeBar
@onready var enemy_vibe_bar: VibeBar = $Enemy/EnemyVibeBar

# Simple combatant for testing (minimal version)
class TestCombatant extends CharacterBody2D:
	signal health_changed(current_hp: int, max_hp: int, delta: int)
	signal defeated(killer)

	var max_hp: int = 100
	var current_hp: int = 100

	func take_damage(amount: int) -> void:
		var old_hp := current_hp
		current_hp -= amount
		current_hp = max(current_hp, 0)
		health_changed.emit(current_hp, max_hp, current_hp - old_hp)

		if current_hp <= 0:
			defeated.emit(null)

	func heal(amount: int) -> void:
		var old_hp := current_hp
		current_hp += amount
		current_hp = min(current_hp, max_hp)
		health_changed.emit(current_hp, max_hp, current_hp - old_hp)

	func reset_health() -> void:
		current_hp = max_hp
		health_changed.emit(current_hp, max_hp, 0)

	func get_hp_percentage() -> float:
		return float(current_hp) / float(max_hp)

var player_combatant: TestCombatant
var enemy_combatant: TestCombatant

func _ready() -> void:
	# Set up test combatants
	player_combatant = TestCombatant.new()
	player.add_child(player_combatant)

	enemy_combatant = TestCombatant.new()
	enemy.add_child(enemy_combatant)

	# Track combatants with vibe bars
	player_vibe_bar.track_combatant(player_combatant)
	enemy_vibe_bar.track_combatant(enemy_combatant)

	# Connect buttons
	$UI/ControlPanel/Controls/PlayerButtons/PlayerDamage10.pressed.connect(_on_player_damage_10)
	$UI/ControlPanel/Controls/PlayerButtons/PlayerDamage25.pressed.connect(_on_player_damage_25)
	$UI/ControlPanel/Controls/PlayerButtons/PlayerDamage50.pressed.connect(_on_player_damage_50)
	$UI/ControlPanel/Controls/PlayerButtons/PlayerHeal50.pressed.connect(_on_player_heal_50)
	$UI/ControlPanel/Controls/PlayerButtons/PlayerReset.pressed.connect(_on_player_reset)

	$UI/ControlPanel/Controls/EnemyButtons/EnemyDamage10.pressed.connect(_on_enemy_damage_10)
	$UI/ControlPanel/Controls/EnemyButtons/EnemyDamage25.pressed.connect(_on_enemy_damage_25)
	$UI/ControlPanel/Controls/EnemyButtons/EnemyDamage50.pressed.connect(_on_enemy_damage_50)
	$UI/ControlPanel/Controls/EnemyButtons/EnemyHeal50.pressed.connect(_on_enemy_heal_50)
	$UI/ControlPanel/Controls/EnemyButtons/EnemyReset.pressed.connect(_on_enemy_reset)

# Player button handlers
func _on_player_damage_10() -> void:
	player_combatant.take_damage(10)

func _on_player_damage_25() -> void:
	player_combatant.take_damage(25)

func _on_player_damage_50() -> void:
	player_combatant.take_damage(50)

func _on_player_heal_50() -> void:
	player_combatant.heal(50)

func _on_player_reset() -> void:
	player_combatant.reset_health()

# Enemy button handlers
func _on_enemy_damage_10() -> void:
	enemy_combatant.take_damage(10)

func _on_enemy_damage_25() -> void:
	enemy_combatant.take_damage(25)

func _on_enemy_damage_50() -> void:
	enemy_combatant.take_damage(50)

func _on_enemy_heal_50() -> void:
	enemy_combatant.heal(50)

func _on_enemy_reset() -> void:
	enemy_combatant.reset_health()
```

Then attach script:
```bash
attach_script res://src/systems/s13-vibebar/test_vibe_bar.tscn TestVibeBar res://src/systems/s13-vibebar/test_vibe_bar.gd
```

---

## Node Hierarchies

### Vibe Bar Scene Structure
```
Control (VibeBar) [Script: vibe_bar.gd]
├── Panel (Background)
├── ColorRect (HealthBar) [ShaderMaterial with color_shift_health.gdshader]
├── Label (HealthText)
├── GPUParticles2D (YellowSparkles)
├── GPUParticles2D (RedWarning)
├── GPUParticles2D (DefeatExplosion)
└── AnimationPlayer (PulseAnimation) [Animation: "pulse"]
```

### Test Scene Structure
```
Node2D (TestVibeBar) [Script: test_vibe_bar.gd]
├── CharacterBody2D (Player)
│   ├── Sprite2D (PlayerSprite)
│   ├── CollisionShape2D (PlayerCollision)
│   └── VibeBar (PlayerVibeBar) [Instance of vibe_bar.tscn]
├── CharacterBody2D (Enemy)
│   ├── Sprite2D (EnemySprite)
│   ├── CollisionShape2D (EnemyCollision)
│   └── VibeBar (EnemyVibeBar) [Instance of vibe_bar.tscn]
└── CanvasLayer (UI)
    └── Panel (ControlPanel)
        └── VBoxContainer (Controls)
            ├── Label (Instructions)
            ├── Label (PlayerLabel)
            ├── HBoxContainer (PlayerButtons)
            │   ├── Button (PlayerDamage10)
            │   ├── Button (PlayerDamage25)
            │   ├── Button (PlayerDamage50)
            │   ├── Button (PlayerHeal50)
            │   └── Button (PlayerReset)
            ├── Label (EnemyLabel)
            ├── HBoxContainer (EnemyButtons)
            │   ├── Button (EnemyDamage10)
            │   ├── Button (EnemyDamage25)
            │   ├── Button (EnemyDamage50)
            │   ├── Button (EnemyHeal50)
            │   └── Button (EnemyReset)
            ├── Label (Separator)
            ├── Label (ColorGuide)
            ├── Label (BlueInfo)
            ├── Label (YellowInfo)
            └── Label (RedInfo)
```

---

## Property Configurations

### Critical Properties

**VibeBar (Control):**
- `custom_minimum_size` = Vector2(200, 30)
- `size` = Vector2(200, 30)

**HealthBar (ColorRect) with ShaderMaterial:**
- `material.shader` = `res://shaders/color_shift_health.gdshader`
- `material.shader_parameter/health_percent` = 1.0 (updated via script)
- `material.shader_parameter/color_high` = Color(0, 0.5, 1, 1) - Blue
- `material.shader_parameter/color_mid` = Color(1, 1, 0, 1) - Yellow
- `material.shader_parameter/color_low` = Color(1, 0, 0, 1) - Red
- `material.shader_parameter/brightness` = 1.0
- `material.shader_parameter/use_gradient` = true

**Particle Systems:**
All GPUParticles2D:
- `emitting` = false (controlled by script)
- `one_shot` = true
- `explosiveness` = 1.0

**PulseAnimation (AnimationPlayer):**
- Animation "pulse": 0.5s loop, scale 1.0 → 1.05 → 1.0
- `speed_scale` = 2.0 (set by script)
- `autoplay` = "" (empty, triggered by script when HP < 20%)

---

## Signal Connections

### In Vibe Bar Script

The vibe bar automatically connects to combatant signals when `track_combatant()` is called:

```gdscript
# Automatic connections in vibe_bar.gd
combatant.health_changed.connect(_on_combatant_health_changed)
combatant.defeated.connect(_on_combatant_defeated)

# Also connects to Conductor if available
if Conductor:
    await Conductor.downbeat  # In defeat animation
```

### In Test Scene Script

Button signals connected in `test_vibe_bar.gd`:
```gdscript
$UI/ControlPanel/Controls/PlayerButtons/PlayerDamage10.pressed.connect(_on_player_damage_10)
# ... etc for all buttons
```

---

## Integration Notes

### How to Use Vibe Bar in Combat Scenes

**Basic Usage:**
```gdscript
# In your combat scene or player scene
@onready var player_vibe_bar: VibeBar = $UI/PlayerVibeBar
@onready var player_combatant: Combatant = $Player

func _ready() -> void:
    # Connect vibe bar to combatant
    player_vibe_bar.track_combatant(player_combatant)

    # That's it! Vibe bar automatically updates when combatant takes damage
```

**Manual Health Updates (if not using Combatant):**
```gdscript
# Update health manually
vibe_bar.update_health(current_hp / max_hp)

# Or with instant transition (no animation)
vibe_bar.update_health(0.5, true)
```

**Listening to Vibe Bar Events:**
```gdscript
vibe_bar.health_updated.connect(_on_vibe_bar_updated)
vibe_bar.threshold_crossed.connect(_on_threshold_crossed)
vibe_bar.defeat_animation_complete.connect(_on_defeat_complete)

func _on_threshold_crossed(threshold_name: String, current_percent: float) -> void:
    match threshold_name:
        "mid":
            print("Player entering warning state!")
        "low":
            print("Player critical!")
        "defeat":
            print("Player defeated!")
```

### Integration with S04 Combat System

The Combatant class (from S04) has the following relevant signals and methods:

```gdscript
# In Combatant.gd (S04)
signal health_changed(current_hp: int, max_hp: int, delta: int)
signal defeated(killer: Combatant)

func get_hp_percentage() -> float:
    return float(current_hp) / float(max_hp)
```

**Example Integration:**
```gdscript
# In combat_arena.tscn or player scene
extends Node2D

@onready var player: Combatant = $Player  # From S04
@onready var player_vibe_bar: VibeBar = $UI/PlayerVibeBar  # From S13

func _ready() -> void:
    player_vibe_bar.track_combatant(player)
    # Now vibe bar automatically reflects player health!
```

### Integration with S01 Conductor System

Defeat animation waits for downbeat signal:

```gdscript
# In vibe_bar.gd
func _on_combatant_defeated(killer: Node = null) -> void:
    if conductor and conductor.has_signal("downbeat"):
        await conductor.downbeat  # Wait for rhythm sync

    # Play defeat explosion on beat
    trigger_particle_effect("defeat_explosion")
```

**Testing Without Conductor:**
- If Conductor autoload not found, defeat animation plays immediately
- Warning logged: "VibeBar: Conductor autoload not found - downbeat sync disabled"

---

## Testing Checklist for Tier 2

**Before marking complete, Tier 2 agent MUST verify:**

### Scene Setup
- [ ] Vibe bar scene created: `res://src/systems/s13-vibebar/vibe_bar.tscn`
- [ ] All nodes present in scene hierarchy
- [ ] Vibe bar script attached correctly
- [ ] ShaderMaterial applied to HealthBar node
- [ ] Shader loaded: `res://shaders/color_shift_health.gdshader`
- [ ] Shader uniforms visible in inspector
- [ ] Pulse animation created with correct keyframes
- [ ] Test scene created: `res://src/systems/s13-vibebar/test_vibe_bar.tscn`
- [ ] Test script attached and buttons connected

### Functional Testing
Run test scene: `play_scene res://src/systems/s13-vibebar/test_vibe_bar.tscn`

**Color Transitions:**
- [ ] 100% HP: Blue color displayed
- [ ] 75% HP: Blue-yellow gradient (smooth blend)
- [ ] 50% HP: Yellow color displayed, yellow sparkle particles trigger ONCE
- [ ] 30% HP: Yellow-red gradient
- [ ] 20% HP: Pulse animation starts (scale 1.0 → 1.05)
- [ ] 10% HP: Red color displayed, red warning particles trigger ONCE
- [ ] 0% HP: Defeat explosion particles trigger (wait for downbeat if Conductor present)

**Healing:**
- [ ] Healing from 50% → 75%: Yellow → Blue gradient smooth
- [ ] Healing from 10% → 30%: Red → Yellow gradient smooth
- [ ] Pulse animation stops when healing above 20%

**Particle Effects:**
- [ ] Yellow sparks: Trigger only when crossing 50% threshold (not every frame)
- [ ] Red warning: Trigger only when crossing 10% threshold
- [ ] Defeat explosion: Triggers on downbeat if Conductor available
- [ ] Particles don't trigger when crossing threshold upward (healing)

**Health Text:**
- [ ] Displays "100%" at full health
- [ ] Updates correctly: "75%", "50%", "10%", "0%"
- [ ] Text centered on bar

**Performance:**
- [ ] No errors in console: `get_godot_errors`
- [ ] Shader compiles without warnings
- [ ] Frame rate stable (60fps)
- [ ] Particle effects don't cause lag

### Integration Testing
- [ ] Vibe bar connects to Combatant.health_changed signal
- [ ] Vibe bar updates when Combatant.take_damage() called
- [ ] Vibe bar updates when Combatant.heal() called
- [ ] Defeat animation syncs with Conductor.downbeat (if available)
- [ ] Multiple vibe bars can exist simultaneously (player + enemy)
- [ ] Vibe bars independent (damaging one doesn't affect other)

### Code Quality
- [ ] No GDScript errors: `get_godot_errors`
- [ ] No shader compilation errors
- [ ] All signals emit correctly
- [ ] Type hints present throughout
- [ ] No null reference errors

### Visual Polish
- [ ] Color transitions are smooth (no jarring jumps)
- [ ] Pulse animation looks good (not too fast/slow)
- [ ] Particle effects visually distinct
- [ ] Health text readable
- [ ] Overall "feel" is satisfying

**Expected Results:**
- Shader compilation: SUCCESS
- Test scene runs: NO ERRORS
- Color transitions: SMOOTH
- Particle triggers: SINGLE BURST per threshold
- Performance: 60fps stable
- Integration: Works with Combatant from S04

---

## Gotchas & Known Issues

### Godot 4.5 Specific

**Shader Uniform Syntax:**
- ✅ Correct: `uniform vec4 color : source_color`
- ❌ Wrong: `uniform vec4 color : hint_color` (Godot 3.x)

**GPUParticles2D:**
- Must set `one_shot = true` and `emitting = false` initially
- Use `.restart()` to trigger, not `.emitting = true` for one-shot particles

**AnimationPlayer Loop:**
- Set via animation properties, not AnimationPlayer properties
- Loop mode: In animation resource, not player node

### System-Specific

**Threshold Detection:**
- Must compare previous_health vs current_health to detect crossings
- Don't trigger particles every frame health is below threshold!
- Pattern in code:
  ```gdscript
  if old_percent > 0.5 and new_percent <= 0.5:
      trigger_yellow_sparkles()  # Only once!
  ```

**Shader Material Setup:**
- Cannot be created programmatically in Tier 1 (GDScript file creation)
- MUST be set up in Godot editor by Tier 2 agent
- Verify shader loads correctly before testing

**Tween Management:**
- Must kill old tween before creating new one: `active_tween.kill()`
- Prevents multiple tweens fighting over same parameter

**Conductor Integration:**
- System gracefully degrades if Conductor not found
- Test both with and without Conductor autoload

### Integration Warnings

**Combatant Signal Format:**
- health_changed expects: `(current_hp: int, max_hp: int, delta: int)`
- Ensure S04 Combatant emits this exact signature

**Multiple Vibe Bars:**
- Each vibe bar instance is independent
- Don't share shader materials between instances (creates instance-specific material)

**Particle Position:**
- Particles emit from their position relative to parent
- Position at center of bar for best visual effect: `Vector2(100, 15)` for 200x30 bar

---

## Research References

**Tier 1 Research Summary:**
- Godot 4.5 CanvasItem Shaders: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html
- Shader Color Interpolation: Uses `mix()` function with two-stage logic
- GodotShaders.com examples: Highlight shader (4.5 compat), transition shaders
- Progress bar shader patterns: GitHub examples

**Full research notes:** `research/s13-vibebar-research.md`

**Key Insights:**
- `smoothstep()` creates even smoother transitions than linear `mix()`
- `source_color` replaces `hint_color` in Godot 4.x
- GPUParticles2D preferred over CPUParticles2D for performance

---

## Verification Evidence Required

**Tier 2 must provide:**
1. Screenshot of vibe bar at 100% HP (blue): `get_editor_screenshot()`
2. Screenshot of vibe bar at 50% HP (yellow with sparks): `get_editor_screenshot()`
3. Screenshot of vibe bar at 10% HP (red, pulsing): `get_editor_screenshot()`
4. Error log output: `get_godot_errors()` - should be empty
5. Performance metrics: Frame time during transitions
6. Test results: All checkboxes above marked ✅

**Save to:** `evidence/S13-tier2-verification/`

---

## Completion Criteria

**System S13 is complete when:**
- ✅ Vibe bar scene fully configured
- ✅ Shader material applied and working
- ✅ Color transitions smooth (blue → yellow → red)
- ✅ Particle effects trigger at correct thresholds
- ✅ Pulse animation activates below 20% HP
- ✅ Defeat animation syncs with downbeat (if Conductor present)
- ✅ Integration with Combatant (S04) tested
- ✅ Test scene runs without errors
- ✅ Performance acceptable (60fps)
- ✅ All verification criteria pass
- ✅ Visual polish complete

**Next Steps:**
- Other systems can use VibeBar component for health display
- S09 (Dodge/Block) can add more particle effects
- S11 (Enemy AI) can use for enemy health bars
- S22 (NPCs) can use for boss fight health display

---

**HANDOFF STATUS: READY FOR TIER 2**
**Estimated Tier 2 Time:** 2-3 hours (scene config + shader setup + testing)
**Priority:** MEDIUM (visual polish, doesn't block other systems)
**Complexity:** MEDIUM (shader setup requires manual editor work)

---

*Generated by: Claude Code Web Agent*
*Date: 2025-11-18*
*Prompt: 015-s13-color-shift-health-vibe-bar.md*
*Branch: claude/implement-s13-health-vibe-bar-01TtVnF78CYNhNyrBGWeiUVx*
