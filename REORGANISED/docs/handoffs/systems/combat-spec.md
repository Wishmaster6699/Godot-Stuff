# Combat Specification Handoff

**Created by:** Claude Code Web
**Date:** 2025-11-18
**Status:** ✅ Ready for Implementation Teams
**Job:** 2 of 4 - Combat Specification

---

## Executive Summary

Combat specification is **COMPLETE**. This handoff contains a comprehensive design document that locks in ALL combat decisions for the Rhythm RPG. Implementation teams (S04, S09, S10, S11) must reference this spec before writing any combat code.

**File Created:**
- ✅ `combat-specification.md` - Complete combat design (33,000+ words, all 14 sections + 3 appendices)

**Status:** This is a specification document. No scene configuration needed for this handoff.

---

## Files Created (Tier 1 Complete)

### combat-specification.md

**Purpose:** Single source of truth for all combat systems

**Comprehensive Coverage (14 Main Sections):**

1. ✅ **Combat Overview** - Design philosophy, player experience goals, game integration
2. ✅ **Combat Mode Types** - Real-time 1v1 and Turn-based 6v6 fully specified
3. ✅ **Mode Selection** - How players choose, UI, mode-locked encounters
4. ✅ **Party System Mechanics** - Real-time companions and turn-based party management
5. ✅ **Rhythm Integration** - Exact timing windows (±75ms perfect, ±100ms good), beat compliance
6. ✅ **Stats & Damage Calculation** - Complete damage formula with all multipliers
7. ✅ **Health & Status Systems** - HP, Vibe Bar, 6 status effects (burn, freeze, poison, etc.)
8. ✅ **Victory & Loss Conditions** - Win/loss/flee mechanics for both modes
9. ✅ **Combat State Management** - Full state machine diagrams
10. ✅ **AI Behavior** - Enemy patterns, difficulty scaling, telegraph system
11. ✅ **Combat UI Requirements** - HUD layouts for both modes, all UI elements
12. ✅ **Combat Rewards** - XP formulas, dual XP system, item drops, bonuses
13. ✅ **Balancing Considerations** - HP scaling, damage progression, difficulty curve
14. ✅ **Integration Points** - How combat connects to S01, S02, S04, S07, S08, S09, S10, S11, S12, S13, S19, S21

**Appendices (3 Total):**

- **Appendix A:** Quick Reference Tables (timing windows, multipliers, stat scaling, etc.)
- **Appendix B:** Design Decisions Log (justifications for all major design choices)
- **Appendix C:** State Machine Diagrams (visual state flow for both combat modes)

**Word Count:** ~33,000 words
**Exact Values:** ✅ All numerical values specified (no "TBD" or placeholders)
**Formulas:** ✅ Complete GDScript-ready damage calculation
**Integration:** ✅ Documented for 12 dependent systems

---

## MCP Agent Tasks (Tier 2)

### Primary Task: Reference During Implementation

**⚠️ IMPORTANT: No scene configuration needed for this document. This is pure specification.**

### What Implementation Teams Should Do

**BEFORE Starting Any Combat System (S04, S09, S10, S11):**

1. **Read combat-specification.md completely** (yes, all 33,000 words)
   - Understand both combat modes (real-time and turn-based)
   - Know exact timing windows (±75ms perfect, ±100ms good, etc.)
   - Study the complete damage formula (Section 6)
   - Review state machine diagrams (Appendix C)

2. **Reference specific sections during implementation:**
   - **S04 (Combat Prototype):** Sections 2, 5, 6, 9, 14 (modes, rhythm, damage, states, integration)
   - **S09 (Dodge/Block):** Section 5 (timing windows for dodge/block mechanics)
   - **S10 (Special Moves):** Sections 5, 6 (rhythm requirements, damage calculation)
   - **S11 (Enemy AI):** Sections 2, 10 (combat modes, AI behavior patterns)

