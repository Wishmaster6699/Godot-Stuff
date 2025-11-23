# Godot 4.5 | GDScript 4.5
# Framework: Checkpoint Rollback System
# Purpose: Create snapshots of checkpoints and enable rollback
# Created: 2025-11-18

extends Node
class_name CheckpointManager

## Checkpoint Rollback System
##
## Creates versioned snapshots of checkpoint files and allows rolling back
## to previous states if needed. Useful for recovering from mistakes or
## exploring alternative implementation approaches.
##
## Usage:
##   var manager = CheckpointManager.new()
##   manager.create_snapshot("before-refactor")
##   # ... make changes ...
##   manager.rollback_to_snapshot("before-refactor")  # If needed

## Snapshot metadata
class Snapshot:
	var snapshot_id: String = ""
	var timestamp: String = ""
	var description: String = ""
	var files_count: int = 0
	var checkpoint_files: Array[String] = []

	func summary() -> String:
		return "%s | %s | %d files | %s" % [
			snapshot_id, timestamp, files_count, description
		]

## Snapshots directory
const SNAPSHOTS_DIR: String = ".snapshots"
const CHECKPOINTS_DIR: String = "checkpoints"

## Available snapshots
var snapshots: Dictionary = {}  # snapshot_id -> Snapshot

func _init() -> void:
	_ensure_snapshots_dir()
	_load_snapshot_metadata()

## Ensure snapshots directory exists
func _ensure_snapshots_dir() -> void:
	if not DirAccess.dir_exists_absolute(SNAPSHOTS_DIR):
		DirAccess.make_dir_absolute(SNAPSHOTS_DIR)
		print("📁 Created snapshots directory: %s" % SNAPSHOTS_DIR)

## Create a snapshot of current checkpoints
func create_snapshot(description: String = "Manual snapshot") -> String:
	var snapshot_id := _generate_snapshot_id()
	var snapshot := Snapshot.new()
	snapshot.snapshot_id = snapshot_id
	snapshot.timestamp = Time.get_datetime_string_from_system()
	snapshot.description = description

	print("\n📸 Creating snapshot: %s" % snapshot_id)
	print("─" * 60)

	# Create snapshot directory
	var snapshot_dir := SNAPSHOTS_DIR + "/" + snapshot_id
	DirAccess.make_dir_absolute(snapshot_dir)

	# Copy all checkpoint files
	if not DirAccess.dir_exists_absolute(CHECKPOINTS_DIR):
		print("⊘ No checkpoints directory found - creating empty snapshot")
		_save_snapshot_metadata(snapshot)
		return snapshot_id

	var dir := DirAccess.open(CHECKPOINTS_DIR)
	if dir == null:
		push_error("Could not open checkpoints directory")
		return ""

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".md") and not file_name.begins_with("."):
			var source_path := CHECKPOINTS_DIR + "/" + file_name
			var dest_path := snapshot_dir + "/" + file_name

			if _copy_file(source_path, dest_path):
				snapshot.checkpoint_files.append(file_name)
				snapshot.files_count += 1
				print("  ✓ Copied: %s" % file_name)

		file_name = dir.get_next()

	dir.list_dir_end()

	# Save snapshot metadata
	_save_snapshot_metadata(snapshot)
	snapshots[snapshot_id] = snapshot

	print("─" * 60)
	print("✅ Snapshot created: %s (%d files)" % [snapshot_id, snapshot.files_count])
	print("")

	return snapshot_id

## Rollback to a previous snapshot
func rollback_to_snapshot(snapshot_id: String) -> bool:
	if not snapshots.has(snapshot_id):
		push_error("Snapshot not found: %s" % snapshot_id)
		return false

	var snapshot: Snapshot = snapshots[snapshot_id]

	print("\n⏮️  Rolling back to snapshot: %s" % snapshot_id)
	print("─" * 60)
	print("Description: %s" % snapshot.description)
	print("Created: %s" % snapshot.timestamp)
	print("Files: %d" % snapshot.files_count)
	print("")
	print("⚠️  This will overwrite current checkpoints!")
	print("")

	# Ensure checkpoints directory exists
	if not DirAccess.dir_exists_absolute(CHECKPOINTS_DIR):
		DirAccess.make_dir_absolute(CHECKPOINTS_DIR)

	# Copy files from snapshot back to checkpoints
	var snapshot_dir := SNAPSHOTS_DIR + "/" + snapshot_id
	var restored_count := 0

	for file_name in snapshot.checkpoint_files:
		var source_path := snapshot_dir + "/" + file_name
		var dest_path := CHECKPOINTS_DIR + "/" + file_name

		if _copy_file(source_path, dest_path):
			restored_count += 1
			print("  ✓ Restored: %s" % file_name)
		else:
			print("  ✗ Failed: %s" % file_name)

	print("─" * 60)
	print("✅ Rollback complete: %d/%d files restored" % [restored_count, snapshot.files_count])
	print("")

	return restored_count == snapshot.files_count

