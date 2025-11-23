# Asset Request System
## On-Demand Asset Creation for Rhythm RPG

**Version:** 1.0
**Date:** 2025-11-18
**Philosophy:** Agents request assets, you provide them on-demand using Aseprite Wizard

---

## Asset Philosophy

**"Request When Needed"**

- Agents specify asset needs in HANDOFF documents
- You create `.aseprite` files on-demand using Aseprite Wizard
- No procedural generation, no placeholder bloat
- Real assets when needed, exactly as specified
- Fast iteration cycle

---

## Directory Structure

Create this structure (directories only, no generated files):

```
assets/
  sprites/
  sounds/
  ui/
  fonts/
```

---

## Asset Request Format

Agents use this format in HANDOFF documents to request assets:

### Request Template

```markdown
## Asset Requests

### From [System Name]:
- [ ] `sprites/[name].aseprite` - [dimensions], [description]
- [ ] `sounds/[name].aseprite` - [duration/bpm], [description]
- [ ] `ui/[name].aseprite` - [dimensions], [description]

**Notes:** [Any special requirements or context]
```

### Example Request

```markdown
## Asset Requests

### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation (4 frames)
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle
- [ ] `sounds/footstep.aseprite` - 0.3s, subtle walking sound

**Notes:** Player should face right by default. Transparent backgrounds.
```

---

## Asset Request Tracking

Create and maintain `assets/ASSET-REQUESTS.md`:

```markdown
# Asset Requests

## Pending Requests
### From S03 (Player Controller):
- [ ] `sprites/player_idle.aseprite` - 64x64, blue character, idle animation
- [ ] `sprites/player_walk.aseprite` - 64x64, 4-frame walk cycle

## In Progress
- [x] Player controller sprite (requested)
- ...

## Completed
- [x] None yet
```

---

## Aseprite Wizard Integration

**When Agent Requests Asset:**

1. Check `ASSET-REQUESTS.md` for request details
2. Open Aseprite Wizard with specifications:
   - Dimensions (width x height)
   - Color palette / style
   - Animation frames
   - Any special notes
3. Create `.aseprite` file in appropriate subdirectory
4. Update `ASSET-REQUESTS.md` - move to "Completed"
5. Provide file to Agent in next HANDOFF document

**Agent then:**
- Imports the `.aseprite` file into Godot
- Uses it in their systems
- Can request revisions if needed

---

## Naming Conventions

**Format:** `[name].aseprite`

**Examples:**
```
player_idle.aseprite
player_walk.aseprite
enemy_slime_attack.aseprite
button_primary.aseprite
footstep.aseprite
```

**Rules:**
- lowercase snake_case
- descriptive names
- include state/variant in name (idle, walk, attack, etc.)

---

## Asset Categories

### Sprites
- Character sprites (idle, walk, attack, etc.)
- Enemy sprites
- Item sprites
- UI elements
- Environmental tiles

### Sounds
- Footsteps, jumps, actions
- Combat sounds (hit, miss, special)
- UI sounds (click, hover, etc.)
- Ambient sounds

### UI
- Buttons, icons, panels
- Health bars, status displays
- Menu elements

---

## Request Checklist for Agents

When requesting an asset in your HANDOFF:

- [ ] Specify dimensions (width x height)
- [ ] Describe visual style or color scheme
- [ ] Indicate if animation needed (how many frames)
- [ ] Note any special requirements
- [ ] Mention priority (if urgent)

---

## Integration with Framework

- **Quality Gates:** Assets are reviewed as part of polish
- **Integration Tests:** Verify assets load and display correctly
- **Known Issues DB:** Track broken or missing assets
- **Handoff Documents:** Primary communication method for requests

---

**End of Asset System** - Keep it simple, request what you need.
