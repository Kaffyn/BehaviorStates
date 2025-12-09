@tool
class_name ClimbComponent extends StateComponent

@export_group("Climb Settings")
@export var climb_speed: float = 200.0
@export var can_climb_walls: bool = true
@export var can_climb_ceilings: bool = false
@export var stamina_cost_per_second: float = 10.0

func get_component_name() -> String:
	return "Climb"

func on_enter(context: StateContext) -> void:
	# Initialize climb state (e.g. disable gravity)
	context.blackboard.set_value("is_climbing", true)

func on_physics(context: StateContext) -> void:
	var input_dir = context.input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity = input_dir * climb_speed
	
	if context.actor is CharacterBody2D:
		context.actor.velocity = velocity
		context.actor.move_and_slide()
		
	# Deduct stamina logic would go here via CharacterComponent query

func on_exit(context: StateContext) -> void:
	context.blackboard.set_value("is_climbing", false)
