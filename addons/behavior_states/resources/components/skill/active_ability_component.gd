@tool
class_name ActiveAbilityComponent extends SkillComponent

@export var action_state: Resource # State to trigger
@export var cooldown: float = 0.0
@export var mana_cost: float = 0.0

func get_component_name() -> String:
	return "Active Ability"