3. **Use Appendix A as quick reference** for:
   - Timing windows (don't guess, use exact millisecond values)
   - Damage multipliers (all types documented)
   - Status effect durations
   - Stat scaling formulas

4. **Follow design decisions from Appendix B:**
   - Understand WHY choices were made (not just WHAT to implement)
   - Don't deviate without updating spec first

5. **Update spec if conflicts found:**
   - If implementation reveals spec ambiguity: document it
   - If formula doesn't work: propose update to spec (don't silently change)
   - Spec is living document during implementation

---

## Integration Points

### Specification Referenced By

**Systems that MUST read this spec before implementation:**

| System | Section Focus | Key Details |
|--------|---------------|-------------|
| **S04** - Combat Prototype | 2, 5, 6, 9, 14 | Combat modes, rhythm integration, damage formula, state machine |
| **S09** - Dodge/Block | 5 (Rhythm Integration) | Timing windows: dodge i-frames (200ms → 350ms → 500ms), block damage reduction (50% → 75% → 100%) |
| **S10** - Special Moves | 5 (Rhythm), 6 (Damage) | Must be on downbeat (±75ms), perfect timing = +25% damage + bonus effect |
| **S11** - Enemy AI | 2 (Modes), 10 (AI Behavior) | Attack patterns, difficulty scaling (60% → 95% on-beat accuracy), telegraph system |
| **S13** - Color-Shift Health | 7 (Health & Status) | Vibe Bar color thresholds: Green (80%+), Yellow (60-79%), Orange (40-59%), Red (20-39%), Purple (1-19%) |
| **S19** - Dual XP System | 12 (Rewards) | 70% Combat XP, 30% Knowledge XP split |
| **S21** - Resonance Alignment | 6 (Damage Calculation) | Type effectiveness multipliers in damage formula |

**Systems that provide data TO combat:**

| System | Data Provided | Used In |
|--------|---------------|---------|
| **S01** - Conductor | Beat signals, BPM, timing data | Section 5 (Rhythm Integration) |
| **S02** - Controller Input | Combat button mapping | Section 2 (Controls) |
| **S07** - Weapons Database | Weapon bonuses (+10%, +25%, +80%) | Section 6 (Damage - Weapon Modifier) |
| **S08** - Equipment System | Equipment stat bonuses | Section 6 (Damage - Equipment Bonus) |
| **S12** - Monster Database | Base stats, growth rates, move lists | Sections 4, 6 (Party, Stats) |

---

## Key Specifications Defined

### Combat Modes

**Real-Time 1v1:**
- Player + 1 companion vs 1 enemy
- Expected duration: 30-90 seconds
- Controls: WASD movement, J/K/L attacks, Shift block
- Rhythm bonuses: 1.0x → 1.25x → 1.5x (baseline → on-beat → downbeat)
- "In The Zone" buff: 80% on-beat actions for 10s = +10% damage

**Turn-Based 6v6:**
- 6 vs 6 monsters, 1 active per side
- Expected duration: 3-20 minutes
- Sequential turn order based on speed stat
- Rhythm mini-game for attack timing
- Wider timing windows: ±150ms (vs ±100ms real-time)

### Timing Windows (Exact Values)

| Quality | Real-Time | Turn-Based | Multiplier |
|---------|-----------|------------|------------|
| **Perfect** | ±75ms from downbeat | ±75ms from downbeat | **1.5x** |
| **Good** | ±100ms from beat | ±150ms from beat | **1.25x** |
| **Okay** | ±150ms from beat | ±250ms from beat | **1.0x** |
| **Miss** | >150ms | >250ms | **0.85x / 0.75x** |

### Complete Damage Formula

```gdscript
var final_damage: int = int(
    base_damage  # Pokemon-style: (((2×Level/5)+2) × ATK × Power / DEF) / 50 + 2
    * weapon_modifier        # 1.10x - 1.80x (from S07)
    * timing_multiplier      # 0.75x - 1.5x (rhythm quality)
    * type_effectiveness     # 0.5x - 2.0x (from S21)
    * critical_modifier      # 1.0x or 1.5x (or 2.0x perfect critical)
    * equipment_bonus        # 1.0x - 1.5x (from S08)
    * buff_modifier          # 0.5x - 1.5x (buffs/debuffs)
    * random_factor          # 0.85 - 1.0 (variance)
)
```

