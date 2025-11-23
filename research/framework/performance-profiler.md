# Performance Profiler Research
## Agent: F2
## Date: 2025-11-18
## Duration: 45 minutes

## Research Goal
Understand Godot 4.5 performance profiling, frame time measurement, memory monitoring, and rhythm game-specific performance requirements to build a comprehensive performance profiler for the Rhythm RPG framework.

---

## Search Queries Performed

1. "Godot 4.5 performance profiling techniques"
2. "GDScript 4.5 frame time measurement best practices"
3. "Godot performance monitoring memory profiling"
4. "rhythm game performance budgets FPS targets"

---

## Key Findings

### 1. Godot Built-in Profiler

**Source:** [Godot Documentation - The Profiler](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html)

**Key Features:**
- Built-in profiler in Godot IDE (Debugger tab)
- Must be manually started/stopped (recording adds overhead)
- Multiple profiling tabs: Monitor, Network Profiler, Video RAM, Frame Time
- Real-time statistics on CPU, memory, nodes, objects, resources

**Profiler Tabs:**
- **Monitor Tab:** Shows CPU/memory usage, node/object/resource counts
  - Subtabs: Script, Rendering, Audio, Physics
- **Video RAM Tab:** Tracks textures, materials, shaders, meshes
- **Frame Time:** Measures execution time for entire frame (physics to rendering)

**Important Metrics:**
- Frame time (total time for one frame)
- Physics frame time
- Idle time
- Physics time

### 2. Frame Time Measurement in GDScript

