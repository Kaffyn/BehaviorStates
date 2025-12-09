## HitboxComponent — Executa detecção de hitbox query-based (sem Area2D persistente).
class_name HitboxComponent extends StateComponent

@export var shape: Shape2D
@export var offset: Vector2 = Vector2.ZERO
@export var delay: float = 0.0
@export var active_time: float = 0.1
@export var damage_multiplier: float = 1.0
@export var knockback: Vector2 = Vector2.ZERO
@export var collision_mask: int = 4

const RUNTIME_KEY := "hitbox"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"timer": 0.0,
		"activated": false,
		"hit_targets": []
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled or not shape:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	state.timer += delta
	
	# Antes do delay ou depois do tempo ativo
	if state.timer < delay or state.timer > delay + active_time:
		return
	
	if not state.activated:
		state.activated = true
	
	# Query de física
	if not ctx.space_state:
		return
	
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, ctx.body.global_position + offset * Vector2(ctx.facing, 1))
	params.collision_mask = collision_mask
	params.exclude = [ctx.body.get_rid()]
	
	var results = ctx.space_state.intersect_shape(params)
	
	for r in results:
		var target = r.collider
		if target in state.hit_targets:
			continue
		state.hit_targets.append(target)
		
		var damage = ctx.base_damage * damage_multiplier
		ctx.hit_connected.emit(target, damage)
		
		if target.has_method("take_damage"):
			target.take_damage(damage, knockback * Vector2(ctx.facing, 1))

static func _get_component_name() -> String:
	return "Hitbox"

static func _get_component_color() -> Color:
	return Color("#ef4444")

static func _get_component_fields() -> Array:
	return [
		{"name": "shape", "type": "Shape2D", "default": null},
		{"name": "offset", "type": "Vector2", "default": Vector2.ZERO},
		{"name": "delay", "type": "float", "default": 0.0},
		{"name": "active_time", "type": "float", "default": 0.1},
		{"name": "damage_multiplier", "type": "float", "default": 1.0},
		{"name": "knockback", "type": "Vector2", "default": Vector2.ZERO},
		{"name": "collision_mask", "type": "int", "default": 4}
	]
