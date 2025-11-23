# Godot 4.5 | GDScript 4.5
# System: S04 - Combat Prototype
# Created: 2025-11-18
# Dependencies: S01 (Conductor), S02 (InputManager), S03 (Player)
#
# Combatant is the base class for all entities that can participate in combat.
# This includes the player, monsters, enemies, and bosses.
#
# It implements the complete damage formula, stat system, and combat interactions
# defined in combat-specification.md

extends CharacterBody2D

class_name Combatant

## Signals for combat events

## Emitted when this combatant takes damage
signal damage_taken(amount: int, source: Combatant, timing_quality: String)

## Emitted when this combatant deals damage to another combatant
signal damage_dealt(amount: int, target: Combatant, timing_quality: String)

## Emitted when health changes
signal health_changed(current_hp: int, max_hp: int, delta: int)

## Emitted when this combatant is defeated (HP <= 0)
signal defeated(killer: Combatant)

## Emitted when attack is executed (before damage calculation)
signal attack_executed(target: Combatant, move_power: int)

## Emitted when dodge is activated
signal dodge_activated(invulnerability_duration: float)

## Emitted when block is activated
signal block_activated(damage_reduction: float)

## Emitted when a status effect is applied
signal status_effect_applied(effect_name: String, duration: float)

## Emitted when a status effect expires
signal status_effect_expired(effect_name: String)

# ═════════════════════════════════════════════════════════════════════════════
# Base Stats (6 core stats from combat specification)
# ═════════════════════════════════════════════════════════════════════════════

## Maximum health points
var max_hp: int = 100

## Current health points
var current_hp: int = 100

## Physical damage output
var attack: int = 10

## Physical damage reduction
var defense: int = 5

## Special/magical damage output
var special_attack: int = 10

## Special/magical damage reduction
var special_defense: int = 5

## Turn order priority, dodge bonus, flee chance
var speed: int = 10

## Character level (affects damage formula)
var level: int = 1

# ═════════════════════════════════════════════════════════════════════════════
# Combat State
# ═════════════════════════════════════════════════════════════════════════════

## Combat states
enum CombatState {
	IDLE,           ## Not in combat
	READY,          ## In combat, can act
	ATTACKING,      ## Executing an attack
	DODGING,        ## Dodge i-frames active
	BLOCKING,       ## Block damage reduction active
	STUNNED,        ## Cannot act temporarily
	DEFEATED        ## HP <= 0
}

## Current combat state
var combat_state: CombatState = CombatState.IDLE

## Is this combatant currently invulnerable (during dodge)
var is_invulnerable: bool = false

## Is this combatant currently blocking
var is_blocking: bool = false

## Invulnerability timer for dodge i-frames
var invulnerability_timer: float = 0.0

## Block timer
var block_timer: float = 0.0

# ═════════════════════════════════════════════════════════════════════════════
# Equipment & Modifiers
# ═════════════════════════════════════════════════════════════════════════════

## Weapon damage bonus (percentage, e.g., 25 = +25% = 1.25x)
var weapon_bonus: float = 0.0

## Equipment defensive bonus
var equipment_defense_bonus: int = 0

## Active buff multiplier (temporary stat boosts)
var buff_modifier: float = 1.0

# ═════════════════════════════════════════════════════════════════════════════
# Status Effects
# ═════════════════════════════════════════════════════════════════════════════

## Active status effects with remaining duration
var status_effects: Dictionary = {}
# Format: {"poison": 5.0, "burn": 3.5, ...}

# ═════════════════════════════════════════════════════════════════════════════
# Combat Configuration (loaded from combat_config.json)
# ═════════════════════════════════════════════════════════════════════════════

var combat_config: Dictionary = {}

# ═════════════════════════════════════════════════════════════════════════════
# Rhythm Integration (S01 Conductor)
# ═════════════════════════════════════════════════════════════════════════════

## Reference to Conductor autoload for rhythm timing
var conductor: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
	else:
		push_warning("Combatant: Conductor autoload not found - rhythm timing disabled")

	# Load combat configuration
	_load_combat_config()

	# Initialize HP
	current_hp = max_hp


