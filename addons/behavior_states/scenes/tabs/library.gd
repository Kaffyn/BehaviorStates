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
@onready var content_box: VBoxContainer = $VBoxContainer/ScrollContainer/Content

const ASSET_CARD_SCENE = "res://addons/behavior_states/scenes/components/asset_card.tscn"
var AssetCardScene: PackedScene

var _all_assets: Array[String] = []
var _icon_cache: Dictionary = {}

# Grouping Definitions
const GROUP_SYSTEM = ["BehaviorStatesConfig", "Inventory", "Item", "Skill", "SkillTree", "CharacterSheet"]

func _ready() -> void:
	AssetCardScene = load(ASSET_CARD_SCENE)
	_preload_icons()
	
	if search_edit:
		search_edit.text_changed.connect(_on_search_text_changed)
	
	refresh_assets()

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
	_update_grid()

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

func _update_grid(filter: String = "") -> void:
	if not content_box:
		return
	
	for child in content_box.get_children():
		child.queue_free()
	
	# Data Buckets
	var system_assets: Array[Resource] = []
	var composes: Array[Resource] = []
	var states: Dictionary = {} # path -> resource
	var linked_states: Dictionary = {}
	
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
	
	# 3. Create Sections
	if not system_assets.is_empty():
		_create_section("Systems & Config", system_assets, fallback_icon)
	
	if not composes.is_empty():
		_create_section("Composes", composes, fallback_icon)
		
	# 4. Group Unlinked States by Folder
	var folder_groups: Dictionary = {}
	for path in states.keys():
		if linked_states.has(path): continue
		var dir = path.get_base_dir().replace("res://", "")
		if not folder_groups.has(dir): folder_groups[dir] = []
		folder_groups[dir].append(states[path])
		
	for dir in folder_groups.keys():
		if not folder_groups[dir].is_empty():
			_create_section("States: " + dir, folder_groups[dir], fallback_icon)

func _create_section(title: String, assets: Array, fallback_icon: Texture2D) -> void:
	var section = VBoxContainer.new()
	content_box.add_child(section)
	
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("#a0aec0"))
	section.add_child(label)
	
	var grid = HFlowContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	section.add_child(grid)
	
	for res in assets:
		var card = AssetCardScene.instantiate()
		grid.add_child(card)
		var icon = _icon_cache.get(_get_resource_type_name(res), fallback_icon)
		card.setup(res.resource_path, icon)
		card.clicked.connect(_on_card_clicked)
		card.activated.connect(_on_card_activated)

func _on_search_text_changed(new_text: String) -> void:
	_update_grid(new_text)

func _on_card_activated(path: String) -> void:
	EditorInterface.edit_resource(load(path))

func _on_card_clicked(path: String, btn: int) -> void:
	if btn == MOUSE_BUTTON_RIGHT:
		var panel = find_parent("BehaviorStatesPanel")
		if panel and panel.has_method("_switch_to_editor_with_resource"):
			panel._switch_to_editor_with_resource(path)
		else:
			EditorInterface.edit_resource(load(path))
	else:
		# Left click - inspect
		EditorInterface.inspect_object(load(path))

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
