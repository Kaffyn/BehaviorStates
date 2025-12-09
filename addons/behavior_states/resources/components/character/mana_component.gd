@tool
class_name ManaComponent extends CharacterComponent

@export var max_mana: float = 100.0
@export var current_mana: float = 100.0
@export var regeneration: float = 5.0

func get_component_name() -> String:
	return "Mana"
