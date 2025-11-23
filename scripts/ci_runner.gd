# Godot 4.5 | GDScript 4.5
# Framework: CI Test Runner
# Purpose: Run automated tests in CI/CD pipelines
# Created: 2025-11-18

extends SceneTree

## CI Test Runner
##
## Runs the integration test suite in headless mode for CI/CD pipelines.
## Returns proper exit codes for CI systems to detect pass/fail.
##
## Usage (command line):
##   godot --headless --script scripts/ci_runner.gd
##
## Exit codes:
##   0 = All tests passed
##   1 = Some tests failed
##   2 = Critical error (couldn't run tests)

class_name CIRunner

## Test configuration
var run_integration_tests: bool = true
var run_validation: bool = true
var generate_reports: bool = true
var strict_mode: bool = false  # Fail on warnings in strict mode

## Results
var exit_code: int = 0

func _init() -> void:
	print("\n" + "═" * 70)
	print("🤖 CI TEST RUNNER - Rhythm RPG Framework")
	print("═" * 70 + "\n")

	# Parse command line arguments
	_parse_arguments()

	# Run tests
	var all_passed := true

	if run_integration_tests:
		all_passed = _run_integration_tests() and all_passed

	if run_validation:
		all_passed = _run_checkpoint_validation() and all_passed

	# Generate reports
	if generate_reports:
		_generate_reports()

	# Determine exit code
	if all_passed:
		exit_code = 0
		print("\n✅ ALL CHECKS PASSED!")
	else:
		exit_code = 1
		print("\n❌ SOME CHECKS FAILED!")

	print("\n" + "═" * 70)
	print("Exit Code: %d" % exit_code)
	print("═" * 70 + "\n")

	# Exit with appropriate code
	quit(exit_code)

## Parse command-line arguments
func _parse_arguments() -> void:
	var args := OS.get_cmdline_args()

	for arg in args:
		match arg:
			"--no-integration":
				run_integration_tests = false
				print("🔧 Skipping integration tests")
			"--no-validation":
				run_validation = false
				print("🔧 Skipping checkpoint validation")
			"--no-reports":
				generate_reports = false
				print("🔧 Skipping report generation")
			"--strict":
				strict_mode = true
				print("🔧 Strict mode enabled (warnings = failures)")

## Run integration test suite
func _run_integration_tests() -> bool:
	print("\n📋 Running Integration Tests...")
	print("─" * 70)

	# Create integration test suite
	var suite = IntegrationTestSuite.new()
	var results = suite.run_all_tests()

	# Print summary
	print(results.summary())

	# Check results
	var passed := results.failed_tests == 0

	if strict_mode and results.skipped_tests > 0:
		print("⚠️  Strict mode: Treating skipped tests as failures")
		passed = false

	return passed

## Run checkpoint validation
func _run_checkpoint_validation() -> bool:
	print("\n📋 Validating Checkpoints...")
	print("─" * 70)

	# Check if checkpoints directory exists
	if not DirAccess.dir_exists_absolute("checkpoints"):
		print("⊘ No checkpoints directory found (skipping)")
		return true

	# Create validator
	var validator = CheckpointValidator.new()
	var results = validator.validate_all_checkpoints("checkpoints")

	# Count results
	var total_passed := 0
	var total_failed := 0

	for checkpoint_name in results.keys():
		var result: CheckpointValidator.ValidationResult = results[checkpoint_name]
		if result.passed:
			total_passed += 1
		else:
			total_failed += 1

	# Print summary
	print("\n📊 Checkpoint Validation Summary:")
	print("  ✅ Valid: %d" % total_passed)
	print("  ❌ Invalid: %d" % total_failed)

	return total_failed == 0

## Generate CI reports
func _generate_reports() -> void:
	print("\n📊 Generating Reports...")
	print("─" * 70)

	# Generate checkpoint validation report
	if run_validation and DirAccess.dir_exists_absolute("checkpoints"):
		var validator = CheckpointValidator.new()
		validator.generate_validation_report("CHECKPOINT-VALIDATION-REPORT.md")

	# Generate test results JSON for CI systems
	_generate_test_json()

	print("✅ Reports generated")

## Generate machine-readable test results (JSON)
func _generate_test_json() -> void:
	var test_data := {
		"timestamp": Time.get_datetime_string_from_system(),
		"framework": "Rhythm RPG",
		"version": "1.0.0",
		"integration_tests": {},
		"checkpoint_validation": {},
		"overall_status": "passed" if exit_code == 0 else "failed"
	}

	# Add integration test results
	if run_integration_tests:
		var suite = IntegrationTestSuite.new()
		var results = suite.run_all_tests()

		test_data["integration_tests"] = {
			"total": results.total_tests,
			"passed": results.passed_tests,
			"failed": results.failed_tests,
			"skipped": results.skipped_tests,
			"duration_ms": results.total_duration_ms,
			"pass_rate": (float(results.passed_tests) / float(results.total_tests) * 100.0) if results.total_tests > 0 else 0.0
		}

	# Add checkpoint validation results
	if run_validation and DirAccess.dir_exists_absolute("checkpoints"):
		var validator = CheckpointValidator.new()
		var results = validator.validate_all_checkpoints("checkpoints")

		var passed_count := 0
		var failed_count := 0

		for checkpoint_name in results.keys():
			var result: CheckpointValidator.ValidationResult = results[checkpoint_name]
			if result.passed:
				passed_count += 1
			else:
				failed_count += 1

		test_data["checkpoint_validation"] = {
			"total": passed_count + failed_count,
			"passed": passed_count,
			"failed": failed_count
		}

	# Write JSON file
	var json_string := JSON.stringify(test_data, "\t")
	var file := FileAccess.open("test-results.json", FileAccess.WRITE)

	if file:
		file.store_string(json_string)
		file.close()
		print("  • test-results.json")
	else:
		push_error("Could not write test-results.json")
