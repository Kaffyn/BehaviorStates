@tool
class_name Machine extends Node

signal state_changed(old_state: State, new_state: State)
signal damage_dealt(target: Node, amount: int)

@export var behavior: Behavior
@export var blackboard: Dictionary = {}

var current_state: State = null
var current_context: StateContext = null

# Core Loop
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not current_state:
		return
		
	if current_context:
		current_context.delta = delta
		
		for component in current_state.components:
			component.on_physics(current_context, delta)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not current_state:
		return
		
	if current_context:
		current_context.delta = delta
		
		for component in current_state.components:
			component.on_process(current_context)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not current_state:
		return
		
	if current_context:
		for component in current_state.components:
			component.on_input(current_context, event)

# State Management
func change_state(new_state: State) -> void:
	var old_state = current_state
	
	if old_state:
		_exit_state(old_state)
	
	current_state = new_state
	
	if new_state:
		_enter_state(new_state)
	
	state_changed.emit(old_state, new_state)

func _enter_state(state: State) -> void:
	# Create new context
	current_context = StateContext.new()
	current_context.state = state
	current_context.actor = get_parent()
	current_context.blackboard = blackboard # Shared blackboard? Or per machine?
	# Pass machine reference if needed, maybe add to StateContext definition
	
	for component in state.components:
		component.on_enter(current_context)

func _exit_state(state: State) -> void:
	if current_context:
		for component in state.components:
			component.on_exit(current_context)
	
	current_context = null
