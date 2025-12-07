@tool
## Visualizador de Estados (State Graph).
##
## Exibe os States de um Compose como nós em um grafo visual.
extends GraphEdit

@onready var file_dialog: FileDialog = $FileDialog

var current_manifest: Compose

func _ready() -> void:
	right_disconnects = true
	add_valid_connection_type(0, 0)
	
func _on_load_pressed() -> void:
	file_dialog.popup_centered_ratio(0.6)

func _on_file_dialog_file_selected(path: String) -> void:
	var res = load(path)
	if res and res is Compose:
		load_manifest(res)
	else:
		printerr("Arquivo não é um Compose.")

func load_manifest(manifest: Compose) -> void:
	current_manifest = manifest
	clear_connections()
	
	# Remove nós existentes
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()
	
	var root_node = _create_node("Compose: " + manifest.resource_path.get_file(), Vector2(50, 50), Color("#ffca5f"))
	
	var y_offset = 0
	
	# Visualizar Move Rules
	if not manifest.move_rules.is_empty():
		var bucket_node = _create_node("Move States", Vector2(300, 50 + y_offset), Color("#8eef97"))
		connect_node(root_node.name, 0, bucket_node.name, 0)
		_create_state_nodes(manifest.move_rules, Vector2(550, 50 + y_offset), bucket_node)
		y_offset += 200
		
	# Visualizar Attack Rules
	if not manifest.attack_rules.is_empty():
		var bucket_node = _create_node("Attack States", Vector2(300, 50 + y_offset), Color("#ff8ccc"))
		connect_node(root_node.name, 0, bucket_node.name, 0)
		_create_state_nodes(manifest.attack_rules, Vector2(550, 50 + y_offset), bucket_node)
		y_offset += 200

func _create_state_nodes(rules: Dictionary, base_pos: Vector2, parent_node: GraphNode) -> void:
	var state_y = 0
	for key in rules.keys():
		var states = rules[key]
		if states is Array:
			for state in states:
				if state is State:
					var node = _create_node(state.resource_path.get_file(), base_pos + Vector2(0, state_y), Color("#8da5f3"))
					connect_node(parent_node.name, 0, node.name, 0)
					state_y += 80

func _create_node(title: String, position: Vector2, color: Color = Color.WHITE) -> GraphNode:
	var node = GraphNode.new()
	node.title = title
	node.position_offset = position
	node.resizable = true
	node.set_slot(0, true, 0, color, true, 0, color)
	add_child(node)
	
	var label = Label.new()
	label.text = " "
	node.add_child(label)
	
	return node
