@tool
class_name PassiveEffectComponent extends SkillComponent

@export var effects: Array[Resource] = [] # Array[Effect]

func get_component_name() -> String:
	return "Passive Effects"

func on_learn(context: SkillContext) -> void:
	# Apply effects permanently or add to list
	pass
