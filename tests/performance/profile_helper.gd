# Godot 4.5 | GDScript 4.5
# Helper: Easy Performance Profiling
extends Node

## Easy performance profiling helper
##
## Usage in any system:
##   ProfileHelper.start("MySystem")
##   # ... do work ...
##   ProfileHelper.end("MySystem")

static var profiler: PerformanceProfiler = null
static var active_timers: Dictionary = {}  # SystemName -> start_time

static func get_profiler() -> PerformanceProfiler:
	if profiler == null:
		profiler = PerformanceProfiler.new()
		profiler.start_profiling()
	return profiler

## Start timing a system
static func start(system_name: String) -> void:
	active_timers[system_name] = Time.get_ticks_usec()

## End timing a system
static func end(system_name: String) -> void:
	if not active_timers.has(system_name):
		push_warning("ProfileHelper: No start time for system '%s'" % system_name)
		return

	var start_time: int = active_timers[system_name]
	var end_time := Time.get_ticks_usec()
	var duration_ms := (end_time - start_time) / 1000.0

	get_profiler().profile_system(system_name, duration_ms)
	active_timers.erase(system_name)

## Generate and print report
static func report() -> void:
	if profiler:
		print(profiler.generate_report())

## Save report to file
static func save(file_path: String = "performance-report.md") -> void:
	if profiler:
		profiler.save_report(file_path)
