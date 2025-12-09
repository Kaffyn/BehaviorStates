@tool
class_name StaminaComponent extends CharacterComponent

@export var max_stamina: float = 100.0
@export var current_stamina: float = 100.0
@export var regeneration: float = 10.0

func get_component_name() -> String:
	return "Stamina"
