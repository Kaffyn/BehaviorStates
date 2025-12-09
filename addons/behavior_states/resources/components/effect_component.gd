## EffectComponent — Base para Components que definem efeitos (buffs/debuffs).
##
## Effects são compostos por múltiplos EffectComponents que definem
## modificadores de stats, damage over time, status effects, etc.
class_name EffectComponent extends ComponentBase

# ══════════════════════════════════════════════════════════════
# RUNTIME INTERFACE (Virtual — sobrescreva nas subclasses)
# ══════════════════════════════════════════════════════════════

## Chamado quando o efeito é aplicado
func on_apply(ctx: EffectContext) -> void:
	pass

## Chamado a cada tick do efeito (para DoT, HoT, etc.)
func on_tick(ctx: EffectContext, delta: float) -> void:
	pass

## Chamado quando o efeito é removido
func on_remove(ctx: EffectContext) -> void:
	pass

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (Override)
# ══════════════════════════════════════════════════════════════

static func _get_component_category() -> String:
	return "Effect"
