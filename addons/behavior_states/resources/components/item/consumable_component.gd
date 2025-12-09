## ConsumableComponent — Comportamento de item consumível.
class_name ConsumableItemComponent extends ItemComponent

@export var consume_on_use: bool = true
@export var use_effects: Array[Resource] = []  # Effects

func on_use(ctx: ItemContext) -> void:
	if not enabled:
		return
	
	# Aplica efeitos
	for effect in use_effects:
		if effect and effect.has_method("apply"):
			effect.apply(ctx.character_sheet)
	
	# Consome o item
	if consume_on_use and ctx.item:
		if "quantity" in ctx.item:
			ctx.item.quantity -= ctx.use_quantity

static func _get_component_name() -> String:
	return "Consumable"

static func _get_component_color() -> Color:
	return Color("#ef4444")

static func _get_component_fields() -> Array:
	return [
		{"name": "consume_on_use", "type": "bool", "default": true},
		{"name": "use_effects", "type": "Array[Effects]", "default": []}
	]
