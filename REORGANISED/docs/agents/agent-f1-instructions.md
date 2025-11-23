# Agent F1 Instructions - Testing & Validation
## Framework Setup Components 1-4

**Agent Mission:** Create the testing and quality infrastructure that ensures every system meets standards.

**Estimated Time:** 2.5 days (6 hours per component + integration)

**Branch:** `claude/framework-setup`

---

## 📋 Your Components

You will create:
1. **Component 1:** Integration Test Suite (`tests/integration/integration_test_suite.gd`)
2. **Component 2:** Quality Gates (`quality-gates.json`)
3. **Component 3:** Checkpoint Validation (`scripts/validate_checkpoint.gd`)
4. **Component 4:** CI Test Runner (`scripts/ci_runner.gd`)

---

## 📚 Prerequisites

### Required Reading

Before starting, read:
- `FRAMEWORK-SETUP-GUIDE.md` (lines 150-2056 for your components)
- `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md` (Complete quality/coordination framework)
- `COORDINATION-DASHBOARD.md` (Check for blockers, update your status)
- `KNOWN-ISSUES.md` (Review for related issues)

### Autoload Registration (CRITICAL)

After creating Component 1 and 3, you MUST register autoloads. See `FRAMEWORK-SETUP-GUIDE.md` lines 98-297 for detailed instructions.

**Required autoloads:**
- `IntegrationTestSuite` → `res://tests/integration/integration_test_suite.gd`
- `CheckpointValidator` → `res://scripts/validate_checkpoint.gd`

**Note:** This is a Tier 2 task (Godot MCP agent will do this), but you must document it in your HANDOFF.

---

## 🎯 Component 1: Integration Test Suite

**Duration:** 1 day
**File:** `tests/integration/integration_test_suite.gd`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 314-795

### Research Phase (30 minutes)

Search for:
- "Godot 4.5 testing framework"
- "Godot 4.5 GUT testing plugin"
- "Godot 4.5 integration test examples"
- "GDScript 4.5 assert functions"

Document findings in `research/framework-integration-tests-research.md`

### Implementation

Create `tests/integration/integration_test_suite.gd` with:

**Key Features:**
- `TestResults` class for tracking test statistics
- 26 system test functions (one per game system S01-S26)
- Signal-based test lifecycle (`test_started`, `test_completed`, `all_tests_completed`)
- Example implementation for S01 Conductor showing testing pattern
- Graceful skipping for unimplemented systems
- Colorful ASCII art test summaries

**Important:** See full implementation in FRAMEWORK-SETUP-GUIDE.md lines 346-642

### Checkpoint

Create `checkpoints/framework-integration-tests-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 660-795

**Must include:**
- What Was Built
- Key Features
- Research Findings
- Design Decisions
- How System Agents Should Use This
- Integration with Other Framework Components
- Files Created
- Git Commit

---

## 🎯 Component 2: Quality Gates

**Duration:** 0.5 day
**File:** `quality-gates.json`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 798-1157

### Research Phase (30 minutes)

Search for:
- "code quality gates best practices"
- "automated code quality scoring"
- "game development quality metrics"
- "Godot code quality standards"

Document findings in `research/framework-quality-gates-research.md`

### Implementation

Create `quality-gates.json` with:

**5 Quality Dimensions (20 points each):**
1. **Code Quality** - Type hints, documentation, naming, organization
2. **Godot Integration** - Signals, lifecycle, resources, Godot 4.5 syntax
3. **Rhythm Integration** - Beat sync, timing windows, rhythm feedback
4. **Fun/Creativity** - Game feel, creative solutions, polish
5. **System Integration** - Dependencies, integration tests, data flow, error handling

**Minimum Score:** 80/100 to pass

**Important:** See full JSON schema in FRAMEWORK-SETUP-GUIDE.md lines 826-1038

### Checkpoint

Create `checkpoints/framework-quality-gates-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 1052-1157

---

## 🎯 Component 3: Checkpoint Validation

**Duration:** 0.5 day
**File:** `scripts/validate_checkpoint.gd`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 1161-1633

### Research Phase (30 minutes)

Search for:
- "Godot 4.5 file validation"
- "GDScript 4.5 JSON parsing"
- "markdown parsing validation"
- "file completeness checking"

Document findings in `research/framework-checkpoint-validation-research.md`

### Implementation

Create `scripts/validate_checkpoint.gd` with:

**Key Features:**
- `ValidationResult` class with errors/warnings/score
- 12 required section checking
- Quality score extraction (regex-based)
- File reference validation
- Batch validation for all checkpoints
- Markdown report generation

**Required Sections:**
- Component, Agent, Date, Duration
- What Was Built, Key Features
- Research Findings, Design Decisions
- Integration with Other, Files Created
- Git Commit, Status

**Important:** See full implementation in FRAMEWORK-SETUP-GUIDE.md lines 1194-1502

### Checkpoint

