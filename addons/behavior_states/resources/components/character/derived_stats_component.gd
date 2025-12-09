@tool
class_name DerivedStatsComponent extends CharacterComponent

@export var physical_defense: float = 0.0
@export var magic_defense: float = 0.0
@export var poise: float = 0.0
@export var crit_chance: float = 0.05
@export var crit_multiplier: float = 1.5

func get_component_name() -> String:
	return "Derived Stats"
