## SpriteComponent — Configura textura e frames do Sprite.
class_name SpriteComponent extends StateComponent

@export var texture: Texture2D
@export var hframes: int = 1
@export var vframes: int = 1
@export var animation_row: int = 0
@export var loop: bool = true
@export var fps: float = 12.0

const RUNTIME_KEY := "sprite"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"frame_timer": 0.0,
		"current_frame": 0
	}
	
	if ctx.sprite and ctx.sprite is Sprite2D and texture:
		var sprite := ctx.sprite as Sprite2D
		sprite.texture = texture
		sprite.hframes = hframes
		sprite.vframes = vframes
		sprite.frame = animation_row * hframes

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled or hframes <= 1:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	if ctx.sprite and ctx.sprite is Sprite2D:
		var sprite := ctx.sprite as Sprite2D
		
		state.frame_timer += delta
		var frame_duration = 1.0 / fps
		
		if state.frame_timer >= frame_duration:
			state.frame_timer = 0.0
			state.current_frame += 1
			
			if state.current_frame >= hframes:
				state.current_frame = 0 if loop else hframes - 1
			
			sprite.frame = animation_row * hframes + state.current_frame

static func _get_component_name() -> String:
	return "Sprite"

static func _get_component_color() -> Color:
	return Color("#a855f7")

static func _get_component_fields() -> Array:
	return [
		{"name": "texture", "type": "Texture2D", "default": null},
		{"name": "hframes", "type": "int", "default": 1},
		{"name": "vframes", "type": "int", "default": 1},
		{"name": "animation_row", "type": "int", "default": 0},
		{"name": "loop", "type": "bool", "default": true},
		{"name": "fps", "type": "float", "default": 12.0}
	]
