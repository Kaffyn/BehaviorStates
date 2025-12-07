@tool
## O Painel do Editor (Bottom Panel Integration).
##
## Fornece a interface visual (Graph, Library, Factory, Debugger, Grimório) para o BehaviorStates dentro da Godot.
class_name BehaviorStatesPanel extends Control

# The Config Resource Instance (should be saved/loaded properly in a real plugin)
var config: BehaviorStatesConfig

@onready var distraction_free_btn: Button = $DistractionFreeBtn

func _ready() -> void:
	_load_config()
	
	if distraction_free_btn:
		distraction_free_btn.toggled.connect(_on_distraction_free_toggled)
		# Set icon from editor theme
		var editor_theme = EditorInterface.get_editor_theme()
		if editor_theme.has_icon("DistractionFree", "EditorIcons"):
			distraction_free_btn.icon = editor_theme.get_icon("DistractionFree", "EditorIcons")
		else:
			# Fallback if specific icon not found
			distraction_free_btn.text = "[ ]"

func _load_config() -> void:
	# In a real scenario, we might want to load this from a ProjectSetting or a known path.
	# For now, we instantiate a default config.
	if not config:
		config = BehaviorStatesConfig.new()

func _on_distraction_free_toggled(toggled_on: bool) -> void:
	EditorInterface.set_distraction_free_mode(toggled_on)
