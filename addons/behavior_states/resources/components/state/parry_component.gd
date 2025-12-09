## ParryComponent — Suporte a defesa ativa (parry/block).
class_name ParryComponent extends StateComponent

@export var parry_window: float = 0.2
@export var block_window: float = 0.5
@export var parry_damage_reduction: float = 1.0  # 1.0 = 100% redução
@export var block_damage_reduction: float = 0.5
@export var parry_stamina_cost: float = 0.0
@export var successful_parry_effect: Resource  # Effects

const RUNTIME_KEY := "parry"

func on_enter(ctx: StateContext) -> void:
	if not enabled:
		return
	
	ctx.runtime[RUNTIME_KEY] = {
		"timer": 0.0,
		"parried": false,
		"blocked": false
	}

func on_physics(ctx: StateContext, delta: float) -> void:
	if not enabled:
		return
	
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return
	
	state.timer += delta

## Chamado quando o personagem recebe dano durante este state
func handle_damage(ctx: StateContext, incoming_damage: float) -> float:
	var state: Dictionary = ctx.runtime.get(RUNTIME_KEY, {})
	if state.is_empty():
		return incoming_damage
	
	if state.timer <= parry_window:
		# Perfect parry
		state.parried = true
		ctx.action_executed.emit(&"parry_success", {"damage_blocked": incoming_damage})
		return incoming_damage * (1.0 - parry_damage_reduction)
	elif state.timer <= block_window:
		# Block
		state.blocked = true
		ctx.action_executed.emit(&"block_success", {"damage_blocked": incoming_damage * block_damage_reduction})
		return incoming_damage * (1.0 - block_damage_reduction)
	
	return incoming_damage

static func _get_component_name() -> String:
	return "Parry"

static func _get_component_color() -> Color:
	return Color("#8b5cf6")

static func _get_component_fields() -> Array:
	return [
		{"name": "parry_window", "type": "float", "default": 0.2},
		{"name": "block_window", "type": "float", "default": 0.5},
		{"name": "parry_damage_reduction", "type": "float", "default": 1.0},
		{"name": "block_damage_reduction", "type": "float", "default": 0.5},
		{"name": "parry_stamina_cost", "type": "float", "default": 0.0}
	]
