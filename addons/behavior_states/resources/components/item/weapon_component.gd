@tool
class_name WeaponComponent extends ItemComponent

@export_group("Stats")
@export var min_damage: float = 1.0
@export var max_damage: float = 2.0
@export var attack_speed: float = 1.0
@export var range: float = 50.0

@export_group("Behavior")
@export var moveset: Resource # Type 'Compose' not strictly typed to avoid cycle, or just generic Resource
@export var two_handed: bool = false

func get_component_name() -> String:
	return "Weapon"
