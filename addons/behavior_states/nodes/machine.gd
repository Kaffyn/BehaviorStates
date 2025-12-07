@tool
## Machine - Máquina de Estados.
##
## Motor de execução que gerencia o estado atual e avalia transições.
## Requer referência ao Behavior. Conecta-se opcionalmente ao Backpack.
## Deve ser filho de CharacterBody2D ou CharacterBody3D.
class_name Machine extends Node

const VALID_PARENTS = ["CharacterBody2D", "CharacterBody3D"]

signal state_changed(old_state: State, new_state: State)

## Referência ao Behavior (obrigatório).
@export var behavior: Behavior
## Referência ao Backpack (opcional, para obter item equipado).
@export var backpack: Backpack
## Compose padrão (usado se não houver Backpack ou item equipado).
@export var default_compose: Compose

## Estado atual sendo executado.
var current_state: State = null
## Tempo no estado atual (segundos).
var time_in_state: float = 0.0

func _ready() -> void:
	_validate_parent()
	
	if behavior:
		behavior.context_changed.connect(_on_context_changed)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not _is_valid_parent():
		warnings.append("Machine deve ser filho de CharacterBody2D ou CharacterBody3D!")
	
	if not behavior:
		warnings.append("Machine requer referência ao Behavior!")
	
	return warnings

func _is_valid_parent() -> bool:
	var parent = get_parent()
	if not parent:
		return false
	return parent.get_class() in VALID_PARENTS or parent is CharacterBody2D or parent is CharacterBody3D

func _validate_parent() -> void:
	if Engine.is_editor_hint():
		return
	
	if not _is_valid_parent():
		push_error("[Machine] Deve ser filho de CharacterBody2D/3D!")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	time_in_state += delta
	
	# Verifica duração do estado
	if current_state and current_state.duration > 0:
		if time_in_state >= current_state.duration:
			_on_state_duration_ended()

func _on_context_changed(category: String, value: int) -> void:
	_try_transition()

func _on_state_duration_ended() -> void:
	change_state(null)
	_try_transition()

func change_state(new_state: State, preserve_time: bool = false) -> void:
	var old_state = current_state
	
	if old_state:
		_exit_state(old_state)
	
	current_state = new_state
	
	if not preserve_time:
		time_in_state = 0.0
	
	if new_state:
		_enter_state(new_state)
	
	state_changed.emit(old_state, new_state)

func _enter_state(state: State) -> void:
	pass

func _exit_state(state: State) -> void:
	pass

func _try_transition() -> void:
	var compose = _get_active_compose()
	if not compose:
		return
	
	var candidates = _get_candidates(compose)
	var best = _find_best_match(candidates)
	
	if best and best != current_state:
		change_state(best)

func _get_active_compose() -> Compose:
	# Prioridade: Backpack -> Item -> Compose
	if backpack:
		var equipped = backpack.get_equipped_compose()
		if equipped:
			return equipped
	
	return default_compose

func _get_candidates(compose: Compose) -> Array[State]:
	var candidates: Array[State] = []
	
	if compose:
		candidates.append_array(compose.get_move_states())
		candidates.append_array(compose.get_attack_states())
	
	# Adiciona states do Behavior (via SkillTree)
	if behavior:
		candidates.append_array(behavior.get_all_available_states())
	
	return candidates

func _find_best_match(candidates: Array[State]) -> State:
	if candidates.is_empty():
		return null
	
	if not behavior:
		return candidates[0]
	
	var best: State = null
	var best_score: int = -1
	
	for state in candidates:
		if _matches_context(state):
			var score = _calculate_score(state)
			if score > best_score:
				best_score = score
				best = state
	
	return best

func _matches_context(state: State) -> bool:
	if not behavior or not state.entry_requirements:
		return true
	
	for category in state.entry_requirements.keys():
		var required = state.entry_requirements[category]
		var current = behavior.get_context(category)
		
		# ANY (0 ou negativo)
		if required <= 0:
			continue
		
		if current != required:
			return false
	
	return true

func _calculate_score(state: State) -> int:
	var score = 0
	score += state.priority_override * 100
	
	if state.entry_requirements:
		for category in state.entry_requirements.keys():
			if state.entry_requirements[category] > 0:
				score += 10
	
	return score
