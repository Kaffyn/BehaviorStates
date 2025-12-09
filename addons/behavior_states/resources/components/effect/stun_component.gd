@tool
class_name StunComponent extends EffectComponent

@export var prevent_movement: bool = true
@export var prevent_actions: bool = true
@export var animation_name: String = "stunned"

func get_component_name() -> String:
	return "Stun"

func on_apply(context: EffectContext) -> void:
    # Logic to lock state machine or input
    pass
