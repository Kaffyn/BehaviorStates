@tool
## O Painel do Editor (Bottom Panel Integration).
##
## Fornece a interface visual (Graph, Library, Factory, Debugger, Grimório) para o BehaviorStates dentro da Godot.
class_name BehaviorStatesPanel extends Control

var config: BehaviorStatesConfig

@onready var distraction_free_btn: Button = $DistractionFreeBtn

func _ready() -> void:
	_load_config()
	
	if distraction_free_btn:
		distraction_free_btn.toggled.connect(_on_distraction_free_toggled)
		var editor_theme = EditorInterface.get_editor_theme()
		if editor_theme.has_icon("DistractionFree", "EditorIcons"):
			distraction_free_btn.icon = editor_theme.get_icon("DistractionFree", "EditorIcons")
		else:
			distraction_free_btn.text = "[ ]"

func _load_config() -> void:
	if not config:
		config = BehaviorStatesConfig.new()

func _on_distraction_free_toggled(toggled_on: bool) -> void:
	EditorInterface.set_distraction_free_mode(toggled_on)
