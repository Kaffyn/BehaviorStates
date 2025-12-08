@tool
extends PanelContainer

signal activated(path)
signal clicked(path, mouse_btn)

var file_path: String = ""
var selected: bool = false : set = _set_selected

@onready var _panel_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()

func _ready():
	add_theme_stylebox_override("panel", _panel_style)
	gui_input.connect(_on_gui_input)

func setup(path: String, icon: Texture2D):
	file_path = path
	%Label.text = path.get_file()
	%Icon.texture = icon
	tooltip_text = path

func _set_selected(val: bool):
	selected = val
	if selected:
		_panel_style.bg_color = Color(1, 1, 1, 0.1) # Highlight
	else:
		_panel_style.bg_color = Color(0, 0, 0, 0)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		clicked.emit(file_path, event.button_index)
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			activated.emit(file_path)

func _get_drag_data(_at_position):
	var preview = VBoxContainer.new()
	var texture = TextureRect.new()
	texture.texture = %Icon.texture
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.custom_minimum_size = Vector2(48, 48)
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.add_child(texture)
	set_drag_preview(preview)
	
	return {"type": "files", "files": [file_path]}
