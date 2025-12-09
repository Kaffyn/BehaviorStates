@tool
class_name DurationEffectComponent extends EffectComponent

@export var duration: float = 5.0
@export var is_infinite: bool = false
@export var remove_on_death: bool = true

func get_component_name() -> String:
	return "Duration"
