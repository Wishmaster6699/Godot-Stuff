# HANDOFF: S10 - Special Moves System

**From:** Tier 1 (Claude Code Web)
**To:** Tier 2 (Godot MCP Agent)
**Date:** 2025-11-18
**Status:** READY FOR TIER 2

---

## System Overview

**Purpose:** Button combo system with rhythm-gated execution for powerful special attacks
**Type:** Combat Enhancement System
**Dependencies:** S01 (Conductor upbeat), S02 (InputManager), S04 (Combat), S07 (Weapons), S09 (Dodge)
**Blocks:** None (final combat system complete)

This system implements powerful special moves triggered by button combos that can ONLY be executed on Conductor upbeats (beats 2 and 4). Each weapon type has unique special moves with resource costs (stamina + energy), damage multipliers, cooldowns, and visual effects. Integrates with the input buffer from S02 for combo detection.

---

## Files Created by Tier 1

### GDScript Files
- ✅ `res://src/systems/s10-specialmoves/special_moves_system.gd` - Complete special moves implementation
  - Combo detection using InputManager buffer (200ms window)
  - Upbeat rhythm gating (only executes on beats 2 and 4)
  - Resource system (stamina + energy with regeneration)
  - Special move execution with damage multipliers
  - Weapon-specific move filtering
  - Cooldown management per move
  - Integration with S01, S02, S04, S07, S09

### JSON Data Files
- ✅ `res://src/systems/s10-specialmoves/special_moves_config.json` - System configuration
  - Combo window: 200ms
  - Upbeat window: 100ms
  - Resource settings: stamina (100 max), energy (50 max)
  - Regeneration rates

- ✅ `res://data/special_moves.json` - 18 special move definitions
  - 3 sword moves (Spin Slash, Thrust, Rising Slash)
  - 3 axe moves (Overhead Smash, Whirlwind, Cleave)
  - 3 spear moves (Impale, Javelin Toss, Sweeping Strike)
  - 3 bow moves (Multi Shot, Piercing Arrow, Rain of Arrows)
  - 4 staff moves (Fireball, Ice Lance, Lightning Strike, Arcane Blast)
  - 2 universal moves (Combo Finisher, Perfect Counter)

**All files validated:** Syntax ✓ | Type hints ✓ | Documentation ✓ | JSON valid ✓

---

## Godot MCP Commands for Tier 2

### Step 1: Create Test Scene

Create a comprehensive test scene to verify combo detection, upbeat gating, resource costs, and weapon-specific moves.

