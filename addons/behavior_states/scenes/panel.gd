@tool
## O Painel do Editor (Bottom Panel Integration).
##
## Fornece a interface visual (Library, Editor, Factory, Debugger, Grimório) para o BehaviorStates.
class_name BehaviorStatesPanel extends Control

var config: BehaviorStatesConfig

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var config_path = "res://addons/behavior_states/data/config.tres"
	if ResourceLoader.exists(config_path):
		config = load(config_path)
	if not config:
		config = BehaviorStatesConfig.new()
