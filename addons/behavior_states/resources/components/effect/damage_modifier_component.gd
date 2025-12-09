@tool
class_name DamageModifierComponent extends EffectComponent

enum ModifierType { FLAT, PERCENT_ADD, PERCENT_MULT }

@export var modifier_type: ModifierType = ModifierType.PERCENT_ADD
@export var value: float = 0.5 # +50% damage
@export_enum("Physical", "Magical", "Fire", "Ice", "All") var damage_type: String = "All"

func get_component_name() -> String:
	return "Damage Modifier"