```bash
# Create test scene
create_scene res://tests/test_special_moves.tscn Node2D TestSpecialMoves

# Add player with special moves system
add_node res://tests/test_special_moves.tscn CharacterBody2D Player TestSpecialMoves
add_node res://tests/test_special_moves.tscn Sprite2D PlayerSprite Player
add_node res://tests/test_special_moves.tscn CollisionShape2D PlayerCollision Player

# Attach special moves system to player
add_node res://tests/test_special_moves.tscn Node SpecialMovesSystem Player

# Add test dummy enemy
add_node res://tests/test_special_moves.tscn StaticBody2D Dummy TestSpecialMoves
add_node res://tests/test_special_moves.tscn Sprite2D DummySprite Dummy
add_node res://tests/test_special_moves.tscn CollisionShape2D DummyCollision Dummy
add_node res://tests/test_special_moves.tscn Label DummyLabel Dummy

# Add UI canvas layer
add_node res://tests/test_special_moves.tscn CanvasLayer UI TestSpecialMoves
add_node res://tests/test_special_moves.tscn ColorRect UIBackground UI
add_node res://tests/test_special_moves.tscn VBoxContainer MainLayout UIBackground

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 1: Title
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn Label TitleLabel MainLayout

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 2: Upbeat Indicator
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator1 MainLayout
add_node res://tests/test_special_moves.tscn Label UpbeatTitle MainLayout
add_node res://tests/test_special_moves.tscn HBoxContainer UpbeatContainer MainLayout
add_node res://tests/test_special_moves.tscn Label UpbeatStatus UpbeatContainer
add_node res://tests/test_special_moves.tscn ProgressBar UpbeatBar UpbeatContainer

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 3: Resource Bars
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator2 MainLayout
add_node res://tests/test_special_moves.tscn Label ResourceTitle MainLayout

# Stamina bar
add_node res://tests/test_special_moves.tscn HBoxContainer StaminaContainer MainLayout
add_node res://tests/test_special_moves.tscn Label StaminaLabel StaminaContainer
add_node res://tests/test_special_moves.tscn ProgressBar StaminaBar StaminaContainer

# Energy bar
add_node res://tests/test_special_moves.tscn HBoxContainer EnergyContainer MainLayout
add_node res://tests/test_special_moves.tscn Label EnergyLabel EnergyContainer
add_node res://tests/test_special_moves.tscn ProgressBar EnergyBar EnergyContainer

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 4: Combo Detection
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator3 MainLayout
add_node res://tests/test_special_moves.tscn Label ComboTitle MainLayout
add_node res://tests/test_special_moves.tscn Label ComboInput MainLayout
add_node res://tests/test_special_moves.tscn Label ComboDetected MainLayout
add_node res://tests/test_special_moves.tscn Label ComboPending MainLayout

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 5: Special Move Feedback
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator4 MainLayout
add_node res://tests/test_special_moves.tscn Label MoveTitle MainLayout
add_node res://tests/test_special_moves.tscn Label MoveExecuted MainLayout
add_node res://tests/test_special_moves.tscn Label MoveDamage MainLayout
add_node res://tests/test_special_moves.tscn Label MoveTiming MainLayout
add_node res://tests/test_special_moves.tscn Label MoveCooldowns MainLayout

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 6: Weapon Selection
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator5 MainLayout
add_node res://tests/test_special_moves.tscn Label WeaponTitle MainLayout
add_node res://tests/test_special_moves.tscn Label CurrentWeapon MainLayout
add_node res://tests/test_special_moves.tscn HBoxContainer WeaponButtons MainLayout

# Weapon selection buttons
add_node res://tests/test_special_moves.tscn Button EquipSword WeaponButtons
add_node res://tests/test_special_moves.tscn Button EquipAxe WeaponButtons
add_node res://tests/test_special_moves.tscn Button EquipSpear WeaponButtons
add_node res://tests/test_special_moves.tscn Button EquipBow WeaponButtons
add_node res://tests/test_special_moves.tscn Button EquipStaff WeaponButtons

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 7: Available Moves List
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator6 MainLayout
add_node res://tests/test_special_moves.tscn Label MovesListTitle MainLayout
add_node res://tests/test_special_moves.tscn ScrollContainer MovesScrollContainer MainLayout
add_node res://tests/test_special_moves.tscn VBoxContainer MovesList MovesScrollContainer

# ═════════════════════════════════════════════════════════════════════════════
# UI Section 8: Instructions
# ═════════════════════════════════════════════════════════════════════════════

add_node res://tests/test_special_moves.tscn HSeparator Separator7 MainLayout
add_node res://tests/test_special_moves.tscn Label InstructionsTitle MainLayout
add_node res://tests/test_special_moves.tscn Label Instructions MainLayout

# ═════════════════════════════════════════════════════════════════════════════
# Visual Effects
# ═════════════════════════════════════════════════════════════════════════════

# Upbeat active indicator (flashes green on upbeat)
add_node res://tests/test_special_moves.tscn ColorRect UpbeatFlash UI

# Special move effect particles
add_node res://tests/test_special_moves.tscn GPUParticles2D SpecialMoveEffect Player

# Combo success flash
add_node res://tests/test_special_moves.tscn ColorRect ComboFlash UI

# Damage number display
add_node res://tests/test_special_moves.tscn Label DamageNumber TestSpecialMoves
```

---

### Step 2: Configure Scene Properties

