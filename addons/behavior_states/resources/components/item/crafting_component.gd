## CraftingComponent — Receita de crafting do Item.
class_name CraftingItemComponent extends ItemComponent

@export var craft_recipe: Dictionary = {}  # { "item_id": quantidade }
@export var craft_time: float = 0.0
@export var required_station: String = ""
@export var output_quantity: int = 1

static func _get_component_name() -> String:
	return "Crafting"

static func _get_component_color() -> Color:
	return Color("#06b6d4")

static func _get_component_fields() -> Array:
	return [
		{"name": "craft_recipe", "type": "Dictionary", "default": {}},
		{"name": "craft_time", "type": "float", "default": 0.0},
		{"name": "required_station", "type": "String", "default": ""},
		{"name": "output_quantity", "type": "int", "default": 1}
	]