**Source:** [GDQuest - Measuring Code Performances](https://www.gdquest.com/tutorial/godot/gdscript/optimization-measure/)

**Best Practices:**

**Using `delta` parameter:**
- `_process(delta)` - delta is elapsed time since last frame (seconds)
- At 60 FPS: delta ≈ 0.0167 seconds (16.67ms)
- Useful for frame-to-frame measurements

**Performance Singleton:**
```gdscript
Performance.get_monitor(Performance.TIME_PROCESS)
Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
```
- **Limitation:** Only updated once per second
- Not suitable for real-time frame measurements

**Custom Timers (RECOMMENDED):**
```gdscript
var start_time = Time.get_ticks_usec()
# ... code to profile ...
var end_time = Time.get_ticks_usec()
var duration_ms = (end_time - start_time) / 1000.0
```
- Microsecond precision with `Time.get_ticks_usec()`
- Convert to milliseconds for readability
- Best for measuring specific code sections

**VSync Considerations:**
- When VSync enabled: delta returns clamped time (exactly 1/60s at 60 FPS)
- Measurements include VSync wait time
- Challenge: Hard to measure actual render time vs VSync wait

### 3. Memory Profiling

**Source:** [Godot Forum - Monitor RAM Usage](https://forum.godotengine.org/t/monitor-ram-usage/42578)

**Available Memory Monitors:**
```gdscript
Performance.get_monitor(Performance.MEMORY_STATIC)        # Static memory allocated
Performance.get_monitor(Performance.MEMORY_STATIC_MAX)    # Peak static memory
Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)
```

**Monitor Tab Features:**
- Real-time CPU and memory usage
- Node/object/resource statistics
- Can export data to CSV for analysis

**Video RAM Monitoring:**
- Tracks textures, materials, shaders, meshes
- Identifies largest/most duplicated resources
- Critical for graphics optimization

**Limitations:**
- No GDScript-level memory debugging (leaks, allocations, zombies)
- System tools lack visibility into GDScript objects
- Platform-specific tools needed for deep profiling

**Memory Optimization Tips:**
- Monitor allocation and deallocation patterns
- Identify memory leaks
- Reuse objects instead of frequent allocation
- Limit allocations in hot paths

### 4. Rhythm Game Performance Requirements

**Source:** [Game Development Stack Exchange - Rhythm Game Accuracy](https://gamedev.stackexchange.com/questions/2972/accuracy-and-frame-rate-in-a-rhythm-game)

**Critical Timing Windows:**

**Human Perception Threshold:**
- **15-20ms:** Threshold where humans detect audio as "off beat"
- **Sub-20ms:** Required for tight, responsive rhythm gameplay
- This is our **CRITICAL CONSTRAINT**

**Frame Rate Implications:**
- **60 FPS:** 16.67ms per frame (TIGHT but workable)
- **30 FPS:** 33.33ms per frame (TOO SLOW for rhythm games)
- **120+ FPS:** 8.33ms or less (IDEAL for competitive rhythm games)

**Performance Budget Breakdown (60 FPS):**
- Total budget: 16.67ms
- Audio timing tolerance: <5ms (to stay well under 15ms threshold)
- Remaining for game logic: ~11-12ms
- Per-system budget: 1ms (assuming 10-12 active systems)

**Input Lag Considerations:**
- Monitor latency: 15-30ms (common LCD)
- Input processing: Variable
- Audio buffer: Configurable (lower = less lag, more CPU)
- **Total system lag must stay under 50ms for "good" feel**

**Player Hardware:**
- Competitive rhythm players use 240Hz monitors (4.17ms per frame)
- Lowest possible input lag critical
- High refresh rates improve reaction timing accuracy

**Android/Mobile Challenges:**
- Often limited to 30 FPS (battery saving)
- 33ms frame time leaves minimal margin (only 18ms with 15ms tolerance)
- Requires aggressive optimization

### 5. Performance Budgets for This Project

Based on research, here are recommended budgets:

**Frame Time:**
- **Target:** 16.67ms (60 FPS)
- **Warning threshold:** 16.67ms
- **Critical threshold:** 20ms (below 50 FPS)

**Per-System Time:**
- **Target:** 0.5ms per system
- **Warning threshold:** 1.0ms per system
- **Critical threshold:** 2.0ms per system
- **Reasoning:** With 26 systems, need tight budgets (26 × 0.5ms = 13ms, leaves 3.67ms for engine/rendering)

**Memory:**
- **Warning threshold:** 512MB
- **Critical threshold:** 1GB
- **Reasoning:** Keep memory usage reasonable for mid-range devices

**Beat Timing Accuracy:**
- **Target:** <3ms error
- **Warning threshold:** 5ms error
- **Critical threshold:** 10ms error
- **Reasoning:** Stay well under 15ms human perception threshold

---

## Design Decisions for Performance Profiler

### 1. Use Custom Timers
- `Time.get_ticks_usec()` for microsecond precision
- Convert to milliseconds for readability
- Better than Performance singleton (only updates per second)

### 2. Track Multiple Metrics
- **Frame time:** Overall performance (60 FPS target)
- **Per-system time:** Identify bottleneck systems
- **Memory usage:** Detect memory leaks/spikes
- **Beat timing:** Rhythm-specific accuracy

### 3. Signal-Based Warnings
- Emit signals when thresholds exceeded
- Allows reactive monitoring (e.g., UI warnings, logging)
- Keeps profiler decoupled from reporting mechanism

### 4. Markdown Report Generation
- Human-readable format
- Easy to commit to git for history
- Can be reviewed in PRs

### 5. ProfileHelper Static Class
- Easy integration for system agents
- Simple API: `ProfileHelper.start(name)` / `ProfileHelper.end(name)`
- No need for each system to manage profiler instance

---

## Implementation Approach

### Core Classes

**PerformanceProfiler (Main Class):**
```gdscript
class_name PerformanceProfiler
- start_profiling() / stop_profiling()
- profile_system(name, time_ms)
- profile_frame(time_ms)
- profile_memory()
- profile_beat_timing(error_ms)
- generate_report() -> String
- save_report(path)
```

**SystemProfile (Data Class):**
```gdscript
class SystemProfile:
- system_name: String
- total_time_ms: float
- avg_time_ms: float
- max_time_ms: float
- min_time_ms: float
- sample_count: int
- warnings: Array[String]
```

**ProfileHelper (Static Helper):**
```gdscript
class ProfileHelper:
- static start(system_name)
- static end(system_name)
- static report()
- static save(path)
```

### Godot 4.5 Specific APIs

**Time:**
- `Time.get_ticks_usec()` - Microsecond precision
- `Time.get_ticks_msec()` - Millisecond precision

**Performance:**
- `Performance.get_monitor(Performance.MEMORY_STATIC)` - Static memory

**Arrays:**
- Typed arrays: `Array[float]`, `Array[int]`, `Array[String]`
- Better performance and type safety

---

## Integration with Framework

### With Other Framework Components

**Integration Tests:**
- Measure test execution performance
- Identify slow tests

**CI Runner:**
- Generate performance reports in CI
- Track performance over time
- Fail CI if performance regresses

**Quality Gates:**
- Could add performance as quality dimension
- e.g., "System must average <1ms per frame"

**Coordination Dashboard:**
- Could show live performance metrics
- Highlight performance bottlenecks

### System Agent Usage

**Easy Integration:**
```gdscript
extends Node

func _process(delta: float) -> void:
    ProfileHelper.start("S05_Inventory")

    # System logic here
    _update_inventory()

    ProfileHelper.end("S05_Inventory")
```

**Generate Reports:**
```gdscript
# After 10 seconds of gameplay
ProfileHelper.report()  # Print to console
ProfileHelper.save("performance-report.md")  # Save to file
```

---

## Potential Issues & Mitigations

### Issue 1: Profiling Overhead
**Problem:** Profiling itself adds overhead
**Mitigation:**
- Only auto-enable in debug builds
- Allow manual start/stop
- Keep tracking code minimal

### Issue 2: VSync Skewing Results
**Problem:** VSync wait time included in measurements
**Mitigation:**
- Document limitation
- Focus on relative performance (system A vs system B)
- Consider disabling VSync for profiling sessions

### Issue 3: Memory Measurements Lag
**Problem:** Performance monitors update slowly
**Mitigation:**
- Sample memory periodically (not every frame)
- Track trends over time vs instantaneous values

### Issue 4: Too Much Data
**Problem:** Storing 1000s of samples uses memory
**Mitigation:**
- Limit sample arrays (1000 frames, 100 memory samples, 500 beat samples)
- Use rolling buffers (pop_front when full)

---

## Success Metrics

**This profiler is successful if:**
1. ✅ System agents can easily integrate with ProfileHelper
2. ✅ Reports clearly identify performance bottlenecks
3. ✅ Beat timing accuracy tracked to sub-5ms
4. ✅ Memory leaks detectable through memory tracking
5. ✅ Overhead of profiling is minimal (<0.5ms per frame)

---

## References

### Documentation
- [Godot Docs - The Profiler](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html)
- [Godot Docs - Performance](https://docs.godotengine.org/en/stable/tutorials/performance/index.html)
- [Godot Docs - CPU Optimization](https://github.com/godotengine/godot-docs/blob/master/tutorials/performance/cpu_optimization.rst)

### Tutorials & Articles
- [GDQuest - Measuring Code Performances](https://www.gdquest.com/tutorial/godot/gdscript/optimization-measure/)
- [LinkedIn - Using Godot's Profiler](https://www.linkedin.com/advice/3/how-can-you-use-godots-profiler-identify-game-performance)
- [Toxigon - Mastering the Profiler in Godot](https://toxigon.com/mastering-the-profiler-in-godot)

### Community Discussions
- [Godot Forum - Monitor RAM Usage](https://forum.godotengine.org/t/monitor-ram-usage/42578)
- [Game Dev SE - Rhythm Game Accuracy](https://gamedev.stackexchange.com/questions/2972/accuracy-and-frame-rate-in-a-rhythm-game)
- [GitHub - GDScript Performance Tests](https://github.com/Zylann/gdscript_performance)

---

## Next Steps

1. ✅ Research complete
2. ⬜ Implement `tests/performance/performance_profiler.gd`
3. ⬜ Implement `tests/performance/profile_helper.gd`
4. ⬜ Create checkpoint document
5. ⬜ Test with sample system integration

---

**Research Status:** COMPLETE ✅
**Ready for Implementation:** YES ✅
