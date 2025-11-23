# Research: Asset Request System
## Framework Component 10 - On-Demand Asset Creation

**Agent:** F3
**Date:** 2025-11-18
**Duration:** 30 minutes (simplified component!)
**Component:** Asset Request System (SIMPLIFIED)

---

## Research Questions

1. How does Aseprite integrate with Godot 4?
2. What are best practices for game asset naming conventions?
3. What does an on-demand asset workflow look like?
4. How should assets be organized?
5. What is the Aseprite Wizard plugin and how does it work?

---

## 🎯 IMPORTANT: Simplified Approach

**NO CODE TO WRITE!** This component is about documentation and directories only.

**Philosophy:**
- Agents request .aseprite files when needed
- You create them on-demand using Aseprite Wizard
- No procedural generation, no placeholder bloat
- Real assets exactly as specified

**Duration: 0.25 day** (down from 0.5 day with procedural generation)

---

## Findings

### 1. Aseprite + Godot 4 Workflow

**Sources:**
- GitHub: viniciusgerevini/godot-aseprite-wizard
- Godot Asset Library: Aseprite Wizard plugin
- GameFromScratch: "Using Aseprite with Godot"
- GodotAwesome: Aseprite Wizard integration guide

**Key Insights:**

**Aseprite Wizard Plugin:**
- **Purpose:** Godot Editor plugin to import Aseprite animations
- **Supports:** AnimationPlayers, AnimatedSprites 2D/3D, SpriteFrames
- **URL:** https://github.com/viniciusgerevini/godot-aseprite-wizard
- **Status:** Fully compatible with Godot 4

**Features:**
- Adds Aseprite file importer to Godot
- Supports animation directions (forward, reverse, ping-pong)
- Converts Aseprite frame duration (ms) to Godot FPS
- Filters layers using regex
- Loopable and non-loopable animations via tags

**Installation:**
1. Open Asset Lib tab in Godot
2. Search for "asep"
3. Install the importer
4. Enable in Project Settings → Plugins tab
5. Configure Aseprite application path in Project Settings → General

**Workflow:**
1. Create .aseprite file in Aseprite
2. Save to project assets folder
3. Godot automatically imports via Aseprite Wizard
4. Use in AnimatedSprite2D, AnimationPlayer, or SpriteFrames

**Timing and Animation:**
- Aseprite frames use milliseconds
- Plugin converts to Godot FPS automatically
- Animation created in Aseprite works same way in Godot
- Use tags to organize animation regions

**Layer Management:**
- Filter out unwanted layers
- Export as single SpriteFrames or separate layers
- Regex-based layer filtering

**Performance Tip:**
- Use RAM Drive for intermediate temporary files during import

**For Our Project:**
- Already documented in PLUGIN-SETUP.md as Recommended Plugin #1
- No need to write placeholder generation code
- Create .aseprite files on-demand when agents request them
- Simple, direct workflow

---

### 2. Game Asset Naming Conventions

**Sources:**
- Gamedev Guide: "Assets naming convention"
- Game Development Stack Exchange discussions
- LinkedIn: "Ultimate Guide to Asset Naming Conventions"
- Medium: "Animation Naming Conventions and Folder Structures"

**Key Insights:**

**Core Principles:**
- **Consistency:** All team members use same convention
- **Clarity:** Simple, clear, descriptive names
- **Brevity:** Keep names short (20-30 characters max)

**Common Prefixes:**
- `spr_` for sprites
- `obj_` for objects
- `char_` for characters
- `env_` for environment
- `ui_` for user interface
- `tex_` for textures
- `anim_` for animations
- `snd_` for sounds

**Formatting Guidelines:**
- Use underscores to split sections
- Use numeric values with 2 digits (01, 02, not 1, 2)
- **Lowercase preferred** for cross-platform compatibility
- No spaces in file names

**Examples:**
```
spr_player_idle_01.aseprite
spr_player_walk_01.aseprite
spr_enemy_slime_attack_01.aseprite
ui_button_primary.aseprite
snd_footstep_01.wav
```

**Organization Structure:**
- Folder hierarchy: `Assets/Category/Subcategory/`
- Example: `assets/sprites/player/`
- Example: `assets/ui/buttons/`

**The Rule:**
- From the name alone, you should understand what the asset is

**For Our Project:**
- Use **lowercase snake_case** (no prefixes needed)
- Simple, descriptive names
- Include state/variant in name (idle, walk, attack)
- Examples:
  - `player_idle.aseprite`
  - `player_walk.aseprite`
  - `enemy_slime_attack.aseprite`
  - `button_primary.aseprite`

---

### 3. On-Demand Asset Creation Workflow

**Sources:**
- Perforce: "Overview of Game Asset Creation"
- Scenario, Layer: AI-powered asset platforms
- Juego Studios: "Detailed Guide to Game Asset Creation"
- ResearchGate: "A Workflow for Developing Game Assets"

**Key Insights:**

**Traditional Workflow:**
1. Concept (2D sketches)
2. Low-poly modeling
3. High-poly refinement
4. UV mapping
5. Baking
6. Texturing
7. Lighting
8. Integration into engine

**On-Demand Approach:**
- Create assets only when needed
- Specification-driven (agent provides exact requirements)
- Fast iteration cycle
- No wasted effort on unused assets

**Advantages:**
- **No bloat:** Only create what's actually used
- **Precise specs:** Agents specify exact dimensions, frames, style
- **Fast turnaround:** Simple assets can be created in minutes
- **Easy iteration:** If not right, revise and re-provide

