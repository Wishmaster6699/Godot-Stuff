# Godot 4.5 | GDScript 4.5
# System: S19 - Dual XP System
# Created: 2025-11-18
# Dependencies: XPManager
#
# Level-up panel displays level-up notifications and stat increases
# Shows which XP type leveled up and the stat bonuses gained

extends Panel

class_name LevelUpPanel

## Signals

## Emitted when panel animation completes
signal display_complete()

# ═════════════════════════════════════════════════════════════════════════════
# Node References (set by MCP agent or in _ready)
# ═════════════════════════════════════════════════════════════════════════════

## Title label showing level-up message
@onready var title_label: Label = $TitleLabel if has_node("TitleLabel") else null

## Label showing combat level information
@onready var combat_level_label: Label = $CombatLevelLabel if has_node("CombatLevelLabel") else null

## Label showing knowledge level information
@onready var knowledge_level_label: Label = $KnowledgeLevelLabel if has_node("KnowledgeLevelLabel") else null

## Container for stat increase labels
@onready var stats_container: VBoxContainer = $StatsContainer if has_node("StatsContainer") else null

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

## Display duration in seconds
@export var display_duration: float = 3.0

## Fade in duration
@export var fade_in_duration: float = 0.3

## Fade out duration
@export var fade_out_duration: float = 0.3

# ═════════════════════════════════════════════════════════════════════════════
# State
# ═════════════════════════════════════════════════════════════════════════════

## Is panel currently displaying
var is_displaying: bool = false

## Reference to XPManager autoload
var xp_manager: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Get XPManager reference
	if has_node("/root/XPManager"):
		xp_manager = get_node("/root/XPManager")
		_connect_xp_signals()
	else:
		push_warning("LevelUpPanel: XPManager autoload not found")

	# Hide panel initially
	visible = false
	modulate = Color(1, 1, 1, 0)


## Connect to XP manager signals
func _connect_xp_signals() -> void:
	if xp_manager == null:
		return

	# Connect to level-up signals
	if xp_manager.has_signal("combat_level_up"):
		xp_manager.combat_level_up.connect(_on_combat_level_up)

	if xp_manager.has_signal("knowledge_level_up"):
		xp_manager.knowledge_level_up.connect(_on_knowledge_level_up)


# ═════════════════════════════════════════════════════════════════════════════
# Level-Up Display
# ═════════════════════════════════════════════════════════════════════════════

## Display combat level-up notification
func _on_combat_level_up(new_level: int, stat_increases: Dictionary) -> void:
	show_level_up("COMBAT", new_level, stat_increases, Color(1.0, 0.3, 0.3))


## Display knowledge level-up notification
func _on_knowledge_level_up(new_level: int, stat_increases: Dictionary) -> void:
	show_level_up("KNOWLEDGE", new_level, stat_increases, Color(0.3, 0.6, 1.0))


## Show level-up panel with animation
## @param xp_type: "COMBAT" or "KNOWLEDGE"
## @param new_level: New level reached
## @param stat_increases: Dictionary of stat increases
## @param color: Color theme for this XP type
func show_level_up(xp_type: String, new_level: int, stat_increases: Dictionary, color: Color) -> void:
	if is_displaying:
		# Queue this level-up to show after current one
		await display_complete
		await get_tree().create_timer(0.5).timeout

	is_displaying = true

	# Update labels
	_update_level_up_display(xp_type, new_level, stat_increases, color)

	# Show panel with fade-in animation
	visible = true
	await _fade_in()

	# Display for duration
	await get_tree().create_timer(display_duration).timeout

	# Fade out
	await _fade_out()

	# Hide panel
	visible = false
	is_displaying = false

	display_complete.emit()


## Update panel content with level-up info
func _update_level_up_display(xp_type: String, new_level: int, stat_increases: Dictionary, color: Color) -> void:
	# Set title
	if title_label != null:
		title_label.text = "%s LEVEL UP!" % xp_type
		title_label.modulate = color

	# Set level label
	var level_text: String = "Level %d Reached!" % new_level

	if xp_type == "COMBAT":
		if combat_level_label != null:
			combat_level_label.text = level_text
			combat_level_label.modulate = color
			combat_level_label.visible = true
		if knowledge_level_label != null:
			knowledge_level_label.visible = false
	else:  # KNOWLEDGE
		if knowledge_level_label != null:
			knowledge_level_label.text = level_text
			knowledge_level_label.modulate = color
			knowledge_level_label.visible = true
		if combat_level_label != null:
			combat_level_label.visible = false

	# Update stat increases
	_update_stats_display(stat_increases, color)


## Update stats container with stat increases
func _update_stats_display(stat_increases: Dictionary, color: Color) -> void:
	if stats_container == null:
		return

	# Clear existing stat labels
	for child in stats_container.get_children():
		child.queue_free()

	# Create labels for each stat increase
	for stat_name in stat_increases:
		var increase: int = stat_increases[stat_name]
		var stat_label: Label = Label.new()

		# Format stat name (e.g., "max_hp" → "Max HP")
		var formatted_name: String = _format_stat_name(stat_name)

		# Set label text
		stat_label.text = "%s +%d" % [formatted_name, increase]
		stat_label.modulate = color

		# Add to container
		stats_container.add_child(stat_label)


## Format stat name for display
func _format_stat_name(stat_name: String) -> String:
	# Convert snake_case to Title Case
	var words: PackedStringArray = stat_name.split("_")
	var formatted_words: PackedStringArray = []

	for word in words:
		if word.is_empty():
			continue
		# Capitalize first letter
		var capitalized: String = word[0].to_upper() + word.substr(1)
		formatted_words.append(capitalized)

	return " ".join(formatted_words)


# ═════════════════════════════════════════════════════════════════════════════
# Animations
# ═════════════════════════════════════════════════════════════════════════════

## Fade in animation
func _fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), fade_in_duration)
	await tween.finished


## Fade out animation
func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), fade_out_duration)
	await tween.finished


# ═════════════════════════════════════════════════════════════════════════════
# Manual Display (for testing)
# ═════════════════════════════════════════════════════════════════════════════

## Manually show combat level-up (for testing)
func test_combat_level_up(level: int = 5) -> void:
	var stat_increases: Dictionary = {
		"max_hp": 10,
		"physical_attack": 3,
		"physical_defense": 2,
		"speed": 1
	}
	show_level_up("COMBAT", level, stat_increases, Color(1.0, 0.3, 0.3))


## Manually show knowledge level-up (for testing)
func test_knowledge_level_up(level: int = 5) -> void:
	var stat_increases: Dictionary = {
		"max_mp": 10,
		"special_attack": 3,
		"special_defense": 2,
		"magic_affinity": 1
	}
	show_level_up("KNOWLEDGE", level, stat_increases, Color(0.3, 0.6, 1.0))
