@tool
class_name MovementStatsComponent extends CharacterComponent

@export var walk_speed: float = 200.0
@export var run_speed: float = 400.0
@export var jump_force: float = -400.0
@export var acceleration: float = 1200.0
@export var friction: float = 1200.0

func get_component_name() -> String:
	return "Movement Stats"
