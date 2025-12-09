@tool
class_name BurnComponent extends EffectComponent

@export var damage_per_tick: float = 8.0
@export var tick_interval: float = 0.5
@export var panic_chance: float = 0.1

func get_component_name() -> String:
	return "Burn"
