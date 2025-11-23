# HANDOFF: S16 - Grind Rail Traversal

## Status: Ready for Tier 2 (MCP Agent)

This document provides complete instructions for the Godot MCP agent to configure scenes and test the Grind Rail Traversal system (S16).

## Files Created by Claude Code Web (Tier 1)

### GDScript Files

✅ **`res://traversal/grind_rail.gd`** - Complete grind rail implementation
- Path2D-based rail following with PathFollow2D
- Rhythm-based balance mechanic (-100 to +100, safe zone -30 to +30)
- Beat-synced input handling (Left/Right on beat)
- Discord penalty integration with status effect system
- Jump precision with upbeat timing detection
- Full integration with Conductor (S01) for rhythm timing
- Signals for all events (entry, exit, balance changes, jumps, Discord)

### Data Files

✅ **`res://data/grind_rail_config.json`** - Grind rail configuration
- Rail speed: 200 px/s
- Balance oscillation speed: 1.0x tempo
- Safe zone: ±30
- Discord penalty: -20% stats for 5 seconds
- Jump timing: 50ms perfect window, 500/250 force

## System Integration Points

### Dependencies

**S01 (Conductor) - REQUIRED:**
- Signal: `beat(beat_number: int)` - Balance oscillation timing
- Signal: `upbeat(beat_number: int)` - Jump timing windows
- Method: `get_timing_quality(input_timestamp: float) -> String` - Input evaluation
- Method: `get_bpm() -> float` - Tempo for oscillation speed
- Autoload: `/root/Conductor`

**S03 (Player Controller) - REQUIRED:**
- Method: `set_velocity_external(new_velocity: Vector2)` - Jump force application
- Property: `velocity: Vector2` - Direct velocity access for CharacterBody2D
- The player node must be accessible to call these methods

**S04 (Combat/Status Effects) - OPTIONAL:**
- Method: `apply_status_effect(effect_name: String, duration: float)` - Discord penalty
- If player has this method, Discord penalty will be applied as status effect
- If not available, system works but without stat reduction

## MCP Agent Tasks

### Task 1: Create Base Grind Rail Scene

Create a reusable grind rail scene that can be instantiated in levels.

```bash
# Create the base grind rail scene
create_scene "res://traversal/grind_rail.tscn" "Path2D"

# Attach the grind rail script to root
attach_script "res://traversal/grind_rail.tscn" "." "res://traversal/grind_rail.gd"

# Add PathFollow2D for rail traversal
add_node "res://traversal/grind_rail.tscn" "PathFollow2D" "RailFollower" "."

# Add visual representation (Line2D to show rail path)
add_node "res://traversal/grind_rail.tscn" "Line2D" "RailVisual" "."
update_property "res://traversal/grind_rail.tscn" "RailVisual" "default_color" "Color(0.2, 0.6, 1.0, 1.0)"
update_property "res://traversal/grind_rail.tscn" "RailVisual" "width" "4.0"

# Add entry detection area
add_node "res://traversal/grind_rail.tscn" "Area2D" "EntryArea" "."
add_node "res://traversal/grind_rail.tscn" "CollisionShape2D" "EntryCollision" "EntryArea"
```

**Note:** The Path2D curve points must be configured per-instance in the level editor or test scene.

### Task 2: Create Balance UI Scene

Create a UI scene to display balance bar and beat markers.

