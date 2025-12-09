@tool
class_name State extends Resource

@export_group("Identity")
@export var name: String = "New State"
@export var icon: Texture2D
@export var debug_color: Color = Color.RED

@export_group("Requirements")
## Dicionário de Tags e valores mínimos para entrar neste estado.
## Ex: {"motion": 2, "stamina": 10}
@export var entry_requirements: Dictionary = {}

@export_group("Components")
@export var components: Array[StateComponent] = []

# ==================== LEGACY DATA (To be migrated) ====================
@export_group("Legacy Data")
@export var damage: int = 0
@export var cooldown: float = 0.0
@export var duration: float = 0.0
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 0.0
@export var projectile_count: int = 1
@export var spawn_offset: Vector2 = Vector2.ZERO
@export var is_charged: bool = false
@export var min_charge_time: float = 0.0
@export var max_charge_time: float = 0.0
@export var fully_charged_damage_multiplier: float = 1.0
@export var cancel_min_time: float = 0.0
@export var buffer_window_start: float = 0.0
@export var cost_type: int = 0
@export var cost_amount: int = 0

## Tries to find a component of the given type. Returns null if not found.
func get_component(type_name: String) -> StateComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

## Tries to find a component by class.
func get_component_by_class(type: Variant) -> StateComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null
