# Research: Integration Test Suite for Godot 4.5

**Date:** 2025-11-18
**Component:** Framework Component 1
**Agent:** F1

## Research Questions

1. What testing frameworks are available for Godot 4.5?
2. How do integration tests work in GDScript 4.5?
3. What assert functions are available?
4. How can tests be integrated with signals?

## Findings

### GUT (Godot Unit Test)

**Version:** 9.x for Godot 4.x
**Repository:** https://github.com/bitwes/Gut
**Documentation:** https://gut.readthedocs.io/

**Key Features:**
- Write tests for gdscript in gdscript
- Signal-based assertions via `watch_signals()`
- Compatible with Godot 4.5
- CI/CD integration support
- Headless mode compatible

**Assert Functions:**
- `assert_eq()` - equality assertions
- `assert_signal_emitted()` - verify signal emissions
- `assert_called()` - verify function calls on mocks
- `assert_call_count()` - verify call counts
- `assert_gt()`, `assert_lt()` - comparison assertions

**Installation:**
Available in Godot Asset Library as "GUT - Godot Unit Testing (Godot 4)"

### gdUnit4

**Repository:** https://github.com/MikeSchulze/gdUnit4
**Features:**
- Embedded unit testing framework
- Supports GDScript and C#
- Test-driven development support
- Scene testing capabilities
- Extensive assertions with fluent syntax
- Built-in mocking

**Example Syntax:**
```gdscript
extends GdUnitTestSuite

func test_example():
    assert_str("hello").has_length(5).starts_with("h")
```

### Native Godot 4.5 Testing Capabilities

**Built-in Features:**
- `Time.get_ticks_usec()` for precise timing
- Signal connection and await for async testing
- FileAccess API for file-based testing
- DirAccess for directory operations

**GDScript 4.5 Syntax:**
- `await` for async operations (replaces yield)
- Type hints required for all function parameters
- `class_name` for global class registration
- Typed arrays: `Array[String]`, `Array[Dictionary]`

## Design Decisions for Integration Test Suite

### Framework Choice: Custom Implementation

**Rationale:**
- No external dependencies required
- Full control over test format
- Lightweight for CI/CD
- Easy for system agents to extend
- Works with existing Godot 4.5 features

### Signal-Based Testing

**Approach:**
```gdscript
var signal_emitted := false
conductor.beat.connect(func(_beat_num): signal_emitted = true)
await get_tree().create_timer(1.1).timeout
if not signal_emitted:
    return {"passed": false, "error": "Signal not emitted"}
```

**Benefits:**
- Tests actual system behavior
- Validates integration points
- Async-friendly

### Test Result Format

**Dictionary-based results:**
```gdscript
{"passed": bool, "error": String}
```

**Rationale:**
- Simple to implement
- Flexible error messaging
- Easy to aggregate results
- JSON-serializable for CI

## CI/CD Integration Research

### Headless Testing

**Required flags:**
```bash
godot --headless --path . --script scripts/ci_runner.gd
```

**Key considerations:**
- Import resources first: `--import --quit`
- Use dummy drivers: `--display-driver headless --audio-driver Dummy`
- Set environment: `GODOT_DISABLE_LEAK_CHECKS=1`

### Two-Step CI Workflow

1. **Import step:** Warm up and register all resources/classes
2. **Test step:** Run tests with registered classes

**Source:** Medium article "CI-tested GUT for Godot 4" (Oct 2025)

## References

1. **GUT Documentation:** https://gut.readthedocs.io/
2. **gdUnit4 GitHub:** https://github.com/MikeSchulze/gdUnit4
3. **Godot 4.4 Unit Testing Docs:** https://docs.godotengine.org/en/4.4/contributing/development/core_and_modules/unit_testing.html
4. **Medium - Unit testing GDScript with GUT:** https://stephan-bester.medium.com/unit-testing-gdscript-with-gut-01c11918e12f
5. **Medium - CI-tested GUT on Godot 4.5:** https://medium.com/@kpicaza/ci-tested-gut-for-godot-4-fast-green-and-reliable-c56f16cde73d

## Conclusion

For the Rhythm RPG framework, a custom lightweight integration test suite is most appropriate:
- No external plugin dependencies
- Simple dictionary-based results
- Signal-based async testing
- Easy for system agents to extend
- CI/CD friendly with proper headless support
