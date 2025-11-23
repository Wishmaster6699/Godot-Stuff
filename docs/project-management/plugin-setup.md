# Plugin Setup Guide
## Required & Optional Plugins for Rhythm RPG

**Version:** 1.0
**Date:** 2025-11-17
**Target:** Godot 4.5.1
**Purpose:** Document all required plugins with installation and verification steps

---

## 🎯 Plugin Overview

### Required Plugins (MUST INSTALL)

| Plugin | Purpose | Priority | Systems Affected |
|--------|---------|----------|------------------|
| GUT (Godot Unit Test) | Testing framework | 🔴 Critical | Framework, All Systems |
| Phantom Camera | Smooth camera system | 🔴 Critical | S03 Player, S16 Grind Rails, S15 Vehicles |

### Recommended Plugins (SHOULD INSTALL)

| Plugin | Purpose | Priority | Systems Affected |
|--------|---------|----------|------------------|
| Aseprite Wizard | Import Aseprite animations | 🟡 High | S03 Player, S04 Combat, S11 Enemy AI, ALL sprites |
| Dialogic 2 | Dialog system | 🟡 High | S22 NPCs, S23 Story |
| Beehave | Behavior trees for AI | 🟡 High | S11 Enemy AI, S12 Monster DB |

### Optional Plugins (NICE TO HAVE)

| Plugin | Purpose | Priority | Systems Affected |
|--------|---------|----------|------------------|
| Godot Jolt | Advanced physics | 🟢 Low | S15 Vehicles (if using advanced physics) |

---

## 📦 Required Plugin #1: GUT (Godot Unit Test)

### Purpose
Essential testing framework that integrates with our Integration Test Suite.

### Godot 4.5 Compatibility
✅ **Fully Compatible** - GUT 9.2.1+ supports Godot 4.5

### Installation

**GitHub:** https://github.com/bitwes/Gut
**Latest Compatible Version:** v9.2.1 or newer
**License:** MIT

**Installation Steps:**

1. **Download from Asset Library (Recommended)**
   ```bash
   # In Godot Editor:
   # 1. AssetLib tab → Search "GUT"
   # 2. Download version 9.2.1+
   # 3. Install to addons/gut/
   ```

2. **OR Manual Installation**
   ```bash
   cd addons
   git clone https://github.com/bitwes/Gut.git gut
   cd gut
   git checkout v9.2.1
   ```

3. **Enable Plugin**
   ```bash
   # In Godot Editor:
   # Project → Project Settings → Plugins
   # Enable "Gut" checkbox
   ```

### Verification

**Test 1: Plugin Enabled**
```bash
# Check plugin is active
# Project Settings → Plugins → Gut should show "Enabled"
```

**Test 2: GUT Panel Visible**
```bash
# Bottom panel should show "GUT" tab
# Click GUT tab - should show test runner interface
```

**Test 3: Run Sample Test**
```gdscript
# Create test_gut_working.gd in tests/
extends GutTest

func test_gut_is_working():
    assert_true(true, "GUT is working!")
```

```bash
# Run in GUT panel
# Should see: 1 test passed
```

### Integration with Framework

**Used by:**
- Integration Test Suite (Component 1)
- CI Test Runner (Component 4)
- All system integration tests

**Configuration:**
```gdscript
# .gutconfig.json (create in project root)
{
  "dirs": ["res://tests/"],
  "include_subdirs": true,
  "prefix": "test_",
  "suffix": ".gd"
}
```

---

## 📦 Required Plugin #2: Phantom Camera

### Purpose
Smooth camera system with beat-synced movement for rhythm game feel.

### Godot 4.5 Compatibility
✅ **Fully Compatible** - Phantom Camera 0.7+ supports Godot 4.5

### Installation

**GitHub:** https://github.com/ramokz/phantom-camera
**Latest Compatible Version:** v0.7.0 or newer
**License:** MIT

**Installation Steps:**

1. **Download from Asset Library (Recommended)**
   ```bash
   # In Godot Editor:
   # 1. AssetLib tab → Search "Phantom Camera"
   # 2. Download version 0.7+
   # 3. Install to addons/phantom_camera/
   ```

2. **OR Manual Installation**
   ```bash
   cd addons
   git clone https://github.com/ramokz/phantom-camera.git phantom_camera
   cd phantom_camera
   git checkout v0.7.0
   ```

3. **Enable Plugin**
   ```bash
   # In Godot Editor:
   # Project → Project Settings → Plugins
   # Enable "Phantom Camera" checkbox
   ```

### Verification

**Test 1: Plugin Enabled**
```bash
# Check plugin is active
# Project Settings → Plugins → Phantom Camera should show "Enabled"
```

