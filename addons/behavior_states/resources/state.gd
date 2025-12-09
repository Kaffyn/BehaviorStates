@tool
class_name State extends Resource

@export var name: String = "New State"
@export var icon: Texture2D
@export var debug_color: Color = Color.RED

## Dicionário de Tags e valores mínimos para entrar neste estado.
## Ex: {"motion": 2, "stamina": 10}
@export var entry_requirements: Dictionary = {}

@export var components: Array[StateComponent] = []

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
