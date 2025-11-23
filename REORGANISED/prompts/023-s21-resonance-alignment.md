<objective>
Implement Resonance Alignment System (S21) - binary Authentic vs Algorithmic alignment affecting enemy behavior, dialogue, loot, combat effectiveness. Visual language: organic vs digital aesthetics.

DEPENDS ON: S04 (Combat), S12 (Monsters), S11 (Enemy AI)
WAVE 2 - Can run in parallel with S20
</objective>

<context>
Resonance Alignment is the thematic core of the game: the duality between authentic human creativity and algorithmic generation. Player choices shift alignment, affecting gameplay.

Reference:
@rhythm-rpg-implementation-guide.md
@vibe-code-philosophy.md @godot-mcp-command-reference.md
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
- [ ] Integration tests: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiling: `PerformanceProfiler.profile_system("S21")`
- [ ] Quality gates: `check_quality_gates("S21")`
- [ ] Checkpoint validation: `validate_checkpoint("S21")`
- [ ] Update `COORDINATION-DASHBOARD.md` (mark complete, release locks, unblock next systems)
- [ ] Create `knowledge-base/` entry if you solved a non-trivial problem

### If Something Goes Wrong
- [ ] Add issue to `KNOWN-ISSUES.md` with [HIGH/MEDIUM/LOW] severity
- [ ] Search `knowledge-base/` for similar issues
- [ ] Consider rollback: `CheckpointManager.rollback_to_checkpoint("S21", version)`
- [ ] Document solution in `knowledge-base/` once fixed

</framework_integration>

<requirements>

## Implementation

### 1. Alignment System
Create `res://systems/resonance_alignment.gd`:
```gdscript
var alignment = 0.0  # -100 (Algorithmic) to +100 (Authentic)

func shift_alignment(amount: float, reason: String):
  alignment = clamp(alignment + amount, -100, 100)
  emit_signal("alignment_changed", alignment, reason)
```

### 2. Alignment Influences

**Combat:**
- Authentic (+50 to +100): Bonus vs Algorithm-type enemies
- Algorithmic (-50 to -100): Bonus vs Authentic-type enemies
- Neutral (-50 to +50): Balanced

**Dialogue:**
- NPCs react differently based on alignment
- Authentic NPCs trust high Authentic players
- Algorithmic NPCs prefer low Authentic players

**Loot:**
- Authentic alignment: Organic items (wood, herbs)
- Algorithmic alignment: Digital items (circuits, code)

**Visual:**
- Authentic: Warm colors, organic shapes, hand-drawn UI
- Algorithmic: Cool colors, geometric shapes, digital UI

### 3. Alignment Shifts
```json
{
  "alignment_shifts": {
    "actions": {
      "help_npc_authentic": 5,
      "use_algorithm_exploit": -10,
      "solve_puzzle_creatively": 3,
      "use_brute_force": -3
    }
  }
}
```

### 4. Type Effectiveness
Extend type system (S12):
- Authentic-aligned attacks: +20% vs Algorithm enemies
- Algorithm-aligned attacks: +20% vs Authentic enemies

### 5. Visual Feedback
- UI border color shifts (orange → blue)
- Alignment meter in pause menu
- Particle effects change based on alignment

### 6. Test Scene
- Alignment shifts from player choices
- Visual changes reflect alignment
- Combat effectiveness varies by alignment

</requirements>

<two_tier_workflow>

## Tier 1: Claude Code Web (You)

Your role is to create all code and data files. Maximize the work done here.

### Your Tasks:
1. **Create all GDScript files** using the Write tool
   - `res://systems/resonance_alignment.gd` - Complete alignment manager with -100 to +100 scale
   - Alignment shift tracking from player actions
   - Combat effectiveness modifiers based on alignment
   - Visual feedback system integration
   - Type hints, documentation, error handling

2. **Create all JSON data files** using the Write tool
   - `res://data/alignment_config.json` - Complete alignment configuration with action shifts and thresholds
   - Valid JSON format with all required fields

3. **Create HANDOFF-S21.md** documenting:
   - Scene structures needed (test scene for alignment shifts and visual feedback)
   - MCP agent tasks (use GDAI tools)
   - Property configurations
   - Testing steps for MCP agent

### Your Deliverables:
- `res://systems/resonance_alignment.gd` - Complete alignment system implementation
- `res://data/alignment_config.json` - Alignment configuration data
- `HANDOFF-S21.md` - Instructions for MCP agent

### You Do NOT:
- Create .tscn files directly (error-prone)
- Use imaginary MCP commands (use Write tool instead)
- Test in Godot editor (MCP agent does this)

## Tier 2: Godot MCP Agent (Handoff)

The MCP agent will:
1. Read your HANDOFF-S21.md
2. Use GDAI tools to configure scenes:
   - `create_scene` - Create test_alignment.tscn
   - `add_node` - Build node hierarchies for test scenes
   - `attach_script` - Connect scripts to nodes
   - `update_property` - Set node properties
3. Test in Godot editor using `play_scene` and `get_godot_errors`
4. Update COORDINATION-DASHBOARD.md with completion status