```bash
# Create balance UI scene
create_scene "res://traversal/balance_ui.tscn" "CanvasLayer"

# Add background panel
add_node "res://traversal/balance_ui.tscn" "Panel" "BalancePanel" "."
update_property "res://traversal/balance_ui.tscn" "BalancePanel" "offset_left" "400"
update_property "res://traversal/balance_ui.tscn" "BalancePanel" "offset_top" "500"
update_property "res://traversal/balance_ui.tscn" "BalancePanel" "offset_right" "880"
update_property "res://traversal/balance_ui.tscn" "BalancePanel" "offset_bottom" "580"

# Add balance bar (ProgressBar for visual representation)
add_node "res://traversal/balance_ui.tscn" "ProgressBar" "BalanceBar" "BalancePanel"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "min_value" "-100"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "max_value" "100"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "value" "0"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "show_percentage" "false"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "offset_left" "10"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "offset_top" "20"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "offset_right" "470"
update_property "res://traversal/balance_ui.tscn" "BalanceBar" "offset_bottom" "60"

# Add safe zone indicator (ColorRect)
add_node "res://traversal/balance_ui.tscn" "ColorRect" "SafeZoneLeft" "BalancePanel"
update_property "res://traversal/balance_ui.tscn" "SafeZoneLeft" "color" "Color(0, 1, 0, 0.3)"
update_property "res://traversal/balance_ui.tscn" "SafeZoneLeft" "offset_left" "170"
update_property "res://traversal/balance_ui.tscn" "SafeZoneLeft" "offset_top" "20"
update_property "res://traversal/balance_ui.tscn" "SafeZoneLeft" "offset_right" "240"
update_property "res://traversal/balance_ui.tscn" "SafeZoneLeft" "offset_bottom" "60"

add_node "res://traversal/balance_ui.tscn" "ColorRect" "SafeZoneRight" "BalancePanel"
update_property "res://traversal/balance_ui.tscn" "SafeZoneRight" "color" "Color(0, 1, 0, 0.3)"
update_property "res://traversal/balance_ui.tscn" "SafeZoneRight" "offset_left" "240"
update_property "res://traversal/balance_ui.tscn" "SafeZoneRight" "offset_top" "20"
update_property "res://traversal/balance_ui.tscn" "SafeZoneRight" "offset_right" "310"
update_property "res://traversal/balance_ui.tscn" "SafeZoneRight" "offset_bottom" "60"

# Add beat marker label
add_node "res://traversal/balance_ui.tscn" "Label" "BeatMarker" "BalancePanel"
update_property "res://traversal/balance_ui.tscn" "BeatMarker" "text" "♪ BEAT"
update_property "res://traversal/balance_ui.tscn" "BeatMarker" "horizontal_alignment" "1"
update_property "res://traversal/balance_ui.tscn" "BeatMarker" "offset_left" "10"
update_property "res://traversal/balance_ui.tscn" "BeatMarker" "offset_top" "5"
update_property "res://traversal/balance_ui.tscn" "BeatMarker" "offset_right" "470"
update_property "res://traversal/balance_ui.tscn" "BeatMarker" "offset_bottom" "20"

# Add balance value label
add_node "res://traversal/balance_ui.tscn" "Label" "BalanceValue" "BalancePanel"
update_property "res://traversal/balance_ui.tscn" "BalanceValue" "text" "Balance: 0"
update_property "res://traversal/balance_ui.tscn" "BalanceValue" "horizontal_alignment" "1"
update_property "res://traversal/balance_ui.tscn" "BalanceValue" "offset_left" "10"
update_property "res://traversal/balance_ui.tscn" "BalanceValue" "offset_top" "60"
update_property "res://traversal/balance_ui.tscn" "BalanceValue" "offset_right" "470"
update_property "res://traversal/balance_ui.tscn" "BalanceValue" "offset_bottom" "75"
```

### Task 3: Create Test Scene

Create a comprehensive test scene with multiple grind rails, platforms, and UI.

