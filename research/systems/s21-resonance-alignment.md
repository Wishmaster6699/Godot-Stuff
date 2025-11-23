# Research: S21 - Resonance Alignment System
**Agent:** Claude Code Web
**Date:** 2025-11-18
**Duration:** 30 minutes

## Godot 4.5 Autoload Pattern

### Resources
- [Official Godot Docs: Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [Godot 4 Autoload Tutorial - NightQuest Games](https://www.nightquestgames.com/godot-4-autoload-singletons-in-gdscript/)
- [Autoloads vs Internal Nodes Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html)

### Key Insights
- Autoload creates a singleton-like pattern for global state management
- Must extend Node class to be used as autoload
- Registered in project.godot under [autoload] section
- Perfect for persistent game state like alignment tracking
- Access globally by name throughout the game

## Game Alignment System Design

### Research Sources
- [Alignment (Role-Playing Games) - Wikipedia](https://en.wikipedia.org/wiki/Alignment_(role-playing_games))
- [Game Mechanic Alignment Theory (arXiv)](https://arxiv.org/abs/2102.10247)
- [10 Best Morality Systems in Video Games - TheGamer](https://www.thegamer.com/video-game-morality-reputation-meters-karma-choices/)
- [Karma Meter - TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/KarmaMeter)

### Types of Alignment Systems

**1. Point-Based (Numerical)**
- Fallout 3: Karma meter shifts based on good/evil actions
- Neverwinter Nights: 0-30 chaotic, 31-69 neutral, 70-100 lawful
- Metro Series: Positive/negative moral points affect story outcomes
- **Our Implementation**: -100 (Algorithmic) to +100 (Authentic)

**2. Dual-Track Systems**
- Mass Effect: Separate Paragon and Renegade tracks (not sliding scale)
- Allows nuanced character development
- Not mutually exclusive

**3. Faction-Based**
- Skyrim: Multiple reputation meters per faction
- Tyranny: Reputation with each faction independently

### Implementation Patterns

**Common Features:**
1. **Action-Based Shifts**: Player choices modify alignment
   - Help NPC: +alignment
   - Use exploits: -alignment
   - Creative solutions: +alignment
   - Brute force: -alignment

2. **Gameplay Effects**: Alignment affects mechanics
   - Combat effectiveness vs opposite alignment
   - NPC dialogue options
   - Loot table variations
   - Quest availability

3. **Visual Feedback**: Player sees alignment status
   - UI elements (meters, color shifts)
   - Particle effects
   - Character appearance changes

4. **Threshold System**: Key breakpoints trigger changes
   - -100 to -50: Strong Algorithmic
   - -50 to +50: Neutral
   - +50 to +100: Strong Authentic

## Integration with Existing Systems

### S04 Combat System Integration
From `src/systems/s04-combat/combatant.gd`:
- Combatant has base stats: attack, defense, special_attack, special_defense
- Signals: damage_dealt, damage_taken
- Combat states: IDLE, READY, ATTACKING, DODGING, BLOCKING

**Integration Approach:**
- Add alignment-based damage modifiers in combat calculations
- +20% damage vs opposite alignment type
- Query ResonanceAlignment autoload for current alignment
- Apply modifier in damage calculation

### S11 Enemy AI Integration
From `src/systems/s11-enemyai/enemy_base.gd`:
- Enemy types: AGGRESSIVE, DEFENSIVE, RANGED, SWARM
- AI states: PATROL, CHASE, ATTACK, RETREAT
- Behavior tree integration with LimboAI

**Integration Approach:**
- Assign alignment type to enemy behaviors
  - AGGRESSIVE → Algorithmic alignment
  - DEFENSIVE → Authentic alignment
  - RANGED → Algorithmic alignment
  - SWARM → Mixed alignment
- AI behavior can react to player alignment
- Telegraph patterns differ based on alignment match

### S12 Monster Database Integration
From `res/resources/monster_resource.gd`:
- Monsters have types (fire, water, grass, etc.)
- AI behavior type stored per monster
- Loot tables defined per monster

**Integration Approach:**
- Add alignment field to monster data
- Loot tables vary based on player alignment
  - Authentic alignment: Organic items (wood, herbs, flowers)
  - Algorithmic alignment: Digital items (circuits, code fragments, data shards)
- Combat effectiveness modifier based on alignment mismatch

## GDScript 4.5 Best Practices

### Critical Syntax Rules
1. **Type Hints Required**: All variables and functions must have type hints
   ```gdscript
   var alignment: float = 0.0
   func shift_alignment(amount: float, reason: String) -> void:
   ```

2. **Signals with Typed Parameters**:
   ```gdscript
   signal alignment_changed(new_alignment: float, reason: String)
   ```

3. **No String Repetition with `*` operator**:
   ❌ `"═" * 60`
   ✅ `"═".repeat(60)`

4. **Class Name Declaration**:
   ```gdscript
   class_name ResonanceAlignment
   ```

5. **Signal Emission**:
   ```gdscript
   alignment_changed.emit(alignment, reason)
   ```

## Implementation Plan

### File Structure
```
src/systems/s21-resonance-alignment/
  ├── resonance_alignment.gd  (Autoload singleton)
  └── alignment_data.gd       (Optional: Data structure)

data/
  └── alignment_config.json    (Configuration data)
```

### Key Components

**1. Alignment Manager (resonance_alignment.gd)**
- Extends Node (required for autoload)
- Tracks alignment value (-100 to +100)
- Provides shift_alignment() method
- Emits alignment_changed signal
- Calculates combat effectiveness modifiers
- Determines visual theme (organic vs digital)
- Loads configuration from JSON

**2. Configuration Data (alignment_config.json)**
- Action shift values
- Threshold definitions
- Combat modifier formulas
- Visual theme mappings
- NPC reaction rules

**3. Public API**
```gdscript
# Get current alignment
ResonanceAlignment.get_alignment() -> float

# Shift alignment
ResonanceAlignment.shift_alignment(amount: float, reason: String) -> void

# Get alignment type string
ResonanceAlignment.get_alignment_type() -> String  # "authentic", "neutral", "algorithmic"

# Get combat modifier
ResonanceAlignment.get_combat_modifier(enemy_alignment: String) -> float

# Get visual theme
ResonanceAlignment.get_visual_theme() -> Dictionary

# Listen to changes
ResonanceAlignment.alignment_changed.connect(_on_alignment_changed)
```

## Known Gotchas

1. **Autoload Registration**: Must be registered in project.godot
2. **Save/Load Integration**: Alignment must persist between sessions (integrate with S06)
3. **Performance**: Avoid recalculating modifiers every frame; cache when possible
4. **Balance**: +20% combat bonus can be significant; may need playtesting adjustment
5. **Visual Feedback**: Need placeholder assets for testing (per ASSET-PIPELINE.md)

## Dependencies

**Depends On:**
- S04 Combat: Combat effectiveness modifiers
- S11 Enemy AI: Enemy alignment types
- S12 Monsters: Monster alignment data

**Integration Points:**
- S22 NPC System: NPCs react to alignment
- S23 Story System: Story branches based on alignment
- S06 Save/Load: Persist alignment between sessions
- S13 Vibe Bar: Could visualize alignment shift

## Next Steps

1. Create `resonance_alignment.gd` with complete implementation
2. Create `alignment_config.json` with all configuration
3. Document integration points in HANDOFF-S21.md
4. Tier 2 will test in Godot editor and integrate with dependent systems

## Reusable Patterns

**Pattern: Autoload State Manager**
```gdscript
extends Node
class_name GlobalStateManager

var state_value: float = 0.0
signal state_changed(new_value: float, context: String)

func modify_state(amount: float, context: String) -> void:
    state_value = clamp(state_value + amount, min_value, max_value)
    state_changed.emit(state_value, context)
```

This pattern can be reused for:
- Reputation systems per faction
- Sanity meters
- Relationship trackers
- World state variables

## References

- Godot 4.5 Official Documentation
- Game Mechanic Alignment Theory (ACM 2021)
- Fallout 3, Mass Effect, Metro series for inspiration
- D&D alignment system as historical reference
