@tool
class_name PlaceableItemComponent extends ItemComponent

@export var scene_to_place: PackedScene
@export var grid_snapping: bool = true
@export var grid_size: Vector2 = Vector2(16, 16)
@export var can_rotate: bool = false

func get_component_name() -> String:
	return "Placeable"

func on_use(context: ItemContext) -> void:
	# Logic to initiate placement mode
	pass
