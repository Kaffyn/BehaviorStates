@tool
class_name StandardMoveComponent extends StateComponent

@export_group("Movement Settings")
@export var use_run_speed: bool = false
@export var multiplier: float = 1.0
@export var friction: float = 1000.0
@export var apply_gravity: bool = true

func get_component_name() -> String:
	return "Standard Move"

func on_physics(context: StateContext) -> void:
	var body = context.actor as CharacterBody2D
	if not body:
		return
		
	# Gravity
	if apply_gravity and not body.is_on_floor():
		body.velocity.y += 980.0 * context.delta # TODO: Get gravity from project settings
	
	# Input
	var input_dir = Input.get_axis("ui_left", "ui_right") # TODO: generic input
	
	# Speed
	var speed_stat = "run_speed" if use_run_speed else "walk_speed"
	var base_speed = context.get_stat(speed_stat)
	var target_speed = base_speed * multiplier * input_dir
	
	# Acceleration/Friction
	var accel = context.get_stat("acceleration")
	if accel <= 0: accel = 1000.0
	
	if input_dir != 0:
		body.velocity.x = move_toward(body.velocity.x, target_speed, accel * context.delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, friction * context.delta)
	
	body.move_and_slide()
