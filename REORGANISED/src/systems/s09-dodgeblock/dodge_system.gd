# Godot 4.5 | GDScript 4.5
# System: S09 - Dodge & Block Mechanics
# Created: 2025-11-18
# Dependencies: S01 (Conductor), S04 (Combat), S08 (Equipment)
#
# DodgeSystem manages the dodge mechanic with rhythm timing, i-frames, and cooldowns.
# Dodging grants temporary invulnerability (i-frames) with duration based on timing quality.
# Perfect timing on beat = longer i-frames, better visual feedback.

extends Node
class_name DodgeSystem

## Signals for dodge events

## Emitted when dodge is attempted (before validation)
signal dodge_attempted(input_timestamp: float)

## Emitted when dodge is successfully executed
signal dodge_executed(timing_quality: String, iframe_duration: float)

## Emitted when dodge fails (on cooldown or other reason)
signal dodge_failed(reason: String)

## Emitted when i-frames begin
signal iframes_started(duration: float)

## Emitted when i-frames end
signal iframes_ended()

## Emitted when cooldown completes
signal cooldown_complete()

# ═════════════════════════════════════════════════════════════════════════════
# Configuration (loaded from dodge_block_config.json)
# ═════════════════════════════════════════════════════════════════════════════

## Configuration dictionary loaded from JSON
var config: Dictionary = {}

## Dodge cooldown in seconds
var dodge_cooldown: float = 0.5

## I-frame duration for perfect timing (in seconds)
var iframe_duration_perfect: float = 0.3

## I-frame duration for good timing (in seconds)
var iframe_duration_good: float = 0.2

## I-frame duration for miss timing (in seconds)
var iframe_duration_miss: float = 0.1

## Dodge distance in pixels
var dodge_distance: float = 64.0

## Dodge speed in pixels per second
var dodge_speed: float = 400.0

# ═════════════════════════════════════════════════════════════════════════════
# State Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Is dodge currently on cooldown
var is_on_cooldown: bool = false

## Cooldown timer remaining
var cooldown_timer: float = 0.0

## Are i-frames currently active
var iframes_active: bool = false

## I-frame timer remaining
var iframe_timer: float = 0.0

## Current timing quality of last dodge ("perfect", "good", "miss")
var last_dodge_quality: String = ""

# ═════════════════════════════════════════════════════════════════════════════
# Equipment Modifiers (from S08)
# ═════════════════════════════════════════════════════════════════════════════

## Cooldown modifier from equipment (e.g., -0.1 = 10% faster)
var cooldown_modifier: float = 0.0

## Dodge distance modifier from equipment (e.g., 1.2 = 20% further)
var distance_modifier: float = 1.0

# ═════════════════════════════════════════════════════════════════════════════
# References
# ═════════════════════════════════════════════════════════════════════════════

## Reference to Conductor for rhythm timing
var conductor: Node = null

## Reference to parent combatant (if attached to one)
var combatant: Node = null

## Reference to equipment manager (if available)
var equipment_manager: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
	else:
		push_warning("DodgeSystem: Conductor autoload not found - rhythm timing disabled")

	# Get parent combatant reference
	if get_parent() is Combatant:
		combatant = get_parent()
		print("DodgeSystem: Attached to combatant: %s" % combatant.name)

	# Load configuration
	_load_configuration()

	print("DodgeSystem: Initialized (Cooldown: %.2fs, Perfect i-frames: %.2fs)" % [dodge_cooldown, iframe_duration_perfect])


## Load dodge configuration from JSON file
func _load_configuration() -> void:
	var config_path: String = "res://src/systems/s09-dodgeblock/dodge_block_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("DodgeSystem: dodge_block_config.json not found at %s, using defaults" % config_path)
		_use_default_configuration()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("DodgeSystem: Failed to open dodge_block_config.json")
		_use_default_configuration()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("DodgeSystem: Failed to parse dodge_block_config.json: %s" % json.get_error_message())
		_use_default_configuration()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("DodgeSystem: Invalid JSON format in dodge_block_config.json")
		_use_default_configuration()
		return

	config = data.get("dodge_block_config", {})

	# Apply dodge configuration
	var dodge_config: Dictionary = config.get("dodge", {})
	dodge_cooldown = dodge_config.get("cooldown_s", 0.5)
	iframe_duration_perfect = dodge_config.get("iframe_duration_perfect", 0.3)
	iframe_duration_good = dodge_config.get("iframe_duration_good", 0.2)
	iframe_duration_miss = dodge_config.get("iframe_duration_miss", 0.1)
	dodge_distance = dodge_config.get("dodge_distance", 64.0)
	dodge_speed = dodge_config.get("dodge_speed", 400.0)


