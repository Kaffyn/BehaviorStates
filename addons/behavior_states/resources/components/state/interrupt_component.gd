## InterruptComponent — Define política de interrupção do state.
class_name InterruptComponent extends StateComponent

enum InterruptPolicy { CANCEL, ADAPT, IGNORE, FINISH }

@export var on_physics_change: InterruptPolicy = InterruptPolicy.ADAPT
@export var on_weapon_change: InterruptPolicy = InterruptPolicy.ADAPT
@export var on_motion_change: InterruptPolicy = InterruptPolicy.ADAPT
@export var on_attack_change: InterruptPolicy = InterruptPolicy.ADAPT
@export var on_take_damage: InterruptPolicy = InterruptPolicy.CANCEL
@export var min_duration: float = 0.0  # Tempo mínimo antes de poder ser interrompido

const RUNTIME_KEY := "interrupt"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"timer": 0.0
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if not state.is_empty():
		state.timer += delta

## Verifica se pode ser interrompido por uma mudança de contexto
func can_interrupt(ctx: StateContext, category: String) -> bool:
	if not enabled:
		return true
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.timer < min_duration:
		return false
	
	var policy: InterruptPolicy
	match category:
		"physics": policy = on_physics_change
		"weapon": policy = on_weapon_change
		"motion": policy = on_motion_change
		"attack": policy = on_attack_change
		"damage": policy = on_take_damage
		_: policy = InterruptPolicy.ADAPT
	
	return policy != InterruptPolicy.IGNORE and policy != InterruptPolicy.FINISH

static func _get_component_name() -> String:
	return "Interrupt"

static func _get_component_color() -> Color:
	return Color("#ec4899")

static func _get_component_fields() -> Array:
	return [
		{"name": "on_physics_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
		{"name": "on_weapon_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
		{"name": "on_motion_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
		{"name": "on_attack_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
		{"name": "on_take_damage", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 0},
		{"name": "min_duration", "type": "float", "default": 0.0}
	]
