## AudioComponent — Toca som ao entrar no state.
class_name AudioComponent extends StateComponent

@export var sound: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var pitch_randomness: float = 0.0

func on_enter(ctx: StateContext) -> void:
	if not enabled or not sound:
		return
	
	# Cria AudioStreamPlayer temporário
	var player: Node
	if ctx.body is Node2D:
		player = AudioStreamPlayer2D.new()
	else:
		player = AudioStreamPlayer.new()
	
	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale + randf_range(-pitch_randomness, pitch_randomness)
	player.autoplay = true
	player.finished.connect(func(): player.queue_free())
	
	ctx.body.add_child(player)

static func _get_component_name() -> String:
	return "Audio"

static func _get_component_color() -> Color:
	return Color("#06b6d4")

static func _get_component_fields() -> Array:
	return [
		{"name": "sound", "type": "AudioStream", "default": null},
		{"name": "volume_db", "type": "float", "default": 0.0},
		{"name": "pitch_scale", "type": "float", "default": 1.0},
		{"name": "pitch_randomness", "type": "float", "default": 0.0}
	]
