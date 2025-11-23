<objective>
Create a complete combat specification document that locks in ALL combat design decisions for the Rhythm RPG. This is pure design work (no implementation) that will guide systems S04 (Combat Prototype), S09 (Dodge/Block), S10 (Special Moves), S11 (Enemy AI), and all future combat-related systems.

This document finalizes: combat modes, rhythm integration, damage calculations, party systems, victory/loss conditions, and combat state management.
</objective>

<context>
You are designing the combat system for a Godot 4.5 Rhythm RPG that blends Pokemon + Zelda + Lufia 2 with rhythm mechanics. The game has TWO combat modes: real-time 1v1 and turn-based 6v6.

The combat must integrate with:
- **S01 Conductor System** - for rhythm beat synchronization
- **S02 Controller Input** - for combat controls
- **S07 Weapons Database** - for damage calculations
- **S08 Equipment System** - for stat bonuses
- **S12 Monster Database** - for party members and enemies

This specification will be referenced by multiple parallel implementation agents.

Reference:
@rhythm-rpg-implementation-guide.md (for overall game context)
@vibe-code-philosophy.md (once Job 1 completes - for design principles)
</context>

<framework_integration>

## AI Development Success Framework

**BEFORE STARTING**, read and follow:
- @AI-VIBE-CODE-SUCCESS-FRAMEWORK.md (Complete quality/coordination framework)

### Pre-Work Checklist
- [ ] Check `COORDINATION-DASHBOARD.md` for blockers, active work, and resource locks
- [ ] Search `knowledge-base/` for related issues or solutions
- [ ] Review `KNOWN-ISSUES.md` for this system's known problems
- [ ] Update `COORDINATION-DASHBOARD.md`: Claim work, lock any shared resources

### During Implementation
- [ ] Update `COORDINATION-DASHBOARD.md` at 25%, 50%, 75% progress milestones
- [ ] Document any issues discovered in `KNOWN-ISSUES.md`
- [ ] Use placeholder assets (see `ASSET-PIPELINE.md`) - don't wait for final art

