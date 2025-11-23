# Godot 4.5 | GDScript 4.5
# System: S14 - Tool System - Laser
# Created: 2025-11-18
# Dependencies: S03 (Player Controller), tool_manager.gd
# Purpose: Laser tool with continuous beam, damage, and overheat mechanics

extends Node2D

class_name Laser

## Signals for laser events

## Emitted when laser starts firing
signal laser_started()

## Emitted when laser stops firing
signal laser_stopped()

## Emitted when laser hits a target
signal laser_hit(target: Node, damage: float)

## Emitted when laser starts overheating
signal laser_overheating()

## Emitted when laser is overheated and shuts down
signal laser_overheated()

## Emitted when laser cooldown completes
signal laser_cooled_down()

# Tool states
enum State {
	INACTIVE,
	READY,
	FIRING,
	OVERHEATING,
	OVERHEATED
}

# Configuration
var config: Dictionary = {}
var damage_per_second: float = 15.0
var max_duration: float = 3.0
var overheat_cooldown: float = 2.0
var laser_range: float = 300.0
var beam_width: float = 4.0

# State
var current_state: State = State.INACTIVE
var is_active: bool = false
var is_firing: bool = false

# Heat tracking
var heat_level: float = 0.0  # 0.0 to 1.0
var heat_buildup_rate: float = 0.333  # Full heat in 3 seconds
var heat_cooldown_rate: float = 0.5   # Cool down in 2 seconds
var overheat_threshold: float = 1.0

# Firing tracking
var firing_time: float = 0.0
var cooldown_time: float = 0.0

# Damage tracking
var damage_accumulator: float = 0.0
var hit_targets: Dictionary = {}  # Track damage dealt to each target

# References
var player: PlayerController = null
var tool_manager: Node = null
var raycast: RayCast2D = null
var beam_line: Line2D = null
var beam_particles: CPUParticles2D = null

func _ready() -> void:
	visible = false
	_setup_raycast()
	_setup_beam_visual()
	_setup_particles()

func initialize(player_ref: PlayerController, tool_config: Dictionary) -> void:
	"""Initialize the laser with player reference and configuration"""
	player = player_ref
	config = tool_config

	# Load config values
	damage_per_second = config.get("damage_per_second", 15.0) as float
	max_duration = config.get("max_duration_s", 3.0) as float
	overheat_cooldown = config.get("overheat_cooldown_s", 2.0) as float

	# Calculate heat rates based on duration
	heat_buildup_rate = 1.0 / max_duration
	heat_cooldown_rate = 1.0 / overheat_cooldown

	# Get tool manager reference
	tool_manager = get_parent()

	print("Laser: Initialized (damage: %.1f/s, duration: %.1fs)" % [damage_per_second, max_duration])

func _setup_raycast() -> void:
	"""Setup raycast for laser beam detection"""
	raycast = RayCast2D.new()
	raycast.name = "LaserRaycast"
	raycast.enabled = false
	raycast.hit_from_inside = false
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = true
	raycast.collision_mask = 1 | 2  # Layers 1 and 2 (enemies, destructibles)
	add_child(raycast)

func _setup_beam_visual() -> void:
	"""Setup Line2D for visualizing the laser beam"""
	beam_line = Line2D.new()
	beam_line.name = "BeamLine"
	beam_line.width = beam_width
	beam_line.default_color = Color(1.0, 0.2, 0.2, 0.9)  # Red laser
	beam_line.visible = false
	add_child(beam_line)