**All multipliers are MULTIPLICATIVE** (they stack by multiplication, not addition).

### Status Effects (6 Total)

1. **Burn 🔥** - 5% Max HP per tick, 10s / 3 turns
2. **Freeze ❄️** - Action lock, -30% DEF, 4s / 1 turn
3. **Poison ☠️** - Ramping damage (3%, 5%, 7%...), until cured
4. **Paralysis ⚡** - 25% action fail, -50% SPD, 12s / 4 turns
5. **Sleep 💤** - Action lock, +50% damage taken, 6s / 2 turns
6. **Confusion 😵** - 33% self-attack, 8s / 2-3 turns

### Victory/Loss Conditions

**Real-Time Victory:**
- Enemy HP = 0
- Downbeat finisher bonus: +25% XP, +15% item drop chance

**Real-Time Loss:**
- Player HP = 0 AND companion fainted/unavailable
- Penalty: -10% gold, respawn at checkpoint

**Turn-Based Victory:**
- All 6 enemy monsters fainted
- Clean Sweep bonus: +30% XP

**Turn-Based Loss:**
- All 6 player monsters fainted
- Penalty: -10% gold, monsters revive at 1 HP

### Party System

**Real-Time:**
- 1 active companion
- AI-controlled (Aggressive, Defensive, Balanced, Follow)
- Can switch during battle (60s cooldown)
- Companion faint: Player continues solo

**Turn-Based:**
- 6 monsters, 1 active
- Free switch when active faints or enemy faints
- Turn-using switch otherwise
- Benched monsters don't regenerate

### Rewards

**XP Bonuses (Multiplicative):**
- Perfect Victory: ×1.25
- Rhythm Master (90%+ on-beat): ×1.20
- Speed Clear: ×1.15
- Downbeat Finisher: ×1.25
- Clean Sweep (turn-based): ×1.30
- Type Advantage (turn-based): ×1.15
- **Max Combined:** ×2.88

**Dual XP Split:**
- 70% → Combat XP (levels up stats)
- 30% → Knowledge XP (unlocks abilities)

**Item Drops:**
- Base chance: 30-40% (varies by enemy)
- Bonuses: +10-15% for perfect victory, downbeat finisher
- Maximum: 75% drop chance

---

## Verification Checklist (MCP Agent)

After reading specification:

### Specification Understanding
- [ ] ✅ Understand both combat modes (real-time 1v1 and turn-based 6v6)
- [ ] ✅ Know exact timing windows (±75ms, ±100ms, ±150ms, ±250ms)
- [ ] ✅ Understand complete damage formula (8 multipliers)
- [ ] ✅ Understand party system mechanics (real-time vs turn-based)
- [ ] ✅ Know all 6 status effects and their durations
- [ ] ✅ Understand victory/loss/flee conditions for both modes
- [ ] ✅ Know reward formulas (XP, dual XP split, item drops)

### Implementation Readiness
- [ ] ✅ Can implement S04 Combat Prototype following this spec
- [ ] ✅ Can implement S09 Dodge/Block with exact timing windows
- [ ] ✅ Can implement S10 Special Moves with rhythm requirements
- [ ] ✅ Can implement S11 Enemy AI following behavior guidelines
- [ ] ✅ No ambiguities or clarifying questions needed

### Framework Quality Gates
- [ ] Run: `check_quality_gates("combat_spec")` - completeness check
- [ ] Run: `validate_checkpoint("combat_spec")` - verify required fields
- [ ] Update: COORDINATION-DASHBOARD.md
  - Status: "complete"
  - Unblock: S04, S09, S10, S11 (can now start implementation)
