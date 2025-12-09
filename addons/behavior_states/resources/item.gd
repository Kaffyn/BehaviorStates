@tool
class_name Item extends Resource

@export var icon: Texture2D
@export var components: Array[ItemComponent] = []

# ==================== FACADE PROPERTIES (Compatibility) ====================

# Instance State (Not in components, as it changes per instance)
var quantity: int = 1

var id: String:
	get:
		var c = get_component("Identity")
		return c.id if c else ""
var display_name: String:
	get:
		var c = get_component("Identity")
		return c.display_name if c else "Item"
var description: String:
	get:
		var c = get_component("Identity")
		return c.description if c else ""

var stackable: bool:
	get:
		var c = get_component("Stacking")
		return c.stackable if c else false
var max_stack: int:
	get:
		var c = get_component("Stacking")
		return c.max_stack if c else 1

var craft_recipe: Dictionary:
	get:
		var c = get_component("Crafting")
		return c.craft_recipe if c else {}
var craft_output_quantity: int:
	get:
		var c = get_component("Crafting")
		return c.output_quantity if c else 1

var compose: Resource: # Type Compose creates cycle? Use Resource
	get:
		var c = get_component("Equipment")
		return c.compose if c else null

# ==================== COMPONENT ACCESS ====================

## Tries to find a component of the given type. Returns null if not found.
func get_component(type_name: String) -> ItemComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

func get_component_by_class(type: Variant) -> ItemComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null
