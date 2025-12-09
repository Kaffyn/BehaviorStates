@tool
class_name PrerequisiteComponent extends SkillComponent

@export var required_skills: Array[Resource] = [] # Array[Skill]

func get_component_name() -> String:
	return "Prerequisites"

func check_prerequisites(context: SkillContext) -> bool:
    # Logic to check if user has skills
    return true