```bash
# Create test scene
create_scene "res://tests/test_grind_rail.tscn" "Node2D"

# Add Conductor (if not autoloaded)
# Note: Conductor should be autoloaded in project.godot by S01 setup

# Add background
add_node "res://tests/test_grind_rail.tscn" "ColorRect" "Background" "."
update_property "res://tests/test_grind_rail.tscn" "Background" "color" "Color(0.1, 0.1, 0.15, 1.0)"
update_property "res://tests/test_grind_rail.tscn" "Background" "offset_left" "0"
update_property "res://tests/test_grind_rail.tscn" "Background" "offset_top" "0"
update_property "res://tests/test_grind_rail.tscn" "Background" "offset_right" "1280"
update_property "res://tests/test_grind_rail.tscn" "Background" "offset_bottom" "720"
update_property "res://tests/test_grind_rail.tscn" "Background" "z_index" "-100"

# Add platforms (using StaticBody2D with CollisionShape2D)
add_node "res://tests/test_grind_rail.tscn" "StaticBody2D" "PlatformStart" "."
update_property "res://tests/test_grind_rail.tscn" "PlatformStart" "position" "Vector2(100, 500)"
add_node "res://tests/test_grind_rail.tscn" "CollisionShape2D" "Collision" "PlatformStart"
add_node "res://tests/test_grind_rail.tscn" "ColorRect" "Visual" "PlatformStart"
update_property "res://tests/test_grind_rail.tscn" "Visual" "color" "Color(0.3, 0.3, 0.3, 1.0)"
update_property "res://tests/test_grind_rail.tscn" "Visual" "size" "Vector2(200, 40)"
update_property "res://tests/test_grind_rail.tscn" "Visual" "position" "Vector2(-100, -20)"

add_node "res://tests/test_grind_rail.tscn" "StaticBody2D" "PlatformEnd" "."
update_property "res://tests/test_grind_rail.tscn" "PlatformEnd" "position" "Vector2(900, 500)"
add_node "res://tests/test_grind_rail.tscn" "CollisionShape2D" "Collision" "PlatformEnd"
add_node "res://tests/test_grind_rail.tscn" "ColorRect" "Visual" "PlatformEnd"
update_property "res://tests/test_grind_rail.tscn" "Visual" "color" "Color(0.3, 0.3, 0.3, 1.0)"
update_property "res://tests/test_grind_rail.tscn" "Visual" "size" "Vector2(200, 40)"
update_property "res://tests/test_grind_rail.tscn" "Visual" "position" "Vector2(-100, -20)"

# Add first grind rail instance
add_scene "res://tests/test_grind_rail.tscn" "res://traversal/grind_rail.tscn" "GrindRail1" "."
update_property "res://tests/test_grind_rail.tscn" "GrindRail1" "position" "Vector2(200, 400)"

# Configure rail curve (straight line for testing)
# NOTE: Curves must be configured in the editor or via editor script
# The MCP agent should use execute_editor_script to set curve points

# Add second grind rail with curve
add_scene "res://tests/test_grind_rail.tscn" "res://traversal/grind_rail.tscn" "GrindRail2" "."
update_property "res://tests/test_grind_rail.tscn" "GrindRail2" "position" "Vector2(200, 300)"

# Add player (if S03 scene exists)
# add_scene "res://tests/test_grind_rail.tscn" "res://src/systems/s03-player/player.tscn" "Player" "."
# update_property "res://tests/test_grind_rail.tscn" "Player" "position" "Vector2(150, 450)"

# Add balance UI
add_scene "res://tests/test_grind_rail.tscn" "res://traversal/balance_ui.tscn" "BalanceUI" "."

# Add instructions label
add_node "res://tests/test_grind_rail.tscn" "CanvasLayer" "InstructionsLayer" "."
add_node "res://tests/test_grind_rail.tscn" "Label" "Instructions" "InstructionsLayer"
update_property "res://tests/test_grind_rail.tscn" "Instructions" "text" "GRIND RAIL TEST\\n\\nPress LEFT/RIGHT on beat to balance\\nPress SPACE on upbeat to jump\\n\\nBalance must stay in green zone (-30 to +30)\\n3 missed beats = Discord penalty + fall"
update_property "res://tests/test_grind_rail.tscn" "Instructions" "offset_left" "20"
update_property "res://tests/test_grind_rail.tscn" "Instructions" "offset_top" "20"
update_property "res://tests/test_grind_rail.tscn" "Instructions" "offset_right" "400"
update_property "res://tests/test_grind_rail.tscn" "Instructions" "offset_bottom" "150"
```

### Task 4: Configure Grind Rail Curves

The grind rail curves need to be configured using an editor script since they require Curve2D manipulation.

```bash
# Execute editor script to set up rail curves
execute_editor_script "
extends EditorScript

func _run() -> void:
	# Open test scene
	var scene = load('res://tests/test_grind_rail.tscn').instantiate()

	# Configure GrindRail1 - Straight rail
	var rail1 = scene.get_node('GrindRail1')
	if rail1:
		var curve1 = Curve2D.new()
		curve1.add_point(Vector2(0, 0))
		curve1.add_point(Vector2(400, 0))
		curve1.add_point(Vector2(600, -50))
		rail1.curve = curve1
		print('GrindRail1 curve configured')

	# Configure GrindRail2 - Curved rail
	var rail2 = scene.get_node('GrindRail2')
	if rail2:
		var curve2 = Curve2D.new()
		curve2.add_point(Vector2(0, 0))
		curve2.add_point(Vector2(200, 50))
		curve2.add_point(Vector2(400, 0))
		curve2.add_point(Vector2(600, -50))
		rail2.curve = curve2
		print('GrindRail2 curve configured')

	# Save scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	ResourceSaver.save(packed_scene, 'res://tests/test_grind_rail.tscn')
	print('Test scene saved with configured curves')
"
```

