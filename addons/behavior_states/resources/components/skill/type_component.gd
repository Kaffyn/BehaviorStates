@tool
class_name SkillTypeComponent extends SkillComponent

enum SkillType { ACTIVE, PASSIVE, BUFF, ULTIMATE }

@export var skill_type: SkillType = SkillType.PASSIVE
@export var category: String = "General"

func get_component_name() -> String:
	return "Type"
