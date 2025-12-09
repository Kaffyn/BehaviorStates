@tool
class_name SkillLevelComponent extends SkillComponent

@export var max_level: int = 1
@export var current_level: int = 0
@export var scaling_factor: float = 1.0

func get_component_name() -> String:
	return "Level"
