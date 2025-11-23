# Godot 4.5 | GDScript 4.5
# Framework: Performance Profiler
# Purpose: Track frame times, memory usage, and system performance
# Created: 2025-11-18

extends Node
class_name PerformanceProfiler

## Performance Profiler for Rhythm RPG
##
## Tracks performance metrics for all game systems with focus on:
## - Frame time budgets (<16.67ms target for 60 FPS)
## - Per-system timing (<1ms per system ideal)
## - Memory usage
## - Beat timing accuracy
##
## Usage:
##   var profiler = PerformanceProfiler.new()
##   profiler.start_profiling()
##   # ... run game ...
##   var report = profiler.generate_report()

## Emitted when performance threshold is exceeded
signal performance_warning(system_name: String, metric: String, value: float, threshold: float)

## Performance data for a single system
class SystemProfile:
	var system_name: String = ""
	var total_time_ms: float = 0.0
	var avg_time_ms: float = 0.0
	var max_time_ms: float = 0.0
	var min_time_ms: float = 999999.0
	var sample_count: int = 0
	var warnings: Array[String] = []

	func add_sample(time_ms: float) -> void:
		total_time_ms += time_ms
		sample_count += 1
		avg_time_ms = total_time_ms / float(sample_count)
		max_time_ms = max(max_time_ms, time_ms)
		min_time_ms = min(min_time_ms, time_ms)

	func summary() -> String:
		return "%s: avg %.2fms, max %.2fms, samples %d" % [
			system_name, avg_time_ms, max_time_ms, sample_count
		]

## Performance thresholds
const TARGET_FRAME_TIME_MS: float = 16.67  # 60 FPS
const SYSTEM_TIME_BUDGET_MS: float = 1.0   # 1ms per system
const MEMORY_WARNING_MB: int = 512         # Warn above 512MB
const BEAT_TIMING_TOLERANCE_MS: float = 5.0  # 5ms beat accuracy

## Profiling state
var is_profiling: bool = false
var profile_start_time: float = 0.0
var total_frames: int = 0

## System profiles
var system_profiles: Dictionary = {}  # SystemName -> SystemProfile

## Frame time tracking
var frame_times: Array[float] = []
var max_frame_time_samples: int = 1000  # Keep last 1000 frames

## Memory tracking
var memory_samples: Array[int] = []
var max_memory_samples: int = 100

## Beat timing tracking (for rhythm accuracy)
var beat_timing_errors: Array[float] = []
var max_beat_samples: int = 500

func _ready() -> void:
	# Auto-start profiling in debug builds
	if OS.is_debug_build():
		start_profiling()

## Start performance profiling
func start_profiling() -> void:
	if is_profiling:
		push_warning("Profiler already running")
		return

	is_profiling = true
	profile_start_time = Time.get_ticks_msec()
	total_frames = 0

	print("🔍 Performance Profiler: Started")

## Stop performance profiling
func stop_profiling() -> void:
	if not is_profiling:
		push_warning("Profiler not running")
		return

	is_profiling = false
	print("🔍 Performance Profiler: Stopped")

## Track a system's execution time
func profile_system(system_name: String, execution_time_ms: float) -> void:
	if not is_profiling:
		return

	# Get or create system profile
	if not system_profiles.has(system_name):
		var profile := SystemProfile.new()
		profile.system_name = system_name
		system_profiles[system_name] = profile

	var profile: SystemProfile = system_profiles[system_name]
	profile.add_sample(execution_time_ms)

	# Check against budget
	if execution_time_ms > SYSTEM_TIME_BUDGET_MS:
		var warning := "System '%s' exceeded budget: %.2fms > %.2fms" % [
			system_name, execution_time_ms, SYSTEM_TIME_BUDGET_MS
		]
		profile.warnings.append(warning)
		performance_warning.emit(system_name, "execution_time", execution_time_ms, SYSTEM_TIME_BUDGET_MS)

## Track frame time
func profile_frame(frame_time_ms: float) -> void:
	if not is_profiling:
		return

	total_frames += 1

	# Add to frame times
	frame_times.append(frame_time_ms)
	if frame_times.size() > max_frame_time_samples:
		frame_times.pop_front()

	# Check against target
	if frame_time_ms > TARGET_FRAME_TIME_MS:
		performance_warning.emit("Frame", "frame_time", frame_time_ms, TARGET_FRAME_TIME_MS)

## Track memory usage
func profile_memory() -> void:
	if not is_profiling:
		return

	var memory_mb := int(Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0)

	memory_samples.append(memory_mb)
	if memory_samples.size() > max_memory_samples:
		memory_samples.pop_front()

	if memory_mb > MEMORY_WARNING_MB:
		performance_warning.emit("Memory", "usage_mb", memory_mb, MEMORY_WARNING_MB)

