@tool
## O Painel do Editor (Bottom Panel Integration).
##
## Fornece a interface visual (Graph, Library, Factory, Debugger, Grimório) para o BehaviorStates dentro da Godot.
class_name BehaviorStatesPanel extends Control

# The Config Resource Instance (should be saved/loaded properly in a real plugin)
var config: BehaviorStatesConfig

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	# In a real scenario, we might want to load this from a ProjectSetting or a known path.
	# For now, we instantiate a default config.
	if not config:
		config = BehaviorStatesConfig.new()