## Load combat configuration from JSON
func _load_combat_config() -> void:
	var config_path: String = "res://src/systems/s04-combat/combat_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("Combatant: combat_config.json not found, using defaults")
		_use_default_combat_config()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Combatant: Failed to open combat_config.json")
		_use_default_combat_config()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("Combatant: Failed to parse combat_config.json: ", json.get_error_message())
		_use_default_combat_config()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Combatant: Invalid JSON format in combat_config.json")
		_use_default_combat_config()
		return

	combat_config = data.get("combat_config", {})


## Use default combat configuration
func _use_default_combat_config() -> void:
	combat_config = {
		"timing_damage_multipliers": {
			"perfect": 1.5,
			"good": 1.25,
			"okay": 1.0,
			"miss": 0.85
		},
		"dodge": {
			"window_duration_s": 0.2,
			"invulnerability_frames": 12
		},
		"block": {
			"damage_reduction": 0.5,
			"duration_s": 0.5
		},
		"critical": {
			"base_chance": 0.0625,
			"multiplier": 1.5
		}
	}


## Update timers each frame
func _process(delta: float) -> void:
	# Update invulnerability timer (dodge i-frames)
	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			if combat_state == CombatState.DODGING:
				combat_state = CombatState.READY

	# Update block timer
	if block_timer > 0.0:
		block_timer -= delta
		if block_timer <= 0.0:
			is_blocking = false
			if combat_state == CombatState.BLOCKING:
				combat_state = CombatState.READY

	# Update status effects
	_update_status_effects(delta)


# ═════════════════════════════════════════════════════════════════════════════
# Core Combat Methods
# ═════════════════════════════════════════════════════════════════════════════

## Execute an attack against a target
## @param target: Combatant to attack
## @param move_power: Base power of the attack (40=weak, 80=medium, 120=strong)
## @param is_special: Whether this is a special attack (uses SP.ATK/SP.DEF)
## @param input_timestamp: Time of input for rhythm timing (optional)
## @return int: Final damage dealt
func attack_target(target: Combatant, move_power: int = 60, is_special: bool = false, input_timestamp: float = 0.0) -> int:
	if target == null or not is_instance_valid(target):
		push_error("Combatant: Invalid attack target")
		return 0

	if combat_state == CombatState.DEFEATED:
		return 0

	# Emit attack executed signal
	attack_executed.emit(target, move_power)

	# Get timing quality from Conductor
	var timing_quality: String = "okay"
	if conductor != null and input_timestamp > 0.0:
		timing_quality = conductor.get_timing_quality(input_timestamp)

	# Calculate damage using complete formula
	var damage: int = _calculate_damage(target, move_power, is_special, timing_quality)

	# Apply damage to target
	target.take_damage(damage, self, timing_quality)

	# Emit damage dealt signal
	damage_dealt.emit(damage, target, timing_quality)

	return damage


## Take damage from another combatant
## @param amount: Raw damage amount (before reductions)
## @param source: Combatant that dealt the damage
## @param timing_quality: Rhythm timing quality for feedback
func take_damage(amount: int, source: Combatant = null, timing_quality: String = "okay") -> void:
	if combat_state == CombatState.DEFEATED:
		return

	# Check invulnerability (dodge i-frames)
	if is_invulnerable:
		# No damage taken during i-frames
		amount = 0
	# Check block damage reduction
	elif is_blocking:
		var block_reduction: float = combat_config.get("block", {}).get("damage_reduction", 0.5)
		amount = int(amount * (1.0 - block_reduction))

	# Apply damage
	var old_hp: int = current_hp
	current_hp -= amount
	current_hp = max(current_hp, 0)

	var hp_delta: int = current_hp - old_hp

	# Emit signals
	health_changed.emit(current_hp, max_hp, hp_delta)
	damage_taken.emit(amount, source, timing_quality)

	# Check for defeat
	if current_hp <= 0:
		_on_defeated(source)


## Heal this combatant
## @param amount: HP to restore
func heal(amount: int) -> void:
	if combat_state == CombatState.DEFEATED:
		return

	var old_hp: int = current_hp
	current_hp += amount
	current_hp = min(current_hp, max_hp)

	var hp_delta: int = current_hp - old_hp

	health_changed.emit(current_hp, max_hp, hp_delta)


