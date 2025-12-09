## AnimationComponent — Integração com AnimationTree/AnimationPlayer.
class_name AnimationComponent extends StateComponent

@export var animation_name: StringName = &""
@export var blend_time: float = 0.1
@export var speed_scale: float = 1.0
@export var use_animation_tree: bool = true

func on_enter(ctx: StateContext) -> void:
	if not enabled or animation_name.is_empty():
		return
	
	if use_animation_tree and ctx.animation_tree:
		# Usa AnimationTree (StateMachine)
		ctx.animation_tree.set("parameters/state/transition_request", animation_name)
	elif ctx.animation_player:
		# Usa AnimationPlayer direto
		if ctx.animation_player.has_animation(animation_name):
			ctx.animation_player.play(animation_name, blend_time, speed_scale)

static func _get_component_name() -> String:
	return "Animation"

static func _get_component_color() -> Color:
	return Color("#a855f7")

static func _get_component_fields() -> Array:
	return [
		{"name": "animation_name", "type": "StringName", "default": &""},
		{"name": "blend_time", "type": "float", "default": 0.1},
		{"name": "speed_scale", "type": "float", "default": 1.0},
		{"name": "use_animation_tree", "type": "bool", "default": true}
	]
