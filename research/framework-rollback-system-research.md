# Rollback System Research
## Agent: F2
## Date: 2025-11-18
## Duration: 30 minutes

## Research Goal
Understand Godot 4.5 file operations, directory management, checkpoint/snapshot patterns, and rollback recovery mechanisms to build a safe and reliable rollback system for framework checkpoints.

---

## Search Queries Performed

1. "Godot 4.5 save system file operations"
2. "GDScript 4.5 file copy directory operations"
3. "version control checkpoint rollback system patterns"
4. "snapshot backup restoration system design"

---

## Key Findings

### 1. Godot 4.5 File Operations

**Source:** [Godot Docs - Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)

**FileAccess API:**

**Basic File Operations:**
```gdscript
# Open file for reading/writing
var file = FileAccess.open(path, FileAccess.READ)
var file = FileAccess.open(path, FileAccess.WRITE)
var file = FileAccess.open(path, FileAccess.READ_WRITE)

# Read/write text
var content = file.get_as_text()
file.store_string(content)

# Read/write binary
file.store_var(data)
var data = file.get_var()
```

**File Access Modes:**
- `FileAccess.READ` - Open for reading
- `FileAccess.WRITE` - Open for writing (creates file, truncates if exists)
- `FileAccess.READ_WRITE` - Open for both (doesn't truncate)

**Path Restrictions:**
- `user://` - User data path (writable)
- `res://` - Resource path (read-only in exported games)
- User data should ONLY be stored in `user://`

**Data Formats:**
- Binary (store_var/get_var) - Godot's built-in serialization
- JSON (JSON.stringify/JSON.parse) - Human-readable
- Custom formats

### 2. GDScript Directory Operations

**Source:** [Godot Docs - DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html)

**DirAccess API:**

**Creating Directories:**
```gdscript
# Create directory (absolute path)
DirAccess.make_dir_absolute(path)

# Check if directory exists
DirAccess.dir_exists_absolute(path)

# Open directory
var dir = DirAccess.open(path)
```

**Listing Directory Contents:**
```gdscript
var dir = DirAccess.open(path)
dir.list_dir_begin()
var file_name = dir.get_next()

while file_name != "":
    if dir.current_is_dir():
        # It's a directory
    else:
        # It's a file
    file_name = dir.get_next()

dir.list_dir_end()
```

**File Copying:**
```gdscript
# Copy individual file
DirAccess.copy_absolute(source, dest)

# OR instance method
var dir = DirAccess.open(source_dir)
dir.copy(file_name, dest_path)
```

**Important Limitations:**

**No Built-in Directory Copy:**
- `copy()` and `copy_absolute()` only work for FILES, not directories
- Must implement recursive directory copy manually
- Need custom function to traverse directory tree

**Recursive Copying Pattern:**
```gdscript
func copy_directory(source: String, dest: String):
    var dir = DirAccess.open(source)
    dir.list_dir_begin()
    DirAccess.make_dir_absolute(dest)

    var file_name = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            # Recursively copy subdirectory
            copy_directory(source + "/" + file_name, dest + "/" + file_name)
        else:
            # Copy file
            DirAccess.copy_absolute(source + "/" + file_name, dest + "/" + file_name)
        file_name = dir.get_next()

    dir.list_dir_end()
```

**Path Handling:**
- `copy()` instance method handles relative paths
- `copy_absolute()` static method requires absolute paths
- Relative paths are converted to absolute internally

### 3. Checkpoint-Based Rollback Patterns

**Source:** [Semantic Scholar - Design Patterns for Checkpoint-Based Rollback Recovery](https://www.semanticscholar.org/paper/Design-Patterns-for-Checkpoint-Based-Rollback-Saridakis/bda1f8f02eee3f8eddeb6f056cc5fc212723b6f2)

**Core Concepts:**

**Checkpoint:**
- Complete snapshot of system state
- Created during error-free execution
- Used to restore to consistent state after error

**Rollback Recovery:**
- Restore system to recent consistent state
- Based on saved checkpoints
- Minimizes lost work

**Key Challenge:**
> "Messages induce inter-process dependencies during failure-free operation. These dependencies may force some processes that did not fail to roll back - a phenomenon called the 'domino effect'."

**For Our Use Case:**
- Checkpoints are markdown files (simple text)
- No inter-process dependencies
- Clean snapshot/restore model

**Three Common Patterns:**

**1. Independent Checkpointing:**
- Each process creates checkpoints independently
- Simple to implement
- May require cascading rollback

**2. Coordinated Checkpointing:**
- Processes coordinate to create consistent global checkpoint
- Prevents domino effect
- More complex coordination

**3. Communication-Induced Checkpointing:**
- Piggyback checkpoint info on messages
- Balance between independent and coordinated

**For Our System:**
- Independent checkpointing (files don't have dependencies)
- Simple snapshot/restore
- No coordination needed

**Replit's Implementation:**

**Source:** [Replit Docs - Checkpoints and Rollbacks](https://docs.replit.com/replitai/checkpoints-and-rollbacks)

**Key Features:**
- Checkpoint = complete snapshot of app state
- Created at key development milestones
- Captures entire development context
- Not just code changes

**Benefits:**
- Version control
- State management
- Easy rollback to known-good state
- Experimentation without risk

### 4. Snapshot Backup System Design

**Source:** [Cohesity - Snapshot Backup](https://www.cohesity.com/glossary/snapshot-backup/)

**Snapshot Defined:**
> "A snapshot is a point-in-time copy of data taken from an operating system, software application, or disk. It captures the data's current state at a specific moment with all its settings."

**Two Main Approaches:**

**1. Copy-on-Write (COW):**
- Copy original block before writing new data
- 3 I/O operations per write (read, copy, write)
- Slower but traditional approach

**2. Redirect-on-Write (ROW):**
- Redirect changes to new blocks
- Faster write performance
- More scalable

**For Our Use Case:**
- Simple file copying (no block-level snapshots)
- Checkpoint files are small text files
- Performance not critical (infrequent snapshots)

**Snapshot Metadata:**

**Essential Information:**
- Timestamp
- Description
- File list
- Version/ID

**Our Metadata Format (JSON):**
```json
{
  "snapshot_id": "snapshot-20251118-143022",
  "timestamp": "2025-11-18T14:30:22",
  "description": "Before major refactor",
  "files_count": 5,
  "checkpoint_files": [
    "framework-performance-profiler-checkpoint.md",
    "framework-coordination-dashboard-checkpoint.md"
  ]
}
```

**Restoration Process:**

**Source:** [Medium - Designing a Backup System](https://pawitp.medium.com/designing-a-backup-system-34673bb7fc4c)

**Key Steps:**
1. User selects snapshot to restore
2. Download/copy all files from snapshot
3. Verify integrity
4. Replace current files with snapshot files
5. Confirm restoration complete

**Best Practice:**
> "Snapshots and data backups are frequently used together to provide holistic protection. This hybrid strategy is widely considered a best practice."

**For Our System:**
- Snapshots are local (not cloud)
- Git provides additional backup layer
- Snapshots for quick experimentation rollback
- Git for long-term version control

---

## Design Decisions for Rollback System

### 1. Storage Location

**`.snapshots/` Directory:**
- Hidden directory (starts with .)
- Easy to `.gitignore`
- Organized separately from checkpoints
- All snapshots in one place

**Directory Structure:**
```
.snapshots/
  snapshot-20251118-143022/
    metadata.json
    framework-performance-profiler-checkpoint.md
    framework-coordination-dashboard-checkpoint.md
  snapshot-20251118-150000/
    metadata.json
    [checkpoint files...]
```

### 2. Snapshot ID Format

**Format:** `snapshot-YYYYMMDD-HHMMSS`

**Benefits:**
- Human-readable
- Sortable chronologically
- Unique per second
- No special characters
- Works on all filesystems

**Example:** `snapshot-20251118-143022`

### 3. Metadata in JSON

**Why JSON:**
- Human-readable
- Easy to parse (JSON.parse)
- Standard format
- Persists across sessions
- Can be inspected manually

**Stored Information:**
- Snapshot ID
- Timestamp
- Description (user-provided)
- File count
- List of all checkpoint files

### 4. Operations Supported

**Create Snapshot:**
- Copy all checkpoint files to snapshot directory
- Generate metadata
- Save metadata.json

**List Snapshots:**
- Read all metadata.json files
- Display summary information
- Sort by timestamp

**Rollback to Snapshot:**
- Verify snapshot exists
- Copy all files from snapshot back to checkpoints
- Show progress and confirmation

**Delete Snapshot:**
- Remove entire snapshot directory
- Clean up metadata

### 5. Safety Features

**Confirmation Before Rollback:**
- Show what will be overwritten
- Display snapshot details
- Warn user of consequences

**Metadata Verification:**
- Check file count matches
- Verify all files exist
- Report any missing files

**Error Handling:**
- Graceful failure if snapshot not found
- Warning if checkpoint directory doesn't exist
- Error messages for file access failures

---

## Implementation Approach

### Core Classes

**CheckpointManager (Main Class):**
```gdscript
class_name CheckpointManager
- create_snapshot(description) -> snapshot_id
- rollback_to_snapshot(snapshot_id) -> bool
- list_snapshots() -> Array[Snapshot]
- print_snapshots()
- delete_snapshot(snapshot_id) -> bool
```

**Snapshot (Data Class):**
```gdscript
class Snapshot:
- snapshot_id: String
- timestamp: String
- description: String
- files_count: int
- checkpoint_files: Array[String]
- summary() -> String
```

### File Operations

**Copying Files:**
```gdscript
func _copy_file(source: String, dest: String) -> bool:
    var source_file = FileAccess.open(source, FileAccess.READ)
    var content = source_file.get_as_text()
    source_file.close()

    var dest_file = FileAccess.open(dest, FileAccess.WRITE)
    dest_file.store_string(content)
    dest_file.close()
```

**Directory Traversal:**
```gdscript
var dir = DirAccess.open(CHECKPOINTS_DIR)
dir.list_dir_begin()
var file_name = dir.get_next()

while file_name != "":
    if file_name.ends_with(".md"):
        # Copy checkpoint file
    file_name = dir.get_next()

dir.list_dir_end()
```

### Godot 4.5 Specific APIs

**DirAccess:**
- `DirAccess.make_dir_absolute()` - Create directory
- `DirAccess.dir_exists_absolute()` - Check directory
- `DirAccess.remove_absolute()` - Delete file/directory
- `dir.list_dir_begin()` - Start directory listing
- `dir.get_next()` - Get next file/directory
- `dir.current_is_dir()` - Check if current item is directory

**FileAccess:**
- `FileAccess.open()` - Open file
- `FileAccess.file_exists()` - Check file existence
- `file.get_as_text()` - Read entire file as string
- `file.store_string()` - Write string to file

**Time:**
- `Time.get_datetime_string_from_system()` - ISO timestamp
- `Time.get_datetime_dict_from_system()` - Date/time components

**JSON:**
- `JSON.stringify(data, indent)` - Convert to JSON string
- `JSON.parse(text)` - Parse JSON string

---

## Integration with Framework

### Other Framework Components

**Checkpoint Validation:**
- Can snapshot before/after validation fixes
- Rollback if validation breaks something

**Quality Gates:**
- Snapshot before quality improvements
- Rollback if changes decrease quality

**CI Runner:**
- Could auto-snapshot before CI runs (future)
- Rollback if CI breaks

**Integration Tests:**
- Snapshot before test-driven refactors
- Rollback if tests fail

### Git Integration

**Complementary, Not Replacement:**
- Git: Long-term version control
- Snapshots: Quick experimentation rollback
- Git: Tracks all project files
- Snapshots: Only checkpoint files

**Workflow:**
```
1. Git commit (before major work)
2. Create snapshot (for quick rollback)
3. Make changes to checkpoints
4. Test changes
5. If good: Git commit
6. If bad: Rollback to snapshot
```

---

## Potential Issues & Mitigations

### Issue 1: Snapshot Storage Size
**Problem:** Many snapshots consume disk space
**Mitigation:**
- Checkpoint files are small text (KB range)
- Delete old snapshots when not needed
- Could add automatic cleanup (future)
- Could compress snapshots (future)

### Issue 2: Snapshot Confusion
**Problem:** Too many snapshots, unclear which to use
**Mitigation:**
- Clear snapshot descriptions
- Timestamp in snapshot ID
- `print_snapshots()` shows summary
- Sort by timestamp (newest first)

### Issue 3: Partial Rollback Failure
**Problem:** Some files restore, others fail
**Mitigation:**
- Track restoration count
- Report success/failure counts
- Show which files failed
- Keep snapshot intact for retry

### Issue 4: Accidental Rollback
**Problem:** User rolls back by mistake
**Mitigation:**
- Show clear warning message
- Display what will be overwritten
- Could require confirmation (future)
- Could create auto-snapshot before rollback (future)

---

## Success Metrics

**This rollback system is successful if:**
1. ✅ Agents can create snapshots before risky changes
2. ✅ Rollback restores to exact previous state
3. ✅ Snapshots are easy to list and identify
4. ✅ System is simple to use (no complex setup)
5. ✅ Error messages are clear and helpful

---

## References

### Godot Documentation
- [Godot Docs - Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)
- [Godot Docs - DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html)
- [Godot Docs - FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)

### Community Resources
- [Kids Can Code - File I/O](https://kidscancode.org/godot_recipes/4.x/basics/file_io/index.html)
- [GDScript - Save and Load](https://gdscript.com/solutions/how-to-save-and-load-godot-game-data/)
- [Godot Forum - Directory Operations](https://forum.godotengine.org/t/how-to-copy-an-entire-directory/86503)

### Checkpoint Patterns
- [Semantic Scholar - Checkpoint-Based Rollback](https://www.semanticscholar.org/paper/Design-Patterns-for-Checkpoint-Based-Rollback-Saridakis/bda1f8f02eee3f8eddeb6f056cc5fc212723b6f2)
- [Replit Docs - Checkpoints and Rollbacks](https://docs.replit.com/replitai/checkpoints-and-rollbacks)

### Backup System Design
- [Cohesity - Snapshot Backup](https://www.cohesity.com/glossary/snapshot-backup/)
- [Medium - Designing a Backup System](https://pawitp.medium.com/designing-a-backup-system-34673bb7fc4c)

---

## Next Steps

1. ✅ Research complete
2. ⬜ Implement `scripts/checkpoint_manager.gd`
3. ⬜ Update `.gitignore` with `.snapshots/`
4. ⬜ Create checkpoint document
5. ⬜ Test snapshot creation and rollback

---

**Research Status:** COMPLETE ✅
**Ready for Implementation:** YES ✅
