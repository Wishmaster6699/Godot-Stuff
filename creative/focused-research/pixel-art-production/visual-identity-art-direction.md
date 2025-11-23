# Visual Identity & Art Direction
## Defining Our Rhythm RPG's Unique Visual Style

---

## I. Core Visual Identity Decision

### Recommended Art Style: **"Neo-Rhythm"**

**Combination of:**
1. **Celeste's** expressive minimalist animation (emotional depth)
2. **Hyper Light Drifter's** neon color palette (musical energy)
3. **Sea of Stars'** dynamic lighting (modern polish)
4. **Dead Cells'** 3D-to-2D pipeline (production efficiency)

**Why This Works for Rhythm RPG:**
- Neon colors visualize music naturally
- Smooth animation essential for rhythm precision
- Dynamic lighting reacts to musical beats
- Efficient pipeline enables iteration on rhythm mechanics
- Minimalism keeps focus on rhythm gameplay

---

## II. Technical Specifications

### Resolution & Pixel Standards

**Display Resolution**: 1920x1080 (scales to common displays)
**Game Render Resolution**: 960x540 (2x upscale for crisp pixels)
**Pixel Perfect**: Yes, with optional CRT shader for retro feel

**Character Sprites:**
- **Player Character**: 36px height (sweet spot for detail + animation smoothness)
- **Important NPCs**: 32-36px
- **Standard NPCs**: 28-32px
- **Bosses**: 48-96px
- **Bounding Box**: Consistent 24x36px for gameplay sprites

**Environment:**
- **Tiles**: 16x16px base (allows dense detail)
- **Backgrounds**: 3-5 parallax layers
- **Foreground**: 24x24px for larger props

---

## III. Color Palette Strategy

### Master Palette System

**Base Palettes (3 Core):**
1. **Neon Rhythm** (16 colors) - Default/Urban levels
2. **Warm Acoustic** (12 colors) - Village/Cozy areas
3. **Gothic Symphony** (14 colors) - Dramatic/Boss areas

**Genre-Specific Additions:**
- Electronic: +6 vibrant colors
- Jazz: +6 noir colors
- Rock: +6 intense colors
- Classical: +6 elegant colors
- Folk: +6 natural colors
- Chiptune: Restrict to 8 colors

**Color Rules:**
- Maximum 32 colors on screen simultaneously
- Character uses 12-16 colors
- Environment uses 16-24 colors (varies by biome)
- UI uses 8-12 colors (consistent across game)
- Effects can add temporary colors (particles, flashes)

**Contrast Requirements:**
- Gameplay elements: Minimum 3:1 contrast ratio
- UI text: Minimum 4.5:1 contrast ratio
- Player character must be visible in ALL biomes

---

## IV. Animation Standards

### Frame Counts (Player Character)

**Essential Animations:**
```
Idle: 12 frames (1.2 second loop)
Walk: 8 frames (800ms loop)
Run: 10 frames (600ms loop)
Jump: 6 frames (non-looping)
Fall: 4 frames (looping)
Land: 4 frames (non-looping)
```

**Combat/Rhythm Animations:**
```
Attack_Light: 6 frames (3 variations = 18 frames total)
Attack_Medium: 10 frames (2 variations = 20 frames total)
Attack_Heavy: 14 frames (1 variation)
Perfect_Hit: 8 frames (special glow effect)
Miss: 6 frames (stumble animation)
Hurt: 6 frames
Death: 12 frames
Victory: 16 frames
```

**Musical Performance:**
```
Guitar_Strum: 8 frames (looping)
Drum_Hit: 6 frames (looping)
Sing: 8 frames (mouth sync loop)
Dance: 12 frames × 5 moves = 60 frames
Instrument_Equip: 8 frames (per instrument)
```

**Total Player Character Frames: ~280-320 frames**

### Animation Timing Standards

**Frame Duration:**
- Standard: 83ms (12 FPS feel, smooth)
- Held: 166ms (2x, for emphasis)
- Quick: 50ms (very fast)
- Impact: 200ms (dramatic pause)

**Smoothness Priority:**
1. Player movement (walk/run) - Must be smooth
2. Rhythm attacks - Timing critical
3. Victory celebrations - Should feel good
4. Idle - Subtle, can be simpler
5. NPCs - Can be reduced frames

---

## V. Lighting & Visual Effects Philosophy

### Dynamic Lighting System

**3-Tier Lighting Approach:**

**Tier 1: Base Static Lighting**
- Time-of-day color tints (dawn/day/dusk/night)
- Ambient biome lighting (warm, cool, neutral)
- Always active, minimal performance cost

**Tier 2: Musical Dynamic Lighting**
- Lights pulse to beat (subtle)
- Character glows during combos
- Stage lights during performances
- Medium performance cost, high visual impact

**Tier 3: Special Effect Lighting**
- Lightning flashes
- Explosion illumination
- Magical spell glows
- High performance cost, used sparingly

