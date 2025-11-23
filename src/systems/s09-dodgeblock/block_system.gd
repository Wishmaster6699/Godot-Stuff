# Godot 4.5 | GDScript 4.5
# System: S09 - Dodge & Block Mechanics
# Created: 2025-11-18
# Dependencies: S01 (Conductor), S04 (Combat), S08 (Equipment)
#
# BlockSystem manages blocking mechanic with stamina costs, rhythm timing, and damage reduction.
# Blocking reduces incoming damage based on timing quality.
# Perfect timing on beat = higher damage reduction, shield clash effect.
# Blocking costs stamina and has a cooldown.

extends Node
class_name BlockSystem

## Signals for block events

## Emitted when block is attempted (before validation)
signal block_attempted(input_timestamp: float)

## Emitted when block is successfully executed
signal block_executed(timing_quality: String, damage_reduction: float)

## Emitted when block fails (insufficient stamina, on cooldown, etc.)
signal block_failed(reason: String)

## Emitted when block is active
signal block_started(damage_reduction: float, duration: float)

## Emitted when block ends
signal block_ended()

## Emitted when block successfully reduces damage
signal damage_blocked(original_damage: int, reduced_damage: int, reduction_percent: float)

## Emitted when stamina changes
signal stamina_changed(current: int, max_stamina: int, delta: int)

## Emitted when stamina depleted (block will fail)
signal stamina_depleted()

## Emitted when cooldown completes
signal cooldown_complete()

# ═════════════════════════════════════════════════════════════════════════════
# Configuration (loaded from dodge_block_config.json)
# ═════════════════════════════════════════════════════════════════════════════

## Configuration dictionary loaded from JSON
var config: Dictionary = {}

## Block cooldown in seconds
var block_cooldown: float = 1.0

## Stamina cost per block
var stamina_cost: int = 10

## Damage reduction for perfect timing (0.85 = 85% reduction)
var damage_reduction_perfect: float = 0.85

## Damage reduction for good timing (0.60 = 60% reduction)
var damage_reduction_good: float = 0.60

## Damage reduction for miss timing (0.30 = 30% reduction)
var damage_reduction_miss: float = 0.30

## Block stun duration after blocking (in seconds)
var block_stun_duration: float = 0.2

# ═════════════════════════════════════════════════════════════════════════════
# Stamina System
# ═════════════════════════════════════════════════════════════════════════════

## Current stamina
var current_stamina: int = 100

## Maximum stamina
var max_stamina: int = 100

## Stamina regeneration rate (per second)
var stamina_regen_rate: int = 10

## Delay after blocking before stamina regenerates (in seconds)
var stamina_regen_delay: float = 2.0

## Timer for stamina regeneration delay
var stamina_regen_timer: float = 0.0

## Is stamina regeneration paused
var stamina_regen_paused: bool = false

# ═════════════════════════════════════════════════════════════════════════════
# State Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Is block currently on cooldown
var is_on_cooldown: bool = false

## Cooldown timer remaining
var cooldown_timer: float = 0.0

## Is block currently active
var block_active: bool = false

## Current damage reduction percentage
var current_damage_reduction: float = 0.0

## Current timing quality of last block ("perfect", "good", "miss")
var last_block_quality: String = ""

# ═════════════════════════════════════════════════════════════════════════════
# Equipment Modifiers (from S08)
# ═════════════════════════════════════════════════════════════════════════════

## Damage reduction bonus from equipment (e.g., 0.1 = +10% reduction)
var reduction_modifier: float = 0.0

## Stamina cost modifier from equipment (e.g., 1.5 = 50% more stamina cost)
var stamina_cost_modifier: float = 1.0

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
		push_warning("BlockSystem: Conductor autoload not found - rhythm timing disabled")

	# Get parent combatant reference
	if get_parent() is Combatant:
		combatant = get_parent()
		print("BlockSystem: Attached to combatant: %s" % combatant.name)

	# Load configuration
	_load_configuration()

	# Initialize stamina
	current_stamina = max_stamina

	print("BlockSystem: Initialized (Cooldown: %.2fs, Stamina: %d/%d, Cost: %d)" %
		[block_cooldown, current_stamina, max_stamina, stamina_cost])


