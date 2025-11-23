# Godot 4.5 | GDScript 4.5
# System: S24 - Cooking System
# Created: 2025-11-18
# Dependencies: S05 (Inventory), S12 (Monster Database for drops), S01 (Conductor for timing)

extends Node
class_name CookingSystemImpl

## Manages cooking system with 50+ ingredients, multiple cooking methods, and quality-based outcomes
## Integrates with rhythm system for quality calculation (Perfect/Good/Miss affects potency)

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when a dish is successfully cooked
## dish_id: The ID of the created dish item
## quality: Quality level ("Perfect", "Good", or "Miss")
signal dish_cooked(dish_id: String, quality: String)

## Emitted when a new recipe is discovered
## recipe_id: The ID of the newly discovered recipe
signal recipe_discovered(recipe_id: String)

## Emitted when an ingredient is consumed during cooking
## ingredient_id: The ID of the ingredient used
## amount: Number of ingredients consumed
signal ingredient_used(ingredient_id: String, amount: int)

# ============================================================================
# CONSTANTS
# ============================================================================

const INGREDIENTS_DATA_PATH: String = "res://data/ingredients.json"
const RECIPES_DATA_PATH: String = "res://data/recipes.json"

# Quality thresholds (timing window in milliseconds)
const PERFECT_TIMING_WINDOW: float = 100.0  # Within 100ms of beat
const GOOD_TIMING_WINDOW: float = 250.0     # Within 250ms of beat

# Quality multipliers
const PERFECT_MULTIPLIER: float = 1.5  # 150% effectiveness
const GOOD_MULTIPLIER: float = 1.0     # 100% effectiveness
const MISS_MULTIPLIER: float = 0.5     # 50% effectiveness

# ============================================================================
# DATA STORAGE
# ============================================================================

## All available ingredients loaded from JSON
var all_ingredients: Dictionary = {}

## All available recipes loaded from JSON
var all_recipes: Dictionary = {}

## Player's known/discovered recipes (array of recipe IDs)
var known_recipes: Array[String] = []

## Player's discovered ingredients (array of ingredient IDs)
var ingredients_discovered: Array[String] = []

## Flag to track if data has been loaded
var data_loaded: bool = false

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	load_cooking_data()

## Load ingredients and recipes from JSON files
func load_cooking_data() -> void:
	if data_loaded:
		return

	load_ingredients()
	load_recipes()
	data_loaded = true
	print("CookingSystem: Loaded ", all_ingredients.size(), " ingredients and ", all_recipes.size(), " recipes")

## Load ingredients from JSON file
func load_ingredients() -> void:
	var file: FileAccess = FileAccess.open(INGREDIENTS_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("CookingSystem: Failed to load ingredients from " + INGREDIENTS_DATA_PATH)
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)

	if parse_result != OK:
		push_error("CookingSystem: JSON parse error in ingredients: " + json.get_error_message())
		return

	var data: Dictionary = json.data
	if data.has("ingredients"):
		var ingredients_array: Array = data["ingredients"]
		for ingredient_data in ingredients_array:
			if ingredient_data is Dictionary and ingredient_data.has("id"):
				var ingredient_id: String = ingredient_data["id"]
				all_ingredients[ingredient_id] = ingredient_data
	else:
		push_error("CookingSystem: No 'ingredients' array found in JSON")

## Load recipes from JSON file
func load_recipes() -> void:
	var file: FileAccess = FileAccess.open(RECIPES_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("CookingSystem: Failed to load recipes from " + RECIPES_DATA_PATH)
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)

	if parse_result != OK:
		push_error("CookingSystem: JSON parse error in recipes: " + json.get_error_message())
		return

	var data: Dictionary = json.data
	if data.has("recipes"):
		var recipes_array: Array = data["recipes"]
		for recipe_data in recipes_array:
			if recipe_data is Dictionary and recipe_data.has("id"):
				var recipe_id: String = recipe_data["id"]
				all_recipes[recipe_id] = recipe_data
	else:
		push_error("CookingSystem: No 'recipes' array found in JSON")

# ============================================================================
# COOKING METHODS
# ============================================================================

## Main cooking function - validates recipe, checks ingredients, determines quality, creates dish
## recipe_id: ID of the recipe to cook
## ingredients: Array of ingredient IDs being used
## timing_ms: Timing offset from beat in milliseconds (for quality calculation)
## Returns: Dictionary with result { "success": bool, "dish": Dictionary, "quality": String, "error": String }
func cook(recipe_id: String, ingredients: Array[String], timing_ms: float = 0.0) -> Dictionary:
	if not data_loaded:
		load_cooking_data()

	# Validate recipe exists and is known
	if not all_recipes.has(recipe_id):
		return _create_error_result("Recipe does not exist: " + recipe_id)

	if not is_recipe_known(recipe_id):
		return _create_error_result("Recipe not yet discovered: " + recipe_id)

	var recipe: Dictionary = all_recipes[recipe_id]

	# Validate ingredients match recipe
	if not validate_recipe(recipe_id, ingredients):
		return _create_error_result("Ingredients do not match recipe requirements")

	# Check if player has ingredients (integrates with S05 Inventory)
	# Note: Actual inventory checking should be done by caller before calling cook()
	# This is a design decision to keep cooking system decoupled from inventory

	# Determine quality based on rhythm timing
	var quality: String = determine_quality(timing_ms)

	# Create dish with quality modifier
	var dish: Dictionary = create_dish(recipe_id, quality)

	# Emit signals
	for ingredient_id in ingredients:
		ingredient_used.emit(ingredient_id, 1)

	dish_cooked.emit(dish["item_id"], quality)

	return {
		"success": true,
		"dish": dish,
		"quality": quality,
		"error": ""
	}

