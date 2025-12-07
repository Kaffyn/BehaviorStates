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

# Tailwind-inspired colors for each resource type
const TYPE_COLORS = {
	"Compose": Color("#f59e0b"),     # amber-500
	"State": Color("#22c55e"),       # green-500
	"Item": Color("#3b82f6"),        # blue-500
	"Skill": Color("#ec4899"),       # pink-500
	"SkillTree": Color("#a855f7"),   # purple-500
	"CharacterSheet": Color("#8b5cf6"), # violet-500
	"Inventory": Color("#6b7280")    # gray-500
}

@onready var type_list: ItemList = $HSplitContainer/Sidebar/TypeList
@onready var graph_edit: GraphEdit = $HSplitContainer/GraphContainer/GraphEdit
@onready var placeholder_label: Label = $HSplitContainer/GraphContainer/GraphEdit/PlaceholderLabel
@onready var file_dialog: FileDialog = $FileDialog

var _selected_type: String = ""
var _loaded_resources: Array[Resource] = []
var _node_counter: int = 0

func _ready() -> void:
	# Setup graph for connections
	graph_edit.add_valid_connection_type(0, 0)
	graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)
	
	# Connect signals for manual connections
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	graph_edit.node_selected.connect(_on_graph_node_selected)
	
	# Auto-select first type
	if type_list.item_count > 0:
		type_list.select(0)
		_on_type_selected(0)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

func _on_type_selected(index: int) -> void:
	_selected_type = type_list.get_item_text(index)
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
	
	# Check if already loaded
	for r in _loaded_resources:
		if r.resource_path == res.resource_path:
			push_warning("Recurso já carregado: ", path)
			return
	
	_loaded_resources.append(res)
	_add_resource_to_graph(res)

func _on_remove_pressed() -> void:
	# Remove selected nodes from graph
	var nodes_to_remove: Array[GraphNode] = []
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			nodes_to_remove.append(child)
	
	for node in nodes_to_remove:
		# Remove connections
		for connection in graph_edit.get_connection_list():
			if connection["from_node"] == node.name or connection["to_node"] == node.name:
				graph_edit.disconnect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
		
		# Remove from loaded resources if it's a root node
		if node.has_meta("resource_path"):
			var path = node.get_meta("resource_path")
			for i in range(_loaded_resources.size() - 1, -1, -1):
				if _loaded_resources[i].resource_path == path:
					_loaded_resources.remove_at(i)
		
		graph_edit.remove_child(node)
		node.queue_free()
	
	# Show placeholder if empty
	if _loaded_resources.is_empty():
		placeholder_label.visible = true

func _on_clear_pressed() -> void:
	_clear_graph()
	_loaded_resources.clear()
	placeholder_label.visible = true

func _on_graph_node_selected(node: Node) -> void:
	# Inspect resource in Godot inspector when node selected
	if node.has_meta("resource_path"):
		var path = node.get_meta("resource_path")
		var res = load(path)
		if res:
			EditorInterface.inspect_object(res)

func _add_resource_to_graph(res: Resource) -> void:
	placeholder_label.visible = false
	
	var type_name = _get_resource_type_name(res)
	var color = TYPE_COLORS.get(type_name, Color.WHITE)
	
	# Calculate position based on existing nodes
	var base_x = 50 + (_loaded_resources.size() - 1) * 300
	var root = _create_node(res.resource_path.get_file(), Vector2(base_x, 50), color)
	root.set_meta("resource_path", res.resource_path)
	
	# Specific rendering based on type
	match type_name:
		"Compose":
			_render_compose(res, root, base_x)
		"Item":
			_render_item(res, root, base_x)
		"Skill":
			_render_skill(res, root, base_x)

func _render_compose(compose: Compose, root: GraphNode, base_x: int) -> void:
	var y_offset = 0
	
	if not compose.move_rules.is_empty():
		var node = _create_node("Move States", Vector2(base_x + 250, 50 + y_offset), Color("#22c55e"))
		graph_edit.connect_node(root.name, 0, node.name, 0)
		_render_states_from_rules(compose.move_rules, Vector2(base_x + 500, 50 + y_offset), node)
		y_offset += 200
	
	if not compose.attack_rules.is_empty():
		var node = _create_node("Attack States", Vector2(base_x + 250, 50 + y_offset), Color("#ec4899"))
		graph_edit.connect_node(root.name, 0, node.name, 0)
		_render_states_from_rules(compose.attack_rules, Vector2(base_x + 500, 50 + y_offset), node)

func _render_states_from_rules(rules: Dictionary, base_pos: Vector2, parent: GraphNode) -> void:
	var state_y = 0
	for key in rules.keys():
		var states = rules[key]
		if states is Array:
			for state in states:
				if state is State:
					var node = _create_node(state.resource_path.get_file(), base_pos + Vector2(0, state_y), Color("#22c55e"))
					node.set_meta("resource_path", state.resource_path)
					graph_edit.connect_node(parent.name, 0, node.name, 0)
					state_y += 80

func _render_item(item: Item, root: GraphNode, base_x: int) -> void:
	if item.get("compose") and item.compose:
		var node = _create_node("Compose: " + item.compose.resource_path.get_file(), Vector2(base_x + 250, 100), Color("#f59e0b"))
		node.set_meta("resource_path", item.compose.resource_path)
		graph_edit.connect_node(root.name, 0, node.name, 0)

func _render_skill(skill: Skill, root: GraphNode, base_x: int) -> void:
	if skill.get("unlocks") and skill.unlocks:
		var y_offset = 0
		for state in skill.unlocks:
			if state is State:
				var node = _create_node(state.resource_path.get_file(), Vector2(base_x + 250, 100 + y_offset), Color("#22c55e"))
				node.set_meta("resource_path", state.resource_path)
				graph_edit.connect_node(root.name, 0, node.name, 0)
				y_offset += 80

func _clear_graph() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			graph_edit.remove_child(child)
			child.queue_free()

func _create_node(title: String, position: Vector2, color: Color = Color.WHITE) -> GraphNode:
	var node = GraphNode.new()
	node.name = "Node_%d" % _node_counter
	_node_counter += 1
	node.title = title
	node.position_offset = position
	node.resizable = true
	node.selectable = true
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
