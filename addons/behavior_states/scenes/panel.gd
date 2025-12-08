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

func _switch_to_editor_with_resource(path: String) -> void:
	print("Panel: Switching to editor with resource: ", path)
	# Find TabContainer and switch to Editor tab (index 1)
	var tab_container = $MarginContainer/TabContainer
	if tab_container:
		tab_container.current_tab = 1  # Editor is index 1
		
		# Get Editor tab and load resource
		var editor = tab_container.get_child(1)
		print("Panel: Editor tab node: ", editor)
		if editor and editor.has_method("load_resource_from_library"):
			editor.load_resource_from_library(path)
