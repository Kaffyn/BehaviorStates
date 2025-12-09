## ComboComponent — Gerencia janela de combo e chain de ataques.
class_name ComboComponent extends StateComponent

@export var next_state: Resource  # State
@export var window_start: float = 0.0
@export var window_duration: float = 0.3
@export var chain_bonus_damage: float = 0.0

const RUNTIME_KEY := "combo"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"timer": 0.0,
		"window_open": false
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled or not next_state:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	state.timer += delta
	
	if state.timer >= window_start and state.timer <= window_start + window_duration:
		if not state.window_open:
			state.window_open = true
		ctx.combo_available.emit(next_state)
	elif state.window_open:
		state.window_open = false

static func _get_component_name() -> String:
	return "Combo"

static func _get_component_color() -> Color:
	return Color("#eab308")

static func _get_component_fields() -> Array:
	return [
		{"name": "next_state", "type": "State", "default": null},
		{"name": "window_start", "type": "float", "default": 0.0},
		{"name": "window_duration", "type": "float", "default": 0.3},
		{"name": "chain_bonus_damage", "type": "float", "default": 0.0}
	]