## Activate dodge (grants temporary invulnerability)
## @param input_timestamp: Time of dodge input for rhythm timing (optional)
func dodge(input_timestamp: float = 0.0) -> void:
	if combat_state == CombatState.DEFEATED or combat_state == CombatState.STUNNED:
		return

	var dodge_config: Dictionary = combat_config.get("dodge", {})
	var duration: float = dodge_config.get("window_duration_s", 0.2)

	# Check if dodge was timed on-beat (extends i-frames)
	if conductor != null and input_timestamp > 0.0:
		var timing_quality: String = conductor.get_timing_quality(input_timestamp)
		if timing_quality == "perfect" or timing_quality == "good":
			# Extend i-frames for on-beat dodge (from combat spec: 200ms → 350ms)
			duration = 0.35

	# Activate invulnerability
	is_invulnerable = true
	invulnerability_timer = duration
	combat_state = CombatState.DODGING

	dodge_activated.emit(duration)


## Activate block (reduces incoming damage)
## @param duration: How long to block (default from config)
func block(duration: float = 0.0) -> void:
	if combat_state == CombatState.DEFEATED or combat_state == CombatState.STUNNED:
		return

	if duration <= 0.0:
		var block_config: Dictionary = combat_config.get("block", {})
		duration = block_config.get("duration_s", 0.5)

	# Activate block
	is_blocking = true
	block_timer = duration
	combat_state = CombatState.BLOCKING

	var block_reduction: float = combat_config.get("block", {}).get("damage_reduction", 0.5)
	block_activated.emit(block_reduction)


# ═════════════════════════════════════════════════════════════════════════════
# Damage Calculation (Complete Formula from Combat Specification)
# ═════════════════════════════════════════════════════════════════════════════

## Calculate damage using complete formula from combat-specification.md
## Formula: ((((2*Level/5)+2) * ATK * MovePower / DEF) / 50 + 2) * Modifiers
func _calculate_damage(target: Combatant, move_power: int, is_special: bool, timing_quality: String) -> int:
	# Determine which stats to use based on attack type
	var attack_stat: int = special_attack if is_special else attack
	var defense_stat: int = target.special_defense if is_special else target.defense

	# 1. Base Damage (Pokemon-inspired formula)
	var base_damage: float = (
		(((2.0 * level / 5.0) + 2.0) * attack_stat * move_power / defense_stat) / 50.0
	) + 2.0

	# 2. Weapon Modifier (1.0 + weapon_bonus/100)
	var weapon_modifier: float = 1.0 + (weapon_bonus / 100.0)

	# 3. Timing Multiplier (from Conductor rhythm evaluation)
	var timing_multiplier: float = _get_timing_multiplier(timing_quality)

	# 4. Critical Hit (simplified for prototype - full implementation in later systems)
	var critical_modifier: float = 1.0
	if _is_critical_hit():
		critical_modifier = combat_config.get("critical", {}).get("multiplier", 1.5)

	# 5. Equipment Bonus (placeholder for S08 Equipment System)
	var equipment_bonus: float = 1.0

	# 6. Buff Modifier (temporary stat boosts)
	var active_buff_modifier: float = buff_modifier

	# 7. Random Factor (0.85 to 1.0 for damage variance)
	var random_factor: float = randf_range(0.85, 1.0)

	# Apply all multipliers
	var final_damage: int = int(
		base_damage
		* weapon_modifier
		* timing_multiplier
		* critical_modifier
		* equipment_bonus
		* active_buff_modifier
		* random_factor
	)

	# Minimum damage is 1
	final_damage = max(final_damage, 1)

	return final_damage


## Get timing multiplier based on rhythm quality
func _get_timing_multiplier(timing_quality: String) -> float:
	var multipliers: Dictionary = combat_config.get("timing_damage_multipliers", {})
	return multipliers.get(timing_quality, 1.0)


## Check if attack is a critical hit
func _is_critical_hit() -> bool:
	var crit_config: Dictionary = combat_config.get("critical", {})
	var base_chance: float = crit_config.get("base_chance", 0.0625)  # 6.25% = 1/16

	# Add speed bonus (from combat spec: Speed / 512)
	var speed_bonus: float = speed / 512.0

	var total_chance: float = base_chance + speed_bonus
	total_chance = min(total_chance, 0.5)  # Cap at 50%

	return randf() < total_chance