```bash
# ═════════════════════════════════════════════════════════════════════════════
# Player Setup
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn Player position "Vector2(300, 400)"
update_property res://tests/test_special_moves.tscn PlayerSprite modulate "Color(0.5, 0.7, 1.0, 1.0)"
update_property res://tests/test_special_moves.tscn PlayerSprite texture "res://icon.svg"
update_property res://tests/test_special_moves.tscn PlayerCollision shape "CircleShape2D(radius=16)"

# ═════════════════════════════════════════════════════════════════════════════
# Dummy Enemy Setup
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn Dummy position "Vector2(700, 400)"
update_property res://tests/test_special_moves.tscn DummySprite modulate "Color(1.0, 0.3, 0.3, 1.0)"
update_property res://tests/test_special_moves.tscn DummySprite texture "res://icon.svg"
update_property res://tests/test_special_moves.tscn DummySprite scale "Vector2(1.5, 1.5)"
update_property res://tests/test_special_moves.tscn DummyCollision shape "RectangleShape2D(size=Vector2(64,64))"
update_property res://tests/test_special_moves.tscn DummyLabel text "Training Dummy"
update_property res://tests/test_special_moves.tscn DummyLabel position "Vector2(-40, -60)"
update_property res://tests/test_special_moves.tscn DummyLabel horizontal_alignment 1

# ═════════════════════════════════════════════════════════════════════════════
# UI Background
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn UIBackground color "Color(0.1, 0.1, 0.15, 0.95)"
update_property res://tests/test_special_moves.tscn UIBackground offset_left 10
update_property res://tests/test_special_moves.tscn UIBackground offset_top 10
update_property res://tests/test_special_moves.tscn UIBackground offset_right 450
update_property res://tests/test_special_moves.tscn UIBackground offset_bottom 850

update_property res://tests/test_special_moves.tscn MainLayout offset_left 15
update_property res://tests/test_special_moves.tscn MainLayout offset_top 15
update_property res://tests/test_special_moves.tscn MainLayout offset_right -15
update_property res://tests/test_special_moves.tscn MainLayout offset_bottom -15

# ═════════════════════════════════════════════════════════════════════════════
# Title
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn TitleLabel text "🎮 Special Moves System Test 🎮"
update_property res://tests/test_special_moves.tscn TitleLabel horizontal_alignment 1
update_property res://tests/test_special_moves.tscn TitleLabel add_theme_font_size_override 24

# ═════════════════════════════════════════════════════════════════════════════
# Upbeat Indicator
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn UpbeatTitle text "⏱️ Upbeat Window"
update_property res://tests/test_special_moves.tscn UpbeatTitle add_theme_font_size_override 18

update_property res://tests/test_special_moves.tscn UpbeatStatus text "Waiting..."
update_property res://tests/test_special_moves.tscn UpbeatStatus custom_minimum_size "Vector2(100, 0)"

update_property res://tests/test_special_moves.tscn UpbeatBar min_value 0
update_property res://tests/test_special_moves.tscn UpbeatBar max_value 100
update_property res://tests/test_special_moves.tscn UpbeatBar value 0
update_property res://tests/test_special_moves.tscn UpbeatBar custom_minimum_size "Vector2(250, 24)"
update_property res://tests/test_special_moves.tscn UpbeatBar show_percentage false

# ═════════════════════════════════════════════════════════════════════════════
# Resource Bars
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn ResourceTitle text "💪 Resources"
update_property res://tests/test_special_moves.tscn ResourceTitle add_theme_font_size_override 18

# Stamina
update_property res://tests/test_special_moves.tscn StaminaLabel text "Stamina:"
update_property res://tests/test_special_moves.tscn StaminaLabel custom_minimum_size "Vector2(100, 0)"

update_property res://tests/test_special_moves.tscn StaminaBar min_value 0
update_property res://tests/test_special_moves.tscn StaminaBar max_value 100
update_property res://tests/test_special_moves.tscn StaminaBar value 100
update_property res://tests/test_special_moves.tscn StaminaBar custom_minimum_size "Vector2(250, 24)"
update_property res://tests/test_special_moves.tscn StaminaBar show_percentage true

# Energy
update_property res://tests/test_special_moves.tscn EnergyLabel text "Energy:"
update_property res://tests/test_special_moves.tscn EnergyLabel custom_minimum_size "Vector2(100, 0)"

update_property res://tests/test_special_moves.tscn EnergyBar min_value 0
update_property res://tests/test_special_moves.tscn EnergyBar max_value 50
update_property res://tests/test_special_moves.tscn EnergyBar value 50
update_property res://tests/test_special_moves.tscn EnergyBar custom_minimum_size "Vector2(250, 24)"
update_property res://tests/test_special_moves.tscn EnergyBar show_percentage true

# ═════════════════════════════════════════════════════════════════════════════
# Combo Detection
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn ComboTitle text "🎯 Combo Detection"
update_property res://tests/test_special_moves.tscn ComboTitle add_theme_font_size_override 18

update_property res://tests/test_special_moves.tscn ComboInput text "Input Buffer: []"
update_property res://tests/test_special_moves.tscn ComboInput modulate "Color(0.7, 0.7, 0.7, 1.0)"

update_property res://tests/test_special_moves.tscn ComboDetected text "Detected: None"
update_property res://tests/test_special_moves.tscn ComboDetected modulate "Color(0.3, 1.0, 0.3, 1.0)"

update_property res://tests/test_special_moves.tscn ComboPending text "Pending: No"
update_property res://tests/test_special_moves.tscn ComboPending modulate "Color(1.0, 1.0, 0.3, 1.0)"

# ═════════════════════════════════════════════════════════════════════════════
# Special Move Feedback
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn MoveTitle text "✨ Special Move Execution"
update_property res://tests/test_special_moves.tscn MoveTitle add_theme_font_size_override 18

update_property res://tests/test_special_moves.tscn MoveExecuted text "Last Move: --"
update_property res://tests/test_special_moves.tscn MoveExecuted modulate "Color(1.0, 0.8, 0.2, 1.0)"

update_property res://tests/test_special_moves.tscn MoveDamage text "Damage: --"
update_property res://tests/test_special_moves.tscn MoveDamage modulate "Color(1.0, 0.3, 0.3, 1.0)"

update_property res://tests/test_special_moves.tscn MoveTiming text "Timing: --"
update_property res://tests/test_special_moves.tscn MoveTiming modulate "Color(0.5, 1.0, 1.0, 1.0)"

update_property res://tests/test_special_moves.tscn MoveCooldowns text "Active Cooldowns: None"
update_property res://tests/test_special_moves.tscn MoveCooldowns modulate "Color(0.8, 0.8, 0.8, 1.0)"

# ═════════════════════════════════════════════════════════════════════════════
# Weapon Selection
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn WeaponTitle text "⚔️ Weapon Selection"
update_property res://tests/test_special_moves.tscn WeaponTitle add_theme_font_size_override 18

update_property res://tests/test_special_moves.tscn CurrentWeapon text "Current: Sword"
update_property res://tests/test_special_moves.tscn CurrentWeapon modulate "Color(1.0, 1.0, 0.5, 1.0)"

# Weapon buttons
update_property res://tests/test_special_moves.tscn EquipSword text "Sword"
update_property res://tests/test_special_moves.tscn EquipAxe text "Axe"
update_property res://tests/test_special_moves.tscn EquipSpear text "Spear"
update_property res://tests/test_special_moves.tscn EquipBow text "Bow"
update_property res://tests/test_special_moves.tscn EquipStaff text "Staff"

# ═════════════════════════════════════════════════════════════════════════════
# Available Moves List
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn MovesListTitle text "📋 Available Moves"
update_property res://tests/test_special_moves.tscn MovesListTitle add_theme_font_size_override 18

update_property res://tests/test_special_moves.tscn MovesScrollContainer custom_minimum_size "Vector2(0, 180)"

# ═════════════════════════════════════════════════════════════════════════════
# Instructions
# ═════════════════════════════════════════════════════════════════════════════

update_property res://tests/test_special_moves.tscn InstructionsTitle text "ℹ️ Instructions"
update_property res://tests/test_special_moves.tscn InstructionsTitle add_theme_font_size_override 18

update_property res://tests/test_special_moves.tscn Instructions text "1. Watch the Upbeat indicator (flashes GREEN on beats 2 & 4)
2. Select a weapon type using the buttons
3. Try button combos: A+B, A+Down, B+B+B, etc.
4. Execute special moves ONLY during upbeat window
5. Monitor resource costs (stamina/energy)
6. Cooldowns prevent spamming same move"
update_property res://tests/test_special_moves.tscn Instructions autowrap_mode 3
update_property res://tests/test_special_moves.tscn Instructions custom_minimum_size "Vector2(0, 120)"

# ═════════════════════════════════════════════════════════════════════════════
# Visual Effects
# ═════════════════════════════════════════════════════════════════════════════

# Upbeat flash (full screen green flash)
update_property res://tests/test_special_moves.tscn UpbeatFlash color "Color(0.0, 1.0, 0.0, 0.0)"
update_property res://tests/test_special_moves.tscn UpbeatFlash anchor_right 1.0
update_property res://tests/test_special_moves.tscn UpbeatFlash anchor_bottom 1.0
update_property res://tests/test_special_moves.tscn UpbeatFlash mouse_filter 2

# Special move particles
update_property res://tests/test_special_moves.tscn SpecialMoveEffect emitting false
update_property res://tests/test_special_moves.tscn SpecialMoveEffect amount 50
update_property res://tests/test_special_moves.tscn SpecialMoveEffect lifetime 1.0
update_property res://tests/test_special_moves.tscn SpecialMoveEffect one_shot true

# Combo success flash (orange flash)
update_property res://tests/test_special_moves.tscn ComboFlash color "Color(1.0, 0.5, 0.0, 0.0)"
update_property res://tests/test_special_moves.tscn ComboFlash anchor_right 1.0
update_property res://tests/test_special_moves.tscn ComboFlash anchor_bottom 1.0
update_property res://tests/test_special_moves.tscn ComboFlash mouse_filter 2

# Damage number
update_property res://tests/test_special_moves.tscn DamageNumber text ""
update_property res://tests/test_special_moves.tscn DamageNumber position "Vector2(700, 300)"
update_property res://tests/test_special_moves.tscn DamageNumber modulate "Color(1.0, 0.0, 0.0, 0.0)"
update_property res://tests/test_special_moves.tscn DamageNumber horizontal_alignment 1
update_property res://tests/test_special_moves.tscn DamageNumber add_theme_font_size_override 48
```

