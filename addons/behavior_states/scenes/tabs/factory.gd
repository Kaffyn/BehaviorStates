@tool
## Factory - Criação de Recursos com Presets.
##
## Interface para criar novos recursos usando presets pré-definidos.
## Também gerencia o BehaviorStatesConfig singleton.
extends MarginContainer

const Presets = preload("res://addons/behavior_states/scenes/tabs/factory_presets.gd")
const CONFIG_PATH = "res://addons/behavior_states/data/&config.tres"

# Tipos disponíveis
const TYPES = ["Config", "State", "Item", "Skill", "Compose", "Inventory", "SkillTree", "CharacterSheet"]
const RESOURCE_TYPES = ["State", "Item", "Skill", "Compose", "Inventory", "SkillTree", "CharacterSheet"]

@onready var type_list: ItemList = $HSplitContainer/TypeList
# @onready var options_label: Label = $HSplitContainer/RightPanel/OptionsLabel
@onready var config_panel: VBoxContainer = $HSplitContainer/RightPanel/ConfigPanel
@onready var resource_panel: VBoxContainer = $HSplitContainer/RightPanel/ResourcePanel
@onready var preset_grid: GridContainer = $HSplitContainer/RightPanel/ResourcePanel/PresetGrid
@onready var preset_description: Label = $HSplitContainer/RightPanel/ResourcePanel/PresetDescription
@onready var name_edit: LineEdit = $HSplitContainer/RightPanel/ResourcePanel/NameRow/NameEdit
@onready var file_dialog: FileDialog = $FileDialog

# Config controls
@onready var game_type_option: OptionButton = $HSplitContainer/RightPanel/ConfigPanel/GameTypeRow/GameTypeOption
@onready var gravity_check: CheckBox = $HSplitContainer/RightPanel/ConfigPanel/GravityRow/GravityCheck
@onready var gravity_spin: SpinBox = $HSplitContainer/RightPanel/ConfigPanel/GravityValueRow/GravitySpin
@onready var default_state_edit: LineEdit = $HSplitContainer/RightPanel/ConfigPanel/DefaultStateRow/DefaultStateEdit
@onready var log_check: CheckBox = $HSplitContainer/RightPanel/ConfigPanel/LogRow/LogCheck

var _selected_type: String = ""
var _selected_preset: String = ""
var _config: BehaviorStatesConfig = null
var _preset_buttons: Array[Button] = []

func _ready() -> void:
	_populate_type_list()
	_load_config()

func _populate_type_list() -> void:
	type_list.clear()
	for t in TYPES:
		if t == "Config":
			type_list.add_item("⚙ Config (único)")
		else:
			type_list.add_item(t)

func _load_config() -> void:
	if ResourceLoader.exists(CONFIG_PATH):
		_config = load(CONFIG_PATH)
	else:
		_config = BehaviorStatesConfig.new()
	_update_config_ui()

func _update_config_ui() -> void:
	if not _config:
		return
	game_type_option.selected = _config.game_type
	gravity_check.button_pressed = _config.use_gravity
	gravity_spin.value = _config.default_gravity
	default_state_edit.text = _config.default_state_name
	log_check.button_pressed = _config.log_transitions

func _on_type_selected(index: int) -> void:
	_selected_type = TYPES[index]
	_selected_preset = ""
	
	# options_label removed from scene
	# options_label.visible = false
	config_panel.visible = _selected_type == "Config"
	resource_panel.visible = _selected_type != "Config"
	
	if _selected_type == "Config":
		_update_config_ui()
	else:
		_populate_presets()
		name_edit.text = "new_" + _selected_type.to_lower()

func _populate_presets() -> void:
	# Clear old buttons
	for btn in _preset_buttons:
		btn.queue_free()
	_preset_buttons.clear()
	
	var group = ButtonGroup.new()
	var presets = Presets.get_presets_for_type(_selected_type)
	for preset_name in presets.keys():
		var btn = Button.new()
		btn.text = preset_name
		btn.toggle_mode = true
		btn.button_group = group
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(func(): _on_preset_selected(preset_name))
		preset_grid.add_child(btn)
		_preset_buttons.append(btn)
	
	preset_description.text = "Selecione um preset" if presets.size() > 0 else "Nenhum preset disponível"

