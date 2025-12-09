@tool
class_name QualityComponent extends ItemComponent

@export_range(0, 100) var quality: int = 0
@export var quality_name: String = "Normal"

func get_component_name() -> String:
	return "Quality"
