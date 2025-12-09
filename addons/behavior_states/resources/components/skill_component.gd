## SkillComponent — Base para Components que definem comportamento de Skills.
##
## Skills são compostas por múltiplos SkillComponents que definem
## requisitos, desbloqueios, efeitos passivos, custos, etc.
class_name SkillComponent extends ComponentBase

# ══════════════════════════════════════════════════════════════
# RUNTIME INTERFACE (Virtual — sobrescreva nas subclasses)
# ══════════════════════════════════════════════════════════════

## Chamado quando a skill é aprendida
func on_learn(ctx: SkillContext) -> void:
	pass

## Chamado quando uma skill ativa é usada
func on_activate(ctx: SkillContext) -> void:
	pass

## Chamado quando a skill sobe de nível
func on_level_up(ctx: SkillContext) -> void:
	pass

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (Override)
# ══════════════════════════════════════════════════════════════

static func _get_component_category() -> String:
	return "Skill"
