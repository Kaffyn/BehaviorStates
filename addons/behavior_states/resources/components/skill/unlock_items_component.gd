@tool
class_name UnlockItemsComponent extends SkillComponent

@export var items_to_grant: Array[Resource] = [] # Array[Item]
@export var recipes_to_unlock: Array[Resource] # Array[Recipe]

func get_component_name() -> String:
	return "Unlock Items"
