@tool
class_name PoisonComponent extends EffectComponent

@export var damage_per_tick: float = 5.0
@export var tick_interval: float = 1.0
@export var reduce_healing: float = 0.5 # -50% healing

func get_component_name() -> String:
	return "Poison"
