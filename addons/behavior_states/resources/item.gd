@tool
class_name Item extends Resource

@export_group("Identity")
@export var name: String = "New Item" # Was 'id' or 'name' in legacy? Checking implementation...
@export var icon: Texture2D

@export_group("Components")
@export var components: Array[ItemComponent] = []

# ==================== LEGACY DATA (DO NOT USE FOR NEW LOGIC) ====================
# Kept for migration purposes.
@export_group("Legacy Data")
@export var id: String = ""
@export var description: String = ""
@export var stackable: bool = false
@export var max_stack: int = 1
@export var craft_recipe: Dictionary = {}
@export var output_quantity: int = 1
@export var quantity: int = 1 # Instance data, but might be in resource for templates
@export var compose: Resource # Was used for Equipment

# ==================== COMPONENT ACCESS ====================

## Tries to find a component of the given type. Returns null if not found.
func get_component(type_name: String) -> ItemComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

func get_component_by_class(type: Variant) -> ItemComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null
