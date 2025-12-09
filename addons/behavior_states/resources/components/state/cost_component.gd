## CostComponent — Define custo de recurso para executar o state.
class_name CostComponent extends StateComponent

enum CostType { NONE, STAMINA, MANA, HEALTH }
enum InsufficientBehavior { BLOCK, IGNORE, WEAKEN }

@export var cost_type: CostType = CostType.NONE
@export var cost_amount: float = 0.0
@export var on_insufficient: InsufficientBehavior = InsufficientBehavior.BLOCK

var _cost_paid: bool = false

func on_enter(ctx: StateContext) -> void:
	if not enabled or cost_type == CostType.NONE or cost_amount <= 0:
		_cost_paid = true
		return
	
	# Verifica e consome recurso (via Behavior)
	# Nota: A verificação real deve ser feita na Machine antes de entrar
	_cost_paid = true
	ctx.action_executed.emit(&"cost_paid", {
		"type": cost_type,
		"amount": cost_amount
	})

static func _get_component_name() -> String:
	return "Cost"

static func _get_component_color() -> Color:
	return Color("#f59e0b")

static func _get_component_fields() -> Array:
	return [
		{"name": "cost_type", "type": "enum", "options": ["None", "Stamina", "Mana", "Health"], "default": 0},
		{"name": "cost_amount", "type": "float", "default": 0.0},
		{"name": "on_insufficient", "type": "enum", "options": ["Block", "Ignore", "Weaken"], "default": 0}
	]
