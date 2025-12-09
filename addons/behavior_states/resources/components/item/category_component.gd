@tool
class_name CategoryComponent extends ItemComponent

@export_enum("Weapon", "Armor", "Consumable", "Material", "Key", "Misc") var category: String = "Misc"
@export var sub_category: String = ""

func get_component_name() -> String:
	return "Category"
