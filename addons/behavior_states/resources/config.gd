@tool
## Configuração Global do BehaviorStates.
##
## Define o tipo de jogo e configurações que afetam Machine e States.
## Singleton: Acesse via preload("res://addons/behavior_states/data/&config.tres")
class_name BehaviorStatesConfig extends Resource

# ============= GAME TYPE =============
@export_category("Game Type")
## Tipo de jogo - afeta física e comportamento da Machine.
@export_enum("Platform2D", "TopDown2D", "3D") var game_type: int = 0:
	set(value):
		game_type = value
		_apply_game_type_preset(value)

# ============= PHYSICS =============
@export_group("Physics")
## Se gravidade é aplicada aos personagens.
@export var use_gravity: bool = true
## Valor padrão de gravidade (só Platform2D).
@export var default_gravity: float = 980.0
## Tipo de process para física.
@export_enum("Idle", "Physics") var physics_process_mode: int = 1

func _apply_game_type_preset(type: int) -> void:
	match type:
		0:  # Platform2D
			use_gravity = true
			default_gravity = 980.0
		1:  # TopDown2D
			use_gravity = false
			default_gravity = 0.0
		2:  # 3D
			use_gravity = true
			default_gravity = 9.8

# ============= MACHINE =============
@export_group("Machine Defaults")
## Nome do state padrão ao iniciar.
@export var default_state_name: String = "Idle"
## Se a Machine deve logar transições no console.
@export var log_transitions: bool = false

# ============= PATHS =============
@export_group("Paths")
## Caminho padrão para salvar novos States.
@export_dir var default_states_path: String = "res://addons/behavior_states/data/states"
## Caminho padrão para salvar novos Items.
@export_dir var default_items_path: String = "res://addons/behavior_states/data/items"
## Caminho padrão para salvar Compose.
@export_dir var default_compose_path: String = "res://addons/behavior_states/data/compose"

# ============= VISUALS =============
@export_group("Editor Visuals")
## Cor usada para nós de Estado no GraphEdit.
@export var state_node_color: Color = Color.CORNFLOWER_BLUE
## Cor usada para conexões.
@export var transition_color: Color = Color.WHITE

# ============= DEBUG =============
@export_group("Debug")
## Cor dos logs de comportamento no console.
@export var log_color: Color = Color.ORANGE

# ============= HELPERS =============
func is_platform_2d() -> bool:
	return game_type == 0

func is_topdown_2d() -> bool:
	return game_type == 1

func is_3d() -> bool:
	return game_type == 2

func get_gravity() -> float:
	if use_gravity and is_platform_2d():
		return default_gravity
	return 0.0