### Task 5: Create Grind Rail Controller Script (UI Integration)

Create a helper script to connect the balance UI to the grind rail signals.

```bash
# Create the controller script
create_script "res://traversal/grind_rail_ui_controller.gd" "extends Node

# Connect grind rail signals to UI elements
var grind_rail: GrindRail = null
var balance_bar: ProgressBar = null
var balance_value_label: Label = null
var beat_marker: Label = null

func _ready() -> void:
	# Find grind rail and UI elements
	# This script should be attached to the test scene root
	_find_nodes()
	_connect_signals()

func _find_nodes() -> void:
	# Find grind rail
	for child in get_parent().get_children():
		if child is GrindRail:
			grind_rail = child
			break

	# Find UI elements
	var ui = get_parent().get_node_or_null('BalanceUI')
	if ui:
		balance_bar = ui.get_node_or_null('BalancePanel/BalanceBar')
		balance_value_label = ui.get_node_or_null('BalancePanel/BalanceValue')
		beat_marker = ui.get_node_or_null('BalancePanel/BeatMarker')

func _connect_signals() -> void:
	if grind_rail == null:
		return

	grind_rail.balance_changed.connect(_on_balance_changed)
	grind_rail.balance_success.connect(_on_balance_success)
	grind_rail.balance_miss.connect(_on_balance_miss)
	grind_rail.player_entered_rail.connect(_on_player_entered)
	grind_rail.player_exited_rail.connect(_on_player_exited)

func _on_balance_changed(balance: float, is_safe: bool) -> void:
	if balance_bar:
		balance_bar.value = balance

	if balance_value_label:
		balance_value_label.text = 'Balance: ' + str(int(balance))
		balance_value_label.modulate = Color.GREEN if is_safe else Color.RED

func _on_balance_success(quality: String) -> void:
	if beat_marker:
		beat_marker.text = '♪ ' + quality.to_upper() + '!'
		beat_marker.modulate = Color.GREEN

func _on_balance_miss() -> void:
	if beat_marker:
		beat_marker.text = '✗ MISS'
		beat_marker.modulate = Color.RED

func _on_player_entered(player: Node2D) -> void:
	print('UI: Player entered rail')

func _on_player_exited(player: Node2D, reason: String) -> void:
	print('UI: Player exited rail - ', reason)
"

# Attach controller to test scene
attach_script "res://tests/test_grind_rail.tscn" "." "res://traversal/grind_rail_ui_controller.gd"
```

## Testing Checklist

Run the test scene and verify all functionality:

```bash
# Play the test scene
play_scene "res://tests/test_grind_rail.tscn"

# Check for errors
get_godot_errors

# Take screenshot to verify visual setup
get_running_scene_screenshot
```

### Manual Testing Steps

1. **Conductor Integration:**
   - [ ] Verify Conductor autoload is active (`/root/Conductor`)
   - [ ] Check that Conductor is emitting beat signals (check debug output)
   - [ ] Confirm BPM is set (default 120 or from config)

2. **Rail Entry:**
   - [ ] Player can enter grind rail (call `enter_rail(player)` method)
   - [ ] Player position snaps to rail start
   - [ ] Balance bar initializes at 0
   - [ ] Balance UI appears and updates

3. **Balance Mechanics:**
   - [ ] Balance bar oscillates automatically with tempo
   - [ ] Balance oscillation follows Conductor BPM
   - [ ] Pressing LEFT on beat pulls balance left
   - [ ] Pressing RIGHT on beat pulls balance right
   - [ ] Perfect timing gives better balance adjustment
   - [ ] Balance value stays between -100 and +100
   - [ ] Green safe zone is visible on UI (-30 to +30)

4. **Balance Failure:**
   - [ ] Missing 3 beats increments miss counter
   - [ ] After 3 consecutive misses, Discord penalty applies
   - [ ] Player falls off rail after Discord penalty
   - [ ] Discord status effect appears on player (if Combatant)

5. **Jump Mechanics:**
   - [ ] Jump only possible while grinding
   - [ ] Pressing SPACE on upbeat gives perfect jump (500 force)
   - [ ] Pressing SPACE off-beat gives weak jump (250 force)
   - [ ] Jump exits the rail correctly
   - [ ] Player velocity is applied correctly

6. **Rail Traversal:**
   - [ ] Player follows Path2D curve smoothly
   - [ ] Rail speed is 200 px/s (from config)
   - [ ] Player reaches end of rail and exits automatically
   - [ ] Progress signal emits with correct ratio (0.0 to 1.0)

