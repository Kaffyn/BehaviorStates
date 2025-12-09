## ChargedComponent — Suporta ataques carregados.
class_name ChargedComponent extends StateComponent

@export var min_charge_time: float = 0.3
@export var max_charge_time: float = 2.0
@export var damage_multiplier_min: float = 1.0
@export var damage_multiplier_max: float = 3.0
@export var release_action: String = "attack"

const RUNTIME_KEY := "charged"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"charge_time": 0.0,
		"charging": true,
		"released": false
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	if state.charging:
		state.charge_time = min(state.charge_time + delta, max_charge_time)
		
		# Verifica se a ação foi liberada
		if not ctx.input_actions.get(release_action, true):
			state.charging = false
			state.released = true
			
			var charge_ratio = clamp(
				(state.charge_time - min_charge_time) / (max_charge_time - min_charge_time),
				0.0, 1.0
			)
			var damage_mult = lerp(damage_multiplier_min, damage_multiplier_max, charge_ratio)
			
			ctx.action_executed.emit(&"charge_released", {
				"charge_time": state.charge_time,
				"damage_multiplier": damage_mult,
				"full_charge": state.charge_time >= max_charge_time
			})

static func _get_component_name() -> String:
	return "Charged"

static func _get_component_color() -> Color:
	return Color("#8b5cf6")

static func _get_component_fields() -> Array:
	return [
		{"name": "min_charge_time", "type": "float", "default": 0.3},
		{"name": "max_charge_time", "type": "float", "default": 2.0},
		{"name": "damage_multiplier_min", "type": "float", "default": 1.0},
		{"name": "damage_multiplier_max", "type": "float", "default": 3.0},
		{"name": "release_action", "type": "String", "default": "attack"}
	]
