@tool
class_name SpeedModifierComponent extends EffectComponent

enum ModifierType { FLAT, PERCENT_ADD, PERCENT_MULT }

@export var modifier_type: ModifierType = ModifierType.PERCENT_MULT
@export var value: float = 1.2 # +20% speed

func get_component_name() -> String:
	return "Speed Modifier"

func on_apply(context: EffectContext) -> void:
    # Logic to apply speed mod to context.target (CharacterComponent)
    pass
    
func on_remove(context: EffectContext) -> void:
    # Logic to remove speed mod
    pass
