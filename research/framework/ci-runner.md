# Research: CI/CD Integration for Godot 4.5

**Date:** 2025-11-18
**Component:** Framework Component 4
**Agent:** F1

## Research Questions

1. How to run Godot 4.5 in headless mode for CI/CD?
2. What command-line arguments are available?
3. How to integrate with GitHub Actions and GitLab CI?
4. What exit codes should be used?
5. How to handle resource imports in CI?

## Findings

### Headless Mode in Godot 4.5

**Basic Headless Flag:**
```bash
godot --headless --script scripts/ci_runner.gd
```

**Complete Headless Configuration:**
```bash
godot --headless \
      -d \
      --display-driver headless \
      --audio-driver Dummy \
      --disable-render-loop \
      --path . \
      --script scripts/ci_runner.gd
```

**Flag Explanations:**
- `--headless` - Run without GUI
- `-d` - Debug mode (verbose output)
- `--display-driver headless` - No display driver
- `--audio-driver Dummy` - No audio driver
- `--disable-render-loop` - Skip rendering
- `--path .` - Project path

**Source:** Medium "CI-tested GUT for Godot 4" (Oct 2025), itch.io blog

### Two-Step CI Workflow (Critical!)

**Problem:** Tests may fail if resources/classes aren't registered

**Solution:**

**Step 1: Import Resources**
```bash
godot --headless --path . --import --quit
```
- Warms up the project
- Registers all resources and classes
- Exits after import

**Step 2: Run Tests**
```bash
godot --headless --path . --script scripts/ci_runner.gd
```
- All classes now available
- Tests can run successfully

**Source:** Medium "CI-tested GUT for Godot 4: fast, green, and reliable"

### Environment Variables

**Disable Leak Checks:**
```bash
export GODOT_DISABLE_LEAK_CHECKS=1
```

**Rationale:**
- Avoids false negatives from leak detection logs
- Engine shutdown can trigger false positives
- Cleaner CI output

**Source:** Medium article on CI-tested GUT

### Command-Line Argument Parsing

**In GDScript:**
```gdscript
var args := OS.get_cmdline_args()

for arg in args:
    match arg:
        "--no-integration":
            run_integration_tests = false
        "--strict":
            strict_mode = true
```

**Passing Arguments:**
```bash
# Note the double dash separator
godot --headless --script ci_runner.gd -- --no-integration --strict
```

### Exit Codes

**Standard Exit Codes:**
- `0` - Success (all tests passed)
- `1` - Failure (some tests failed)
- `2` - Error (critical error, couldn't run tests)

**Implementation:**
```gdscript
extends SceneTree

func _init() -> void:
    var all_passed := run_tests()

    if all_passed:
        quit(0)
    else:
        quit(1)
```

**Why extend SceneTree:**
- Allows initialization without full game setup
- Can call `quit(exit_code)`
- Lightweight for CI environments

### GitHub Actions Integration

**Example Workflow:**
```yaml
name: Framework Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.5.1

      - name: Import Resources
        run: godot --headless --path . --import --quit

      - name: Run Tests
        run: godot --headless --script scripts/ci_runner.gd

      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: |
            test-results.json
            CHECKPOINT-VALIDATION-REPORT.md
```

**Available Actions:**
- `chickensoft-games/setup-godot@v1` - Setup Godot
- `godot-ci` - Docker-based Godot CI (barichello/godot-ci)

**Source:** GitHub Marketplace, various CI tutorials

### GitLab CI Integration

**Example Configuration:**
```yaml
test:
  image: barichello/godot-ci:4.2.1
  script:
    - godot --headless --path . --import --quit
    - godot --headless --script scripts/ci_runner.gd
  artifacts:
    reports:
      junit: test-results.json
    paths:
      - test-results.json
      - CHECKPOINT-VALIDATION-REPORT.md
```

**Source:** Roger Clotet blog on GitLab CI workflow

### Docker Images

**Popular Image:**
```
barichello/godot-ci:4.2.1
```

**Contents:**
- Godot engine
- Export templates
- Butler utility (for itch.io publishing)

**Source:** GitHub godot-ci marketplace

### Test Reporting Formats

**JSON for CI Systems:**
```json
{
  "timestamp": "2025-11-18T10:30:00",
  "framework": "Rhythm RPG",
  "overall_status": "passed",
  "integration_tests": {
    "total": 26,
    "passed": 20,
    "failed": 0,
    "skipped": 6
  }
}
```

**Benefits:**
- Machine-readable
- Easy to parse in CI dashboards
- Can be converted to JUnit XML if needed

**Markdown for Humans:**
- Human-readable reports
- Can be attached as CI artifacts
- Easy to review in browser

### Testing Frameworks CI Integration

**GdUnit4:**
- Command-line tool for headless execution
- HTML reports, JUnit XML format
- GitHub Action available
- Exit codes: 0 (pass), 1 (fail), 2+ (errors)

**GUT (Godot Unit Test):**
- Test discovery: `-gdir=res://tests -ginclude_subdirs`
- Exit after tests: `-gexit`
- Single test failure fails job

**Source:** gdUnit4 README, GUT documentation

### Avoiding Common CI Pitfalls

**Issue 1: Resource Not Found**
- **Solution:** Run import step first

**Issue 2: False Leak Detection**
- **Solution:** Set `GODOT_DISABLE_LEAK_CHECKS=1`

**Issue 3: Engine Shutdown Noise**
- **Solution:** Filter output, use reliable headless flags

**Issue 4: Timeout on Slow Tests**
- **Solution:** Set appropriate CI timeout values

**Source:** Various Medium articles and forum discussions

## CI Runner Design Decisions

### Extend SceneTree vs Node

**Choice:** Extend SceneTree

**Rationale:**
- Lightweight initialization
- Can quit with exit codes
- No scene tree setup required
- Perfect for headless CI

### Report Generation

**Multiple Formats:**
- JSON for machines (CI dashboards)
- Markdown for humans (artifacts)

**Benefits:**
- Flexibility in CI integration
- Human reviewable results
- Machine parseable for metrics

### Command-Line Configuration

**Flags:**
- `--no-integration` - Skip integration tests
- `--no-validation` - Skip checkpoint validation
- `--no-reports` - Skip report generation
- `--strict` - Warnings become failures

**Rationale:**
- Flexibility for different CI scenarios
- Can run subsets of tests
- Strict mode for production branches

## References

1. **Medium - CI-tested GUT for Godot 4:** https://medium.com/@kpicaza/ci-tested-gut-for-godot-4-fast-green-and-reliable-c56f16cde73d
2. **itch.io Blog - CI-tested GUT on Godot 4.5:** https://itch.io/blog/1088565/ci-tested-gut-on-godot-45
3. **nakyle.com - Godot CI:** https://nakyle.com/godot-ci/
4. **David Saltares - Run automated tests:** https://saltares.com/run-automated-tests-for-your-godot-game-on-ci/
5. **Roger Clotet - GitLab CI workflow:** https://clotet.dev/blog/gitlab-ci-workflow-android-game-godot
6. **GitHub Marketplace - godot-ci:** https://github.com/marketplace/actions/godot-ci
7. **TeamCity Blog - Automating Godot Builds:** https://blog.jetbrains.com/teamcity/2024/10/automating-godot-game-builds-with-teamcity/
8. **gdUnit4 Documentation:** https://mikeschulze.github.io/gdUnit4/latest/

## Conclusion

For the Rhythm RPG CI runner:
- Extend SceneTree for lightweight execution
- Use two-step workflow (import → test)
- Proper exit codes for CI integration
- Command-line arguments for flexibility
- JSON + Markdown reports
- Environment variable for leak checks
