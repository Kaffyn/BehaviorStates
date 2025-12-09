## FilterComponent — Define requisitos de contexto para ativação do State.
class_name FilterComponent extends StateComponent

@export var entry_requirements: Dictionary = {}  # { "motion": 0, "attack": 1 }
@export var priority_override: int = 0
@export var required_skill: String = ""

## Não tem lógica de runtime — apenas dados para seleção
func on_enter(ctx: StateContext) -> void:
	pass

## Verifica se o state deve ser candidato baseado no contexto
func matches_context(context: Dictionary) -> bool:
	if not enabled:
		return true  # Disabled filter = always matches
	
	for category in entry_requirements:
		if category in context:
			if entry_requirements[category] != context[category]:
				return false
	
	return true

static func _get_component_name() -> String:
	return "Filter"

static func _get_component_color() -> Color:
	return Color("#3b82f6")

static func _get_component_fields() -> Array:
	return [
		{"name": "entry_requirements", "type": "Dictionary", "default": {}},
		{"name": "priority_override", "type": "int", "default": 0},
		{"name": "required_skill", "type": "String", "default": ""}
	]
