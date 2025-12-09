@tool
class_name Item extends Resource

enum ItemType { GENERIC=0, CONSUMABLE, WEAPON, ARMOR, KEY }

@export var name: String = "New Item" 
@export var type: ItemType = ItemType.GENERIC
@export var icon: Texture2D
@export var components: Array[ItemComponent] = []

# ==================== FACADE PROPERTIES (Compatibility) ====================
# These allow scripts to access data transparently, even though it lives in components.

var id: String:
	get:
		var c = get_component("Identity")
		return c.id if c else ""
	set(value):
		var c = get_component("Identity")
		if c: c.id = value

var display_name: String:
	get:
		var c = get_component("Identity")
		return c.display_name if c else "Item"
	set(value):
		var c = get_component("Identity")
		if c: c.display_name = value

var description: String:
	get:
		var c = get_component("Identity")
		return c.description if c else ""
	set(value):
		var c = get_component("Identity")
		if c: c.description = value

var stackable: bool:
	get:
		var c = get_component("Stacking")
		return c.stackable if c else false
	set(value):
		var c = get_component("Stacking")
		if c: c.stackable = value

var max_stack: int:
	get:
		var c = get_component("Stacking")
		return c.max_stack if c else 1
	set(value):
		var c = get_component("Stacking")
		if c: c.max_stack = value

var craft_recipe: Dictionary:
	get:
		var c = get_component("Crafting")
		return c.craft_recipe if c else {}

var craft_output_quantity: int:
	get:
		var c = get_component("Crafting")
		return c.output_quantity if c else 1

var compose: Resource: 
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