## Track beat timing accuracy (for rhythm systems)
func profile_beat_timing(timing_error_ms: float) -> void:
	if not is_profiling:
		return

	beat_timing_errors.append(timing_error_ms)
	if beat_timing_errors.size() > max_beat_samples:
		beat_timing_errors.pop_front()

	if abs(timing_error_ms) > BEAT_TIMING_TOLERANCE_MS:
		performance_warning.emit("Beat Timing", "error_ms", timing_error_ms, BEAT_TIMING_TOLERANCE_MS)

## Generate performance report
func generate_report() -> String:
	if frame_times.is_empty():
		return "⊘ No performance data collected"

	var report := """
╔═══════════════════════════════════════════════════════════════╗
║              PERFORMANCE PROFILER REPORT                       ║
╚═══════════════════════════════════════════════════════════════╝

"""

	# Overall stats
	var duration_sec := (Time.get_ticks_msec() - profile_start_time) / 1000.0
	report += "📊 Overall Statistics:\n"
	report += "  Duration: %.2f seconds\n" % duration_sec
	report += "  Total Frames: %d\n" % total_frames
	report += "  Average FPS: %.1f\n\n" % (total_frames / duration_sec if duration_sec > 0 else 0)

	# Frame time stats
	if not frame_times.is_empty():
		var avg_frame_ms := _array_average(frame_times)
		var max_frame_ms := _array_max(frame_times)
		var min_frame_ms := _array_min(frame_times)

		report += "🎮 Frame Time:\n"
		report += "  Target: %.2f ms (60 FPS)\n" % TARGET_FRAME_TIME_MS
		report += "  Average: %.2f ms\n" % avg_frame_ms
		report += "  Max: %.2f ms\n" % max_frame_ms
		report += "  Min: %.2f ms\n" % min_frame_ms

		if avg_frame_ms <= TARGET_FRAME_TIME_MS:
			report += "  Status: ✅ Within budget\n\n"
		else:
			report += "  Status: ⚠️  Over budget\n\n"

	# System profiles
	if not system_profiles.is_empty():
		report += "🔧 System Performance:\n"
		report += "  Budget per system: %.2f ms\n\n" % SYSTEM_TIME_BUDGET_MS

		# Sort systems by average time (slowest first)
		var sorted_systems := system_profiles.keys()
		sorted_systems.sort_custom(func(a, b):
			return system_profiles[a].avg_time_ms > system_profiles[b].avg_time_ms
		)

		for system_name in sorted_systems:
			var profile: SystemProfile = system_profiles[system_name]
			var status := "✅" if profile.avg_time_ms <= SYSTEM_TIME_BUDGET_MS else "⚠️"
			report += "  %s %s\n" % [status, profile.summary()]

		report += "\n"

	# Memory stats
	if not memory_samples.is_empty():
		var avg_memory := _array_average_int(memory_samples)
		var max_memory := _array_max_int(memory_samples)

		report += "💾 Memory Usage:\n"
		report += "  Average: %d MB\n" % avg_memory
		report += "  Peak: %d MB\n" % max_memory
		report += "  Status: %s\n\n" % ("✅ OK" if max_memory <= MEMORY_WARNING_MB else "⚠️ High")

	# Beat timing stats
	if not beat_timing_errors.is_empty():
		var avg_error := _array_average(beat_timing_errors)
		var max_error := _array_max(beat_timing_errors)

		report += "🎵 Beat Timing Accuracy:\n"
		report += "  Average Error: %.2f ms\n" % avg_error
		report += "  Max Error: %.2f ms\n" % max_error
		report += "  Status: %s\n\n" % ("✅ Tight" if abs(avg_error) <= BEAT_TIMING_TOLERANCE_MS else "⚠️ Loose")

	# Performance warnings
	var total_warnings := 0
	for system_name in system_profiles.keys():
		var profile: SystemProfile = system_profiles[system_name]
		total_warnings += profile.warnings.size()

	if total_warnings > 0:
		report += "⚠️  Performance Warnings: %d\n" % total_warnings
		report += "  (Check individual system profiles for details)\n"

	report += "\n" + "═" * 70 + "\n"

	return report

## Save report to file
func save_report(file_path: String = "performance-report.md") -> void:
	var report := generate_report()
	var file := FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(report)
		file.close()
		print("✅ Performance report saved to: %s" % file_path)
	else:
		push_error("Could not save performance report to: %s" % file_path)

## Helper: Average of float array
func _array_average(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var sum := 0.0
	for val in arr:
		sum += val
	return sum / float(arr.size())

## Helper: Max of float array
func _array_max(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var max_val := arr[0]
	for val in arr:
		max_val = max(max_val, val)
	return max_val

## Helper: Min of float array
func _array_min(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var min_val := arr[0]
	for val in arr:
		min_val = min(min_val, val)
	return min_val

## Helper: Average of int array
func _array_average_int(arr: Array[int]) -> int:
	if arr.is_empty():
		return 0
	var sum := 0
	for val in arr:
		sum += val
	return int(sum / arr.size())

## Helper: Max of int array
func _array_max_int(arr: Array[int]) -> int:
	if arr.is_empty():
		return 0
	var max_val := arr[0]
	for val in arr:
		max_val = max(max_val, val)
	return max_val
