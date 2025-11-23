# HANDOFF: S09 - Dodge & Block Mechanics

## Files Created by Claude Code Web

### GDScript Files
- `src/systems/s09-dodgeblock/dodge_system.gd` - Complete dodge mechanics with rhythm timing, i-frames, cooldown management
- `src/systems/s09-dodgeblock/block_system.gd` - Complete block mechanics with stamina costs, damage reduction, rhythm timing

### Data Files
- `src/systems/s09-dodgeblock/dodge_block_config.json` - All dodge/block parameters, timing windows, stamina configuration

## System Overview

### Dodge System Features
- **Rhythm Timing Integration**: Uses Conductor (S01) to evaluate timing quality (Perfect/Good/Miss)
- **I-Frame Duration**:
  - Perfect timing: 0.3s invulnerability
  - Good timing: 0.2s invulnerability
  - Miss timing: 0.1s invulnerability
- **Cooldown**: 0.5s between dodges
- **Equipment Integration**: Supports cooldown modifiers and distance modifiers from S08

### Block System Features
- **Stamina System**:
  - Max stamina: 100
  - Block cost: 10 stamina
  - Regen rate: 10/s after 2s delay
- **Damage Reduction** (rhythm-based):
  - Perfect timing: 85% damage reduction
  - Good timing: 60% damage reduction
  - Miss timing: 30% damage reduction
- **Cooldown**: 1.0s between blocks
- **Equipment Integration**: Supports damage reduction bonuses and stamina cost modifiers from S08

### Integration Points
- **S01 Conductor**: Both systems use `get_timing_quality()` for rhythm evaluation
- **S04 Combat**: Integrates with Combatant's `is_invulnerable` and `is_blocking` flags
- **S08 Equipment**: Ready for equipment stat modifiers

---

## MCP Agent Tasks

### Phase 1: Create Test Scene

Create a test scene to demonstrate and test dodge/block mechanics with visual feedback.

```bash
# Create the test scene
create_scene res://src/systems/s09-dodgeblock/test_dodge_block.tscn Node2D

# Add root node
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Node2D TestDodgeBlock root

# Add Player (CharacterBody2D with dodge/block systems)
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CharacterBody2D Player TestDodgeBlock
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Sprite2D PlayerSprite Player
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CollisionShape2D PlayerCollision Player

# Add Dodge System to Player
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Node DodgeSystem Player
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Node BlockSystem Player

# Add Hurtbox for player
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Area2D Hurtbox Player
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CollisionShape2D HurtboxCollision Hurtbox

# Add Test Enemy with telegraphed attacks
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CharacterBody2D Enemy TestDodgeBlock
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Sprite2D EnemySprite Enemy
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CollisionShape2D EnemyCollision Enemy

# Add Enemy attack area
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Area2D AttackArea Enemy
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CollisionShape2D AttackCollision AttackArea

# Add UI Layer
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn CanvasLayer UI TestDodgeBlock
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn VBoxContainer UILayout UI

# Beat Timing Indicator
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label BeatIndicator UILayout
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn ProgressBar BeatProgress UILayout

# Stamina Bar
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label StaminaLabel UILayout
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn ProgressBar StaminaBar UILayout

# Dodge Status
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label DodgeCooldownLabel UILayout
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn ProgressBar DodgeCooldownBar UILayout

# Block Status
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label BlockCooldownLabel UILayout
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn ProgressBar BlockCooldownBar UILayout

# Success Counters
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label DodgeCounters UILayout
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label BlockCounters UILayout

# I-Frame Status Indicator
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label IFrameStatus UILayout

# Instructions
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn Label Instructions UILayout
```

### Phase 2: Attach Scripts

```bash
# Attach dodge and block systems
attach_script res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeSystem res://src/systems/s09-dodgeblock/dodge_system.gd
attach_script res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockSystem res://src/systems/s09-dodgeblock/block_system.gd
```

### Phase 3: Configure Scene Properties

