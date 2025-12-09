## StateComponent — Base para Components que definem comportamento de States.
##
## States são compostos por múltiplos StateComponents que executam lógica
## atômica (movimento, hitbox, animação, som, etc.).
## Cada Component recebe um StateContext com todas as dependências injetadas.
@abstract
class_name StateComponent extends ComponentBase

# ══════════════════════════════════════════════════════════════
# RUNTIME INTERFACE (Virtual — sobrescreva nas subclasses)
# ══════════════════════════════════════════════════════════════

## Chamado quando o State é ativado
func on_enter(ctx: StateContext) -> void:
	pass

## Chamado a cada physics frame enquanto o State está ativo
func on_physics(ctx: StateContext, delta: float) -> void:
	pass

## Chamado quando o State é desativado
func on_exit(ctx: StateContext) -> void:
	pass

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (Override)
# ══════════════════════════════════════════════════════════════

static func _get_component_category() -> String:
	return "State"
