# System S11 (Enemy AI) - Tier 1 Checkpoint

**Status:** ✅ Tier 1 Complete - Ready for MCP Agent (Tier 2)
**Created:** 2025-11-18
**System:** S11 - Enemy AI System
**Dependencies:** S04 (Combat/Combatant), S01 (Conductor), LimboAI plugin

---

## Files Created

### Core GDScript Files (13 files)

**Base Enemy Class:**
- ✅ `src/systems/s11-enemyai/enemy_base.gd` (584 lines)
  - Extends Combatant from S04
  - Integrates LimboAI BTPlayer
  - AI states: Patrol, Chase, Attack, Retreat, Stun
  - Telegraph system for rhythm-synced attack warnings
  - Fallback AI when LimboAI unavailable
  - Type-based behavior modifiers
  - Blackboard integration for behavior trees

**Type-Specific Enemy Classes:**
- ✅ `src/systems/s11-enemyai/enemy_aggressive.gd` (32 lines)
  - High damage, low retreat threshold (10% HP)
  - Fast chase speed (1.7x multiplier)
  - Extended attack range (80px)

- ✅ `src/systems/s11-enemyai/enemy_defensive.gd` (35 lines)
  - High retreat threshold (40% HP)
  - Increased defense stats (+5 DEF, +5 SP.DEF)
  - Slower movement (80 speed)

- ✅ `src/systems/s11-enemyai/enemy_ranged.gd` (32 lines)
  - Long attack range (150px)
  - Extended detection range (250px)
  - Medium movement speed (90)

- ✅ `src/systems/s11-enemyai/enemy_swarm.gd` (37 lines)
  - Reduced HP (70% multiplier)
  - Fast movement (120 speed)
  - Calls allies when damaged (300px range)
  - Smaller scale (0.8x)

**LimboAI Behavior Tree Tasks (8 files):**

*Conditions:*
- ✅ `src/systems/s11-enemyai/tasks/bt_check_player_detected.gd` - Check if player in detection range
- ✅ `src/systems/s11-enemyai/tasks/bt_check_in_attack_range.gd` - Check if in attack range
- ✅ `src/systems/s11-enemyai/tasks/bt_check_should_retreat.gd` - Check retreat threshold

*Actions:*
- ✅ `src/systems/s11-enemyai/tasks/bt_scan_for_player.gd` - Scan for player in range
- ✅ `src/systems/s11-enemyai/tasks/bt_patrol_move.gd` - Move to patrol waypoints
- ✅ `src/systems/s11-enemyai/tasks/bt_chase_player.gd` - Chase player with speed multiplier
- ✅ `src/systems/s11-enemyai/tasks/bt_attack_player.gd` - Attack with telegraph system
- ✅ `src/systems/s11-enemyai/tasks/bt_retreat.gd` - Retreat from player

### Data Files (1 file)

- ✅ `src/systems/s11-enemyai/enemy_ai_config.json` (58 lines)
  - Detection range: 200px
  - Attack range: 64px
  - Retreat threshold: 20% HP
  - Telegraph: 1 beat before attack
  - Difficulty modifiers (normal/hard/expert)
  - Enemy type configurations (aggressive/defensive/ranged/swarm)
  - Patrol, telegraph, and chase parameters

### Documentation Files (2 files)

- ✅ `HANDOFF-S11.md` (700+ lines)
  - Complete MCP agent instructions
  - LimboAI installation guide
  - Scene creation commands (GDAI)
  - Behavior tree structure specification
  - Testing checklist
  - Integration points with S04/S01
  - Troubleshooting guide

- ✅ `checkpoints/s11-enemyai-checkpoint.md` (this file)

---

## LimboAI Integration

### Behavior Tree Structure (To be created by MCP agent)

```
BTSelector (Root)
├── BTSequence (Retreat Branch - Priority 1)
│   ├── BTCheckShouldRetreat (Condition: HP < 20%)
│   └── BTRetreat (Action: Move away from target)
│
├── BTSequence (Attack Branch - Priority 2)
│   ├── BTCheckPlayerDetected (Condition: Player in range)
│   ├── BTCheckInAttackRange (Condition: Within attack range)
│   └── BTAttackPlayer (Action: Telegraph + Attack)
│
├── BTSequence (Chase Branch - Priority 3)
│   ├── BTCheckPlayerDetected (Condition: Player detected)
│   └── BTChasePlayer (Action: Move toward player)
│
└── BTSequence (Patrol Branch - Default Priority 4)
    ├── BTScanForPlayer (Action: Check for player)
    └── BTPatrolMove (Action: Wander patrol points)
```

