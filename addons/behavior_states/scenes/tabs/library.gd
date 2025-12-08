@tool
## Biblioteca de Ativos (Asset Library).
##
## Gerencia, lista e filtra recursos de comportamento (.tres) do projeto.
extends MarginContainer

# Plugin Icon Paths
const ICON_STATE = "res://addons/behavior_states/assets/icons/state.svg"
const ICON_COMPOSE = "res://addons/behavior_states/assets/icons/compose.svg"
const ICON_ITEM = "res://addons/behavior_states/assets/icons/item.svg"
const ICON_SKILL = "res://addons/behavior_states/assets/icons/skill.svg"
const ICON_CHARACTER_SHEET = "res://addons/behavior_states/assets/icons/character_sheet.svg"
const ICON_CONFIG = "res://addons/behavior_states/assets/icons/config.svg"

# Plugin resource types to show
const PLUGIN_TYPES = ["State", "Compose", "Item", "Skill", "CharacterSheet", "BehaviorStatesConfig"]

@onready var search_edit: LineEdit = $VBoxContainer/HBoxContainer/SearchEdit
@onready var asset_list: ItemList = $VBoxContainer/AssetList

var _all_assets: Array[String] = []
var _icon_cache: Dictionary = {}
var _is_dragging: bool = false

func _ready() -> void:
	_preload_icons()
	
	if search_edit:
		search_edit.text_changed.connect(_on_search_text_changed)
	if asset_list:
		asset_list.item_activated.connect(_on_item_activated)
		asset_list.item_selected.connect(_on_item_selected)
		asset_list.item_clicked.connect(_on_item_clicked)
		# Enable drag & drop
		asset_list.set_drag_forwarding(_get_drag_data_fw, Callable(), Callable())
	
	refresh_assets()

# Drag & Drop - Forward drag data from ItemList
func _get_drag_data_fw(at_position: Vector2):
	var idx = asset_list.get_item_at_position(at_position, true)
	if idx < 0:
		return null
	
	var path = asset_list.get_item_metadata(idx)
	if not path:
		return null
	
	# Create preview
	var preview = HBoxContainer.new()
	var icon = TextureRect.new()
	icon.texture = asset_list.get_item_icon(idx)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(32, 32)
	preview.add_child(icon)
	
	var label = Label.new()
	label.text = asset_list.get_item_text(idx)
	preview.add_child(label)
	
	asset_list.set_drag_preview(preview)
	
	# Set flag to prevent inspector change
	_is_dragging = true
	
	# Return data in the same format as FileSystem dock
	return {"type": "files", "files": [path]}

func _preload_icons() -> void:
	# Preload plugin icons
	_icon_cache["State"] = load(ICON_STATE) if ResourceLoader.exists(ICON_STATE) else null
	_icon_cache["Compose"] = load(ICON_COMPOSE) if ResourceLoader.exists(ICON_COMPOSE) else null
	_icon_cache["Item"] = load(ICON_ITEM) if ResourceLoader.exists(ICON_ITEM) else null
	_icon_cache["Skill"] = load(ICON_SKILL) if ResourceLoader.exists(ICON_SKILL) else null
	_icon_cache["CharacterSheet"] = load(ICON_CHARACTER_SHEET) if ResourceLoader.exists(ICON_CHARACTER_SHEET) else null
	_icon_cache["BehaviorStatesConfig"] = load(ICON_CONFIG) if ResourceLoader.exists(ICON_CONFIG) else null

func refresh_assets() -> void:
	_all_assets.clear()
	_scan_directory("res://")
	_update_list()

func _scan_directory(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != ".." and file_name != ".godot":
					_scan_directory(path + "/" + file_name)
			else:
				if file_name.ends_with(".tres"):
					_all_assets.append(path + "/" + file_name)
			file_name = dir.get_next()

func _update_list(filter: String = "") -> void:
	if not asset_list:
		return
		
	asset_list.clear()
	var editor_theme = EditorInterface.get_editor_theme()
	var fallback_icon = editor_theme.get_icon("Object", "EditorIcons")
	
	for path in _all_assets:
		if filter.is_empty() or filter.to_lower() in path.get_file().to_lower():
			if not ResourceLoader.exists(path):
				continue
				
			var res = load(path)
			if not res:
				continue
			
			# Filter: Only show plugin resources
			var type_name = _get_resource_type_name(res)
			if type_name not in PLUGIN_TYPES:
				continue
			
			var file_name = path.get_file()
			
			# Get icon from cache or use fallback
			var icon = _icon_cache.get(type_name, fallback_icon)
			if icon == null:
				icon = fallback_icon
			
			var idx = asset_list.add_item(file_name, icon)
			asset_list.set_item_tooltip(idx, path)
			asset_list.set_item_metadata(idx, path)

func _on_search_text_changed(new_text: String) -> void:
	_update_list(new_text)

func _on_item_activated(index: int) -> void:
	var path = asset_list.get_item_metadata(index)
	if path and ResourceLoader.exists(path):
		var res = load(path)
		EditorInterface.edit_resource(res)

func _on_item_selected(index: int) -> void:
	# Don't change inspector if we're starting a drag
	if _is_dragging:
		_is_dragging = false
		return
	
	# Show selected resource in native Godot inspector
	var path = asset_list.get_item_metadata(index)
	if path and ResourceLoader.exists(path):
		var res = load(path)
		EditorInterface.inspect_object(res)

func _on_item_clicked(index: int, at_position: Vector2, mouse_button: int) -> void:
	print("Library: Item clicked. Index: ", index, " Button: ", mouse_button)
	# Right-click opens in Editor tab
	if mouse_button == MOUSE_BUTTON_RIGHT:
		var path = asset_list.get_item_metadata(index)
		print("Library: Right click on path: ", path)
		if path and ResourceLoader.exists(path):
			# Switch to Editor tab and load resource via Panel root
			var panel = find_parent("BehaviorStatesPanel")
			print("Library: Found panel? ", panel)
			if panel and panel.has_method("_switch_to_editor_with_resource"):
				print("Library: Calling _switch_to_editor_with_resource")
				panel._switch_to_editor_with_resource(path)
			else:
				print("Library: Fallback to inspector")
				# Fallback: just open in inspector
				var res = load(path)
				EditorInterface.edit_resource(res)

func _on_refresh_pressed() -> void:
	refresh_assets()

func _get_resource_type_name(res: Resource) -> String:
	# Get the class name from the resource's script
	var script = res.get_script()
	if script:
		var class_name_str = script.get_global_name()
		if not class_name_str.is_empty():
			return class_name_str
	# Fallback to built-in class
	return res.get_class()
