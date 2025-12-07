@tool
extends EditorPlugin

# Nodes
const TYPE_BEHAVIOR = "Behavior"
const TYPE_MACHINE = "Machine"
const TYPE_INVENTORY = "Inventory"

# Resources
const TYPE_STATE = "State"
const TYPE_COMPOSE = "Compose"
const TYPE_ITEM = "Item"
const TYPE_SKILL = "Skill"
const TYPE_CHARACTER_SHEET = "CharacterSheet"

# Scripts Paths (Nodes)
const PATH_BEHAVIOR = "res://addons/behavior_states/nodes/behavior.gd"
const PATH_MACHINE = "res://addons/behavior_states/nodes/machine.gd"
const PATH_INVENTORY = "res://addons/behavior_states/nodes/inventory.gd"

# Scripts Paths (Resources)
const PATH_STATE = "res://addons/behavior_states/resources/state.gd"
const PATH_COMPOSE = "res://addons/behavior_states/resources/compose.gd"
const PATH_ITEM = "res://addons/behavior_states/resources/item.gd"
const PATH_SKILL = "res://addons/behavior_states/resources/skill.gd"
const PATH_CHARACTER_SHEET = "res://addons/behavior_states/resources/character_sheet.gd"

# Icons
const ICON_BEHAVIOR = "res://addons/behavior_states/assets/icons/behavior.svg"
const ICON_MACHINE = "res://addons/behavior_states/assets/icons/machine.svg"
const ICON_INVENTORY = "res://addons/behavior_states/assets/icons/inventory.svg"
const ICON_STATE = "res://addons/behavior_states/assets/icons/state.svg"
const ICON_COMPOSE = "res://addons/behavior_states/assets/icons/compose.svg"
const ICON_ITEM = "res://addons/behavior_states/assets/icons/item.svg"
const ICON_SKILL = "res://addons/behavior_states/assets/icons/skill.svg"
const ICON_CHARACTER_SHEET = "res://addons/behavior_states/assets/icons/character_sheet.svg"

func _enter_tree() -> void:
	# Nodes
	add_custom_type(TYPE_BEHAVIOR, "Node", load(PATH_BEHAVIOR), load(ICON_BEHAVIOR))
	add_custom_type(TYPE_MACHINE, "Node", load(PATH_MACHINE), load(ICON_MACHINE))
	add_custom_type(TYPE_INVENTORY, "Node", load(PATH_INVENTORY), load(ICON_INVENTORY))
	
	# Resources
	add_custom_type(TYPE_STATE, "Resource", load(PATH_STATE), load(ICON_STATE))
	add_custom_type(TYPE_COMPOSE, "Resource", load(PATH_COMPOSE), load(ICON_COMPOSE))
	add_custom_type(TYPE_ITEM, "Resource", load(PATH_ITEM), load(ICON_ITEM))
	add_custom_type(TYPE_SKILL, "Resource", load(PATH_SKILL), load(ICON_SKILL))
	add_custom_type(TYPE_CHARACTER_SHEET, "Resource", load(PATH_CHARACTER_SHEET), load(ICON_CHARACTER_SHEET))

func _exit_tree() -> void:
	# Nodes
	remove_custom_type(TYPE_BEHAVIOR)
	remove_custom_type(TYPE_MACHINE)
	remove_custom_type(TYPE_INVENTORY)
	
	# Resources
	remove_custom_type(TYPE_STATE)
	remove_custom_type(TYPE_COMPOSE)
	remove_custom_type(TYPE_ITEM)
	remove_custom_type(TYPE_SKILL)
	remove_custom_type(TYPE_CHARACTER_SHEET)