---

### Step 3: Attach Scripts

```bash
# Attach special moves system script
attach_script res://tests/test_special_moves.tscn SpecialMovesSystem res://src/systems/s10-specialmoves/special_moves_system.gd

# Create and attach test controller script
create_script res://tests/test_special_moves_controller.gd
attach_script res://tests/test_special_moves.tscn TestSpecialMoves res://tests/test_special_moves_controller.gd
```

---

### Step 4: Create Test Controller Script

The test controller script needs to be created to wire up all the UI elements and handle weapon switching, visual feedback, etc.

**File:** `res://tests/test_special_moves_controller.gd`

```gdscript
extends Node2D

# References
@onready var special_moves: SpecialMovesSystem = $Player/SpecialMovesSystem
@onready var conductor: Node = get_node("/root/Conductor") if has_node("/root/Conductor") else null
@onready var input_manager: Node = get_node("/root/InputManager") if has_node("/root/InputManager") else null

# UI References
@onready var upbeat_status: Label = $UI/UIBackground/MainLayout/UpbeatContainer/UpbeatStatus
@onready var upbeat_bar: ProgressBar = $UI/UIBackground/MainLayout/UpbeatContainer/UpbeatBar
@onready var stamina_bar: ProgressBar = $UI/UIBackground/MainLayout/StaminaContainer/StaminaBar
@onready var energy_bar: ProgressBar = $UI/UIBackground/MainLayout/EnergyContainer/EnergyBar
@onready var combo_input: Label = $UI/UIBackground/MainLayout/ComboInput
@onready var combo_detected: Label = $UI/UIBackground/MainLayout/ComboDetected
@onready var combo_pending: Label = $UI/UIBackground/MainLayout/ComboPending
@onready var move_executed: Label = $UI/UIBackground/MainLayout/MoveExecuted
@onready var move_damage: Label = $UI/UIBackground/MainLayout/MoveDamage
@onready var move_timing: Label = $UI/UIBackground/MainLayout/MoveTiming
@onready var move_cooldowns: Label = $UI/UIBackground/MainLayout/MoveCooldowns
@onready var current_weapon: Label = $UI/UIBackground/MainLayout/CurrentWeapon
@onready var moves_list: VBoxContainer = $UI/UIBackground/MainLayout/MovesScrollContainer/MovesList
@onready var upbeat_flash: ColorRect = $UI/UpbeatFlash
@onready var combo_flash: ColorRect = $UI/ComboFlash
@onready var damage_number: Label = $DamageNumber

func _ready() -> void:
	# Connect to special moves signals
	if special_moves:
		special_moves.combo_detected.connect(_on_combo_detected)
		special_moves.special_move_executed.connect(_on_special_move_executed)
		special_moves.special_move_failed.connect(_on_special_move_failed)
		special_moves.resources_changed.connect(_on_resources_changed)
		special_moves.cooldown_complete.connect(_on_cooldown_complete)

	# Connect to conductor signals
	if conductor:
		conductor.upbeat.connect(_on_upbeat)
		conductor.beat.connect(_on_beat)

	# Connect weapon buttons
	$UI/UIBackground/MainLayout/WeaponButtons/EquipSword.pressed.connect(_on_equip_weapon.bind("sword"))
	$UI/UIBackground/MainLayout/WeaponButtons/EquipAxe.pressed.connect(_on_equip_weapon.bind("axe"))
	$UI/UIBackground/MainLayout/WeaponButtons/EquipSpear.pressed.connect(_on_equip_weapon.bind("spear"))
	$UI/UIBackground/MainLayout/WeaponButtons/EquipBow.pressed.connect(_on_equip_weapon.bind("bow"))
	$UI/UIBackground/MainLayout/WeaponButtons/EquipStaff.pressed.connect(_on_equip_weapon.bind("staff"))

	# Initialize UI
	_update_moves_list()
	_update_resources_ui()

func _process(_delta: float) -> void:
	# Update input buffer display
	if input_manager and input_manager.has_method("get_input_buffer"):
		var buffer: Array = input_manager.get_input_buffer()
		var buffer_str: String = "Input Buffer: ["
		for i in range(min(5, buffer.size())):  # Show last 5 inputs
			var input_data: Dictionary = buffer[buffer.size() - 1 - i]
			buffer_str += input_data.get("action", "?")
			if i < min(4, buffer.size() - 1):
				buffer_str += ", "
		buffer_str += "]"
		combo_input.text = buffer_str

	# Update upbeat status
	if special_moves:
		if special_moves.is_upbeat_active():
			upbeat_status.text = "ACTIVE!"
			upbeat_status.modulate = Color(0.3, 1.0, 0.3)
			upbeat_bar.value = 100
		else:
			upbeat_status.text = "Waiting..."
			upbeat_status.modulate = Color(0.7, 0.7, 0.7)
			upbeat_bar.value = 0

		# Update combo pending
		combo_pending.text = "Pending: Yes" if special_moves.combo_pending else "Pending: No"

		# Update cooldowns
		_update_cooldowns_display()

func _on_upbeat(_beat_number: int) -> void:
	# Flash green on upbeat
	upbeat_flash.modulate = Color(0.0, 1.0, 0.0, 0.3)
	var tween: Tween = create_tween()
	tween.tween_property(upbeat_flash, "modulate", Color(0.0, 1.0, 0.0, 0.0), 0.2)

func _on_beat(_beat_number: int) -> void:
	pass

func _on_combo_detected(combo_pattern: String, move_id: String) -> void:
	combo_detected.text = "Detected: %s (%s)" % [move_id, combo_pattern]

	# Flash orange on combo detection
	combo_flash.modulate = Color(1.0, 0.5, 0.0, 0.3)
	var tween: Tween = create_tween()
	tween.tween_property(combo_flash, "modulate", Color(1.0, 0.5, 0.0, 0.0), 0.3)

func _on_special_move_executed(move_data: Dictionary, damage: int, timing_quality: String) -> void:
	var move_name: String = move_data.get("name", "Unknown")
	move_executed.text = "Last Move: %s" % move_name
	move_damage.text = "Damage: %d" % damage
	move_timing.text = "Timing: %s" % timing_quality.to_upper()

	# Show damage number
	damage_number.text = str(damage)
	damage_number.position = Vector2(700, 300)
	damage_number.modulate = Color(1.0, 0.0, 0.0, 1.0)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_number, "position", Vector2(700, 200), 1.0)
	tween.tween_property(damage_number, "modulate", Color(1.0, 0.0, 0.0, 0.0), 1.0)

func _on_special_move_failed(_move_id: String, reason: String) -> void:
	move_executed.text = "FAILED: %s" % reason
	move_damage.text = "Damage: --"
	move_timing.text = "Timing: --"

func _on_resources_changed(_stamina: int, _energy: int) -> void:
	_update_resources_ui()

func _on_cooldown_complete(_move_id: String) -> void:
	_update_cooldowns_display()

func _on_equip_weapon(weapon_type: String) -> void:
	if special_moves:
		special_moves.set_weapon_type(weapon_type)
		current_weapon.text = "Current: %s" % weapon_type.capitalize()
		_update_moves_list()

func _update_resources_ui() -> void:
	if special_moves:
		var resources: Dictionary = special_moves.get_resources()
		var max_resources: Dictionary = special_moves.get_max_resources()

		stamina_bar.value = resources.get("stamina", 0)
		stamina_bar.max_value = max_resources.get("stamina", 100)

		energy_bar.value = resources.get("energy", 0)
		energy_bar.max_value = max_resources.get("energy", 50)

func _update_moves_list() -> void:
	# Clear existing
	for child in moves_list.get_children():
		child.queue_free()

	if not special_moves:
		return

	var available_moves: Array = special_moves.get_available_moves()
	for move in available_moves:
		var move_label: Label = Label.new()
		var combo_str: String = ""
		var combo: Array = move.get("button_combo", [])
		for i in range(combo.size()):
			combo_str += combo[i]
			if i < combo.size() - 1:
				combo_str += "+"

		var cost: Dictionary = move.get("resource_cost", {})
		var cost_str: String = "S:%d E:%d" % [cost.get("stamina", 0), cost.get("energy", 0)]

		move_label.text = "%s [%s] - %s" % [move.get("name", "?"), combo_str, cost_str]
		move_label.modulate = Color(0.8, 0.8, 1.0)
		moves_list.add_child(move_label)

func _update_cooldowns_display() -> void:
	if not special_moves:
		return

	var cooldowns_text: String = "Active Cooldowns: "
	var has_cooldowns: bool = false

	var available_moves: Array = special_moves.get_available_moves()
	for move in available_moves:
		var move_id: String = move.get("id", "")
		if special_moves.is_move_on_cooldown(move_id):
			has_cooldowns = true
			var remaining: float = special_moves.get_cooldown_remaining(move_id)
			cooldowns_text += "%s (%.1fs) " % [move.get("name", "?"), remaining]

	if not has_cooldowns:
		cooldowns_text += "None"

	move_cooldowns.text = cooldowns_text
```

