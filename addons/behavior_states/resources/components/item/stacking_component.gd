## StackingComponent — Comportamento de empilhamento do Item.
class_name StackingItemComponent extends ItemComponent

@export var stackable: bool = false
@export var max_stack: int = 99

static func _get_component_name() -> String:
	return "Stacking"

static func _get_component_color() -> Color:
	return Color("#22c55e")

static func _get_component_fields() -> Array:
	return [
		{"name": "stackable", "type": "bool", "default": false},
		{"name": "max_stack", "type": "int", "default": 99}
	]
