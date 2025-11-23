# Checkpoint: Performance Profiler

## Component: Performance Profiler
## Agent: F2
## Date: 2025-11-18
## Duration: 1.5 hours

### What Was Built

**Files:**
- `tests/performance/performance_profiler.gd` (~410 lines)
- `tests/performance/profile_helper.gd` (~50 lines)

**Purpose:** Track and report performance metrics for all game systems

### Key Features

1. **Frame time tracking** - Monitors 60 FPS target (16.67ms)
2. **Per-system profiling** - 1ms budget per system
3. **Memory monitoring** - Tracks static memory usage
4. **Beat timing accuracy** - Rhythm-specific performance
5. **SystemProfile class** - Detailed per-system statistics
6. **Performance warnings** - Signal-based alerts for threshold breaches
7. **Report generation** - Formatted markdown reports
8. **ProfileHelper** - Easy integration for system agents

### Research Findings

**Godot 4.5 Performance:**
- [Godot Docs - The Profiler](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html) - Built-in profiler features
- [GDQuest - Measuring Code Performances](https://www.gdquest.com/tutorial/godot/gdscript/optimization-measure/) - Custom timer best practices
- [Godot Forum - Monitor RAM Usage](https://forum.godotengine.org/t/monitor-ram-usage/42578) - Memory profiling techniques
- [Game Dev SE - Rhythm Game Accuracy](https://gamedev.stackexchange.com/questions/2972/accuracy-and-frame-rate-in-a-rhythm-game) - Performance budgets for rhythm games

### Design Decisions

**Performance budgets:**
- 16.67ms frame time (60 FPS target)
- 1ms per system (allows 16 systems comfortably)
- 512MB memory warning threshold
- 5ms beat timing tolerance

**Why track beat timing:**
- Rhythm games need tight timing
- <5ms error keeps feel responsive
- Helps identify audio/input lag issues
- Human perception threshold is 15-20ms for "off beat" detection

**Godot 4.5 Specifics:**
- Performance.get_monitor() for memory tracking
- Time.get_ticks_usec() for microsecond precision
- Signal-based warnings for reactive monitoring
- Typed arrays (Array[float], Array[int])

### How System Agents Should Use This

**Easy method (recommended):**
```gdscript
extends Node

func _process(delta: float) -> void:
    ProfileHelper.start("S05_Inventory")

    # Your system logic here
    _update_inventory()

    ProfileHelper.end("S05_Inventory")

func _ready() -> void:
    # Print report after 10 seconds
    await get_tree().create_timer(10.0).timeout
    ProfileHelper.report()
```

**Manual method:**
```gdscript
var profiler = PerformanceProfiler.new()
profiler.start_profiling()

var start_time = Time.get_ticks_usec()
_do_work()
var end_time = Time.get_ticks_usec()
var duration_ms = (end_time - start_time) / 1000.0

profiler.profile_system("MySystem", duration_ms)
```

### Integration with Other Framework Components

- **Integration Tests:** Can measure test execution performance
- **CI Runner:** Generate performance reports in CI
- **Quality Gates:** Performance could be a quality dimension (future)
- **Coordination Dashboard:** Show live performance stats (future)

### Files Created

- `tests/performance/performance_profiler.gd`
- `tests/performance/profile_helper.gd`
- `research/framework-performance-profiler-research.md`

### Output Files

Generated reports:
- `performance-report.md`

### Git Commit

```bash
git add tests/performance/ research/ checkpoints/
git commit -m "Add Performance Profiler framework component

- Frame time tracking with 60 FPS target
- Per-system profiling with 1ms budget
- Memory usage monitoring
- Beat timing accuracy tracking
- SystemProfile class for detailed stats
- ProfileHelper for easy integration
- Markdown report generation

Research: Godot 4.5 performance monitoring, rhythm game budgets
Duration: 1.5 hours"
```

### Status

✅ Integration Test Suite: **COMPLETE**
✅ Quality Gates: **COMPLETE**
✅ Checkpoint Validation: **COMPLETE**
✅ CI Test Runner: **COMPLETE**
✅ Performance Profiler: **COMPLETE**
⬜ Coordination Dashboard: **NEXT**

### Autoload Registration Note

**CRITICAL:** The PerformanceProfiler requires autoload registration in Godot Project Settings.

This is a **Tier 2 task** for the Godot MCP agent.

**Required autoload:**
- `PerformanceProfiler` → `res://tests/performance/performance_profiler.gd`

See FRAMEWORK-SETUP-GUIDE.md lines 98-297 for detailed autoload registration instructions.

This will be documented in the final HANDOFF-FRAMEWORK-F2.md for the MCP agent to complete.
