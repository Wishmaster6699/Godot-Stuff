# Research: S04 - Combat Prototype
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 45 minutes

---

## Research Objectives

Implement a 1v1 real-time combat system with rhythm integration that serves as the foundation for all future combat features (S05-S13, S19-S21).

---

## Godot 4.5 Documentation Research

### Combat System Architecture

**Official Documentation:**
- Godot 4.5 CharacterBody2D: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html
- Godot 4.5 Signals: https://docs.godotengine.org/en/4.5/getting_started/step_by_step/signals.html
- Godot 4.5 Scene Tree: https://docs.godotengine.org/en/4.5/tutorials/scripting/scene_tree.html

**Key Insights:**
- Use CharacterBody2D as base for Combatant (compatible with player movement)
- Signal-based architecture for combat events (damage, defeat, state changes)
- Node-based organization: CombatManager orchestrates, Combatant handles individual stats/actions

### State Machine Patterns

**Research Sources:**
- GDQuest State Machine Tutorial: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
- NightQuest Games Adaptive FSM: https://www.nightquestgames.com/how-to-build-state-machines-in-godot-4/

**Pattern Used:**
```gdscript
enum CombatState { IDLE, PLAYER_TURN, ENEMY_TURN, ENEMY_TELEGRAPH, VICTORY, DEFEAT }
var current_state: CombatState = CombatState.IDLE

func _change_state(new_state: CombatState) -> void:
    previous_state = current_state
    current_state = new_state
    _on_state_entered(new_state)
```

**Why This Works:**
- Simple enum-based state machine (no complex node hierarchy needed for prototype)
- Easy to extend in future systems (S09 adds more combat states)
- Aligns with GDQuest recommended patterns for Godot 4.x

### Damage Calculation Systems

**Research Sources:**
- Godot Forum: Complex RPG Damage System Discussion
- DEV.to: Godot 4 RPG Damage Implementation

**Formula Implemented:**
Based on combat-specification.md, using Pokemon-inspired damage formula:

```gdscript
var base_damage: float = (
    (((2.0 * attacker_level / 5.0) + 2.0) * attack_stat * move_power / defense_stat) / 50.0
) + 2.0

var final_damage: int = int(
    base_damage
    * weapon_modifier
    * timing_multiplier
    * critical_modifier
    * random_factor
)
```

**Key Design Decisions:**
1. **Level-based scaling:** Ensures stat growth matters
2. **Defense reduction:** Defense doesn't negate damage completely (division in formula)
3. **Multiplicative modifiers:** Timing, crits, equipment stack multiplicatively
4. **Random variance (0.85-1.0):** Prevents repetitive same-damage hits
5. **Minimum 1 damage:** Prevents 0-damage attacks feeling bad

---

## Existing Projects Research

### Pattern: Signal-Based Damage System

**Source:** GitHub - damage_lab example project

**Implementation:**
```gdscript
signal damage_taken(amount: int, source: Combatant, timing_quality: String)
signal health_changed(current_hp: int, max_hp: int, delta: int)

func take_damage(amount: int, source: Combatant = null) -> void:
    var old_hp = current_hp
    current_hp -= amount
    var hp_delta = current_hp - old_hp

    health_changed.emit(current_hp, max_hp, hp_delta)
    damage_taken.emit(amount, source, timing_quality)
```

**Why This Pattern:**
- UI can listen to health_changed for health bar updates
- Combat effects listen to damage_taken for visual feedback
- Decoupled: Combatant doesn't need to know about UI/effects

### Pattern: Timer-Based Status Effects

**Source:** MakeUseOf - Health & Damage System Tutorial

**Implementation:**
```gdscript
var status_effects: Dictionary = {"poison": 5.0, "burn": 3.5}

func _update_status_effects(delta: float) -> void:
    for effect_name in status_effects:
        status_effects[effect_name] -= delta
        _apply_status_effect_tick(effect_name, delta)

        if status_effects[effect_name] <= 0.0:
            remove_status_effect(effect_name)
```

**Why This Pattern:**
- Simple dictionary-based tracking (no complex effect objects needed for prototype)
- Delta-based countdown works with _process()
- Easy to extend in S13 (Vibe/Stamina) with more effect types

---

## Godot 4.5 Plugins/Addons

### RhythmNotifier Integration

**Already integrated in S01 Conductor**
- Conductor provides timing evaluation via `get_timing_quality(input_timestamp)`
- Returns "perfect", "good", or "miss" based on beat alignment
- Combat system uses this for damage multipliers

**No additional plugins needed for S04 prototype**

---

## GDScript 4.5 Specific Patterns

### Type Hints (Required)

```gdscript
# Correct GDScript 4.5
func attack_target(target: Combatant, move_power: int = 60) -> int:
    var damage: int = _calculate_damage(target, move_power)
    return damage

# Incorrect (GDScript 1.0 style)
func attack_target(target, move_power = 60):  # Missing type hints
```

### Signals with Typed Parameters

```gdscript
# Correct GDScript 4.5
signal damage_taken(amount: int, source: Combatant, timing_quality: String)

# Emit signals with .emit()
damage_taken.emit(damage, source, "perfect")
```

