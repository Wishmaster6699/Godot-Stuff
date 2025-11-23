# Aseprite Production Pipeline
## Complete Workflow Guide for Professional Pixel Art

**Based on research from**: Pizza Tower, Dead Cells workflow, MortMort tutorials, professional 2025 best practices

---

## I. Initial Setup & Configuration

### Canvas Setup

**Project Settings:**
```
Resolution Standards:
- Character Sprites: 128x128px canvas (32-48px actual character)
- Tilesets: 256x256px canvas (16x16px tiles)
- Backgrounds: Screen resolution (e.g., 1920x1080 for reference, downscale to game res)
- Effects: 64x64px or 128x128px depending on effect size

Color Mode: RGBA (for transparency)
Grid: 8x8px or 16x16px (depending on tile size)
Pixel Ratio: 1:1 (square pixels)
```

**Workspace Organization:**
1. Create project folder structure:
```
/ProjectName
  /Characters
    /Player
    /NPCs
    /Enemies
  /Environments
    /Tilesets
    /Backgrounds
    /Props
  /Effects
    /Particles
    /UI
  /Palettes
  /Reference
```

### Essential Aseprite Settings

**Preferences (Edit → Preferences):**
- **Editor**: Enable pixel-perfect mode
- **Grid**: Show grid, snap to grid
- **Timeline**: Show thumbnail in each frame
- **Cursor**: Crosshair cursor for precision
- **Background**: Set to checkerboard or mid-gray (#808080)
- **Experimental**: Enable all performance features

**Keyboard Shortcuts to Learn:**
```
Essential Shortcuts:
B - Pencil tool
E - Eraser
M - Rectangular Marquee
L - Line tool
G - Paint Bucket
I - Eyedropper
K - Replace Color
X - Swap foreground/background colors
[ / ] - Decrease/increase brush size
Alt+Click - Pick color
Ctrl+T - New cel (frame)
```

---

## II. Color Palette Management

### Creating Project Palettes

**Step 1: Create Base Palette**
1. Color → Palette Options → New Palette
2. Name it (e.g., "Character_Main" or "Biome_Forest")
3. Start with 8 core colors, expand to 16-24 as needed

**Step 2: Organize Colors**
```
Palette Organization (Left to Right):
1. Shadows (darkest) → Highlights (lightest) for each hue
2. Skin tones together
3. Hair colors together
4. Clothing colors together
5. Effects/special colors at end
```

**Step 3: Lock Palette**
- During production, lock palette to avoid accidental additions
- Palette → Lock Palette

### Color Ramp Creation

**For Each Main Color, Create Ramp:**
```
Example: Blue Clothing
#1a1c3e - Shadow (darkest)
#2e4052 - Dark mid-tone
#415a77 - Mid-tone
#778da9 - Light mid-tone
#e0e1dd - Highlight (brightest)
```

**Pro Tip**: Use HSV sliders, not RGB
- Shift Hue slightly (warmer highlights, cooler shadows)
- Increase Saturation in mid-tones
- Decrease Saturation in darkest shadows

---

## III. Character Sprite Workflow

### Phase 1: Sketch & Blocking

**Step 1: Reference Setup**
1. File → Open → Select reference images
2. Arrange reference in separate window
3. Or: Create reference layer in Aseprite (mark as reference)

**Step 2: Silhouette First**
1. Create new layer: "Silhouette"
2. Use pure black or mid-gray
3. Rough shape, 50% size of final
4. Focus on readable silhouette

**Step 3: Proportions Check**
1. Add guide lines (View → Grid → Guide Lines)
2. Vertical center line
3. Horizontal thirds for head/torso/legs
4. Ensure proportions match design

### Phase 2: Line Art / Pixel Art Base

**Step 1: Clean Pixel Art**
1. Create new layer: "Line Art" or "Base"
2. Zoom to 800-1600%
3. Use Pencil tool (B key)
4. 1-pixel outlines (or no outlines for hi-bit style)
5. Work from head down to feet

**Step 2: Internal Details**
1. Eyes, facial features (if applicable)
2. Clothing folds and seams
3. Equipment/instrument details
4. Keep details readable at 100% zoom

**Pizza Tower Technique:**
- Use 1-pixel thick outlines consistently
- Avoid "ugly thickness" variations
- Clean, simple shapes

### Phase 3: Base Colors

**Step 1: Flat Colors**
1. Create new layer: "Base Colors"
2. Set to Normal blending
3. Use Paint Bucket (G key) or Pencil
4. Fill each section with mid-tone color from palette
5. No shading yet - pure flat colors

**Step 2: Color Isolation**
1. Separate layer for each major color? (Optional, for complex characters)
2. Or: Single layer with all base colors
3. Use Magic Wand to select regions later

### Phase 4: Shading

**Step 1: Identify Light Source**
1. Decide light direction (typically 45° from top-left)
2. Mark on reference layer if needed

**Step 2: Add Shadows**
1. Create new layer: "Shadows" (set to Multiply) OR
2. Work directly on Base Colors layer
3. Use shadow colors from palette
4. Shade where light doesn't hit:
   - Under chin
   - Armpit areas
   - Under clothing folds
   - Far side of rounded surfaces

**Step 3: Add Highlights**
1. Create new layer: "Highlights" OR
2. Continue on same layer
3. Use highlight colors from palette
4. Add to surfaces facing light:
   - Top of head/hair
   - Shoulders
   - Tops of arms
   - Knee caps
   - Anywhere light hits directly

**Step 4: Dithering (Optional)**
1. Only use for gradual transitions
2. Checkerboard pattern (alternate pixels)
3. Or: Noise brush with low density
4. Modern pixel art often avoids dithering

### Phase 5: Details & Polish

**Step 1: Add Texture**
1. Clothing fabric texture (subtle)
2. Hair strands (few select highlights)
3. Metal shine on equipment

**Step 2: Rim Lighting (Optional)**
1. 1-pixel bright outline on shadow side
2. Separates character from background
3. Common in modern pixel art

**Step 3: Final Touches**
1. Color balance check
2. Contrast check (zoom out to 100%)
3. Readability test

---

## IV. Animation Workflow

### Setup Animation Project

**Step 1: Animation Configuration**
1. Frame → Frame Duration → Set to 100ms (10 FPS) or 83ms (12 FPS)
2. Timeline → Enable onion skinning
3. Configure onion skin: 2 frames before, 2 frames after
4. Opacity: Previous frames 50%, next frames 30%

**Step 2: Animation Tags**
1. Timeline → New Tag
2. Name tags for each animation:
   - "Idle" (frames 1-12)
   - "Walk" (frames 13-20)
   - "Attack_Light" (frames 21-28)
   - etc.

### Animation Creation Process

**Method 1: Pose-to-Pose (Recommended)**
1. Frame 1: Start pose (key frame)
2. Frame 8: End pose (key frame)
3. Frames 2-7: In-between frames
4. Use onion skinning to guide in-betweens

**Method 2: Straight-Ahead**
1. Frame 1: Start
2. Frame 2: Slight change from frame 1
3. Frame 3: Slight change from frame 2
4. Continue until animation complete
5. Good for organic/flowing animations

### Key Animation Principles in Aseprite

**1. Squash and Stretch**
- Deform sprite on impact frames
- Edit → Transform → Free transform
- Or: Redraw compressed/stretched version

**2. Anticipation**
- Add 1-2 frames before main action
- Character pulls back before punch
- Crouch before jump

**3. Smear Frames**
- For very fast actions
- Frame where character is blurred/stretched
- Only visible for 1 frame (83-100ms)

**4. Impact Frames**
- Frame where hit connects
- Often held for 2x duration (200ms)
- Maximum squash/deformation

**5. Follow-Through**
- 2-3 frames after main action
- Hair/cloth settles
- Body returns to neutral

### Frame Timing Adjustment

**Adjust Individual Frame Duration:**
1. Right-click frame in timeline
2. Properties → Frame Duration
3. Common timings:
   - Standard: 100ms
   - Held frame: 200ms
   - Quick frame: 50ms
   - Impact: 150-200ms

**Timeline Preview:**
- Play button (Space bar) or Enter
- Adjust playback speed: Frame → Playback Speed
- Loop animation to check smoothness

---

## V. Tileset Creation

### Grid-Based Tileset Workflow

**Step 1: Setup Tileset Canvas**
```
Canvas: 256x256px (for 16x16 tiles = 16x16 grid)
or 128x128px (for 16x16 tiles = 8x8 grid)
Grid: 16x16px, snap to grid ON
```

**Step 2: Core Tiles First**
1. Ground/floor tile
2. Wall tile (top, mid, bottom)
3. Corner tiles (inner, outer)
4. Transition tiles

**Step 3: Tile Variations**
1. Create 3-5 variations of ground tiles
2. Randomness prevents repetition
3. Slight color/detail changes

**Step 4: Autotiling Setup** (If using compatible engine)
1. Follow engine's autotile template
2. Common: 47-tile blob tileset
3. Godot: Use Godot autotile template

### Tile Details

**Visual Techniques:**
1. 2-3 pixel grass tufts
2. Small pebbles/debris
3. Cracks in stone
4. Subtle texture variation

**Avoid:**
- High contrast details (creates noise when tiled)
- Patterns that create obvious repetition
- Hard edges that don't tile seamlessly

---

## VI. Sprite Sheet Export for Godot

### Export Settings

**Step 1: Prepare for Export**
1. Ensure all animations are tagged
2. Check frame durations are correct
3. Test animation playback

**Step 2: Export Sprite Sheet**
1. File → Export → Export Sprite Sheet
2. **Settings:**
   ```
   Layout:
   - Type: By Rows/By Columns
   - Merge Duplicates: OFF (important for Godot)
   - Padding: 1px (prevents bleeding)
   - Trim Sprite: OFF (keeps consistent sizes)

   Output:
   - Sprite Sheet Type: Horizontal Strip or Packed
   - JSON Data: YES (check "Export JSON Data")
   - JSON Format: Array
   - Filename: {title}_{tag}.png
   - JSON File: {title}_{tag}.json
   ```

**Step 3: Import to Godot**
1. Copy .png and .json files to Godot project
2. Godot auto-detects sprite sheet
3. Create AnimatedSprite node
4. Configure frames using JSON data or manually

### Naming Conventions

```
File Naming:
player_idle.png
player_idle.json
player_walk.png
player_walk.json
player_attack_light.png
player_attack_light.json

Consistent, descriptive, lowercase, underscores
```

---

## VII. Advanced Techniques

### Technique 1: Normal Maps for Lighting (Dead Cells Style)

**If using lighting:**
1. Duplicate sprite layer
2. Shade using lighting from desired angle
3. Export both: base sprite + normal map sprite
4. Engine applies lighting dynamically

### Technique 2: Palette Swapping

**For character variations:**
1. Design character with specific palette
2. Export base sprite
3. In Aseprite: Color → Replace Color
4. Replace entire palette with variation
5. Export new sprite (same animations, different colors)
6. Engine: Shader swaps palettes at runtime

### Technique 3: Modular Characters

**For equipment/costume changes:**
1. Layer organization:
   - Base body layer
   - Hair layer (separate)
   - Equipment layer (separate)
   - Accessory layer (separate)
2. Export layers separately
3. Engine combines layers in real-time

### Technique 4: VFX Animation

**For particle effects:**
1. Small canvas (32x32 or 64x64)
2. 4-8 frame loop
3. Starts large, shrinks to nothing OR
4. Starts nothing, grows, shrinks
5. Use additive blending in engine

---

## VIII. Quality Control Checklist

Before finalizing any asset:

**Visual Checks:**
- [ ] Readable at 100% zoom
- [ ] Silhouette is clear
- [ ] Colors from approved palette only
- [ ] No "orphan pixels" (single pixels in wrong places)
- [ ] Outlines consistent thickness
- [ ] Shading follows light source
- [ ] Animation is smooth (no jarring transitions)
- [ ] Frame timings feel right

**Technical Checks:**
- [ ] Transparent background (no white/black BG)
- [ ] Sprite dimensions correct
- [ ] Exported to correct folder
- [ ] JSON data exported with sprite sheet
- [ ] File naming follows convention
- [ ] Tags properly labeled
- [ ] No unnecessary frames/layers

**Engine Integration Checks:**
- [ ] Imports correctly into Godot
- [ ] Animations play at correct speed
- [ ] Collision boxes align with sprite
- [ ] No visual artifacts in-game
- [ ] Performs well (no frame drops)

---

## IX. Workflow Optimization Tips

### Speed Up Production:

**1. Custom Brushes**
- Create brushes for common shapes
- Hair strands brush
- Grass tuft brush
- Save in Brush presets

**2. Use Cel Linking**
- Timeline → Link Cels
- Parts of sprite that don't change between frames
- Link multiple frames to same cel
- Example: Idle animation - body linked, only arms/head animate

**3. Symmetry Tool**
- Edit → Symmetry Options
- Vertical or Horizontal symmetry
- For characters/objects with symmetry
- Draw one side, other side mirrors

**4. Scripts/Extensions**
- Aseprite supports Lua scripts
- Community scripts for automation
- Install from Aseprite website

**5. Reference Palettes**
- Save commonly used palettes
- Palette → Save Palette
- Quickly load for new sprites

### Time Management:

**Estimated Times (With Practice):**
- Simple idle (8 frames): 2-4 hours
- Walk cycle (8 frames): 3-5 hours
- Complex attack (12 frames): 5-8 hours
- Tileset (50 tiles): 15-25 hours
- Background (full screen): 8-15 hours

**Batch Processing:**
- Do all character idles in one session
- Then all walk cycles
- Maintains consistency, builds muscle memory

---

## X. Backup & Version Control

### File Management:

**Backup Strategy:**
1. Save frequently (Ctrl+S obsessively)
2. Incremental saves: file_v01.aseprite, file_v02.aseprite
3. Major milestone saves: file_FINAL.aseprite, file_MASTER.aseprite
4. Cloud backup (Google Drive, Dropbox)
5. Local backup (external drive)

**Git Integration (Optional but Recommended):**
1. Save .aseprite files to Git
2. Commit after each major milestone
3. Commit message describes change
4. Easy rollback if needed

**Export Organization:**
```
/Exports
  /PNG (exported sprite sheets)
  /JSON (animation data)
  /Archive (old versions)
```

---

## XI. Conclusion: Professional Pipeline Summary

**Complete Workflow:**
1. **Setup**: Project structure, palettes, canvas
2. **Concept**: Silhouette, proportions, design
3. **Base Art**: Line art, flat colors
4. **Shading**: Shadows, highlights, details
5. **Animation**: Key frames, in-betweens, timing
6. **Polish**: Fine details, quality check
7. **Export**: Sprite sheets, JSON data
8. **Integration**: Import to Godot, test in-game
9. **Iteration**: Adjust based on in-game testing
10. **Finalize**: Archive source, backup files

**This pipeline enables:**
- Consistent quality across all assets
- Efficient production workflow
- Easy iteration and changes
- Professional results
- Game-ready exports

**Total estimated time to master workflow: 40-80 hours of practice**

With this Aseprite production pipeline, you'll create professional pixel art efficiently for the rhythm RPG!