func _on_preset_selected(preset_name: String) -> void:
	_selected_preset = preset_name
	
	# Update button states
	for btn in _preset_buttons:
		btn.button_pressed = btn.text == preset_name
	
	# Update description
	var presets = Presets.get_presets_for_type(_selected_type)
	if preset_name in presets:
		preset_description.text = presets[preset_name].get("description", "")
		
		# Update name suggestion
		var values = presets[preset_name].get("values", {})
		if "name" in values:
			name_edit.text = values["name"]

func _on_config_changed(_value = null) -> void:
	pass  # Other config changes are saved on button press

func _on_game_type_changed(index: int) -> void:
	# Apply game type presets automatically
	match index:
		0:  # Platform2D
			gravity_check.button_pressed = true
			gravity_spin.value = 980.0
			gravity_spin.editable = true
		1:  # TopDown2D
			gravity_check.button_pressed = false
			gravity_spin.value = 0.0
			gravity_spin.editable = false
		2:  # 3D
			gravity_check.button_pressed = true
			gravity_spin.value = 9.8
			gravity_spin.editable = true

func _on_save_config_pressed() -> void:
	if not _config:
		_config = BehaviorStatesConfig.new()
	
	_config.game_type = game_type_option.selected
	_config.use_gravity = gravity_check.button_pressed
	_config.default_gravity = gravity_spin.value
	_config.default_state_name = default_state_edit.text
	_config.log_transitions = log_check.button_pressed
	
	var err = ResourceSaver.save(_config, CONFIG_PATH)
	if err == OK:
		print("[Factory] Config saved: " + CONFIG_PATH)
	else:
		printerr("[Factory] Error saving config: " + str(err))

func _on_create_pressed() -> void:
	if _selected_type.is_empty() or _selected_type == "Config":
		return
	
	var default_path = _get_default_path_for_type(_selected_type)
	file_dialog.current_dir = default_path
	file_dialog.current_file = name_edit.text + ".tres"
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	var res = _create_resource_for_type(_selected_type)
	if not res:
		printerr("[Factory] Failed to create resource for type: " + _selected_type)
		return
	
	# Apply preset values
	if not _selected_preset.is_empty():
		Presets.apply_preset_to_resource(res, _selected_type, _selected_preset)
	
	# Apply name
	if "name" in res:
		res.name = name_edit.text
	if "id" in res:
		res.id = name_edit.text.to_snake_case()
	
	var err = ResourceSaver.save(res, path)
	if err == OK:
		print("[Factory] Created: " + path)
		EditorInterface.edit_resource(res)
	else:
		printerr("[Factory] Error saving: " + str(err))

func _create_resource_for_type(type_name: String) -> Resource:
	var script_map = {
		"State": "res://addons/behavior_states/resources/state.gd",
		"Item": "res://addons/behavior_states/resources/item.gd",
		"Skill": "res://addons/behavior_states/resources/skill.gd",
		"Compose": "res://addons/behavior_states/resources/compose.gd",
		"Inventory": "res://addons/behavior_states/resources/inventory.gd",
		"SkillTree": "res://addons/behavior_states/resources/skilltree.gd",
		"CharacterSheet": "res://addons/behavior_states/resources/character_sheet.gd"
	}
	
	if not type_name in script_map:
		return null
	
	var script_path = script_map[type_name]
	if ResourceLoader.exists(script_path):
		var script = load(script_path)
		if script and script is GDScript:
			return script.new()
	
	return null

func _get_default_path_for_type(type_name: String) -> String:
	if not _config:
		return "res://"
	
	match type_name:
		"State":
			return _config.default_states_path
		"Item":
			return _config.default_items_path
		"Compose":
			return _config.default_compose_path
	
	return "res://"
