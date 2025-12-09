## HealOverTimeComponent — Cura periódica (HoT) para Effects.
class_name HealOverTimeEffectComponent extends EffectComponent

@export var heal_per_tick: int = 5
@export var tick_interval: float = 1.0

func on_tick(ctx: EffectContext, delta: float) -> void:
	if not enabled or not ctx.target:
		return
	
	ctx.tick_timer += delta
	if ctx.tick_timer >= tick_interval:
		ctx.tick_timer = 0.0
		
		if "current_health" in ctx.target and "max_health" in ctx.target:
			ctx.target.current_health = min(ctx.target.max_health, ctx.target.current_health + heal_per_tick)

static func _get_component_name() -> String:
	return "Heal Over Time"

static func _get_component_color() -> Color:
	return Color("#22c55e")

static func _get_component_fields() -> Array:
	return [
		{"name": "heal_per_tick", "type": "int", "default": 5},
		{"name": "tick_interval", "type": "float", "default": 1.0}
	]
