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
@onready var asset_tree: Tree = $VBoxContainer/AssetTree

var _all_assets: Array[String] = []
var _icon_cache: Dictionary = {}
var _is_dragging: bool = false

# Grouping Definitions
const GROUP_SYSTEM = ["BehaviorStatesConfig", "InventoryData", "Item", "Skill", "SkillTree", "CharacterSheet"]

func _ready() -> void:
	_preload_icons()
	
	if search_edit:
		search_edit.text_changed.connect(_on_search_text_changed)
	if asset_tree:
		asset_tree.item_activated.connect(_on_item_activated)
		asset_tree.item_selected.connect(_on_item_selected)
		asset_tree.item_mouse_selected.connect(_on_item_clicked)
		asset_tree.set_drag_forwarding(_get_drag_data_fw, Callable(), Callable())
	
	refresh_assets()

func _get_drag_data_fw(at_position: Vector2):
	var item = asset_tree.get_item_at_position(at_position)
	if not item:
		return null
	
	var path = item.get_metadata(0)
	if not path or not (path is String):
		return null
	
	# Preview
	var preview = Label.new()
	preview.text = item.get_text(0)
	asset_tree.set_drag_preview(preview)
	
	_is_dragging = true
	return {"type": "files", "files": [path]}

func _preload_icons() -> void:
	_icon_cache["State"] = load(ICON_STATE) if ResourceLoader.exists(ICON_STATE) else null
	_icon_cache["Compose"] = load(ICON_COMPOSE) if ResourceLoader.exists(ICON_COMPOSE) else null
	_icon_cache["Item"] = load(ICON_ITEM) if ResourceLoader.exists(ICON_ITEM) else null
	_icon_cache["Skill"] = load(ICON_SKILL) if ResourceLoader.exists(ICON_SKILL) else null
	_icon_cache["CharacterSheet"] = load(ICON_CHARACTER_SHEET) if ResourceLoader.exists(ICON_CHARACTER_SHEET) else null
	_icon_cache["BehaviorStatesConfig"] = load(ICON_CONFIG) if ResourceLoader.exists(ICON_CONFIG) else null

func refresh_assets() -> void:
	_all_assets.clear()
	_scan_directory("res://")
	_update_tree()

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

