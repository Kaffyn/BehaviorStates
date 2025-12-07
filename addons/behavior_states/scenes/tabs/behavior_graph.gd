@tool
## Visualizador de Comportamentos (Behavior Graph).
##
## Exibe as relações entre Items, Skills e CharacterSheet.
extends GraphEdit

@onready var file_dialog: FileDialog = $FileDialog

var _load_mode: String = "item"

func _ready() -> void:
	right_disconnects = true
	add_valid_connection_type(0, 0)

func _on_load_item_pressed() -> void:
	_load_mode = "item"
	file_dialog.filters = PackedStringArray(["*.tres ; Item"])
	file_dialog.popup_centered_ratio(0.6)

func _on_load_skill_pressed() -> void:
	_load_mode = "skill"
	file_dialog.filters = PackedStringArray(["*.tres ; Skill"])
	file_dialog.popup_centered_ratio(0.6)

func _on_file_dialog_file_selected(path: String) -> void:
	var res = load(path)
	if not res:
		printerr("Não foi possível carregar o arquivo.")
		return
	
	match _load_mode:
		"item":
			if res is Item:
				_visualize_item(res)
		"skill":
			if res is Skill:
				_visualize_skill(res)

func _visualize_item(item: Item) -> void:
	_clear_graph()
	
	# Item node
	var item_node = _create_node("Item: " + item.resource_path.get_file(), Vector2(50, 100), Color("#8da5f3"))
	
	# Se tiver Compose associado
	if item.get("compose") and item.compose:
		var compose_node = _create_node("Compose: " + item.compose.resource_path.get_file(), Vector2(300, 100), Color("#ffca5f"))
		connect_node(item_node.name, 0, compose_node.name, 0)

func _visualize_skill(skill: Skill) -> void:
	_clear_graph()
	
	# Skill node
	var skill_node = _create_node("Skill: " + skill.resource_path.get_file(), Vector2(50, 100), Color("#ff8ccc"))
	
	# Visualizar states unlockados (se tiver propriedade)
	if skill.get("unlocks") and skill.unlocks:
		var y_offset = 0
		for state in skill.unlocks:
			if state is State:
				var state_node = _create_node(state.resource_path.get_file(), Vector2(300, 100 + y_offset), Color("#8eef97"))
				connect_node(skill_node.name, 0, state_node.name, 0)
				y_offset += 80

func _clear_graph() -> void:
	clear_connections()
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()

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
