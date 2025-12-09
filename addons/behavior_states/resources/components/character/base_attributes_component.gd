@tool
class_name BaseAttributesComponent extends CharacterComponent

@export var strength: int = 10
@export var dexterity: int = 10
@export var intelligence: int = 10
@export var vitality: int = 10

func get_component_name() -> String:
	return "Base Attributes"