### Blackboard Variables

| Variable | Type | Description |
|----------|------|-------------|
| `enemy` | Node | Reference to enemy instance |
| `target` | Node | Current target (player) |
| `detection_range` | Float | Player detection radius (200px) |
| `attack_range` | Float | Attack execution radius (64px) |
| `retreat_hp_threshold` | Float | HP % to trigger retreat (0.2) |
| `current_state` | String | Current AI state name |
| `patrol_target` | Vector2 | Current patrol waypoint |
| `spawn_position` | Vector2 | Original spawn location |
| `is_telegraphing` | Bool | Is attack telegraph active |
| `can_attack` | Bool | Can execute attacks |
| `time_since_target_seen` | Float | Time since last saw target |

---

## Telegraph System

### Visual Telegraph
- Red flash sprite overlay on enemy
- Pulsates at 10 Hz frequency
- Opacity: 0.0 to 0.7 (70% max)
- Color: #FF0000 (red)
- Duration: 1 beat (calculated from Conductor BPM)

### Telegraph Timing
- Duration in beats: 1 (configurable in config.json)
- Calculated duration: `60.0 / BPM * beats`
- Example at 120 BPM: 0.5 seconds
- Syncs with Conductor signals from S01

### Telegraph Execution Flow
1. Enemy enters attack range
2. `start_attack_telegraph()` called
3. TelegraphFlash sprite becomes visible
4. Flash pulsates with red color
5. Timer counts down (1 beat duration)
6. Attack executes when timer expires
7. Flash becomes invisible
8. Enemy returns to appropriate state

---

## AI States

### Patrol (Default State)
- Wander within patrol radius (150px from spawn)
- Pick random waypoints every 3 seconds
- Scan for player continuously
- Transition: Player detected → Chase

### Chase
- Follow player at chase_speed_multiplier (1.5x base speed)
- Track last known position
- Give up after 3 seconds without line of sight
- Transition: In attack range → Attack
- Transition: Lost player → Patrol

### Attack
- Stop movement (face target)
- Start telegraph (1 beat warning)
- Execute attack after telegraph
- Apply accuracy modifier (difficulty-based)
- Transition: HP low → Retreat
- Transition: Out of range → Chase

### Retreat
- Move away from target at retreat_speed (1.3x base speed)
- Activate when HP < threshold (20% default)
- Continue until HP recovers above threshold + 10%
- Transition: HP recovered → Chase
- Transition: No target → Patrol

### Stun
- Immobile, cannot act
- Triggered by "stun" status effect from S04
- Duration controlled by status effect system
- Transition: Stun expires → Previous State

---

## Enemy Types

### Aggressive
- **Behavior:** Always chase, rarely retreat
- **Retreat Threshold:** 10% HP
- **Chase Speed:** 1.7x
- **Attack Range:** 80px
- **Attack Power:** 80 (high damage)
- **Visual:** Red tint (Color(1, 0.5, 0.5))

### Defensive
- **Behavior:** Cautious, retreat early
- **Retreat Threshold:** 40% HP
- **Defense Bonus:** +5 DEF, +5 SP.DEF
- **Move Speed:** 80 (slower)
- **Attack Power:** 50 (medium damage)
- **Visual:** Blue tint (Color(0.5, 0.5, 1))

### Ranged
- **Behavior:** Keep distance, long-range attacks
- **Attack Range:** 150px (long)
- **Detection Range:** 250px (very long)
- **Move Speed:** 90
- **Attack Power:** 60 (medium damage)
- **Visual:** Green tint (Color(0.5, 1, 0.5))
- **Note:** Projectile attacks will be added in future system

### Swarm
- **Behavior:** Fast, weak, call allies
- **HP Multiplier:** 0.7x (lower HP)
- **Move Speed:** 120 (very fast)
- **Chase Speed:** 1.6x
- **Attack Power:** 40 (low damage)
- **Ally Call Range:** 300px
- **Visual:** Yellow tint (Color(1, 1, 0.5)), smaller scale (0.8x)

---

## Difficulty Scaling

