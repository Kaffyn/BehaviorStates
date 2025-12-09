## DurationComponent — Define duração e timing do State.
class_name DurationComponent extends StateComponent

@export var duration: float = 0.0  # 0 = infinito
@export var min_time: float = 0.0  # Tempo mínimo antes de poder sair
@export var can_loop: bool = false  # Se verdadeiro, reinicia ao terminar

const RUNTIME_KEY := "duration"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"elapsed": 0.0,
		"finished": false
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled or duration <= 0:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	state.elapsed += delta
	
	if state.elapsed >= duration:
		if can_loop:
			state.elapsed = 0.0
		else:
			state.finished = true
			ctx.action_executed.emit(&"duration_finished", {})

## Verifica se a duração terminou
func is_finished(ctx: StateContext) -> bool:
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	return state.get("finished", false)

## Verifica se o tempo mínimo foi atingido
func can_exit(ctx: StateContext) -> bool:
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	return state.get("elapsed", 0.0) >= min_time

static func _get_component_name() -> String:
	return "Duration"

static func _get_component_color() -> Color:
	return Color("#64748b")

static func _get_component_fields() -> Array:
	return [
		{"name": "duration", "type": "float", "default": 0.0},
		{"name": "min_time", "type": "float", "default": 0.0},
		{"name": "can_loop", "type": "bool", "default": false}
	]
