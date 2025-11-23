# Godot 4.5 | GDScript 4.5
# System: S25 - Crafting System
# Created: 2025-11-18
# Dependencies: S08 (Equipment), S12 (Monsters for materials), S07 (Weapons)
# Purpose: Combine base items with modifiers, weapon enchantment, armor customization, recipe discovery

extends Node
class_name CraftingSystemImpl

## Signals for crafting events

## Emitted when crafting completes successfully
signal item_crafted(item_id: String, modifiers: Array, result: Dictionary)

## Emitted when a new recipe is discovered
signal recipe_discovered(recipe_id: String)

## Emitted when enchantment is applied to an item
signal enchantment_applied(item_id: String, enchantment: String)

## Emitted when armor customization is applied
signal armor_customized(item_id: String, customization: Dictionary)

## Emitted when crafting fails
signal crafting_failed(reason: String)

## Recipe discovery types
enum DiscoveryType {
	BLUEPRINT,      # Found in world as items
	NPC_TAUGHT,     # Learned from NPC craftsmen
	EXPERIMENTATION # Discovered by trying combinations
}

## Enchantment types for weapons
enum EnchantmentType {
	FIRE,
	ICE,
	LIGHTNING,
	POISON,
	HOLY,
	DARK
}

# Configuration paths
const RECIPES_PATH: String = "res://data/crafting_recipes.json"
const MATERIALS_PATH: String = "res://data/crafting_materials.json"

# Recipe database (loaded from JSON)
var recipe_database: Dictionary = {}

# Known recipes (unlocked by player)
var known_recipes: Array[String] = []

# Material definitions
var material_database: Dictionary = {}

# Player inventory reference (will be set externally)
var player_inventory: Node = null

# Equipment manager reference (for equipment crafting)
var equipment_manager: Node = null

# Initialization state
var is_initialized: bool = false

# Enchantment definitions
var enchantment_effects: Dictionary = {
	"fire": {
		"damage_type": "fire",
		"damage_bonus": 10,
		"status_effect": "burn",
		"status_chance": 0.25,
		"visual": "fire_trail_particle"
	},
	"ice": {
		"damage_type": "ice",
		"damage_bonus": 8,
		"status_effect": "slow",
		"status_chance": 0.30,
		"visual": "ice_crystal_particle"
	},
	"lightning": {
		"damage_type": "lightning",
		"damage_bonus": 12,
		"status_effect": "stun",
		"status_chance": 0.20,
		"visual": "lightning_spark_particle"
	},
	"poison": {
		"damage_type": "poison",
		"damage_bonus": 5,
		"status_effect": "poison",
		"status_chance": 0.40,
		"visual": "poison_cloud_particle"
	},
	"holy": {
		"damage_type": "holy",
		"damage_bonus": 15,
		"status_effect": "purify",
		"status_chance": 0.15,
		"visual": "holy_light_particle"
	},
	"dark": {
		"damage_type": "dark",
		"damage_bonus": 13,
		"status_effect": "curse",
		"status_chance": 0.20,
		"visual": "dark_aura_particle"
	}
}

# Armor set definitions for set bonuses
var armor_sets: Dictionary = {
	"iron_set": {
		"pieces": ["iron_helmet", "iron_torso", "iron_boots"],
		"two_piece_bonus": {"defense": 5, "physical_resistance": 0.05},
		"three_piece_bonus": {"defense": 15, "physical_resistance": 0.15, "max_hp": 20}
	},
	"leather_set": {
		"pieces": ["leather_helmet", "leather_torso", "leather_boots"],
		"two_piece_bonus": {"speed": 10, "evasion": 0.05},
		"three_piece_bonus": {"speed": 25, "evasion": 0.15, "critical_chance": 0.10}
	},
	"flame_set": {
		"pieces": ["flame_helmet", "flame_torso", "flame_boots"],
		"two_piece_bonus": {"fire_resistance": 0.10, "attack": 5},
		"three_piece_bonus": {"fire_resistance": 0.30, "attack": 15, "fire_damage": 10}
	}
}

func _ready() -> void:
	print("CraftingSystem: Initializing...")
	_load_recipe_database()
	_load_material_database()
	is_initialized = true
	print("CraftingSystem: Ready (Recipes: %d, Materials: %d)" % [recipe_database.size(), material_database.size()])