| Difficulty | Reaction Time | Accuracy | Description |
|------------|---------------|----------|-------------|
| Normal | 0.5s | 70% | Casual players, forgiving timing |
| Hard | 0.3s | 90% | Experienced players, precise timing |
| Expert | 0.1s | 100% | Challenge mode, perfect precision |

### How Difficulty Affects Gameplay
- **Reaction Time:** Delay before enemy responds to player actions
- **Accuracy:** Chance for attack to hit (miss chance = 1 - accuracy)
- **Telegraph:** Same duration for all difficulties (maintains rhythm fairness)

---

## Integration Points

### S04 (Combat System) ✅
- **Inheritance:** EnemyBase extends Combatant
- **Combat Methods:** `attack_target()`, `take_damage()`, `heal()`
- **Status Effects:** Stun state triggered by "stun" effect
- **Stats System:** All 6 core stats (HP, ATK, DEF, SP.ATK, SP.DEF, Speed)
- **Damage Formula:** Complete formula with timing multipliers
- **Signals:** `damage_taken`, `damage_dealt`, `defeated`, `health_changed`

### S01 (Conductor/Rhythm System) ✅
- **Telegraph Timing:** Duration calculated from BPM and beats
- **Beat Sync:** Attack execution can sync with beat signals
- **Timing Quality:** Can use `get_timing_quality()` for attack evaluation
- **Signal Integration:** Can connect to `beat`, `downbeat`, `measure_complete`

### S12 (Monster Database) - Future
- **Enemy Stats:** Will load from monster database
- **Type Assignment:** Monster entries will specify behavior type
- **Spawning:** Monsters instantiated with database stats
- **Variations:** Individual monsters can override base stats

---

## GDScript 4.5 Syntax Validation ✅

### Validation Checklist

- ✅ **No string * number operations** - All string repetition uses `.repeat()`
- ✅ **All classes have class_name** - 13/13 files have unique class_name
- ✅ **Function type hints** - All public functions have parameter and return types
- ✅ **Explicit types** - No Variant inference issues
- ✅ **Proper extends** - All classes extend correct base classes
- ✅ **No autoload conflicts** - Class names don't conflict with singletons

### Verified Files (13 total)
1. ✅ enemy_base.gd - class_name EnemyBase
2. ✅ enemy_aggressive.gd - class_name EnemyAggressive
3. ✅ enemy_defensive.gd - class_name EnemyDefensive
4. ✅ enemy_ranged.gd - class_name EnemyRanged
5. ✅ enemy_swarm.gd - class_name EnemySwarm
6. ✅ bt_check_player_detected.gd - class_name BTCheckPlayerDetected
7. ✅ bt_check_in_attack_range.gd - class_name BTCheckInAttackRange
8. ✅ bt_check_should_retreat.gd - class_name BTCheckShouldRetreat
9. ✅ bt_scan_for_player.gd - class_name BTScanForPlayer
10. ✅ bt_patrol_move.gd - class_name BTPatrolMove
11. ✅ bt_chase_player.gd - class_name BTChasePlayer
12. ✅ bt_attack_player.gd - class_name BTAttackPlayer
13. ✅ bt_retreat.gd - class_name BTRetreat

---

## Fallback AI System

If LimboAI is not available, the enemy_base.gd includes a complete fallback state machine:

- `_fallback_ai_behavior(delta)` - Main fallback loop
- `_fallback_patrol_behavior(delta)` - Patrol logic
- `_fallback_chase_behavior(delta)` - Chase logic
- `_fallback_attack_behavior(delta)` - Attack logic
- `_fallback_retreat_behavior(delta)` - Retreat logic

This ensures enemies function even without the plugin, making development and testing easier.

---

## Testing Strategy (MCP Agent)

### Phase 1: Plugin Verification
1. Install LimboAI from Asset Library
2. Enable in Project Settings
3. Verify BTPlayer node available
4. Check for any installation errors

### Phase 2: Scene Creation
1. Create enemy_base.tscn with all nodes
2. Configure detection zones (200px)
3. Configure attack zones (64px)
4. Add BTPlayer node
5. Add telegraph flash sprite

### Phase 3: Behavior Tree Setup
1. Create BehaviorTree resource in BTPlayer
2. Build tree structure (Selector > Sequences > Tasks)
3. Attach custom task scripts
4. Configure blackboard variables
5. Test tree execution in debugger

