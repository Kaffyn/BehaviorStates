@tool
class_name ExperienceComponent extends CharacterComponent

@export var level: int = 1
@export var current_xp: int = 0
@export var xp_to_next_level: int = 100
@export var unspent_attribute_points: int = 0
@export var unspent_skill_points: int = 0

func get_component_name() -> String:
	return "Experience"
