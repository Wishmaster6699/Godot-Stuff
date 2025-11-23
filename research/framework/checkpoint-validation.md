# Research: Checkpoint Validation in Godot 4.5

**Date:** 2025-11-18
**Component:** Framework Component 3
**Agent:** F1

## Research Questions

1. How does file I/O work in Godot 4.5?
2. How can we parse and validate markdown files?
3. How to extract structured data from text files?
4. What are best practices for file validation?

## Findings

### Godot 4.5 File API Changes

**Major Change from Godot 3.x:**
- `File` class no longer exists
- Use `FileAccess` instead
- Different API for opening files

**Old (Godot 3.x):**
```gdscript
var file = File.new()
file.open(path, File.READ)
```

**New (Godot 4.x):**
```gdscript
var file = FileAccess.open(path, FileAccess.READ)
```

**Source:** Stack Overflow, Godot Forum discussions

### FileAccess API

**Opening Files:**
```gdscript
var file := FileAccess.open(path, FileAccess.READ)
if file == null:
    push_error("Cannot open file")
    return
var content := file.get_as_text()
file.close()
```

**Checking File Existence:**
```gdscript
if FileAccess.file_exists(path):
    # File exists
```

**Key Methods:**
- `FileAccess.open(path, mode)` - Open file
- `FileAccess.file_exists(path)` - Check existence
- `get_as_text()` - Read entire file as string
- `close()` - Close file

### DirAccess API (Directory Operations)

**Listing Directory Contents:**
```gdscript
var dir := DirAccess.open(directory_path)
if dir == null:
    push_error("Cannot open directory")
    return

dir.list_dir_begin()
var file_name := dir.get_next()

while file_name != "":
    if file_name.ends_with(".md"):
        # Process markdown file
    file_name = dir.get_next()

dir.list_dir_end()
```

**Checking Directory Existence:**
```gdscript
if DirAccess.dir_exists_absolute(path):
    # Directory exists
```

**Source:** Godot 4.4 Documentation

### JSON Parsing in Godot 4.5

**API Change:**
- Old: `parse_json()` function
- New: `JSON.parse_string()` method

**Usage:**
```gdscript
var json_string = '{"key": "value"}'
var parsed = JSON.parse_string(json_string)
if parsed == null:
    push_error("Invalid JSON")
else:
    print(parsed["key"])  # "value"
```

**Source:** Godot 4.4 Documentation, Stack Overflow

### Regular Expressions (RegEx)

**Creating and Using RegEx:**
```gdscript
var regex := RegEx.new()
regex.compile(r"Total:\s*(\d+)/100")
var result := regex.search(content)
if result:
    var score := int(result.get_string(1))
```

**Capture Groups:**
- `result.get_string(0)` - Full match
- `result.get_string(1)` - First capture group
- `result.get_string(2)` - Second capture group

**Common Patterns:**
- `\d+` - One or more digits
- `\s*` - Zero or more whitespace
- `(\d+)` - Capture group for digits
- `.*?` - Non-greedy any character

### Markdown Validation Approaches

**Section Detection:**
```gdscript
# Check if section exists
if "### Key Features" in content:
    # Section found
```

**Extracting Section Content:**
```gdscript
var marker := "### Key Features"
var start_idx := content.find(marker)
var next_section := content.find("###", start_idx + marker.length())

var section_content := ""
if next_section > start_idx:
    section_content = content.substr(start_idx + marker.length(),
                                     next_section - start_idx - marker.length())
else:
    section_content = content.substr(start_idx + marker.length())
```

**Checking for Empty Sections:**
```gdscript
section_content = section_content.strip_edges()
if section_content.length() < 10:
    # Likely empty
```

### File Reference Validation

**Pattern Matching for File Paths:**
```gdscript
# Look for patterns like: - `path/to/file.gd`
if line.strip_edges().begins_with("- `"):
    var path_start := line.find("`") + 1
    var path_end := line.find("`", path_start)
    if path_end > path_start:
        var file_path := line.substr(path_start, path_end - path_start)

        # Skip URLs
        if not file_path.begins_with("http"):
            if not FileAccess.file_exists(file_path):
                # File not found
```

## Validation Best Practices

### Required Sections Approach

**Define Required Sections:**
```gdscript
const REQUIRED_SECTIONS: Array[String] = [
    "Component:",
    "Agent:",
    "Date:",
    # ... more sections
]
```

**Validate Presence:**
```gdscript
for section in REQUIRED_SECTIONS:
    if section in content:
        sections_found += 1
    else:
        errors.append("Missing: %s" % section)
```

### Completeness Scoring

**Calculate Score:**
```gdscript
var score := int((float(sections_found) / float(total_sections)) * 100.0)
```

**Minimum Threshold:**
- 80% completeness for valid checkpoint
- Aligns with quality gate minimum

### Validation Result Structure

**ValidationResult Class:**
```gdscript
class ValidationResult:
    var passed: bool = false
    var errors: Array[String] = []
    var warnings: Array[String] = []
    var score: int = 0
```

**Benefits:**
- Clear pass/fail status
- Detailed error reporting
- Warning vs error distinction
- Numeric score for trends

## References

1. **Godot 4.4 JSON Class Docs:** https://docs.godotengine.org/en/4.4/classes/class_json.html
2. **Stack Overflow - JSON parsing in Godot 4:** Various threads on API changes
3. **Godot Forum - File I/O in Godot 4:** Community discussions on FileAccess
4. **GitHub - JSON Library for Godot 4:** https://github.com/kibble-cabal/json-library
5. **Online JSON Validators:** jsonformatter.curiousconcept.com (for testing)

## Conclusion

For checkpoint validation:
- Use FileAccess API (not File)
- DirAccess for batch validation
- RegEx for extracting quality scores
- String manipulation for section validation
- File reference checking for integrity
- Clear ValidationResult class for reporting
