@tool
class_name LevelRequirementComponent extends SkillComponent

@export var min_character_level: int = 1
@export var min_attribute_requirements: Dictionary = {} # e.g. {"Strength": 10}

func get_component_name() -> String:
	return "Level Req"

func check_requirements(context: SkillContext) -> bool:
	# Logic to check level
	return true
