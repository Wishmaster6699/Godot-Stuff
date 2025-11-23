# Development Guide - Rhythm RPG
**Comprehensive Workflow for Human and AI Developers**
**Last Updated:** 2025-11-18

---

## Table of Contents
1. [Project Philosophy](#project-philosophy)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Testing Protocols](#testing-protocols)
5. [Integration Guidelines](#integration-guidelines)
6. [Common Workflows](#common-workflows)

---

## Project Philosophy

### Research → MCP → Verify → Checkpoint

This is the core workflow for ALL development on this project.

**1. Research First**
- Web search for Godot 4.5 best practices (November 2025)
- Never code from cached knowledge
- Document findings in research/[system]-research.md

**2. MCP as Primary Tool**
- Use Godot MCP/GDAI commands for scene work
- MCP is not a fallback - it's the main tool
- See vibe-code-philosophy.md for details

**3. Verify Everything**
- Test via play_scene()
- Check get_godot_errors()
- Run integration tests
- Never assume it works

**4. Checkpoint Progress**
- Save checkpoints after each system
- Document decisions and patterns
- Enable future agents to continue work

**Full Philosophy:** See `/vibe-code-philosophy.md` (REQUIRED READING)

---

## Getting Started

### Environment Setup (Tier 2 - MCP Work)
1. Install Godot 4.5.1
2. Install Godot MCP server
3. Clone repository: `git clone [repo-url]`
4. Checkout branch: `claude/read-prompt-01WSWeCekRXhsSms7wbKCSaU`
5. Open project in Godot

### File Structure Overview
```
vibe-code-game/
├── src/systems/        # System implementations (20 systems)
├── res/                # Autoloads, resources, data
├── data/               # JSON configuration files
├── checkpoints/        # System completion records
├── research/           # Research documentation
├── knowledge-base/     # Developer documentation
└── HANDOFF-*.md        # Tier 1 → Tier 2 instructions
```

### Read First
1. `/AGENT-QUICKSTART.md` (5 min)
2. `/vibe-code-philosophy.md` (10 min)
3. `/SYSTEM-REGISTRY.md` (browse, don't memorize)
4. `/ARCHITECTURE-OVERVIEW.md` (understand design)

---

## Development Workflow

### Tier 1 Workflow (Scripts & Data - Complete)
All Tier 1 work is COMPLETE. All .gd scripts and .json data files exist.

### Tier 2 Workflow (Scene Configuration - Pending)

**Step 1: Read HANDOFF Document**
```bash
# Find relevant HANDOFF file
ls HANDOFF-*.md

# Read instructions
Read HANDOFF-S##.md
```

**Step 2: Research (15-20 min)**
```
Search: "Godot 4.5 [scene type] best practices 2025"
Search: "Godot 4.5 [node type] properties"
Document: Save URLs and key findings
```

**Step 3: Create Scene with MCP**
```python
# Create scene
create_scene("res://scenes/player.tscn", "CharacterBody2D")

# Add child nodes
add_node(".", "Sprite2D", "PlayerSprite")
add_node(".", "CollisionShape2D", "Collision")

# Attach script
attach_script(".", "res://src/systems/s03-player/player_controller.gd")

# Set properties
update_property("PlayerSprite", "texture", "res://assets/player.png")
```

**Step 4: Test Scene**
```python
# Run scene
play_scene("res://scenes/player.tscn")

# Check errors
errors = get_godot_errors()
if errors:
    # Fix issues
    # Re-test

# Visual check
screenshot = get_running_scene_screenshot()

# Stop scene
stop_running_scene()
```

**Step 5: Integration Tests**
```gdscript
# In Godot console or test scene
var suite = IntegrationTestSuite.new()
var results = suite.run_all_tests()
print(results.summary())
```

**Step 6: Performance Profile**
```gdscript
var profiler = PerformanceProfiler.new()
var metrics = profiler.profile_system("S##")
# Target: <1ms per frame
```

**Step 7: Quality Gates**
```gdscript
var gates = QualityGateChecker.new()
var score = gates.check_system("S##")
# Must be ≥80/100
```

**Step 8: Checkpoint**
Create `checkpoints/s##-system-checkpoint.md`:
```markdown
## System: S## - [Name]
## Completed: 2025-11-18
## Status: ✅ Complete

### Files Created
- res://scenes/system.tscn
- All nodes configured

### Testing Results
- Integration tests: PASS
- Performance: 0.5ms/frame
- Quality gates: 85/100

### Known Issues
- None

### Next Steps
- System ready for use
```

---

## Testing Protocols

### Unit Testing (Per System)
- Test core functionality in isolation
- Use test scenes: `res://tests/test_s##_*.tscn`
- Verify expected behavior

### Integration Testing
```gdscript
# Test system interactions
IntegrationTestSuite.run_all_tests()

# Expected results:
# - All tests pass
# - No errors in console
# - Performance within budget
```

### Performance Testing
```gdscript
# Profile system
PerformanceProfiler.profile_system("S##")

# Targets:
# - <1ms per frame per system
# - <0.01ms for Conductor (rhythm-critical)
# - No memory leaks
```

### Manual Testing Checklist
- [ ] Scene loads without errors
- [ ] Visual appearance correct
- [ ] Gameplay mechanics work as expected
- [ ] Signals connect properly
- [ ] No console warnings
- [ ] Performance acceptable (60 FPS maintained)

---

## Integration Guidelines

### Before Modifying Any System

1. **Check Dependencies**
   - What systems depend on this? (See SYSTEM-REGISTRY.md)
   - What does this depend on?
   - What will break if I change this?

2. **Review Integration Points**
   - Signals: What listens to this system's signals?
   - Autoloads: Is this accessed globally?
   - Data: What JSON files are involved?

3. **Plan Testing**
   - How will I verify this works?
   - What integration tests need to run?
   - What edge cases should I check?

### After Making Changes

1. **Test Direct Functionality**
   - Does the modified system still work?
   - Test all features, not just changes

2. **Test Integration**
   - Run integration test suite
   - Manually test dependent systems
   - Check for regressions

3. **Performance Check**
   - Profile modified system
   - Ensure frame budget not exceeded
   - Check for memory leaks

4. **Documentation**
   - Update HANDOFF if needed
   - Update checkpoint
   - Note any breaking changes

---

## Common Workflows

### Workflow 1: Add New Content (No Code Changes)

**Example: Add a new monster**

1. Edit JSON file:
```bash
# Edit data file
vim res/data/monsters.json
```

2. Add entry:
```json
{
  "monster_id": "shadow_wolf",
  "name": "Shadow Wolf",
  "stats": {"hp": 80, "attack": 35, "defense": 20, "speed": 40},
  "type": "dark",
  "ai_type": "aggressive",
  "loot_table": [{"item_id": "shadow_fang", "chance": 0.3}]
}
```

3. Test:
   - Load game
   - Spawn monster
   - Verify stats
   - Confirm loot drops

4. Commit:
```bash
git add res/data/monsters.json
git commit -m "Add Shadow Wolf monster

- HP: 80, ATK: 35, DEF: 20, SPD: 40
- Dark type, aggressive AI
- Drops shadow_fang (30% chance)"
```

**Time Estimate:** 15-30 minutes

---

### Workflow 2: Modify Existing System

**Example: Adjust combat damage formula**

1. **Research** (if needed):
   - Review combat-specification.md
   - Check similar games' formulas

2. **Locate Code**:
```bash
# Find damage calculation
grep -r "calculate_damage" src/systems/s04-combat/
```

3. **Read Current Implementation**:
```bash
Read src/systems/s04-combat/combatant.gd
# Find calculate_damage() function
```

4. **Make Changes**:
```bash
Edit src/systems/s04-combat/combatant.gd
# Modify damage formula
```

5. **Test Thoroughly**:
   - Create test combat scenario
   - Verify damage values
   - Check edge cases (0 defense, max stats, etc.)
   - Run integration tests

6. **Document**:
```bash
# Update checkpoint
Edit checkpoints/s04-combat-checkpoint.md
# Note formula change
```

7. **Commit**:
```bash
git add src/systems/s04-combat/combatant.gd checkpoints/
git commit -m "Adjust combat damage formula

Changed base formula from:
  damage = (power * (atk/def) * (level/5) + 2) * timing
To:
  damage = (power * (atk/def) * (level/10) + 5) * timing

Reduces early-game damage spikes while maintaining late-game scaling.

Tested: All combat scenarios pass, integration tests green."
```

**Time Estimate:** 1-3 hours

---

### Workflow 3: Create New System (S27+)

1. **Plan System**:
   - Define purpose and scope
   - Identify dependencies
   - Design integration points

2. **Research**:
```bash
# Search for similar systems
# Document findings
Write research/s27-[system-name]-research.md
```

3. **Create Directory Structure**:
```bash
mkdir -p src/systems/s27-system-name
```

4. **Implement Core Logic** (Tier 1):
```bash
# Create manager script
Write src/systems/s27-system-name/system_manager.gd

# Create configuration
Write data/system_config.json

# Create test script
Write src/systems/s27-system-name/test_system.gd
```

5. **Write HANDOFF**:
```bash
Write HANDOFF-S27.md
# Include:
# - Scene structure
# - MCP commands
# - Property configurations
# - Testing checklist
```

6. **Register with Systems** (if persistent):
```gdscript
# In _ready():
SaveManager.register_system("s27_system", self)
```

7. **Test** (Tier 2):
   - Create scenes via MCP
   - Run integration tests
   - Performance profile
   - Quality gates

8. **Document**:
```bash
# Update registry
Edit SYSTEM-REGISTRY.md
# Add S27 entry

# Create checkpoint
Write checkpoints/s27-system-checkpoint.md

# Update architecture
Edit ARCHITECTURE-OVERVIEW.md
# Add to dependency map
```

9. **Commit**:
```bash
git add src/systems/s27-* data/ HANDOFF-S27.md checkpoints/ SYSTEM-REGISTRY.md
git commit -m "Implement S27 - [System Name]

Complete Tier 1 implementation:
- Core logic in system_manager.gd
- Configuration in data/system_config.json
- Test scripts created
- HANDOFF documentation for Tier 2

Dependencies: [List]
Blocks: [List]
Integration points: [List]

Ready for Tier 2 scene configuration."
```

**Time Estimate:** 1 day (Tier 1) + 4 hours (Tier 2)

---

## Git Workflow

### Branch Strategy
- Main branch: (preserved)
- Development branch: `claude/read-prompt-01WSWeCekRXhsSms7wbKCSaU`
- All work happens on designated branch

### Commit Messages
```
[Short summary - imperative mood]

[Detailed description]
- Bullet point 1
- Bullet point 2

[Testing/verification notes]
```

**Example:**
```
Add fire-based special moves

Implemented three new special moves:
- Flame Strike: 3x damage, fire DoT effect
- Inferno Blast: AoE attack, burns enemies
- Phoenix Rising: Self-heal + fire shield

Tested: All moves work correctly in combat
Integration: Connects to S10 special moves system
Balance: Costs scale with power (20-50 resource)
```

### When to Commit
- ✅ After completing a feature
- ✅ After fixing a bug
- ✅ After successful testing
- ✅ Before starting risky changes (safety commit)
- ❌ Don't commit broken code
- ❌ Don't commit untested changes

### Push Strategy
```bash
# Always push to designated branch
git push -u origin claude/read-prompt-01WSWeCekRXhsSms7wbKCSaU
```

---

## Troubleshooting

### "Scene won't load"
1. Check get_godot_errors()
2. Verify all scripts exist
3. Check node paths
4. Ensure resources exist

### "Signal not working"
1. Verify signal declaration: `signal signal_name(params)`
2. Check connection: `signal_name.connect(callable)`
3. Confirm emit: `signal_name.emit(args)`
4. Check if connection still alive (not freed)

### "Performance issues"
1. Profile system: `PerformanceProfiler.profile_system("S##")`
2. Check for infinite loops
3. Optimize update frequency (_process vs _physics_process)
4. Use object pooling for frequently instantiated objects

### "Integration test failures"
1. Run individual tests to isolate
2. Check recent changes to involved systems
3. Verify dependencies haven't changed
4. Check for timing issues (async operations)

---

## Best Practices Summary

### DO:
- ✅ Research Godot 4.5 practices before coding
- ✅ Use MCP for scene work
- ✅ Test thoroughly before committing
- ✅ Document decisions in checkpoints
- ✅ Use type hints throughout
- ✅ Follow existing patterns
- ✅ Keep JSON for data, code for logic
- ✅ Disconnect signals when done

### DON'T:
- ❌ Use Godot 3.x deprecated code
- ❌ Hardcode game data in scripts
- ❌ Commit untested changes
- ❌ Modify systems without checking dependencies
- ❌ Skip integration testing
- ❌ Assume scene structures without verifying
- ❌ Forget to update documentation

---

## Quick Reference

### File Locations
- Systems: `src/systems/s##-system-name/`
- Autoloads: `res/autoloads/`
- Data: `data/` and `res/data/`
- Scenes: `res/scenes/` (Tier 2)
- Tests: `res/tests/` and `tests/`

### Key Documents
- Quick start: `/AGENT-QUICKSTART.md`
- System catalog: `/SYSTEM-REGISTRY.md`
- Architecture: `/ARCHITECTURE-OVERVIEW.md`
- Philosophy: `/vibe-code-philosophy.md`
- This guide: `/DEVELOPMENT-GUIDE.md`

### Common Commands
```bash
# Search for code
grep -r "pattern" src/

# Find files
find . -name "*.json"

# Test JSON
python3 -m json.tool data/file.json

# Git status
git status
```

---

**End of Development Guide**

**Remember: Research → MCP → Verify → Checkpoint**
