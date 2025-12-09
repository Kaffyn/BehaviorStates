@tool
class_name HealthComponent extends CharacterComponent

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var regeneration: float = 0.0

func get_component_name() -> String:
	return "Health"
