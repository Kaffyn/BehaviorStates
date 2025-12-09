@tool
class_name StackingEffectComponent extends EffectComponent

enum StackingType {
	NONE,      # Apply new instance separately
	REFRESH,   # Refresh duration of existing
	ADD_TIME,  # Add duration to existing
	STACK_INTENSITY # Increase stack count (requires logic)
}

@export var stacking_type: StackingType = StackingType.REFRESH
@export var max_stacks: int = 1

func get_component_name() -> String:
	return "Stacking"