### Before Marking Complete
Run all quality gates (see expanded verification section below):
- [ ] Integration tests: `IntegrationTestSuite.run_all_tests()` (N/A for specification docs)
- [ ] Performance profiling: `PerformanceProfiler.profile_system()` (N/A for specs)
- [ ] Quality gates: `check_quality_gates("combat_spec")` - specification completeness check
- [ ] Checkpoint validation: `validate_checkpoint("combat_spec")` - verify all required fields
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock S04/S09/S10/S11)
- [ ] Create `knowledge-base/` entry if you discovered important design patterns in `knowledge-base/patterns/`

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint(system_id, version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

Create a markdown file: `./combat-specification.md`

## Required Sections

### 1. Combat Overview
- Design philosophy (authentic rhythm combat, skill-based, visually impactful)
- How combat fits into the broader game
- Player experience goals (feel, difficulty, progression)

### 2. Combat Mode Types

#### Real-Time 1v1 Mode
Document these details:
- **Trigger conditions**: When does this mode activate?
- **Participants**: Player + Monster Companion vs 1 Enemy
- **Controls**: Movement, Attack, Dodge, Block, Special Moves, Tools, Item Use
- **Duration**: Expected combat length (30-60 seconds)
- **Rhythm requirements**: Which actions require rhythm? Which get bonuses?
- **Camera**: Fixed, following, zoom level
- **Arena**: Size, boundaries, environmental hazards?
- **Victory conditions**: Specific requirements
- **Loss conditions**: What causes defeat?
- **Flee mechanics**: Can player escape? Success rate?
- **Companion fainting**: What happens if companion goes to 0 HP?

#### Turn-Based 6v6 Mode
Document these details:
- **Trigger conditions**: When does this mode activate?
- **Participants**: 6 Party Members vs 6 Enemy Monsters
- **Turn structure**: Simultaneous or sequential? (Make a decision and justify)
- **Action selection**: How does player choose actions?
- **Rhythm requirements**: Which actions require rhythm? Bonus percentages?
- **Duration**: Expected combat length (3-20 minutes)
- **Switching mechanics**: Can player switch active monster? Cost?
- **Victory conditions**: Specific requirements
- **Loss conditions**: What causes defeat?
- **Flee mechanics**: When is fleeing allowed?

### 3. Mode Selection
- How does player choose between real-time and turn-based?
- Can they change mid-battle?
- Are certain encounters locked to one mode?
- UI for mode selection

### 4. Party System Mechanics

For **Real-Time** mode:
- Active party composition (1 monster companion)
- How to select which companion before battle
- Switching mechanics during battle (timing, cooldown, penalties)
- What happens when companion faints
- Can player summon another companion mid-battle?

For **Turn-Based** mode:
- Active party composition (all 6 monsters)
- Turn order determination (speed stat? initiative rolls? player choice?)
- Switching mechanics (free action or uses turn?)
- Benched monsters (do they exist? healing?)
- Monster order in UI

### 5. Rhythm Integration

Specify for EACH action type:
- **Normal Attack**: Rhythm required? Bonus if timed? Penalty if missed?
- **Special Moves**: Rhythm required? Which beat (downbeat/upbeat)?
- **Dodge**: Rhythm timing windows (perfect/good/miss)
- **Block**: Rhythm timing windows (perfect/good/miss)
- **Item Use**: Rhythm bonuses?
- **Movement**: Affected by rhythm?

Define timing windows precisely:
- Perfect: ±X milliseconds from beat
- Good: ±X milliseconds from beat
- Miss: >X milliseconds from beat

### 6. Stats & Damage Calculation

Define the complete damage formula:
```
Damage = (Base Attack - Defense) × Weapon Modifier × Timing Multiplier × Type Effectiveness × Critical Modifier
```

Specify exact values:
- **Base stats**: Attack, Defense, Special Attack, Special Defense, Speed, HP
- **Weapon modifiers**: How do weapon stats modify damage?
- **Timing multipliers**: Perfect (2.0x?), Good (1.5x?), Miss (1.0x?)
- **Type effectiveness**: Super effective (1.5x?), Not very (0.66x?), Neutral (1.0x)
- **Critical hits**: Chance? Damage multiplier?
- **Equipment bonuses**: How do they apply?
- **Buff/debuff system**: Stacking? Duration? Max stacks?

### 7. Health & Status Systems

#### Health (HP)
- Max HP calculation: Base + Equipment + Level
- HP regeneration: Out of combat? During combat?
- Fainting: What happens at 0 HP?
- Revival: Can monsters be revived mid-combat?

#### Vibe Bar (Color-Shift Health) - S13
- How does Vibe Bar relate to HP?
- Color transitions at what HP thresholds?
- Visual representation

#### Status Effects
Design AT LEAST:
- Burn (damage over time)
- Freeze (skip turns?)
- Poison (damage over time, different from burn?)
- Paralysis (chance to fail action?)
- Sleep (skip turns, wake on damage?)
- Confusion (attack self or ally?)

For each status:
- Duration (turns or seconds?)
- Application chance
- Cure conditions
- Stacking behavior

### 8. Victory & Loss Conditions

For **Real-Time**:
- Victory: Enemy HP reaches 0, defeated on downbeat (specify visual impact)
- Loss: Player HP reaches 0 OR companion HP reaches 0 (OR can player continue alone?)
- Fleeing: Success rate formula (based on speed stat?)
- Rewards: How are they calculated?

For **Turn-Based**:
- Victory: All 6 enemy monsters fainted
- Loss: All 6 party monsters fainted
- Fleeing: Allowed in which situations? Boss battles?
- Rewards: XP distribution, item drops, currency

### 9. Combat State Management

Define state machine:
- **Pre-Combat**: Mode selection, party selection, positioning
- **Combat Active**: Main combat loop
- **Paused**: Can player pause? What options available?
- **Victory**: Transition, rewards screen, XP gain
- **Defeat**: Transition, penalties, respawn location
- **Fled**: Transition, penalties

### 10. AI Behavior (Enemy)

High-level specification (detailed implementation in S11):
- **Attack patterns**: Random? Scripted? Adaptive?
- **Difficulty scaling**: How does AI get smarter?
- **Telegraph system**: How much warning before attacks?
- **Special move usage**: When does AI use special moves?
- **Rhythm compliance**: Does AI follow rhythm? Always perfect timing?

### 11. Combat UI Requirements

Specify UI elements needed:
- Health bars (player, companion, enemy)
- Vibe bar (color-shift health)
- Rhythm indicator (beat visualization)
- Action buttons/prompts
- Damage numbers (floating text)
- Status effect icons
- Turn order indicator (turn-based)
- Combo counter?
- Timing feedback (Perfect/Good/Miss display)
- Victory/defeat screen

### 12. Combat Rewards

Define reward structure:
- **XP gain**: Formula (based on enemy level, performance, rhythm accuracy?)
- **Dual XP system**: Combat XP vs Knowledge XP (S19) - how is it split?
- **Item drops**: Chance percentages, loot tables
- **Currency**: Amount formula
- **Bonuses**: Perfect victory? No damage taken? All rhythm attacks?

### 13. Balancing Considerations

Provide guidelines for:
- Enemy HP scaling (Level 1 vs Level 50)
- Damage scaling (early game vs late game)
- Combat duration targets (how long should average battle last?)
- Difficulty curve (how should challenge increase?)
- Rhythm requirement balance (not too punishing for non-rhythm players)
- Real-time vs turn-based balance (why choose one over the other?)

### 14. Integration Points

Specify how combat integrates with:
- **S01 Conductor**: Which signals to listen for?
- **S02 Controller Input**: Button mapping in combat
- **S04 Combat Prototype**: What to implement first
- **S07 Weapons**: How weapon stats apply
- **S08 Equipment**: How equipment stats apply
- **S09 Dodge/Block**: Timing windows, i-frames
- **S10 Special Moves**: Execution requirements
- **S11 Enemy AI**: Behavior tree integration
- **S12 Monster Database**: Monster stat lookup
- **S13 Color-Shift Health**: Visual feedback
- **S19 Dual XP**: XP type distribution
- **S21 Resonance Alignment**: Does alignment affect combat?

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create the complete combat specification document using the Write tool. This is pure design work.

### Your Tasks:
1. **Create combat-specification.md** using the Write tool
   - Complete specification with all 14 required sections
   - Exact numerical values (no TBDs)
   - Design decisions justified in appendix
   - Integration points documented

2. **Create HANDOFF-combat-spec.md** documenting:
   - That this is a specification document for implementation teams
   - No scene configuration needed
   - Implementation teams (S04, S09, S10, S11) should reference this spec

### Your Deliverables:
- `combat-specification.md` - Complete combat design specification
- `HANDOFF-combat-spec.md` - Instructions for implementation teams

### You Do NOT:
- Create .tscn files (this is pure specification)
- Implement any systems (that's for S04, S09, S10, S11)
- Test in Godot editor (no implementation yet)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-combat-spec.md
2. Read combat-specification.md
3. Use this spec as reference for combat system implementations (S04, S09, S10, S11)
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-combat-spec.md` with this structure:

```markdown
# Combat Specification Handoff

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for Implementation Teams

---

## Files Created (Tier 1 Complete)

### Specification Files
- `combat-specification.md` - Complete combat design (all 14 sections, appendices)

---

## MCP Agent Tasks (Tier 2)

### Primary Task: Reference During Implementation

**No scene configuration needed.** This is a specification document.

Implementation teams should:
1. **Read combat-specification.md** before implementing S04, S09, S10, S11
2. Reference exact numerical values (timing windows, damage formulas, etc.)
3. Follow design decisions documented in Appendix B

---

## Integration Points

### Specification Referenced By:
- **S04** - Combat Prototype (implements core combat loop)
- **S09** - Dodge/Block Mechanics (uses timing windows from spec)
- **S10** - Special Moves (uses rhythm requirements from spec)
- **S11** - Enemy AI (uses behavior guidelines from spec)
- **S13** - Color-Shift Health/Vibe Bar (uses health system from spec)
- **S19** - Dual XP System (uses XP distribution from spec)

### Key Specifications Defined:
- Combat modes (real-time 1v1, turn-based 6v6)
- Timing windows (perfect/good/miss milliseconds)
- Damage calculation formula
- Status effects and durations
- Victory/loss conditions
- Party system mechanics
- Rhythm integration requirements

---

## Verification Checklist (MCP Agent)

After reading specification:

- [ ] Understand both combat modes (real-time and turn-based)
- [ ] Know exact timing windows and damage formulas
- [ ] Understand party system mechanics
- [ ] Ready to implement systems following this spec

---

## Notes

This specification locks in ALL combat design decisions. Implementation teams should NOT deviate from this spec without updating it first.

---

**Next Steps:** Implementation teams should reference this spec during S04, S09, S10, S11 development. Update COORDINATION-DASHBOARD.md to mark combat spec as complete and unblock implementation systems.
```

</handoff_requirements>

<research_phase>

Before writing the specification, research:

1. **Combat system design patterns**
   - Web search: "rhythm game combat mechanics best practices"
   - Web search: "real-time vs turn-based combat design"
   - Study: Crypt of the NecroDancer combat (rhythm-based)
   - Study: Pokemon combat (turn-based party system)
   - Study: Zelda combat (real-time action)

2. **Godot 4.5 combat architecture**
   - Web search: "Godot 4.5 combat system architecture"
   - Web search: "Godot 4.5 state machine combat"
   - Look for performance best practices

3. **Damage calculation systems**
   - Study how Pokemon calculates damage
   - Study how rhythm games reward timing
   - Design a formula that balances stats + skill + rhythm

Make informed decisions, not arbitrary ones. Justify major choices.

</research_phase>

<output>

Generate one markdown file: `./combat-specification.md`

File structure:
```markdown
# Rhythm RPG - Complete Combat Specification
**Version:** 1.0
**Date:** [Current Date]
**Status:** Locked - Ready for Implementation

## Table of Contents
[Auto-generated from sections]

## 1. Combat Overview
[Content]

## 2. Combat Mode Types
[Content with subsections for Real-Time and Turn-Based]

[... all 14 sections ...]

## Appendix A: Quick Reference Tables
- Timing windows (Perfect/Good/Miss milliseconds)
- Damage multipliers (all types)
- Status effect durations
- Stat scaling formulas

## Appendix B: Design Decisions Log
Document key decisions made and WHY:
- Why simultaneous vs sequential turns? (if turn-based)
- Why allow fleeing in real-time but not boss battles?
- Why these specific timing windows?
- etc.
```

Include:
- Clear headings and subheadings
- Tables for numerical values
- Formulas in code blocks
- Justifications for major decisions
- Cross-references to systems (S01, S04, etc.)

</output>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-combat-spec.md, verify:

### Code Quality
- [ ] combat-specification.md created with complete content (no TODOs or placeholders)
- [ ] All 14 required sections are present and comprehensive
- [ ] Numerical values are specified (not "TBD" or placeholders)
- [ ] Damage formula is complete with exact multipliers
- [ ] Timing windows have precise millisecond values
- [ ] Victory/loss conditions are unambiguous
- [ ] Both combat modes are fully specified
- [ ] Design decisions are justified in Appendix B
- [ ] Quick reference tables are complete
- [ ] No contradictions between sections

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Specification follows documentation conventions
- [ ] Design decisions are clearly documented
- [ ] HANDOFF-combat-spec.md created with all required sections
- [ ] Knowledge base entry created if non-trivial combat design patterns documented (in `knowledge-base/patterns/combat-design.md`)

### System-Specific Verification (Specification Creation)
- [ ] Integration points with all 8+ systems are documented
- [ ] Real-time 1v1 mode fully specified
- [ ] Turn-based 6v6 mode fully specified
- [ ] Party system mechanics defined
- [ ] Rhythm integration requirements clear

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Specification Reading
- [ ] Read combat-specification.md and understand all 14 sections
- [ ] Understand combat modes, timing windows, damage formulas
- [ ] Understand party system and rhythm integration
- [ ] Ready to implement S04, S09, S10, S11 following this spec

### Framework Quality Gates (MCP Agent Phase)
- [ ] Quality gates passed: `check_quality_gates("combat_spec")` - completeness and consistency check
- [ ] Checkpoint validated: `validate_checkpoint("combat_spec")` - verify all required fields
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, S04/S09/S10/S11 unblocked
- [ ] Knowledge base entry created: Document any additional patterns discovered

### Implementation Readiness
- [ ] Specification is sufficient for implementation teams to build S04, S09, S10, S11
- [ ] No ambiguity in design decisions
- [ ] Implementation teams can work without clarifying questions

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ combat-specification.md complete with all 14 sections and appendices
- ✅ Exact numerical values specified (no TBDs or placeholders)
- ✅ Design decisions justified in Appendix B
- ✅ HANDOFF-combat-spec.md provides clear instructions for implementation teams
- ✅ Specification is comprehensive, unambiguous, and implementation-ready

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Implementation teams can build S04 Combat Prototype without asking clarifying questions
- ✅ Implementation teams can implement S09 Dodge/Block with exact timing windows
- ✅ Implementation teams can create S10 Special Moves knowing rhythm requirements
- ✅ Implementation teams can design S11 Enemy AI following behavior guidelines
- ✅ All combat systems can be balanced using the formulas provided
- ✅ Specification serves as single source of truth for all combat systems

</success_criteria>

<workflow_guidance>

Recommended approach:

1. **Research Phase** (30% of effort)
   - Study combat systems in similar games
   - Research rhythm game timing mechanics
   - Review Godot combat architecture patterns
   - Take notes on best practices

2. **Design Decisions** (40% of effort)
   - Make concrete choices for all TBD items
   - Define exact numerical values
   - Design the complete damage formula
   - Specify timing windows based on research
   - Choose turn structure (simultaneous vs sequential)
   - Justify all major decisions

3. **Documentation** (25% of effort)
   - Write all 14 sections comprehensively
   - Create reference tables
   - Document integration points
   - Write design decisions log

4. **Verification** (5% of effort)
   - Check for completeness
   - Ensure no contradictions
   - Verify all numbers are specified
   - Test that spec can guide implementation

</workflow_guidance>

<important_notes>

## Critical Requirements

1. **Make Decisions**: Don't leave things as "TBD" or "to be determined later"
2. **Be Specific**: Exact numbers, not ranges or approximations
3. **Justify Choices**: Explain WHY in the design decisions log
4. **Think Integration**: Every decision affects multiple systems
5. **Balance Accessibility**: Rhythm should enhance, not gatekeep gameplay

## Design Philosophy

- **Rhythm is Enhancement**: Non-rhythm players can still win, rhythm players get bonuses
- **Skill Expression**: Player skill should matter more than stats
- **Visual Impact**: Combat should FEEL good (beat-synced effects, satisfying feedback)
- **Progression**: Combat should evolve from simple to complex over the game
- **Choice**: Player chooses real-time vs turn-based based on preference, not enforcement

</important_notes>
