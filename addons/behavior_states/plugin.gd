@tool
extends EditorPlugin

var main_panel_instance

# Nodes
const TYPE_BEHAVIOR = "Behavior"
const TYPE_MACHINE = "Machine"
const TYPE_BACKPACK = "Backpack"

# Resources
const TYPE_STATE = "State"
const TYPE_COMPOSE = "Compose"
const TYPE_ITEM = "Item"
const TYPE_SKILL = "Skill"
const TYPE_SKILL_TREE = "SkillTree"
const TYPE_INVENTORY_DATA = "InventoryData"
const TYPE_CHARACTER_SHEET = "CharacterSheet"
const TYPE_CONFIG = "BehaviorStatesConfig"

# Scripts Paths (Nodes)
const PATH_BEHAVIOR = "res://addons/behavior_states/nodes/behavior.gd"
const PATH_MACHINE = "res://addons/behavior_states/nodes/machine.gd"
const PATH_BACKPACK = "res://addons/behavior_states/nodes/backpack.gd"

# Scripts Paths (Resources)
const PATH_STATE = "res://addons/behavior_states/resources/state.gd"
const PATH_COMPOSE = "res://addons/behavior_states/resources/compose.gd"
const PATH_ITEM = "res://addons/behavior_states/resources/item.gd"
const PATH_SKILL = "res://addons/behavior_states/resources/skill.gd"
const PATH_SKILL_TREE = "res://addons/behavior_states/resources/skilltree.gd"
const PATH_INVENTORY_DATA = "res://addons/behavior_states/resources/inventory.gd"
const PATH_CHARACTER_SHEET = "res://addons/behavior_states/resources/character_sheet.gd"
const PATH_CONFIG = "res://addons/behavior_states/resources/config.gd"

# Icons
const ICON_BEHAVIOR = "res://addons/behavior_states/assets/icons/behavior.svg"
const ICON_MACHINE = "res://addons/behavior_states/assets/icons/machine.svg"
const ICON_BACKPACK = "res://addons/behavior_states/assets/icons/inventory.svg"
const ICON_STATE = "res://addons/behavior_states/assets/icons/state.svg"
const ICON_COMPOSE = "res://addons/behavior_states/assets/icons/compose.svg"
const ICON_ITEM = "res://addons/behavior_states/assets/icons/item.svg"
const ICON_SKILL = "res://addons/behavior_states/assets/icons/skill.svg"
const ICON_SKILL_TREE = "res://addons/behavior_states/assets/icons/skill_tree.svg"
const ICON_INVENTORY = "res://addons/behavior_states/assets/icons/inventory.svg"
const ICON_CHARACTER_SHEET = "res://addons/behavior_states/assets/icons/character_sheet.svg"
const ICON_CONFIG = "res://addons/behavior_states/assets/icons/config.svg"

func _enter_tree() -> void:
	# Nodes
	add_custom_type(TYPE_BEHAVIOR, "Node", load(PATH_BEHAVIOR), load(ICON_BEHAVIOR))
	add_custom_type(TYPE_MACHINE, "Node", load(PATH_MACHINE), load(ICON_MACHINE))
	add_custom_type(TYPE_BACKPACK, "Control", load(PATH_BACKPACK), load(ICON_BACKPACK))
	
	# Resources
	add_custom_type(TYPE_STATE, "Resource", load(PATH_STATE), load(ICON_STATE))
	add_custom_type(TYPE_COMPOSE, "Resource", load(PATH_COMPOSE), load(ICON_COMPOSE))
	add_custom_type(TYPE_ITEM, "Resource", load(PATH_ITEM), load(ICON_ITEM))
	add_custom_type(TYPE_SKILL, "Resource", load(PATH_SKILL), load(ICON_SKILL))
	add_custom_type(TYPE_SKILL_TREE, "Resource", load(PATH_SKILL_TREE), load(ICON_SKILL_TREE))
	add_custom_type(TYPE_INVENTORY_DATA, "Resource", load(PATH_INVENTORY_DATA), load(ICON_INVENTORY))
	add_custom_type(TYPE_CHARACTER_SHEET, "Resource", load(PATH_CHARACTER_SHEET), load(ICON_CHARACTER_SHEET))
	add_custom_type(TYPE_CONFIG, "Resource", load(PATH_CONFIG), load(ICON_CONFIG))
	
	# Bottom Panel
	var panel_scene = load("res://addons/behavior_states/scenes/panel.tscn")
	if panel_scene:
		main_panel_instance = panel_scene.instantiate()
		add_control_to_bottom_panel(main_panel_instance, "BehaviorStates")

func _exit_tree() -> void:
	# Nodes
	remove_custom_type(TYPE_BEHAVIOR)
	remove_custom_type(TYPE_MACHINE)
	remove_custom_type(TYPE_BACKPACK)
	
	# Resources
	remove_custom_type(TYPE_STATE)
	remove_custom_type(TYPE_COMPOSE)
	remove_custom_type(TYPE_ITEM)
	remove_custom_type(TYPE_SKILL)
	remove_custom_type(TYPE_SKILL_TREE)
	remove_custom_type(TYPE_INVENTORY_DATA)
	remove_custom_type(TYPE_CHARACTER_SHEET)
	remove_custom_type(TYPE_CONFIG)
	
	# Bottom Panel
	if main_panel_instance:
		remove_control_from_bottom_panel(main_panel_instance)
		main_panel_instance.free()