## Validate if provided ingredients match recipe requirements
## recipe_id: ID of the recipe to validate
## ingredients: Array of ingredient IDs to check
## Returns: true if ingredients match recipe, false otherwise
func validate_recipe(recipe_id: String, ingredients: Array[String]) -> bool:
	if not all_recipes.has(recipe_id):
		return false

	var recipe: Dictionary = all_recipes[recipe_id]
	if not recipe.has("ingredients"):
		return false

	var required_ingredients: Array = recipe["ingredients"]

	# Check if ingredient counts match
	if ingredients.size() != required_ingredients.size():
		return false

	# Create sorted copies for comparison
	var sorted_provided: Array[String] = ingredients.duplicate()
	sorted_provided.sort()

	var sorted_required: Array[String] = []
	for ing in required_ingredients:
		sorted_required.append(str(ing))
	sorted_required.sort()

	# Compare sorted arrays
	for i in range(sorted_provided.size()):
		if sorted_provided[i] != sorted_required[i]:
			return false

	return true

## Determine quality based on rhythm timing
## timing_ms: Offset from beat in milliseconds (absolute value)
## Returns: "Perfect", "Good", or "Miss"
func determine_quality(timing_ms: float) -> String:
	var abs_timing: float = abs(timing_ms)

	if abs_timing <= PERFECT_TIMING_WINDOW:
		return "Perfect"
	elif abs_timing <= GOOD_TIMING_WINDOW:
		return "Good"
	else:
		return "Miss"

## Create a dish based on recipe and quality
## recipe_id: ID of the recipe
## quality: Quality level ("Perfect", "Good", "Miss")
## Returns: Dictionary with dish data including modified effects
func create_dish(recipe_id: String, quality: String) -> Dictionary:
	if not all_recipes.has(recipe_id):
		return {}

	var recipe: Dictionary = all_recipes[recipe_id]
	var output: Dictionary = recipe.get("output", {}).duplicate(true)

	# Get quality multiplier
	var multiplier: float = get_quality_multiplier(quality)

	# Apply multiplier to effects
	if output.has("effects"):
		var effects: Dictionary = output["effects"]
		for effect_key in effects.keys():
			if effects[effect_key] is int or effects[effect_key] is float:
				effects[effect_key] = int(effects[effect_key] * multiplier)

	# Add quality metadata
	output["quality"] = quality
	output["quality_multiplier"] = multiplier
	output["recipe_id"] = recipe_id
	output["recipe_name"] = recipe.get("name", "Unknown Dish")

	return output

## Get quality multiplier for effect calculations
## quality: Quality level string
## Returns: Multiplier value (1.5, 1.0, or 0.5)
func get_quality_multiplier(quality: String) -> float:
	match quality:
		"Perfect":
			return PERFECT_MULTIPLIER
		"Good":
			return GOOD_MULTIPLIER
		"Miss":
			return MISS_MULTIPLIER
		_:
			return GOOD_MULTIPLIER

# ============================================================================
# RECIPE & INGREDIENT MANAGEMENT
# ============================================================================

## Discover a new recipe, adding it to known recipes
## recipe_id: ID of the recipe to discover
## Returns: true if newly discovered, false if already known
func discover_recipe(recipe_id: String) -> bool:
	if not all_recipes.has(recipe_id):
		push_warning("CookingSystem: Attempted to discover non-existent recipe: " + recipe_id)
		return false

	if is_recipe_known(recipe_id):
		return false

	known_recipes.append(recipe_id)
	recipe_discovered.emit(recipe_id)
	print("CookingSystem: Discovered new recipe: ", all_recipes[recipe_id].get("name", recipe_id))
	return true

## Check if a recipe is known to the player
## recipe_id: ID of the recipe to check
## Returns: true if recipe is known, false otherwise
func is_recipe_known(recipe_id: String) -> bool:
	return known_recipes.has(recipe_id)

## Discover a new ingredient
## ingredient_id: ID of the ingredient to discover
## Returns: true if newly discovered, false if already known
func discover_ingredient(ingredient_id: String) -> bool:
	if not all_ingredients.has(ingredient_id):
		push_warning("CookingSystem: Attempted to discover non-existent ingredient: " + ingredient_id)
		return false

	if is_ingredient_discovered(ingredient_id):
		return false

	ingredients_discovered.append(ingredient_id)
	print("CookingSystem: Discovered new ingredient: ", all_ingredients[ingredient_id].get("name", ingredient_id))
	return true