**MCP Command to create this script:**

```bash
create_script res://tests/test_special_moves_controller.gd
# Then paste the above content into the file
```

---

### Step 5: Testing Checklist

Use Godot MCP tools to test:

```bash
# Start conductor (if not auto-started)
# Run test scene
play_scene res://tests/test_special_moves.tscn

# Check for errors
get_godot_errors
```

### Verification Checklist:

**Core Functionality:**
- [ ] Test scene runs without errors
- [ ] Conductor is running (upbeat indicator flashes green on beats 2 and 4)
- [ ] Input buffer tracks button presses (displayed in UI)
- [ ] Combo detection works for button sequences (A+B, A+Down, B+B+B, etc.)
- [ ] Special moves ONLY execute during upbeat window (green flash)
- [ ] Special moves fail to execute outside upbeat window

**Resource System:**
- [ ] Resource costs deducted when special move executes (stamina/energy bars decrease)
- [ ] Special move execution blocked if insufficient resources (shows "FAILED: insufficient_resources")
- [ ] Stamina regenerates at 10/s
- [ ] Energy regenerates at 5/s
- [ ] Resource bars display correctly and update in real-time

**Weapon-Specific Moves:**
- [ ] Equipping different weapons changes available special moves (moves list updates)
- [ ] Sword has 3 moves (Spin Slash, Thrust, Rising Slash)
- [ ] Axe has 3 moves (Overhead Smash, Whirlwind, Cleave)
- [ ] Spear has 3 moves (Impale, Javelin Toss, Sweeping Strike)
- [ ] Bow has 3 moves (Multi Shot, Piercing Arrow, Rain of Arrows)
- [ ] Staff has 4 moves (Fireball, Ice Lance, Lightning Strike, Arcane Blast)
- [ ] Universal moves (Combo Finisher, Perfect Counter) appear for all weapons