### Phase 4: Enemy Type Scenes
1. Create inherited scenes for each type
2. Attach type-specific scripts
3. Customize appearance (color tints)
4. Verify type-specific stats applied

### Phase 5: Test Scene
1. Create test_enemy_ai.tscn
2. Add player with simple controls
3. Add 5 enemies (1 of each type + extra swarm)
4. Add UI for state display
5. Add difficulty selector buttons
6. Test all states and transitions

### Phase 6: Integration Testing
1. Verify combat integration (damage, HP)
2. Test telegraph timing with Conductor
3. Test status effects (stun state)
4. Verify difficulty scaling
5. Test enemy type behaviors
6. Check for console errors

---

## Performance Considerations

### Optimizations Implemented
- Blackboard updates only on relevant changes
- Fallback timer uses single Timer node
- Detection checks use built-in Area2D nodes (efficient)
- State changes emit signals (observers can optimize)
- Patrol uses simple random waypoints (no complex pathfinding)

### Expected Performance
- **5 enemies:** Negligible impact on performance
- **20 enemies:** Still performant on modern hardware
- **50+ enemies:** May need optimization (object pooling, LOD states)

### Future Optimizations (Not in S11 Scope)
- Object pooling for enemy instances
- LOD behavior trees (simplified at distance)
- Spatial partitioning for detection
- Async pathfinding

---

## Known Issues & Limitations

### Current Limitations
1. **No Projectile System:** Ranged enemies use same attack as melee (future system needed)
2. **Simple Patrol:** Random wandering only (no waypoint paths or nav mesh)
3. **Placeholder Art:** Using colored Sprite2D nodes instead of actual sprites
4. **No Audio:** Telegraph audio cues mentioned in config but not implemented
5. **No Formation AI:** Swarm enemies don't use formations (just call allies)

### Future Work (Not Blocking S11 Completion)
- Projectile system integration (S13 or later)
- Advanced pathfinding with NavigationServer2D
- Audio system integration for telegraph sounds
- Formation behavior for swarm types
- Boss-specific behavior trees
- Dynamic difficulty adjustment based on player performance

---

## Next Steps (MCP Agent - Tier 2)

1. **Read HANDOFF-S11.md** - Complete instructions for scene setup
2. **Install LimboAI plugin** - From Asset Library or GitHub
3. **Execute GDAI commands** - Create scenes, nodes, behavior trees
4. **Test in Godot editor** - Run test scene, verify all states
5. **Document results** - Update COORDINATION-DASHBOARD.md
6. **Create knowledge base entry** - If any non-trivial issues solved

---

## Success Criteria Validation

### Tier 1 (Claude Code Web) - COMPLETE ✅

- ✅ enemy_base.gd complete with behavior tree integration
- ✅ All behavior tree task scripts complete (8 tasks)
- ✅ enemy_ai_config.json complete with AI parameters
- ✅ Type-specific enemy classes complete (4 types)
- ✅ HANDOFF-S11.md provides clear MCP agent instructions
- ✅ Telegraph system implemented
- ✅ Integration patterns documented for S04/S01
- ✅ GDScript 4.5 syntax validated
- ✅ All files follow project structure conventions
- ✅ Fallback AI implemented for LimboAI unavailable case

### Tier 2 (MCP Agent) - PENDING

- ⏳ LimboAI plugin installed and configured
- ⏳ Enemy scenes configured correctly in Godot editor
- ⏳ Behavior tree executes all states correctly
- ⏳ Telegraph system warns before attacks
- ⏳ Type-based behaviors work correctly
- ⏳ Difficulty scaling works
- ⏳ All verification criteria pass
- ⏳ System ready for Monster Database (S12)

---

## System Status

**Tier 1 Status:** ✅ COMPLETE
**Tier 2 Status:** ⏳ PENDING (Waiting for MCP agent)
**Overall Status:** 🟡 IN PROGRESS (50% complete)

**Ready for:** MCP Agent handoff
**Blocks:** S12 (Monster Database)
**Unblocks After Tier 2:** S12, S17 (Enemy Spawning)

---

**Checkpoint Created:** 2025-11-18
**Verified By:** Claude Code Web (Tier 1)
**Next Action:** Execute HANDOFF-S11.md with MCP agent