### String Repetition

```gdscript
# Correct GDScript 4.5
print("═".repeat(60))

# WRONG (GDScript 3.x / Python style)
print("═" * 60)  # This will error in Godot 4.5!
```

### Autoload Access

```gdscript
# Correct pattern for accessing Conductor autoload
if has_node("/root/Conductor"):
    conductor = get_node("/root/Conductor")
```

---

## Key Decisions & Trade-offs

### Decision 1: CharacterBody2D vs Node2D for Combatant

**Chosen:** CharacterBody2D

**Reasoning:**
- Player already uses CharacterBody2D (S03)
- Allows combatants to inherit player movement (enemy chasing)
- Compatible with collision detection for hitboxes (future S09)
- Physics integration (knockback, environmental hazards)

**Trade-off:** Slightly heavier than Node2D, but benefits outweigh cost

### Decision 2: Enum State Machine vs Node-Based State Machine

**Chosen:** Enum-based state machine

**Reasoning:**
- Simpler for prototype (less boilerplate)
- Easier to debug (states are just integers)
- Node-based is overkill for 6 combat states
- Can migrate to node-based in S11 (Enemy AI) if needed

**Trade-off:** Less extensible, but adequate for S04 scope

### Decision 3: Timing Multipliers

**Chosen:** Perfect=1.5x, Good=1.25x, Okay=1.0x, Miss=0.85x

**Source:** combat-specification.md (adjusted from initial 2.0x/1.5x/0.5x)

**Reasoning:**
- 2.0x perfect felt too punishing (miss = half damage)
- 1.5x perfect still rewards rhythm mastery
- 0.85x miss penalty prevents button mashing
- Balanced between "rhythm required" and "accessible to non-rhythm players"

### Decision 4: Telegraph Duration

**Chosen:** 1 beat warning (configurable in combat_config.json)

**Reasoning:**
- At 120 BPM, 1 beat = 500ms reaction time
- Enough time for player to dodge/block
- Aligns with combat-specification.md requirements
- Can be extended for difficulty scaling (easy = 2 beats)

### Decision 5: Damage Formula Complexity

**Chosen:** Full Pokemon-inspired formula with 7 multipliers

**Reasoning:**
- Allows stats to scale properly across levels
- Equipment/weapons have meaningful impact
- Rhythm timing feels impactful
- Future-proofs for S07 (Weapons), S08 (Equipment), S21 (Type Resonance)

**Trade-off:** More complex calculation, but optimized (runs once per attack)

---

## Integration Points

### S01 Conductor Integration

**How Combat Uses Conductor:**
1. `conductor.beat.connect(_on_conductor_beat)` - Track beats for telegraph countdown
2. `conductor.downbeat.connect(_on_conductor_downbeat)` - Measure-based turn timing
3. `conductor.get_timing_quality(input_timestamp)` - Evaluate player attack timing
4. `conductor.get_score_multiplier(quality)` - Get damage multiplier for timing

**Critical:** Combat system REQUIRES Conductor - will error if not available

### S02 InputManager Integration

**How Combat Uses Input:**
- Player attack action: `InputManager.is_action_pressed("attack")`
- Dodge action: `InputManager.is_action_pressed("dodge")`
- Block action: `InputManager.is_action_pressed("block")`

**Fallback:** If InputManager not available, uses default Input class

### S03 Player Integration

**How Combat Uses Player:**
- Player is a Combatant (extends CharacterBody2D, same as PlayerController)
- Player can enter combat mode (combat_state changes)
- Player stats loaded from player_config.json

**Note:** Player may need dual inheritance or composition pattern

---

## Gotchas for Tier 2 Agent

### Scene Configuration Challenges

1. **Combatant Node Setup:**
   - Root must be CharacterBody2D (not Node2D!)
   - Needs CollisionShape2D child for hitbox
   - Needs Sprite2D or AnimatedSprite2D for visuals

2. **Telegraph Visual Cue:**
   - Create ColorRect above enemy head
   - Animate modulate alpha on beat signal
   - Color from combat_config.json: "#FFFF00" (yellow)

3. **Health Bar UI:**
   - Use TextureProgressBar (not ProgressBar!)
   - tint_progress property for green → yellow → red
   - Update on Combatant.health_changed signal

4. **Autoload Considerations:**
   - CombatManager is NOT an autoload (per-scene instance)
   - Instantiate CombatManager in combat arena scenes
   - Connect to Conductor (which IS an autoload)

### Testing Gotchas

1. **Conductor Must Be Running:**
   - Call `Conductor.start()` before starting combat
   - Combat will fail if beat signals not emitting

2. **Timing Quality Testing:**
   - Use Conductor debug overlay (S01) to visualize beats
   - Test attacks on-beat vs off-beat
   - Verify damage multipliers apply correctly

3. **Telegraph Visual Feedback:**
   - Should flash yellow 1 beat before enemy attacks
   - Should disappear when attack executes
   - Should be clearly visible to player

