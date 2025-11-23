read and complete: 

some additional context:

CRITICAL: Before implementing, know these rules from PARALLEL-EXECUTION-GUIDE-V2.md:

FILE ISOLATION:
- Only modify: src/systems/s{##}-{your-system}/, scenes/s{##}-{your-system}/
- Never modify: Other systems, src/core/, project.godot

HANDOFF:
- Create HANDOFF-s{##}.md with exact GDAI commands for Tier 2
- Use template from PARALLEL-EXECUTION-GUIDE-V2.md

CHECKPOINTS:
- Dual-track: Markdown (.md) 
- Include: Files created, integration points, testing results

## MANDATORY: GDScript 4.5 Syntax Validation

Before submitting ANY code files, you MUST validate that all GDScript code is compatible with **Godot 4.5.1** and follows current GDScript 4.5 syntax standards.

### Critical Syntax Rules to Verify

1. **String Repetition**: Use `.repeat()` method, NOT `*` operator
   - ❌ WRONG: `"═" * 60`
   - ✅ CORRECT: `"═".repeat(60)`

2. **Class Declarations**: Add `class_name` declarations with unique names
   - Include `class_name ClassName` at the top of files
   - Avoid conflicts with autoload singleton names (use `Impl` suffix if needed)

3. **Type Inference**: Always use explicit types when Variant could cause issues
   - ❌ WRONG: `var result := function_call()` (if return type is unknown)
   - ✅ CORRECT: `var result: Dictionary = function_call()`

4. **Function Signatures**: All functions must have complete type hints
   - ❌ WRONG: `func process_data(input):`
   - ✅ CORRECT: `func process_data(input: String) -> Dictionary:`

5. **Autoload Access**: Use preload() for class instantiation in scripts, not direct singleton access during script load
   - ❌ WRONG: `var instance = AutoloadClass.new()` (in top-level code)
   - ✅ CORRECT: `const ClassImpl = preload("path/to/class.gd")` then `var instance = ClassImpl.new()`

### Validation Checklist

Before finalizing any GDScript files:
- [ ] No `string * number` operations (use `.repeat()`)
- [ ] All classes have `class_name` declarations
- [ ] All functions have parameter and return type hints
- [ ] No type inference from Variant returns without explicit types
- [ ] Preload statements used for cross-file class access
- [ ] Code compiles without parse errors in Godot 4.5 editor

### Testing Protocol

After writing GDScript code:
1. Check in Godot 4.5 editor for parse errors
2. Verify no warnings about type inference
3. Test that all functions work as expected
4. Confirm all syntax matches GDScript 4.5 documentation

---

**This is non-negotiable. Invalid GDScript will delay integration and create rework.**

GDAI Godot-MCP Supported Tools
Tools are the functionalities that the plugin provides to the AI (MCP Client). Here is a list of tools in the plugin:

Project tools
get_project_info - Get information about the Godot project from the project.godot file and other sources
get_filesystem_tree - Get a recursive tree view of all files and directories in the project with file type filtering
search_files - Recursively search the filesystem for files matching a query using fuzzy search
uid_to_project_path - Convert a Godot UID string (uid://) to a Godot project path (res://)
project_path_to_uid - Convert a Godot project path (res://) to a Godot UID string (uid://)
Scene tools
get_scene_tree - Get a recursive tree view of all nodes in the current scene with visibility and script info
get_scene_file_content - Get the raw content of the current scene file to see overridden properties and resources
create_scene - Create a new scene with the root node of given type
open_scene - Open a scene in the editor
delete_scene - Delete a scene with given file path
add_scene - Add a scene as a node to a parent node in the current scene
play_scene - Play either the current scene or the main project scene in Godot
stop_running_scene - Stop the currently running scene in the Godot Editor, if any
Node tools
add_node - Add a new node to a parent node in the current scene
delete_node - Delete a node (except root) in the current scene
duplicate_node - Duplicate an existing node in the scene
move_node - Move a node to a different parent in the scene
update_property - Update a property of a given node in a scene (does not create sub-resources)
add_resource - Add a new resource or subresource as a property to a node (e.g., shape to collision, texture to sprite)
set_anchor_preset - Set the anchor of a Control node using a preset (top_left, center, full_rect, etc.)
set_anchor_values - Set the anchor values (top, bottom, left, right) for a Control node with precise values
Script tools
get_open_scripts - Get a list of all scripts open in the Godot editor along with their contents
view_script - View the contents of a GDScript file and make it active in the script editor
create_script - Create a GDScript script file with content
attach_script - Attach a script file to a node in the scene
edit_file - Edit a file by performing a find and replace operation on its contents
Editor tools
get_godot_errors - Get errors from Godot such as script errors, runtime errors, stack trace and output logs
get_editor_screenshot - Return a screenshot of the entire Godot editor window
get_running_scene_screenshot - Return a screenshot of the running game window
execute_editor_script - Execute arbitrary GDScript in the Editor as a tool script
clear_output_logs - Clear the output logs in the editor to remove previous errors