## Load block configuration from JSON file
func _load_configuration() -> void:
	var config_path: String = "res://src/systems/s09-dodgeblock/dodge_block_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("BlockSystem: dodge_block_config.json not found at %s, using defaults" % config_path)
		_use_default_configuration()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("BlockSystem: Failed to open dodge_block_config.json")
		_use_default_configuration()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("BlockSystem: Failed to parse dodge_block_config.json: %s" % json.get_error_message())
		_use_default_configuration()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("BlockSystem: Invalid JSON format in dodge_block_config.json")
		_use_default_configuration()
		return

	config = data.get("dodge_block_config", {})

	# Apply block configuration
	var block_config: Dictionary = config.get("block", {})
	block_cooldown = block_config.get("cooldown_s", 1.0)
	stamina_cost = block_config.get("stamina_cost", 10)
	damage_reduction_perfect = block_config.get("damage_reduction_perfect", 0.85)
	damage_reduction_good = block_config.get("damage_reduction_good", 0.60)
	damage_reduction_miss = block_config.get("damage_reduction_miss", 0.30)
	block_stun_duration = block_config.get("block_stun_duration", 0.2)

	# Apply stamina configuration
	var stamina_config: Dictionary = config.get("stamina", {})
	max_stamina = stamina_config.get("max_stamina", 100)
	stamina_regen_rate = stamina_config.get("regen_rate", 10)
	stamina_regen_delay = stamina_config.get("regen_delay_after_block", 2.0)


## Use default configuration if JSON loading fails
func _use_default_configuration() -> void:
	config = {
		"block": {
			"cooldown_s": 1.0,
			"stamina_cost": 10,
			"damage_reduction_perfect": 0.85,
			"damage_reduction_good": 0.60,
			"damage_reduction_miss": 0.30,
			"block_stun_duration": 0.2
		},
		"stamina": {
			"max_stamina": 100,
			"regen_rate": 10,
			"regen_delay_after_block": 2.0
		}
	}

	block_cooldown = 1.0
	stamina_cost = 10
	damage_reduction_perfect = 0.85
	damage_reduction_good = 0.60
	damage_reduction_miss = 0.30
	block_stun_duration = 0.2
	max_stamina = 100
	stamina_regen_rate = 10
	stamina_regen_delay = 2.0


## Update timers each frame
func _process(delta: float) -> void:
	# Update cooldown timer
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_on_cooldown = false
			cooldown_timer = 0.0
			cooldown_complete.emit()

	# Update stamina regeneration
	_update_stamina_regen(delta)


# ═════════════════════════════════════════════════════════════════════════════
# Core Block Logic
# ═════════════════════════════════════════════════════════════════════════════

## Attempt to perform a block
## @param input_timestamp: Time of block input for rhythm timing (use Time.get_ticks_msec() / 1000.0)
## @return bool: True if block was successful, false if failed
func perform_block(input_timestamp: float = 0.0) -> bool:
	# Emit attempted signal
	block_attempted.emit(input_timestamp)

	# Check if block is on cooldown
	if is_on_cooldown:
		block_failed.emit("on_cooldown")
		return false

	# Check if enough stamina
	var modified_stamina_cost: int = int(stamina_cost * stamina_cost_modifier)
	if current_stamina < modified_stamina_cost:
		block_failed.emit("insufficient_stamina")
		stamina_depleted.emit()
		return false

	# Use current time if no timestamp provided
	if input_timestamp <= 0.0:
		input_timestamp = Time.get_ticks_msec() / 1000.0

	# Get timing quality from Conductor
	var timing_quality: String = "miss"
	if conductor != null:
		timing_quality = conductor.get_timing_quality(input_timestamp)

	# Calculate damage reduction based on timing quality
	var damage_reduction: float = _get_damage_reduction(timing_quality)

	# Apply equipment modifiers
	damage_reduction = _apply_equipment_modifiers(damage_reduction)

	# Store timing quality and damage reduction
	last_block_quality = timing_quality
	current_damage_reduction = damage_reduction

	# Consume stamina
	_consume_stamina(modified_stamina_cost)

	# Activate block
	_activate_block(damage_reduction)

	# Start cooldown
	_start_cooldown()

	# Update combatant state if attached
	if combatant != null:
		combatant.is_blocking = true
		combatant.combat_state = Combatant.CombatState.BLOCKING

	# Emit success signal
	block_executed.emit(timing_quality, damage_reduction)

	return true


## Get damage reduction based on timing quality
## @param timing_quality: "perfect", "good", or "miss"
## @return float: Damage reduction percentage (0.0 to 1.0)
func _get_damage_reduction(timing_quality: String) -> float:
	match timing_quality:
		"perfect":
			return damage_reduction_perfect
		"good":
			return damage_reduction_good
		_:
			return damage_reduction_miss


