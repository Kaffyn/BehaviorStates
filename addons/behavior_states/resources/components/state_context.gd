@tool
class_name StateContext extends RefCounted

var state: State
var actor: Node
var behavior: Behavior
var blackboard: Dictionary = {}
var delta: float = 0.0

# Helpers/Shortcuts
var input_dir: Vector2 = Vector2.ZERO

func setup(p_state: State, p_actor: Node, p_behavior: Behavior, p_blackboard: Dictionary) -> void:
    state = p_state
    actor = p_actor
    behavior = p_behavior
    blackboard = p_blackboard

func get_stat(stat_name: String) -> float:
    if behavior:
        return behavior.get_stat(stat_name)
    return 0.0
