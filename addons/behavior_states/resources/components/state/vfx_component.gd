## VFXComponent — Spawn de efeitos visuais (partículas).
class_name VFXComponent extends StateComponent

@export var vfx_scene: PackedScene
@export var offset: Vector2 = Vector2.ZERO
@export var auto_destroy: bool = true
@export var destroy_time: float = 2.0

func on_enter(ctx: StateContext) -> void:
	if not enabled or not vfx_scene:
		return
	
	var vfx = vfx_scene.instantiate()
	
	if vfx is Node2D:
		vfx.global_position = ctx.body.global_position + offset * Vector2(ctx.facing, 1)
	
	ctx.body.get_tree().current_scene.add_child(vfx)
	
	if auto_destroy:
		var timer = Timer.new()
		timer.wait_time = destroy_time
		timer.one_shot = true
		timer.autostart = true
		timer.timeout.connect(func(): vfx.queue_free())
		vfx.add_child(timer)

static func _get_component_name() -> String:
	return "VFX"

static func _get_component_color() -> Color:
	return Color("#06b6d4")

static func _get_component_fields() -> Array:
	return [
		{"name": "vfx_scene", "type": "PackedScene", "default": null},
		{"name": "offset", "type": "Vector2", "default": Vector2.ZERO},
		{"name": "auto_destroy", "type": "bool", "default": true},
		{"name": "destroy_time", "type": "float", "default": 2.0}
	]
