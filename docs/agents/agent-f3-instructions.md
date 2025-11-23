# Agent F3 Instructions - Knowledge & Assets
## Framework Setup Components 8-10

**Agent Mission:** Create knowledge management systems and asset request tools to support all game systems.

**Estimated Time:** 1.25 days (4-5 hours per component, Component 10 simplified!)

**Branch:** `claude/framework-setup`

---

## 📋 Your Components

You will create:
1. **Component 8:** Known Issues DB (`KNOWN-ISSUES.md`)
2. **Component 9:** Knowledge Base Directories (`knowledge-base/` structure)
3. **Component 10:** Asset Request System (`ASSET-PIPELINE.md` + directories) **[SIMPLIFIED - 0.25 day!]**

---

## 📚 Prerequisites

### Required Reading

Before starting, read:
- `FRAMEWORK-SETUP-GUIDE.md` (lines 3615-5104 for your components)
- `PLUGIN-SETUP.md` (lines 98-275 for Aseprite Wizard integration)
- `AI-VIBE-CODE-SUCCESS-FRAMEWORK.md` (Complete quality/coordination framework)
- `COORDINATION-DASHBOARD.md` (Check for blockers, update your status)
- `KNOWN-ISSUES.md` (Will create this!)

### Important: Component 10 Simplification

**Component 10 has been simplified!** No procedural placeholder generation. Just documentation and directory structure.

- **Old approach:** 500+ line generator script, complex placeholders
- **New approach:** On-demand .aseprite file requests via HANDOFF documents
- **Duration:** 0.25 day (down from 0.5 day)
- **Workflow:** Agents request → You provide .aseprite files using Aseprite Wizard

---

## 🎯 Component 8: Known Issues DB

**Duration:** 0.5 day
**File:** `KNOWN-ISSUES.md`
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 3628-4100

### Research Phase (30 minutes)

Search for:
- "bug tracking best practices"
- "issue database markdown format"
- "game development common issues"
- "Godot known issues tracking"

Document findings in `research/framework-known-issues-research.md`

### Implementation

Create `KNOWN-ISSUES.md` with:

**Key Sections:**
1. **Quick Stats** - Dashboard of issue counts by severity
2. **Issue Categories** - 6 categories (Framework, System Integration, Godot, Performance, Gameplay, Asset)
3. **Severity Sections** - 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low
4. **Resolved Issues** - Archive of fixed bugs
5. **How to Report** - Template and guidelines
6. **How to Resolve** - Resolution workflow
7. **Issue Analytics** - Patterns and prevention
8. **Integration with Framework** - Workflow diagram

**Severity Levels:**
- 🔴 Critical: Blocks development, crashes, data loss
- 🟠 High: Major functionality broken, bad performance
- 🟡 Medium: Minor functionality issues, cosmetic bugs
- 🟢 Low: Enhancements, polish, nice-to-have

