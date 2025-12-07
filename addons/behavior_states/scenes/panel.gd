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

# Stores the original split offset before maximizing
var _original_split_offset: int = -1

func _on_distraction_free_toggled(toggled_on: bool) -> void:
	EditorInterface.set_distraction_free_mode(toggled_on)
	
	# Also expand/collapse the bottom panel
	_toggle_bottom_panel_expansion(toggled_on)

func _toggle_bottom_panel_expansion(expand: bool) -> void:
	# Find the VSplitContainer that holds this bottom panel
	# The bottom panel is a child of the main editor layout's VSplitContainer
	var split_container = _find_parent_vsplit()
	if not split_container:
		return
	
	if expand:
		# Store original offset and maximize the bottom panel
		_original_split_offset = split_container.split_offset
		# Set a large negative value to push the split up (expand bottom panel)
		split_container.split_offset = -split_container.size.y * 0.7
	else:
		# Restore original offset
		if _original_split_offset != -1:
			split_container.split_offset = _original_split_offset

func _find_parent_vsplit() -> VSplitContainer:
	# Walk up the tree to find the VSplitContainer that controls the bottom panel
	var current = get_parent()
	while current:
		if current is VSplitContainer:
			return current
		current = current.get_parent()
	return null
