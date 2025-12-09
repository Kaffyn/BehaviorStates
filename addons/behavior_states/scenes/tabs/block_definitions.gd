## Block Definitions (DEPRECATED)
## Este arquivo foi substituído por ComponentDefinitions.
## Mantido apenas para compatibilidade com código legado.
##
## @deprecated Use ComponentDefinitions em vez disso.
class_name BlockDefinitions extends RefCounted

const ComponentDefs = preload("res://addons/behavior_states/resources/components/component_definitions.gd")

## DEPRECATED: Use ComponentDefinitions.get_components_for_type()
static func get_blocks_for_type(type_name: String) -> Dictionary:
	push_warning("BlockDefinitions is deprecated. Use ComponentDefinitions instead.")
	return ComponentDefs.get_components_for_type(type_name)

## DEPRECATED: Use ComponentDefinitions.get_component_names_for_type()
static func get_block_names_for_type(type_name: String) -> Array:
	push_warning("BlockDefinitions is deprecated. Use ComponentDefinitions instead.")
	return ComponentDefs.get_component_names_for_type(type_name)