func _update_tree(filter: String = "") -> void:
	if not asset_tree:
		return
	asset_tree.clear()
	var root = asset_tree.create_item() # Invisible root
	
	# Categories
	var system_root = asset_tree.create_item(root)
	system_root.set_text(0, "Systems & Items")
	system_root.set_selectable(0, false)
	system_root.set_custom_color(0, Color("#8b5cf6"))
	
	var compose_root = asset_tree.create_item(root)
	compose_root.set_text(0, "Composes")
	compose_root.set_selectable(0, false)
	compose_root.set_custom_color(0, Color("#f59e0b"))
	
	var folder_root = asset_tree.create_item(root)
	folder_root.set_text(0, "Unlinked States")
	folder_root.set_selectable(0, false)
	folder_root.set_custom_color(0, Color("#9ca3af"))
	
	# Data Buckets
	var system_assets: Array[Resource] = []
	var composes: Array[Resource] = []
	var states: Dictionary = {} # path -> resource
	var linked_states: Dictionary = {} # path -> true (if belongs to a compose)
	
	var editor_theme = EditorInterface.get_editor_theme()
	var fallback_icon = editor_theme.get_icon("Object", "EditorIcons")
	
	# 1. Load and Classify
	for path in _all_assets:
		if not filter.is_empty() and not (filter.to_lower() in path.get_file().to_lower()):
			continue
			
		var res = load(path)
		if not res: continue
		var type = _get_resource_type_name(res)
		
		if type == "Compose":
			composes.append(res)
		elif type in GROUP_SYSTEM:
			system_assets.append(res)
		elif type == "State":
			states[path] = res
	
	# 2. Map Compose Links
	for comp in composes:
		var moves = comp.get("move_states")
		if moves is Array: for s in moves: if s: linked_states[s.resource_path] = true
			
		var attacks = comp.get("attack_states")
		if attacks is Array: for s in attacks: if s: linked_states[s.resource_path] = true
			
		var interact = comp.get("interactive_states")
		if interact is Array: for s in interact: if s: linked_states[s.resource_path] = true
	
	# 3. Populate Systems
	for res in system_assets:
		var item = asset_tree.create_item(system_root)
		item.set_text(0, res.resource_path.get_file())
		item.set_icon(0, _icon_cache.get(_get_resource_type_name(res), fallback_icon))
		item.set_metadata(0, res.resource_path)
		item.set_tooltip_text(0, res.resource_path)
	
	# 4. Populate Composes
	for comp in composes:
		var comp_item = asset_tree.create_item(compose_root)
		comp_item.set_text(0, comp.resource_path.get_file())
		comp_item.set_icon(0, _icon_cache.get("Compose", fallback_icon))
		comp_item.set_metadata(0, comp.resource_path)
		
		# Add child states
		var child_states = []
		var m = comp.get("move_states"); if m is Array: child_states.append_array(m)
		var a = comp.get("attack_states"); if a is Array: child_states.append_array(a)
		var i = comp.get("interactive_states"); if i is Array: child_states.append_array(i)
		
		for s in child_states:
			if s:
				var s_item = asset_tree.create_item(comp_item)
				s_item.set_text(0, s.resource_path.get_file())
				s_item.set_icon(0, _icon_cache.get("State", fallback_icon))
				s_item.set_metadata(0, s.resource_path)
				s_item.set_tooltip_text(0, s.resource_path)
	
	# 5. Populate Folders (Unlinked States)
	var folder_groups: Dictionary = {}
	
	for path in states.keys():
		if linked_states.has(path):
			continue
			
		var dir_path = path.get_base_dir().replace("res://", "")
		if not folder_groups.has(dir_path):
			folder_groups[dir_path] = []
		folder_groups[dir_path].append(states[path])
		
	for dir in folder_groups.keys():
		var dir_item = asset_tree.create_item(folder_root)
		dir_item.set_text(0, dir)
		dir_item.set_selectable(0, false)
		dir_item.set_custom_color(0, Color("#6b7280"))
		
		for s in folder_groups[dir]:
			var s_item = asset_tree.create_item(dir_item)
			s_item.set_text(0, s.resource_path.get_file())
			s_item.set_icon(0, _icon_cache.get("State", fallback_icon))
			s_item.set_metadata(0, s.resource_path)

func _on_search_text_changed(new_text: String) -> void:
	_update_tree(new_text)

func _on_item_activated() -> void:
	var item = asset_tree.get_selected()
	if not item: return
	var path = item.get_metadata(0)
	if path and ResourceLoader.exists(path):
		EditorInterface.edit_resource(load(path))

func _on_item_selected() -> void:
	if _is_dragging: 
		_is_dragging = false
		return
	var item = asset_tree.get_selected()
	if not item: return
	var path = item.get_metadata(0)
	if path and ResourceLoader.exists(path):
		EditorInterface.inspect_object(load(path))

func _on_item_clicked(position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var item = asset_tree.get_item_at_position(position)
		if item:
			item.select(0)
			var path = item.get_metadata(0)
			if path and ResourceLoader.exists(path):
				var panel = find_parent("BehaviorStatesPanel")
				if panel and panel.has_method("_switch_to_editor_with_resource"):
					panel._switch_to_editor_with_resource(path)
				else:
					EditorInterface.edit_resource(load(path))

func _on_refresh_pressed() -> void:
	refresh_assets()

func _on_new_pressed() -> void:
	var panel = find_parent("BehaviorStatesPanel")
	if panel:
		var tab_container = panel.find_child("TabContainer", true, false)
		if tab_container:
			tab_container.current_tab = 2

func _get_resource_type_name(res: Resource) -> String:
	var script = res.get_script()
	if script:
		var class_name_str = script.get_global_name()
		if not class_name_str.is_empty():
			return class_name_str
	return res.get_class()