## Apply equipment modifiers to damage reduction
## @param base_reduction: Base damage reduction before modifiers
## @return float: Modified damage reduction
func _apply_equipment_modifiers(base_reduction: float) -> float:
	# Add equipment bonus (e.g., +10% = 0.1)
	var modified_reduction: float = base_reduction + reduction_modifier

	# Cap at 95% maximum reduction (always take at least 5% damage)
	modified_reduction = min(modified_reduction, 0.95)

	return modified_reduction


## Activate block state
## @param damage_reduction: Current damage reduction percentage
func _activate_block(damage_reduction: float) -> void:
	block_active = true
	current_damage_reduction = damage_reduction
	block_started.emit(damage_reduction, block_stun_duration)


## End block state
func _end_block() -> void:
	block_active = false
	current_damage_reduction = 0.0

	# Update combatant state if attached
	if combatant != null:
		combatant.is_blocking = false
		if combatant.combat_state == Combatant.CombatState.BLOCKING:
			combatant.combat_state = Combatant.CombatState.READY

	block_ended.emit()


## Start block cooldown
func _start_cooldown() -> void:
	is_on_cooldown = true
	cooldown_timer = block_cooldown


## Calculate damage after block reduction
## @param incoming_damage: Original damage amount
## @return int: Reduced damage amount
func calculate_blocked_damage(incoming_damage: int) -> int:
	if not block_active:
		return incoming_damage

	# Apply damage reduction
	var reduced_damage: int = int(incoming_damage * (1.0 - current_damage_reduction))

	# Minimum 1 damage (always take at least some damage when blocking)
	reduced_damage = max(reduced_damage, 1)

	# Emit damage blocked signal
	damage_blocked.emit(incoming_damage, reduced_damage, current_damage_reduction)

	# End block after taking damage
	_end_block()

	return reduced_damage


# ═════════════════════════════════════════════════════════════════════════════
# Stamina Management
# ═════════════════════════════════════════════════════════════════════════════

## Consume stamina for blocking
## @param amount: Stamina to consume
func _consume_stamina(amount: int) -> void:
	var old_stamina: int = current_stamina
	current_stamina -= amount
	current_stamina = max(current_stamina, 0)

	var delta: int = current_stamina - old_stamina

	# Emit stamina changed signal
	stamina_changed.emit(current_stamina, max_stamina, delta)

	# Pause stamina regeneration and start delay
	stamina_regen_paused = true
	stamina_regen_timer = stamina_regen_delay


## Update stamina regeneration
## @param delta: Time delta in seconds
func _update_stamina_regen(delta: float) -> void:
	# Update regeneration delay timer
	if stamina_regen_paused:
		stamina_regen_timer -= delta
		if stamina_regen_timer <= 0.0:
			stamina_regen_paused = false
			stamina_regen_timer = 0.0
		return

	# Regenerate stamina if not at max
	if current_stamina < max_stamina:
		var old_stamina: int = current_stamina
		var regen_amount: float = stamina_regen_rate * delta

		current_stamina += int(regen_amount)
		current_stamina = min(current_stamina, max_stamina)

		var delta_stamina: int = current_stamina - old_stamina

		if delta_stamina > 0:
			stamina_changed.emit(current_stamina, max_stamina, delta_stamina)


## Restore stamina (for healing items, etc.)
## @param amount: Stamina to restore
func restore_stamina(amount: int) -> void:
	var old_stamina: int = current_stamina
	current_stamina += amount
	current_stamina = min(current_stamina, max_stamina)

	var delta: int = current_stamina - old_stamina

	if delta > 0:
		stamina_changed.emit(current_stamina, max_stamina, delta)


## Set stamina (for debugging or special events)
## @param value: New stamina value
func set_stamina(value: int) -> void:
	var old_stamina: int = current_stamina
	current_stamina = clamp(value, 0, max_stamina)

	var delta: int = current_stamina - old_stamina

	if delta != 0:
		stamina_changed.emit(current_stamina, max_stamina, delta)


# ═════════════════════════════════════════════════════════════════════════════
# Equipment Integration (S08)
# ═════════════════════════════════════════════════════════════════════════════