func _load_recipe_database() -> void:
	"""Load crafting recipes from JSON"""
	var file = FileAccess.open(RECIPES_PATH, FileAccess.READ)
	if file == null:
		push_error("CraftingSystem: Failed to load recipes from %s" % RECIPES_PATH)
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("CraftingSystem: JSON parse error in recipes: %s" % json.get_error_message())
		return

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("crafting_recipes"):
		push_error("CraftingSystem: Invalid recipe database structure")
		return

	# Build recipe lookup dictionary by ID
	var recipe_list = data["crafting_recipes"] as Array
	for recipe_item in recipe_list:
		var recipe_dict = recipe_item as Dictionary
		var recipe_id = recipe_dict.get("id", "") as String
		if recipe_id != "":
			recipe_database[recipe_id] = recipe_dict

	print("CraftingSystem: Loaded %d recipe definitions" % recipe_database.size())

func _load_material_database() -> void:
	"""Load material definitions from JSON (materials gathered from world/monsters)"""
	# For now, create default materials
	# In full implementation, this would load from JSON
	material_database = {
		"fire_gem": {
			"id": "fire_gem",
			"name": "Fire Gem",
			"rarity": "rare",
			"source": "fire_elemental_drop"
		},
		"fire_essence": {
			"id": "fire_essence",
			"name": "Fire Essence",
			"rarity": "uncommon",
			"source": "fire_monster_drop"
		},
		"ice_gem": {
			"id": "ice_gem",
			"name": "Ice Gem",
			"rarity": "rare",
			"source": "ice_elemental_drop"
		},
		"ice_essence": {
			"id": "ice_essence",
			"name": "Ice Essence",
			"rarity": "uncommon",
			"source": "ice_monster_drop"
		},
		"lightning_gem": {
			"id": "lightning_gem",
			"name": "Lightning Gem",
			"rarity": "rare",
			"source": "lightning_elemental_drop"
		},
		"blue_dye": {
			"id": "blue_dye",
			"name": "Blue Dye",
			"rarity": "common",
			"source": "crafted_or_bought"
		},
		"red_dye": {
			"id": "red_dye",
			"name": "Red Dye",
			"rarity": "common",
			"source": "crafted_or_bought"
		},
		"iron_ore": {
			"id": "iron_ore",
			"name": "Iron Ore",
			"rarity": "common",
			"source": "mining"
		},
		"leather_scraps": {
			"id": "leather_scraps",
			"name": "Leather Scraps",
			"rarity": "common",
			"source": "monster_drops"
		}
	}

	print("CraftingSystem: Loaded %d material definitions" % material_database.size())

## Public API Methods

func craft(base_item: String, modifiers: Array) -> Dictionary:
	"""
	Craft an item by combining base item with modifiers
	Returns crafted item dictionary on success, empty dictionary on failure
	"""
	if not is_initialized:
		push_error("CraftingSystem: Cannot craft, not initialized")
		crafting_failed.emit("System not initialized")
		return {}

	# Find matching recipe
	var recipe = _find_recipe(base_item, modifiers)
	if recipe.is_empty():
		push_warning("CraftingSystem: No recipe found for base '%s' with modifiers %s" % [base_item, str(modifiers)])
		crafting_failed.emit("Recipe not found")
		return {}

	# Check if recipe is known
	var recipe_id = recipe.get("id", "") as String
	if not _is_recipe_known(recipe_id):
		push_warning("CraftingSystem: Recipe '%s' not yet discovered" % recipe_id)
		crafting_failed.emit("Recipe not discovered")
		return {}

	# Check if player has required materials
	if not _has_required_materials(base_item, modifiers):
		push_warning("CraftingSystem: Missing required materials for recipe '%s'" % recipe_id)
		crafting_failed.emit("Missing materials")
		return {}

	# Craft the item
	var result = _create_crafted_item(recipe)

	# Consume materials (would integrate with S05 Inventory System)
	_consume_materials(base_item, modifiers)

	# Emit signal
	item_crafted.emit(base_item, modifiers, result)

	print("CraftingSystem: Crafted '%s' from base '%s' with modifiers %s" % [result.get("name", "Unknown"), base_item, str(modifiers)])

	return result

func craft_by_recipe_id(recipe_id: String) -> Dictionary:
	"""
	Craft an item using a recipe ID
	Convenience method for UI-based crafting
	"""
	if not recipe_database.has(recipe_id):
		crafting_failed.emit("Recipe not found")
		return {}

	var recipe = recipe_database[recipe_id]
	var base_item = recipe.get("base_item", "")
	var modifiers = recipe.get("modifiers", [])

	return craft(base_item, modifiers)

