@tool
class_name VisualEffectComponent extends EffectComponent

@export var vfx_scene: PackedScene
@export var color_tint: Color = Color.WHITE
@export var scale_modifier: float = 1.0

func get_component_name() -> String:
	return "Visual"

func on_apply(context: EffectContext) -> void:
	if vfx_scene:
		var vfx = vfx_scene.instantiate()
		if context.target:
			context.target.add_child(vfx)
			# Store reference to remove later