- [ ] Create: `knowledge-base/patterns/combat-design-patterns.md` if valuable insights discovered

---

## Notes

### Critical Guidelines for Implementation

**1. Do NOT Deviate from Spec Without Updating It First**

This spec is the single source of truth. If you find:
- Ambiguity in formulas
- Conflicting requirements
- Missing information
- Implementation impossibility

**Action:** Propose spec update, get approval, THEN update spec before implementing change.

**2. Use Exact Values (No Approximations)**

The spec provides:
- Timing windows in milliseconds: USE THEM EXACTLY
- Damage multipliers: USE THEM EXACTLY
- Status durations: USE THEM EXACTLY

Don't round, don't "roughly match" - use the specified values.

**3. Reference Appendix A for Quick Lookups**

Don't search through 33,000 words every time you need a value. Appendix A has quick reference tables for:
- All timing windows
- All multipliers
- All stat scaling formulas
- All status durations

**4. Understand Design Decisions (Appendix B)**

When implementing, read WHY a decision was made:
- "Why sequential turn order?" → Strategic depth, simpler UI, rhythm integration
- "Why rhythm doesn't gatekeep?" → Accessibility, gradual mastery
- "Why enemy AI follows rhythm?" → Predictable patterns, rhythm duel feel

Understanding the WHY helps you make aligned implementation choices.

**5. Test Against Spec Requirements**

After implementing a feature, verify:
- ✅ Timing windows match spec values
- ✅ Damage formula includes ALL 8 multipliers
- ✅ Status effects use correct durations
- ✅ State machine follows diagram in Appendix C
- ✅ UI includes all required elements from Section 11

---

## Success Criteria

### Tier 1 Success (Claude Code Web) ✅

- ✅ combat-specification.md complete (33,000+ words, all 14 sections + 3 appendices)
- ✅ Exact numerical values specified (no "TBD" or placeholders)
- ✅ Complete damage formula with all 8 multipliers
- ✅ Timing windows have precise millisecond values
- ✅ Both combat modes fully specified
- ✅ Design decisions justified in Appendix B
- ✅ Quick reference tables in Appendix A
- ✅ State machine diagrams in Appendix C
- ✅ Integration points documented for 12 systems
- ✅ HANDOFF-combat-spec.md provides clear implementation guidance

### Tier 2 Success (MCP Agent - Implementation Teams)

When implementation teams can:

- ✅ Implement S04 Combat Prototype without asking clarifying questions
- ✅ Implement S09 Dodge/Block using exact timing windows from spec
- ✅ Implement S10 Special Moves knowing exact rhythm requirements
- ✅ Implement S11 Enemy AI following behavior guidelines
- ✅ Integrate with S01, S02, S07, S08, S12 using documented integration points
- ✅ Apply S13 Vibe Bar color thresholds correctly
- ✅ Split XP according to S19 dual XP system (70/30 split)
- ✅ Use S21 type effectiveness in damage formula
- ✅ Balance combat using scaling formulas from Section 13
- ✅ All combat feels consistent across real-time and turn-based modes

**Specification is successful when ALL combat systems can be implemented by following this document without ambiguity.**

---

## Next Steps

### For Implementation Teams (S04, S09, S10, S11)

**Immediate Actions:**