```bash
# Player setup
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn Player position "Vector2(200, 300)"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn PlayerSprite modulate "Color(0.5, 0.8, 1.0, 1.0)"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn PlayerSprite texture "res://icon.svg"

# Enemy setup
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn Enemy position "Vector2(600, 300)"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn EnemySprite modulate "Color(1.0, 0.3, 0.3, 1.0)"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn EnemySprite texture "res://icon.svg"

# UI Layout
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn UILayout position "Vector2(10, 10)"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn UILayout custom_minimum_size "Vector2(400, 0)"

# Beat Indicator
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BeatIndicator text "Beat Timing: Waiting..."
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BeatProgress min_value 0
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BeatProgress max_value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BeatProgress value 0
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BeatProgress custom_minimum_size "Vector2(300, 20)"

# Stamina Bar
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn StaminaLabel text "Stamina:"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn StaminaBar min_value 0
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn StaminaBar max_value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn StaminaBar value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn StaminaBar custom_minimum_size "Vector2(300, 20)"

# Dodge Cooldown
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeCooldownLabel text "Dodge Cooldown:"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeCooldownBar min_value 0
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeCooldownBar max_value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeCooldownBar value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeCooldownBar custom_minimum_size "Vector2(300, 20)"

# Block Cooldown
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockCooldownLabel text "Block Cooldown:"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockCooldownBar min_value 0
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockCooldownBar max_value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockCooldownBar value 100
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockCooldownBar custom_minimum_size "Vector2(300, 20)"

# Success Counters
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeCounters text "Dodges - Perfect: 0 | Good: 0 | Miss: 0"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockCounters text "Blocks - Perfect: 0 | Good: 0 | Miss: 0"

# I-Frame Status
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn IFrameStatus text "I-Frames: Inactive"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn IFrameStatus modulate "Color(1, 1, 1, 1)"

# Instructions
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn Instructions text "Press B to Dodge | Press X to Block\nTry timing with the beat for Perfect/Good quality!\n\nPerfect dodge: 0.3s i-frames | Good: 0.2s | Miss: 0.1s\nPerfect block: 85% reduction | Good: 60% | Miss: 30%"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn Instructions autowrap_mode 3
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn Instructions custom_minimum_size "Vector2(400, 100)"
```

### Phase 4: Add Visual Effects

```bash
# Dodge ghost trail effect (placeholder)
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn GPUParticles2D DodgeTrail Player
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeTrail emitting false
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeTrail amount 20
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeTrail lifetime 0.3
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn DodgeTrail one_shot true

# Block shield clash effect (placeholder)
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn GPUParticles2D BlockClash Player
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockClash emitting false
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockClash amount 10
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockClash lifetime 0.2
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn BlockClash one_shot true

# Perfect timing flash effect
add_node res://src/systems/s09-dodgeblock/test_dodge_block.tscn ColorRect PerfectFlash UI
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn PerfectFlash color "Color(1, 1, 0, 0)"
update_property res://src/systems/s09-dodgeblock/test_dodge_block.tscn PerfectFlash mouse_filter 2
```

### Phase 5: Create Test Controller Script

Create a simple controller script to test dodge/block in the scene.

**File**: `src/systems/s09-dodgeblock/test_dodge_block_controller.gd`

```gdscript
extends Node2D

var dodge_system: DodgeSystem
var block_system: BlockSystem
var conductor: Node

# UI References
var stamina_bar: ProgressBar
var dodge_cooldown_bar: ProgressBar
var block_cooldown_bar: ProgressBar
var iframe_status: Label
var dodge_counters: Label
var block_counters: Label

# Statistics
var dodge_stats = {"perfect": 0, "good": 0, "miss": 0}
var block_stats = {"perfect": 0, "good": 0, "miss": 0}

func _ready():
	# Get system references
	dodge_system = $Player/DodgeSystem
	block_system = $Player/BlockSystem

	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
		conductor.start()

	# Get UI references
	stamina_bar = $UI/UILayout/StaminaBar
	dodge_cooldown_bar = $UI/UILayout/DodgeCooldownBar
	block_cooldown_bar = $UI/UILayout/BlockCooldownBar
	iframe_status = $UI/UILayout/IFrameStatus
	dodge_counters = $UI/UILayout/DodgeCounters
	block_counters = $UI/UILayout/BlockCounters

	# Connect signals
	dodge_system.dodge_executed.connect(_on_dodge_executed)
	block_system.block_executed.connect(_on_block_executed)
	block_system.stamina_changed.connect(_on_stamina_changed)
	dodge_system.iframes_started.connect(_on_iframes_started)
	dodge_system.iframes_ended.connect(_on_iframes_ended)

func _process(_delta):
	# Update UI
	if stamina_bar:
		stamina_bar.value = block_system.get_stamina_percentage() * 100.0

	if dodge_cooldown_bar:
		dodge_cooldown_bar.value = dodge_system.get_cooldown_progress() * 100.0

	if block_cooldown_bar:
		block_cooldown_bar.value = block_system.get_cooldown_progress() * 100.0

func _input(event):
	# Test dodge with B key
	if event.is_action_pressed("ui_accept"):  # Spacebar for dodge
		var timestamp = Time.get_ticks_msec() / 1000.0
		dodge_system.perform_dodge(timestamp)

	# Test block with X key (or another input)
	if event.is_action_pressed("ui_cancel"):  # Escape for block
		var timestamp = Time.get_ticks_msec() / 1000.0
		block_system.perform_block(timestamp)

func _on_dodge_executed(quality: String, duration: float):
	dodge_stats[quality] += 1
	_update_dodge_counters()
	print("Dodge executed: %s (%.2fs i-frames)" % [quality, duration])

func _on_block_executed(quality: String, reduction: float):
	block_stats[quality] += 1
	_update_block_counters()
	print("Block executed: %s (%.1f%% reduction)" % [quality, reduction * 100.0])

func _on_stamina_changed(current: int, max_stamina: int, delta: int):
	print("Stamina: %d/%d (%+d)" % [current, max_stamina, delta])

func _on_iframes_started(duration: float):
	if iframe_status:
		iframe_status.text = "I-Frames: ACTIVE (%.2fs)" % duration
		iframe_status.modulate = Color(0, 1, 0, 1)  # Green

func _on_iframes_ended():
	if iframe_status:
		iframe_status.text = "I-Frames: Inactive"
		iframe_status.modulate = Color(1, 1, 1, 1)  # White

func _update_dodge_counters():
	if dodge_counters:
		dodge_counters.text = "Dodges - Perfect: %d | Good: %d | Miss: %d" % [
			dodge_stats["perfect"],
			dodge_stats["good"],
			dodge_stats["miss"]
		]

func _update_block_counters():
	if block_counters:
		block_counters.text = "Blocks - Perfect: %d | Good: %d | Miss: %d" % [
			block_stats["perfect"],
			block_stats["good"],
			block_stats["miss"]
		]
```

