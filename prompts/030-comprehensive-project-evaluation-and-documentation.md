<objective>
Conduct a comprehensive evaluation of the Rhythm RPG project after completion of all 28 system implementation prompts. Create thorough, searchable documentation and a robust knowledge base that enables future agents of any skill level to easily understand, extend, and build upon the existing codebase.

This evaluation ensures:
- All systems integrate seamlessly and work together effectively
- The project is scalable and open to future development
- Future agents can quickly discover existing frameworks (e.g., finding monster creation patterns with a simple prompt like "create a new monster")
- All implementations use verified Godot 4.5+ compatible code
- Godot-MCP GDAI tools can be leveraged effectively throughout the project
- A comprehensive knowledge base exists for agent learning and onboarding
</objective>

<context>
**Project:** Rhythm RPG (Godot 4.5.1)
**Status:** All 28 prompts executed, all Tier 1 (file creation) and Tier 2 (scene configuration) work complete
**Goal:** Validate integration, create comprehensive documentation, and establish knowledge base for future development

**Critical Foundation Documents:**
@PARALLEL-EXECUTION-GUIDE-V2.md - Multi-agent execution strategy and system dependencies
@vibe-code-philosophy.md - LLM development principles (Research → MCP → Verify → Checkpoint)

**Project Structure:**
- 26 game systems (S01-S26) implemented across 28 prompts
- Tier 1 artifacts: .gd scripts, .json data files, HANDOFF-*.md documents
- Tier 2 artifacts: .tscn scene files, project.godot configurations
- Support files: research/*.md, checkpoints/*.md, knowledge-base/

**Why This Matters:**
This evaluation is the critical bridge between "systems implemented" and "systems production-ready." Future agents must be able to:
1. Quickly locate existing functionality without re-implementing
2. Understand integration patterns to avoid breaking existing systems
3. Extend systems confidently using established patterns
4. Learn from previous implementation decisions
</context>

<requirements>
You must thoroughly complete ALL of the following evaluation phases. This is not a quick review - take your time to be comprehensive, as this documentation will be the foundation for all future development.

## Phase 1: System Integration Audit (2-3 hours)

For EACH of the 26 systems (S01-S26):

1. **File Verification**
   - Verify all expected files exist (.gd, .json, .tscn, HANDOFF-*.md)
   - Check file paths match project structure conventions
   - Confirm no placeholder/dummy implementations remain

2. **Godot 4.5 Compatibility Check**
   - Search each .gd file for Godot 3.x deprecated patterns:
     * KinematicBody2D → should be CharacterBody2D
     * yield() → should be await
     * onready → should be @onready
     * export → should be @export
     * move_and_slide(velocity) → should be move_and_slide() with velocity as property
   - Verify all nodes use Godot 4.5 naming (Area2D, not Area2D)
   - Check signal syntax uses .emit() not legacy patterns
   - Document any compatibility issues found

3. **Integration Point Analysis**
   - Map how each system connects to others (signals, autoloads, shared data)
   - Identify critical dependencies between systems
   - Verify dependency relationships match PARALLEL-EXECUTION-GUIDE-V2.md expectations
   - Flag any circular dependencies or architectural issues

4. **MCP GDAI Usability Assessment**
   - Can scenes be easily modified using GDAI tools?
   - Are node structures logical and follow Godot best practices?
   - Are properties exposed for easy configuration?
   - Can test scenes be created and run via play_scene()?

## Phase 2: Framework Discovery Documentation (3-4 hours)

Create comprehensive "How to Extend" guides for ALL major frameworks. Future agents must be able to find these quickly.

For each extendable framework, create a guide:

1. **Monster/Enemy Framework**
   - Location: Where is the base enemy system? (S11, S12)
   - Data Structure: JSON template for new enemies
   - Script Pattern: How to create enemy behavior variants
   - Integration: How enemies interact with combat, spawning, progression
   - Example: Step-by-step "Create a new boss monster" walkthrough

2. **Combat System Framework**
   - Core mechanics: Rhythm timing, damage calculation, status effects
   - How to add new abilities/special moves
   - How to extend combatant types (player vs enemy variations)
   - Integration: Links to S01 Conductor, S04 Combat, S09 Dodge/Block, S10 Special Moves

3. **Inventory/Item Framework**
   - Location: S05 Inventory, S06 Save/Load, S07 Weapons, S08 Equipment
   - How to create new item types (weapons, armor, consumables, quest items)
   - JSON data structure for items
   - How items integrate with combat, crafting, cooking

4. **Progression Framework**
   - XP and leveling system (S19 Dual XP)
   - Monster evolution (S20 Evolution)
   - Alignment system (S21 Alignment)
   - How to add new progression mechanics

5. **Content Systems Framework**
   - Cooking system (S24)
   - Crafting system (S25)
   - Rhythm mini-games (S26)
   - How to add new mini-games or content systems

6. **World Systems Framework**
   - NPCs and dialogue (S22)
   - Story/quest system (S23)
   - Environment interaction (S14 Tools, S15 Vehicles, S16 Grind Rails, S17 Puzzles)

For EACH framework guide, include:
- **Quick Start**: One paragraph summary
- **File Locations**: Exact paths to key files
- **Data Templates**: JSON schemas with examples
- **Code Patterns**: GDScript patterns to follow
- **Integration Points**: What other systems are affected
- **Common Tasks**: "How do I..." for typical operations
- **Godot MCP Commands**: GDAI commands to create/modify related scenes

## Phase 3: Knowledge Base Construction (2-3 hours)

Build a structured, searchable knowledge base in `./knowledge-base/`.

### 3A. Create Knowledge Base Structure

```
knowledge-base/
├── README.md (Master index - START HERE)
├── quick-reference/
│   ├── file-locations.md (Where to find everything)
│   ├── godot-4.5-patterns.md (Verified Godot 4.5 code patterns)
│   ├── mcp-commands.md (Common GDAI MCP operations)
│   └── system-dependencies.md (What depends on what)
├── frameworks/
│   ├── monster-creation.md
│   ├── combat-extension.md
│   ├── inventory-items.md
│   ├── progression-systems.md
│   ├── content-systems.md
│   └── world-building.md
├── integration-patterns/
│   ├── signal-connections.md (How systems communicate)
│   ├── autoload-usage.md (Global singletons)
│   ├── data-flow.md (JSON → GDScript patterns)
│   └── scene-composition.md (Scene hierarchies)
├── godot-specifics/
│   ├── version-compatibility.md (4.5 vs 3.x differences)
│   ├── node-usage.md (Which nodes for what)
│   ├── performance-tips.md
│   └── common-pitfalls.md
├── agent-guides/
│   ├── onboarding.md (New agent start here)
│   ├── making-changes.md (How to modify existing systems)
│   ├── adding-features.md (How to add new systems)
│   └── testing-guide.md (How to verify changes)
└── implementation-notes/
    ├── S01-S08-foundation-notes.md
    ├── S09-S18-gameplay-notes.md
    └── S19-S26-content-notes.md
```

### 3B. Populate Each Knowledge Base File

Use this format for maximum searchability:

```markdown
# [Topic]

## Quick Summary
[2-3 sentences: What is this? Why does it matter?]

## When to Use This
- [Scenario 1]
- [Scenario 2]

## Related Systems
- S## System Name - [How it relates]

## File Locations
- `path/to/file.gd` - [Purpose]

## Key Patterns
[Code examples, JSON templates]

## MCP Commands
[Relevant GDAI commands for this topic]

## Common Tasks
### How to [Task 1]
1. Step-by-step

### How to [Task 2]
1. Step-by-step

## Gotchas & Tips
- [Things to watch out for]

## Further Reading
- Link to related knowledge base articles
```

## Phase 4: Master Documentation (1-2 hours)

Create comprehensive master documentation files:

### 4A. ARCHITECTURE-OVERVIEW.md

Create `./ARCHITECTURE-OVERVIEW.md` with:
- High-level system diagram (ASCII art or description)
- All 26 systems organized by category (Foundation, Gameplay, Content, Progression)
- Critical paths and dependencies
- Autoload singletons and their purposes
- Data flow: JSON → Scripts → Scenes
- Signal architecture: How systems communicate

### 4B. DEVELOPMENT-GUIDE.md

Create `./DEVELOPMENT-GUIDE.md` for human and AI developers:
- Project philosophy (reference vibe-code-philosophy.md)
- How to get started (environment setup, file structure)
- Development workflow (Research → MCP → Verify → Checkpoint)
- How to add new features (step-by-step)
- How to modify existing systems safely
- Testing protocols
- Common MCP GDAI workflows

### 4C. SYSTEM-REGISTRY.md

Create `./SYSTEM-REGISTRY.md` - A complete catalog:

For each system (S01-S26):
- **System ID & Name**
- **Purpose** (1 sentence)
- **Status** (Complete/Issues/Notes)
- **Key Files** (scripts, scenes, data)
- **Dependencies** (what it needs)
- **Dependents** (what needs it)
- **Integration Points** (signals, autoloads, shared data)
- **Extensibility** (how to extend/modify)
- **Knowledge Base Links** (relevant guides)

### 4D. AGENT-QUICKSTART.md

Create `./AGENT-QUICKSTART.md` - New agent onboarding:

```markdown
# New Agent Quickstart Guide

## Your First 5 Minutes

1. Read this file completely (5 min)
2. Read @vibe-code-philosophy.md (10 min)
3. Read @knowledge-base/README.md (5 min)
4. Search knowledge base for your task (2 min)

## Common Agent Tasks

### "Create a new monster"
→ See @knowledge-base/frameworks/monster-creation.md
→ Use template at @data/enemies/template.json
→ Follow patterns from @src/systems/s12-monster-database/

### "Add a new item"
→ See @knowledge-base/frameworks/inventory-items.md
→ Use template at @data/items/template.json
→ Follow patterns from @src/systems/s05-inventory/

### "Modify combat mechanics"
→ See @knowledge-base/frameworks/combat-extension.md
→ Review @src/systems/s04-combat/
→ Check dependencies: S01, S02, S03

[Continue for all common tasks...]

## File Structure
[Quick overview of where everything is]

## How to Search This Project
[Guide to using grep, knowledge base, system registry]

## Before You Start Any Task
1. Search knowledge base: Does this already exist?
2. Check SYSTEM-REGISTRY.md: What systems are involved?
3. Read relevant framework guide
4. Verify Godot 4.5 compatibility if using new patterns
5. Plan integration points

## MCP GDAI Quick Reference
[Most common commands with examples]
```

## Phase 5: Scalability & Future-Proofing Assessment (1-2 hours)

Evaluate and document the project's readiness for future expansion:

1. **Identify Extension Points**
   - Where can new systems be easily added?
   - What patterns support scalability?
   - Are there bottlenecks or limitations?

2. **Create Expansion Templates**
   - Generic system template (for adding S27, S28, etc.)
   - New content type template
   - Integration checklist for new systems

3. **Document Architectural Constraints**
   - What are the limits of current design?
   - What would require refactoring to change?
   - What's the migration path for major changes?

4. **Future Development Roadmap Suggestions**
   - Based on the architecture, what's easy to add next?
   - What would be difficult and why?
   - Recommendations for maintaining scalability

## Phase 6: Verification & Testing Documentation (1 hour)

Document what needs testing and how:

1. **Integration Test Plan**
   - Create checklist of critical integration paths
   - Document how to test each integration
   - Identify gaps in testing coverage

2. **MCP Testing Workflows**
   - Create reusable test sequences using GDAI commands
   - Document how to verify changes don't break existing systems
   - Provide test scene templates

3. **Quality Gates for Future Changes**
   - Define what "done" means for new features
   - Checklist for code review
   - Standards for new documentation
</requirements>

<output>
Create the following files:

## Core Documentation
- `./ARCHITECTURE-OVERVIEW.md` - High-level system architecture
- `./SYSTEM-REGISTRY.md` - Complete catalog of all 26 systems
- `./DEVELOPMENT-GUIDE.md` - Comprehensive development workflow
- `./AGENT-QUICKSTART.md` - New agent onboarding guide

## Knowledge Base Structure
- `./knowledge-base/README.md` - Master index (START HERE for all agents)
- `./knowledge-base/quick-reference/file-locations.md`
- `./knowledge-base/quick-reference/godot-4.5-patterns.md`
- `./knowledge-base/quick-reference/mcp-commands.md`
- `./knowledge-base/quick-reference/system-dependencies.md`
- `./knowledge-base/frameworks/monster-creation.md`
- `./knowledge-base/frameworks/combat-extension.md`
- `./knowledge-base/frameworks/inventory-items.md`
- `./knowledge-base/frameworks/progression-systems.md`
- `./knowledge-base/frameworks/content-systems.md`
- `./knowledge-base/frameworks/world-building.md`
- `./knowledge-base/integration-patterns/signal-connections.md`
- `./knowledge-base/integration-patterns/autoload-usage.md`
- `./knowledge-base/integration-patterns/data-flow.md`
- `./knowledge-base/integration-patterns/scene-composition.md`
- `./knowledge-base/godot-specifics/version-compatibility.md`
- `./knowledge-base/godot-specifics/node-usage.md`
- `./knowledge-base/godot-specifics/performance-tips.md`
- `./knowledge-base/godot-specifics/common-pitfalls.md`
- `./knowledge-base/agent-guides/onboarding.md`
- `./knowledge-base/agent-guides/making-changes.md`
- `./knowledge-base/agent-guides/adding-features.md`
- `./knowledge-base/agent-guides/testing-guide.md`
- `./knowledge-base/implementation-notes/S01-S08-foundation-notes.md`
- `./knowledge-base/implementation-notes/S09-S18-gameplay-notes.md`
- `./knowledge-base/implementation-notes/S19-S26-content-notes.md`

## Evaluation Report
- `./evaluation-report.md` - Comprehensive audit findings including:
  * Godot 4.5 compatibility issues found (if any)
  * Integration issues or concerns
  * Scalability assessment
  * Recommendations for improvements
  * Testing gaps
  * Future development suggestions

All documentation must be:
- **Searchable**: Use consistent terminology and keywords
- **Actionable**: Include specific file paths, commands, and code examples
- **Cross-referenced**: Link between related documents
- **Beginner-friendly**: Assume no prior project knowledge
- **Example-rich**: Show, don't just tell
</output>

<implementation>
Follow this systematic approach:

### Step 1: Audit Phase (Research)
- Use Glob and Grep to find all .gd, .json, .tscn files
- Read HANDOFF-*.md files to understand intended implementation
- Read checkpoint files to understand what was actually built
- Search for Godot 3.x patterns that need flagging
- Map out system dependencies and integration points

### Step 2: Research Godot 4.5 Best Practices
Before writing documentation, search for current best practices:
- "Godot 4.5 project structure best practices 2025"
- "Godot 4.5 autoload singleton patterns 2025"
- "Godot 4.5 scene composition best practices 2025"
- "Godot 4.5 data-driven game design 2025"

Incorporate these findings into your knowledge base articles.

### Step 3: Framework Documentation (Write)
For each major framework (monsters, combat, items, etc.):
1. Locate all relevant files
2. Understand the data structures (JSON schemas)
3. Extract reusable patterns
4. Create step-by-step extension guides
5. Include MCP GDAI commands for common operations

### Step 4: Knowledge Base Construction (Write)
Create the complete knowledge base structure:
1. Start with README.md (master index)
2. Build quick-reference section (most accessed)
3. Create detailed framework guides
4. Document integration patterns
5. Add Godot-specific guidance
6. Create agent guides for different skill levels

### Step 5: Master Documentation (Write)
Create the four core documentation files:
1. ARCHITECTURE-OVERVIEW.md (big picture)
2. SYSTEM-REGISTRY.md (complete catalog)
3. DEVELOPMENT-GUIDE.md (how to work)
4. AGENT-QUICKSTART.md (fast onboarding)

### Step 6: Evaluation Report (Write)
Compile all findings into a comprehensive report:
- Issues discovered and their severity
- Compatibility concerns
- Integration gaps
- Scalability assessment
- Actionable recommendations

### Godot 4.5 Compatibility Patterns to Verify

**MUST USE (Godot 4.5):**
- `CharacterBody2D` (not KinematicBody2D)
- `await signal_name` (not yield())
- `@onready` decorator (not onready)
- `@export` decorator (not export)
- `signal_name.emit(args)` (not emit_signal())
- `move_and_slide()` with velocity as property (not move_and_slide(velocity))
- `Time.get_ticks_msec()` (not OS.get_ticks_msec())

**FLAG AS INCOMPATIBLE:**
- Any use of Godot 3.x node names
- Legacy signal patterns
- Old script syntax

### MCP GDAI Usability Criteria

Document how well the project supports MCP operations:
- Can you easily add_node() to existing scenes?
- Are properties exposed for update_property()?
- Can you create_scene() following existing patterns?
- Are test scenes easy to play_scene()?
- Can you get_scene_tree() and understand structure?

### Documentation Writing Style

**BE SPECIFIC:**
- ✅ "Edit `./src/systems/s12-monster-database/monster_data.json`"
- ❌ "Edit the monster file"

**BE EXAMPLE-RICH:**
- Always include code examples
- Show JSON templates
- Demonstrate MCP commands
- Provide step-by-step walkthroughs

**BE SEARCHABLE:**
- Use consistent terminology
- Include synonyms (e.g., "enemy" and "monster")
- Add tags at top of documents: [Keywords: monster, enemy, creation, S12]
- Cross-reference related documents

**BE ACTIONABLE:**
- Every guide should have clear "How to [X]" sections
- Provide copy-pasteable code
- Include verification steps
</implementation>

<verification>
Before declaring this evaluation complete, verify:

## Completeness Checks
- [ ] All 26 systems (S01-S26) audited individually
- [ ] All framework guides created (minimum 6 major frameworks)
- [ ] Complete knowledge base structure exists
- [ ] All 4 core documentation files created
- [ ] Comprehensive evaluation report written

## Quality Checks
- [ ] Every knowledge base article has code examples
- [ ] Every framework guide has JSON templates
- [ ] Every integration pattern has GDScript examples
- [ ] Every agent guide has step-by-step instructions
- [ ] All file paths are accurate and verified to exist

## Usability Checks
- [ ] A new agent could find "how to create a monster" in under 2 minutes
- [ ] knowledge-base/README.md effectively directs to all resources
- [ ] AGENT-QUICKSTART.md covers all common tasks
- [ ] SYSTEM-REGISTRY.md has complete information for all systems
- [ ] Cross-references between documents are accurate

## Technical Checks
- [ ] All Godot 3.x compatibility issues documented
- [ ] All system dependencies verified against PARALLEL-EXECUTION-GUIDE-V2.md
- [ ] Integration points clearly documented
- [ ] MCP GDAI usability assessed for all major scenes

## Searchability Checks
- [ ] Consistent terminology used throughout
- [ ] Keywords and tags included in documents
- [ ] Multiple access paths to the same information (e.g., by system, by task, by file)
- [ ] Examples use real file paths from the project

## Test the Documentation
Simulate these agent queries and verify they can be answered quickly:
1. "How do I create a new monster?"
2. "What files control player movement?"
3. "How do combat and rhythm systems integrate?"
4. "What's the JSON structure for items?"
5. "How do I test my changes?"
6. "What depends on the S01 Conductor system?"
7. "How do I add a new mini-game?"
8. "What Godot MCP commands work with scenes?"

Each query should be answerable in under 5 minutes using your documentation.
</verification>

<success_criteria>
This evaluation is successful when:

1. **Complete System Audit**
   - All 26 systems verified for file existence, Godot 4.5 compatibility, and integration
   - Evaluation report documents all findings with severity and recommendations

2. **Searchable Knowledge Base**
   - Structured knowledge base with minimum 25 articles
   - New agents can find framework documentation in under 2 minutes
   - Every major framework has extension guide with examples

3. **Comprehensive Documentation**
   - 4 core documentation files cover architecture, systems, development, and onboarding
   - SYSTEM-REGISTRY.md catalogs all 26 systems with complete metadata
   - AGENT-QUICKSTART.md enables immediate productivity

4. **Future-Proof Foundation**
   - Extension templates exist for adding new systems
   - Scalability assessment identifies growth paths
   - Integration patterns documented for consistent expansion

5. **MCP GDAI Enablement**
   - Knowledge base includes common MCP command patterns
   - Scene structures documented for easy modification
   - Test workflows use GDAI play_scene() and verification tools

6. **Cross-Verification**
   - All documentation cross-references are accurate
   - File paths verified to exist
   - Examples use real code from the project

The ultimate test: Could a new agent with zero project knowledge complete a task like "create a new boss monster with unique abilities" using only the documentation you've created, in under 30 minutes?
</success_criteria>

<constraints>
- **Time Investment**: This is a comprehensive evaluation. Expect 10-15 hours of thorough work.
- **No Shortcuts**: Every system must be audited individually. Do not assume.
- **Godot 4.5 Only**: Flag any Godot 3.x patterns. This is critical for project functionality.
- **Vibe Code Philosophy**: Follow Research → MCP → Verify → Checkpoint workflow from @vibe-code-philosophy.md
- **Example-Driven**: Every guide needs real, working examples from the actual project code
- **Searchability First**: Optimize for agent discovery. Use consistent terms, keywords, cross-references.
- **No Assumptions**: If a file should exist but doesn't, document it in the evaluation report
- **MCP Focus**: Emphasize Godot MCP GDAI usage throughout documentation
</constraints>

<research>
Before beginning implementation, research:

1. **Godot 4.5 Documentation Structure**
   - Search: "Godot 4.5 official documentation structure 2025"
   - Goal: Learn how Godot organizes their docs for maximum searchability

2. **Knowledge Base Best Practices**
   - Search: "technical documentation knowledge base structure best practices 2025"
   - Goal: Learn optimal organization for searchability and agent discovery

3. **AI Agent Documentation Patterns**
   - Search: "documentation for AI agents LLM best practices 2025"
   - Goal: Understand how to write docs that LLMs can effectively search and use

4. **Godot 4.5 Architecture Patterns**
   - Search: "Godot 4.5 large game project architecture 2025"
   - Goal: Compare this project's architecture against community best practices

Incorporate findings from this research into your knowledge base articles and documentation structure.
</research>

<timeline>
Suggested time allocation for this comprehensive evaluation:

- Phase 1 (System Integration Audit): 2-3 hours
- Phase 2 (Framework Discovery Docs): 3-4 hours
- Phase 3 (Knowledge Base Construction): 2-3 hours
- Phase 4 (Master Documentation): 1-2 hours
- Phase 5 (Scalability Assessment): 1-2 hours
- Phase 6 (Verification & Testing Docs): 1 hour

**Total: 10-15 hours of focused work**

This is NOT a task to rush. The quality of this documentation directly impacts the success of all future development on this project.
</timeline>
