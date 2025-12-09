@tool
class_name CharacterSheet extends Resource

@export var components: Array[CharacterComponent] = []

## Tries to find a component of the given type. Returns null if not found.
func get_component(type_name: String) -> CharacterComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

## Tries to find a component by class.
func get_component_by_class(type: Variant) -> CharacterComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null

func get_stat(stat_name: String) -> Variant:
	match stat_name:
		"health", "current_health":
			var c = get_component("Health")
			return c.current_health if c else 0.0
		"max_health":
			var c = get_component("Health")
			return c.max_health if c else 0.0
		"stamina", "current_stamina":
			var c = get_component("Stamina")
			return c.current_stamina if c else 0.0
		"max_stamina":
			var c = get_component("Stamina")
			return c.max_stamina if c else 0.0
		"mana", "current_mana":
			var c = get_component("Mana")
			return c.current_mana if c else 0.0
		"max_mana":
			var c = get_component("Mana")
			return c.max_mana if c else 0.0
		"level":
			var c = get_component("Experience")
			return c.level if c else 1
		"xp", "experience":
			var c = get_component("Experience")
			return c.current_xp if c else 0
		"walk_speed":
			var c = get_component("Movement Stats")
			return c.walk_speed if c else 0.0
		"run_speed":
			var c = get_component("Movement Stats")
			return c.run_speed if c else 0.0
		"jump_force":
			var c = get_component("Movement Stats")
			return c.jump_force if c else 0.0
			
		# Attributes
		"strength", "str":
			var c = get_component("Base Attributes")
			return c.strength if c else 0
		"dexterity", "dex":
			var c = get_component("Base Attributes")
			return c.dexterity if c else 0
		"intelligence", "int":
			var c = get_component("Base Attributes")
			return c.intelligence if c else 0
		"vitality", "vit":
			var c = get_component("Base Attributes")
			return c.vitality if c else 0
			
	return 0.0

func set_stat(stat_name: String, value: Variant) -> void:
	match stat_name:
		"health", "current_health":
			var c = get_component("Health")
			if c: c.current_health = value
		"stamina", "current_stamina":
			var c = get_component("Stamina")
			if c: c.current_stamina = value
		"mana", "current_mana":
			var c = get_component("Mana")
			if c: c.current_mana = value
		"experience":
			var c = get_component("Experience")
			if c: c.current_xp = value