**Test 2: Node Types Available**
```bash
# Create new node (+ button in scene tree)
# Search for "PhantomCamera2D" or "PhantomCamera3D"
# Should appear in node list
```

**Test 3: Create Test Scene**
```gdscript
# Create test_phantom_camera.tscn
# Add PhantomCamera2D node
# Should configure without errors
```

### Integration with Framework

**Used by:**
- S03 Player Controller (follow player)
- S16 Grind Rails (smooth rail following)
- S15 Vehicles (vehicle camera)
- S04 Combat (dynamic combat camera)

**Key Features for Rhythm Game:**
- Beat-synced camera shake
- Smooth follow with damping
- Priority system for camera switching
- Tween-based transitions

---

## 📦 Recommended Plugin #1: Aseprite Wizard

### Purpose
Import Aseprite animations directly into Godot without manual PNG export.

### Godot 4.5 Compatibility
✅ **Fully Compatible** - Aseprite Wizard 5.1.0+ supports Godot 4.5

### Installation

**GitHub:** https://github.com/viniciusgerevini/godot-aseprite-wizard
**Latest Compatible Version:** v5.1.0 or newer
**License:** MIT

**Installation Steps:**

1. **Download from GitHub**
   ```bash
   cd addons
   git clone https://github.com/viniciusgerevini/godot-aseprite-wizard.git AsepriteWizard
   cd AsepriteWizard
   git checkout v5.1.0
   ```

2. **Enable Plugin**
   ```bash
   # In Godot Editor:
   # Project → Project Settings → Plugins
   # Enable "Aseprite Wizard" checkbox
   ```

3. **Configure Aseprite Path**
   ```bash
   # Project → Project Settings → General → Aseprite
   # Set "Aseprite Command Path" to your Aseprite executable
   # Windows: C:/Program Files/Aseprite/Aseprite.exe
   # Linux: /usr/bin/aseprite
   # Mac: /Applications/Aseprite.app/Contents/MacOS/aseprite
   ```

### Verification

**Test 1: Plugin Enabled**
```bash
# Check plugin is active
# Project Settings → Plugins → Aseprite Wizard should show "Enabled"
```

**Test 2: Import Menu Available**
```bash
# Right-click in FileSystem
# Should see "Aseprite Wizard" context menu
```

**Test 3: Import Test File**
```bash
# Create test.aseprite in assets/sprites/
# Right-click → Aseprite Wizard → Import
# Should generate sprite frames and animations
```

### Integration with Framework

**Used by:**
- S03 Player Controller (player animations)
- S04 Combat (attack animations)
- S11 Enemy AI (enemy animations)
- S12 Monster DB (monster sprites)
- ALL character/sprite systems

**Key Features:**
- Import .aseprite files directly (no PNG export needed)
- Automatic sprite sheet generation
- Animation import with tags
- Layer support
- Frame-by-frame control

**Workflow:**
1. Create animations in Aseprite
2. Tag animations (idle, walk, attack, etc.)
3. Save as `.aseprite` file in project
4. Right-click → Import with Aseprite Wizard
5. Godot generates sprite frames + AnimationPlayer automatically

---

## 📦 Recommended Plugin #2: Dialogic 2

### Purpose
Visual novel-style dialog system for NPCs and story sequences.

### Godot 4.5 Compatibility
✅ **Fully Compatible** - Dialogic 2.0+ rebuilt for Godot 4.x

### Installation

**GitHub:** https://github.com/dialogic-godot/dialogic
**Latest Compatible Version:** v2.0-beta6 or newer
**License:** MIT

**Installation Steps:**

1. **Download from Asset Library (Recommended)**
   ```bash
   # In Godot Editor:
   # 1. AssetLib tab → Search "Dialogic"
   # 2. Download Dialogic 2.0+ (NOT 1.x)
   # 3. Install to addons/dialogic/
   ```

2. **OR Manual Installation**
   ```bash
   cd addons
   git clone https://github.com/dialogic-godot/dialogic.git dialogic
   cd dialogic
   git checkout 2.0-beta6
   ```

3. **Enable Plugin**
   ```bash
   # In Godot Editor:
   # Project → Project Settings → Plugins
   # Enable "Dialogic" checkbox
   ```

### Verification

**Test 1: Plugin Enabled**
```bash
# Check plugin is active
# Should see "Dialogic" tab in main toolbar
```

**Test 2: Create Test Timeline**
```bash
# Click Dialogic tab
# Create new timeline
# Add test dialog
# Should save without errors
```

**Test 3: Run Test Dialog**
```gdscript
# In any scene:
Dialogic.start("test_timeline")
# Should display dialog
```

### Integration with Framework

