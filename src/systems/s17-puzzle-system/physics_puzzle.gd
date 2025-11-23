# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System - Physics-Based Puzzles
# Created: 2025-11-18
# Purpose: Physics-based puzzles (momentum, gravity, buoyancy, projectiles)

extends Puzzle
class_name PhysicsPuzzle

## Physics puzzle specific signals

## Emitted when a physics object reaches target
signal physics_object_reached_target(object_id: String, target_id: String)

## Emitted when momentum threshold is achieved
signal momentum_threshold_reached(object_id: String, momentum: float)

## Emitted when object enters water
signal object_entered_water(object_id: String)

## Emitted when object exits water
signal object_exited_water(object_id: String)

## Emitted when projectile hits target
signal projectile_hit_target(projectile_id: String, target_id: String)

## Physics puzzle subtypes
enum PhysicsPuzzleType {
	MOMENTUM_SWING,    # Swing object to hit target
	GRAVITY_DROP,      # Drop weights in correct order/position
	BUOYANCY,          # Float/sink objects to solve
	PROJECTILE         # Launch objects to hit targets
}

@export var physics_puzzle_type: PhysicsPuzzleType = PhysicsPuzzleType.MOMENTUM_SWING

# Puzzle elements
var physics_objects: Dictionary = {}  # object_id -> RigidBody2D
var targets: Dictionary = {}  # target_id -> Area2D
var weight_plates: Dictionary = {}  # plate_id -> Area2D
var water_areas: Dictionary = {}  # water_id -> Area2D
var launchers: Dictionary = {}  # launcher_id -> Node2D

# State tracking
var objects_at_targets: Dictionary = {}  # target_id -> object_id
var activated_plates: Array[String] = []
var objects_in_water: Array[String] = []
var hit_targets: Array[String] = []

# Physics configuration
var required_momentum: float = 0.0
var gravity_scale: float = 1.0


func _ready() -> void:
	puzzle_type = PuzzleType.PHYSICS
	super._ready()


## Initialize physics puzzle
func _initialize_puzzle() -> void:
	super._initialize_puzzle()

	# Load physics parameters from solution data
	required_momentum = solution_data.get("required_momentum", 0.0)
	gravity_scale = solution_data.get("gravity_scale", 1.0)

	# Find puzzle elements in scene tree
	_find_puzzle_elements()

	# Setup based on physics puzzle type
	match physics_puzzle_type:
		PhysicsPuzzleType.MOMENTUM_SWING:
			_setup_momentum_swing_puzzle()
		PhysicsPuzzleType.GRAVITY_DROP:
			_setup_gravity_drop_puzzle()
		PhysicsPuzzleType.BUOYANCY:
			_setup_buoyancy_puzzle()
		PhysicsPuzzleType.PROJECTILE:
			_setup_projectile_puzzle()


## Find all puzzle elements in the scene tree
func _find_puzzle_elements() -> void:
	# Find physics objects (RigidBody2D in "PhysicsObjects" group)
	var object_nodes: Array[Node] = get_tree().get_nodes_in_group("physics_objects")
	for obj in object_nodes:
		if obj.has_meta("object_id"):
			var object_id: String = obj.get_meta("object_id")
			physics_objects[object_id] = obj

	# Find targets (Area2D in "PhysicsTargets" group)
	var target_nodes: Array[Node] = get_tree().get_nodes_in_group("physics_targets")
	for target in target_nodes:
		if target.has_meta("target_id"):
			var target_id: String = target.get_meta("target_id")
			targets[target_id] = target
			# Connect signals
			if target.has_signal("body_entered"):
				target.body_entered.connect(_on_target_entered.bind(target_id))

	# Find weight plates (Area2D in "WeightPlates" group)
	var plate_nodes: Array[Node] = get_tree().get_nodes_in_group("weight_plates")
	for plate in plate_nodes:
		if plate.has_meta("plate_id"):
			var plate_id: String = plate.get_meta("plate_id")
			weight_plates[plate_id] = plate
			# Connect signals
			if plate.has_signal("body_entered"):
				plate.body_entered.connect(_on_weight_plate_entered.bind(plate_id))
			if plate.has_signal("body_exited"):
				plate.body_exited.connect(_on_weight_plate_exited.bind(plate_id))

	# Find water areas (Area2D in "WaterAreas" group)
	var water_nodes: Array[Node] = get_tree().get_nodes_in_group("water_areas")
	for water in water_nodes:
		if water.has_meta("water_id"):
			var water_id: String = water.get_meta("water_id")
			water_areas[water_id] = water
			# Connect signals
			if water.has_signal("body_entered"):
				water.body_entered.connect(_on_water_entered.bind(water_id))
			if water.has_signal("body_exited"):
				water.body_exited.connect(_on_water_exited.bind(water_id))

	# Find launchers (Node2D in "Launchers" group)
	var launcher_nodes: Array[Node] = get_tree().get_nodes_in_group("projectile_launchers")
	for launcher in launcher_nodes:
		if launcher.has_meta("launcher_id"):
			var launcher_id: String = launcher.get_meta("launcher_id")
			launchers[launcher_id] = launcher


