## EconomyComponent — Valores de compra/venda do Item.
class_name EconomyItemComponent extends ItemComponent

@export var sell_price: int = 0
@export var buy_price: int = 0

static func _get_component_name() -> String:
	return "Economy"

static func _get_component_color() -> Color:
	return Color("#eab308")

static func _get_component_fields() -> Array:
	return [
		{"name": "sell_price", "type": "int", "default": 0},
		{"name": "buy_price", "type": "int", "default": 0}
	]
