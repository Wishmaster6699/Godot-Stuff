# Godot 4.5 | GDScript 4.5
# Framework: Checkpoint Validation
# Purpose: Validate checkpoint files for completeness and quality
# Created: 2025-11-18

extends Node
class_name CheckpointValidator

## Checkpoint Validation System
##
## Validates that checkpoint .md files contain all required sections
## and that quality scores meet minimum standards.
##
## Usage:
##   var validator = CheckpointValidator.new()
##   var result = validator.validate_checkpoint("checkpoints/S01-conductor-checkpoint.md")
##   if result.passed:
##       print("✅ Checkpoint valid!")

## Validation result container
class ValidationResult:
	var passed: bool = false
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var score: int = 0
	var quality_gate_score: int = -1

	func summary() -> String:
		var status := "✅ VALID" if passed else "❌ INVALID"
		var summary_text := """
╔═══════════════════════════════════════════════════════════════╗
║         CHECKPOINT VALIDATION RESULT                           ║
╠═══════════════════════════════════════════════════════════════╣
║ Status:          %s                                            ║
║ Completeness:    %d/100                                        ║
║ Quality Score:   %s                                            ║
║ Errors:          %d                                            ║
║ Warnings:        %d                                            ║
╚═══════════════════════════════════════════════════════════════╝
""" % [
	status,
	score,
	str(quality_gate_score) if quality_gate_score >= 0 else "N/A",
	errors.size(),
	warnings.size()
]

		if errors.size() > 0:
			summary_text += "\n❌ ERRORS:\n"
			for error in errors:
				summary_text += "  • %s\n" % error

		if warnings.size() > 0:
			summary_text += "\n⚠️  WARNINGS:\n"
			for warning in warnings:
				summary_text += "  • %s\n" % warning

		return summary_text

## Required sections in checkpoint files
const REQUIRED_SECTIONS: Array[String] = [
	"Component:",
	"Agent:",
	"Date:",
	"Duration:",
	"What Was Built",
	"Key Features",
	"Research Findings",
	"Design Decisions",
	"Integration with Other",
	"Files Created",
	"Git Commit",
	"Status"
]

## Quality gate minimum score
const MIN_QUALITY_SCORE: int = 80

## Validate a checkpoint file
func validate_checkpoint(checkpoint_path: String) -> ValidationResult:
	var result := ValidationResult.new()

	# Check if file exists
	if not FileAccess.file_exists(checkpoint_path):
		result.errors.append("Checkpoint file not found: %s" % checkpoint_path)
		return result

	# Read file contents
	var file := FileAccess.open(checkpoint_path, FileAccess.READ)
	if file == null:
		result.errors.append("Could not open checkpoint file: %s" % checkpoint_path)
		return result

	var content := file.get_as_text()
	file.close()

	# Validate required sections
	var sections_found := 0
	for section in REQUIRED_SECTIONS:
		if section in content:
			sections_found += 1
		else:
			result.errors.append("Missing required section: %s" % section)

	# Calculate completeness score
	result.score = int((float(sections_found) / float(REQUIRED_SECTIONS.size())) * 100.0)

	# Extract quality gate score if present
	result.quality_gate_score = _extract_quality_score(content)

	# Check quality gate score
	if result.quality_gate_score >= 0:
		if result.quality_gate_score < MIN_QUALITY_SCORE:
			result.errors.append("Quality gate score %d is below minimum %d" % [result.quality_gate_score, MIN_QUALITY_SCORE])
	else:
		result.warnings.append("No quality gate score found in checkpoint")

	# Check for empty sections
	_check_empty_sections(content, result)

	# Validate file references exist
	_validate_file_references(content, result)

	# Determine pass/fail
	result.passed = result.errors.size() == 0 and result.score >= 80

	return result

## Validate multiple checkpoints
func validate_all_checkpoints(checkpoint_dir: String = "checkpoints") -> Dictionary:
	var all_results := {}
	var total_passed := 0
	var total_failed := 0

	print("\n🔍 Validating all checkpoints in: %s" % checkpoint_dir)
	print("═" * 60)

	# Get all .md files in checkpoint directory
	var dir := DirAccess.open(checkpoint_dir)
	if dir == null:
		push_error("Cannot open checkpoint directory: %s" % checkpoint_dir)
		return all_results

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".md") and not file_name.begins_with("."):
			var checkpoint_path := checkpoint_dir + "/" + file_name
			print("\n📄 Validating: %s" % file_name)

			var result := validate_checkpoint(checkpoint_path)
			all_results[file_name] = result

			if result.passed:
				print("  ✅ VALID (Score: %d/100)" % result.score)
				total_passed += 1
			else:
				print("  ❌ INVALID (Score: %d/100, Errors: %d)" % [result.score, result.errors.size()])
				total_failed += 1

		file_name = dir.get_next()

	dir.list_dir_end()

	# Print summary
	print("\n" + "═" * 60)
	print("📊 VALIDATION SUMMARY")
	print("  Total Checkpoints: %d" % (total_passed + total_failed))
	print("  ✅ Valid: %d" % total_passed)
	print("  ❌ Invalid: %d" % total_failed)
	print("═" * 60 + "\n")

	return all_results