Create `checkpoints/framework-checkpoint-validation-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 1517-1633

---

## 🎯 Component 4: CI Test Runner

**Duration:** 0.5 day
**File:** `scripts/ci_runner.gd`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 1636-2055

### Research Phase (30 minutes)

Search for:
- "Godot 4.5 continuous integration"
- "GDScript 4.5 command line testing"
- "Godot headless testing"
- "automated Godot testing"

Document findings in `research/framework-ci-runner-research.md`

### Implementation

Create `scripts/ci_runner.gd` with:

**Key Features:**
- Extends `SceneTree` for headless execution
- Runs IntegrationTestSuite automatically
- Runs CheckpointValidator for all checkpoints
- Proper exit codes (0=pass, 1=fail, 2=error)
- Command-line argument parsing (--no-integration, --strict, etc.)
- JSON and markdown report generation

**Command-line options:**
- `--no-integration` - Skip integration tests
- `--no-validation` - Skip checkpoint validation
- `--no-reports` - Skip report generation
- `--strict` - Treat warnings as failures

**Important:** See full implementation in FRAMEWORK-SETUP-GUIDE.md lines 1664-1875

### Checkpoint

Create `checkpoints/framework-ci-runner-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 1920-2055

---

## 📤 Final Deliverable: HANDOFF-FRAMEWORK-F1.md

After completing all 4 components, create `HANDOFF-FRAMEWORK-F1.md`:

```markdown
# HANDOFF: Framework F1 - Testing & Validation

## Components Completed

### Component 1: Integration Test Suite
- ✅ `tests/integration/integration_test_suite.gd` - 26 system test templates
- ✅ `research/framework-integration-tests-research.md`
- ✅ `checkpoints/framework-integration-tests-checkpoint.md`

### Component 2: Quality Gates
- ✅ `quality-gates.json` - 5 dimensions, 80/100 minimum
- ✅ `research/framework-quality-gates-research.md`
- ✅ `checkpoints/framework-quality-gates-checkpoint.md`

### Component 3: Checkpoint Validation
- ✅ `scripts/validate_checkpoint.gd` - Validates all checkpoints
- ✅ `research/framework-checkpoint-validation-research.md`
- ✅ `checkpoints/framework-checkpoint-validation-checkpoint.md`

### Component 4: CI Test Runner
- ✅ `scripts/ci_runner.gd` - Headless test runner
- ✅ `research/framework-ci-runner-research.md`
- ✅ `checkpoints/framework-ci-runner-checkpoint.md`

## MCP Agent Tasks (Tier 2)

### Autoload Registration

**CRITICAL:** The following autoloads MUST be registered in Godot Project Settings:

```bash
# Method 1: Via Godot UI
# Project → Project Settings → Autoload tab
# Add each autoload with "Enable" checkbox ON

# Method 2: Manual project.godot edit
# Add to [autoload] section:
IntegrationTestSuite="*res://tests/integration/integration_test_suite.gd"
CheckpointValidator="*res://scripts/validate_checkpoint.gd"

# Verify with:
godot --headless --script scripts/verify_framework_autoloads.gd
```

See FRAMEWORK-SETUP-GUIDE.md lines 98-297 for detailed instructions.

### Verification Checklist

- [ ] All GDScript files have no syntax errors
- [ ] Autoloads registered and verified
- [ ] IntegrationTestSuite can be instantiated
- [ ] Quality gates JSON is valid
- [ ] CheckpointValidator runs without errors
- [ ] CI runner executes in headless mode
- [ ] All checkpoints created and valid

## Testing Commands

```bash
# Run integration tests
godot --headless --script scripts/ci_runner.gd

# Validate checkpoints
# (In Godot console or script)
var validator = CheckpointValidator.new()
validator.validate_all_checkpoints()

# Verify autoloads
godot --headless --script scripts/verify_framework_autoloads.gd
```

## Integration Points

### With F2 Components:
- Performance Profiler will track test execution times
- Coordination Dashboard will show component status
- Rollback System can snapshot checkpoints

### With F3 Components:
- Known Issues DB will track bugs found during testing
- Knowledge Base will store testing patterns
- Asset Pipeline (future tests may need test assets)

## Status

✅ **All F1 components complete!**

**Ready for:**
- F2 to start (Components 5-7)
- F3 to start (Components 8-10)
- System agents to use framework for development
```

---

## ✅ Completion Checklist

Before marking your work complete:

- [ ] All 4 components implemented with complete code
- [ ] All 4 research documents created
- [ ] All 4 checkpoint files created
- [ ] Quality gate self-evaluation (80+ score for each component)
- [ ] Integration between components tested
- [ ] HANDOFF-FRAMEWORK-F1.md created
- [ ] COORDINATION-DASHBOARD.md updated with your completion
- [ ] All files committed to git
- [ ] Git pushed to `claude/framework-setup` branch

---

## 🎨 Creative Notes

**Make testing satisfying:**
- Colorful console output with emojis
- ASCII art test summaries
- Fun success messages
- Helpful error messages (not scary)
- Celebrate when tests pass!

---

## 📞 Need Help?

If blocked:
1. Search `knowledge-base/` for solutions
2. Check `KNOWN-ISSUES.md` for similar problems
3. Add blocker to COORDINATION-DASHBOARD.md
4. Document issue in KNOWN-ISSUES.md if novel

---

**Good luck, Agent F1! You're building the quality foundation for the entire project! 🧪✨**