## Setup momentum swing puzzle
func _setup_momentum_swing_puzzle() -> void:
	print("PhysicsPuzzle: Setting up momentum swing puzzle")
	# Solution data should contain swinging objects and targets
	# Example: {"swing_objects": ["pendulum_1"], "targets": ["bell_1"], "required_momentum": 500.0}


## Setup gravity drop puzzle
func _setup_gravity_drop_puzzle() -> void:
	print("PhysicsPuzzle: Setting up gravity drop puzzle")
	# Solution data should contain weight order and plates
	# Example: {"weight_order": ["heavy", "medium", "light"], "plates": ["plate_1", "plate_2", "plate_3"]}


## Setup buoyancy puzzle
func _setup_buoyancy_puzzle() -> void:
	print("PhysicsPuzzle: Setting up buoyancy puzzle")
	# Solution data should contain floating/sinking objects
	# Example: {"float_objects": ["cork_1", "wood_1"], "sink_objects": ["stone_1"]}


## Setup projectile puzzle
func _setup_projectile_puzzle() -> void:
	print("PhysicsPuzzle: Setting up projectile puzzle")
	# Solution data should contain launch parameters and targets
	# Example: {"projectiles": ["ball_1", "ball_2"], "targets": ["target_1", "target_2"]}


## Check if puzzle solution is correct
func check_solution() -> bool:
	match physics_puzzle_type:
		PhysicsPuzzleType.MOMENTUM_SWING:
			return _check_momentum_swing_solution()
		PhysicsPuzzleType.GRAVITY_DROP:
			return _check_gravity_drop_solution()
		PhysicsPuzzleType.BUOYANCY:
			return _check_buoyancy_solution()
		PhysicsPuzzleType.PROJECTILE:
			return _check_projectile_solution()

	return false


## Check momentum swing solution
func _check_momentum_swing_solution() -> bool:
	var required_targets: Array = solution_data.get("targets", [])

	# Check if all targets were hit with sufficient momentum
	for target_id in required_targets:
		if not target_id in hit_targets:
			return false

	return true


## Check gravity drop solution
func _check_gravity_drop_solution() -> bool:
	var weight_order: Array = solution_data.get("weight_order", [])
	var required_plates: Array = solution_data.get("plates", [])

	# Check if plates are activated in correct order
	if activated_plates.size() != required_plates.size():
		return false

	for i in range(required_plates.size()):
		if activated_plates[i] != required_plates[i]:
			return false

	return true


## Check buoyancy solution
func _check_buoyancy_solution() -> bool:
	var float_objects: Array = solution_data.get("float_objects", [])
	var sink_objects: Array = solution_data.get("sink_objects", [])

	# Check if floating objects are in water
	for obj_id in float_objects:
		if not obj_id in objects_in_water:
			return false

	# Check if sinking objects reached bottom (not in water area anymore)
	for obj_id in sink_objects:
		if obj_id in objects_in_water:
			# Still floating, not sunk yet
			return false

	return true


## Check projectile solution
func _check_projectile_solution() -> bool:
	var required_targets: Array = solution_data.get("targets", [])

	# Check if all targets were hit
	for target_id in required_targets:
		if not target_id in hit_targets:
			return false

	return true


