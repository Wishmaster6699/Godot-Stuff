# Rhythm RPG - Complete Combat Specification

**Version:** 1.0
**Date:** 2025-11-18
**Status:** 🔒 Locked - Ready for Implementation
**Project:** Vibe Code Rhythm RPG (Godot 4.5.1)

---

## Table of Contents

1. [Combat Overview](#1-combat-overview)
2. [Combat Mode Types](#2-combat-mode-types)
   - [Real-Time 1v1 Mode](#real-time-1v1-mode)
   - [Turn-Based 6v6 Mode](#turn-based-6v6-mode)
3. [Mode Selection](#3-mode-selection)
4. [Party System Mechanics](#4-party-system-mechanics)
5. [Rhythm Integration](#5-rhythm-integration)
6. [Stats & Damage Calculation](#6-stats--damage-calculation)
7. [Health & Status Systems](#7-health--status-systems)
8. [Victory & Loss Conditions](#8-victory--loss-conditions)
9. [Combat State Management](#9-combat-state-management)
10. [AI Behavior (Enemy)](#10-ai-behavior-enemy)
11. [Combat UI Requirements](#11-combat-ui-requirements)
12. [Combat Rewards](#12-combat-rewards)
13. [Balancing Considerations](#13-balancing-considerations)
14. [Integration Points](#14-integration-points)

**Appendices:**
- [Appendix A: Quick Reference Tables](#appendix-a-quick-reference-tables)
- [Appendix B: Design Decisions Log](#appendix-b-design-decisions-log)
- [Appendix C: State Machine Diagrams](#appendix-c-state-machine-diagrams)

---

## 1. Combat Overview

### Design Philosophy

**Core Principle:** Rhythm enhances combat, but does not gatekeep success.

The Rhythm RPG combat system is designed around three pillars:

1. **Skill Expression** - Player timing and tactical decisions matter more than raw stats
2. **Visual Impact** - Every action feels satisfying with beat-synced effects and feedback
3. **Accessibility** - Non-rhythm players can succeed; rhythm mastery provides competitive advantage

**Authentic Rhythm Combat:**
- All combat actions can sync to the music's beat (120 BPM baseline)
- Perfect timing rewards bonus damage/effects (not required for basic success)
- Beat visualization helps players find the rhythm naturally
- Music dynamically responds to combat intensity

**Blended Inspirations:**
- **Crypt of the NecroDancer** - Actions on-beat execute first, rhythm priority system
- **Pokemon** - Turn-based party battles, type effectiveness, stat-based calculations
- **Zelda** - Real-time action combat, dodge/block mechanics, skill-based gameplay
- **Lufia 2** - Strategic party management, puzzle-like boss encounters

### How Combat Fits Into The Game

**Frequency:** Moderate - Combat is important but not overwhelming
**Placement:** Overworld encounters, dungeon battles, scripted boss fights
**Avoidability:** Players can avoid some encounters; story battles are mandatory
**Integration:** Combat XP and Knowledge XP both contribute to progression (S19)

### Player Experience Goals

**Feel:**
- ⚡ Responsive - Input lag < 50ms, actions execute instantly on-beat
- 💥 Impactful - Screen shake, particle effects, satisfying audio feedback
- 🎵 Musical - Combat flows like a rhythm game performance
- 🎯 Fair - Clear telegraphs, learnable patterns, no cheap deaths

**Difficulty:**
- Early game: Forgiving timing windows (±150ms), simple patterns
- Mid game: Tighter windows (±100ms), multi-step combos
- Late game: Precision required (±75ms), complex boss mechanics
- **Adaptive Difficulty:** Players who struggle get subtle assists (wider windows)

**Progression:**
- Combat mechanics unlock gradually (dodge → block → special moves)
- Enemy patterns increase in complexity
- Player mastery curve: Learn rhythm → Master timing → Optimize strategy

---

## 2. Combat Mode Types

Players choose between two distinct combat modes, each balanced for different playstyles.

### Real-Time 1v1 Mode

**Core Concept:** Fast-paced action combat with rhythm-enhanced attacks

#### Trigger Conditions

- **Overworld Encounters:** When player contacts enemy in exploration
- **Random Encounters:** (If enabled) Trigger after X steps in dungeon
- **Boss Battles:** Specific story encounters
- **Duel Challenges:** Optional NPC challenges

#### Participants

- **Player Character** - Controlled directly by player
- **Monster Companion** - 1 selected monster fights alongside player (AI-controlled or semi-controllable)
- **Enemy** - 1 enemy monster or boss

**Formation:**
```
    [Enemy]

[Player]  [Companion]
```

#### Controls

| Action | Input | Rhythm Requirement |
|--------|-------|-------------------|
| **Move** | WASD / Left Stick | None (continuous) |
| **Basic Attack** | J / A Button | Bonus if on-beat |
| **Heavy Attack** | K / B Button | Must be on-beat |
| **Dodge Roll** | L / X Button | Timing window applies |
| **Block** | Hold Shift / LB | Active frames on-beat |
| **Special Move** | U / Y Button | Must be on downbeat |
| **Use Item** | I / D-Pad | No rhythm requirement |
| **Use Tool** | O / RB | Depends on tool |
| **Switch Companion** | Tab / Select | No rhythm (has cooldown) |

#### Duration

**Expected Combat Length:** 30-90 seconds
- **Trash Mobs:** 20-40 seconds
- **Elite Enemies:** 45-75 seconds
- **Mini-Bosses:** 60-120 seconds
- **Major Bosses:** 90-300 seconds (multi-phase)

#### Rhythm Requirements

**On-Beat Actions (Bonus Damage):**
- Basic Attack: 1.0x damage baseline, **1.25x on-beat, 1.5x on downbeat**
- Heavy Attack: **MUST be on-beat** (fails if off-beat), 2.0x damage on downbeat
- Dodge: I-frames extend from 200ms to 350ms if timed on-beat
- Block: 50% damage reduction baseline, 75% if timed on-beat, 100% if on downbeat

**Beat Compliance Bonus:**
- If player maintains >80% on-beat actions for 10 seconds: **"In The Zone"** buff
  - +10% damage
  - +5% movement speed
  - Visual effect: Character glows with rhythm aura
  - Duration: Until player misses 3 beats in a row

#### Camera

- **Type:** Dynamic follow camera
- **Zoom:** Medium (fits all combatants plus 10% buffer)
- **Movement:** Smoothly follows midpoint between player and enemy
- **Boss Battles:** May zoom out for larger enemies
- **Special Moves:** Quick zoom-in on impact, then zoom out

#### Arena

**Size:**
- Standard: 20m × 15m play area
- Boss arenas: 30m × 25m with potential obstacles

**Boundaries:**
- Soft boundaries: Invisible walls, visual indicator when near edge
- Players cannot be knocked out of bounds
- Environmental hazards create danger zones (lava, spikes, etc.)

**Environmental Hazards:**
- **Damage Zones:** 10 HP/second in lava, poison pools, etc.
- **Obstacles:** Pillars provide cover, can be destroyed
- **Interactive Elements:** Explosive barrels, switches, bounce pads

#### Victory Conditions

**Primary:** Enemy HP reaches 0

**Bonus Objectives (Affect Rewards):**
- ⭐ **Perfect Victory:** No damage taken by player or companion
- ⭐ **Rhythm Master:** 90%+ actions on-beat
- ⭐ **Speed Clear:** Defeat enemy in under 30 seconds
- ⭐ **Finisher:** Land final blow on downbeat (triggers special animation)

#### Loss Conditions

**Defeat occurs when:**
1. Player HP reaches 0 **AND** companion is already fainted
2. Player HP reaches 0 and no conscious companion available

**If only companion faints:**
- Player can continue fighting solo
- Option to flee becomes available
- Can summon another companion if cooldown expired (60s cooldown)

#### Flee Mechanics

**Conditions:**
- Available at any time (except scripted boss battles)
- Companion must be fainted OR player below 30% HP

**Success Rate:**
```
Flee Chance = 50% + (Player Speed - Enemy Speed) × 2%
Minimum: 20%
Maximum: 95%
```

**On Success:**
- Combat ends immediately
- Player teleported back 10 meters in overworld
- 15 second "Winded" debuff: -20% movement speed

**On Failure:**
- Enemy gets free attack
- Can attempt again next turn (chance decreases by 10% each attempt)

---

### Turn-Based 6v6 Mode

**Core Concept:** Strategic party battles with rhythm-enhanced damage

#### Trigger Conditions

- **Gym Leader Battles:** Story-required boss encounters
- **Tournament Matches:** Optional competitive battles
- **Large-Scale Encounters:** Special story events
- **Player Choice:** Can opt into turn-based for any encounter via mode toggle

#### Participants

- **Player Party:** Up to 6 monster companions
- **Enemy Party:** Up to 6 enemy monsters

**Only 1 monster per side is "active" at a time** (front-line fighter)

#### Turn Structure

**Type:** **Sequential with Speed-Based Turn Order** (Active Time Battle inspired)

**Turn Order Determination:**
1. At battle start, calculate initiative for all 12 monsters:
   ```
   Initiative = Speed Stat + Random(0, 10)
   ```
2. Sort by initiative (highest to lowest)
3. Monsters take turns in this order
4. After all monsters act, recalculate initiative for next round

**Why Sequential?**
- Allows for strategic counter-play (see enemy action, respond accordingly)
- Creates tension as player waits for their turn
- Enables combo opportunities (one monster sets up, another finishes)

#### Action Selection

**Player's Turn UI:**
```
┌────────────────────────────────┐
│ [Monster Portrait] HP: ████░░  │
│ Goblin Warrior                 │
│                                │
│ > ATTACK     SPECIAL MOVE      │
│   ITEM       SWITCH            │
│   BLOCK      FLEE              │
└────────────────────────────────┘
```

**Actions Available:**
1. **Attack** - Basic attack with weapon
2. **Special Move** - Costs MP/ability resource
3. **Item** - Use consumable from inventory
4. **Switch** - Swap active monster (uses turn)
5. **Block** - Reduce incoming damage until next turn
6. **Flee** - Attempt to escape (whole party)

**Time Limit:** 15 seconds to choose action (or auto-selects Attack)

#### Rhythm Requirements

**All Offensive Actions Have Rhythm Timing:**

When player selects Attack/Special Move:
1. Rhythm timing mini-game appears
2. Beat marker moves along track
3. Player presses button when marker hits zone
4. Timing quality determines damage multiplier

**Timing Windows:**
- **Perfect:** ±75ms from downbeat = **1.5x damage**
- **Good:** ±150ms from beat = **1.25x damage**
- **Okay:** ±250ms from beat = **1.0x damage**
- **Miss:** >250ms from beat = **0.75x damage**

**Defensive Actions:**
- Block: No rhythm requirement (set it and forget it)
- Item Use: No rhythm requirement
- Switch: No rhythm requirement

#### Duration

**Expected Combat Length:** 3-20 minutes
- **Standard Battles:** 3-8 minutes (weak enemies faint quickly)
- **Gym Leaders:** 8-15 minutes (strategic back-and-forth)
- **Championship:** 15-25 minutes (full 6v6 slugfest)

#### Switching Mechanics

**Free Switch Conditions:**
- When active monster faints (switch before opponent's next turn)
- After defeating opponent's active monster

**Turn-Using Switch:**
- Switching during active combat uses your turn
- Switched-in monster is vulnerable to incoming attack
- **Prediction Bonus:** If you switch and opponent uses super-effective move on previous monster, new monster takes 0.5x damage

**Benched Monsters:**
- Do NOT regenerate HP while benched
- Can use items on benched monsters (uses active monster's turn)
- Status effects continue ticking (burn/poison still damages)

#### Victory Conditions

**Primary:** All 6 enemy monsters fainted

**Bonus Objectives:**
- ⭐ **Clean Sweep:** Win without losing any monsters
- ⭐ **Rhythm Expert:** 80%+ Perfect/Good timings
- ⭐ **Strategic Victory:** Win with type advantage (all attacks super-effective)

#### Loss Conditions

**Defeat occurs when:** All 6 player monsters have fainted

**Partial Loss:**
- If 3+ monsters faint: Reduced XP/rewards
- If all monsters faint: Pay 10% of gold, return to last checkpoint

#### Flee Mechanics

**Conditions:**
- Only available if NOT a story battle/boss
- Can attempt on player's turn

**Success Rate:**
```
Flee Chance = 30% + (Average Party Speed - Average Enemy Speed) × 3%
Minimum: 10%
Maximum: 90%
```

**On Success:**
- Battle ends, no rewards
- Party returns to overworld

**On Failure:**
- Turn is wasted
- All enemy monsters get to act before player's next turn

---

## 3. Mode Selection

### How Players Choose Mode

**Pre-Battle Selection:**

When encounter triggers:
```
┌─────────────────────────────────────┐
│  ENCOUNTER: Wild Goblin Appears!    │
│                                     │
│  Choose Combat Mode:                │
│                                     │
│  > REAL-TIME (1v1)                  │
│    Fast action, skill-based         │
│                                     │
│    TURN-BASED (6v6)                 │
│    Strategic, party-focused         │
│                                     │
│  Press SELECT for default mode      │
└─────────────────────────────────────┘
```

**Default Mode Setting:**
- Players can set preferred default in Options menu
- Quick-start: Press A/Enter to use default immediately
- Manual select: Use D-Pad to choose, then confirm

### Changing Mid-Battle

**NOT ALLOWED** - Once combat starts, mode is locked for that battle.

**Reasoning:**
- Systems are too different to convert mid-fight
- Would require rebuilding entire combat state
- Creates commitment to strategic choice

### Mode-Locked Encounters

**Always Real-Time:**
- Duel challenges (1v1 honor battles)
- Specific boss encounters designed for action combat
- Tutorial battles

**Always Turn-Based:**
- Gym Leader battles
- Tournament finals
- Large-scale story battles (6v6)

**Player Choice:**
- Random encounters
- Most overworld enemies
- Optional dungeon fights

### Mode Selection UI

**HUD Indicator (Overworld):**
- Top-right corner shows current default mode icon
- Press SELECT to toggle default mode anytime
- Visual feedback confirms change

**Lock Icon:**
- When approaching mode-locked encounter, icon appears above enemy
- ⚡ = Real-time only
- 🎯 = Turn-based only

---

## 4. Party System Mechanics

### Real-Time Mode Party

**Active Composition:**
- **1 Player Character** (always present, directly controlled)
- **1 Monster Companion** (AI-controlled or semi-controllable)

**Pre-Battle Selection:**

Before entering encounter:
```
┌─────────────────────────────────┐
│  Select Companion:              │
│                                 │
│  1. [Goblin Warrior] HP: ████  │
│  2. [Fire Drake]     HP: ███░  │
│  3. [Thunder Wolf]   HP: █████ │
│  4. [Ice Golem]      HP: ██░░░ │
│                                 │
│  Current: Goblin Warrior        │
└─────────────────────────────────┘
```

**Companion AI:**
- **Aggressive:** Attacks on cooldown, prioritizes damage
- **Defensive:** Protects player, blocks incoming attacks
- **Balanced:** Mix of offense and defense
- **Follow:** Stays near player, attacks only when player does

**Semi-Controllable:**
- Press Tab to ping target (companion focuses that enemy)
- Press Tab + Direction to command position
- Companion still acts autonomously within strategy

**Switching During Battle:**
- Press SELECT + Monster # to switch
- **Cooldown:** 60 seconds after switch
- **Animation:** 2 second switch animation (both are vulnerable)
- **If Companion Faints:** Can immediately summon replacement (no cooldown)

**When Companion Faints:**
1. Companion HP reaches 0
2. Companion collapses, becomes inactive
3. Player continues fighting solo
4. "Summon Another Companion" prompt appears
5. Player can summon next companion (if available and cooldown ready)

**Cannot Summon Another If:**
- All monsters in party fainted
- Cooldown still active (60s)
- In scripted 1v1 duel

---

### Turn-Based Mode Party

**Active Composition:**
- **6 Monster Party** (chosen before battle)
- **1 Active Monster** at a time (front-line)
- **5 Benched Monsters** (waiting to switch in)

**Party Selection (Pre-Battle):**

```
┌──────────────────────────────────────┐
│  Select Your 6-Monster Party:        │
│                                      │
│  Active: [Goblin Warrior]   Lvl 12  │
│                                      │
│  Bench:                              │
│  2. [Fire Drake]            Lvl 10  │
│  3. [Thunder Wolf]          Lvl 11  │
│  4. [Ice Golem]             Lvl 9   │
│  5. [Shadow Cat]            Lvl 13  │
│  6. [Rock Titan]            Lvl 8   │
│                                      │
│  [Confirm]  [Change Order]          │
└──────────────────────────────────────┘
```

**Turn Order in Party:**
- Order matters for initiative tiebreakers
- Position 1 (Active) starts battle
- Player can rearrange order before battle

**Switching Mechanics:**

**Free Switch (No Turn Cost):**
- When active monster faints
- After defeating enemy's active monster
- On first turn of battle (before any actions)

**Turn-Using Switch:**
- Switch during active combat: Costs entire turn
- New monster appears, enemy gets to attack it
- Use strategically to counter enemy type

**Switch Animation:** 1 second (turn-based, not real-time)

**Benched Monsters:**

**Do NOT:**
- Regenerate HP
- Cure status effects
- Gain "rest" bonuses

**DO:**
- Continue ticking status effects (poison/burn damages even benched monsters)
- Can be targeted by items (player can heal benched monster using active's turn)
- Gain XP from battle if they participated

**Monster Order in UI:**

Battle UI shows all 6:
```
Active:  [████████░░] Goblin Warrior
Bench:   [███░░░░░░░] Fire Drake
         [██████████] Thunder Wolf
         [█████░░░░░] Ice Golem
         [████████░░] Shadow Cat
         [███░░░░░░░] Rock Titan
```

---

## 5. Rhythm Integration

### Conductor System Integration (S01)

**Beat Structure:**
- **BPM:** 120 (baseline, may vary per track)
- **Beat Interval:** 500ms
- **Downbeat:** Every 4th beat (measure)
- **Upbeat:** Beats 2 and 4 (syncopation)

**Signals from S01 Conductor:**
- `beat` - Fires every beat
- `downbeat` - Fires every measure
- `upbeat` - Fires on syncopated beats
- `measure_complete` - Fires at end of 4-beat measure

### Timing Windows (Precise Values)

**Real-Time Mode:**

| Quality | Window | Multiplier | Visual Feedback |
|---------|--------|------------|-----------------|
| **Perfect** | ±75ms from downbeat | 1.5x damage | Gold flash, "PERFECT!" |
| **Good** | ±100ms from beat | 1.25x damage | Blue flash, "Good!" |
| **Okay** | ±150ms from beat | 1.0x damage | No flash, damage number |
| **Miss** | >150ms from beat | 0.85x damage | Red "X", "Missed Beat" |

**Turn-Based Mode:**

| Quality | Window | Multiplier | Visual Feedback |
|---------|--------|------------|-----------------|
| **Perfect** | ±75ms from downbeat | 1.5x damage | Gold burst, "PERFECT!" |
| **Good** | ±150ms from beat | 1.25x damage | Blue glow, "Good!" |
| **Okay** | ±250ms from beat | 1.0x damage | Standard hit effect |
| **Miss** | >250ms from beat | 0.75x damage | Dull impact, "Weak" |

**Why Wider Windows for Turn-Based?**
- Turn-based is more strategic, less reflex-focused
- Easier to time when you control when to act
- Still rewards rhythm mastery with damage boost

### Action-Specific Rhythm Requirements

#### Normal Attack

**Real-Time:**
- No rhythm requirement (can spam)
- **Bonus:** 1.0x → 1.25x if on-beat → 1.5x if on downbeat
- **Miss:** 0.85x if very off-beat (>150ms)

**Turn-Based:**
- Rhythm mini-game appears after selecting Attack
- Must time button press to beat marker
- Damage multiplier based on timing quality (table above)

#### Heavy Attack (Real-Time Only)

**Requirements:**
- **MUST** be on-beat (within ±100ms) or attack fails
- If on downbeat: 2.0x damage multiplier
- If on regular beat: 1.5x damage multiplier
- If miss timing: Attack doesn't execute, animation cancels

**Cooldown:** 3 seconds

#### Special Moves

**Real-Time:**
- **MUST** be on downbeat or move fails
- Perfect timing (±75ms): Full power + bonus effect
- Good timing (±150ms): Reduced power (80%)
- Miss: Move fails, MP still consumed

**Turn-Based:**
- Same rhythm mini-game as Attack
- Perfect timing: +25% damage AND bonus effect (stun, burn, etc.)
- Good timing: Full damage, no bonus effect
- Okay/Miss: Reduced damage, no bonus

#### Dodge

**Real-Time:**
- **I-Frames (Invincibility Frames):**
  - Base: 200ms of invincibility
  - On-beat: 350ms of invincibility
  - Perfect (downbeat): 500ms + speed boost after

**Turn-Based:**
- Not applicable (use Block instead)

#### Block

**Real-Time:**
- **Hold** to block (consumes stamina while held)
- Damage reduction:
  - Baseline: 50%
  - On-beat: 75%
  - Perfect (downbeat): 100% (no damage)
- **Parry:** If block timed within ±50ms of enemy attack: Stagger enemy for 1 second

**Turn-Based:**
- Select "Block" action, blocks until next turn
- Flat 50% damage reduction
- No rhythm timing (set it and forget it)

#### Item Use

**No rhythm requirement** in either mode
- Items execute immediately
- No bonus for timing
- Accessibility: Non-rhythm players can always use items effectively

#### Movement (Real-Time Only)

**Not affected by rhythm**
- Players can move freely at all times
- Continuous WASD control
- No movement bonuses for rhythm (would be too restrictive)

---

## 6. Stats & Damage Calculation

### Base Stats System

**All Monsters and Player Have 6 Base Stats:**

| Stat | Abbreviation | Purpose |
|------|--------------|---------|
| **Health Points** | HP | Damage absorption before fainting |
| **Attack** | ATK | Physical damage output |
| **Defense** | DEF | Physical damage reduction |
| **Special Attack** | SP.ATK | Magical/special damage output |
| **Special Defense** | SP.DEF | Magical/special damage reduction |
| **Speed** | SPD | Turn order, flee chance, dodge bonus |

**Stat Ranges (Level 1):**
- HP: 30-50
- ATK: 8-15
- DEF: 5-12
- SP.ATK: 8-15
- SP.DEF: 5-12
- SPD: 6-14

**Stat Growth per Level:**
```
New Stat = Base Stat + (Growth Rate × Level)

Growth Rates:
- HP: +3 to +6 per level (varies by monster)
- ATK/DEF/SP.ATK/SP.DEF: +1 to +3 per level
- SPD: +0.5 to +2 per level
```

**Level 50 Example (High-Growth Monster):**
- HP: 280
- ATK: 98
- DEF: 87
- SP.ATK: 102
- SP.DEF: 85
- SPD: 95

---

### Complete Damage Formula

```gdscript
# Base damage calculation
var base_damage: float = (
    (((2.0 * attacker_level / 5.0) + 2.0) * attack_stat * move_power / defense_stat) / 50.0
) + 2.0

# Apply all multipliers
var final_damage: int = int(
    base_damage
    * weapon_modifier
    * timing_multiplier
    * type_effectiveness
    * critical_modifier
    * equipment_bonus
    * buff_modifier
    * random_factor
)

# Minimum damage
final_damage = max(final_damage, 1)
```

**Formula Breakdown:**

#### 1. Base Damage (Pokemon-Inspired)

```
Base = (((2 × Level / 5) + 2) × Attack × Move Power / Defense) / 50 + 2
```

**Variables:**
- `Level` = Attacker's level
- `Attack` = Attacker's ATK (or SP.ATK if special move)
- `Move Power` = Base power of attack (e.g., 40 for weak, 80 for strong, 120 for ultimate)
- `Defense` = Defender's DEF (or SP.DEF if special move)

**Example:**
```
Attacker: Level 10, ATK 25
Defender: DEF 15
Move Power: 60 (medium attack)

Base = (((2 × 10 / 5) + 2) × 25 × 60 / 15) / 50 + 2
Base = ((4 + 2) × 25 × 60 / 15) / 50 + 2
Base = (6 × 1500 / 15) / 50 + 2
Base = (9000 / 15) / 50 + 2
Base = 600 / 50 + 2
Base = 12 + 2 = 14 damage
```

#### 2. Weapon Modifier

**Equipped Weapon Adds:**
```
Weapon Modifier = 1.0 + (Weapon Bonus / 100)
```

**Example Weapons:**
- Wooden Sword: +10% → 1.10x
- Iron Sword: +25% → 1.25x
- Legendary Blade: +80% → 1.80x

#### 3. Timing Multiplier (Rhythm Bonus)

| Timing | Real-Time | Turn-Based |
|--------|-----------|------------|
| Perfect | 1.5x | 1.5x |
| Good | 1.25x | 1.25x |
| Okay | 1.0x | 1.0x |
| Miss | 0.85x | 0.75x |

#### 4. Type Effectiveness

```
Type Effectiveness = 2.0   (Super Effective)
                   = 1.5   (Effective)
                   = 1.0   (Neutral)
                   = 0.66  (Not Very Effective)
                   = 0.5   (Resisted)
```

**Type Chart (Simplified - Expand in S21 Resonance):**
- Fire > Nature > Water > Fire
- Lightning > Water
- Dark > Light > Dark

**Dual Typing:** Multipliers stack
```
Fire + Lightning attack vs Water + Nature enemy:
= 2.0 (Fire > Nature) × 2.0 (Lightning > Water) = 4.0x total
```

#### 5. Critical Hits

**Critical Chance:**
```
Base Crit Chance = 6.25% (1 in 16)
+ (Speed Stat / 512) × 100%
+ Equipment bonuses
+ Ability bonuses

Maximum: 50%
```

**Critical Multiplier:**
```
Critical Hit = 1.5x damage
Perfect Critical (on downbeat) = 2.0x damage
```

**Visual Feedback:**
- Screen flash
- Larger damage number
- "CRITICAL!" text
- Satisfying impact sound

#### 6. Equipment Bonuses

**Armor/Accessories Add Flat % Bonus:**
```
Equipment Bonus = 1.0 + (All Equipment Bonuses / 100)
```

**Example:**
- Strength Ring: +8% ATK → 1.08x
- Power Gloves: +12% ATK → 1.12x
- Total: 1.20x damage boost

#### 7. Buff/Debuff Modifier

**Stacking System:**
```
Each buff/debuff = ±10% per stack
Maximum: 5 stacks (±50%)
```

**Examples:**
- ATK Up ×2: 1.20x damage
- ATK Down ×3: 0.70x damage
- ATK Up ×2 + DEF Down ×2 on enemy: 1.20x × 1.20x = 1.44x total

**Duration:**
- Real-time: 15 seconds per stack
- Turn-based: 3 turns per stack

#### 8. Random Factor

```gdscript
var random_factor: float = randf_range(0.85, 1.0)
```

**Why Random?**
- Adds slight variance (prevents repetitive damage)
- Range: 85% to 100% of calculated damage
- Small enough to not feel unfair
- Large enough to create tension

---

### Example Damage Calculation

**Scenario:**
- Level 15 Goblin Warrior (ATK 42)
- Iron Sword equipped (+25%)
- Perfect timing on downbeat (1.5x)
- Critical hit (1.5x)
- Fire attack vs Nature enemy (2.0x)
- +1 ATK buff (1.10x)
- Enemy DEF 28
- Move Power: 60

**Step by Step:**
```
1. Base = (((2×15/5)+2) × 42 × 60 / 28) / 50 + 2
   Base = ((6+2) × 42 × 60 / 28) / 50 + 2
   Base = (8 × 2520 / 28) / 50 + 2
   Base = (20160 / 28) / 50 + 2
   Base = 720 / 50 + 2 = 14.4 + 2 = 16.4

2. Weapon: 16.4 × 1.25 = 20.5

3. Timing: 20.5 × 1.5 = 30.75

4. Type: 30.75 × 2.0 = 61.5

5. Critical: 61.5 × 1.5 = 92.25

6. Equipment: 92.25 × 1.0 = 92.25 (no equipment bonus)

7. Buff: 92.25 × 1.10 = 101.475

8. Random: 101.475 × 0.92 (example) = 93.36

Final: 93 damage
```

**Display:** Large gold "93 CRITICAL!" with screen shake

---

## 7. Health & Status Systems

### Health (HP) System

#### Max HP Calculation

```
Max HP = Base HP + (HP Growth × Level) + Equipment Bonus
```

**Example:**
- Base HP: 40
- HP Growth: 4 per level
- Level: 20
- Equipment: +15 HP

```
Max HP = 40 + (4 × 20) + 15 = 40 + 80 + 15 = 135 HP
```

#### HP Regeneration

**Out of Combat:**
- 10% Max HP per second (full heal in 10 seconds)
- Begins 5 seconds after combat ends
- Can be interrupted if another encounter starts

**During Combat:**
- No natural regeneration
- Only via items, abilities, or special effects

#### Fainting (0 HP)

**When Monster Reaches 0 HP:**
1. HP clamped to 0 (cannot go negative)
2. Monster plays faint animation (1.5 seconds)
3. Monster becomes inactive
4. In real-time: Falls to ground, becomes semi-transparent
5. In turn-based: Removed from active slot, bench order shifts

**Fainted Monsters:**
- Cannot act
- Do not take damage
- Do not regenerate
- Can be revived via items (Revive Potion restores 50% HP)

#### Revival

**During Combat:**
- Use Revive item (restores 50% Max HP)
- Use Full Revive item (restores 100% Max HP)
- Certain special moves can revive (rare)

**After Combat:**
- Automatic revival at 1 HP when battle ends
- Player can then use items/healing to restore fully

---

### Vibe Bar (Color-Shift Health) - S13 Integration

**Concept:** Visual HP representation that shifts color as health depletes

#### Color Thresholds

| HP Range | Color | Vibe State | Visual Effect |
|----------|-------|------------|---------------|
| 100-80% | 💚 Green | Energized | Bright, pulsing glow |
| 79-60% | 💛 Yellow | Confident | Steady glow |
| 59-40% | 🧡 Orange | Cautious | Flickering |
| 39-20% | 🔴 Red | Stressed | Rapid pulse |
| 19-1% | 💜 Purple | Critical | Erratic flashing |

#### Visual Representation

**HUD:**
```
╔══════════════════════════════╗
║ [████████████████████░░░░░] ║ 85% HP
║ 💚 Energized                 ║
╚══════════════════════════════╝
```

**Character Shader:**
- Character sprite tinted with Vibe color
- Intensity increases as HP decreases
- Critical state: Screen border pulses purple

#### Gameplay Integration

**Vibe State Effects:**
- **Energized (Green):** +5% damage, high morale
- **Confident (Yellow):** Normal performance
- **Cautious (Orange):** -5% damage, defensive AI
- **Stressed (Red):** -10% damage, erratic AI
- **Critical (Purple):** Desperation bonus: +15% damage, +20% crit chance

---

### Status Effects System

**Duration Format:**
- Real-time: Seconds
- Turn-based: Turns

#### 1. Burn 🔥

**Effect:** Damage over time (fire damage)
- **Damage:** 5% Max HP per tick
- **Tick Rate:** Every 2 seconds (real-time) / Every turn (turn-based)
- **Duration:** 10 seconds / 3 turns
- **Application Chance:** 20% on fire-type moves
- **Cure:** Ice-type move, Antidote item, wait it out
- **Stacking:** Does NOT stack (resets duration)
- **Visual:** Orange flames around character

**Special Interaction:**
- Taking water damage cures burn immediately

#### 2. Freeze ❄️

**Effect:** Skip actions, reduced defense
- **Action Lock:** Cannot act for duration
- **Defense Penalty:** -30% DEF
- **Duration:** 4 seconds / 1 turn
- **Application Chance:** 15% on ice-type moves
- **Cure:** Fire-type move, warm item, time
- **Stacking:** Does NOT stack (resets duration)
- **Visual:** Encased in ice block

**Break Early:**
- Taking fire damage: 100% break chance
- Taking physical damage: 30% break chance per hit

#### 3. Poison ☠️

**Effect:** Increasing damage over time
- **Damage:** 3% Max HP first tick, +2% each subsequent tick (3%, 5%, 7%, 9%...)
- **Tick Rate:** Every 2 seconds / Every turn
- **Duration:** Until cured or combat ends
- **Application Chance:** 25% on poison-type moves
- **Cure:** Antidote item, certain abilities
- **Stacking:** Resets damage ramp (back to 3%)
- **Visual:** Purple bubbles, sickly green tint

**Difference from Burn:**
- Poison ramps up (more dangerous over time)
- Burn is consistent damage
- Poison persists after combat (continues in overworld until cured)

#### 4. Paralysis ⚡

**Effect:** Chance to fail action, reduced speed
- **Action Fail:** 25% chance each action
- **Speed Penalty:** -50% SPD
- **Duration:** 12 seconds / 4 turns
- **Application Chance:** 20% on electric moves
- **Cure:** Paralyze Heal item, certain abilities, time
- **Stacking:** Does NOT stack (resets duration)
- **Visual:** Yellow sparks, jittery animation

**Failed Action:**
- Animation starts, then stutters
- No damage dealt
- Turn/action wasted

#### 5. Sleep 💤

**Effect:** Cannot act, high vulnerability
- **Action Lock:** Cannot act for duration
- **Damage Taken:** +50% damage from all sources
- **Duration:** 6 seconds / 2 turns
- **Application Chance:** 30% on sleep-inducing moves
- **Cure:** Taking any damage (instant wake), Awakening item
- **Stacking:** Does NOT stack (resets duration)
- **Visual:** "Zzz" particle, eyes closed, gentle snore sound

**Wake-Up Mechanics:**
- Any damage: 100% wake chance
- Loud noise (special moves): 75% wake chance
- Ally action: 25% wake chance

#### 6. Confusion 😵

**Effect:** Random action targeting
- **Self-Attack:** 33% chance to attack self
- **Wrong Target:** 33% chance to attack ally (if any)
- **Correct Action:** 34% chance to act normally
- **Damage (Self):** 50% of intended damage
- **Duration:** 8 seconds / 2-3 turns (random)
- **Application Chance:** 20% on psychic moves
- **Cure:** Confusion Cure item, time, taking damage (25% cure chance)
- **Stacking:** Does NOT stack (resets duration)
- **Visual:** Swirling stars above head, wobbly movement

**Turn Order:**
- Confused character still takes turn
- Target is randomized at action execution

---

### Status Effect Priority

**If Multiple Effects Apply Simultaneously:**

1. **Freeze** - Total action lock (highest priority)
2. **Sleep** - Total action lock (second)
3. **Confusion** - Partial action lock
4. **Paralysis** - Chance-based action lock
5. **Burn/Poison** - Damage over time (lowest priority, always applies)

**Rule:** Only ONE action-locking status can be active at a time.
**Multiple DoTs:** Burn AND Poison can both be active (stacks damage)

---

## 8. Victory & Loss Conditions

### Real-Time Mode

#### Victory

**Primary Condition:** Enemy HP reaches 0

**Downbeat Finisher Bonus:**
- If final blow lands on downbeat (±75ms):
  - ⭐ **Finisher animation** plays (slow-mo, dramatic impact)
  - +25% XP bonus
  - +15% item drop chance bonus
  - Special victory fanfare synced to music

**Visual Sequence:**
1. Enemy HP reaches 0
2. If downbeat finisher: Slow-motion effect for 0.5s
3. Enemy faint animation (1.5s)
4. Victory music stinger
5. XP/rewards appear (3s)
6. Return to overworld

#### Loss

**Condition 1:** Player HP reaches 0 AND companion fainted
**Condition 2:** Player HP reaches 0 AND no companion available

**Player Alone:**
- If companion faints first, player can continue solo
- Increased difficulty but still winnable
- Option to flee available

**Defeat Sequence:**
1. Player HP reaches 0
2. Player collapses animation (1s)
3. Screen fades to black
4. "Defeated" message
5. Penalty applied:
   - Lose 10% of carried gold
   - Respawn at last checkpoint/town
   - All monsters revived at 1 HP

#### Fleeing

**Availability:**
- Always available except:
  - Boss battles (story-required)
  - Duel challenges
  - Arena matches

**Success Rate:**
```gdscript
var flee_chance: float = 0.50 + ((player_speed - enemy_speed) / 100.0) * 2.0
flee_chance = clamp(flee_chance, 0.20, 0.95)
```

**Example:**
- Player SPD: 60
- Enemy SPD: 45
- Difference: +15

```
Chance = 50% + (15 / 100) × 2.0 = 50% + 0.30 = 80%
```

**Attempt Sequence:**
1. Press Flee button (Tab by default)
2. Confirmation prompt: "Attempt to flee?"
3. Roll random(0, 1) vs flee_chance
4. **On Success:**
   - Immediate combat end
   - Player teleported 10m back in overworld
   - "Winded" debuff for 15s (-20% movement speed)
   - No rewards
5. **On Failure:**
   - "Failed to escape!" message
   - Enemy gets free attack
   - Flee chance reduces by -10% for next attempt
   - Can retry

#### Rewards

**Base XP:**
```
XP = Enemy Base XP × Level Difference Modifier
```

**Level Difference Modifier:**
```
If Enemy Level > Player Level:
  Modifier = 1.0 + (Difference × 0.1)  // Max +50%

If Enemy Level < Player Level:
  Modifier = max(0.5, 1.0 - (Difference × 0.05))  // Min 50%
```

**Bonus Multipliers (Stack):**
- Perfect Victory (no damage taken): ×1.25
- Rhythm Master (90%+ on-beat): ×1.20
- Speed Clear (<30s): ×1.15
- Downbeat Finisher: ×1.25

**Example:**
- Base XP: 100
- Perfect Victory + Downbeat Finisher
- Total: 100 × 1.25 × 1.25 = 156 XP

**Item Drops:**
```
Base Drop Chance = 30%
+ Downbeat Finisher: +15%
+ Perfect Victory: +10%

Maximum: 75%
```

**Currency (Gold):**
```
Gold = Enemy Base Gold × (1.0 + Random(0, 0.3))
```

---

### Turn-Based Mode

#### Victory

**Primary Condition:** All 6 enemy monsters fainted

**Bonus Victory Conditions:**
- ⭐ Clean Sweep: No player monsters fainted (+30% XP)
- ⭐ Rhythm Expert: 80%+ perfect/good timings (+20% XP)
- ⭐ Type Advantage: Used super-effective moves exclusively (+15% XP)

**Visual Sequence:**
1. Last enemy monster faints
2. All enemy monsters disappear
3. Victory fanfare (4s)
4. XP distribution to participating monsters
5. Level-up animations (if applicable)
6. Item/gold rewards display
7. Return to overworld

#### Loss

**Condition:** All 6 player monsters fainted

**Defeat Sequence:**
1. Last player monster faints
2. "All monsters fainted!" message
3. Screen fade
4. Penalty:
   - Lose 10% gold
   - Return to last Pokemon Center/checkpoint
   - All monsters auto-revive at 1 HP

**No Game Over:**
- Player never truly loses (no permadeath)
- Just setback + retry

#### Fleeing

**Availability:**
- Non-boss battles only
- Gym Leaders: No flee
- Story battles: No flee
- Wild encounters: Flee allowed

**Success Rate:**
```gdscript
var avg_party_speed: float = party.get_average_speed()
var avg_enemy_speed: float = enemies.get_average_speed()

var flee_chance: float = 0.30 + ((avg_party_speed - avg_enemy_speed) / 100.0) * 3.0
flee_chance = clamp(flee_chance, 0.10, 0.90)
```

**Attempt:**
- Use "Flee" action on your turn
- Turn is consumed attempting
- **On Success:** Battle ends immediately
- **On Failure:** All enemies get turns before player's next action

#### Rewards

**XP Distribution:**
```
Total XP = Sum of All Enemy XP

Distribution:
- Monsters that participated (dealt damage or took damage): Full share
- Monsters that never entered battle: 0 XP

XP per Monster = Total XP / Number of Participants
```

**Example:**
- 6 enemies worth 600 total XP
- Only 4 monsters participated
- Each gets: 600 / 4 = 150 XP

**Dual XP System (S19):**
```
Total XP Split:
- 70% → Combat XP (levels up monsters)
- 30% → Knowledge XP (unlocks abilities, upgrades)
```

**Bonus Multipliers:**
- Clean Sweep: ×1.30
- Rhythm Expert: ×1.20
- Type Advantage: ×1.15

**Item Drops:**
```
Each Enemy has independent drop chance:
- Common Item: 40%
- Uncommon: 15%
- Rare: 5%

Total items = Sum of all drops
```

**Gold:**
```
Gold = Sum(Each Enemy Base Gold) × (1.0 + Random(0, 0.2))
```

---

## 9. Combat State Management

### Combat State Machine

**States:**
```
PRE_COMBAT
  ↓
MODE_SELECT
  ↓
PARTY_SELECT
  ↓
COMBAT_INITIALIZE
  ↓
COMBAT_ACTIVE ←→ PAUSED
  ↓
VICTORY / DEFEAT / FLED
  ↓
REWARDS
  ↓
EXIT_COMBAT
```

---

### State Descriptions

#### PRE_COMBAT

**Entry:** Encounter triggered
**Duration:** Instant
**Actions:**
- Detect encounter type
- Determine if mode-locked
- Load enemy data
- Stop overworld music

**Exit to:** MODE_SELECT

---

#### MODE_SELECT

**Entry:** If not mode-locked
**Duration:** Player choice (max 10s timeout)
**Actions:**
- Display mode selection UI
- Wait for player input
- Apply default if timeout

**Exit to:** PARTY_SELECT

---

#### PARTY_SELECT

**Entry:** Mode chosen
**Duration:** Player choice (max 30s timeout)
**Actions:**
- Real-time: Select 1 companion
- Turn-based: Arrange 6-monster party
- Display party UI
- Show monster stats/HP

**Exit to:** COMBAT_INITIALIZE

---

#### COMBAT_INITIALIZE

**Entry:** Party confirmed
**Duration:** 2-3 seconds
**Actions:**
- Load combat scene
- Position combatants
- Initialize health/stats
- Start combat music
- Display combat UI
- Real-time: Enable player controls
- Turn-based: Calculate initiative

**Exit to:** COMBAT_ACTIVE

---

#### COMBAT_ACTIVE

**Main Combat Loop**

**Real-Time:**
```gdscript
func _process(delta: float) -> void:
    process_player_input()
    update_companion_ai()
    update_enemy_ai()
    process_attacks()
    check_win_loss_conditions()
    update_status_effects()
    sync_to_conductor_beat()
```

**Turn-Based:**
```gdscript
func execute_turn() -> void:
    var current_actor = turn_order[turn_index]

    if current_actor.is_player_controlled():
        await display_action_menu()
        await get_player_input()
        await execute_action_with_rhythm()
    else:
        execute_enemy_ai_action()

    check_win_loss_conditions()
    advance_turn_order()
```

**Can Transition To:**
- PAUSED (player presses Start)
- VICTORY (win conditions met)
- DEFEAT (loss conditions met)
- FLED (successful flee)

---

#### PAUSED

**Entry:** Player presses Start/Pause
**Duration:** Until player resumes
**Actions:**
- Freeze all combat (timer stops)
- Display pause menu
- Options:
  - Resume
  - Items (use items from inventory)
  - Options (adjust settings)
  - Flee (attempt to flee)
  - Forfeit (auto-lose, emergency quit)

**Real-Time Only:**
- True pause (enemies stop acting)

**Turn-Based:**
- Can pause between turns
- Cannot pause during action execution

**Exit to:**
- COMBAT_ACTIVE (resume)
- FLED (if flee successful)
- DEFEAT (if forfeit)

---

#### VICTORY

**Entry:** Win conditions met
**Duration:** 5-8 seconds
**Actions:**
1. Stop combat music
2. Play victory fanfare
3. Display "Victory!" message
4. Show defeated enemies
5. Calculate bonuses
6. Play celebration animation

**Exit to:** REWARDS

---

#### DEFEAT

**Entry:** Loss conditions met
**Duration:** 3-4 seconds
**Actions:**
1. Stop combat music
2. Play defeat sound
3. Display "Defeated!" message
4. Fade to black
5. Calculate penalty (10% gold loss)
6. Queue respawn location

**Exit to:** EXIT_COMBAT (with defeat flag)

---

#### FLED

**Entry:** Successful flee
**Duration:** 1-2 seconds
**Actions:**
1. Play flee sound effect
2. Display "Got away safely!"
3. Fade out combat scene
4. Apply "Winded" debuff

**Exit to:** EXIT_COMBAT (with fled flag)

---

#### REWARDS

**Entry:** From VICTORY
**Duration:** Variable (player controlled)
**Actions:**
1. Display XP gained (animated counter)
2. Show level-ups (if any)
3. Display items obtained
4. Display gold earned
5. Show combat statistics
6. Wait for player confirmation

**UI:**
```
┌─────────────────────────────┐
│ ★ VICTORY! ★                │
│                             │
│ XP Gained: 156 (+25% bonus) │
│                             │
│ Goblin Warrior: Lv 12 → 13! │
│ Fire Drake: +89 XP           │
│                             │
│ Items: Rusty Sword ×1       │
│ Gold: 45G                   │
│                             │
│ [Press A to Continue]       │
└─────────────────────────────┘
```

**Exit to:** EXIT_COMBAT

---

#### EXIT_COMBAT

**Entry:** From REWARDS, DEFEAT, or FLED
**Duration:** 1-2 seconds
**Actions:**
1. Save combat results
2. Update player stats
3. Apply post-combat effects
4. Restore overworld music
5. Unload combat scene
6. Return to overworld

**If Defeated:**
- Teleport to checkpoint
- Revive all monsters at 1 HP
- Deduct gold penalty

**If Fled:**
- Place player 10m away from encounter
- Apply "Winded" debuff

**If Victory:**
- Place player at encounter location
- Start HP regeneration

**Exit to:** [Overworld]

---

## 10. AI Behavior (Enemy)

**Note:** Full implementation details in S11 Enemy AI. This section provides high-level specification.

### Attack Patterns

**Pattern Types:**

1. **Random Aggro** (Early enemies)
   - Random attack selection
   - No strategy
   - 60% attack, 30% move, 10% defend

2. **Scripted Pattern** (Mid-game enemies)
   - Fixed rotation: Attack → Special → Attack → Defend
   - Predictable but requires learning

3. **Adaptive** (Late-game enemies)
   - Reads player behavior
   - Counters player strategy
   - Switches between aggressive/defensive based on HP

4. **Boss Phases** (Major bosses)
   - Phase 1 (100-70% HP): Aggressive, simple attacks
   - Phase 2 (69-40% HP): Mixed, introduces special moves
   - Phase 3 (39-0% HP): Desperate, high-damage attacks, complex patterns

### Difficulty Scaling

**Difficulty Levels:**

| Difficulty | Reaction Time | Timing Accuracy | Strategy Depth |
|------------|---------------|-----------------|----------------|
| Easy | 500ms delay | 60% on-beat | Random attacks |
| Normal | 300ms delay | 75% on-beat | Basic patterns |
| Hard | 150ms delay | 90% on-beat | Adaptive tactics |
| Expert | 50ms delay | 95% on-beat | Optimal play |

**Smart AI:**
- Tracks player weaknesses (which defense is lowest?)
- Uses super-effective moves when available
- Switches monsters strategically (turn-based)
- Blocks when low HP
- Uses items intelligently

### Telegraph System

**Attack Warnings:**

**Wind-Up Time (Real-Time):**
- Basic attack: 0.3s wind-up (half a beat)
- Heavy attack: 0.6s wind-up (full beat)
- Special move: 1.0s wind-up (two beats)

**Visual Telegraphs:**
- Red flash on enemy
- Attack arc indicator (shows range/direction)
- Audio cue (sound effect pitched to beat)

**Turn-Based Telegraphs:**
- Enemy selects move (player sees icon)
- Player has full turn to react
- Advanced enemies may feint (show fake move)

### Special Move Usage

**AI Special Move Logic:**
```gdscript
func should_use_special() -> bool:
    if mp < special_cost:
        return false

    if player_hp_percent < 30:
        return true  # Go for kill

    if own_hp_percent < 40:
        return true  # Desperate move

    if type_advantage:
        return randf() < 0.6  # 60% chance if super effective

    return randf() < 0.15  # 15% baseline chance
```

**Boss Special Moves:**
- Triggered at HP thresholds (75%, 50%, 25%)
- Announces move before using ("charging ultimate attack!")
- Player has 2 beats to prepare (dodge/block)

### Rhythm Compliance

**Does AI Follow Rhythm?**

**YES** - AI actions sync to beat just like player

**Timing Accuracy:**
- Easy enemies: 60% on-beat (often miss)
- Normal enemies: 75% on-beat
- Hard enemies: 90% on-beat (rarely miss)
- Bosses: 95-100% on-beat (perfect rhythm)

**Why AI Uses Rhythm:**
- Creates predictable attack patterns (player can learn timing)
- Makes combat feel like a rhythm duel
- Rewards player for internalizing the beat
- Boss battles become rhythm boss fights

**Player Advantage:**
- Even on Expert, AI is not frame-perfect
- Player skill can outplay AI timing
- AI doesn't adapt to music changes as fast as player

---

## 11. Combat UI Requirements

### HUD Elements (Real-Time Mode)

```
╔════════════════════════════════════════════════════════════════╗
║ [Player HP]  ████████████░░░  85/100                          ║
║ [Companion]  ██████░░░░░░░░░  45/75                           ║
║                                                                ║
║                    ┌─────────────┐                             ║
║                    │   ENEMY     │                             ║
║                    │ ██████████  │ 50/50                       ║
║                    │ Goblin      │                             ║
║                    └─────────────┘                             ║
║                                                                ║
║                                                                ║
║ ♪ ♪ ♪ ♪ ♪ ♪ ♪ ♪  [Beat Indicator]                           ║
║       ↑ (Current Beat)                                        ║
║                                                                ║
║ [J] Attack  [K] Heavy  [L] Dodge  [Shift] Block              ║
╚════════════════════════════════════════════════════════════════╝
```

**Components:**

1. **Health Bars**
   - Player: Top-left, green → red gradient
   - Companion: Below player, blue → purple gradient
   - Enemy: Above enemy sprite, red bar with outline
   - HP numbers visible (current/max)
   - Vibe Bar color overlay (S13)

2. **Rhythm Indicator**
   - Bottom-center of screen
   - 8 beat markers (shows 2 measures ahead)
   - Current beat highlighted
   - Downbeats emphasized (larger icons)
   - Pulses with music

3. **Action Prompts**
   - Bottom of screen
   - Show current key bindings
   - Highlight available actions (greyed out if on cooldown)
   - Show cooldown timers

4. **Status Effect Icons**
   - Above character sprites
   - Max 3 icons visible (most recent/important)
   - Tooltip on hover (shows duration remaining)

5. **Damage Numbers**
   - Float up from hit location
   - Color-coded:
     - White: Normal damage
     - Gold: Critical hit
     - Blue: Perfect timing bonus
     - Red: Type super-effective
   - Size scales with damage

6. **Timing Feedback**
   - Center-screen, brief display (0.5s)
   - "PERFECT!" (gold, large)
   - "Good!" (blue, medium)
   - "Missed Beat" (red, small)

7. **Combo Counter**
   - Top-right corner
   - "x5 Combo!"
   - Resets when player takes damage or misses beat

---

### HUD Elements (Turn-Based Mode)

```
╔════════════════════════════════════════════════════════════════╗
║ YOUR PARTY                        ENEMY PARTY                  ║
║ 1. Goblin    ████████░░ 80%     1. Fire Drake  ██████░░░░ 60% ║
║ 2. Wolf      ██████████ 100%    2. Ice Golem   ████████░░ 80% ║
║ 3. Drake     ████░░░░░░ 40%     3. Thunder     ███░░░░░░░ 30% ║
║ 4. Golem     ██████░░░░ 60%     4. Shadow      ██████████ 100%║
║ 5. Thunder   ████████░░ 80%     5. Rock        ████░░░░░░ 40% ║
║ 6. Shadow    ██████████ 100%    6. Fire        ██████░░░░ 60% ║
║                                                                ║
║         [Goblin Warrior - Your Turn]                           ║
║         ┌─────────────────────┐                                ║
║         │ > ATTACK            │                                ║
║         │   SPECIAL MOVE      │                                ║
║         │   ITEM              │                                ║
║         │   SWITCH            │                                ║
║         │   BLOCK             │                                ║
║         │   FLEE              │                                ║
║         └─────────────────────┘                                ║
║                                                                ║
║ ♪ ♪ ♪ ♪  [Press A on beat]                                    ║
║     ↑                                                          ║
╚════════════════════════════════════════════════════════════════╝
```

**Components:**

1. **Party Status Panels**
   - Left: Player party
   - Right: Enemy party
   - Shows all 6 monsters
   - HP bars, status icons, names
   - Active monster highlighted (glowing border)

2. **Action Menu**
   - Center-screen when player's turn
   - 6 main actions
   - Shows MP cost for special moves
   - Disabled options greyed out

3. **Turn Order Indicator**
   - Top-center
   - Shows next 5 upcoming turns
   - Portrait icons + names
   - Current actor highlighted

4. **Rhythm Mini-Game**
   - Appears after action selected
   - Beat track with moving marker
   - "Press A" prompt
   - Timing zones colored (gold = perfect, blue = good, grey = okay)

5. **Battle Log**
   - Bottom-left corner (optional, can be toggled)
   - Shows last 5 actions
   - "Goblin used Fire Blast! Super effective!"
   - "Thunder Wolf took 45 damage!"

---

### Shared UI Elements

**Pause Menu:**
```
┌─────────────────┐
│ PAUSED          │
│                 │
│ > Resume        │
│   Items         │
│   Options       │
│   Flee          │
│   Forfeit       │
└─────────────────┘
```

**Victory Screen:**
```
┌──────────────────────────────┐
│    ★ VICTORY! ★              │
│                              │
│ XP Gained: 156 (+25% bonus)  │
│                              │
│ Level Up! Lv 12 → 13         │
│ ATK: 42 → 45                 │
│ DEF: 28 → 30                 │
│                              │
│ Items: Rusty Sword ×1        │
│ Gold: 45G                    │
│                              │
│ Bonuses:                     │
│ ⭐ Perfect Victory            │
│ ⭐ Downbeat Finisher          │
│                              │
│ [Press A to Continue]        │
└──────────────────────────────┘
```

**Defeat Screen:**
```
┌──────────────────────────────┐
│      DEFEATED                │
│                              │
│ You lost 10% of your gold    │
│ (-127G)                      │
│                              │
│ Returning to last            │
│ checkpoint...                │
│                              │
│ [Press A to Continue]        │
└──────────────────────────────┘
```

---

## 12. Combat Rewards

### XP Gain Formula

**Base XP Calculation:**
```gdscript
var base_xp: int = enemy.base_xp_value

# Level difference modifier
var level_diff: int = enemy.level - player_level

var level_mod: float = 1.0
if level_diff > 0:
    level_mod = 1.0 + (level_diff * 0.1)  # +10% per level higher
    level_mod = min(level_mod, 1.5)  # Cap at +50%
elif level_diff < 0:
    level_mod = max(0.5, 1.0 - (abs(level_diff) * 0.05))  # -5% per level lower, min 50%

var final_xp: int = int(base_xp * level_mod)
```

**Bonus Multipliers (Multiplicative):**
- Perfect Victory (no damage taken): ×1.25
- Rhythm Master (90%+ on-beat): ×1.20
- Speed Clear (<30s real-time / <10 turns turn-based): ×1.15
- Downbeat Finisher: ×1.25
- Clean Sweep (turn-based, no faints): ×1.30
- Type Advantage (turn-based): ×1.15

**Example:**
```
Enemy Base XP: 100
Enemy Level 15, Player Level 12
Level Diff: +3

Level Mod: 1.0 + (3 × 0.1) = 1.30
Base XP: 100 × 1.30 = 130

Bonuses: Perfect Victory + Rhythm Master
Final XP: 130 × 1.25 × 1.20 = 195 XP
```

---

### Dual XP System (S19 Integration)

**XP Split:**
```
Total XP earned → Split into two types:
- 70% → Combat XP (traditional leveling, increases stats)
- 30% → Knowledge XP (unlocks abilities, upgrades, lore)
```

**Example:**
```
Total XP: 195

Combat XP: 195 × 0.70 = 136 XP
Knowledge XP: 195 × 0.30 = 59 XP
```

**Why Split?**
- Combat XP: Direct power increase (HP, ATK, DEF, etc.)
- Knowledge XP: Unlocks skill trees, special moves, passive abilities
- Encourages diverse playstyles (not just grinding for levels)

**Knowledge XP Uses:**
- Unlock new special moves (costs 100 Knowledge XP)
- Upgrade existing moves (costs 50 Knowledge XP)
- Learn passive abilities (costs 75 Knowledge XP)
- Unlock lore entries (costs 25 Knowledge XP)

---

### Item Drops

**Drop System:**

Each enemy has a **loot table** (stored in S12 Monster Database):

```json
{
  "enemy_id": "goblin_warrior",
  "loot_table": {
    "guaranteed": [],
    "common": [
      {"item": "rusty_sword", "chance": 0.40},
      {"item": "health_potion", "chance": 0.30}
    ],
    "uncommon": [
      {"item": "iron_sword", "chance": 0.15},
      {"item": "strength_ring", "chance": 0.10}
    ],
    "rare": [
      {"item": "legendary_blade", "chance": 0.05}
    ]
  }
}
```

**Drop Chance Calculation:**
```gdscript
func roll_item_drop(item: Dictionary, base_chance: float) -> bool:
    var final_chance: float = base_chance

    # Bonuses
    if downbeat_finisher:
        final_chance += 0.15
    if perfect_victory:
        final_chance += 0.10
    if rhythm_master:
        final_chance += 0.05

    # Cap at 75%
    final_chance = min(final_chance, 0.75)

    return randf() < final_chance
```

**Multiple Drops:**
- Can drop multiple items (common + uncommon + rare all possible)
- Each item rolls independently

---

### Currency (Gold)

**Gold Formula:**
```gdscript
var base_gold: int = enemy.base_gold_value

# Random variance (±30%)
var variance: float = randf_range(0.70, 1.30)

var final_gold: int = int(base_gold * variance)
```

**No Bonuses for Gold:**
- Gold is consistent across victories
- Only varies by random factor
- Prevents gold farming exploits

**Example:**
```
Enemy Base Gold: 50

Random variance: 1.12

Final Gold: 50 × 1.12 = 56 gold
```

---

### Performance Bonuses

**Bonus Triggers:**

| Bonus | Requirement | XP Multiplier | Item Chance Bonus |
|-------|-------------|---------------|-------------------|
| Perfect Victory | No damage taken | ×1.25 | +10% |
| Rhythm Master | 90%+ on-beat actions | ×1.20 | +5% |
| Speed Clear | <30s (real-time) / <10 turns | ×1.15 | +5% |
| Downbeat Finisher | Final hit on downbeat | ×1.25 | +15% |
| Clean Sweep | No party faints (turn-based) | ×1.30 | +10% |
| Type Advantage | Only super-effective moves | ×1.15 | +5% |

**Stacking:**
- All bonuses are **multiplicative**
- Max possible: ×2.88 XP (all bonuses combined)

**Example Max Rewards:**
```
Base XP: 100
All bonuses active:
100 × 1.25 × 1.20 × 1.15 × 1.25 × 1.30 × 1.15 = 288 XP

Item drop chance:
Base: 30%
Bonuses: +10% + 5% + 5% + 15% + 10% + 5% = +50%
Final: 80% (capped at 75%, so 75%)
```

---

## 13. Balancing Considerations

### Enemy HP Scaling

**Formula:**
```
Enemy HP = Base HP × (1 + (Level - 1) × Growth Rate)
```

**Growth Rates by Enemy Type:**
- **Weak/Fast enemies:** Growth Rate = 0.08 (8% per level)
- **Balanced enemies:** Growth Rate = 0.12 (12% per level)
- **Tank enemies:** Growth Rate = 0.18 (18% per level)
- **Bosses:** Growth Rate = 0.25 (25% per level)

**Examples:**

**Goblin (Weak, Fast):**
- Base HP: 30
- Growth: 8%

| Level | HP |
|-------|-----|
| 1 | 30 |
| 10 | 51 |
| 25 | 87 |
| 50 | 148 |

**Boss (Tank):**
- Base HP: 80
- Growth: 25%

| Level | HP |
|-------|-----|
| 1 | 80 |
| 10 | 260 |
| 25 | 560 |
| 50 | 1,060 |

---

### Damage Scaling

**Player Damage Progression:**

**Early Game (Levels 1-15):**
- Average damage: 10-25 per hit
- Battles: 4-8 hits to kill
- Duration: 20-40 seconds (real-time)

**Mid Game (Levels 16-35):**
- Average damage: 30-70 per hit
- Battles: 5-10 hits to kill
- Duration: 30-60 seconds

**Late Game (Levels 36-50):**
- Average damage: 80-150 per hit
- Battles: 6-12 hits to kill
- Duration: 40-90 seconds

**Why Scaling Slows:**
- Enemy HP scales faster than player damage
- Encourages strategic play (not just raw stats)
- Rhythm mastery becomes more important
- Special moves and type advantages matter more

---

### Combat Duration Targets

**Real-Time Mode:**
| Enemy Type | Target Duration |
|------------|-----------------|
| Trash Mob | 20-40 seconds |
| Elite Enemy | 45-75 seconds |
| Mini-Boss | 60-120 seconds |
| Major Boss | 90-300 seconds (multi-phase) |

**Turn-Based Mode:**
| Battle Type | Target Turns | Real-Time Equivalent |
|-------------|--------------|----------------------|
| Wild Encounter | 6-12 turns | 3-6 minutes |
| Trainer Battle | 12-20 turns | 6-10 minutes |
| Gym Leader | 20-30 turns | 10-15 minutes |
| Championship | 30-50 turns | 15-25 minutes |

**Pacing:**
- Early battles: Shorter (build confidence)
- Mid game: Moderate (test mastery)
- Late game: Longer (strategic depth)
- Bosses: Extended (epic encounters)

---

### Difficulty Curve

**Level-Based Difficulty:**

| Player Level | Enemy Difficulty | New Mechanics Introduced |
|--------------|------------------|--------------------------|
| 1-5 | Tutorial | Basic attack, dodge |
| 6-10 | Easy | Heavy attack, block |
| 11-20 | Moderate | Special moves, status effects |
| 21-35 | Challenging | Multi-phase bosses, combos |
| 36-50 | Hard | Complex patterns, mastery required |

**Adaptive Difficulty (Optional Setting):**

```gdscript
func calculate_player_performance() -> float:
    var metrics = {
        "death_count": player.deaths_last_hour,
        "avg_combat_duration": player.avg_combat_time,
        "rhythm_accuracy": player.avg_timing_quality
    }

    var performance_score: float = 0.0

    if metrics.death_count > 5:
        performance_score -= 0.2
    if metrics.avg_combat_duration > target_duration * 1.5:
        performance_score -= 0.15
    if metrics.rhythm_accuracy < 0.6:
        performance_score -= 0.15

    return performance_score
```

**Adaptive Adjustments:**
- Struggling players: +25ms timing windows, -10% enemy damage
- Thriving players: -15ms timing windows, +10% enemy HP (more challenge)
- Neutral players: No adjustments

---

### Rhythm Requirement Balance

**Design Goal:** Rhythm enhances but doesn't gatekeep

**Non-Rhythm Player Path:**
```
- Can complete game without timing bonuses
- Takes ~30% longer in combat
- Relies on stats, items, type advantages
- Still enjoyable experience
```

**Rhythm Master Path:**
```
- 40% faster combat clear times
- Higher XP gains (+20-50% bonuses)
- More item drops
- Feels like rhythm game mastery
```

**Accessibility Options:**
- **Rhythm Assist:** Visual metronome, larger timing windows (+50ms)
- **Audio Cues:** Sound effect on upcoming beat
- **Auto-Timing:** Game times actions for player (80% accuracy)

---

### Real-Time vs Turn-Based Balance

**Why Choose Real-Time?**
- ✅ Faster pacing (action-oriented)
- ✅ Skill expression (player reflexes matter)
- ✅ Feels like Zelda combat
- ❌ More difficult for non-action players
- ❌ Cannot strategize mid-battle

**Why Choose Turn-Based?**
- ✅ Strategic depth (plan ahead)
- ✅ Party management (use all 6 monsters)
- ✅ Easier for casual players (take time to think)
- ❌ Slower pacing (can feel tedious)
- ❌ Less direct control

**Balancing Rewards:**
```
Real-Time XP: 100% of calculated XP
Turn-Based XP: 120% of calculated XP (bonus for longer battles)

Real-Time Gold: 100%
Turn-Based Gold: 110% (slightly more)
```

**Why Turn-Based Gets More?**
- Longer time investment
- Manages 6 monsters vs 1 companion
- Encourages players to try both modes

---

## 14. Integration Points

### S01 - Conductor System

**Signals to Listen For:**
```gdscript
# In combat script
func _ready() -> void:
    Conductor.beat.connect(_on_beat)
    Conductor.downbeat.connect(_on_downbeat)
    Conductor.measure_complete.connect(_on_measure_complete)

func _on_beat() -> void:
    # Update beat indicator UI
    beat_indicator.pulse()

    # Check if player action was on-beat
    if player_action_this_frame:
        evaluate_timing_quality()

func _on_downbeat() -> void:
    # Trigger special effects
    # Check for downbeat finishers
    # Award bonus multipliers
    pass
```

**Data Needed from S01:**
- Current BPM
- Beat timestamp
- Time until next beat
- Measure position (1, 2, 3, 4)

---

### S02 - Controller Input

**Button Mapping in Combat:**

**Real-Time:**
```gdscript
var combat_input_map = {
    "move_up": "w",
    "move_down": "s",
    "move_left": "a",
    "move_right": "d",
    "attack_basic": "j",
    "attack_heavy": "k",
    "dodge": "l",
    "block": "shift",
    "special_move": "u",
    "use_item": "i",
    "use_tool": "o",
    "switch_companion": "tab",
    "pause": "escape"
}
```

**Turn-Based:**
```gdscript
var menu_input_map = {
    "menu_up": "w",
    "menu_down": "s",
    "menu_confirm": "j",
    "menu_cancel": "k",
    "rhythm_button": "space"
}
```

**Input Buffering:**
- Buffer window: 100ms
- Allows "early" inputs to register
- Prevents dropped inputs on beat

---

### S04 - Combat Prototype

**Implementation Priority:**
1. ✅ **Phase 1:** Basic real-time combat
   - Player movement
   - Basic attack
   - Enemy AI (simple aggro)
   - Win/loss conditions

2. ✅ **Phase 2:** Rhythm integration
   - Connect to Conductor
   - Timing windows
   - Damage multipliers
   - Beat indicator UI

3. ✅ **Phase 3:** Advanced mechanics
   - Dodge/block (basic)
   - Special moves
   - Status effects
   - Companion AI

4. ✅ **Phase 4:** Turn-based mode
   - Turn order system
   - Party management
   - Action menu
   - Rhythm mini-game

---

### S07 - Weapons Database

**Weapon Stat Application:**
```gdscript
# In damage calculation
var weapon_data: Dictionary = WeaponsDB.get_weapon(player.equipped_weapon_id)

var weapon_bonus: float = 1.0 + (weapon_data.attack_bonus / 100.0)
final_damage *= weapon_bonus
```

**Weapon Properties Used:**
- `attack_bonus` - % increase to damage (10%, 25%, 80%)
- `special_effects` - On-hit effects (burn, bleed, stun)
- `type` - Weapon element (fire, ice, lightning)
- `crit_bonus` - Additional crit chance (+5%, +10%)

---

### S08 - Equipment System

**Equipment Stat Application:**
```gdscript
# Calculate total equipment bonuses
func get_equipment_bonuses() -> Dictionary:
    var bonuses = {
        "hp": 0,
        "atk": 0,
        "def": 0,
        "sp_atk": 0,
        "sp_def": 0,
        "spd": 0,
        "crit_chance": 0.0
    }

    for slot in ["helmet", "armor", "gloves", "boots", "accessory"]:
        var item = player.equipment[slot]
        if item:
            bonuses.hp += item.hp_bonus
            bonuses.atk += item.atk_bonus
            # ... etc

    return bonuses
```

**Equipment Slots:**
- Helmet (DEF, SP.DEF)
- Armor (HP, DEF)
- Gloves (ATK)
- Boots (SPD)
- Accessory (varies - special effects)

---

### S09 - Dodge/Block Mechanics

**Dodge Specifications:**
```gdscript
func execute_dodge() -> void:
    var iframe_duration: float = 0.2  # Base 200ms

    # Check timing quality
    var timing = get_timing_quality()
    match timing:
        TimingQuality.PERFECT:
            iframe_duration = 0.5  # 500ms
            apply_speed_boost(1.5, 2.0)  # +50% speed for 2s
        TimingQuality.GOOD:
            iframe_duration = 0.35  # 350ms
        _:
            iframe_duration = 0.2  # 200ms

    player.set_invulnerable(iframe_duration)
    play_dodge_animation()
```

**Block Specifications:**
```gdscript
func execute_block(enemy_attack: Attack) -> void:
    var damage_reduction: float = 0.5  # Base 50%

    var timing = get_timing_quality()
    match timing:
        TimingQuality.PERFECT:
            damage_reduction = 1.0  # 100% - no damage
            enemy.apply_stagger(1.0)  # Parry!
        TimingQuality.GOOD:
            damage_reduction = 0.75  # 75%
        _:
            damage_reduction = 0.5  # 50%

    var final_damage = enemy_attack.damage * (1.0 - damage_reduction)
    player.take_damage(final_damage)
```

---

### S10 - Special Moves

**Special Move Requirements:**
```gdscript
class_name SpecialMove

var move_name: String
var mp_cost: int
var base_power: int
var timing_requirement: String  # "downbeat", "beat", "none"
var bonus_effect: String  # "burn", "stun", "heal", etc.

func can_execute() -> bool:
    if player.mp < mp_cost:
        return false

    if timing_requirement == "downbeat":
        return Conductor.is_downbeat(0.075)  # ±75ms
    elif timing_requirement == "beat":
        return Conductor.is_on_beat(0.100)  # ±100ms

    return true

func execute() -> void:
    player.consume_mp(mp_cost)

    var damage = calculate_damage(base_power)

    if get_timing_quality() == TimingQuality.PERFECT:
        damage *= 1.25
        apply_bonus_effect()

    target.take_damage(damage)
```

**Integration:**
- Pull move data from S10 special moves database
- Use same timing windows as normal attacks
- Perfect timing = bonus effect triggers

---

### S11 - Enemy AI

**AI Behavior Tree Integration:**
```gdscript
# Enemy AI uses same timing system as player
func enemy_attack() -> void:
    # Wait for next beat
    await Conductor.beat

    # AI timing accuracy based on difficulty
    var timing_quality = roll_ai_timing_accuracy()

    var damage = calculate_damage(base_attack)
    damage *= get_timing_multiplier(timing_quality)

    player.take_damage(damage)
```

**AI Difficulty Settings (from Section 10):**
- Easy: 60% on-beat accuracy
- Normal: 75%
- Hard: 90%
- Expert: 95%

---

### S12 - Monster Database

**Monster Data Structure:**
```json
{
  "monster_id": "goblin_warrior",
  "base_stats": {
    "hp": 40,
    "atk": 12,
    "def": 8,
    "sp_atk": 6,
    "sp_def": 7,
    "spd": 10
  },
  "growth_rates": {
    "hp": 4,
    "atk": 2,
    "def": 1,
    "sp_atk": 1,
    "sp_def": 1,
    "spd": 1
  },
  "learnable_moves": [
    {"move": "slash", "level": 1},
    {"move": "power_strike", "level": 8},
    {"move": "whirlwind", "level": 15}
  ],
  "type": ["physical", "earth"]
}
```

**Combat Integration:**
```gdscript
# Load monster stats
var monster_data = MonsterDB.get_monster("goblin_warrior")

# Apply level scaling
var scaled_stats = calculate_scaled_stats(monster_data, current_level)

# Create combat instance
var enemy = Enemy.new(scaled_stats)
```

---

### S13 - Color-Shift Health (Vibe Bar)

**HP Percentage to Color Mapping:**
```gdscript
func get_vibe_color(hp_percent: float) -> Color:
    if hp_percent >= 0.80:
        return Color.GREEN  # Energized
    elif hp_percent >= 0.60:
        return Color.YELLOW  # Confident
    elif hp_percent >= 0.40:
        return Color.ORANGE  # Cautious
    elif hp_percent >= 0.20:
        return Color.RED  # Stressed
    else:
        return Color.PURPLE  # Critical

func get_vibe_state(hp_percent: float) -> String:
    if hp_percent >= 0.80:
        return "energized"
    elif hp_percent >= 0.60:
        return "confident"
    elif hp_percent >= 0.40:
        return "cautious"
    elif hp_percent >= 0.20:
        return "stressed"
    else:
        return "critical"
```

**Vibe State Buffs (from Section 7):**
- Energized: +5% damage
- Critical: +15% damage, +20% crit chance (desperation)

---

### S19 - Dual XP System

**XP Distribution:**
```gdscript
func award_xp(total_xp: int) -> void:
    var combat_xp: int = int(total_xp * 0.70)
    var knowledge_xp: int = int(total_xp * 0.30)

    player.gain_combat_xp(combat_xp)
    player.gain_knowledge_xp(knowledge_xp)

    check_level_up()
    check_knowledge_unlocks()
```

**Combat XP:** Levels up monster stats (traditional)
**Knowledge XP:** Unlocks abilities, skills, lore

---

### S21 - Resonance Alignment

**Type Effectiveness Integration:**
```gdscript
func get_type_effectiveness(attack_type: String, defender_type: String) -> float:
    return ResonanceSystem.get_effectiveness(attack_type, defender_type)
```

**Resonance Affects Combat:**
- Fire > Nature > Water > Fire
- Light > Dark > Light
- Physical/Special effectiveness matrix
- Dual-type stacking multipliers

**Combat Integration:**
- Pull type chart from S21
- Apply to damage formula (Section 6)
- Display effectiveness indicator in UI ("Super effective!")

---

## Appendix A: Quick Reference Tables

### Timing Windows

| Quality | Real-Time | Turn-Based | Multiplier |
|---------|-----------|------------|------------|
| Perfect | ±75ms (downbeat) | ±75ms (downbeat) | 1.5x |
| Good | ±100ms (beat) | ±150ms (beat) | 1.25x |
| Okay | ±150ms | ±250ms | 1.0x |
| Miss | >150ms | >250ms | 0.85x / 0.75x |

---

### Damage Multipliers

| Modifier | Value | Source |
|----------|-------|--------|
| Weapon (Wooden Sword) | 1.10x | S07 |
| Weapon (Iron Sword) | 1.25x | S07 |
| Weapon (Legendary) | 1.80x | S07 |
| Perfect Timing | 1.5x | Rhythm |
| Good Timing | 1.25x | Rhythm |
| Critical Hit | 1.5x | Random |
| Perfect Critical | 2.0x | Downbeat + Crit |
| Super Effective | 2.0x | S21 Type |
| Not Very Effective | 0.66x | S21 Type |
| ATK Buff (×1) | 1.10x | Status |
| ATK Buff (×2) | 1.20x | Status |
| Equipment Bonus | 1.0-1.5x | S08 |

---

### Status Effect Durations

| Status | Real-Time Duration | Turn-Based Duration | Damage/Effect |
|--------|-------------------|---------------------|---------------|
| Burn | 10s | 3 turns | 5% Max HP/tick |
| Freeze | 4s | 1 turn | -30% DEF |
| Poison | Until cured | Until cured | 3%, 5%, 7%... Max HP |
| Paralysis | 12s | 4 turns | 25% action fail, -50% SPD |
| Sleep | 6s | 2 turns | +50% damage taken |
| Confusion | 8s | 2-3 turns | 33% self-attack |

---

### Stat Scaling (Level 1 → Level 50)

| Stat | Level 1 Range | Level 50 (Low Growth) | Level 50 (High Growth) |
|------|---------------|----------------------|------------------------|
| HP | 30-50 | 130-180 | 250-330 |
| ATK | 8-15 | 32-58 | 98-135 |
| DEF | 5-12 | 25-50 | 87-112 |
| SP.ATK | 8-15 | 30-55 | 95-140 |
| SP.DEF | 5-12 | 24-48 | 85-110 |
| SPD | 6-14 | 28-52 | 72-108 |

---

### XP Bonus Multipliers

| Bonus Type | Requirement | Multiplier |
|------------|-------------|------------|
| Perfect Victory | No damage taken | ×1.25 |
| Rhythm Master | 90%+ on-beat | ×1.20 |
| Speed Clear | <30s (RT) / <10 turns (TB) | ×1.15 |
| Downbeat Finisher | Final hit on downbeat | ×1.25 |
| Clean Sweep | No party faints (TB) | ×1.30 |
| Type Advantage | Only super-effective (TB) | ×1.15 |

**Max Combined:** ×2.88 (all bonuses)

---

## Appendix B: Design Decisions Log

### Why Sequential Turn Order (Not Simultaneous)?

**Decision:** Turn-based mode uses sequential turns (one actor at a time)

**Rationale:**
1. **Strategic Depth:** Player can react to enemy actions, plan counter-moves
2. **Simpler UI:** Easier to show one action at a time vs simultaneous chaos
3. **Rhythm Integration:** Easier to present rhythm mini-game for one action
4. **Pokemon Familiarity:** Most players expect sequential from Pokemon-style games
5. **Clearer Feedback:** Player can see exact damage numbers, status effects per action

**Rejected Alternative:** WEGO system (both sides issue orders, execute simultaneously)
- **Why Rejected:** Too complex for rhythm integration, harder to visualize

---

### Why Allow Real-Time and Turn-Based Choice?

**Decision:** Player chooses mode for most encounters

**Rationale:**
1. **Player Agency:** Different players prefer different combat styles
2. **Accessibility:** Turn-based is easier for casual players, real-time for action fans
3. **Research Finding:** "Players are open to other styles of combat" (academic study)
4. **Replayability:** Same encounter feels different in each mode
5. **Prevents Fatigue:** Can switch modes if one gets repetitive

**Constraints:** Certain battles are mode-locked to preserve design intent (boss choreography, story beats)

---

### Why Wider Timing Windows for Turn-Based?

**Decision:** Turn-based has ±150ms vs ±100ms (real-time)

**Rationale:**
1. **Less Reflex-Focused:** Turn-based is strategic, not twitch-based
2. **Easier to Time:** Player controls when action happens (can wait for beat)
3. **Still Rewards Skill:** Perfect timing still grants 1.5x multiplier
4. **Accessibility:** Makes turn-based mode more forgiving overall
5. **Balances Modes:** Real-time rewards reflexes, turn-based rewards strategy

---

### Why Rhythm Enhances But Doesn't Gatekeep?

**Decision:** Off-beat actions still work, just deal 0.85x damage (not 0x)

**Rationale:**
1. **Accessibility:** Non-rhythm players can complete game
2. **Encouragement:** Players naturally improve over time (rhythm is learned)
3. **No Frustration:** Missing beat doesn't mean "action failed entirely"
4. **Research Finding:** NecroDancer creator found 100% timing leeway felt best
5. **Gradual Mastery:** Players who start bad at rhythm can still enjoy, then improve

**Alternative Rejected:** Require perfect timing for all actions
- **Why:** Too punishing, would exclude non-rhythm players

---

### Why Enemy AI Follows Rhythm?

**Decision:** Enemies attack on-beat (with varying accuracy)

**Rationale:**
1. **Predictability:** Players can learn attack patterns by beat
2. **Rhythm Duel:** Combat feels like a musical performance (call and response)
3. **Fairness:** AI plays by same rules as player
4. **Boss Design:** Rhythm-based bosses are iconic (Crypt of NecroDancer)
5. **Difficulty Scaling:** Easy enemies miss beats, hard enemies hit perfectly

**Alternative Rejected:** Random attack timing
- **Why:** Less satisfying, harder to learn patterns

---

### Why Companion Faint Doesn't Auto-Lose?

**Decision:** Player can continue solo if companion faints

**Rationale:**
1. **Player Skill Matters:** Skilled players can clutch victory solo
2. **Tension:** Creates dramatic moments ("down to the wire")
3. **Not Instant Defeat:** Gives player chance to flee or finish fight
4. **Resource Management:** Player must decide when to summon next companion
5. **Risk/Reward:** Solo play is harder but demonstrates mastery

---

### Why Dual XP System (Combat + Knowledge)?

**Decision:** XP splits 70% Combat, 30% Knowledge

**Rationale:**
1. **Progression Diversity:** Not just stat increases (boring)
2. **Skill Unlocks:** Knowledge XP unlocks new abilities (exciting)
3. **Player Choice:** Players decide what to unlock with Knowledge XP
4. **Prevents Grind:** Can't just over-level stats, need skill unlocks too
5. **Lore Integration:** Knowledge XP ties to S19 exploration/discovery

---

### Why Item Drops Scale with Performance?

**Decision:** Better rhythm/speed = higher drop chance

**Rationale:**
1. **Reward Skill:** Players who master combat get better loot
2. **Engagement:** Encourages trying for perfect victories
3. **Farming Efficiency:** Skilled players can farm items faster
4. **Not Required:** Base drop rates are still fair, bonuses are extra
5. **Feels Good:** Hitting that perfect downbeat finisher → rare item feels amazing

---

### Why Boss Battles Use Rhythm Perfectly?

**Decision:** Bosses execute 95-100% on-beat actions

**Rationale:**
1. **Challenge:** Final test of player rhythm mastery
2. **Musical Boss Fight:** Boss attacks ARE the music (choreographed)
3. **Learnable Patterns:** On-beat = predictable patterns players can learn
4. **Epic Feel:** Rhythmic boss fights are memorable (iconic moments)
5. **Skill Check:** Players must internalize beat to succeed

---

### Why Burn and Poison Are Different?

**Decision:** Burn = consistent 5% damage, Poison = ramping 3%, 5%, 7%...

**Rationale:**
1. **Tactical Choice:** Burn is immediate, poison is long-term threat
2. **Curing Priority:** Poison becomes urgent if not cured (ramps)
3. **Time Limit:** Poison creates pressure (must end fight or cure)
4. **Design Space:** Two DoT effects with different strategic uses
5. **Pokemon Inspiration:** Toxic (poison) is more dangerous over time

---

## Appendix C: State Machine Diagrams

### Real-Time Combat State Machine

```
                    [ENCOUNTER TRIGGER]
                            ↓
                    ┌──────────────┐
                    │ PRE_COMBAT   │
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │ MODE_SELECT  │ (if not locked)
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │PARTY_SELECT  │ (choose companion)
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │  COMBAT_     │
                    │ INITIALIZE   │
                    └──────┬───────┘
                           ↓
             ┌─────────────┴──────────────┐
             │                            │
      ┌──────▼──────┐              ┌─────▼──────┐
      │   COMBAT    │◄────────────►│   PAUSED   │
      │   ACTIVE    │              └─────┬──────┘
      └──────┬──────┘                    │
             │                            │
        ┌────┴────┬──────────┬───────────┘
        ↓         ↓          ↓
  ┌─────────┐ ┌────────┐ ┌──────┐
  │ VICTORY │ │ DEFEAT │ │ FLED │
  └────┬────┘ └───┬────┘ └───┬──┘
       │          │           │
       ↓          └───┬───┘   │
  ┌─────────┐        │        │
  │ REWARDS │        │        │
  └────┬────┘        │        │
       └─────────────┴────────┘
                     ↓
              ┌─────────────┐
              │EXIT_COMBAT  │
              └─────────────┘
                     ↓
               [OVERWORLD]
```

---

### Turn-Based Combat State Machine

```
                    [ENCOUNTER TRIGGER]
                            ↓
                    ┌──────────────┐
                    │ PRE_COMBAT   │
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │ MODE_SELECT  │
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │PARTY_SELECT  │ (arrange 6 monsters)
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │  COMBAT_     │
                    │ INITIALIZE   │ (calculate initiative)
                    └──────┬───────┘
                           ↓
                    ┌──────────────┐
                    │   TURN_      │
                    │   START      │
                    └──────┬───────┘
                           ↓
                  ┌────────┴────────┐
                  │                 │
          ┌───────▼──────┐   ┌─────▼──────┐
          │ PLAYER_TURN  │   │ ENEMY_TURN │
          │ (action menu)│   │ (AI acts)  │
          └───────┬──────┘   └─────┬──────┘
                  │                │
                  └────────┬───────┘
                           ↓
                  ┌────────────────┐
                  │  EXECUTE_      │
                  │  ACTION        │ (rhythm mini-game)
                  └────────┬───────┘
                           ↓
                  ┌────────────────┐
                  │  CHECK_WIN_    │
                  │  LOSS          │
                  └────────┬───────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼────┐   ┌───────▼──────┐   ┌────▼────┐
    │ VICTORY  │   │ NEXT_TURN    │   │ DEFEAT  │
    └────┬─────┘   └───────┬──────┘   └────┬────┘
         │                 ↓               │
         │          (loop back to          │
         │           TURN_START)           │
         │                                 │
         └────────────┬────────────────────┘
                      ↓
              ┌───────────────┐
              │   REWARDS     │
              └───────┬───────┘
                      ↓
              ┌───────────────┐
              │ EXIT_COMBAT   │
              └───────────────┘
                      ↓
                [OVERWORLD]
```

---

## Document Completion

**Specification Version:** 1.0
**Status:** 🔒 **LOCKED** - Ready for Implementation
**Date Completed:** 2025-11-18

**All 14 Required Sections:** ✅ Complete
**Numerical Values:** ✅ All specified (no TBDs)
**Design Decisions:** ✅ Justified in Appendix B
**Integration Points:** ✅ Documented for all dependent systems

**This specification is now the single source of truth for all combat-related systems (S04, S09, S10, S11, S13, S19, S21).**

**Next Steps:**
1. Implementation teams should read this spec before starting S04, S09, S10, S11
2. Reference exact formulas and timing windows during implementation
3. Do NOT deviate from this spec without updating it first
4. Report any ambiguities or conflicts back to design team

---

**End of Combat Specification**