**Used by:**
- S22 NPCs (NPC conversations)
- S23 Story System (cutscenes, story beats)
- S05 Inventory (item descriptions)
- S24 Cooking (recipe instructions)

**Rhythm Integration:**
- Time dialog advances to beat
- Beat-synced text reveals
- Rhythm minigames in dialog

---

## 📦 Recommended Plugin #3: Beehave

### Purpose
Behavior tree AI system for enemy and NPC logic.

### Godot 4.5 Compatibility
✅ **Fully Compatible** - Beehave 3.0+ for Godot 4.x

### Installation

**GitHub:** https://github.com/bitbrain/beehave
**Latest Compatible Version:** v3.1.0 or newer
**License:** MIT

**Installation Steps:**

1. **Download from Asset Library (Recommended)**
   ```bash
   # In Godot Editor:
   # 1. AssetLib tab → Search "Beehave"
   # 2. Download version 3.1+
   # 3. Install to addons/beehave/
   ```

2. **OR Manual Installation**
   ```bash
   cd addons
   git clone https://github.com/bitbrain/beehave.git beehave
   cd beehave
   git checkout v3.1.0
   ```

3. **Enable Plugin**
   ```bash
   # In Godot Editor:
   # Project → Project Settings → Plugins
   # Enable "Beehave" checkbox
   ```

### Verification

**Test 1: Plugin Enabled**
```bash
# Check plugin is active
# Bottom panel should show "Beehave" tab
```

**Test 2: Node Types Available**
```bash
# Create new node
# Search for "BeehaveTree"
# Should appear in node list
```

**Test 3: Create Test Behavior**
```bash
# Create test scene with BeehaveTree
# Add Selector and Action nodes
# Should configure without errors
```

### Integration with Framework

**Used by:**
- S11 Enemy AI (combat behaviors)
- S12 Monster DB (monster patterns)
- S22 NPCs (NPC behaviors)

**Rhythm Integration:**
- Beat-synced AI decisions
- Rhythm-based attack patterns
- Musical behavior transitions

---

## 📦 Optional Plugin: Godot Jolt

### Purpose
Jolt physics engine integration (faster, more stable than default).

### Godot 4.5 Compatibility
✅ **Compatible** - Godot Jolt 0.12+ supports Godot 4.5

### Installation

**GitHub:** https://github.com/godot-jolt/godot-jolt
**Latest Compatible Version:** v0.12.0 or newer
**License:** MIT

**⚠️ Note:** Requires native library compilation or prebuilt binaries.

**Installation Steps:**

1. **Download Prebuilt Binary**
   ```bash
   # Visit releases: https://github.com/godot-jolt/godot-jolt/releases
   # Download for your platform (Windows/Linux/Mac)
   # Extract to project root
   ```

2. **Enable in Project Settings**
   ```bash
   # Project → Project Settings → Physics
   # Physics Engine: Switch from "GodotPhysics3D" to "Jolt3D"
   ```

### Verification

**Test 1: Physics Engine Changed**
```bash
# Project Settings → Physics → 3D
# Should show "Jolt3D" as active engine
```

**Test 2: Run Physics Test**
```gdscript
# Create test scene with RigidBody3D
# Should simulate with Jolt physics
```

### When to Use

**Use Jolt if:**
- S15 Vehicles uses complex physics
- Need better performance with many physics objects
- Want more stable vehicle physics

**Skip Jolt if:**
- Project is mostly 2D
- Using simple physics
- Want to avoid native library dependencies

---

## 🔧 Plugin Installation Order

**Recommended order to avoid conflicts:**

1. ✅ **GUT** (testing framework - no dependencies)
2. ✅ **Phantom Camera** (camera system - no dependencies)
3. ✅ **Aseprite Wizard** (animation import - no dependencies)
4. ✅ **Dialogic** (dialog system - may add custom nodes)
5. ✅ **Beehave** (AI system - no conflicts)
6. ✅ **Godot Jolt** (last - changes core physics)

**Why this order:**
- GUT first so you can test each plugin after installation
- Phantom Camera and Aseprite Wizard early (commonly used, no dependencies)
- Dialogic before Beehave (Beehave may reference dialog nodes)
- Jolt last (changes fundamental engine behavior)

---

## ✅ Post-Installation Checklist

### For All Agents

After installing plugins:

- [ ] All plugins show "Enabled" in Project Settings → Plugins
- [ ] No error messages in Output panel
- [ ] Test scenes created for each plugin
- [ ] Each plugin's custom nodes appear in "Create New Node" dialog
- [ ] Project opens without errors
- [ ] Git commit plugin installation

### Git Tracking