**MCP Commands to add controller**:
```bash
# Create the controller script
create_script res://src/systems/s09-dodgeblock/test_dodge_block_controller.gd

# Attach to root node
attach_script res://src/systems/s09-dodgeblock/test_dodge_block.tscn TestDodgeBlock res://src/systems/s09-dodgeblock/test_dodge_block_controller.gd
```

---

## Testing Checklist

Use Godot MCP tools to test the implementation:

```bash
# Run the test scene
play_scene res://src/systems/s09-dodgeblock/test_dodge_block.tscn

# Check for errors
get_godot_errors
```

### Manual Testing Steps

**Verify the following in Godot Editor:**

#### Dodge System
- [ ] Press Spacebar to dodge
- [ ] Dodge timing quality is displayed (Perfect/Good/Miss based on beat timing)
- [ ] I-frame duration varies by timing quality:
  - Perfect: 0.3s (on-beat ±50ms)
  - Good: 0.2s (on-beat ±100ms)
  - Miss: 0.1s (off-beat)
- [ ] Dodge cooldown prevents spam (0.5s cooldown)
- [ ] Cooldown bar shows progress visually
- [ ] I-Frame status indicator shows "ACTIVE" (green) during i-frames
- [ ] Dodge counters increment correctly (Perfect/Good/Miss)
- [ ] Console prints dodge execution with quality and duration

#### Block System
- [ ] Press Escape to block
- [ ] Block timing quality is displayed (Perfect/Good/Miss based on beat timing)
- [ ] Damage reduction varies by timing quality:
  - Perfect: 85% reduction
  - Good: 60% reduction
  - Miss: 30% reduction
- [ ] Stamina depletes on block (10 stamina per block)
- [ ] Stamina bar shows current/max stamina visually
- [ ] Stamina regenerates after 2s delay (10/s regen rate)
- [ ] Block fails if stamina < 10
- [ ] Block cooldown prevents spam (1.0s cooldown)
- [ ] Cooldown bar shows progress visually
- [ ] Block counters increment correctly (Perfect/Good/Miss)
- [ ] Console prints block execution with quality and reduction

#### Rhythm Integration
- [ ] Conductor autoload is running (beat emissions visible in output)
- [ ] Timing quality evaluation works correctly with Conductor
- [ ] Perfect timing requires pressing within ±50ms of beat
- [ ] Good timing requires pressing within ±100ms of beat
- [ ] Miss timing is anything outside good window

#### Visual Feedback
- [ ] All UI elements display correctly
- [ ] Bars update in real-time
- [ ] Counters increment properly
- [ ] I-Frame status changes color (white → green → white)
- [ ] Instructions are readable and accurate

---

## Integration Points

### S01 Conductor Integration
Both systems use Conductor's `get_timing_quality()` method:
```gdscript
var timing_quality: String = conductor.get_timing_quality(input_timestamp)
# Returns: "perfect", "good", or "miss"
```

### S04 Combat Integration
Systems update Combatant state flags:
```gdscript
# Dodge sets:
combatant.is_invulnerable = true
combatant.combat_state = Combatant.CombatState.DODGING

# Block sets:
combatant.is_blocking = true
combatant.combat_state = Combatant.CombatState.BLOCKING
```

