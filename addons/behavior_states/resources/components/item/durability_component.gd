## DurabilityComponent — Sistema de durabilidade do Item.
class_name DurabilityItemComponent extends ItemComponent

@export var max_durability: int = 100
@export var break_on_zero: bool = true

func on_use(ctx: ItemContext) -> void:
	if not enabled:
		return
	
	# Reduz durabilidade ao usar
	if ctx.item and "durability" in ctx.item:
		ctx.item.durability -= 1
		if ctx.item.durability <= 0 and break_on_zero:
			# Sinaliza que o item quebrou
			pass

static func _get_component_name() -> String:
	return "Durability"

static func _get_component_color() -> Color:
	return Color("#f59e0b")

static func _get_component_fields() -> Array:
	return [
		{"name": "max_durability", "type": "int", "default": 100},
		{"name": "break_on_zero", "type": "bool", "default": true}
	]