**Inspiration Sources:**
- Sea of Stars: Dynamic lighting technical approach
- Hyper Light Drifter: Soft gradient overlays
- Eastward: 3D lighting on 2D assets

### VFX Style Guidelines

**Particle Effects:**
- Musical notes (primary VFX)
- Rhythm pulses (circular waves)
- Combo sparks (increasing intensity)
- Perfect hit bursts (star explosions)

**Screen Effects:**
- Screen shake on heavy beats (2-4 pixels)
- Flash on perfect combo (white overlay, 1 frame)
- Slow-motion on ultimate attacks (50% speed, 1-2 seconds)
- Color tint shifts for special modes

**Effect Color Coding:**
- Perfect timing: Gold/Yellow (#FFD700)
- Good timing: White (#FFFFFF)
- Miss: Red (#FF0000)
- Combo building: Cyan → Purple gradient
- Ultimate ready: Rainbow pulse

---

## VI. UI/UX Visual Design

### HUD Philosophy: Minimal & Musical

**In-Game HUD (Exploration):**
- Health: Heart icons (top-left)
- Instrument equipped: Icon (bottom-left)
- Mini-map: Corner (optional, can be toggled)
- **Screen coverage: <10%**

**In-Game HUD (Rhythm Battle):**
- Health: Simplified bar (top)
- Rhythm notes: Center (Guitar Hero style lanes)
- Combo counter: Large, center-top
- Beat indicator: Pulsing circle (tracks tempo)
- **Screen coverage: 25-30% (necessary for rhythm gameplay)**

**Menu Style:**
- Flat design with neon accents
- Pixel font (readable, 8px or 16px height)
- Animated transitions (slide, fade)
- Musical theme (staff lines, note icons)

**Color Scheme:**
- BG: Dark (#0d1b2a)
- Primary: Neon Pink (#ff006e)
- Secondary: Cyan (#00f5ff)
- Text: Off-white (#e0e1dd)
- Disabled: Gray (#778da9)

---

## VII. Biome Visual Identity Guide

### Mandatory Biomes (MVP):

**1. Harmony Haven (Starting Town)**
- Palette: Warm Acoustic
- Style: Cozy, welcoming, tutorial-friendly
- Music: Folk, Acoustic
- Lighting: Warm, golden hour
- Reference: Stardew Valley + Eastward

**2. Neon District (Urban Hub)**
- Palette: Neon Rhythm
- Style: Cyberpunk lite, music venues, nightlife
- Music: Electronic, Hip-Hop, Pop
- Lighting: Neon signs, artificial lights, dark sky
- Reference: Hyper Light Drifter + Katana ZERO

**3. Crystal Caverns (Underground)**
- Palette: Crystal Cavern
- Style: Glowing, mysterious, ethereal
- Music: Ambient, Electronic
- Lighting: Emissive crystals, point lights
- Reference: Terraria + Axiom Verge

### Stretch Goal Biomes:

**4. Verdant Grove (Forest)**
- Palette: Forest Canopy
- Music: Folk, Nature sounds
- Reference: Eastward

**5. Frost Peaks (Mountain)**
- Palette: Frozen Peaks
- Music: Piano, Orchestral
- Reference: Celeste

**6. Glitch Void (Corrupted Area)**
- Palette: Corrupted Glitch
- Music: Glitch, Experimental
- Reference: Axiom Verge

---

## VIII. Character Design Guidelines

### Player Character: "Tempo" (Placeholder Name)

**Visual Traits:**
- Headphones (signature element, always visible)
- Casual modern clothing
- One vibrant accent color (neon pink or cyan)
- Medium-length hair (allows for hair animation)
- Expressive even without detailed face

**Design Philosophy:**
- Silhouette must be iconic (recognizable as pure black shape)
- Gender-neutral or customizable
- Relatable, not overly "heroic" looking
- Music lover vibe, not warrior

**Reference Mix:**
- Celeste's Madeline (relatability, emotion)
- Hyper Light Drifter's Drifter (iconic silhouette)
- Modern indie protagonist (hoodie, casual)

### NPC Design Variety

**Categories:**
1. **Musicians (Important NPCs)**: Unique sprites, detailed, memorable
2. **Town Folk**: 5-6 base sprites, palette swaps for variety
3. **Audience Members**: Simple, animated reactions
4. **Bosses**: Large, detailed, multiple phases

**Visual Coding:**
- NPCs with quests: Exclamation mark icon
- Shopkeepers: Distinct colors (merchant green, etc.)
- Musicians: Hold/wear instruments

---

## IX. Environmental Art Direction

### Composition Principles

**Rule of Thirds:**
- Important elements at intersection points
- Horizon line at 1/3 or 2/3 height
- Player character slightly off-center

**Depth Through:**
- 3-5 parallax layers (minimum 3)
- Color desaturation (far = less saturated)
- Detail reduction (far = less detail)
- Atmospheric fog/haze

**Visual Flow:**
- Use leading lines (paths, architecture)
- Direct player attention with lighting
- Negative space for readability

### Atmospheric Goals

**Each Biome Should Feel:**
1. **Distinct**: Immediately recognizable
2. **Musical**: Visual elements reflect music genre
3. **Alive**: Animated elements, living world
4. **Explorable**: Hidden areas, visual secrets
5. **Performable**: Space for musical performances

---

## X. Production Art Direction

### Workflow Pipeline Decision

**Recommended: Hybrid Approach**

**For Player Character & Bosses:**
- Use Dead Cells 3D-to-2D pipeline
- Faster iteration on complex animations
- Allows precise timing adjustments for rhythm

**For NPCs & Environment:**
- Traditional frame-by-frame in Aseprite
- More control over pixel-perfect details
- Simpler animations don't need 3D pipeline

**For VFX:**
- Aseprite for base effects
- After Effects for complex rhythm visualizations
- Export as sprite sheets

### Outsourcing Strategy (If Team Expands)

**Art Direction Stays In-House:**
- Lead artist defines style
- Creates character style guides
- Approves all major assets

**Can Outsource:**
- NPC variations (with style guide)
- Environmental props (with reference)
- VFX particles (with examples)
- UI icons (with specifications)

**Never Outsource:**
- Player character design
- Key boss designs
- Core visual identity decisions
- Musical performance animations (too critical)

---

## XI. Consistency Checklist

Before any asset is finalized:

**Visual Consistency:**
- [ ] Matches established color palette
- [ ] Follows resolution standards
- [ ] Lighting direction consistent
- [ ] Outline thickness consistent (if using outlines)
- [ ] Shading style matches other assets
- [ ] Readable at 1x zoom (no upscaling)

**Technical Consistency:**
- [ ] File naming convention followed
- [ ] Exported to correct folder
- [ ] Frame timing documented
- [ ] Sprite sheet properly formatted
- [ ] Transparent background (RGBA)

**Thematic Consistency:**
- [ ] Fits musical theme of biome/context
- [ ] Character personality visible
- [ ] Matches game's tone (fun, expressive, musical)

---

## XII. Mood Board References

### Primary Inspirations (70% Influence)

1. **Hyper Light Drifter** - Neon color palette, atmospheric lighting, minimalist storytelling
2. **Sea of Stars** - Dynamic lighting, modern JRPG feel, vibrant colors
3. **Celeste** - Expressive animation, emotional resonance, minimalist design
4. **Dead Cells** - Smooth combat animation, efficient pipeline, satisfying feedback

### Secondary Inspirations (30% Influence)

5. **Eastward** - Cozy environments, detailed backgrounds, warm lighting
6. **Katana ZERO** - Cinematic presentation, neon noir aesthetic
7. **Pizza Tower** - Exaggerated animation, energetic personality
8. **Stardew Valley** - Accessible, cozy, inviting world

### Musical Visual References

- **Album Covers**: Daft Punk (neon), Pink Floyd (atmospheric)
- **Concert Visuals**: EDM stage design, rock concert lighting
- **Music Videos**: Pixel art music videos, rhythm visualizers

---

## XIII. Visual Identity Statement

**"Neo-Rhythm is a visual style that makes music visible."**

Every pixel, every color, every animation serves the core rhythm gameplay. The world pulses with musical energy. Neon lights synchronize to beats. Characters express emotion through exaggerated movement. Environments react to performances.

**Core Pillars:**
1. **Musical**: Everything ties to music
2. **Expressive**: Emotion over realism
3. **Vibrant**: Bold colors, high energy
4. **Smooth**: 60+ fps animation, fluid movement
5. **Accessible**: Clear visuals, readable gameplay

**This is not a retro game with pixel art. This is a modern musical experience that uses pixel art as its medium.**

---

## XIV. Implementation Roadmap

### Phase 1: Establish Foundation (Months 1-2)
- Finalize player character design
- Create 3 core palettes
- Build Harmony Haven (starter town)
- Implement basic lighting system

### Phase 2: Core Loop Art (Months 3-4)
- Complete player animation set
- Create rhythm battle arena
- Design musical note VFX
- Build combo effect system

### Phase 3: Expand Content (Months 5-8)
- Neon District biome
- Crystal Caverns biome
- 10+ NPC designs
- 3+ boss designs

### Phase 4: Polish & Effects (Months 9-10)
- Advanced lighting effects
- Particle system expansion
- Environmental animations
- UI/UX refinement

### Phase 5: Final Art Pass (Months 11-12)
- Quality consistency pass
- Additional biomes (if time permits)
- Marketing art assets
- Trailer visuals

---

This visual identity creates a cohesive, memorable, musical pixel art experience that stands out in the crowded pixel art indie game market while remaining achievable with a small team and realistic timeline.
