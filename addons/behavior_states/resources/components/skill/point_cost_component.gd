@tool
class_name PointCostComponent extends SkillComponent

@export var skill_points_cost: int = 1
@export var gold_cost: int = 0

func get_component_name() -> String:
	return "Cost"
