@tool
class_name ArmorComponent extends ItemComponent

@export_enum("Head", "Chest", "Legs", "Feet", "Hands", "Shield") var slot: String = "Chest"
@export var defense: float = 0.0
@export var magic_resistance: float = 0.0
@export var poise: float = 0.0

func get_component_name() -> String:
	return "Armor"
