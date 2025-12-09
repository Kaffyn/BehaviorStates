@tool
class_name CombatStatsComponent extends CharacterComponent

@export var attack_power: float = 10.0
@export var attack_speed: float = 1.0
@export var cooldown_reduction: float = 0.0

func get_component_name() -> String:
	return "Combat Stats"