## Set equipment modifiers from EquipmentManager
## @param modifiers: Dictionary with "block_damage_reduction" and "stamina_cost_modifier"
func apply_equipment_modifiers(modifiers: Dictionary) -> void:
	reduction_modifier = modifiers.get("block_damage_reduction", 0.0)
	stamina_cost_modifier = modifiers.get("stamina_cost_modifier", 1.0)


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

## Check if block is available (not on cooldown and enough stamina)
## @return bool: True if block can be performed
func can_block() -> bool:
	var modified_stamina_cost: int = int(stamina_cost * stamina_cost_modifier)
	return not is_on_cooldown and current_stamina >= modified_stamina_cost


## Get cooldown remaining time
## @return float: Seconds until block is available again
func get_cooldown_remaining() -> float:
	return cooldown_timer if is_on_cooldown else 0.0


## Get cooldown progress (0.0 to 1.0)
## @return float: Progress from 0 (just started) to 1 (complete)
func get_cooldown_progress() -> float:
	if not is_on_cooldown:
		return 1.0

	return 1.0 - (cooldown_timer / block_cooldown)


## Check if block is currently active
## @return bool: True if blocking
func is_blocking() -> bool:
	return block_active


## Get current damage reduction percentage
## @return float: Damage reduction (0.0 to 1.0)
func get_damage_reduction() -> float:
	return current_damage_reduction if block_active else 0.0


## Get last block timing quality
## @return String: "perfect", "good", or "miss"
func get_last_block_quality() -> String:
	return last_block_quality


## Get current stamina
## @return int: Current stamina value
func get_current_stamina() -> int:
	return current_stamina


## Get maximum stamina
## @return int: Maximum stamina value
func get_max_stamina() -> int:
	return max_stamina


## Get stamina percentage (0.0 to 1.0)
## @return float: Stamina percentage
func get_stamina_percentage() -> float:
	if max_stamina <= 0:
		return 0.0
	return float(current_stamina) / float(max_stamina)


## Get stamina cost for next block
## @return int: Stamina cost with modifiers
func get_block_stamina_cost() -> int:
	return int(stamina_cost * stamina_cost_modifier)


## Get block configuration
## @return Dictionary: Current block config values
func get_block_config() -> Dictionary:
	return {
		"cooldown": block_cooldown,
		"stamina_cost": stamina_cost,
		"reduction_perfect": damage_reduction_perfect,
		"reduction_good": damage_reduction_good,
		"reduction_miss": damage_reduction_miss,
		"stun_duration": block_stun_duration
	}


## Reset block state (useful for starting new combat)
func reset() -> void:
	is_on_cooldown = false
	cooldown_timer = 0.0
	block_active = false
	current_damage_reduction = 0.0
	last_block_quality = ""
	current_stamina = max_stamina
	stamina_regen_paused = false
	stamina_regen_timer = 0.0

	# Reset combatant state if attached
	if combatant != null:
		combatant.is_blocking = false


# ═════════════════════════════════════════════════════════════════════════════
# Debug / Testing
# ═════════════════════════════════════════════════════════════════════════════

## Print debug information about block state
func print_debug_info() -> void:
	print("═".repeat(60))
	print("BlockSystem Debug Info")
	print("═".repeat(60))
	print("Cooldown: %.2fs" % block_cooldown)
	print("On Cooldown: %s (Remaining: %.2fs)" % [is_on_cooldown, cooldown_timer])
	print("Block Active: %s (Reduction: %.1f%%)" % [block_active, current_damage_reduction * 100.0])
	print("Last Block Quality: %s" % last_block_quality)
	print("Stamina: %d/%d (%.1f%%)" % [current_stamina, max_stamina, get_stamina_percentage() * 100.0])
	print("Stamina Cost: %d (Modified: %d)" % [stamina_cost, get_block_stamina_cost()])
	print("Stamina Regen: %d/s (Paused: %s, Timer: %.2fs)" % [stamina_regen_rate, stamina_regen_paused, stamina_regen_timer])
	print("Damage Reduction:")
	print("  Perfect: %.1f%%" % (damage_reduction_perfect * 100.0))
	print("  Good: %.1f%%" % (damage_reduction_good * 100.0))
	print("  Miss: %.1f%%" % (damage_reduction_miss * 100.0))
	print("Equipment Modifiers:")
	print("  Reduction Bonus: +%.1f%%" % (reduction_modifier * 100.0))
	print("  Stamina Cost: x%.2f" % stamina_cost_modifier)
	print("═".repeat(60))