func apply_enchantment(item: Dictionary, enchantment: String) -> Dictionary:
	"""
	Apply an enchantment to a weapon or armor
	Returns the enchanted item dictionary
	"""
	if item.is_empty():
		push_error("CraftingSystem: Cannot enchant empty item")
		return {}

	if not enchantment_effects.has(enchantment):
		push_error("CraftingSystem: Unknown enchantment type '%s'" % enchantment)
		return {}

	# Create enchanted copy
	var enchanted_item = item.duplicate(true)

	# Apply enchantment effects
	var effect = enchantment_effects[enchantment]

	# Add enchantment to item name
	var enchant_prefix = enchantment.capitalize()
	enchanted_item["name"] = "%s %s" % [enchant_prefix, item.get("name", "Item")]

	# Add stat bonuses
	if not enchanted_item.has("stat_bonuses"):
		enchanted_item["stat_bonuses"] = {}

	var stat_bonuses = enchanted_item["stat_bonuses"] as Dictionary

	# Add damage bonus for weapons
	if item.has("damage"):
		enchanted_item["damage"] = item.get("damage", 0) + effect.get("damage_bonus", 0)

	# Add elemental damage
	var damage_type_key = "%s_damage" % effect.get("damage_type", "fire")
	stat_bonuses[damage_type_key] = effect.get("damage_bonus", 0)

	# Add special effects
	if not enchanted_item.has("special_effects"):
		enchanted_item["special_effects"] = []

	var special_effects = enchanted_item["special_effects"] as Array
	var status_effect = effect.get("status_effect", "")
	if status_effect != "" and status_effect not in special_effects:
		special_effects.append(status_effect)

	# Add visual effect
	enchanted_item["visual_effect"] = effect.get("visual", "")
	enchanted_item["enchantment"] = enchantment

	# Increase value
	enchanted_item["value"] = int(item.get("value", 0) * 1.5)

	# Emit signal
	enchantment_applied.emit(item.get("id", "unknown"), enchantment)

	print("CraftingSystem: Applied %s enchantment to %s" % [enchantment, item.get("name", "Unknown")])

	return enchanted_item

func customize_armor(item: Dictionary, customization: Dictionary) -> Dictionary:
	"""
	Customize armor with color and stat modifications
	customization = { "color": Color, "stat_mods": { "defense": 5 } }
	Returns the customized armor dictionary
	"""
	if item.is_empty():
		push_error("CraftingSystem: Cannot customize empty item")
		return {}

	# Create customized copy
	var custom_item = item.duplicate(true)

	# Apply color customization
	if customization.has("color"):
		custom_item["custom_color"] = customization["color"]
		print("CraftingSystem: Applied color customization to %s" % item.get("name", "Unknown"))

	# Apply stat modifications
	if customization.has("stat_mods"):
		if not custom_item.has("stat_bonuses"):
			custom_item["stat_bonuses"] = {}

		var stat_bonuses = custom_item["stat_bonuses"] as Dictionary
		var stat_mods = customization["stat_mods"] as Dictionary

		for stat in stat_mods.keys():
			var current_value = stat_bonuses.get(stat, 0)
			if current_value is int:
				stat_bonuses[stat] = current_value + (stat_mods[stat] as int)
			elif current_value is float:
				stat_bonuses[stat] = current_value + (stat_mods[stat] as float)
			else:
				stat_bonuses[stat] = stat_mods[stat]

	# Emit signal
	armor_customized.emit(item.get("id", "unknown"), customization)

	print("CraftingSystem: Customized armor %s" % item.get("name", "Unknown"))

	return custom_item

func discover_recipe(recipe_id: String, discovery_type: DiscoveryType = DiscoveryType.BLUEPRINT) -> bool:
	"""
	Unlock a recipe for the player
	Returns true if recipe was newly discovered, false if already known
	"""
	if not recipe_database.has(recipe_id):
		push_error("CraftingSystem: Recipe '%s' not found in database" % recipe_id)
		return false

	if _is_recipe_known(recipe_id):
		return false

	known_recipes.append(recipe_id)

	# Emit signal
	recipe_discovered.emit(recipe_id)

	var discovery_source = ""
	match discovery_type:
		DiscoveryType.BLUEPRINT:
			discovery_source = "blueprint"
		DiscoveryType.NPC_TAUGHT:
			discovery_source = "NPC teacher"
		DiscoveryType.EXPERIMENTATION:
			discovery_source = "experimentation"

	print("CraftingSystem: Discovered recipe '%s' via %s" % [recipe_id, discovery_source])

	return true

