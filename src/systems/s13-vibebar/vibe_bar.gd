# Godot 4.5 | GDScript 4.5
# System: S13 - Color-Shift Health/Vibe Bar
# Created: 2025-11-18
# Dependencies: S04 (Combat), S01 (Conductor)
#
# Vibe Bar is a visual health indicator that uses shader-based color shifting
# to communicate health state through color:
# - Blue (100% - 51%): Healthy
# - Yellow (50% - 11%): Warning
# - Red (10% - 0%): Critical
#
# Features:
# - Smooth color transitions using shader
# - Particle effects at thresholds (50%, 10%, 0%)
# - Pulse animation below 20% HP
# - Defeat animation synced with Conductor downbeat

extends Control

class_name VibeBar

## Signals

## Emitted when health updates complete (after tween)
signal health_updated(current_percent: float)

## Emitted when a threshold is crossed (50%, 10%, or 0%)
signal threshold_crossed(threshold_name: String, current_percent: float)

## Emitted when defeat animation completes
signal defeat_animation_complete()

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

## Configuration loaded from vibe_bar_config.json
var config: Dictionary = {}

## Color thresholds for state transitions
var thresholds: Dictionary = {
	"high": 1.0,     # 100%
	"mid": 0.5,      # 50%
	"low": 0.1       # 10%
}

## Transition speed for health bar animations (seconds)
var transition_speed: float = 0.3

## Health percentage at which to start pulse effect
var pulse_threshold: float = 0.2  # 20%

## Pulse animation speed multiplier
var pulse_speed: float = 2.0

# ═════════════════════════════════════════════════════════════════════════════
# Node References (set by MCP agent in scene)
# ═════════════════════════════════════════════════════════════════════════════

## Reference to the TextureProgressBar or ColorRect with shader
@onready var health_bar: Control = $HealthBar if has_node("HealthBar") else null

## Reference to health percentage text label
@onready var health_text: Label = $HealthText if has_node("HealthText") else null

## Particle effect references
@onready var yellow_sparkles: GPUParticles2D = $YellowSparkles if has_node("YellowSparkles") else null
@onready var red_warning: GPUParticles2D = $RedWarning if has_node("RedWarning") else null
@onready var defeat_explosion: GPUParticles2D = $DefeatExplosion if has_node("DefeatExplosion") else null

## Animation player for pulse effect
@onready var pulse_animation: AnimationPlayer = $PulseAnimation if has_node("PulseAnimation") else null

# ═════════════════════════════════════════════════════════════════════════════
# Internal State
# ═════════════════════════════════════════════════════════════════════════════

## Current health percentage (0.0 to 1.0)
var current_health_percent: float = 1.0

## Previous health percentage (for threshold detection)
var previous_health_percent: float = 1.0

## Reference to shader material
var shader_material: ShaderMaterial = null

## Active tween for smooth health transitions
var active_tween: Tween = null

## Reference to Conductor autoload for downbeat sync
var conductor: Node = null

## Reference to combatant this vibe bar is tracking
var tracked_combatant: Node = null

## Is pulse animation currently active
var is_pulsing: bool = false

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Load configuration
	_load_config()

	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
	else:
		push_warning("VibeBar: Conductor autoload not found - downbeat sync disabled")

	# Get shader material from health bar node
	if health_bar:
		if health_bar.material and health_bar.material is ShaderMaterial:
			shader_material = health_bar.material as ShaderMaterial
		else:
			push_warning("VibeBar: HealthBar node does not have ShaderMaterial - color transitions disabled")

	# Initialize shader to full health
	_update_shader_parameter(1.0)

	# Update health text
	if health_text:
		health_text.text = "100%%"


## Load configuration from vibe_bar_config.json
func _load_config() -> void:
	var config_path: String = "res://data/vibe_bar_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("VibeBar: vibe_bar_config.json not found, using defaults")
		_use_default_config()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("VibeBar: Failed to open vibe_bar_config.json")
		_use_default_config()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("VibeBar: Failed to parse vibe_bar_config.json: ", json.get_error_message())
		_use_default_config()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("VibeBar: Invalid JSON format in vibe_bar_config.json")
		_use_default_config()
		return

	config = data.get("vibe_bar_config", {})

	# Apply configuration values
	var color_thresholds: Dictionary = config.get("color_thresholds", {})
	thresholds["high"] = color_thresholds.get("high", {}).get("percent", 1.0)
	thresholds["mid"] = color_thresholds.get("mid", {}).get("percent", 0.5)
	thresholds["low"] = color_thresholds.get("low", {}).get("percent", 0.1)

	transition_speed = config.get("transition_speed", 0.3)
	pulse_threshold = config.get("pulse_at_percent", 0.2)
	pulse_speed = config.get("pulse_speed", 2.0)


