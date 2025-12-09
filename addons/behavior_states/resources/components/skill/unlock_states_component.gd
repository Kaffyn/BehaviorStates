@tool
class_name UnlockStatesComponent extends SkillComponent

@export var states_to_unlock: Array[Resource] = [] # Array[State]
@export var compose_to_inject: Resource # Compose

func get_component_name() -> String:
	return "Unlock States"