func try_experimental_craft(base_item: String, modifiers: Array) -> bool:
	"""
	Attempt to discover a recipe through experimentation
	Returns true if a new recipe was discovered
	"""
	# Find matching recipe (even if unknown)
	var recipe = _find_recipe(base_item, modifiers)
	if recipe.is_empty():
		crafting_failed.emit("No recipe exists for this combination")
		return false

	var recipe_id = recipe.get("id", "") as String
	if _is_recipe_known(recipe_id):
		return false

	# Check if this recipe can be discovered through experimentation
	var discovery_method = recipe.get("discovery_method", "blueprint") as String
	if discovery_method != "experimentation" and discovery_method != "any":
		crafting_failed.emit("This recipe cannot be discovered through experimentation")
		return false

	# Discover the recipe
	return discover_recipe(recipe_id, DiscoveryType.EXPERIMENTATION)

func get_armor_set_bonus(equipped_armor: Array[String]) -> Dictionary:
	"""
	Calculate set bonuses based on equipped armor pieces
	Returns dictionary with stat bonuses
	"""
	var total_bonuses: Dictionary = {
		"defense": 0,
		"max_hp": 0,
		"speed": 0,
		"attack": 0,
		"evasion": 0.0,
		"critical_chance": 0.0
	}

	# Check each armor set
	for set_name in armor_sets.keys():
		var set_data = armor_sets[set_name]
		var set_pieces = set_data.get("pieces", []) as Array

		# Count how many pieces of this set are equipped
		var equipped_count = 0
		for piece in set_pieces:
			if piece in equipped_armor:
				equipped_count += 1

		# Apply set bonuses based on equipped count
		if equipped_count >= 2 and set_data.has("two_piece_bonus"):
			var two_piece = set_data["two_piece_bonus"] as Dictionary
			_add_bonuses(total_bonuses, two_piece)

		if equipped_count >= 3 and set_data.has("three_piece_bonus"):
			var three_piece = set_data["three_piece_bonus"] as Dictionary
			_add_bonuses(total_bonuses, three_piece)

	return total_bonuses

func get_known_recipes() -> Array[String]:
	"""Get list of recipe IDs the player has discovered"""
	return known_recipes.duplicate()

func get_all_recipes() -> Array:
	"""Get all recipes in the database (for debugging)"""
	var recipes: Array = []
	for recipe_id in recipe_database.keys():
		recipes.append(recipe_database[recipe_id])
	return recipes

func get_recipe(recipe_id: String) -> Dictionary:
	"""Get a specific recipe by ID"""
	return recipe_database.get(recipe_id, {})

func can_craft_recipe(recipe_id: String) -> bool:
	"""Check if player can currently craft a recipe (has materials)"""
	if not _is_recipe_known(recipe_id):
		return false

	if not recipe_database.has(recipe_id):
		return false

	var recipe = recipe_database[recipe_id]
	var base_item = recipe.get("base_item", "")
	var modifiers = recipe.get("modifiers", [])

	return _has_required_materials(base_item, modifiers)

func get_material_info(material_id: String) -> Dictionary:
	"""Get information about a crafting material"""
	return material_database.get(material_id, {})

## Helper Methods

func _find_recipe(base_item: String, modifiers: Array) -> Dictionary:
	"""Find a recipe matching the base item and modifiers"""
	for recipe_id in recipe_database.keys():
		var recipe = recipe_database[recipe_id]

		# Check if base item matches
		if recipe.get("base_item", "") != base_item:
			continue

		# Check if modifiers match (order doesn't matter)
		var recipe_modifiers = recipe.get("modifiers", []) as Array
		if _modifiers_match(modifiers, recipe_modifiers):
			return recipe

	return {}

func _modifiers_match(modifiers_a: Array, modifiers_b: Array) -> bool:
	"""Check if two modifier arrays match (order-independent)"""
	if modifiers_a.size() != modifiers_b.size():
		return false

	# Create sorted copies for comparison
	var sorted_a = modifiers_a.duplicate()
	var sorted_b = modifiers_b.duplicate()
	sorted_a.sort()
	sorted_b.sort()

	for i in range(sorted_a.size()):
		if sorted_a[i] != sorted_b[i]:
			return false

	return true

func _is_recipe_known(recipe_id: String) -> bool:
	"""Check if player has discovered this recipe"""
	return recipe_id in known_recipes