Combatant's `take_damage()` already checks these flags:
- `is_invulnerable` → no damage taken (i-frames)
- `is_blocking` → reduced damage based on block config

### S08 Equipment Integration
Equipment can provide modifiers:
```json
{
  "light_boots": {
    "dodge_cooldown_modifier": -0.1,
    "dodge_distance_modifier": 1.2
  },
  "heavy_shield": {
    "block_damage_reduction": 0.1,
    "stamina_cost_modifier": 1.5
  }
}
```

Apply modifiers via:
```gdscript
dodge_system.apply_equipment_modifiers(modifiers)
block_system.apply_equipment_modifiers(modifiers)
```

---

## Known Issues & Limitations

### Current Implementation
1. **Visual Effects**: Particle effects are placeholders (no configured ParticleProcessMaterial)
2. **Input Mapping**: Uses default Godot inputs (ui_accept, ui_cancel) - should use S02 InputManager in production
3. **No Player Movement**: Test scene is static - integrate with S03 Player for full movement
4. **No Enemy AI**: Enemy is static - integrate with S11 Enemy AI for telegraphed attacks

### Future Enhancements (Post-S09)
1. Add actual particle materials for dodge trail and block clash
2. Integrate with S02 InputManager for B/X button mapping
3. Create full combat test scene with moving player and attacking enemies
4. Add sound effects for dodge whoosh and block clash
5. Add screen shake on perfect block
6. Add visual telegraph indicator for enemy attacks
7. Full equipment modifier system integration

---

## Completion Criteria

### Tier 1 (Claude Code Web) - ✅ COMPLETE
- [x] `dodge_system.gd` created with full dodge logic
- [x] `block_system.gd` created with full block + stamina logic
- [x] `dodge_block_config.json` created with all parameters
- [x] HANDOFF-S09.md created with MCP instructions
- [x] Integration patterns documented for S01, S04, S08
- [x] GDScript 4.5 syntax compliance verified

### Tier 2 (MCP Agent) - TODO
- [ ] Test scene created and configured
- [ ] Scripts attached to nodes
- [ ] Properties configured correctly
- [ ] Test controller script created
- [ ] Scene runs without errors
- [ ] All manual testing steps verified
- [ ] Integration with Conductor confirmed
- [ ] Dodge timing quality works correctly
- [ ] Block timing quality works correctly
- [ ] Stamina system works correctly
- [ ] Cooldowns work correctly
- [ ] Visual feedback displays correctly

---

## Next Steps After S09 Completion

Once S09 is verified and complete:

1. **Update COORDINATION-DASHBOARD.md**:
   - Mark S09 as complete
   - Release any locked resources
   - Unblock S10 (Special Moves) - can now build on dodge/block

2. **Create Knowledge Base Entry** (if applicable):
   - Document any non-trivial patterns discovered
   - Add to `knowledge-base/patterns/dodge-block-rhythm-integration.md`

3. **Integration with Other Systems**:
   - S10 can now create special moves that combo with dodge/block
   - S11 Enemy AI can create enemies that encourage dodge/block usage
   - S03 Player can integrate dodge/block into movement system

4. **Performance Profiling**:
   ```gdscript
   PerformanceProfiler.profile_system("S09")
   ```

---

## Support & Troubleshooting

### Common Issues

**"Conductor autoload not found"**
- Ensure Conductor is set up as autoload in project.godot
- Path should be: `/root/Conductor`

**"Timing quality always returns 'miss'"**
- Check that Conductor is started: `conductor.start()`
- Verify beat emissions in console with `conductor.print_debug_info()`

**"Stamina not regenerating"**
- Check stamina_regen_delay (default 2s after block)
- Verify stamina_regen_rate in config (default 10/s)

**"Block has no effect on damage"**
- Verify Combatant's `take_damage()` checks `is_blocking` flag
- Check that BlockSystem sets `combatant.is_blocking = true`

**"Scripts not found when attaching"**
- Verify file paths are correct: `res://src/systems/s09-dodgeblock/*.gd`
- Check files exist in Godot FileSystem dock

---

## Summary

**System S09 (Dodge/Block Mechanics) is ready for Tier 2 integration.**

All code files have been created with:
- ✅ Complete dodge mechanics with rhythm timing and i-frames
- ✅ Complete block mechanics with stamina and damage reduction
- ✅ Full Conductor (S01) rhythm integration
- ✅ Combatant (S04) state management integration
- ✅ Equipment (S08) modifier support
- ✅ Comprehensive signal system for UI feedback
- ✅ GDScript 4.5 syntax compliance
- ✅ Extensive configuration via JSON
- ✅ Debug methods for testing

**MCP Agent**: Follow the commands above to create the test scene, attach scripts, configure properties, and verify functionality in the Godot editor.