</two_tier_workflow>

<handoff_requirements>

## HANDOFF.md Template

Create `HANDOFF-S21.md` with this structure:

```markdown
# System S21 Handoff - Resonance Alignment System

**Created by:** Claude Code Web
**Date:** [timestamp]
**Status:** Ready for MCP Agent Configuration

---

## Files Created (Tier 1 Complete)

### GDScript Files
- `res://systems/resonance_alignment.gd` - Alignment manager with -100 to +100 scale, action tracking, combat modifiers

### Data Files
- `res://data/alignment_config.json` - Alignment configuration with action shifts, thresholds, combat modifiers

---

## Scene Configuration Needed (Tier 2 - MCP Agent Tasks)

### Scene 1: `res://tests/test_alignment.tscn`

**MCP Agent Commands:**
```gdscript
# Create test scene
create_scene("res://tests/test_alignment.tscn", "Node2D", "TestAlignment")

# Add UI elements for testing
add_node("TestAlignment", "Label", "AlignmentValue")
add_node("TestAlignment", "Label", "AlignmentType")
add_node("TestAlignment", "ColorRect", "AlignmentVisual")
add_node("TestAlignment", "VBoxContainer", "ActionButtons")
add_node("TestAlignment/ActionButtons", "Button", "HelpNPC")
add_node("TestAlignment/ActionButtons", "Button", "UseExploit")
add_node("TestAlignment/ActionButtons", "Button", "CreativePuzzle")
add_node("TestAlignment/ActionButtons", "Button", "BruteForce")
add_node("TestAlignment", "Label", "CombatEffectiveness")

# Configure properties
update_property("TestAlignment/AlignmentValue", "position", Vector2(10, 10))
update_property("TestAlignment/AlignmentType", "position", Vector2(10, 40))
update_property("TestAlignment/AlignmentVisual", "position", Vector2(400, 100))
update_property("TestAlignment/AlignmentVisual", "size", Vector2(200, 200))
update_property("TestAlignment/ActionButtons", "position", Vector2(10, 100))
update_property("TestAlignment/HelpNPC", "text", "Help NPC (+5 Authentic)")
update_property("TestAlignment/UseExploit", "text", "Use Exploit (-10 Algorithm)")
update_property("TestAlignment/CreativePuzzle", "text", "Creative Puzzle (+3 Authentic)")
update_property("TestAlignment/BruteForce", "text", "Brute Force (-3 Algorithm)")
update_property("TestAlignment/CombatEffectiveness", "position", Vector2(10, 300))
```

**Node Hierarchy:**
```
TestAlignment (Node2D)
├── AlignmentValue (Label)
├── AlignmentType (Label)
├── AlignmentVisual (ColorRect)
├── ActionButtons (VBoxContainer)
│   ├── HelpNPC (Button)
│   ├── UseExploit (Button)
│   ├── CreativePuzzle (Button)
│   └── BruteForce (Button)
└── CombatEffectiveness (Label)
```

---

## Integration Points

### Signals Exposed:
- `alignment_changed(new_alignment: float, reason: String)` - Emitted when alignment shifts
- `alignment_threshold_crossed(threshold_name: String)` - Emitted when alignment crosses major threshold

### Public Methods:
- `shift_alignment(amount: float, reason: String)` - Shift alignment by amount
- `get_alignment() -> float` - Get current alignment value (-100 to +100)
- `get_alignment_type() -> String` - Returns "authentic", "neutral", or "algorithmic"
- `get_combat_modifier(enemy_type: String) -> float` - Get combat effectiveness modifier vs enemy type

### Dependencies:
- Depends on: S04 (Combat), S12 (Monsters), S11 (Enemy AI)
- Depended on by: S22 (NPC dialogue branches), S23 (Story endings)

---

## Testing Checklist (MCP Agent)

After scene configuration, test with:

```gdscript
# Play test scene
play_scene("res://tests/test_alignment.tscn")

# Check for errors
get_godot_errors()

# Verify:
```
- [ ] Alignment shifts from -100 to +100
- [ ] Player choices affect alignment correctly
- [ ] Combat effectiveness varies by alignment (check modifiers)
- [ ] Visual feedback changes (UI color shifts from orange to blue)
- [ ] NPCs react to alignment (dialogue integration ready)
- [ ] Loot tables can vary by alignment (system ready)
- [ ] Type advantages apply correctly (+20% vs opposite type)
- [ ] Integration with S04 Combat works
- [ ] Integration with S11 Enemy AI works
- [ ] Integration with S12 Monster types works
- [ ] alignment_config.json loads correctly

```gdscript
# Stop scene when done
stop_running_scene()
```

---

## Notes / Gotchas

- **Alignment Scale**: -100 (Algorithmic) to +100 (Authentic), 0 is neutral
- **Visual Language**: Organic/warm colors (Authentic) vs Digital/cool colors (Algorithmic)
- **Combat Modifiers**: +20% effectiveness vs opposite alignment type
- **Thematic Core**: This is the central theme of the game - authenticity vs algorithms

