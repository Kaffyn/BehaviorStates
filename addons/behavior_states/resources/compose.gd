@tool
## Container de composição de estados.
##
## Permite combinar múltiplos sub-estados ou comportamentos em um único recurso.
## Útil para definir conjuntos de regras ou variações de estados complexos.
class_name Compose extends Resource

@export var move_states: Array[State] = []
@export var attack_states: Array[State] = []
@export var interactive_states: Array[State] = []

## Índices para busca O(1).
var move_rules: Dictionary = {}
var attack_rules: Dictionary = {}
var interactive_rules: Dictionary = {}

# Cache
var _states_map: Dictionary = {}
var _initialized: bool = false

func initialize() -> void:
	if _initialized:
		return
	
	_states_map.clear()
	move_rules.clear()
	attack_rules.clear()
	interactive_rules.clear()

	move_rules = _build_index(move_states)
	attack_rules = _build_index(attack_states)
	interactive_rules = _build_index(interactive_states)

	_initialized = true

func _build_index(states: Array[State]) -> Dictionary:
	var index: Dictionary = {}
	for state in states:
		if not state:
			continue
		_register_state(state)
		
		var key = state.get_lookup_key()
		if not index.has(key):
			index[key] = []
		index[key].append(state)
	return index

func _register_state(res: Resource) -> void:
	if res and "name" in res:
		_states_map[res.name] = res

func get_state_by_name(state_name: String) -> Resource:
	if not _initialized:
		initialize()
	return _states_map.get(state_name)

func get_move_states() -> Array[State]:
	if not _initialized:
		initialize()
	return move_states

func get_attack_states() -> Array[State]:
	if not _initialized:
		initialize()
	return attack_states

func get_interactive_states() -> Array[State]:
	if not _initialized:
		initialize()
	return interactive_states

func get_states_for_key(category: String, key: int) -> Array:
	if not _initialized:
		initialize()
	
	match category:
		"motion", "move":
			return move_rules.get(key, [])
		"attack":
			return attack_rules.get(key, [])
		"interactive":
			return interactive_rules.get(key, [])
	
	return []
