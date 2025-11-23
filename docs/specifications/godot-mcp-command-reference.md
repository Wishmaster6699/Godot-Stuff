# Godot MCP Command Reference

**Created:** 2025-11-18
**Version:** 1.0
**MCP Server:** GDAI MCP (gdaimcp.com)
**Memory Server:** Basic Memory MCP
**Godot Version:** 4.5.1

---

## Table of Contents

1. [File Operations](#1-file-operations)
2. [Scene Operations](#2-scene-operations)
3. [Node Operations](#3-node-operations)
4. [Script Operations](#4-script-operations)
5. [Testing & Debugging Operations](#5-testing--debugging-operations)
6. [Memory Operations (Basic Memory MCP)](#6-memory-operations-basic-memory-mcp)
7. [Common Workflows](#7-common-workflows)
8. [Troubleshooting Guide](#8-troubleshooting-guide)

---

## Overview

This reference provides **exact command syntax** for GDAI MCP tools used in Rhythm RPG development. Every example uses **real working commands**, not templates or placeholders.

**GDAI MCP tools are accessed through the MCP protocol.** Commands shown below represent the tool invocations you'll make through your MCP client (Claude, Cursor, etc.).

---

## 1. File Operations

### get_filesystem_tree

**Purpose:** Get recursive tree view of project files with optional filtering

**Syntax:**
```
get_filesystem_tree(filter: Optional[string])
```

**Parameters:**
- `filter` (optional): File type to filter by (e.g., "gd", "tscn", "json", "png")

**Working Example:**
```
# Get all GDScript files
get_filesystem_tree("gd")

# Get all scene files
get_filesystem_tree("tscn")

# Get all JSON data files
get_filesystem_tree("json")

# Get entire project tree (no filter)
get_filesystem_tree()
```

**Returns:**
```
res://
├── scenes/
│   ├── player/
│   │   └── player.tscn
│   └── enemies/
│       └── enemy_base.tscn
├── scripts/
│   └── player/
│       └── player.gd
└── data/
    └── enemies/
        └── enemy_template.json
```

**Use when:**
- Finding where specific file types are located
- Verifying file structure before creating new files
- Checking if a file path already exists

**Common Errors:**
- Invalid filter: Use file extensions without dot (e.g., "gd" not ".gd")

---

### search_files

**Purpose:** Recursively search filesystem for files matching a query using fuzzy search

**Syntax:**
```
search_files(query: string)
```

**Parameters:**
- `query`: Search string (supports fuzzy matching)

**Working Example:**
```
# Find player-related files
search_files("player")
Returns:
  - res://scenes/player/player.tscn
  - res://scripts/player/player.gd
  - res://data/config/player_config.json

# Find enemy scripts
search_files("enemy")
Returns:
  - res://scripts/enemies/enemy_base.gd
  - res://scenes/enemies/enemy_base.tscn

# Find specific file by partial name
search_files("health")
Returns:
  - res://scripts/ui/health_bar.gd
  - res://scenes/ui/health_bar.tscn
```

**Use when:**
- You know part of a filename but not the full path
- Searching for all files related to a feature
- Verifying if a similarly named file already exists

**Common Errors:**
- Query too generic (e.g., "script" returns hundreds of results)
- Solution: Be more specific (e.g., "player_script")

---

### edit_file

**Purpose:** Edit a file by performing find and replace operation

**Syntax:**
```
edit_file(file_path: string, find: string, replace: string)
```

**Parameters:**
- `file_path`: Absolute path to file (e.g., "res://scripts/player.gd")
- `find`: Exact text to find
- `replace`: Text to replace with

**Working Example:**
```
# Update player speed value
edit_file(
  "res://scripts/player/player.gd",
  "var speed: float = 200.0",
  "var speed: float = 250.0"
)

# Fix typo in comment
edit_file(
  "res://scripts/enemies/enemy_base.gd",
  "# Handel movement",
  "# Handle movement"
)

# Update JSON data
edit_file(
  "res://data/enemies/goblin.json",
  "\"hp\": 50",
  "\"hp\": 75"
)
```

**Use when:**
- Making small, targeted changes to existing files
- Updating specific values or text
- Fixing typos or errors

**Verification:**
```
# After editing, verify with:
view_script("res://scripts/player/player.gd")
```

**Common Errors:**
- `find` text doesn't match exactly (case-sensitive, whitespace-sensitive)
- Solution: Use `view_script()` first to get exact text to find

---

### uid_to_project_path

**Purpose:** Convert Godot UID string to project path

**Syntax:**
```
uid_to_project_path(uid: string)
```

**Parameters:**
- `uid`: Godot UID string (format: "uid://...")

**Working Example:**
```
# Convert UID from scene reference
uid_to_project_path("uid://abcd1234efgh5678")
Returns: "res://scenes/player/player.tscn"

# Use to resolve dependencies
uid_to_project_path("uid://xyz9876abc4321")
Returns: "res://assets/sprites/player_sprite.png"
```

**Use when:**
- Debugging scene file references
- Converting .tscn file UIDs to human-readable paths
- Tracing resource dependencies

---

### project_path_to_uid

**Purpose:** Convert Godot project path to UID string

**Syntax:**
```
project_path_to_uid(path: string)
```

**Parameters:**
- `path`: Godot project path (format: "res://...")

**Working Example:**
```
# Get UID for scene file
project_path_to_uid("res://scenes/player/player.tscn")
Returns: "uid://abcd1234efgh5678"

# Get UID for resource
project_path_to_uid("res://assets/sprites/player_sprite.png")
Returns: "uid://xyz9876abc4321"
```

**Use when:**
- Creating scene references programmatically
- Understanding how Godot tracks resources internally

---

## 2. Scene Operations

### create_scene

**Purpose:** Create a new scene file with specified root node type

**Syntax:**
```
create_scene(scene_path: string, root_node_type: string)
```

**Parameters:**
- `scene_path`: Absolute path for new scene (e.g., "res://scenes/player/player.tscn")
- `root_node_type`: Godot node class name (e.g., "CharacterBody2D", "Control", "Node2D")

**Working Example:**
```
# Create player scene with CharacterBody2D root
create_scene("res://scenes/player/player.tscn", "CharacterBody2D")

# Create UI scene with Control root
create_scene("res://scenes/ui/health_bar.tscn", "Control")

# Create enemy scene with CharacterBody2D root
create_scene("res://scenes/enemies/goblin.tscn", "CharacterBody2D")

# Create level scene with Node2D root
create_scene("res://scenes/levels/level_01.tscn", "Node2D")

# Create generic container scene
create_scene("res://scenes/managers/game_manager.tscn", "Node")
```

**Verification:**
```
# Verify scene was created
get_filesystem_tree("tscn")

# View scene structure
get_scene_tree()
```

**Common Errors:**
- Directory doesn't exist: Scene creation fails if parent directory missing
- Solution: Create directories manually or ensure path exists first
- Invalid node type: "CharacterBody2d" vs "CharacterBody2D" (case-sensitive)

---

### open_scene

**Purpose:** Open a scene in the Godot editor

**Syntax:**
```
open_scene(scene_path: string)
```

**Parameters:**
- `scene_path`: Absolute path to scene file

**Working Example:**
```
# Open player scene for editing
open_scene("res://scenes/player/player.tscn")

# Open test scene
open_scene("res://tests/test_player_movement.tscn")

# Open UI scene
open_scene("res://scenes/ui/main_menu.tscn")
```

**Use when:**
- Switching between scenes for editing
- Preparing to add nodes or modify scene
- Setting up before using `get_scene_tree()`

**Note:** This changes the active scene in the Godot editor

---

### delete_scene

**Purpose:** Delete a scene file

**Syntax:**
```
delete_scene(scene_path: string)
```

**Parameters:**
- `scene_path`: Absolute path to scene file to delete

**Working Example:**
```
# Delete old test scene
delete_scene("res://tests/old_test.tscn")

# Remove deprecated scene
delete_scene("res://scenes/deprecated/old_player.tscn")
```

**Warning:** This permanently deletes the file. Use with caution.

**Verification:**
```
# Verify deletion
get_filesystem_tree("tscn")
```

---

### add_scene

**Purpose:** Add a scene as a node instance to a parent node in the current scene

**Syntax:**
```
add_scene(parent_path: string, scene_path: string, node_name: string)
```

**Parameters:**
- `parent_path`: Node path to parent (e.g., "." for root, "Player/Body" for nested)
- `scene_path`: Path to scene file to instance
- `node_name`: Name for the instanced node

**Working Example:**
```
# Add player scene to main game scene
open_scene("res://scenes/main.tscn")
add_scene(".", "res://scenes/player/player.tscn", "Player")

# Add enemy to level scene
open_scene("res://scenes/levels/level_01.tscn")
add_scene("Enemies", "res://scenes/enemies/goblin.tscn", "Goblin1")

# Add UI overlay to game scene
open_scene("res://scenes/main.tscn")
add_scene("UI", "res://scenes/ui/health_bar.tscn", "HealthBar")
```

**Verification:**
```
# Check scene tree after adding
get_scene_tree()
```

**Common Errors:**
- Parent path doesn't exist: Verify parent node with `get_scene_tree()` first
- Scene path invalid: Use `search_files()` to find correct path

---

### get_scene_tree

**Purpose:** Get recursive tree view of all nodes in current scene with visibility and script info

**Syntax:**
```
get_scene_tree()
```

**Parameters:** None

**Working Example:**
```
# Open scene first
open_scene("res://scenes/player/player.tscn")

# Get full scene tree
get_scene_tree()

Returns:
CharacterBody2D (player.gd)
├── Sprite2D [visible]
├── CollisionShape2D [visible]
└── AnimationPlayer
    └── AnimatedSprite2D [visible]
```

**Use when:**
- Verifying node hierarchy after creation
- Finding node paths for update_property commands
- Debugging scene structure
- Planning where to add new nodes

**Note:** Must have a scene open in the editor first

---

### get_scene_file_content

**Purpose:** Get raw content of scene file to see overridden properties and resources

**Syntax:**
```
get_scene_file_content(scene_path: string)
```

**Parameters:**
- `scene_path`: Absolute path to scene file

**Working Example:**
```
# View raw scene file
get_scene_file_content("res://scenes/player/player.tscn")

Returns:
[gd_scene load_steps=4 format=3 uid="uid://abcd1234"]

[ext_resource type="Script" path="res://scripts/player/player.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/sprites/player.png" id="2"]

[sub_resource type="RectangleShape2D" id="1"]
size = Vector2(32, 48)

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("1")
```

**Use when:**
- Debugging complex scene issues
- Understanding how properties are stored
- Verifying resource references
- Troubleshooting UID issues

---

### play_scene

**Purpose:** Run a scene in the Godot editor (either current scene or main project scene)

**Syntax:**
```
play_scene(scene_path: Optional[string])
```

**Parameters:**
- `scene_path` (optional): Absolute path to scene file. If omitted, plays current scene.

**Working Example:**
```
# Play current open scene
play_scene()

# Play specific test scene
play_scene("res://tests/test_player_movement.tscn")

# Play main game scene
play_scene("res://scenes/main.tscn")

# Play specific level
play_scene("res://scenes/levels/level_01.tscn")
```

**Use when:**
- Testing scene functionality
- Verifying visual appearance
- Checking for runtime errors
- Confirming scripts work as expected

**Follow up with:**
```
# Check for errors after playing
get_godot_errors()

# Get visual confirmation
get_running_scene_screenshot()

# Stop when done
stop_running_scene()
```

---

### stop_running_scene

**Purpose:** Stop the currently running scene in Godot editor

**Syntax:**
```
stop_running_scene()
```

**Parameters:** None

**Working Example:**
```
# After testing, stop the scene
stop_running_scene()
```

**Use when:**
- After completing test playthrough
- Before making changes to scenes
- Cleaning up after debugging

---

## 3. Node Operations

### add_node

**Purpose:** Add a new node to a parent node in the current scene

**Syntax:**
```
add_node(parent_path: string, node_type: string, node_name: string)
```

**Parameters:**
- `parent_path`: Path to parent node (e.g., "." for root, "Player" for specific node)
- `node_type`: Godot node class name (e.g., "Sprite2D", "CollisionShape2D", "Label")
- `node_name`: Name for the new node

**Working Example:**
```
# Open scene first
open_scene("res://scenes/player/player.tscn")

# Add Sprite2D to root
add_node(".", "Sprite2D", "PlayerSprite")

# Add CollisionShape2D to root
add_node(".", "CollisionShape2D", "Collision")

# Add AnimationPlayer to root
add_node(".", "AnimationPlayer", "Animator")

# Add child to specific node
add_node("PlayerSprite", "PointLight2D", "Glow")

# Add UI nodes
open_scene("res://scenes/ui/health_bar.tscn")
add_node(".", "ProgressBar", "HealthBar")
add_node(".", "Label", "HealthText")

# Add collision layers
open_scene("res://scenes/enemies/goblin.tscn")
add_node(".", "Area2D", "HitBox")
add_node("HitBox", "CollisionShape2D", "HitShape")
```

**Common Node Types:**
- **2D:** Node2D, Sprite2D, AnimatedSprite2D, CharacterBody2D, Area2D, CollisionShape2D, RigidBody2D
- **UI:** Control, Label, Button, ProgressBar, TextureProgressBar, Panel, VBoxContainer, HBoxContainer
- **Utility:** AnimationPlayer, Timer, AudioStreamPlayer2D, Camera2D, CanvasLayer

**Verification:**
```
# Check node was added
get_scene_tree()
```

**Common Errors:**
- Parent path doesn't exist: Use `get_scene_tree()` to verify parent first
- Invalid node type: Check exact class name (case-sensitive) in Godot docs
- Duplicate node name: Each child must have unique name under same parent

---

### delete_node

**Purpose:** Delete a node (except root) from the current scene

**Syntax:**
```
delete_node(node_path: string)
```

**Parameters:**
- `node_path`: Path to node to delete (cannot be root ".")

**Working Example:**
```
# Open scene first
open_scene("res://scenes/player/player.tscn")

# Delete specific node
delete_node("OldSprite")

# Delete nested node
delete_node("Body/DeprecatedCollision")

# Clean up test nodes
delete_node("DebugLabel")
```

**Verification:**
```
get_scene_tree()
```

**Common Errors:**
- Cannot delete root node: Use `delete_scene()` instead
- Node path doesn't exist: Verify with `get_scene_tree()` first

---

### duplicate_node

**Purpose:** Duplicate an existing node in the scene

**Syntax:**
```
duplicate_node(node_path: string, new_name: string)
```

**Parameters:**
- `node_path`: Path to node to duplicate
- `new_name`: Name for the duplicated node

**Working Example:**
```
# Duplicate enemy node
open_scene("res://scenes/levels/level_01.tscn")
duplicate_node("Enemies/Goblin1", "Goblin2")

# Duplicate UI element
open_scene("res://scenes/ui/hud.tscn")
duplicate_node("HealthBar", "ManaBar")

# Duplicate platform
open_scene("res://scenes/levels/level_01.tscn")
duplicate_node("Platforms/Platform1", "Platform2")
```

**Note:** Duplicated node will have same properties and children as original

**Verification:**
```
get_scene_tree()
```

---

### move_node

**Purpose:** Move a node to a different parent in the scene

**Syntax:**
```
move_node(node_path: string, new_parent_path: string)
```

**Parameters:**
- `node_path`: Path to node to move
- `new_parent_path`: Path to new parent node

**Working Example:**
```
# Move sprite under body node
open_scene("res://scenes/player/player.tscn")
add_node(".", "Node2D", "Body")
move_node("PlayerSprite", "Body")

# Reorganize UI
open_scene("res://scenes/ui/hud.tscn")
add_node(".", "VBoxContainer", "LeftPanel")
move_node("HealthBar", "LeftPanel")
move_node("ManaBar", "LeftPanel")

# Restructure scene hierarchy
move_node("Effects/ParticleEffect", "Player")
```

**Verification:**
```
get_scene_tree()
```

---

### update_property

**Purpose:** Update a property of a node in the scene (does not create sub-resources)

**Syntax:**
```
update_property(node_path: string, property_name: string, value: any)
```

**Parameters:**
- `node_path`: Path to node
- `property_name`: Godot property name (check docs for exact names)
- `value`: New value (type must match property type)

**Working Example:**
```
# Open scene first
open_scene("res://scenes/player/player.tscn")

# Set node position
update_property("PlayerSprite", "position", Vector2(100, 200))

# Set sprite texture
update_property("PlayerSprite", "texture", "res://assets/sprites/player.png")

# Set collision layer
update_property(".", "collision_layer", 1)

# Configure ProgressBar
open_scene("res://scenes/ui/health_bar.tscn")
update_property("HealthBar", "max_value", 100)
update_property("HealthBar", "value", 75)
update_property("HealthBar", "size", Vector2(200, 20))

# Set label text
update_property("HealthText", "text", "Health: 75/100")

# Configure animation
open_scene("res://scenes/player/player.tscn")
update_property("Animator", "autoplay", "idle")

# Set physics properties
update_property(".", "motion_mode", 0)  # MOTION_MODE_GROUNDED
update_property(".", "floor_stop_on_slope", true)
```

**Common Property Types:**
- **Position/Size:** Vector2(x, y)
- **String:** "text value"
- **Number:** 42 (int) or 3.14 (float)
- **Boolean:** true or false
- **Resource Path:** "res://path/to/resource"
- **Color:** Color(1.0, 0.5, 0.0, 1.0)

**Finding Property Names:**
```
# Check Godot documentation for exact property names:
# https://docs.godotengine.org/en/4.5/classes/

# Common properties by node type:

Sprite2D:
- texture, position, scale, rotation, modulate, centered

CollisionShape2D:
- shape, position, disabled

Label:
- text, position, size, horizontal_alignment, vertical_alignment

ProgressBar:
- min_value, max_value, value, show_percentage, size

CharacterBody2D:
- position, collision_layer, collision_mask, motion_mode
```

**Common Errors:**
- Property name typo: Check Godot docs for exact spelling
- Wrong value type: "100" (string) vs 100 (int)
- Read-only property: Some properties can't be set directly

---

### add_resource

**Purpose:** Add a new resource or subresource as a property to a node (e.g., shape to collision, texture to sprite)

**Syntax:**
```
add_resource(node_path: string, property_name: string, resource_type: string, resource_properties: dict)
```

**Parameters:**
- `node_path`: Path to node
- `property_name`: Property to set (e.g., "shape", "texture")
- `resource_type`: Godot resource class (e.g., "RectangleShape2D", "CircleShape2D")
- `resource_properties`: Dictionary of resource properties

**Working Example:**
```
# Add collision shape to CollisionShape2D
open_scene("res://scenes/player/player.tscn")
add_resource(
  "Collision",
  "shape",
  "RectangleShape2D",
  {"size": Vector2(32, 48)}
)

# Add circle collision shape
add_resource(
  "HitBox/CollisionShape2D",
  "shape",
  "CircleShape2D",
  {"radius": 16}
)

# Add capsule shape for player
add_resource(
  "Collision",
  "shape",
  "CapsuleShape2D",
  {"radius": 12, "height": 40}
)
```

**Common Resource Types:**
- **Shapes:** RectangleShape2D, CircleShape2D, CapsuleShape2D, ConvexPolygonShape2D
- **Materials:** ShaderMaterial, CanvasItemMaterial
- **Textures:** ImageTexture, AtlasTexture

**Verification:**
```
# Verify resource added
get_scene_file_content("res://scenes/player/player.tscn")
```

---

### set_anchor_preset

**Purpose:** Set Control node anchor using a preset (for UI positioning)

**Syntax:**
```
set_anchor_preset(node_path: string, preset: string)
```

**Parameters:**
- `node_path`: Path to Control node
- `preset`: Anchor preset name

**Preset Options:**
- `top_left` - Anchored to top-left corner
- `top_right` - Anchored to top-right corner
- `bottom_left` - Anchored to bottom-left corner
- `bottom_right` - Anchored to bottom-right corner
- `center` - Centered in parent
- `center_top` - Centered horizontally at top
- `center_bottom` - Centered horizontally at bottom
- `center_left` - Centered vertically at left
- `center_right` - Centered vertically at right
- `top_wide` - Full width at top
- `bottom_wide` - Full width at bottom
- `left_wide` - Full height at left
- `right_wide` - Full height at right
- `full_rect` - Fills entire parent

**Working Example:**
```
# Open UI scene
open_scene("res://scenes/ui/hud.tscn")

# Position health bar at top-left
set_anchor_preset("HealthBar", "top_left")

# Center title label
set_anchor_preset("TitleLabel", "center_top")

# Position button at bottom-right
set_anchor_preset("PauseButton", "bottom_right")

# Make panel fill screen
set_anchor_preset("BackgroundPanel", "full_rect")

# Position mini-map at top-right
set_anchor_preset("MiniMap", "top_right")
```

**Use when:**
- Creating responsive UI layouts
- Positioning UI elements for different screen sizes
- Setting up HUD elements

---

### set_anchor_values

**Purpose:** Set precise anchor values for a Control node (advanced positioning)

**Syntax:**
```
set_anchor_values(node_path: string, left: float, top: float, right: float, bottom: float)
```

**Parameters:**
- `node_path`: Path to Control node
- `left`: Left anchor (0.0 to 1.0)
- `top`: Top anchor (0.0 to 1.0)
- `right`: Right anchor (0.0 to 1.0)
- `bottom`: Bottom anchor (0.0 to 1.0)

**Anchor Value Ranges:**
- `0.0` - Start edge (left/top)
- `0.5` - Center
- `1.0` - End edge (right/bottom)

**Working Example:**
```
# Top-left corner (manual)
set_anchor_values("HealthBar", 0.0, 0.0, 0.0, 0.0)

# Center of screen
set_anchor_values("TitleLabel", 0.5, 0.5, 0.5, 0.5)

# Full screen fill
set_anchor_values("BackgroundPanel", 0.0, 0.0, 1.0, 1.0)

# Top 20% of screen (wide)
set_anchor_values("HeaderPanel", 0.0, 0.0, 1.0, 0.2)

# Right 30% of screen (tall)
set_anchor_values("RightPanel", 0.7, 0.0, 1.0, 1.0)

# Custom centered area (50% width, 30% height, centered)
set_anchor_values("DialogBox", 0.25, 0.35, 0.75, 0.65)
```

**Use when:**
- `set_anchor_preset()` doesn't provide exact layout needed
- Creating custom responsive layouts
- Precise UI positioning for complex interfaces

**Note:** Most common cases should use `set_anchor_preset()` for simplicity

---

## 4. Script Operations

### create_script

**Purpose:** Create a GDScript file with specified content

**Syntax:**
```
create_script(file_path: string, content: string)
```

**Parameters:**
- `file_path`: Absolute path for new script (e.g., "res://scripts/player/player.gd")
- `content`: Complete GDScript code as string

**Working Example:**
```
# Create player movement script
create_script("res://scripts/player/player.gd", """
extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0

func _physics_process(delta: float) -> void:
    # Add gravity
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump
    if Input.is_action_just_pressed(\"jump\") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get input direction
    var direction := Input.get_axis(\"move_left\", \"move_right\")

    # Apply movement
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
""")

# Create simple enemy AI script
create_script("res://scripts/enemies/enemy_base.gd", """
extends CharacterBody2D
class_name EnemyBase

@export var enemy_data: Dictionary
var hp: int = 100
var speed: float = 100.0

func _ready() -> void:
    if enemy_data.is_empty():
        return
    hp = enemy_data.get(\"hp\", 100)
    speed = enemy_data.get(\"speed\", 100.0)

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        die()

func die() -> void:
    queue_free()
""")

# Create UI controller script
create_script("res://scripts/ui/health_bar.gd", """
extends ProgressBar

func update_health(current: int, maximum: int) -> void:
    max_value = maximum
    value = current
""")
```

**Important GDScript 4.5 Syntax Rules:**
```gdscript
# ✅ CORRECT: Use .repeat() for string repetition
var line := "═".repeat(60)

# ❌ WRONG: String multiplication not supported
var line := "═" * 60

# ✅ CORRECT: Always use type hints
func process_data(input: String) -> Dictionary:
    pass

# ❌ WRONG: Missing type hints
func process_data(input):
    pass

# ✅ CORRECT: Use class_name for class declarations
class_name PlayerController

# ✅ CORRECT: Explicit types for Variant returns
var result: Dictionary = JSON.parse_string(text)

# ❌ WRONG: Type inference from Variant
var result := JSON.parse_string(text)
```

**Verification:**
```
# Check script was created
get_filesystem_tree("gd")

# View script content
view_script("res://scripts/player/player.gd")
```

---

### attach_script

**Purpose:** Attach a script file to a node in the current scene

**Syntax:**
```
attach_script(node_path: string, script_path: string)
```

**Parameters:**
- `node_path`: Path to node in scene (e.g., "." for root, "Player" for specific node)
- `script_path`: Absolute path to script file

**Working Example:**
```
# Open scene first
open_scene("res://scenes/player/player.tscn")

# Attach script to root node
attach_script(".", "res://scripts/player/player.gd")

# Attach to specific node
open_scene("res://scenes/ui/health_bar.tscn")
attach_script("HealthBar", "res://scripts/ui/health_bar.gd")

# Attach enemy AI
open_scene("res://scenes/enemies/goblin.tscn")
attach_script(".", "res://scripts/enemies/enemy_base.gd")
```

**Verification:**
```
# Check script attachment in scene tree
get_scene_tree()
# Should show: CharacterBody2D (player.gd)

# Or view scene file content
get_scene_file_content("res://scenes/player/player.tscn")
# Should show: script = ExtResource("...")
```

**Common Errors:**
- Script doesn't exist: Create script first with `create_script()`
- Node path invalid: Verify with `get_scene_tree()`
- Script already attached: Will replace existing script

---

### view_script

**Purpose:** View contents of a GDScript file and make it active in the script editor

**Syntax:**
```
view_script(file_path: string)
```

**Parameters:**
- `file_path`: Absolute path to script file

**Working Example:**
```
# View player script
view_script("res://scripts/player/player.gd")

# View enemy AI script
view_script("res://scripts/enemies/enemy_base.gd")

# View manager script
view_script("res://scripts/managers/game_manager.gd")
```

**Returns:** Full content of the script file

**Use when:**
- Reviewing existing code before editing
- Finding exact text for `edit_file()` command
- Debugging script issues
- Understanding current implementation

---

### get_open_scripts

**Purpose:** Get list of all scripts currently open in Godot editor with their contents

**Syntax:**
```
get_open_scripts()
```

**Parameters:** None

**Working Example:**
```
# Get all open scripts
get_open_scripts()

Returns:
[
  {
    "path": "res://scripts/player/player.gd",
    "content": "extends CharacterBody2D\n..."
  },
  {
    "path": "res://scripts/enemies/enemy_base.gd",
    "content": "extends CharacterBody2D\n..."
  }
]
```

**Use when:**
- Reviewing what's currently being worked on
- Finding scripts to edit
- Checking if script is already open

---

### execute_editor_script

**Purpose:** Execute arbitrary GDScript in the Editor as a tool script

**Syntax:**
```
execute_editor_script(script_content: string)
```

**Parameters:**
- `script_content`: GDScript code to execute (must use `@tool` mode capabilities)

**Working Example:**
```
# Print project info
execute_editor_script("""
@tool
extends EditorScript

func _run():
    print(\"Project path: \", ProjectSettings.globalize_path(\"res://\"))
    print(\"Godot version: \", Engine.get_version_info())
""")

# List all scenes in project
execute_editor_script("""
@tool
extends EditorScript

func _run():
    var dir = DirAccess.open(\"res://scenes/\")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != \"\":
            if file_name.ends_with(\".tscn\"):
                print(file_name)
            file_name = dir.get_next()
""")
```

**Warning:** Advanced tool. Use only when standard MCP commands don't provide needed functionality.

**Use when:**
- Performing complex editor operations
- Batch processing files
- Custom project analysis

---

## 5. Testing & Debugging Operations

### get_godot_errors

**Purpose:** Get errors from Godot including script errors, runtime errors, stack traces, and output logs

**Syntax:**
```
get_godot_errors()
```

**Parameters:** None

**Working Example:**
```
# After running scene, check for errors
play_scene("res://tests/test_player_movement.tscn")
get_godot_errors()

Returns (if errors exist):
[ERROR] Invalid get index 'hp' (on base: 'Dictionary').
  At: res://scripts/enemies/enemy_base.gd:12
  Stack trace: ...

[WARNING] Unused variable: 'delta'
  At: res://scripts/player/player.gd:8

Output:
Player ready!
Game started
...
```

**Use when:**
- **ALWAYS after running a scene** to verify no errors
- Debugging script issues
- Checking for warnings
- Verifying output logs

**Best Practice:**
```xml
<test_workflow>
  <step>play_scene("res://tests/test_scene.tscn")</step>
  <step>Wait for scene to run</step>
  <step>get_godot_errors()</step>
  <step>Analyze output - any errors = test fails</step>
  <step>stop_running_scene()</step>
</test_workflow>
```

---

### clear_output_logs

**Purpose:** Clear the output logs in the editor to remove previous errors

**Syntax:**
```
clear_output_logs()
```

**Parameters:** None

**Working Example:**
```
# Clear logs before testing
clear_output_logs()

# Run test
play_scene("res://tests/test_scene.tscn")

# Check only new errors
get_godot_errors()

stop_running_scene()
```

**Use when:**
- Starting fresh test runs
- Ensuring you're seeing only current errors
- Cleaning up after previous tests

---

### get_editor_screenshot

**Purpose:** Return a screenshot of the entire Godot editor window

**Syntax:**
```
get_editor_screenshot()
```

**Parameters:** None

**Working Example:**
```
# Capture current editor state
get_editor_screenshot()

# Use for:
# - Verifying scene layout in viewport
# - Documenting editor configuration
# - Visual debugging
```

**Returns:** Image of entire Godot editor window

---

### get_running_scene_screenshot

**Purpose:** Return a screenshot of the running game window only

**Syntax:**
```
get_running_scene_screenshot()
```

**Parameters:** None

**Working Example:**
```
# Run scene
play_scene("res://scenes/player/player.tscn")

# Capture game window
get_running_scene_screenshot()

# Visual verification of:
# - Sprite rendering
# - UI positioning
# - Animation states
# - Particle effects

stop_running_scene()
```

**Use when:**
- Verifying visual appearance
- Confirming sprites loaded correctly
- Checking UI layout
- Documenting game state

**Best Practice:**
```xml
<visual_test>
  <step>play_scene(test_scene)</step>
  <step>get_running_scene_screenshot()</step>
  <step>Verify visually: sprites visible, UI positioned correctly</step>
  <step>get_godot_errors() # Check no errors</step>
  <step>stop_running_scene()</step>
</visual_test>
```

---

## 6. Memory Operations (Basic Memory MCP)

### write_note

**Purpose:** Create or update a note in the knowledge base

**Syntax:**
```
write_note(title: string, content: string, folder: Optional[string], tags: Optional[list])
```

**Parameters:**
- `title`: Note title (used for retrieval)
- `content`: Markdown-formatted content
- `folder` (optional): Directory organization (e.g., "systems", "progress")
- `tags` (optional): List of tags for categorization

**Working Example:**
```
# Save system checkpoint
write_note(
  "system_01_player_movement",
  """
  # S01: Player Movement - COMPLETE

  ## Files Created
  - res://scenes/player/player.tscn
  - res://scripts/player/player.gd
  - res://tests/test_player_movement.tscn

  ## Implementation
  - CharacterBody2D with move_and_slide()
  - Input.get_vector() for 8-directional movement
  - Gravity and jump mechanics working

  ## Testing
  - [x] Movement responds to WASD
  - [x] Jump works with space
  - [x] No console errors
  - [x] Visual verification passed

  ## Integration Points
  - Ready for S02 (Combat System) integration
  - Exports player_velocity for S08 (UI) to display

  ## Date
  2025-11-18
  """,
  "systems",
  ["s01", "player", "movement", "complete"]
)

# Save research findings
write_note(
  "godot_4_5_character_body_2d_patterns",
  """
  # CharacterBody2D Best Practices

  ## Key Patterns
  - [method] Use move_and_slide() for physics movement
  - [method] Use Input.get_vector() for directional input
  - [tip] Apply velocity *= friction for smooth deceleration

  ## Relations
  - requires [[Godot 4.5]]
  - pairs_well_with [[Area2D for detection]]

  ## Sources
  - https://docs.godotengine.org/en/4.5/tutorials/physics/using_character_body_2d.html
  """,
  "research",
  ["godot", "physics", "movement"]
)

# Save integration pattern
write_note(
  "pattern_data_driven_enemy_system",
  """
  # Pattern: Data-Driven Enemy System

  ## Approach
  - Single enemy_base.gd script
  - JSON files for each enemy type
  - DataManager autoload for loading

  ## Benefits
  - Create unlimited enemies via JSON
  - No code changes for new types
  - Easy balancing

  ## Example
  See: enemy_template.json
  """,
  "patterns",
  ["pattern", "data-driven", "enemies"]
)
```

**Content Formatting:**
- Use Markdown for structure
- Include `[method]`, `[tip]`, `[fact]` observation prefixes
- Add `#tags` for categorization
- Use `[[WikiLinks]]` for relations

**Verification:**
```
# Verify note was saved
read_note("system_01_player_movement")
```

---

### read_note

**Purpose:** Access notes by title or permalink with pagination

**Syntax:**
```
read_note(identifier: string, page: Optional[int], page_size: Optional[int])
```

**Parameters:**
- `identifier`: Note title or permalink
- `page` (optional): Page number for long notes (default: 1)
- `page_size` (optional): Items per page (default: 10)

**Working Example:**
```
# Read specific system checkpoint
read_note("system_01_player_movement")

# Read research note
read_note("godot_4_5_character_body_2d_patterns")

# Read with pagination (for long notes)
read_note("all_systems_progress", page=1, page_size=5)
read_note("all_systems_progress", page=2, page_size=5)
```

**Returns:** Full note content in Markdown format

**Use when:**
- Retrieving checkpoint data
- Reviewing prior work before starting new system
- Checking integration patterns
- Understanding previous decisions

---

### edit_note

**Purpose:** Incrementally edit an existing note

**Syntax:**
```
edit_note(identifier: string, operation: string, content: string)
```

**Parameters:**
- `identifier`: Note title or permalink
- `operation`: Edit operation ("append", "prepend", "replace")
- `content`: Content to add/replace

**Working Example:**
```
# Append test results to checkpoint
edit_note(
  "system_01_player_movement",
  "append",
  """

  ## Additional Testing
  - Tested with S02 combat integration
  - All tests still passing
  - Date: 2025-11-19
  """
)

# Prepend urgent note
edit_note(
  "system_05_inventory",
  "prepend",
  "**BLOCKED**: Waiting on S03 completion\n\n"
)

# Replace entire section
edit_note(
  "system_08_ui",
  "replace",
  "[NEW CONTENT REPLACING ENTIRE NOTE]"
)
```

**Use when:**
- Updating checkpoint with new information
- Adding test results to existing notes
- Correcting prior documentation

---

### delete_note

**Purpose:** Remove a note from the knowledge base

**Syntax:**
```
delete_note(identifier: string)
```

**Parameters:**
- `identifier`: Note title or permalink

**Working Example:**
```
# Delete deprecated checkpoint
delete_note("old_approach_player_movement")

# Remove obsolete research
delete_note("godot_3_x_patterns")
```

**Warning:** Permanent deletion. Use with caution.

---

### search

**Purpose:** Semantic search across knowledge base

**Syntax:**
```
search(query: string, page: Optional[int], page_size: Optional[int])
```

**Parameters:**
- `query`: Search query
- `page` (optional): Page number (default: 1)
- `page_size` (optional): Results per page (default: 10)

**Working Example:**
```
# Find all player-related notes
search("player movement")

# Find complete systems
search("status:complete")

# Find blocked systems
search("blocked")

# Find specific patterns
search("data-driven enemy")

# Find by tag
search("#combat")
```

**Returns:** List of matching notes with relevance scores

**Use when:**
- Finding related work before starting
- Searching for specific patterns
- Discovering existing solutions
- Checking if work already done

---

### build_context

**Purpose:** Traverse knowledge graph via memory:// URLs

**Syntax:**
```
build_context(url: string, depth: Optional[int], timeframe: Optional[string])
```

**Parameters:**
- `url`: memory:// URL to traverse
- `depth` (optional): How many relation levels to follow (default: 1)
- `timeframe` (optional): Filter by date (e.g., "last_week", "last_month")

**Working Example:**
```
# Get context for player system with related notes
build_context("memory://system_01_player_movement", depth=2)

# Get recent work context
build_context("memory://progress", timeframe="last_week")

# Explore pattern relations
build_context("memory://pattern_data_driven_enemy_system", depth=3)
```

**Returns:** Graph of connected notes following relations

**Use when:**
- Understanding how systems interconnect
- Finding all related work for a feature
- Building comprehensive context before integration

---

### list_directory

**Purpose:** Browse directory contents in knowledge base

**Syntax:**
```
list_directory(dir_name: string, depth: Optional[int])
```

**Parameters:**
- `dir_name`: Directory name (e.g., "systems", "patterns", "research")
- `depth` (optional): Recursion depth (default: 1)

**Working Example:**
```
# List all system checkpoints
list_directory("systems")

Returns:
systems/
├── system_01_player_movement.md
├── system_02_combat.md
├── system_03_abilities.md
└── ...

# List research notes
list_directory("research")

# List with subdirectories
list_directory("systems", depth=2)
```

**Use when:**
- Browsing available checkpoints
- Finding what work exists
- Organizing knowledge base

---

### list_memory_projects

**Purpose:** Display all available memory projects

**Syntax:**
```
list_memory_projects()
```

**Parameters:** None

**Working Example:**
```
list_memory_projects()

Returns:
- rhythm-rpg
- other-project
- test-project
```

**Use when:**
- Checking available projects
- Verifying correct project active

---

### create_memory_project

**Purpose:** Initialize new memory project

**Syntax:**
```
create_memory_project(project_name: string, project_path: string)
```

**Parameters:**
- `project_name`: Project identifier
- `project_path`: File system path for project memory

**Working Example:**
```
# Create new project memory space
create_memory_project("rhythm-rpg", "/home/user/vibe-code-game/memory")
```

**Use when:**
- Starting new project
- Setting up separate memory space

---

## 7. Common Workflows

### Workflow 1: Create a New System Script

**Complete process from research to checkpoint:**

```xml
<workflow name="create_system_script">

  <!-- STEP 1: Research -->
  <step id="1" name="Research">
    Web search: "Godot 4.5 [feature] best practices 2025"
    Read: Official Godot 4.5 docs
    Note: Key patterns and URLs
  </step>

  <!-- STEP 2: Create Script -->
  <step id="2" name="Create Script">
    create_script("res://scripts/[system]/[name].gd", """
    extends [BaseClass]
    class_name [ClassName]

    # Script content following Godot 4.5 syntax
    # - Type hints on all functions
    # - Use .repeat() not * for strings
    # - Explicit types for Variant returns
    """)
  </step>

  <!-- STEP 3: Verify Creation -->
  <step id="3" name="Verify">
    # Check file exists
    get_filesystem_tree("gd")

    # View content
    view_script("res://scripts/[system]/[name].gd")
  </step>

  <!-- STEP 4: Checkpoint -->
  <step id="4" name="Checkpoint">
    write_note(
      "system_[NN]_[name]_script_created",
      """
      # Script Created: [name].gd

      ## Location
      res://scripts/[system]/[name].gd

      ## Purpose
      [Description]

      ## Research Sources
      - [URL1]
      - [URL2]

      ## Next Steps
      - Create scene and attach script
      - Implement test scene
      """,
      "systems",
      ["s[NN]", "[system]", "script"]
    )
  </step>

</workflow>
```

**Real Example:**

```
# STEP 1: Research
Web search: "Godot 4.5 CharacterBody2D movement 2025"
Found: https://docs.godotengine.org/en/4.5/tutorials/physics/using_character_body_2d.html
Key: Use move_and_slide(), Input.get_vector()

# STEP 2: Create Script
create_script("res://scripts/player/player.gd", """
extends CharacterBody2D
class_name PlayerController

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed(\"jump\") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var direction := Input.get_axis(\"move_left\", \"move_right\")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
""")

# STEP 3: Verify
get_filesystem_tree("gd")
# Confirms: res://scripts/player/player.gd exists

view_script("res://scripts/player/player.gd")
# Confirms: Content matches

# STEP 4: Checkpoint
write_note(
  "system_01_player_movement_script",
  """
  # Script Created: player.gd

  ## Location
  res://scripts/player/player.gd

  ## Purpose
  Player character movement with WASD + jump

  ## Implementation
  - CharacterBody2D base
  - move_and_slide() physics
  - Input.get_vector() for direction
  - Gravity and jump mechanics

  ## Research
  - https://docs.godotengine.org/en/4.5/tutorials/physics/using_character_body_2d.html

  ## Next Steps
  - Create player.tscn scene
  - Attach script
  - Create test scene
  """,
  "systems",
  ["s01", "player", "movement", "script"]
)
```

---

### Workflow 2: Create Test Scene and Run It

**Complete test workflow:**

```xml
<workflow name="create_and_run_test">

  <!-- STEP 1: Create Test Scene -->
  <step id="1" name="Create Scene">
    create_scene("res://tests/test_[system].tscn", "Node2D")
  </step>

  <!-- STEP 2: Add Test Environment -->
  <step id="2" name="Setup Test">
    open_scene("res://tests/test_[system].tscn")

    # Add system under test
    add_scene(".", "res://scenes/[system]/[name].tscn", "[Name]")

    # Add test environment (e.g., ground platform)
    add_node(".", "StaticBody2D", "Ground")
    add_node("Ground", "CollisionShape2D", "GroundCollision")
    add_resource("Ground/GroundCollision", "shape", "RectangleShape2D", {"size": Vector2(500, 50)})

    # Add debug UI
    add_node(".", "CanvasLayer", "Debug")
    add_node("Debug", "Label", "Instructions")
    update_property("Debug/Instructions", "text", "Test: [what to test]")
  </step>

  <!-- STEP 3: Verify Scene Structure -->
  <step id="3" name="Verify Structure">
    get_scene_tree()
    # Confirm all nodes present
  </step>

  <!-- STEP 4: Run Test -->
  <step id="4" name="Run">
    clear_output_logs()
    play_scene("res://tests/test_[system].tscn")
  </step>

  <!-- STEP 5: Check Errors -->
  <step id="5" name="Check Errors">
    get_godot_errors()
    # Analyze: Any errors? Warnings?
  </step>

  <!-- STEP 6: Visual Verification -->
  <step id="6" name="Visual Check">
    get_running_scene_screenshot()
    # Verify: Scene loaded, sprites visible, layout correct
  </step>

  <!-- STEP 7: Stop -->
  <step id="7" name="Stop">
    stop_running_scene()
  </step>

  <!-- STEP 8: Document Results -->
  <step id="8" name="Document">
    write_note(
      "system_[NN]_test_results",
      """
      # Test Results: [System]

      ## Test Scene
      res://tests/test_[system].tscn

      ## Results
      - [x] No script errors
      - [x] Scene runs without crashes
      - [x] Expected behavior confirmed
      - [x] Visual verification passed

      ## Status
      PASS - All tests successful

      ## Date
      [date]
      """,
      "systems",
      ["s[NN]", "testing", "pass"]
    )
  </step>

</workflow>
```

**Real Example:**

```
# STEP 1: Create Scene
create_scene("res://tests/test_player_movement.tscn", "Node2D")

# STEP 2: Setup Test
open_scene("res://tests/test_player_movement.tscn")

add_scene(".", "res://scenes/player/player.tscn", "Player")

add_node(".", "StaticBody2D", "Ground")
add_node("Ground", "CollisionShape2D", "GroundCollision")
add_resource("Ground/GroundCollision", "shape", "RectangleShape2D", {"size": Vector2(500, 50)})
update_property("Ground", "position", Vector2(0, 300))

add_node(".", "CanvasLayer", "Debug")
add_node("Debug", "Label", "Instructions")
update_property("Debug/Instructions", "text", "Test: Press WASD to move, Space to jump")
update_property("Debug/Instructions", "position", Vector2(10, 10))

# STEP 3: Verify
get_scene_tree()
# Returns:
# Node2D
# ├── Player (player.gd)
# │   ├── Sprite2D
# │   └── CollisionShape2D
# ├── Ground
# │   └── GroundCollision
# └── Debug
#     └── Instructions

# STEP 4: Run
clear_output_logs()
play_scene("res://tests/test_player_movement.tscn")

# STEP 5: Check Errors
get_godot_errors()
# Returns: (no errors)

# STEP 6: Visual
get_running_scene_screenshot()
# Confirms: Player sprite visible, ground visible, instructions visible

# STEP 7: Stop
stop_running_scene()

# STEP 8: Document
write_note(
  "system_01_test_results",
  """
  # Test Results: Player Movement

  ## Test Scene
  res://tests/test_player_movement.tscn

  ## Test Environment
  - Player instance at default position
  - Ground platform at y=300
  - Debug instructions overlay

  ## Results
  - [x] No script errors
  - [x] Player responds to WASD input
  - [x] Jump works with space bar
  - [x] Collision with ground works
  - [x] Visual verification: sprites render correctly

  ## Status
  PASS - All tests successful

  ## Date
  2025-11-18
  """,
  "systems",
  ["s01", "player", "testing", "pass"]
)
```

---

### Workflow 3: Create JSON Data File

**Complete data file workflow:**

```xml
<workflow name="create_json_data">

  <!-- STEP 1: Research Data Structure -->
  <step id="1" name="Research">
    # Determine what data is needed
    # Review similar systems for patterns
    search("data structure [feature]")
  </step>

  <!-- STEP 2: Create Directory Structure -->
  <step id="2" name="Setup">
    # Verify directory exists (use Bash if needed)
    get_filesystem_tree()
  </step>

  <!-- STEP 3: Create Template -->
  <step id="3" name="Create Template">
    # Use standard file creation (MCP or Write tool)
    # Create template.json with full structure
  </step>

  <!-- STEP 4: Create Specific Data Files -->
  <step id="4" name="Create Data">
    # Create actual data files based on template
    # One for each entity (enemy, item, level, etc.)
  </step>

  <!-- STEP 5: Verify Format -->
  <step id="5" name="Verify">
    # Check JSON is valid
    # Verify all required fields present
  </step>

  <!-- STEP 6: Document -->
  <step id="6" name="Document">
    write_note(
      "data_structure_[feature]",
      """
      # Data Structure: [Feature]

      ## Location
      res://data/[feature]/

      ## Template
      See: template.json

      ## Fields
      - field1: description
      - field2: description

      ## Usage
      Load via DataManager.get_[feature]_data(id)
      """,
      "patterns",
      ["data", "[feature]"]
    )
  </step>

</workflow>
```

**Real Example:**

```
# STEP 1: Research
search("enemy data structure")
# Find: Pattern uses JSON with stats, sprite paths, abilities

# STEP 2: Verify Directory
get_filesystem_tree("json")
# Confirm: res://data/ exists

# STEP 3: Create Template (using standard file write)
# Create res://data/enemies/enemy_template.json
{
  "enemy_id": "template_id",
  "display_name": "Template Enemy",
  "description": "Template for creating new enemies",
  "stats": {
    "hp": 100,
    "attack": 10,
    "defense": 5,
    "speed": 100
  },
  "sprite": "res://assets/sprites/enemies/template.png",
  "animations": {
    "idle": "idle",
    "walk": "walk",
    "attack": "attack",
    "hurt": "hurt",
    "death": "death"
  },
  "abilities": [],
  "ai_behavior": "neutral",
  "loot_table": {
    "gold": [0, 10],
    "items": []
  }
}

# STEP 4: Create Specific Enemy
# Create res://data/enemies/goblin_warrior.json
{
  "enemy_id": "goblin_warrior",
  "display_name": "Goblin Warrior",
  "description": "Basic melee enemy",
  "stats": {
    "hp": 50,
    "attack": 12,
    "defense": 8,
    "speed": 100
  },
  "sprite": "res://assets/sprites/enemies/goblin_warrior.png",
  "animations": {
    "idle": "goblin_idle",
    "walk": "goblin_walk",
    "attack": "goblin_attack",
    "hurt": "goblin_hurt",
    "death": "goblin_death"
  },
  "abilities": ["melee_attack", "dodge"],
  "ai_behavior": "aggressive",
  "loot_table": {
    "gold": [10, 25],
    "items": [
      {"item_id": "rusty_sword", "chance": 0.15}
    ]
  }
}

# STEP 5: Verify Format
# JSON is valid (no syntax errors)
# All template fields present

# STEP 6: Document
write_note(
  "data_structure_enemies",
  """
  # Data Structure: Enemies

  ## Location
  res://data/enemies/

  ## Template
  enemy_template.json

  ## Fields
  - enemy_id: Unique identifier (string)
  - display_name: Name shown in UI (string)
  - stats.hp: Health points (int)
  - stats.attack: Attack damage (int)
  - stats.defense: Defense rating (int)
  - stats.speed: Movement speed (float)
  - sprite: Path to sprite resource (string)
  - abilities: List of ability IDs (array)
  - ai_behavior: AI type (string: "aggressive", "passive", "neutral")
  - loot_table: Drops on death (object)

  ## Usage
  ```gdscript
  var enemy_data = DataManager.get_enemy_data("goblin_warrior")
  enemy_instance.initialize(enemy_data)
  ```

  ## Examples
  - goblin_warrior.json (basic melee)
  - goblin_archer.json (ranged)

  ## Extension
  To add new enemy:
  1. Copy enemy_template.json
  2. Rename to [enemy_id].json
  3. Fill in values
  4. No code changes needed!
  """,
  "patterns",
  ["data", "enemies", "json"]
)
```

---

### Workflow 4: Save Progress to Memory

**Complete checkpoint workflow:**

```xml
<workflow name="save_checkpoint">

  <!-- STEP 1: Gather Context -->
  <step id="1" name="Gather">
    # List files created
    get_filesystem_tree()

    # Review implementation
    view_script("res://scripts/[system]/[name].gd")
    get_scene_tree()

    # Check test results
    # Review what was accomplished
  </step>

  <!-- STEP 2: Format Checkpoint -->
  <step id="2" name="Format">
    # Use standard checkpoint XML structure:
    """
    # System [NN]: [Name] - STATUS

    ## Files Created
    - file 1
    - file 2

    ## Implementation
    - Key decision 1
    - Key decision 2

    ## Integration Points
    - How this connects to other systems

    ## Testing
    - [x] Test 1
    - [x] Test 2

    ## Next Steps
    - What future LLM should do
    """
  </step>

  <!-- STEP 3: Save with Proper Key -->
  <step id="3" name="Save">
    write_note(
      "system_[NN]_[snake_case_name]",
      [checkpoint_content],
      "systems",
      ["s[NN]", "[category]", "[status]"]
    )
  </step>

  <!-- STEP 4: Verify Saved -->
  <step id="4" name="Verify">
    read_note("system_[NN]_[snake_case_name]")
    # Confirm content correct
  </step>

</workflow>
```

**Real Example:**

```
# STEP 1: Gather Context
get_filesystem_tree("gd")
# Shows: player.gd created

get_filesystem_tree("tscn")
# Shows: player.tscn, test_player_movement.tscn created

view_script("res://scripts/player/player.gd")
# Confirms: Movement implementation complete

open_scene("res://scenes/player/player.tscn")
get_scene_tree()
# Shows: Proper node hierarchy

# Review test results from earlier:
# - All tests passed
# - No errors
# - Visual verification confirmed

# STEP 2: Format Checkpoint
checkpoint_content = """
# System 01: Player Movement - COMPLETE

## Files Created
- res://scenes/player/player.tscn (CharacterBody2D scene)
- res://scripts/player/player.gd (movement script)
- res://tests/test_player_movement.tscn (test scene)

## Implementation Details
- CharacterBody2D base class for physics
- move_and_slide() for collision-aware movement
- Input.get_vector() for 8-directional input
- Gravity system using get_gravity()
- Jump mechanic with is_on_floor() check
- Smooth deceleration with move_toward()

## Key Decisions
- Used CharacterBody2D (not RigidBody2D) for direct control
- Followed Godot 4.5 physics best practices
- All type hints explicit (GDScript 4.5 compliance)

## Integration Points
- Exports player position for camera following (S06)
- Velocity data available for UI speedometer (S08)
- Ready for combat system attachment (S02)
- Collision layers set for enemy detection (S04)

## Testing Results
- [x] WASD movement responsive
- [x] Jump mechanic works correctly
- [x] Gravity applies properly
- [x] Ground collision functional
- [x] No script errors in console
- [x] Visual verification: sprites render
- [x] Test scene: res://tests/test_player_movement.tscn

## Research Sources
- https://docs.godotengine.org/en/4.5/tutorials/physics/using_character_body_2d.html

## Next Steps for Future LLMs
- S02 (Combat) can attach weapon systems to this player
- S06 (Camera) should follow player.position
- S08 (UI) can read player velocity for HUD

## Status
✅ COMPLETE - All tests passing

## Date
2025-11-18
"""

# STEP 3: Save
write_note(
  "system_01_player_movement",
  checkpoint_content,
  "systems",
  ["s01", "player", "movement", "complete"]
)

# STEP 4: Verify
read_note("system_01_player_movement")
# Returns: Full checkpoint content
# Confirmed: Saved successfully
```

---

## 8. Troubleshooting Guide

### Common Error Patterns

#### Error: "Invalid parent path"

**Problem:**
```
add_node("NonExistentNode", "Sprite2D", "MySprite")
Error: Parent node 'NonExistentNode' not found
```

**Solution:**
```
# First verify parent exists
get_scene_tree()

# Then add node
add_node(".", "Sprite2D", "MySprite")  # Use "." for root if unsure
```

---

#### Error: "Scene not open"

**Problem:**
```
get_scene_tree()
Error: No scene currently open in editor
```

**Solution:**
```
# Open scene first
open_scene("res://scenes/player/player.tscn")

# Then get tree
get_scene_tree()
```

---

#### Error: "Invalid node type"

**Problem:**
```
create_scene("res://scenes/test.tscn", "CharacterBody2d")
Error: Unknown class 'CharacterBody2d'
```

**Solution:**
```
# Check exact class name (case-sensitive!)
# Correct: CharacterBody2D (capital D)
create_scene("res://scenes/test.tscn", "CharacterBody2D")
```

**Common mistakes:**
- `CharacterBody2d` → `CharacterBody2D`
- `Sprite2d` → `Sprite2D`
- `Area2d` → `Area2D`
- `node2D` → `Node2D`

---

#### Error: "File not found"

**Problem:**
```
attach_script(".", "res://scripts/player.gd")
Error: Script file not found
```

**Solution:**
```
# Verify file exists first
get_filesystem_tree("gd")

# Check exact path (typos common!)
# Or create script if missing
create_script("res://scripts/player.gd", [content])

# Then attach
attach_script(".", "res://scripts/player.gd")
```

---

#### Error: "Script parse error"

**Problem:**
```
play_scene("res://tests/test.tscn")
get_godot_errors()

Returns:
[ERROR] Parse Error at line 15: Invalid syntax
  res://scripts/player.gd:15
```

**Solution:**
```
# View script to find error
view_script("res://scripts/player.gd")

# Common GDScript 4.5 issues:
# ❌ var line = "═" * 60
# ✅ var line = "═".repeat(60)

# ❌ func process_data(input):
# ✅ func process_data(input: String) -> void:

# Fix with edit_file
edit_file(
  "res://scripts/player.gd",
  "var line = \"═\" * 60",
  "var line = \"═\".repeat(60)"
)

# Test again
clear_output_logs()
play_scene("res://tests/test.tscn")
get_godot_errors()
```

---

#### Error: "Property doesn't exist"

**Problem:**
```
update_property("Sprite2D", "image", "res://sprite.png")
Error: Property 'image' not found on Sprite2D
```

**Solution:**
```
# Check Godot docs for correct property name
# Sprite2D uses 'texture', not 'image'

update_property("Sprite2D", "texture", "res://sprite.png")
```

**Common property name mistakes:**
- `image` → `texture` (Sprite2D)
- `text_value` → `text` (Label)
- `pos` → `position`
- `rot` → `rotation`

---

### Debugging Workflow

**When something doesn't work:**

```xml
<debug_workflow>

  <step id="1">
    clear_output_logs()
  </step>

  <step id="2">
    play_scene("res://tests/[test_scene].tscn")
  </step>

  <step id="3">
    get_godot_errors()
    # Read error messages carefully
    # Note file and line number
  </step>

  <step id="4">
    stop_running_scene()
  </step>

  <step id="5">
    view_script("res://scripts/[problematic_file].gd")
    # Look at specific line from error
  </step>

  <step id="6">
    # Fix issue with edit_file
    edit_file([file], [find_broken], [replace_fixed])
  </step>

  <step id="7">
    # Test fix
    clear_output_logs()
    play_scene("res://tests/[test_scene].tscn")
    get_godot_errors()
    # Verify: error gone?
  </step>

  <step id="8">
    stop_running_scene()
  </step>

</debug_workflow>
```

---

### Quick Reference: Error Recovery

| Error Type | First Action | Tool to Use |
|------------|--------------|-------------|
| Parse error | View script | `view_script()` → `edit_file()` |
| Invalid node path | Check scene tree | `get_scene_tree()` |
| File not found | List files | `get_filesystem_tree()` |
| Scene not open | Open scene | `open_scene()` |
| Runtime error | Check logs | `get_godot_errors()` |
| Visual issue | Screenshot | `get_running_scene_screenshot()` |
| Property error | Check docs | Web search + `update_property()` |

---

## Summary: MCP Command Philosophy

**Key Principles:**

1. **MCP First:** Always use MCP commands before manual file editing
2. **Verify Always:** Use `get_scene_tree()`, `get_filesystem_tree()` to confirm
3. **Test Everything:** `play_scene()` → `get_godot_errors()` → `stop_running_scene()`
4. **Checkpoint Often:** `write_note()` after each completed system
5. **Research Before:** Web search → implement → test → checkpoint

**The Complete Workflow:**

```
Research (Web Search)
  ↓
Implement (MCP Commands)
  ↓
Verify (get_scene_tree, get_filesystem_tree)
  ↓
Test (play_scene, get_godot_errors, screenshot)
  ↓
Checkpoint (write_note)
  ↓
Next System
```

---

**References:**
- GDAI MCP Documentation: https://gdaimcp.com/
- GDAI MCP Tools: https://gdaimcp.com/docs/supported-tools
- GDAI MCP Examples: https://gdaimcp.com/docs/examples
- Basic Memory MCP: https://github.com/basicmachines-co/basic-memory
- Godot 4.5 Docs: https://docs.godotengine.org/en/4.5/
- Godot 4.5 GDScript Reference: https://docs.godotengine.org/en/4.5/tutorials/scripting/gdscript/gdscript_basics.html

**Last Updated:** 2025-11-18
**Version:** 1.0

**End of Document**