**Issue ID Format:** Simple sequential (#001, #002, etc.)

**Important:** See full template in FRAMEWORK-SETUP-GUIDE.md lines 3656-3925

### Checkpoint

Create `checkpoints/framework-known-issues-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 3945-4100

---

## 🎯 Component 9: Knowledge Base Directories

**Duration:** 0.5 day
**Files:** `knowledge-base/` directory structure + README files
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 4104-4774

### Research Phase (30 minutes)

Search for:
- "knowledge management for development teams"
- "documentation organization best practices"
- "lessons learned database structure"
- "technical knowledge base design"

Document findings in `research/framework-knowledge-base-research.md`

### Implementation

Create directory structure:
```bash
mkdir -p knowledge-base/solutions
mkdir -p knowledge-base/patterns
mkdir -p knowledge-base/gotchas
mkdir -p knowledge-base/integration-recipes
```

Create these files:

#### 1. `knowledge-base/README.md`
**Key Sections:**
- Structure overview (4 categories)
- How to use (when you learn, when you're stuck)
- 4 entry templates (Solution, Pattern, Gotcha, Integration Recipe)
- Quick search guide (grep examples)
- Knowledge base stats
- Creative knowledge sharing
- Integration with framework

**Important:** See full template in FRAMEWORK-SETUP-GUIDE.md lines 4140-4480

#### 2. `knowledge-base/solutions/README.md`
Simple index file for solutions

#### 3. `knowledge-base/patterns/README.md`
Simple index file for design patterns

#### 4. `knowledge-base/gotchas/README.md`
Simple index file for pitfalls

#### 5. `knowledge-base/integration-recipes/README.md`
Simple index file for integration guides

**Important:** See README templates in FRAMEWORK-SETUP-GUIDE.md lines 4482-4544

### Checkpoint

Create `checkpoints/framework-knowledge-base-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 4566-4774

---

## 🎯 Component 10: Asset Request System **[SIMPLIFIED!]**

**Duration:** 0.25 day (60% faster than original!)
**Files:** `ASSET-PIPELINE.md` + directory structure only
**Reference:** FRAMEWORK-SETUP-GUIDE.md lines 4777-5104

### ⚠️ IMPORTANT: Simplified Approach

**NO CODE TO WRITE!** Just documentation and directories.

**Philosophy:**
- Agents request .aseprite files in HANDOFF documents
- You provide them on-demand using Aseprite Wizard
- No procedural generation, no placeholder bloat
- Real assets when needed, exactly as specified

### Implementation

#### File 1: `ASSET-PIPELINE.md`

Create documentation with:

**Key Sections:**
1. **Asset Philosophy** - "Request When Needed" approach
2. **Directory Structure** - Simple folder layout
3. **Asset Request Format** - Template for agents to use
4. **Asset Request Tracking** - ASSET-REQUESTS.md format
5. **Aseprite Wizard Integration** - Workflow steps
6. **Naming Conventions** - lowercase snake_case
7. **Asset Categories** - Sprites, sounds, UI
8. **Request Checklist** - What agents should specify
9. **Integration with Framework** - Links to other tools

**Important:** See full template in FRAMEWORK-SETUP-GUIDE.md lines 4792-4967

#### Directory Creation

Create these directories (empty):
```bash
mkdir -p assets/sprites
mkdir -p assets/sounds
mkdir -p assets/ui
mkdir -p assets/fonts
```

#### File 2: `assets/ASSET-REQUESTS.md`

Create tracking template:
```markdown
# Asset Requests

## Pending Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle

## In Progress

(None yet)

## Completed

- [x] None yet
```

**Important:** See full template in FRAMEWORK-SETUP-GUIDE.md lines 4979-4995

### Aseprite Wizard Integration

**Agent Request Workflow:**
1. Agent adds request to HANDOFF document
2. You check `ASSET-REQUESTS.md` for request details
3. You create `.aseprite` file with Aseprite Wizard
4. You provide file to agent in next HANDOFF
5. Agent imports and uses it

**Aseprite Wizard Setup:**
- Plugin URL: https://github.com/viniciusgerevini/godot-aseprite-wizard
- Already documented in `PLUGIN-SETUP.md` as Recommended Plugin #1
- Supports Godot 4.5
- Auto-generates sprite frames from .aseprite files

### Checkpoint

Create `checkpoints/framework-asset-request-system-checkpoint.md` using template in FRAMEWORK-SETUP-GUIDE.md lines 4999-5104

**Key Points to Emphasize:**
- Simplified from procedural generation
- Duration: 0.25 day (not 0.5 day)
- No generator script needed
- On-demand workflow using Aseprite Wizard
- Agent-driven requests via HANDOFF documents

---

## 📤 Final Deliverable: HANDOFF-FRAMEWORK-F3.md

After completing all 3 components, create `HANDOFF-FRAMEWORK-F3.md`:

```markdown
# HANDOFF: Framework F3 - Knowledge & Assets

## Components Completed

### Component 8: Known Issues DB
- ✅ `KNOWN-ISSUES.md` - Centralized bug tracking
- ✅ `research/framework-known-issues-research.md`
- ✅ `checkpoints/framework-known-issues-checkpoint.md`

### Component 9: Knowledge Base Directories
- ✅ `knowledge-base/README.md` - Main knowledge base guide
- ✅ `knowledge-base/solutions/README.md` - Solutions index
- ✅ `knowledge-base/patterns/README.md` - Patterns index
- ✅ `knowledge-base/gotchas/README.md` - Gotchas index
- ✅ `knowledge-base/integration-recipes/README.md` - Recipes index
- ✅ `research/framework-knowledge-base-research.md`
- ✅ `checkpoints/framework-knowledge-base-checkpoint.md`

### Component 10: Asset Request System (SIMPLIFIED)
- ✅ `ASSET-PIPELINE.md` - On-demand asset creation guide
- ✅ `assets/ASSET-REQUESTS.md` - Request tracking template
- ✅ Asset directory structure (sprites/, sounds/, ui/, fonts/)
- ✅ `research/framework-asset-request-system-research.md`
- ✅ `checkpoints/framework-asset-request-system-checkpoint.md`

## Simplified Component 10 Details

**What Changed:**
- ❌ NO procedural placeholder generator script
- ❌ NO complex placeholder generation logic
- ✅ Simple on-demand .aseprite file requests
- ✅ Aseprite Wizard integration documented
- ✅ Duration reduced from 0.5 day to 0.25 day

**Workflow:**
1. Agent adds asset request to HANDOFF document
2. You create .aseprite file using Aseprite Wizard
3. You provide file to agent
4. Agent imports into Godot

**Aseprite Wizard:**
- Documented in PLUGIN-SETUP.md as Recommended Plugin #1
- URL: https://github.com/viniciusgerevini/godot-aseprite-wizard
- Godot 4.5 compatible
- Auto-generates sprite sheets from .aseprite files

## MCP Agent Tasks (Tier 2)

### Verification Checklist

- [ ] KNOWN-ISSUES.md formatted correctly
- [ ] Knowledge base directories created
- [ ] All knowledge base READMEs present
- [ ] ASSET-PIPELINE.md clear and complete
- [ ] Asset directories created (sprites/, sounds/, ui/, fonts/)
- [ ] ASSET-REQUESTS.md tracking template ready
- [ ] Aseprite Wizard documented in PLUGIN-SETUP.md
- [ ] All checkpoints created and valid

### Directory Structure Created

```
knowledge-base/
  README.md
  solutions/
    README.md
  patterns/
    README.md
  gotchas/
    README.md
  integration-recipes/
    README.md

assets/
  ASSET-REQUESTS.md
  sprites/
  sounds/
  ui/
  fonts/
```

## Usage Examples

### Reporting an Issue
```markdown
# In KNOWN-ISSUES.md

**Issue ID:** #042
**Severity:** 🟡 Medium
**Category:** System Integration
**System:** S03 Player Controller
**Reported By:** S03
**Date Reported:** 2025-11-20
**Status:** Open

[... fill in template ...]
```

### Adding Knowledge Entry
```bash
# Create new solution
cd knowledge-base/solutions
# Use Solution Template from main README
# Commit with: "Add knowledge: Fixed conductor timing drift"
```

### Requesting an Asset
```markdown
# In system HANDOFF document

## Asset Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation (4 frames)
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle

**Notes:** Player should face right by default. Transparent backgrounds.
```

## Integration Points

### With F1 Components:
- Integration Tests run tests, report bugs in KNOWN-ISSUES.md
- Quality Gates standards documented in Knowledge Base
- Checkpoint Validation may find issues

### With F2 Components:
- Performance Profiler findings → KNOWN-ISSUES.md
- Coordination Dashboard links to issue counts
- Rollback System can snapshot before risky changes

## Status

✅ **All F3 components complete!**
✅ **ALL 10 FRAMEWORK COMPONENTS COMPLETE!**

**Ready for:**
- System agents (S01-S26) to start development
- On-demand asset creation via Aseprite Wizard
- Knowledge accumulation as systems are built
- Issue tracking throughout development
```

---

## ✅ Completion Checklist

Before marking your work complete:

- [ ] All 3 components implemented (documentation + directories)
- [ ] All 3 research documents created
- [ ] All 3 checkpoint files created
- [ ] Quality gate self-evaluation (80+ score for each component)
- [ ] HANDOFF-FRAMEWORK-F3.md created
- [ ] COORDINATION-DASHBOARD.md updated with your completion
- [ ] Verified Component 10 is simplified (no generator script!)
- [ ] Aseprite Wizard documented in PLUGIN-SETUP.md
- [ ] All files committed to git
- [ ] Git pushed to `claude/framework-setup` branch

---

## 🎨 Creative Notes

**Make knowledge sharing satisfying:**
- Clear categorization (easy to find things)
- Copy-paste ready templates
- Celebrate "Aha!" moments in knowledge entries
- Fun emoji indicators for severity/difficulty
- Simple asset request workflow (no bloat!)

---

## 📞 Need Help?

If blocked:
1. Search `knowledge-base/` for solutions (you're creating it!)
2. Check `KNOWN-ISSUES.md` for similar problems (you're creating it!)
3. Add blocker to COORDINATION-DASHBOARD.md
4. Document issue in KNOWN-ISSUES.md

---

## ⚠️ Key Reminder: Component 10 is SIMPLIFIED!

**DO NOT:**
- ❌ Create `scripts/generate_placeholders.gd`
- ❌ Write procedural placeholder generation code
- ❌ Generate placeholder images programmatically

**DO:**
- ✅ Create `ASSET-PIPELINE.md` (documentation only)
- ✅ Create asset directories (empty)
- ✅ Create `assets/ASSET-REQUESTS.md` (tracking template)
- ✅ Document Aseprite Wizard workflow
- ✅ Keep it simple and on-demand!

**This saves you ~4 hours of work! 🎉**

---

**Good luck, Agent F3! You're building the knowledge and asset foundation! 🧠🎨**
