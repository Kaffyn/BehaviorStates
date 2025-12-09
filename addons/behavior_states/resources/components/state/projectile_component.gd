## ProjectileComponent — Spawn de projéteis.
class_name ProjectileComponent extends StateComponent

@export var projectile_scene: PackedScene
@export var spawn_offset: Vector2 = Vector2.ZERO
@export var projectile_speed: float = 500.0
@export var projectile_count: int = 1
@export var spread_angle: float = 0.0
@export var damage_multiplier: float = 1.0
@export var spawn_delay: float = 0.0

const RUNTIME_KEY := "projectile"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"timer": 0.0,
		"spawned": false
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled or not projectile_scene:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty() or state.spawned:
		return
	
	state.timer += delta
	
	if state.timer >= spawn_delay:
		state.spawned = true
		_spawn_projectiles(ctx)

func _spawn_projectiles(ctx: StateContext) -> void:
	var base_pos = ctx.body.global_position + spawn_offset * Vector2(ctx.facing, 1)
	var base_dir = Vector2(ctx.facing, 0)
	
	for i in range(projectile_count):
		var projectile = projectile_scene.instantiate()
		
		# Calcula direção com spread
		var angle_offset = 0.0
		if projectile_count > 1:
			angle_offset = lerp(-spread_angle / 2, spread_angle / 2, float(i) / (projectile_count - 1))
		
		var direction = base_dir.rotated(deg_to_rad(angle_offset))
		
		if projectile is Node2D:
			projectile.global_position = base_pos
		
		# Configura propriedades do projétil
		if "direction" in projectile:
			projectile.direction = direction
		if "speed" in projectile:
			projectile.speed = projectile_speed
		if "damage" in projectile:
			projectile.damage = ctx.base_damage * damage_multiplier
		
		ctx.body.get_tree().current_scene.add_child(projectile)

static func _get_component_name() -> String:
	return "Projectile"

static func _get_component_color() -> Color:
	return Color("#f97316")

static func _get_component_fields() -> Array:
	return [
		{"name": "projectile_scene", "type": "PackedScene", "default": null},
		{"name": "spawn_offset", "type": "Vector2", "default": Vector2.ZERO},
		{"name": "projectile_speed", "type": "float", "default": 500.0},
		{"name": "projectile_count", "type": "int", "default": 1},
		{"name": "spread_angle", "type": "float", "default": 0.0},
		{"name": "damage_multiplier", "type": "float", "default": 1.0},
		{"name": "spawn_delay", "type": "float", "default": 0.0}
	]
