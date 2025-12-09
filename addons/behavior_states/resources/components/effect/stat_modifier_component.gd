## StatModifierComponent — Modificadores de atributos para Effects.
class_name StatModifierEffectComponent extends EffectComponent

@export var stat_modifiers: Dictionary = {}  # { "max_health": 50, "speed": 1.2 }

func on_apply(ctx: EffectContext) -> void:
	if not enabled or not ctx.target:
		return
	
	for stat in stat_modifiers:
		if stat in ctx.target:
			var modifier = stat_modifiers[stat]
			var current = ctx.target.get(stat)
			if modifier is float and modifier != 0.0:
				# Multiplicativo
				ctx.target.set(stat, current * modifier)
			elif modifier is int:
				# Aditivo
				ctx.target.set(stat, current + modifier)

func on_remove(ctx: EffectContext) -> void:
	if not enabled or not ctx.target:
		return
	
	for stat in stat_modifiers:
		if stat in ctx.target:
			var modifier = stat_modifiers[stat]
			var current = ctx.target.get(stat)
			if modifier is float and modifier != 0.0:
				ctx.target.set(stat, current / modifier)
			elif modifier is int:
				ctx.target.set(stat, current - modifier)

static func _get_component_name() -> String:
	return "Stat Modifier"

static func _get_component_color() -> Color:
	return Color("#3b82f6")

static func _get_component_fields() -> Array:
	return [
		{"name": "stat_modifiers", "type": "Dictionary", "default": {}}
	]