**What to commit:**
```bash
git add addons/gut/
git add addons/phantom_camera/
git add addons/dialogic/
git add addons/beehave/
# Note: Godot Jolt binaries may be .gitignored (too large)
```

**What to .gitignore:**
```
# .gitignore additions
addons/*/bin/           # Native plugin binaries
addons/*/.import/       # Import cache
*.so                    # Linux libraries
*.dylib                 # Mac libraries
*.dll                   # Windows libraries (if > 100MB)
```

### Verification Script

Create `scripts/verify_plugins.gd` to verify all plugins:

```gdscript
# Godot 4.5 | GDScript 4.5
# Verify all required plugins are installed
extends SceneTree

func _init() -> void:
    print("\n🔌 Plugin Verification\n")
    print("═" * 60)

    var required_plugins := [
        "res://addons/gut/gut.gd",
        "res://addons/phantom_camera/phantom_camera_2d.gd",
    ]

    var recommended_plugins := [
        "res://addons/AsepriteWizard/plugin.cfg",
        "res://addons/dialogic/plugin.cfg",
        "res://addons/beehave/plugin.cfg",
    ]

    var all_present := true

    print("\n✅ Required Plugins:")
    for plugin_path in required_plugins:
        if FileAccess.file_exists(plugin_path):
            print("  ✓ %s" % plugin_path.get_file())
        else:
            print("  ✗ MISSING: %s" % plugin_path.get_file())
            all_present = false

    print("\n🟡 Recommended Plugins:")
    for plugin_path in recommended_plugins:
        if FileAccess.file_exists(plugin_path):
            print("  ✓ %s" % plugin_path.get_file())
        else:
            print("  ⊘ Not installed: %s" % plugin_path.get_file())

    print("\n" + "═" * 60)

    if all_present:
        print("✅ All required plugins present!")
        quit(0)
    else:
        print("❌ Some required plugins missing!")
        quit(1)
```

**Run verification:**
```bash
godot --script scripts/verify_plugins.gd
```

---

## 🆘 Troubleshooting

### Plugin Won't Enable

**Symptom:** Plugin checkbox stays unchecked or errors on enable

**Solutions:**
1. Check Godot version (must be 4.5+)
2. Check plugin version (must support Godot 4.x)
3. Restart Godot Editor
4. Check Output panel for error messages
5. Verify plugin.cfg exists in plugin directory

### Missing Nodes After Installation

**Symptom:** Custom node types don't appear in "Create New Node"

**Solutions:**
1. Restart Godot Editor
2. Project → Reload Current Project
3. Check plugin is actually enabled
4. Verify plugin files aren't corrupted

### Conflicts Between Plugins

**Symptom:** Errors when multiple plugins enabled

**Solutions:**
1. Install plugins one at a time
2. Test each plugin individually
3. Check plugin GitHub issues for known conflicts
4. Update to latest versions

### Performance Issues After Jolt

**Symptom:** Worse performance after installing Jolt physics

**Solutions:**
1. Verify you downloaded correct binary for your platform
2. Check Jolt is actually active (Project Settings → Physics)
3. Jolt may be slower on very simple scenes (switch back to GodotPhysics)

---

## 📚 Additional Resources

### Plugin Documentation

- **GUT:** https://github.com/bitwes/Gut/wiki
- **Phantom Camera:** https://phantom-camera.dev/
- **Dialogic:** https://docs.dialogic.pro/
- **Beehave:** https://bitbrain.github.io/beehave/
- **Godot Jolt:** https://github.com/godot-jolt/godot-jolt/wiki

### Godot 4.5 Plugin Development

- Official Plugin Tutorial: https://docs.godotengine.org/en/stable/tutorials/plugins/
- Asset Library: https://godotengine.org/asset-library/

---

## 🔄 Plugin Update Strategy

### When to Update

**Update plugins:**
- When Godot 4.5.x patch releases fix bugs
- When plugin has critical security fixes
- When plugin adds needed features

**DON'T update plugins:**
- Mid-development of a system
- When all agents are actively working
- Without testing in separate branch first

### Update Procedure

1. **Create backup branch**
   ```bash
   git checkout -b backup-before-plugin-update
   git push
   ```

2. **Update plugin in separate branch**
   ```bash
   git checkout -b update-plugin-name
   # Update plugin files
   ```

3. **Test thoroughly**
   ```bash
   # Run all integration tests
   godot --script scripts/ci_runner.gd

   # Test affected systems
   # Verify plugin-specific features
   ```

4. **Merge if successful**
   ```bash
   git checkout main
   git merge update-plugin-name
   ```

---

**END OF PLUGIN SETUP GUIDE**

**Next Steps:**
1. Install required plugins (GUT, Phantom Camera)
2. Run verification script
3. Proceed with framework setup