1. **Read combat-specification.md** (bookmark it, you'll reference it constantly)
2. **Study your section focus:**
   - S04: Sections 2, 5, 6, 9 (modes, rhythm, damage, states)
   - S09: Section 5 (timing windows for dodge/block)
   - S10: Sections 5, 6 (rhythm requirements, damage calculation)
   - S11: Sections 2, 10 (combat modes, AI behavior)

3. **Use Appendix A** as quick reference during implementation
4. **Follow state machine diagrams** in Appendix C
5. **Reference integration points** in Section 14 for connecting to other systems

**During Implementation:**

1. **Implement exactly as specified** (don't improvise)
2. **Test timing windows** match spec (±75ms perfect, ±100ms good, etc.)
3. **Verify damage formula** includes all 8 multipliers
4. **Check state transitions** match diagrams
5. **Test both combat modes** (real-time and turn-based)

**When Complete:**

1. **Verify against spec** (all requirements met?)
2. **Run quality gates:** `check_quality_gates(system_id)`
3. **Update COORDINATION-DASHBOARD.md** (mark complete, unblock next systems)
4. **Create checkpoint:** Document implementation notes, issues encountered
5. **Knowledge base entry:** Share useful patterns discovered

---

### For Other Systems (S13, S19, S21)

**Systems that integrate with combat:**

**S13 (Color-Shift Health/Vibe Bar):**
- Read Section 7 (Health & Status Systems)
- Implement Vibe Bar color thresholds: Green (80%+), Yellow (60-79%), Orange (40-59%), Red (20-39%), Purple (1-19%)
- Apply Vibe State buffs: Energized (+5% damage), Critical (+15% damage, +20% crit)

**S19 (Dual XP System):**
- Read Section 12 (Combat Rewards)
- Implement 70% Combat XP / 30% Knowledge XP split
- Combat XP → stat leveling
- Knowledge XP → ability unlocks

**S21 (Resonance Alignment):**
- Read Section 6 (Stats & Damage Calculation)
- Provide type effectiveness multipliers for damage formula
- Fire > Nature > Water > Fire, Light > Dark > Light
- Super effective: 2.0x, Effective: 1.5x, Neutral: 1.0x, Not very: 0.66x, Resisted: 0.5x

---

## File Locations

```
/home/user/vibe-code-game/
├── combat-specification.md           ← Complete combat design (33,000 words)
├── HANDOFF-combat-spec.md            ← This file
├── COORDINATION-DASHBOARD.md         ← Update this (mark Job 2 complete, unblock S04/S09/S10/S11)
├── vibe-code-philosophy.md           ← LLM handbook (reference for development principles)
└── godot-mcp-command-reference.md    ← Technical reference (GDAI MCP commands)
```

---

## Contact & Support

**Issues with combat spec:**
- Spec unclear? Request clarification in KNOWN-ISSUES.md
- Formula doesn't work? Document conflict, propose update
- Missing information? Note in knowledge base, suggest spec amendment

**For Implementation Teams:**
- Spec is living document during implementation
- Update it if reality reveals better approaches
- Document all deviations in checkpoint
- Share discoveries in knowledge base

---

## Appendix: Implementation Priority

### Recommended Implementation Order

**Phase 1: Core Combat (S04 - Week 1)**
1. Real-time movement + basic attack
2. Enemy AI (simple aggro)
3. Win/loss conditions
4. Basic UI (health bars)

**Phase 2: Rhythm Integration (S04 - Week 1-2)**
1. Connect to S01 Conductor
2. Timing windows (perfect/good/okay/miss)
3. Damage multipliers
4. Beat indicator UI

**Phase 3: Advanced Mechanics (S09, S10 - Week 2-3)**
1. S09: Dodge/block with timing windows
2. S10: Special moves with rhythm requirements
3. Status effects (burn, poison, etc.)
4. Companion AI

**Phase 4: Turn-Based Mode (S04 - Week 3-4)**
1. Turn order system
2. Party management (6 monsters)
3. Action menu UI
4. Rhythm mini-game

**Phase 5: Enemy AI (S11 - Week 4-5)**
1. Attack patterns (random → scripted → adaptive)
2. Difficulty scaling
3. Telegraph system
4. Boss phases

**Phase 6: Polish & Balance (All Systems - Week 5-6)**
1. Rewards (XP, items, gold)
2. Balance testing (scaling formulas)
3. UI polish
4. Integration testing with S07, S08, S12, S13, S19, S21

---

**Combat Specification Complete. Ready for Implementation.**

**All combat systems (S04, S09, S10, S11) can now proceed using this locked specification.**

---

**End of Handoff Document**
