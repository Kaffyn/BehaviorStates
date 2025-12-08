@tool
## GraphEdit customizado que aceita drag & drop de blocos.
extends GraphEdit

signal block_dropped(block_name: String, position: Vector2)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.get("type") == "block":
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.get("type") == "block":
		var block_name = data.get("block_name")
		var drop_pos = at_position + scroll_offset
		block_dropped.emit(block_name, drop_pos)