**AI-Powered Tools (for reference):**
- Scenario: Production-ready asset creation
- Layer: Scales asset production for live services
- Procedural generation: Quickly scale up asset creation

**For Our Project:**
- **Manual creation with Aseprite** (not AI/procedural)
- Agent specifies in HANDOFF document
- You create using Aseprite
- Provide file in next HANDOFF
- Agent imports and uses
- Simple, direct, no automation overhead

---

### 4. Asset Organization Best Practices

**Sources:**
- Multiple game dev forums and guides
- Unity/Unreal asset organization patterns
- Godot project structure recommendations

**Key Insights:**

**Directory Structure:**
```
assets/
  sprites/
    characters/
    enemies/
    items/
  sounds/
    sfx/
    music/
  ui/
    buttons/
    icons/
    panels/
  fonts/
```

**For Small/Medium Projects:**
- Simpler is better
- Main categories (sprites, sounds, ui, fonts)
- Subcategories as needed

**For Our Project:**
- Start simple with 4 main directories
- Add subcategories later if needed
- Empty directories ready for on-demand creation

---

### 5. Aseprite Wizard Detailed Integration

**Sources:**
- Official GitHub repository
- Godot Asset Library
- Community tutorials

**Complete Setup:**

1. **Install Plugin:**
   - Via Godot Asset Library (search "asep")
   - Or manual: Clone repo to `addons/` folder

2. **Configure:**
   - Enable in Project Settings → Plugins
   - Set Aseprite path in Project Settings → General

3. **Create Assets:**
   - Open Aseprite
   - Create sprite/animation
   - Save as .aseprite in project assets folder

4. **Import:**
   - Godot detects .aseprite file
   - Plugin automatically imports
   - Creates SpriteFrames or AnimationPlayer

5. **Use:**
   - Drag .aseprite to AnimatedSprite2D node
   - Or configure in AnimationPlayer
   - Animation ready to use

**File Format:**
- Native .aseprite files (not exported PNG/GIF)
- Godot handles conversion automatically
- Preserves animation timing and layers

---

## Design Decisions for ASSET-PIPELINE.md

### Simplified Approach

**What We're NOT Doing:**
- ❌ Procedural placeholder generation
- ❌ Complex generator scripts
- ❌ Automated asset creation
- ❌ Placeholder bloat

**What We ARE Doing:**
- ✅ Simple request format for agents
- ✅ On-demand .aseprite file creation
- ✅ Aseprite Wizard integration
- ✅ Request tracking (ASSET-REQUESTS.md)
- ✅ Directory structure only

### Request Workflow

1. **Agent needs asset** → Adds to HANDOFF document
2. **You check request** → Review specifications
3. **You create .aseprite** → Using Aseprite Wizard
4. **You provide file** → In next HANDOFF
5. **Agent imports** → Using Godot's Aseprite Wizard plugin
6. **Agent uses asset** → In their system

### Asset Categories

**Main directories:**
- `assets/sprites/` - Character sprites, enemies, items, tiles
- `assets/sounds/` - Sound effects, footsteps, combat sounds
- `assets/ui/` - Buttons, icons, panels, menus
- `assets/fonts/` - Custom fonts if needed

### Naming Convention

**Format:** `[name].aseprite`
**Style:** lowercase snake_case
**Examples:**
- `player_idle.aseprite`
- `player_walk.aseprite`
- `enemy_slime_attack.aseprite`
- `button_primary.aseprite`
- `icon_health.aseprite`

### Request Format

**In agent HANDOFF documents:**
```markdown
## Asset Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation (4 frames)
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle

**Notes:** Player should face right by default. Transparent backgrounds.
```

### Tracking

**File:** `assets/ASSET-REQUESTS.md`
- Track pending requests
- Track in-progress work
- Track completed assets
- Simple checklist format

---

## Implementation Plan

1. Create `ASSET-PIPELINE.md` with:
   - Asset philosophy (request when needed)
   - Directory structure
   - Request format for agents
   - Request tracking format
   - Aseprite Wizard integration workflow
   - Naming conventions
   - Asset categories
   - Request checklist

2. Create directory structure:
   - `assets/sprites/`
   - `assets/sounds/`
   - `assets/ui/`
   - `assets/fonts/`

3. Create `assets/ASSET-REQUESTS.md`:
   - Tracking template
   - Example requests (to be replaced)

---

## References

**Aseprite + Godot:**
- https://github.com/viniciusgerevini/godot-aseprite-wizard
- https://godotengine.org/asset-library/asset/713
- https://gamefromscratch.com/using-aseprite-with-godot/

**Naming Conventions:**
- https://ikrima.dev/ue4guide/wip/assets-naming-convention/
- https://gamedev.stackexchange.com/questions/38180/naming-conventions-for-external-resources
- https://medium.com/@nicholasRodgers/animation-naming-conventions-and-folder-structures-for-game-development-2e87f3d0668f

**Asset Workflow:**
- https://www.perforce.com/blog/vcs/game-asset-creation-workflow
- https://www.researchgate.net/publication/352801759_A_Workflow_for_Developing_Game_Assets_for_Video_Games

---

## Conclusion

The simplified asset request system is:
- **Documentation-only:** No code to write
- **On-demand:** Create assets when needed, not before
- **Agent-driven:** Agents specify exactly what they need
- **Aseprite Wizard:** Leverages existing Godot plugin
- **Simple and direct:** No procedural generation overhead

**Time saved:** 4 hours (0.25 day vs 0.5 day with generator script)

**Benefits:**
- No placeholder bloat
- Precise specifications
- Fast iteration
- Easy to maintain
- Real assets when needed

**Status:** Research complete, ready for implementation ✅
