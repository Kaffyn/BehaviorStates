## BufferComponent — Suporte a input buffering.
class_name BufferComponent extends StateComponent

@export var buffer_window_start: float = 0.3
@export var buffered_actions: Array[String] = ["attack", "jump"]

const RUNTIME_KEY := "buffer"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"timer": 0.0,
		"buffered_action": ""
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	state.timer += delta
	
	if state.timer >= buffer_window_start:
		# Verifica inputs e armazena no buffer
		for action in buffered_actions:
			if ctx.input_actions.get(action, false):
				state.buffered_action = action
				ctx.action_executed.emit(&"input_buffered", {"action": action})
				break

static func _get_component_name() -> String:
	return "Buffer"

static func _get_component_color() -> Color:
	return Color("#eab308")

static func _get_component_fields() -> Array:
	return [
		{"name": "buffer_window_start", "type": "float", "default": 0.3},
		{"name": "buffered_actions", "type": "Array[String]", "default": ["attack", "jump"]}
	]
