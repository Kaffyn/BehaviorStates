## DashComponent — Executa dash direcional.
class_name DashComponent extends StateComponent

@export var dash_speed: float = 600.0
@export var dash_direction: Vector2 = Vector2.RIGHT
@export var use_input_direction: bool = true
@export var preserve_y_velocity: bool = false

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	if ctx.body is CharacterBody2D:
		var body := ctx.body as CharacterBody2D
		
		var direction: Vector2
		if use_input_direction and ctx.input_direction != Vector2.ZERO:
			direction = ctx.input_direction.normalized()
		else:
			direction = dash_direction * Vector2(ctx.facing, 1)
		
		var prev_y = body.velocity.y
		body.velocity = direction * dash_speed
		
		if preserve_y_velocity:
			body.velocity.y = prev_y

static func _get_component_name() -> String:
	return "Dash"

static func _get_component_color() -> Color:
	return Color("#22c55e")

static func _get_component_fields() -> Array:
	return [
		{"name": "dash_speed", "type": "float", "default": 600.0},
		{"name": "dash_direction", "type": "Vector2", "default": Vector2.RIGHT},
		{"name": "use_input_direction", "type": "bool", "default": true},
		{"name": "preserve_y_velocity", "type": "bool", "default": false}
	]