## List all available snapshots
func list_snapshots() -> Array[Snapshot]:
	var snapshot_list: Array[Snapshot] = []

	for snapshot_id in snapshots.keys():
		snapshot_list.append(snapshots[snapshot_id])

	# Sort by timestamp (newest first)
	snapshot_list.sort_custom(func(a: Snapshot, b: Snapshot):
		return a.timestamp > b.timestamp
	)

	return snapshot_list

## Print snapshot list
func print_snapshots() -> void:
	var snapshot_list := list_snapshots()

	if snapshot_list.is_empty():
		print("⊘ No snapshots found")
		return

	print("\n📸 Available Snapshots:")
	print("═" * 70)

	for snapshot in snapshot_list:
		print(snapshot.summary())

	print("═" * 70)
	print("Total: %d snapshots\n" % snapshot_list.size())

## Delete a snapshot
func delete_snapshot(snapshot_id: String) -> bool:
	if not snapshots.has(snapshot_id):
		push_error("Snapshot not found: %s" % snapshot_id)
		return false

	var snapshot_dir := SNAPSHOTS_DIR + "/" + snapshot_id

	# Delete all files in snapshot directory
	_delete_directory_recursive(snapshot_dir)

	# Remove from snapshots dict
	snapshots.erase(snapshot_id)

	print("🗑️  Deleted snapshot: %s" % snapshot_id)
	return true

## Generate unique snapshot ID
func _generate_snapshot_id() -> String:
	var timestamp := Time.get_datetime_dict_from_system()
	return "snapshot-%04d%02d%02d-%02d%02d%02d" % [
		timestamp.year, timestamp.month, timestamp.day,
		timestamp.hour, timestamp.minute, timestamp.second
	]

## Copy a single file
func _copy_file(source_path: String, dest_path: String) -> bool:
	var source_file := FileAccess.open(source_path, FileAccess.READ)
	if source_file == null:
		push_error("Could not open source file: %s" % source_path)
		return false

	var content := source_file.get_as_text()
	source_file.close()

	var dest_file := FileAccess.open(dest_path, FileAccess.WRITE)
	if dest_file == null:
		push_error("Could not create destination file: %s" % dest_path)
		return false

	dest_file.store_string(content)
	dest_file.close()

	return true

## Save snapshot metadata to JSON
func _save_snapshot_metadata(snapshot: Snapshot) -> void:
	var metadata := {
		"snapshot_id": snapshot.snapshot_id,
		"timestamp": snapshot.timestamp,
		"description": snapshot.description,
		"files_count": snapshot.files_count,
		"checkpoint_files": snapshot.checkpoint_files
	}

	var metadata_path := SNAPSHOTS_DIR + "/" + snapshot.snapshot_id + "/metadata.json"
	var file := FileAccess.open(metadata_path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(metadata, "\t"))
		file.close()

## Load all snapshot metadata
func _load_snapshot_metadata() -> void:
	if not DirAccess.dir_exists_absolute(SNAPSHOTS_DIR):
		return

	var dir := DirAccess.open(SNAPSHOTS_DIR)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var metadata_path := SNAPSHOTS_DIR + "/" + file_name + "/metadata.json"

			if FileAccess.file_exists(metadata_path):
				_load_single_snapshot_metadata(file_name, metadata_path)

		file_name = dir.get_next()

	dir.list_dir_end()

## Load metadata for a single snapshot
func _load_single_snapshot_metadata(snapshot_id: String, metadata_path: String) -> void:
	var file := FileAccess.open(metadata_path, FileAccess.READ)
	if file == null:
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)

	if parse_result == OK:
		var data: Dictionary = json.data
		var snapshot := Snapshot.new()
		snapshot.snapshot_id = data.get("snapshot_id", snapshot_id)
		snapshot.timestamp = data.get("timestamp", "")
		snapshot.description = data.get("description", "")
		snapshot.files_count = data.get("files_count", 0)

		var files_array: Array = data.get("checkpoint_files", [])
		for file_path in files_array:
			snapshot.checkpoint_files.append(file_path)

		snapshots[snapshot_id] = snapshot

## Delete directory and all contents recursively
func _delete_directory_recursive(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	# Delete all files first
	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		var full_path := dir_path + "/" + file_name

		if dir.current_is_dir() and not file_name.begins_with("."):
			_delete_directory_recursive(full_path)
		else:
			DirAccess.remove_absolute(full_path)

		file_name = dir.get_next()

	dir.list_dir_end()

	# Delete the directory itself
	DirAccess.remove_absolute(dir_path)