4. **Win/Lose Conditions:**
   - Test player victory (enemy HP = 0)
   - Test player defeat (player HP = 0)
   - Verify combat_ended signal emits correctly
   - Check combat stats are calculated (accuracy, damage, etc.)

---

## Performance Considerations

### Optimization Strategies

1. **Damage Calculation:**
   - Runs only on attack execution (not per-frame)
   - Int casting at end minimizes floating-point operations
   - No object allocation during calculation

2. **Status Effect Updates:**
   - Dictionary-based (O(1) lookup)
   - Only processes active effects (not all possible effects)
   - Removed effects cleaned up immediately

3. **Signal Emissions:**
   - Signals are lightweight (Godot-optimized)
   - Emit only on state change (not per-frame)
   - UI updates reactive (no polling)

**Expected Performance:**
- Combat system: <0.5ms per frame (excluding rendering)
- Damage calculation: <0.1ms per attack
- Status effect updates: <0.2ms per frame (with 5 active effects)

---

## Future Extensions (Post-Prototype)

### S05 - Inventory System
- Add item usage during combat (potions, consumables)
- Connect to Combatant.heal() method

### S07 - Weapons System
- Extend weapon_bonus calculation
- Add weapon-specific attack animations
- Implement special weapon abilities

### S08 - Equipment System
- Equipment stats add to combatant base stats
- Equipment bonuses in damage formula
- Set bonuses for equipped gear

### S09 - Dodge/Block System
- Refine dodge i-frames (add stamina cost)
- Parry mechanic (perfect-timed block = counterattack)
- Directional blocking

### S11 - Enemy AI
- Replace simple telegraph AI with behavior trees
- Pattern-based attack sequences
- Difficulty scaling AI

### S13 - Health/Stamina Visualization
- Vibe bar integration
- Stamina costs for dodge/block
- Health bar color transitions

### S21 - Resonance/Alignment System
- Type effectiveness integration
- Elemental damage types
- Dual-type multipliers

---

## Reusable Patterns Created

### Pattern 1: Combatant Base Class

**File:** `combatant.gd`

**Reusability:**
- Can be extended by Player, Enemy, Monster, Boss
- All use same stat system and damage formula
- Signals allow UI/effects to attach to any combatant

**How to Reuse:**
```gdscript
extends Combatant
class_name EnemyGoblin

func _ready():
    super._ready()
    # Set enemy-specific stats
    set_stats({
        "max_hp": 50,
        "attack": 12,
        "defense": 6,
        # ...
    })
```

### Pattern 2: Combat State Machine

**File:** `combat_manager.gd`

**Reusability:**
- Can be adapted for turn-based combat (S04 future mode)
- Multi-combatant battles (S12 party system)
- Boss multi-phase battles

**How to Extend:**
```gdscript
enum CombatState {
    # ... existing states ...
    PHASE_TRANSITION,  # Boss phase changes
    CUTSCENE           # Mid-combat story events
}
```

### Pattern 3: JSON Configuration

**File:** `combat_config.json`

**Reusability:**
- All combat parameters in one place
- Can be loaded per-encounter for balance tweaks
- Supports difficulty scaling without code changes

**How to Use:**
```gdscript
var config = combatant.combat_config
var dodge_duration = config.get("dodge", {}).get("window_duration_s", 0.2)
```

---

## References

### Godot 4.5 Documentation
- CharacterBody2D: https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html
- Signals: https://docs.godotengine.org/en/4.5/getting_started/step_by_step/signals.html
- GDScript Style Guide: https://docs.godotengine.org/en/4.5/tutorials/scripting/gdscript/gdscript_styleguide.html

### Tutorials & Patterns
- GDQuest FSM: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
- NightQuest State Machines: https://www.nightquestgames.com/how-to-build-state-machines-in-godot-4/
- MakeUseOf Health System: https://www.makeuseof.com/health-damage-system-in-godot/

### Community Resources
- Godot Forum: Combat System Discussion
- DEV.to: Godot 4 RPG Development Series
- GitHub: damage_lab example project

### Project-Specific
- combat-specification.md (complete damage formula, timing windows, combat rules)
- S01 Conductor (rhythm timing integration)
- S03 Player (player controller integration)
- PARALLEL-EXECUTION-GUIDE-V2.md (development workflow)

---

## Knowledge Base Entry

**Created:** `knowledge-base/patterns/rhythm-combat-integration.md` (if non-trivial)

**Summary:**
Integrating Conductor rhythm timing with combat damage multipliers required careful timestamp handling and timing window evaluation. Key insight: Input timestamp must be captured at input time (not when damage is calculated) to accurately measure beat alignment.

**Code Pattern:**
```gdscript
# Capture timestamp when input occurs
func _input(event):
    if event.is_action_pressed("attack"):
        var input_time = Time.get_ticks_msec() / 1000.0
        combat_manager.player_attack(input_time)

# Evaluate timing when calculating damage
func attack_target(target, move_power, input_timestamp):
    var timing_quality = conductor.get_timing_quality(input_timestamp)
    var multiplier = _get_timing_multiplier(timing_quality)
    # ... apply multiplier to damage
```

---

**Research Complete:** Ready for implementation → HANDOFF to Tier 2 agent
