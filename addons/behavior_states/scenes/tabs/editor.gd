@tool
## Editor Unificado de Recursos.
##
## Permite editar visualmente Compose, State, Item, Skill e outros resources do plugin.
extends MarginContainer

# Resource type filters for FileDialog
const TYPE_FILTERS = {
	"Compose": "*.tres ; Compose",
	"State": "*.tres ; State",
	"Item": "*.tres ; Item",
	"Skill": "*.tres ; Skill",
	"SkillTree": "*.tres ; SkillTree",
	"CharacterSheet": "*.tres ; CharacterSheet",
	"Inventory": "*.tres ; Inventory"
}

# Colors for each resource type
const TYPE_COLORS = {
	"Compose": Color("#ffca5f"),
	"State": Color("#8eef97"),
	"Item": Color("#8da5f3"),
	"Skill": Color("#ff8ccc"),
	"SkillTree": Color("#ff8ccc"),
	"CharacterSheet": Color("#e1a8ff"),
	"Inventory": Color("#e0e0e0")
}

@onready var type_list: ItemList = $HSplitContainer/Sidebar/TypeList
@onready var graph_edit: GraphEdit = $HSplitContainer/GraphContainer/GraphEdit
@onready var placeholder_label: Label = $HSplitContainer/GraphContainer/GraphEdit/PlaceholderLabel
@onready var file_dialog: FileDialog = $FileDialog

var _selected_type: String = ""
var _current_resource: Resource = null

func _ready() -> void:
	graph_edit.add_valid_connection_type(0, 0)
	# Auto-select first type
	if type_list.item_count > 0:
		type_list.select(0)
		_on_type_selected(0)

func _on_type_selected(index: int) -> void:
	_selected_type = type_list.get_item_text(index)
	# Update FileDialog filter
	if _selected_type in TYPE_FILTERS:
		file_dialog.filters = PackedStringArray([TYPE_FILTERS[_selected_type]])

func _on_load_pressed() -> void:
	if _selected_type.is_empty():
		push_warning("Selecione um tipo de recurso primeiro.")
		return
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	var res = load(path)
	if not res:
		printerr("Não foi possível carregar: ", path)
		return
	
	_current_resource = res
	_render_resource(res)

func _render_resource(res: Resource) -> void:
	_clear_graph()
	placeholder_label.visible = false
	
	var type_name = _get_resource_type_name(res)
	var color = TYPE_COLORS.get(type_name, Color.WHITE)
	
	# Create root node for the resource
	var root = _create_node(res.resource_path.get_file(), Vector2(50, 50), color)
	
	# Specific rendering based on type
	match type_name:
		"Compose":
			_render_compose(res, root)
		"Item":
			_render_item(res, root)
		"Skill":
			_render_skill(res, root)
		_:
			# Generic rendering - just show properties
			_render_generic(res, root)

func _render_compose(compose: Compose, root: GraphNode) -> void:
	var y_offset = 0
	
	if not compose.move_rules.is_empty():
		var node = _create_node("Move States", Vector2(300, 50 + y_offset), Color("#8eef97"))
		graph_edit.connect_node(root.name, 0, node.name, 0)
		_render_states_from_rules(compose.move_rules, Vector2(550, 50 + y_offset), node)
		y_offset += 200
	
	if not compose.attack_rules.is_empty():
		var node = _create_node("Attack States", Vector2(300, 50 + y_offset), Color("#ff8ccc"))
		graph_edit.connect_node(root.name, 0, node.name, 0)
		_render_states_from_rules(compose.attack_rules, Vector2(550, 50 + y_offset), node)

func _render_states_from_rules(rules: Dictionary, base_pos: Vector2, parent: GraphNode) -> void:
	var state_y = 0
	for key in rules.keys():
		var states = rules[key]
		if states is Array:
			for state in states:
				if state is State:
					var node = _create_node(state.resource_path.get_file(), base_pos + Vector2(0, state_y), Color("#8eef97"))
					graph_edit.connect_node(parent.name, 0, node.name, 0)
					state_y += 80

func _render_item(item: Item, root: GraphNode) -> void:
	if item.get("compose") and item.compose:
		var node = _create_node("Compose: " + item.compose.resource_path.get_file(), Vector2(300, 100), Color("#ffca5f"))
		graph_edit.connect_node(root.name, 0, node.name, 0)

func _render_skill(skill: Skill, root: GraphNode) -> void:
	if skill.get("unlocks") and skill.unlocks:
		var y_offset = 0
		for state in skill.unlocks:
			if state is State:
				var node = _create_node(state.resource_path.get_file(), Vector2(300, 100 + y_offset), Color("#8eef97"))
				graph_edit.connect_node(root.name, 0, node.name, 0)
				y_offset += 80

func _render_generic(res: Resource, root: GraphNode) -> void:
	# Just display a message in the root node
	pass

func _clear_graph() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			graph_edit.remove_child(child)
			child.queue_free()

func _create_node(title: String, position: Vector2, color: Color = Color.WHITE) -> GraphNode:
	var node = GraphNode.new()
	node.title = title
	node.position_offset = position
	node.resizable = true
	node.set_slot(0, true, 0, color, true, 0, color)
	graph_edit.add_child(node)
	
	var label = Label.new()
	label.text = " "
	node.add_child(label)
	
	return node

func _get_resource_type_name(res: Resource) -> String:
	var script = res.get_script()
	if script:
		var class_name_str = script.get_global_name()
		if not class_name_str.is_empty():
			return class_name_str
	return res.get_class()
