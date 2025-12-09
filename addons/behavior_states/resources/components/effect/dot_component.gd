## DamageOverTimeComponent — Dano periódico (DoT) para Effects.
class_name DamageOverTimeEffectComponent extends EffectComponent

enum DamageType { PHYSICAL, FIRE, POISON, BLEED, MAGIC }

@export var damage_type: DamageType = DamageType.PHYSICAL
@export var damage_per_tick: int = 5
@export var tick_interval: float = 1.0

func on_tick(ctx: EffectContext, delta: float) -> void:
	if not enabled or not ctx.target:
		return
	
	ctx.tick_timer += delta
	if ctx.tick_timer >= tick_interval:
		ctx.tick_timer = 0.0
		
		if "current_health" in ctx.target:
			ctx.target.current_health = max(0, ctx.target.current_health - damage_per_tick)

static func _get_component_name() -> String:
	return "Damage Over Time"

static func _get_component_color() -> Color:
	return Color("#ef4444")

static func _get_component_fields() -> Array:
	return [
		{"name": "damage_type", "type": "enum", "options": ["Physical", "Fire", "Poison", "Bleed", "Magic"], "default": 0},
		{"name": "damage_per_tick", "type": "int", "default": 5},
		{"name": "tick_interval", "type": "float", "default": 1.0}
	]
