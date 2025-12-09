## PhysicsComponent — Controla gravidade, pulo e resistência do ar.
class_name PhysicsComponent extends StateComponent

@export var gravity_scale: float = 1.0
@export var ignore_gravity: bool = false
@export var jump_force: float = 0.0
@export var air_resistance: float = 0.0

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	# Aplica pulo se configurado
	if jump_force != 0.0 and ctx.body is CharacterBody2D:
		var body := ctx.body as CharacterBody2D
		body.velocity.y = jump_force

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled:
		return
	
	if ctx.body is CharacterBody2D:
		var body := ctx.body as CharacterBody2D
		
		# Aplica gravidade
		if not ignore_gravity and not body.is_on_floor():
			var gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
			body.velocity.y += gravity * gravity_scale * delta
		
		# Aplica resistência do ar
		if air_resistance > 0 and not body.is_on_floor():
			body.velocity.x = move_toward(body.velocity.x, 0, air_resistance * delta)

static func _get_component_name() -> String:
	return "Physics"

static func _get_component_color() -> Color:
	return Color("#06b6d4")

static func _get_component_fields() -> Array:
	return [
		{"name": "gravity_scale", "type": "float", "default": 1.0},
		{"name": "ignore_gravity", "type": "bool", "default": false},
		{"name": "jump_force", "type": "float", "default": 0.0},
		{"name": "air_resistance", "type": "float", "default": 0.0}
	]
