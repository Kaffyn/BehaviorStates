## MovementComponent — Controla velocidade e aceleração do personagem.
class_name MovementComponent extends StateComponent

@export var speed_multiplier: float = 1.0
@export var acceleration: float = 0.0
@export var friction: float = 0.0
@export var lock_input: bool = false

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled or lock_input:
		return
	
	var input = ctx.input_direction
	var speed = ctx.base_speed * speed_multiplier
	
	if ctx.body is CharacterBody2D:
		var body := ctx.body as CharacterBody2D
		if acceleration > 0:
			body.velocity.x = move_toward(body.velocity.x, input.x * speed, acceleration * delta)
		else:
			body.velocity.x = input.x * speed
		
		if friction > 0 and is_zero_approx(input.x):
			body.velocity.x = move_toward(body.velocity.x, 0, friction * delta)

static func _get_component_name() -> String:
	return "Movement"

static func _get_component_color() -> Color:
	return Color("#22c55e")

static func _get_component_fields() -> Array:
	return [
		{"name": "speed_multiplier", "type": "float", "default": 1.0},
		{"name": "acceleration", "type": "float", "default": 0.0},
		{"name": "friction", "type": "float", "default": 0.0},
		{"name": "lock_input", "type": "bool", "default": false}
	]