**Timing and Effects:**
- [ ] Damage multiplier applied correctly (displayed in damage number)
- [ ] Perfect timing on upbeat gives 20% damage bonus
- [ ] Visual feedback: Green flash on upbeat
- [ ] Visual feedback: Orange flash on combo detection
- [ ] Visual feedback: Damage numbers float upward and fade
- [ ] Move names and effects displayed in UI
- [ ] Timing quality shown ("PERFECT", "GOOD", "MISS")

**Cooldown System:**
- [ ] Cooldown prevents spamming same special move (3-5s depending on move)
- [ ] Cooldowns displayed in UI with time remaining
- [ ] Multiple moves can be on cooldown simultaneously
- [ ] Attempting move on cooldown shows "FAILED: on_cooldown"

**Combo Detection:**
- [ ] Combo detection has 200ms window for completion
- [ ] Combo shows as "Pending: Yes" after detection
- [ ] Pending combo executes automatically when upbeat becomes active
- [ ] Multiple rapid combos don't interfere with each other

### Integration Points:

**S01 (Conductor):**
- [ ] Upbeat signal gates special move execution (beats 2 and 4)
- [ ] Timing quality evaluation for damage bonus
- [ ] Beat synchronization for visual feedback

**S02 (InputManager):**
- [ ] Input buffer used for combo detection
- [ ] Button press signals trigger combo checking
- [ ] 200ms combo window uses buffer timestamps