## Called when physics object enters target area
func _on_target_entered(body: Node2D, target_id: String) -> void:
	if not is_active or is_solved:
		return

	# Check if body is a physics puzzle object
	var object_id: String = ""
	if body.has_meta("object_id"):
		object_id = body.get_meta("object_id")

	if not physics_objects.has(object_id):
		return

	# Check momentum for momentum swing puzzles
	if physics_puzzle_type == PhysicsPuzzleType.MOMENTUM_SWING:
		var momentum: float = _calculate_momentum(body)

		if momentum < required_momentum:
			print("PhysicsPuzzle: Insufficient momentum (%.1f < %.1f)" % [momentum, required_momentum])
			return

		momentum_threshold_reached.emit(object_id, momentum)

	# Record target hit
	objects_at_targets[target_id] = object_id
	if not target_id in hit_targets:
		hit_targets.append(target_id)

	physics_object_reached_target.emit(object_id, target_id)
	print("PhysicsPuzzle: Object %s reached target %s" % [object_id, target_id])

	# Check solution
	if check_solution():
		solve_puzzle()


## Calculate momentum of a physics object
func _calculate_momentum(body: Node2D) -> float:
	if not body is RigidBody2D:
		return 0.0

	var rigid_body: RigidBody2D = body as RigidBody2D
	var velocity: Vector2 = rigid_body.linear_velocity
	var mass: float = rigid_body.mass

	return velocity.length() * mass


## Called when weight plate is entered
func _on_weight_plate_entered(body: Node2D, plate_id: String) -> void:
	if not is_active or is_solved:
		return

	# Check if body is a physics puzzle object
	var object_id: String = ""
	if body.has_meta("object_id"):
		object_id = body.get_meta("object_id")

	if not physics_objects.has(object_id):
		return

	# Check weight requirement
	var required_weight: float = solution_data.get("plate_weights", {}).get(plate_id, 0.0)

	if body is RigidBody2D:
		var rigid_body: RigidBody2D = body as RigidBody2D
		var weight: float = rigid_body.mass

		if weight < required_weight:
			print("PhysicsPuzzle: Insufficient weight on plate %s (%.1f < %.1f)" % [plate_id, weight, required_weight])
			return

	# Activate plate
	if not plate_id in activated_plates:
		activated_plates.append(plate_id)
		print("PhysicsPuzzle: Weight plate %s activated by %s" % [plate_id, object_id])

		# Check solution
		if check_solution():
			solve_puzzle()


## Called when weight plate is exited
func _on_weight_plate_exited(body: Node2D, plate_id: String) -> void:
	if not is_active or is_solved:
		return

	# Deactivate plate if configured
	if plate_id in activated_plates:
		activated_plates.erase(plate_id)
		print("PhysicsPuzzle: Weight plate %s deactivated" % plate_id)


## Called when object enters water
func _on_water_entered(body: Node2D, water_id: String) -> void:
	if not is_active or is_solved:
		return

	# Check if body is a physics puzzle object
	var object_id: String = ""
	if body.has_meta("object_id"):
		object_id = body.get_meta("object_id")

	if not physics_objects.has(object_id):
		return

	# Add to water tracking
	if not object_id in objects_in_water:
		objects_in_water.append(object_id)
		object_entered_water.emit(object_id)
		print("PhysicsPuzzle: Object %s entered water" % object_id)

		# Apply buoyancy force
		_apply_buoyancy(body, water_id)

		# Check solution
		if check_solution():
			solve_puzzle()


## Called when object exits water
func _on_water_exited(body: Node2D, water_id: String) -> void:
	if not is_active:
		return

	# Check if body is a physics puzzle object
	var object_id: String = ""
	if body.has_meta("object_id"):
		object_id = body.get_meta("object_id")

	if not physics_objects.has(object_id):
		return

	# Remove from water tracking
	if object_id in objects_in_water:
		objects_in_water.erase(object_id)
		object_exited_water.emit(object_id)
		print("PhysicsPuzzle: Object %s exited water" % object_id)


