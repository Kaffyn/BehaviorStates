@tool
class_name IdentityEffectComponent extends EffectComponent

@export var effect_name: String = "Effect"
@export_multiline var description: String = ""
@export var icon: Texture2D

func get_component_name() -> String:
	return "Identity"