## Use default configuration
func _use_default_config() -> void:
	config = {
		"color_thresholds": {
			"high": {"percent": 1.0, "color": "#0080FF"},
			"mid": {"percent": 0.5, "color": "#FFFF00"},
			"low": {"percent": 0.1, "color": "#FF0000"}
		},
		"transition_speed": 0.3,
		"pulse_at_percent": 0.2,
		"pulse_speed": 2.0,
		"particle_effects": {
			"yellow_sparks": {"threshold": 0.5, "enabled": true},
			"red_warning": {"threshold": 0.1, "enabled": true},
			"defeat_explosion": {"threshold": 0.0, "enabled": true}
		}
	}

	thresholds = {
		"high": 1.0,
		"mid": 0.5,
		"low": 0.1
	}

	transition_speed = 0.3
	pulse_threshold = 0.2
	pulse_speed = 2.0


# ═════════════════════════════════════════════════════════════════════════════
# Public API
# ═════════════════════════════════════════════════════════════════════════════

## Set up the vibe bar to track a combatant's health
## @param combatant: Combatant node to track (must have health_changed signal)
func track_combatant(combatant: Node) -> void:
	# Disconnect from previous combatant
	if tracked_combatant and tracked_combatant.has_signal("health_changed"):
		tracked_combatant.health_changed.disconnect(_on_combatant_health_changed)
		tracked_combatant.defeated.disconnect(_on_combatant_defeated)

	# Connect to new combatant
	tracked_combatant = combatant

	if tracked_combatant:
		if tracked_combatant.has_signal("health_changed"):
			tracked_combatant.health_changed.connect(_on_combatant_health_changed)
		else:
			push_error("VibeBar: Combatant does not have 'health_changed' signal")

		if tracked_combatant.has_signal("defeated"):
			tracked_combatant.defeated.connect(_on_combatant_defeated)

		# Initialize with current health
		if tracked_combatant.has_method("get_hp_percentage"):
			var hp_percent: float = tracked_combatant.get_hp_percentage()
			update_health(hp_percent)
		elif "max_hp" in tracked_combatant and "current_hp" in tracked_combatant:
			var max_hp: int = tracked_combatant.get("max_hp")
			var current_hp: int = tracked_combatant.get("current_hp")
			update_health(float(current_hp) / float(max_hp) if max_hp > 0 else 0.0)


## Update health bar to new percentage with smooth transition
## @param health_percent: New health percentage (0.0 to 1.0)
## @param instant: Skip transition animation if true
func update_health(health_percent: float, instant: bool = false) -> void:
	# Clamp to valid range
	health_percent = clamp(health_percent, 0.0, 1.0)

	# Store previous health for threshold detection
	previous_health_percent = current_health_percent

	# Check for threshold crossings BEFORE updating
	_check_thresholds(previous_health_percent, health_percent)

	# Update current health
	current_health_percent = health_percent

	# Update health text
	if health_text:
		health_text.text = "%d%%" % int(health_percent * 100.0)

	# Update shader with transition
	if instant:
		_update_shader_parameter(health_percent)
	else:
		_animate_health_change(health_percent)

	# Handle pulse animation
	_update_pulse_state()

	# Emit signal
	health_updated.emit(health_percent)


## Manually trigger a particle effect
## @param effect_name: Name of effect ("yellow_sparkles", "red_warning", "defeat_explosion")
func trigger_particle_effect(effect_name: String) -> void:
	match effect_name:
		"yellow_sparkles", "yellow":
			if yellow_sparkles:
				yellow_sparkles.restart()

		"red_warning", "red":
			if red_warning:
				red_warning.restart()

		"defeat_explosion", "defeat":
			if defeat_explosion:
				defeat_explosion.restart()

		_:
			push_warning("VibeBar: Unknown particle effect '%s'" % effect_name)


