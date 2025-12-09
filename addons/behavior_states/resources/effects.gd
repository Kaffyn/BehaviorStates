@tool
class_name Effect extends Resource

@export var icon: Texture2D
@export var components: Array[EffectComponent] = []

## Tries to find a component of the given type. Returns null if not found.
func get_component(type_name: String) -> EffectComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

## Tries to find a component by class.
func get_component_by_class(type: Variant) -> EffectComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null