# ═════════════════════════════════════════════════════════════════════════════
# Status Effects
# ═════════════════════════════════════════════════════════════════════════════

## Apply a status effect to this combatant
## @param effect_name: Name of the effect (e.g., "poison", "burn", "stun")
## @param duration: How long the effect lasts in seconds
func apply_status_effect(effect_name: String, duration: float) -> void:
	status_effects[effect_name] = duration
	status_effect_applied.emit(effect_name, duration)


## Remove a status effect
func remove_status_effect(effect_name: String) -> void:
	if effect_name in status_effects:
		status_effects.erase(effect_name)
		status_effect_expired.emit(effect_name)


## Update all active status effects
func _update_status_effects(delta: float) -> void:
	var expired_effects: Array[String] = []

	for effect_name in status_effects:
		status_effects[effect_name] -= delta

		# Apply effect damage/logic per tick
		_apply_status_effect_tick(effect_name, delta)

		# Check if expired
		if status_effects[effect_name] <= 0.0:
			expired_effects.append(effect_name)

	# Remove expired effects
	for effect_name in expired_effects:
		remove_status_effect(effect_name)


## Apply status effect damage/logic each tick
func _apply_status_effect_tick(effect_name: String, delta: float) -> void:
	match effect_name:
		"poison":
			# Poison deals 5% max HP per second
			var damage: int = int(max_hp * 0.05 * delta)
			take_damage(damage, null, "okay")

		"burn":
			# Burn deals 8% max HP per second
			var damage: int = int(max_hp * 0.08 * delta)
			take_damage(damage, null, "okay")

		"stun":
			# Stun prevents actions
			combat_state = CombatState.STUNNED


# ═════════════════════════════════════════════════════════════════════════════
# Combat State Management
# ═════════════════════════════════════════════════════════════════════════════

## Called when combatant is defeated (HP <= 0)
func _on_defeated(killer: Combatant = null) -> void:
	combat_state = CombatState.DEFEATED
	current_hp = 0

	defeated.emit(killer)


## Reset combatant for new combat encounter
func reset_for_combat() -> void:
	current_hp = max_hp
	combat_state = CombatState.READY
	is_invulnerable = false
	is_blocking = false
	invulnerability_timer = 0.0
	block_timer = 0.0
	status_effects.clear()
	buff_modifier = 1.0


# ═════════════════════════════════════════════════════════════════════════════
# Getters / Setters
# ═════════════════════════════════════════════════════════════════════════════

## Get current stats as dictionary
func get_stats() -> Dictionary:
	return {
		"max_hp": max_hp,
		"current_hp": current_hp,
		"attack": attack,
		"defense": defense,
		"special_attack": special_attack,
		"special_defense": special_defense,
		"speed": speed,
		"level": level
	}


## Set stats from dictionary (for loading from data)
func set_stats(stats: Dictionary) -> void:
	max_hp = stats.get("max_hp", 100)
	current_hp = stats.get("current_hp", max_hp)
	attack = stats.get("attack", 10)
	defense = stats.get("defense", 5)
	special_attack = stats.get("special_attack", 10)
	special_defense = stats.get("special_defense", 5)
	speed = stats.get("speed", 10)
	level = stats.get("level", 1)


## Get current HP percentage (0.0 to 1.0)
func get_hp_percentage() -> float:
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)


## Check if combatant is alive
func is_alive() -> bool:
	return current_hp > 0 and combat_state != CombatState.DEFEATED


## Check if combatant can act
func can_act() -> bool:
	return is_alive() and combat_state not in [CombatState.STUNNED, CombatState.DEFEATED]


## Get current combat state as string
func get_combat_state_string() -> String:
	match combat_state:
		CombatState.IDLE:
			return "Idle"
		CombatState.READY:
			return "Ready"
		CombatState.ATTACKING:
			return "Attacking"
		CombatState.DODGING:
			return "Dodging"
		CombatState.BLOCKING:
			return "Blocking"
		CombatState.STUNNED:
			return "Stunned"
		CombatState.DEFEATED:
			return "Defeated"
		_:
			return "Unknown"