**S04 (Combat):**
- [ ] Damage multiplier applied to base attack damage
- [ ] Integration with combatant system (if available)
- [ ] Combat state awareness

**S07 (Weapons):**
- [ ] Weapon-specific moves loaded from database
- [ ] Weapon type filtering works correctly
- [ ] ItemDatabase integration (if available)

**S09 (Dodge):**
- [ ] Combo chains can include dodge cancels (future enhancement)
- [ ] Shared stamina resource with dodge system
- [ ] Resource regeneration coordinated

---

## Completion Checklist

After all verification passes:

1. **Update COORDINATION-DASHBOARD.md:**
   - Mark S10 as complete
   - Release any locked resources
   - Note: Combat system complete (S04, S09, S10 all integrated)
   - Document that all combat mechanics are now available

2. **Run Quality Gates:**
   ```bash
   # Integration tests (if framework available)
   IntegrationTestSuite.run_all_tests()

   # Performance profiling
   PerformanceProfiler.profile_system("S10")

   # Quality gates
   check_quality_gates("S10")

   # Checkpoint validation
   validate_checkpoint("S10")
   ```

3. **Create Knowledge Base Entry:**
   - Document any non-trivial patterns used
   - Record combo detection algorithms
   - Note rhythm timing integration patterns
   - Save to `knowledge-base/patterns/s10-special-moves-patterns.md`

