## ComponentBase — Base para todos os Components do sistema.
##
## Components são unidades atômicas de comportamento/dados que podem ser
## compostas em Resources maiores (State, Item, Effect, Skill, CharacterSheet).
## Cada Component tem interface dupla: Runtime (hooks) e Editor (metadados visuais).
@abstract
class_name ComponentBase extends Resource

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (Static — para o painel visual)
# ══════════════════════════════════════════════════════════════

## Nome exibido no editor visual
static func _get_component_name() -> String:
	return "Component"

## Cor do node no GraphEdit
static func _get_component_color() -> Color:
	return Color.WHITE

## Ícone para a biblioteca (opcional)
static func _get_component_icon() -> Texture2D:
	return null

## Campos editáveis (para gerar UI dinamicamente)
## Retorna: [{ "name": "x", "type": "float", "default": 0.0 }, ...]
static func _get_component_fields() -> Array:
	return []

## Categoria do component para agrupamento no editor
static func _get_component_category() -> String:
	return "General"

# ══════════════════════════════════════════════════════════════
# COMMON PROPERTIES
# ══════════════════════════════════════════════════════════════

## Se o component está habilitado
@export var enabled: bool = true