## Reset vibe bar to full health
func reset_to_full() -> void:
	update_health(1.0, true)
	previous_health_percent = 1.0

	# Stop pulse animation
	if pulse_animation and is_pulsing:
		pulse_animation.stop()
		is_pulsing = false


# ═════════════════════════════════════════════════════════════════════════════
# Internal Methods
# ═════════════════════════════════════════════════════════════════════════════

## Update shader parameter directly (no animation)
func _update_shader_parameter(health_percent: float) -> void:
	if shader_material:
		shader_material.set_shader_parameter("health_percent", health_percent)


## Animate health change with tween
func _animate_health_change(target_percent: float) -> void:
	# Kill existing tween
	if active_tween:
		active_tween.kill()

	# Create new tween
	active_tween = create_tween()
	active_tween.set_ease(Tween.EASE_OUT)
	active_tween.set_trans(Tween.TRANS_CUBIC)

	# Tween the shader parameter
	active_tween.tween_method(
		_update_shader_parameter,
		previous_health_percent,
		target_percent,
		transition_speed
	)


## Check if health crossed any thresholds
func _check_thresholds(old_percent: float, new_percent: float) -> void:
	var particle_config: Dictionary = config.get("particle_effects", {})

	# Check 50% threshold (yellow sparkles)
	if old_percent > 0.5 and new_percent <= 0.5:
		if particle_config.get("yellow_sparks", {}).get("enabled", true):
			trigger_particle_effect("yellow_sparkles")
		threshold_crossed.emit("mid", new_percent)

	# Check 10% threshold (red warning)
	if old_percent > 0.1 and new_percent <= 0.1:
		if particle_config.get("red_warning", {}).get("enabled", true):
			trigger_particle_effect("red_warning")
		threshold_crossed.emit("low", new_percent)

	# Check 0% threshold (defeat)
	if old_percent > 0.0 and new_percent <= 0.0:
		# Defeat explosion handled separately with downbeat sync
		threshold_crossed.emit("defeat", new_percent)


## Update pulse animation state based on health
func _update_pulse_state() -> void:
	if not pulse_animation:
		return

	# Start pulse if below threshold and not already pulsing
	if current_health_percent < pulse_threshold and not is_pulsing:
		pulse_animation.speed_scale = pulse_speed
		pulse_animation.play("pulse")
		is_pulsing = true

	# Stop pulse if above threshold
	elif current_health_percent >= pulse_threshold and is_pulsing:
		pulse_animation.stop()
		is_pulsing = false


# ═════════════════════════════════════════════════════════════════════════════
# Signal Handlers
# ═════════════════════════════════════════════════════════════════════════════

## Called when tracked combatant's health changes
## @param current_hp: New current HP
## @param max_hp: Maximum HP
## @param delta: HP change amount (negative for damage, positive for healing)
func _on_combatant_health_changed(current_hp: int, max_hp: int, delta: int) -> void:
	var health_percent: float = float(current_hp) / float(max_hp) if max_hp > 0 else 0.0
	update_health(health_percent)


## Called when tracked combatant is defeated (HP <= 0)
## @param killer: Combatant that defeated this one (may be null)
func _on_combatant_defeated(killer: Node = null) -> void:
	# Wait for downbeat before playing defeat animation
	if conductor and conductor.has_signal("downbeat"):
		await conductor.downbeat

	# Play defeat explosion particles
	var particle_config: Dictionary = config.get("particle_effects", {})
	if particle_config.get("defeat_explosion", {}).get("enabled", true):
		trigger_particle_effect("defeat_explosion")

	# Stop pulse animation
	if pulse_animation and is_pulsing:
		pulse_animation.stop()
		is_pulsing = false

	# Emit completion signal
	defeat_animation_complete.emit()


# ═════════════════════════════════════════════════════════════════════════════
# Utility Methods
# ═════════════════════════════════════════════════════════════════════════════

## Get current health percentage
func get_current_health_percent() -> float:
	return current_health_percent


## Get current vibe state as string
func get_vibe_state() -> String:
	if current_health_percent > 0.5:
		return "high"
	elif current_health_percent > 0.1:
		return "mid"
	else:
		return "low"


## Check if vibe bar is showing critical health
func is_critical() -> bool:
	return current_health_percent <= 0.1


## Check if pulse animation should be active
func should_pulse() -> bool:
	return current_health_percent < pulse_threshold