---

## Known Issues and Limitations

**Current Implementation:**
- Combo detection uses simple pattern matching (future: sequence detection with wildcards)
- Visual effects use placeholder particles (requires art assets from ASSET-PIPELINE.md)
- Animation system not fully integrated (requires AnimationTree setup)
- Sound effects not implemented (requires audio assets)

**Future Enhancements (Post-S10):**
- Combo cancels from dodge into special moves (S09 integration)
- Chain bonus multipliers for consecutive special moves
- Weapon-specific particle effects and animations
- Advanced combo patterns (charge moves, held buttons)
- Special move upgrade system (increased damage, reduced cooldown)

---

## System Architecture Summary

```
SpecialMovesSystem (Node)
├── Combo Detection
│   ├── InputManager buffer monitoring
│   ├── Pattern matching (200ms window)
│   └── Weapon-specific filtering
├── Upbeat Gating
│   ├── Conductor.upbeat signal listener
│   ├── Upbeat window (100ms)
│   └── Pending combo execution
├── Resource Management
│   ├── Stamina (max 100, regen 10/s)
│   ├── Energy (max 50, regen 5/s)
│   └── Cost validation and deduction
├── Move Execution
│   ├── Damage calculation (base * multiplier)
│   ├── Timing bonus (perfect +20%)
│   └── Effect application
└── Cooldown System
    ├── Per-move timers
    ├── Independent cooldowns
    └── Completion signals
```

**Database Structure:**
- `special_moves.json`: 18 moves across 5 weapon types + 2 universal
- Each move: id, name, weapon_type, combo, costs, multiplier, effects, cooldown

**Integration Flow:**
1. Player presses buttons → InputManager buffer
2. SpecialMovesSystem detects combo pattern
3. Combo marked as pending
4. Conductor emits upbeat signal
5. System checks: upbeat active + sufficient resources + not on cooldown
6. Move executes: damage calculated, resources deducted, cooldown started
7. Signals emitted for UI/VFX updates

---

## Final Notes

This system completes the combat enhancement trilogy (S04 → S09 → S10). All combat mechanics are now available:
- Basic attacks with rhythm timing (S04)
- Dodge and block for defense (S09)
- Special moves for powerful offense (S10)

The system is fully data-driven (special_moves.json), making it easy to add new moves, adjust balance, and expand weapon types without code changes.

**Next Systems:**
- S11 (Enemy AI) - Use special moves in enemy behavior trees
- S12 (Monster Database) - Define which special moves enemies can use
- S13 (Vibe Bar) - Link special moves to visual/audio feedback

---

**END OF HANDOFF DOCUMENT**