## Check if an ingredient has been discovered
## ingredient_id: ID of the ingredient to check
## Returns: true if discovered, false otherwise
func is_ingredient_discovered(ingredient_id: String) -> bool:
	return ingredients_discovered.has(ingredient_id)

## Get all recipes that can be cooked with available ingredients
## available_ingredients: Array of ingredient IDs the player currently has
## Returns: Array of recipe IDs that can be cooked
func get_cookable_recipes(available_ingredients: Array[String]) -> Array[String]:
	var cookable: Array[String] = []

	for recipe_id in known_recipes:
		if has_ingredients_for_recipe(recipe_id, available_ingredients):
			cookable.append(recipe_id)

	return cookable

## Check if player has the required ingredients for a recipe
## recipe_id: ID of the recipe
## available_ingredients: Array of ingredient IDs available to the player
## Returns: true if all required ingredients are available
func has_ingredients_for_recipe(recipe_id: String, available_ingredients: Array[String]) -> bool:
	if not all_recipes.has(recipe_id):
		return false

	var recipe: Dictionary = all_recipes[recipe_id]
	var required: Array = recipe.get("ingredients", [])

	# Create a copy of available ingredients to count
	var available_copy: Array[String] = available_ingredients.duplicate()

	# Check if each required ingredient exists in available
	for req_ing in required:
		var req_id: String = str(req_ing)
		var index: int = available_copy.find(req_id)
		if index == -1:
			return false
		available_copy.remove_at(index)

	return true

# ============================================================================
# QUERY METHODS
# ============================================================================

## Get all recipes for a specific town
## town_id: ID of the town (e.g., "forest_town")
## Returns: Array of recipe IDs specific to that town
func get_town_recipes(town_id: String) -> Array[String]:
	var town_recipes: Array[String] = []

	for recipe_id in all_recipes.keys():
		var recipe: Dictionary = all_recipes[recipe_id]
		if recipe.get("town_specific", null) == town_id:
			town_recipes.append(recipe_id)

	return town_recipes

## Get all recipes using a specific cooking method
## method: Cooking method ("fire", "oven", "sandwich", "shop")
## Returns: Array of recipe IDs using that method
func get_recipes_by_method(method: String) -> Array[String]:
	var method_recipes: Array[String] = []

	for recipe_id in all_recipes.keys():
		var recipe: Dictionary = all_recipes[recipe_id]
		if recipe.get("cooking_method", "") == method:
			method_recipes.append(recipe_id)

	return method_recipes

## Get ingredient data by ID
## ingredient_id: ID of the ingredient
## Returns: Dictionary with ingredient data, or empty dict if not found
func get_ingredient_data(ingredient_id: String) -> Dictionary:
	return all_ingredients.get(ingredient_id, {})

## Get recipe data by ID
## recipe_id: ID of the recipe
## Returns: Dictionary with recipe data, or empty dict if not found
func get_recipe_data(recipe_id: String) -> Dictionary:
	return all_recipes.get(recipe_id, {})

## Get all ingredients from a specific source
## source: Source type ("overworld_forest", "monster_drop", "npc_gift", "shop")
## Returns: Array of ingredient IDs from that source
func get_ingredients_by_source(source: String) -> Array[String]:
	var source_ingredients: Array[String] = []

	for ingredient_id in all_ingredients.keys():
		var ingredient: Dictionary = all_ingredients[ingredient_id]
		if ingredient.get("source", "") == source:
			source_ingredients.append(ingredient_id)

	return source_ingredients

## Get all ingredients dropped by a specific monster
## monster_id: ID of the monster (e.g., "095_dragon")
## Returns: Array of ingredient IDs dropped by that monster
func get_monster_ingredients(monster_id: String) -> Array[String]:
	var monster_drops: Array[String] = []

	for ingredient_id in all_ingredients.keys():
		var ingredient: Dictionary = all_ingredients[ingredient_id]
		if ingredient.get("source", "") == "monster_drop" and ingredient.get("monster_id", "") == monster_id:
			monster_drops.append(ingredient_id)

	return monster_drops

# ============================================================================
# SAVE/LOAD SUPPORT
# ============================================================================

## Get save data for the cooking system
## Returns: Dictionary with player's cooking progress
func get_save_data() -> Dictionary:
	return {
		"known_recipes": known_recipes.duplicate(),
		"ingredients_discovered": ingredients_discovered.duplicate()
	}

## Load save data for the cooking system
## save_data: Dictionary with saved cooking progress
func load_save_data(save_data: Dictionary) -> void:
	if save_data.has("known_recipes"):
		known_recipes = save_data["known_recipes"].duplicate()

	if save_data.has("ingredients_discovered"):
		ingredients_discovered = save_data["ingredients_discovered"].duplicate()

	print("CookingSystem: Loaded save data - ", known_recipes.size(), " known recipes, ", ingredients_discovered.size(), " discovered ingredients")

# ============================================================================
# HELPER METHODS
# ============================================================================

## Create an error result dictionary
func _create_error_result(error_message: String) -> Dictionary:
	return {
		"success": false,
		"dish": {},
		"quality": "",
		"error": error_message
	}
