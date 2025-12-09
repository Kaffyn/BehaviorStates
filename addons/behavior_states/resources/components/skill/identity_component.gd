@tool
class_name SkillIdentityComponent extends SkillComponent

@export var skill_name: String = "New Skill"
@export_multiline var description: String = ""
@export var icon: Texture2D

func get_component_name() -> String:
	return "Identity"