7. **Visual Feedback:**
   - [ ] Balance bar updates in real-time
   - [ ] Beat marker flashes on beat
   - [ ] "PERFECT"/"GOOD"/"MISS" displays on input
   - [ ] Safe zone indicator is green and visible
   - [ ] Rail path is visible (Line2D)

8. **Configuration:**
   - [ ] Config file loads successfully
   - [ ] All values from JSON are applied correctly
   - [ ] Fallback to defaults if config missing

9. **Signals:**
   - [ ] `player_entered_rail` emits on entry
   - [ ] `player_exited_rail` emits on exit with reason
   - [ ] `balance_changed` emits continuously
   - [ ] `balance_success` emits on good timing
   - [ ] `balance_miss` emits on bad timing
   - [ ] `discord_applied` emits when penalty triggers
   - [ ] `jump_executed` emits when jumping
   - [ ] `progress_updated` emits during traversal

## Integration Points

### Connecting to Player (S03)

The player needs to be able to enter the grind rail. Add this to your player controller or level manager:

```gdscript
# Example: Detect when player enters grind rail area
func _on_grind_rail_entry_area_entered(body: Node2D) -> void:
	if body.name == "Player":
		var rail = $GrindRail1  # Get the rail node
		rail.enter_rail(body)
```

### Connecting to Conductor (S01)

The grind rail automatically connects to the Conductor autoload. Ensure:
1. Conductor is registered as autoload in `project.godot`
2. Conductor is running (`conductor.start()`)
3. Conductor is emitting beat signals

### Connecting to Combat System (S04)

If the player has Combatant functionality (status effects), the Discord penalty will automatically apply as a status effect. No additional setup needed.

## Known Issues and Solutions

### Issue: Player doesn't snap to rail
**Solution:** Ensure `path_follower` is created in `_ready()` and player position is set in `enter_rail()`

### Issue: Balance doesn't oscillate
**Solution:** Check Conductor is running and BPM is > 0

### Issue: Jump doesn't work
**Solution:** Verify player has `set_velocity_external()` method or is CharacterBody2D

### Issue: Discord penalty doesn't apply
**Solution:** Player must have `apply_status_effect()` method (Combatant class)

## Performance Notes

- Each grind rail instance creates one PathFollow2D node
- Balance calculation is lightweight (runs in `_process()`)
- No physics calculations except player movement
- Suitable for multiple simultaneous rails

## Next Steps (After Testing)

1. **Create additional rail scenes:**
   - Looping rails
   - Branching rails (multiple paths)
   - Rails with speed zones

2. **Enhance visual feedback:**
   - Particle effects on balance success
   - Screen shake on Discord penalty
   - Trail effect behind player

3. **Add audio:**
   - Rail grinding sound effect
   - Balance success/miss sounds
   - Discord penalty dissonant sound

4. **Create level integration:**
   - Place grind rails in main game levels
   - Connect to platforming sections
   - Add rail-to-rail transitions

## Completion Criteria

Mark S16 as complete when:

- ✅ All test cases pass
- ✅ No errors in `get_godot_errors`
- ✅ Balance mechanic works smoothly
- ✅ Conductor integration confirmed
- ✅ Jump timing works correctly
- ✅ Discord penalty applies
- ✅ Visual feedback displays correctly
- ✅ Configuration loads from JSON
- ✅ All signals emit properly

## Update Coordination Dashboard

After testing is complete, update `COORDINATION-DASHBOARD.md`:

```markdown
### S16: Grind Rail Traversal ✅
- **Status:** Complete
- **Dependencies:** S01 ✅, S03 ✅
- **Blocks:** None
- **Files:** `res://traversal/grind_rail.gd`, `res://data/grind_rail_config.json`
- **Completed:** [DATE]
- **Notes:** Jet Set Radio-style grinding with rhythm-based balance mechanics
```

## Quality Gates

Run these framework quality checks:

```gdscript
# Integration tests
IntegrationTestSuite.run_all_tests()

# Performance profiling
PerformanceProfiler.profile_system("S16")

# Quality gates
check_quality_gates("S16")

# Checkpoint validation
validate_checkpoint("S16")
```

---

**Tier 1 (Claude Code Web) Complete ✅**
**Ready for Tier 2 (MCP Agent) ⏭️**