## Apply buoyancy force to object in water
func _apply_buoyancy(body: Node2D, water_id: String) -> void:
	if not body is RigidBody2D:
		return

	var rigid_body: RigidBody2D = body as RigidBody2D

	# Get object density (from metadata or default)
	var density: float = rigid_body.get_meta("density", 1.0)
	var water_density: float = 1.0  # Water density

	# Apply buoyancy force
	if density < water_density:
		# Object floats - apply upward force
		var buoyancy_force: float = (water_density - density) * 100.0
		rigid_body.apply_central_force(Vector2(0, -buoyancy_force))
	else:
		# Object sinks - gravity pulls it down normally
		pass


## Launch projectile from launcher
func launch_projectile(launcher_id: String, force: float, angle_deg: float) -> void:
	if not is_active or is_solved:
		return

	if not launchers.has(launcher_id):
		print("PhysicsPuzzle: Launcher %s not found" % launcher_id)
		return

	var launcher: Node2D = launchers[launcher_id]

	# Create projectile (or activate existing one)
	# TODO: Implement projectile creation and launch
	# This would create a RigidBody2D projectile and apply impulse

	var launch_angle: float = deg_to_rad(angle_deg)
	var launch_vector: Vector2 = Vector2(cos(launch_angle), sin(launch_angle)) * force

	print("PhysicsPuzzle: Launching projectile from %s (force: %.1f, angle: %.1f)" % [launcher_id, force, angle_deg])


## Reset puzzle to initial state
func _on_puzzle_reset() -> void:
	objects_at_targets.clear()
	activated_plates.clear()
	objects_in_water.clear()
	hit_targets.clear()

	# Reset physics objects to initial positions
	for object_id in physics_objects.keys():
		var obj: Node = physics_objects[object_id]
		if obj.has_meta("initial_position"):
			var initial_pos: Vector2 = obj.get_meta("initial_position")
			obj.global_position = initial_pos

		# Reset velocity if RigidBody2D
		if obj is RigidBody2D:
			var rigid_body: RigidBody2D = obj as RigidBody2D
			rigid_body.linear_velocity = Vector2.ZERO
			rigid_body.angular_velocity = 0.0


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0

	match physics_puzzle_type:
		PhysicsPuzzleType.MOMENTUM_SWING, PhysicsPuzzleType.PROJECTILE:
			var required_targets: Array = solution_data.get("targets", [])
			if required_targets.is_empty():
				return 0.0
			return float(hit_targets.size()) / float(required_targets.size())

		PhysicsPuzzleType.GRAVITY_DROP:
			var required_plates: Array = solution_data.get("plates", [])
			if required_plates.is_empty():
				return 0.0
			return float(activated_plates.size()) / float(required_plates.size())

		PhysicsPuzzleType.BUOYANCY:
			var float_objects: Array = solution_data.get("float_objects", [])
			var sink_objects: Array = solution_data.get("sink_objects", [])
			var total_objects: int = float_objects.size() + sink_objects.size()

			if total_objects == 0:
				return 0.0

			var correct_count: int = 0

			# Count floating objects in water
			for obj_id in float_objects:
				if obj_id in objects_in_water:
					correct_count += 1

			# Count sinking objects not in water (reached bottom)
			for obj_id in sink_objects:
				if not obj_id in objects_in_water:
					correct_count += 1

			return float(correct_count) / float(total_objects)

	return 0.0


## Get hint for puzzle
func get_hint() -> String:
	var base_hint: String = super.get_hint()

	if base_hint != "No hint available":
		return base_hint

	# Provide physics-specific hints
	match physics_puzzle_type:
		PhysicsPuzzleType.MOMENTUM_SWING:
			return "Build up momentum by swinging objects to hit the target"
		PhysicsPuzzleType.GRAVITY_DROP:
			return "Drop weights in the correct order to activate plates"
		PhysicsPuzzleType.BUOYANCY:
			return "Use buoyancy to float or sink objects as needed"
		PhysicsPuzzleType.PROJECTILE:
			return "Aim and launch projectiles to hit all targets"

	return "Use physics to solve this puzzle"
