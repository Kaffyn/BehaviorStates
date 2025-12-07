@tool
## Biblioteca de Ativos (Asset Library).
##
## Gerencia, lista e filtra recursos de comportamento (.tres) do projeto.
extends MarginContainer

@onready var search_edit: LineEdit = $VBoxContainer/HBoxContainer/SearchEdit
@onready var asset_list: ItemList = $VBoxContainer/AssetList

var _all_assets: Array[String] = []

func _ready() -> void:
	if search_edit:
		search_edit.text_changed.connect(_on_search_text_changed)
	if asset_list:
		asset_list.item_activated.connect(_on_item_activated)
		asset_list.item_selected.connect(_on_item_selected)
	
	refresh_assets()

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
	
	for path in _all_assets:
		if filter.is_empty() or filter.to_lower() in path.get_file().to_lower():
			# Only load and check if it's a plugin resource
			if not ResourceLoader.exists(path):
				continue
				
			var res = load(path)
			if not res:
				continue
			
			# Filter: Only show plugin resources using script class name check
			var type_name = _get_resource_type_name(res)
			if type_name not in ["State", "Compose", "BehaviorStatesConfig"]:
				continue
			
			var file_name = path.get_file()
			var icon = editor_theme.get_icon("Object", "EditorIcons")
			
			# Set appropriate icon based on type
			match type_name:
				"State":
					icon = editor_theme.get_icon("ResourcePreloader", "EditorIcons")
				"Compose":
					icon = editor_theme.get_icon("GDScript", "EditorIcons")
				"BehaviorStatesConfig":
					icon = editor_theme.get_icon("Tools", "EditorIcons") if editor_theme.has_icon("Tools", "EditorIcons") else editor_theme.get_icon("Object", "EditorIcons")
			
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
	# Show selected resource in native Godot inspector
	var path = asset_list.get_item_metadata(index)
	if path and ResourceLoader.exists(path):
		var res = load(path)
		EditorInterface.inspect_object(res)

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