func _setup_particles() -> void:
	"""Setup particle effects for laser impact"""
	beam_particles = CPUParticles2D.new()
	beam_particles.name = "BeamParticles"
	beam_particles.emitting = false
	beam_particles.amount = 16
	beam_particles.lifetime = 0.3
	beam_particles.one_shot = false
	beam_particles.explosiveness = 0.8
	beam_particles.randomness = 0.5
	beam_particles.direction = Vector2(-1, 0)
	beam_particles.spread = 45.0
	beam_particles.gravity = Vector2(0, 0)
	beam_particles.initial_velocity_min = 50.0
	beam_particles.initial_velocity_max = 100.0
	beam_particles.scale_amount_min = 2.0
	beam_particles.scale_amount_max = 4.0
	beam_particles.color = Color(1.0, 0.5, 0.2, 1.0)
	add_child(beam_particles)

func _process(delta: float) -> void:
	"""Update laser state and visuals"""
	if not is_active:
		return

	_update_state(delta)
	_update_heat(delta)
	_update_beam_visual()

func _physics_process(delta: float) -> void:
	"""Handle laser firing and damage"""
	if is_firing and current_state == State.FIRING:
		_fire_laser(delta)

func _update_state(delta: float) -> void:
	"""Update laser state machine"""
	match current_state:
		State.READY:
			# Ready to fire
			pass
		State.FIRING:
			# Currently firing
			firing_time += delta
			if heat_level >= overheat_threshold:
				_overheat()
		State.OVERHEATING:
			# Warning state before full overheat
			if heat_level >= overheat_threshold:
				_overheat()
		State.OVERHEATED:
			# Cooling down after overheat
			cooldown_time -= delta
			if cooldown_time <= 0.0:
				_cool_down()

func _update_heat(delta: float) -> void:
	"""Update heat level"""
	if is_firing and current_state == State.FIRING:
		# Build up heat while firing
		heat_level += heat_buildup_rate * delta
		heat_level = clamp(heat_level, 0.0, 1.0)

		# Check for overheat warning
		if heat_level >= 0.8 and current_state != State.OVERHEATING:
			current_state = State.OVERHEATING
			laser_overheating.emit()
			print("Laser: Overheating warning!")
	else:
		# Cool down when not firing
		if current_state != State.OVERHEATED:
			heat_level -= heat_cooldown_rate * delta * 0.5  # Slower passive cooldown
			heat_level = clamp(heat_level, 0.0, 1.0)

func _fire_laser(delta: float) -> void:
	"""Fire the laser beam and deal damage"""
	var aim_direction = _get_aim_direction()
	raycast.target_position = aim_direction * laser_range
	raycast.enabled = true
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var hit_position = raycast.get_collision_point()
		var hit_object = raycast.get_collider()

		# Update beam visual to hit point
		beam_line.clear_points()
		beam_line.add_point(Vector2.ZERO)
		beam_line.add_point(to_local(hit_position))

		# Update particles at hit point
		beam_particles.position = to_local(hit_position)
		beam_particles.emitting = true

		# Deal damage if target is damageable
		if hit_object != null:
			_deal_damage(hit_object, delta)
	else:
		# No hit, show full range beam
		beam_line.clear_points()
		beam_line.add_point(Vector2.ZERO)
		beam_line.add_point(aim_direction * laser_range)
		beam_particles.emitting = false

func _deal_damage(target: Node, delta: float) -> void:
	"""Deal damage to a target"""
	# Check if target can take damage
	if target.has_method("take_damage") or target.has_method("damage"):
		var damage_this_frame = damage_per_second * delta
		damage_accumulator += damage_this_frame

		# Track total damage to this target
		if not hit_targets.has(target):
			hit_targets[target] = 0.0
		hit_targets[target] += damage_this_frame

		# Apply damage (call every frame for continuous damage)
		if target.has_method("take_damage"):
			target.call("take_damage", damage_this_frame)
		elif target.has_method("damage"):
			target.call("damage", damage_this_frame)

		laser_hit.emit(target, damage_this_frame)

	# Check if target is destructible
	elif target.has_method("destroy") or target.has_method("break"):
		# Accumulate damage and destroy when threshold is reached
		if not hit_targets.has(target):
			hit_targets[target] = 0.0
		hit_targets[target] += damage_per_second * delta

		# Destroy after dealing enough damage (e.g., 1 second of damage)
		if hit_targets[target] >= damage_per_second:
			if target.has_method("destroy"):
				target.call("destroy")
			elif target.has_method("break"):
				target.call("break")
			hit_targets.erase(target)
			print("Laser: Destroyed object %s" % target.name)