func _has_required_materials(base_item: String, modifiers: Array) -> bool:
	"""Check if player inventory has required materials"""
	# This would integrate with S05 Inventory System
	# For now, return true (placeholder)
	# In real implementation:
	# - Check if player has base_item
	# - Check if player has all items in modifiers array
	# - Use player_inventory.has_item(item_id) for each

	return true

func _consume_materials(base_item: String, modifiers: Array) -> void:
	"""Consume materials from player inventory"""
	# This would integrate with S05 Inventory System
	# For now, just print (placeholder)
	# In real implementation:
	# - player_inventory.remove_item(base_item, 1)
	# - for modifier in modifiers: player_inventory.remove_item(modifier, 1)

	print("CraftingSystem: Consumed materials: %s + %s" % [base_item, str(modifiers)])

func _create_crafted_item(recipe: Dictionary) -> Dictionary:
	"""Create the resulting item from a recipe"""
	var result = recipe.get("result", {}) as Dictionary

	# Create a complete item dictionary
	var crafted_item: Dictionary = {
		"id": result.get("id", "crafted_item"),
		"name": result.get("name", "Crafted Item"),
		"type": result.get("type", "equipment"),
		"stat_bonuses": result.get("stat_bonuses", {}).duplicate(true),
		"visual": result.get("visual", ""),
		"value": result.get("value", 0)
	}

	# Add any special properties
	if result.has("special_effects"):
		crafted_item["special_effects"] = result.get("special_effects", []).duplicate()

	if result.has("resistances"):
		crafted_item["resistances"] = result.get("resistances", {}).duplicate(true)

	return crafted_item

func _add_bonuses(target: Dictionary, bonuses: Dictionary) -> void:
	"""Add stat bonuses from one dictionary to another"""
	for stat in bonuses.keys():
		var bonus_value = bonuses[stat]
		var current_value = target.get(stat, 0)

		if bonus_value is int:
			target[stat] = current_value + bonus_value
		elif bonus_value is float:
			target[stat] = current_value + bonus_value

## Save/Load Integration (S06)

func save_state() -> Dictionary:
	"""
	Serialize crafting state for saving
	Used by SaveManager (S06)
	"""
	return {
		"known_recipes": known_recipes.duplicate()
	}

func load_state(save_data: Dictionary) -> bool:
	"""
	Deserialize crafting state for loading
	Used by SaveManager (S06)
	"""
	if save_data.is_empty():
		return false

	if save_data.has("known_recipes"):
		known_recipes = save_data["known_recipes"].duplicate()

	print("CraftingSystem: Loaded state (%d known recipes)" % known_recipes.size())
	return true

## Debug Methods

func print_known_recipes() -> void:
	"""Debug method to print all known recipes"""
	print("========== KNOWN RECIPES ==========")
	print("Total: %d" % known_recipes.size())

	for recipe_id in known_recipes:
		if recipe_database.has(recipe_id):
			var recipe = recipe_database[recipe_id]
			print("- %s: %s + %s = %s" % [
				recipe_id,
				recipe.get("base_item", "?"),
				str(recipe.get("modifiers", [])),
				recipe.get("result", {}).get("name", "?")
			])

	print("===================================")

func print_enchantments() -> void:
	"""Debug method to print all available enchantments"""
	print("========== ENCHANTMENTS ==========")

	for enchant_name in enchantment_effects.keys():
		var effect = enchantment_effects[enchant_name]
		print("%s: +%d %s damage, %s chance: %.0f%%" % [
			enchant_name.capitalize(),
			effect.get("damage_bonus", 0),
			effect.get("damage_type", "?"),
			effect.get("status_effect", "?"),
			effect.get("status_chance", 0.0) * 100.0
		])

	print("==================================")

func print_armor_sets() -> void:
	"""Debug method to print all armor sets and bonuses"""
	print("========== ARMOR SETS ==========")

	for set_name in armor_sets.keys():
		var set_data = armor_sets[set_name]
		print("\n%s:" % set_name.capitalize().replace("_", " "))
		print("  Pieces: %s" % str(set_data.get("pieces", [])))

		if set_data.has("two_piece_bonus"):
			print("  2-Piece Bonus: %s" % str(set_data["two_piece_bonus"]))

		if set_data.has("three_piece_bonus"):
			print("  3-Piece Bonus: %s" % str(set_data["three_piece_bonus"]))

	print("================================")