---

**Next Steps:** MCP agent should execute all commands above, then update COORDINATION-DASHBOARD.md to mark S21 complete and unblock S22, S23.
```

</handoff_requirements>

<verification>

## Tier 1 Verification (Claude Code Web - You)

Before creating HANDOFF-S21.md, verify:

### Code Quality
- [ ] resonance_alignment.gd created with complete implementation (no TODOs or placeholders)
- [ ] alignment_config.json created with valid JSON (no syntax errors)
- [ ] Type hints used throughout GDScript
- [ ] Documentation comments for public methods/signals
- [ ] Error handling implemented where needed
- [ ] Alignment shift logic implemented (-100 to +100)
- [ ] Combat modifier calculation implemented
- [ ] Visual feedback system hooks implemented
- [ ] Integration with S04, S11, S12 documented

### Framework Quality Gates (Claude Code Web Phase)
- [ ] Files follow project structure conventions (systems/, data/)
- [ ] Code follows GDScript style guide
- [ ] Data schema is complete and validated
- [ ] HANDOFF-S21.md created with all required sections
- [ ] Knowledge base entry created if non-trivial patterns used (in `knowledge-base/patterns/`)

### System-Specific Verification (File Creation)
- [ ] All alignment shifts configurable from alignment_config.json
- [ ] No hardcoded alignment values in resonance_alignment.gd
- [ ] Signal parameters documented
- [ ] Public methods have return type hints
- [ ] Configuration validation logic included

---

## Tier 2 Verification (MCP Agent - Documented in HANDOFF.md)

The MCP agent will verify:

### Scene Configuration
- [ ] test_alignment.tscn created using `create_scene`
- [ ] All test scene nodes added using `add_node`
- [ ] Properties configured using `update_property`

### Framework Quality Gates (MCP Agent Phase)
- [ ] Integration tests passed: `IntegrationTestSuite.run_all_tests()`
- [ ] Performance profiled: `PerformanceProfiler.profile_system("S21")`
- [ ] Quality gates passed: `check_quality_gates("S21")`
- [ ] Checkpoint validated: `validate_checkpoint("S21")`
- [ ] COORDINATION-DASHBOARD.md updated: Status "complete", locks released, dependent systems unblocked
- [ ] Knowledge base entry created if issues solved during testing

### System-Specific Verification (Godot Editor Testing)
- [ ] Test scene runs without errors (use `play_scene` + `get_godot_errors`)
- [ ] Alignment shifts from -100 to +100
- [ ] Player choices affect alignment correctly
- [ ] Combat effectiveness varies by alignment (check modifiers)
- [ ] Visual feedback changes (UI color shifts)
- [ ] NPCs can react to alignment (dialogue integration ready)
- [ ] Loot tables can vary by alignment (system ready)
- [ ] Type advantages apply correctly (+20% vs opposite type)
- [ ] Integration with S04 Combat works
- [ ] Integration with S11 Enemy AI works
- [ ] Integration with S12 Monster types works
- [ ] alignment_config.json loads correctly

</verification>

<success_criteria>

## Tier 1 Success (Claude Code Web):
- ✅ resonance_alignment.gd complete with -100 to +100 alignment scale
- ✅ alignment_config.json complete with all action shifts and thresholds
- ✅ Combat modifier logic implemented based on alignment
- ✅ Visual feedback hooks implemented
- ✅ All code documented with type hints and comments
- ✅ HANDOFF-S21.md provides clear MCP agent instructions
- ✅ All alignment data configurable from JSON (no hardcoding)

## Tier 2 Success (MCP Agent - in HANDOFF.md):
- ✅ Test scene configured correctly in Godot editor
- ✅ Alignment system tracks player choices accurately
- ✅ Visual language shifts between organic (Authentic) and digital (Algorithmic)
- ✅ Combat effectiveness varies correctly by alignment (+20% vs opposite type)
- ✅ NPCs can react to player alignment (ready for S22 dialogue branches)
- ✅ Loot tables can vary by alignment (system ready)
- ✅ Integrates with S04 Combat for type effectiveness
- ✅ Integrates with S11 Enemy AI for behavior changes
- ✅ Integrates with S12 Monster types for alignment matching
- ✅ System ready for S22 (NPC dialogue) and S23 (Story endings)

This system is the thematic core of the game - the duality between authenticity and algorithms.

</success_criteria>

<memory_checkpoint_format>
```
System S21 (Resonance Alignment) Complete

FILES:
- res://systems/resonance_alignment.gd
- res://data/alignment_config.json

ALIGNMENT RANGE: -100 (Algorithmic) to +100 (Authentic)

AFFECTS:
- Combat effectiveness (+20% vs opposite type)
- NPC dialogue branches
- Loot tables (organic vs digital items)
- Visual language (UI colors, particles)

ALIGNMENT SHIFTS:
- Help NPC: +5
- Use exploit: -10
- Creative puzzle: +3
- Brute force: -3

STATUS: Ready for S22 (NPC dialogue uses alignment)
```
</memory_checkpoint_format>