## Use default configuration if JSON loading fails
func _use_default_configuration() -> void:
	config = {
		"dodge": {
			"cooldown_s": 0.5,
			"iframe_duration_perfect": 0.3,
			"iframe_duration_good": 0.2,
			"iframe_duration_miss": 0.1,
			"dodge_distance": 64.0,
			"dodge_speed": 400.0
		}
	}

	dodge_cooldown = 0.5
	iframe_duration_perfect = 0.3
	iframe_duration_good = 0.2
	iframe_duration_miss = 0.1
	dodge_distance = 64.0
	dodge_speed = 400.0


## Update timers each frame
func _process(delta: float) -> void:
	# Update cooldown timer
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_on_cooldown = false
			cooldown_timer = 0.0
			cooldown_complete.emit()

	# Update i-frame timer
	if iframes_active:
		iframe_timer -= delta
		if iframe_timer <= 0.0:
			_end_iframes()


# ═════════════════════════════════════════════════════════════════════════════
# Core Dodge Logic
# ═════════════════════════════════════════════════════════════════════════════

## Attempt to perform a dodge
## @param input_timestamp: Time of dodge input for rhythm timing (use Time.get_ticks_msec() / 1000.0)
## @return bool: True if dodge was successful, false if failed
func perform_dodge(input_timestamp: float = 0.0) -> bool:
	# Emit attempted signal
	dodge_attempted.emit(input_timestamp)

	# Check if dodge is on cooldown
	if is_on_cooldown:
		dodge_failed.emit("on_cooldown")
		return false

	# Use current time if no timestamp provided
	if input_timestamp <= 0.0:
		input_timestamp = Time.get_ticks_msec() / 1000.0

	# Get timing quality from Conductor
	var timing_quality: String = "miss"
	if conductor != null:
		timing_quality = conductor.get_timing_quality(input_timestamp)

	# Calculate i-frame duration based on timing quality
	var iframe_duration: float = _get_iframe_duration(timing_quality)

	# Apply equipment modifiers
	iframe_duration = _apply_equipment_modifiers(iframe_duration)

	# Store timing quality
	last_dodge_quality = timing_quality

	# Activate i-frames
	_activate_iframes(iframe_duration)

	# Start cooldown
	_start_cooldown()

	# Update combatant state if attached
	if combatant != null:
		combatant.is_invulnerable = true
		combatant.combat_state = Combatant.CombatState.DODGING

	# Emit success signal
	dodge_executed.emit(timing_quality, iframe_duration)

	return true


## Get i-frame duration based on timing quality
## @param timing_quality: "perfect", "good", or "miss"
## @return float: I-frame duration in seconds
func _get_iframe_duration(timing_quality: String) -> float:
	match timing_quality:
		"perfect":
			return iframe_duration_perfect
		"good":
			return iframe_duration_good
		_:
			return iframe_duration_miss


## Apply equipment modifiers to i-frame duration
## @param base_duration: Base i-frame duration before modifiers
## @return float: Modified i-frame duration
func _apply_equipment_modifiers(base_duration: float) -> float:
	# Equipment could extend i-frames or increase dodge effectiveness
	# For now, just return base duration
	# TODO: Integrate with S08 Equipment System for modifiers
	return base_duration


## Activate i-frames for specified duration
## @param duration: How long i-frames last in seconds
func _activate_iframes(duration: float) -> void:
	iframes_active = true
	iframe_timer = duration
	iframes_started.emit(duration)


## End i-frames
func _end_iframes() -> void:
	iframes_active = false
	iframe_timer = 0.0

	# Update combatant state if attached
	if combatant != null:
		combatant.is_invulnerable = false
		if combatant.combat_state == Combatant.CombatState.DODGING:
			combatant.combat_state = Combatant.CombatState.READY

	iframes_ended.emit()


## Start dodge cooldown
func _start_cooldown() -> void:
	is_on_cooldown = true

	# Apply cooldown modifier from equipment (e.g., -0.1 = 10% faster)
	var modified_cooldown: float = dodge_cooldown * (1.0 + cooldown_modifier)
	modified_cooldown = max(modified_cooldown, 0.1)  # Minimum 0.1s cooldown

	cooldown_timer = modified_cooldown