func _update_beam_visual() -> void:
	"""Update the visual representation of the laser beam"""
	if is_firing and current_state == State.FIRING:
		beam_line.visible = true

		# Change color based on heat level
		var heat_color = Color(1.0, 1.0 - heat_level, 1.0 - heat_level, 0.9)
		beam_line.default_color = heat_color
	else:
		beam_line.visible = false
		beam_particles.emitting = false

func _get_aim_direction() -> Vector2:
	"""Get the direction the player is aiming"""
	var aim_dir = Vector2.ZERO

	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		aim_dir = input_manager.get_stick_input("right_stick")
		if aim_dir.length() < 0.1:
			aim_dir = input_manager.get_stick_input("left_stick")

	if aim_dir.length() < 0.1:
		# Use player facing direction as fallback
		if player != null:
			aim_dir = player.get_facing_direction()

	if aim_dir.length() < 0.1:
		# Default to right if no input
		aim_dir = Vector2.RIGHT

	return aim_dir.normalized()

func _overheat() -> void:
	"""Handle overheat shutdown"""
	current_state = State.OVERHEATED
	is_firing = false
	cooldown_time = overheat_cooldown
	laser_overheated.emit()
	print("Laser: OVERHEATED! Cooling down for %.1fs" % overheat_cooldown)

	# Stop visuals
	beam_line.visible = false
	beam_particles.emitting = false

	# Start cooldown in tool manager
	if tool_manager != null and tool_manager.has_method("start_tool_cooldown"):
		tool_manager.call("start_tool_cooldown", "laser", overheat_cooldown)

func _cool_down() -> void:
	"""Handle cooldown completion"""
	current_state = State.READY
	heat_level = 0.0
	laser_cooled_down.emit()
	print("Laser: Cooled down and ready")

## Public API Methods

func activate() -> void:
	"""Called when this tool is selected"""
	is_active = true
	visible = true
	if current_state == State.INACTIVE or current_state == State.READY:
		current_state = State.READY
	print("Laser: Activated")

func deactivate() -> void:
	"""Called when this tool is deselected"""
	is_active = false
	visible = false
	stop_firing()
	current_state = State.INACTIVE
	print("Laser: Deactivated")

func use() -> void:
	"""Use the laser - start firing (hold to fire continuously)"""
	if not is_active:
		return

	if current_state == State.OVERHEATED:
		print("Laser: Cannot fire - overheated!")
		return

	start_firing()

func start_firing() -> void:
	"""Start firing the laser"""
	if is_firing:
		return

	if current_state == State.OVERHEATED:
		print("Laser: Cannot fire - overheated!")
		return

	is_firing = true
	current_state = State.FIRING
	firing_time = 0.0
	hit_targets.clear()
	damage_accumulator = 0.0
	laser_started.emit()
	print("Laser: Started firing")

func stop_firing() -> void:
	"""Stop firing the laser"""
	if not is_firing:
		return

	is_firing = false
	if current_state == State.FIRING or current_state == State.OVERHEATING:
		current_state = State.READY
	laser_stopped.emit()
	raycast.enabled = false
	beam_line.visible = false
	beam_particles.emitting = false
	print("Laser: Stopped firing")

func get_heat_level() -> float:
	"""Get current heat level (0.0 to 1.0)"""
	return heat_level

func is_overheated() -> bool:
	"""Check if laser is currently overheated"""
	return current_state == State.OVERHEATED

func get_total_damage_dealt() -> float:
	"""Get total damage dealt since last firing"""
	return damage_accumulator
