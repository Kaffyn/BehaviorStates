@tool
class_name StateContext extends RefCounted

var state: Resource
var actor: Node
var behavior: Node # Node type to break cycle
var blackboard: Dictionary = {}
var delta: float = 0.0

# Helpers/Shortcuts
var input_dir: Vector2 = Vector2.ZERO

# Stats shortcuts
var base_damage: float:
	get:
		if behavior and behavior.has_method("get_stat"):
			return behavior.get_stat("damage") # Assuming 'damage' stat exists in CharacterSheet
		return 10.0 # Default fallback

func setup(p_state: Resource, p_actor: Node, p_behavior: Node, p_blackboard: Dictionary) -> void:
	state = p_state
	actor = p_actor
	behavior = p_behavior
	blackboard = p_blackboard

func get_stat(stat_name: String) -> float:
	if behavior and behavior.has_method("get_stat"):
		return behavior.get_stat(stat_name)
	return 0.0
