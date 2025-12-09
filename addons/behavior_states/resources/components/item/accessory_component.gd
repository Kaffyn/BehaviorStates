@tool
class_name AccessoryComponent extends ItemComponent

@export_enum("Ring", "Necklace", "Charm") var slot: String = "Ring"
@export var effects: Array[Resource] = [] # Array[Effect]

func get_component_name() -> String:
	return "Accessory"