# ═════════════════════════════════════════════════════════════════════════════
# Equipment Integration (S08)
# ═════════════════════════════════════════════════════════════════════════════

## Set equipment modifiers from EquipmentManager
## @param modifiers: Dictionary with "cooldown_modifier" and "distance_modifier"
func apply_equipment_modifiers(modifiers: Dictionary) -> void:
	cooldown_modifier = modifiers.get("dodge_cooldown_modifier", 0.0)
	distance_modifier = modifiers.get("dodge_distance_modifier", 1.0)


## Get equipment manager reference
func set_equipment_manager(manager: Node) -> void:
	equipment_manager = manager

	# Connect to equipment changes to update modifiers
	if equipment_manager.has_signal("stats_changed"):
		if not equipment_manager.stats_changed.is_connected(_on_equipment_changed):
			equipment_manager.stats_changed.connect(_on_equipment_changed)


## Handle equipment changes
func _on_equipment_changed(new_stats: Dictionary) -> void:
	# Update modifiers from equipment stats
	# This would be called when equipment changes
	pass


# ═════════════════════════════════════════════════════════════════════════════
# Public API
# ═════════════════════════════════════════════════════════════════════════════

## Check if dodge is available (not on cooldown)
## @return bool: True if dodge can be performed
func can_dodge() -> bool:
	return not is_on_cooldown


## Get cooldown remaining time
## @return float: Seconds until dodge is available again
func get_cooldown_remaining() -> float:
	return cooldown_timer if is_on_cooldown else 0.0


## Get cooldown progress (0.0 to 1.0)
## @return float: Progress from 0 (just started) to 1 (complete)
func get_cooldown_progress() -> float:
	if not is_on_cooldown:
		return 1.0

	var modified_cooldown: float = dodge_cooldown * (1.0 + cooldown_modifier)
	return 1.0 - (cooldown_timer / modified_cooldown)


## Check if i-frames are currently active
## @return bool: True if invulnerable from dodge
func are_iframes_active() -> bool:
	return iframes_active


## Get i-frame remaining time
## @return float: Seconds of invulnerability remaining
func get_iframe_remaining() -> float:
	return iframe_timer if iframes_active else 0.0


## Get last dodge timing quality
## @return String: "perfect", "good", or "miss"
func get_last_dodge_quality() -> String:
	return last_dodge_quality


## Get dodge configuration
## @return Dictionary: Current dodge config values
func get_dodge_config() -> Dictionary:
	return {
		"cooldown": dodge_cooldown,
		"iframe_perfect": iframe_duration_perfect,
		"iframe_good": iframe_duration_good,
		"iframe_miss": iframe_duration_miss,
		"distance": dodge_distance,
		"speed": dodge_speed
	}


## Reset dodge state (useful for starting new combat)
func reset() -> void:
	is_on_cooldown = false
	cooldown_timer = 0.0
	iframes_active = false
	iframe_timer = 0.0
	last_dodge_quality = ""

	# Reset combatant state if attached
	if combatant != null:
		combatant.is_invulnerable = false


# ═════════════════════════════════════════════════════════════════════════════
# Debug / Testing
# ═════════════════════════════════════════════════════════════════════════════

## Print debug information about dodge state
func print_debug_info() -> void:
	print("═".repeat(60))
	print("DodgeSystem Debug Info")
	print("═".repeat(60))
	print("Cooldown: %.2fs (Modified: %.2fs)" % [dodge_cooldown, dodge_cooldown * (1.0 + cooldown_modifier)])
	print("On Cooldown: %s (Remaining: %.2fs)" % [is_on_cooldown, cooldown_timer])
	print("I-Frames Active: %s (Remaining: %.2fs)" % [iframes_active, iframe_timer])
	print("Last Dodge Quality: %s" % last_dodge_quality)
	print("I-Frame Durations:")
	print("  Perfect: %.2fs" % iframe_duration_perfect)
	print("  Good: %.2fs" % iframe_duration_good)
	print("  Miss: %.2fs" % iframe_duration_miss)
	print("Equipment Modifiers:")
	print("  Cooldown: %.1f%%" % (cooldown_modifier * 100.0))
	print("  Distance: %.1f%%" % ((distance_modifier - 1.0) * 100.0))
	print("═".repeat(60))