## Extract quality gate score from checkpoint content
func _extract_quality_score(content: String) -> int:
	# Look for patterns like "Total: 85/100" or "Score: 85"
	var patterns := [
		r"\*\*Total:\*\*\s*(\d+)/100",
		r"Total Score:\s*(\d+)",
		r"Quality Score:\s*(\d+)"
	]

	for pattern in patterns:
		var regex := RegEx.new()
		regex.compile(pattern)
		var result := regex.search(content)
		if result:
			return int(result.get_string(1))

	return -1

## Check for sections that exist but are empty
func _check_empty_sections(content: String, result: ValidationResult) -> void:
	var empty_sections := [
		{"name": "Key Features", "marker": "### Key Features"},
		{"name": "Research Findings", "marker": "### Research Findings"},
		{"name": "Files Created", "marker": "### Files Created"}
	]

	for section_check in empty_sections:
		var marker: String = section_check["marker"]
		var name: String = section_check["name"]

		if marker in content:
			var start_idx := content.find(marker)
			var next_section := content.find("###", start_idx + marker.length())
			var section_content := ""

			if next_section > start_idx:
				section_content = content.substr(start_idx + marker.length(), next_section - start_idx - marker.length())
			else:
				section_content = content.substr(start_idx + marker.length())

			# Remove whitespace and check if empty
			section_content = section_content.strip_edges()
			if section_content.length() < 10:  # Less than 10 chars is likely empty
				result.warnings.append("%s section appears to be empty" % name)

## Validate that referenced files actually exist
func _validate_file_references(content: String, result: ValidationResult) -> void:
	# Look for file paths in "Files Created" section
	var files_section_start := content.find("### Files Created")
	if files_section_start < 0:
		return

	var files_section_end := content.find("###", files_section_start + 10)
	var files_section := ""

	if files_section_end > files_section_start:
		files_section = content.substr(files_section_start, files_section_end - files_section_start)
	else:
		files_section = content.substr(files_section_start)

	# Extract file paths (basic pattern matching)
	var lines := files_section.split("\n")
	for line in lines:
		# Look for patterns like: - `path/to/file.gd`
		if line.strip_edges().begins_with("- `") or line.strip_edges().begins_with("* `"):
			var path_start := line.find("`") + 1
			var path_end := line.find("`", path_start)
			if path_end > path_start:
				var file_path := line.substr(path_start, path_end - path_start)

				# Skip URLs and placeholders
				if not file_path.begins_with("http") and not "[" in file_path:
					if not FileAccess.file_exists(file_path):
						result.warnings.append("Referenced file not found: %s" % file_path)

## Generate a checkpoint validation report
func generate_validation_report(output_path: String = "CHECKPOINT-VALIDATION-REPORT.md") -> void:
	var all_results := validate_all_checkpoints()

	var report := """# Checkpoint Validation Report

**Generated:** %s
**Total Checkpoints:** %d

## Summary

""" % [Time.get_datetime_string_from_system(), all_results.size()]

	var passed_count := 0
	var failed_count := 0

	for checkpoint_name in all_results.keys():
		var result: ValidationResult = all_results[checkpoint_name]
		if result.passed:
			passed_count += 1
		else:
			failed_count += 1

	report += "- ✅ Valid: %d\n" % passed_count
	report += "- ❌ Invalid: %d\n" % failed_count
	report += "\n## Details\n\n"

	for checkpoint_name in all_results.keys():
		var result: ValidationResult = all_results[checkpoint_name]
		var status := "✅ VALID" if result.passed else "❌ INVALID"

		report += "### %s - %s\n\n" % [checkpoint_name, status]
		report += "**Completeness:** %d/100\n" % result.score

		if result.quality_gate_score >= 0:
			report += "**Quality Score:** %d/100\n" % result.quality_gate_score

		if result.errors.size() > 0:
			report += "\n**Errors:**\n"
			for error in result.errors:
				report += "- %s\n" % error

		if result.warnings.size() > 0:
			report += "\n**Warnings:**\n"
			for warning in result.warnings:
				report += "- %s\n" % warning

		report += "\n---\n\n"

	# Write report
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
		print("✅ Validation report written to: %s" % output_path)
	else:
		push_error("Could not write validation report to: %s" % output_path)
