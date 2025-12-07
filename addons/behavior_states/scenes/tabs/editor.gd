@tool
## Visual Blueprint Editor
##
## Editor visual para montar recursos usando blocos componentes.
extends MarginContainer

# Tipos e seus blocos/assets correspondentes
const TYPE_BLOCKS = {
	"State": ["FilterBlock", "ActionBlock", "TriggerBlock"],
	"Item": ["ModifierBlock", "PropertyBlock"],
	"Skill": ["RequirementBlock", "UnlockBlock"]
}

const TYPE_ASSETS = {
	"Compose": "State",
	"Inventory": "Item",
	"SkillTree": "Skill"
}

const TYPE_FILTERS = {
	"State": "*.tres ; State",
	"Item": "*.tres ; Item",
	"Skill": "*.tres ; Skill",
	"Compose": "*.tres ; Compose",
	"Inventory": "*.tres ; InventoryData",
	"SkillTree": "*.tres ; SkillTree"
}

const TYPE_COLORS = {
	"State": Color("#22c55e"),
	"Item": Color("#3b82f6"),
	"Skill": Color("#ec4899"),
	"Compose": Color("#f59e0b"),
	"Inventory": Color("#8b5cf6"),
	"SkillTree": Color("#a855f7")
}

@onready var block_list: ItemList = $VBoxContainer/HSplitContainer/Sidebar/BlockList
@onready var search_edit: LineEdit = $VBoxContainer/HSplitContainer/Sidebar/SearchEdit
@onready var graph_edit: GraphEdit = $VBoxContainer/HSplitContainer/GraphContainer/GraphEdit
@onready var placeholder_label: Label = $VBoxContainer/HSplitContainer/GraphContainer/GraphEdit/PlaceholderLabel
@onready var file_dialog: FileDialog = $FileDialog
@onready var current_file_label: Label = $VBoxContainer/Footer/CurrentFileLabel
@onready var save_btn: Button = $VBoxContainer/Footer/SaveBtn
@onready var cancel_btn: Button = $VBoxContainer/Footer/CancelBtn

var _selected_type: String = ""
var _current_resource: Resource = null
var _current_path: String = ""
var _node_counter: int = 0
var _is_dirty: bool = false

func _ready() -> void:
	graph_edit.add_valid_connection_type(0, 0)
	graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)

func _on_type_selected(type_name: String) -> void:
	_selected_type = type_name
	_update_sidebar()
	
	# Abre FileDialog para selecionar resource
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(type_name, "*.tres")])
	file_dialog.title = "Selecionar " + type_name
	file_dialog.popup_centered_ratio(0.6)

func _on_new_pressed() -> void:
	if _selected_type.is_empty():
		return
	
	# Cria novo resource do tipo selecionado
	var new_res = _create_resource_for_type(_selected_type)
	if new_res:
		_load_resource_to_graph(new_res, "")
		_is_dirty = true
		_update_footer()

func _on_file_dialog_pressed() -> void:
	if _selected_type.is_empty():
		return
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(_selected_type, "*.tres")])
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	var res = load(path)
	if res:
		_load_resource_to_graph(res, path)

func _on_save_pressed() -> void:
	if not _current_resource:
		return
	
	if _current_path.is_empty():
		# Novo arquivo - pedir para salvar
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.popup_centered_ratio(0.6)
	else:
		_save_resource()

func _on_cancel_pressed() -> void:
	_clear_editor()

func _on_search_changed(text: String) -> void:
	_update_sidebar(text)

func _on_block_activated(index: int) -> void:
	if not _current_resource:
		return
	
	var block_name = block_list.get_item_text(index)
	
	# Se é um asset (State, Item, Skill), abre FileDialog
	if _selected_type in TYPE_ASSETS:
		var asset_type = TYPE_ASSETS[_selected_type]
		file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(asset_type, "*.tres")])
		file_dialog.title = "Adicionar " + asset_type
		file_dialog.popup_centered_ratio(0.6)
	else:
		# É um bloco, cria node no graph
		_create_block_node(block_name, _get_spawn_position())

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	_is_dirty = true
	_update_footer()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	_is_dirty = true
	_update_footer()

func _update_sidebar(filter: String = "") -> void:
	block_list.clear()
	
	if _selected_type.is_empty():
		return
	
	var items: Array = []
	
	# Blocos para State/Item/Skill
	if _selected_type in TYPE_BLOCKS:
		items = TYPE_BLOCKS[_selected_type]
	# Assets para Compose/Inventory/SkillTree
	elif _selected_type in TYPE_ASSETS:
		items = _scan_assets_for_type(TYPE_ASSETS[_selected_type])
	
	for item in items:
		if filter.is_empty() or filter.to_lower() in str(item).to_lower():
			block_list.add_item(str(item))

func _scan_assets_for_type(type_name: String) -> Array:
	var assets: Array = []
	var dir = DirAccess.open("res://")
	if dir:
		assets = _scan_directory_recursive(dir, "res://", type_name)
	return assets

func _scan_directory_recursive(dir: DirAccess, base_path: String, type_name: String) -> Array:
	var results: Array = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = base_path.path_join(file_name)
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			var sub_dir = DirAccess.open(full_path)
			if sub_dir:
				results.append_array(_scan_directory_recursive(sub_dir, full_path, type_name))
		elif file_name.ends_with(".tres"):
			var res = load(full_path)
			if res and res.get_class() == type_name:
				results.append(full_path.get_file())
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return results

func _load_resource_to_graph(res: Resource, path: String) -> void:
	_clear_graph()
	
	_current_resource = res
	_current_path = path
	placeholder_label.visible = false
	
	# Cria nó raiz
	var color = TYPE_COLORS.get(_selected_type, Color.WHITE)
	var root = _create_graph_node(res.get("name") if "name" in res else _selected_type, Vector2(100, 100), color)
	root.set_meta("resource", res)
	root.set_meta("is_root", true)
	
	# Carrega children baseado no tipo
	_load_children_for_resource(res, root)
	
	_update_footer()

func _load_children_for_resource(res: Resource, parent_node: GraphNode) -> void:
	var x_offset = 350
	var y_offset = 0
	
	match _selected_type:
		"Compose":
			for state in res.get("move_states") if res.get("move_states") else []:
				if state:
					var node = _create_graph_node(state.name, Vector2(x_offset, 50 + y_offset), TYPE_COLORS["State"])
					node.set_meta("resource", state)
					graph_edit.connect_node(parent_node.name, 0, node.name, 0)
					y_offset += 80
			for state in res.get("attack_states") if res.get("attack_states") else []:
				if state:
					var node = _create_graph_node(state.name, Vector2(x_offset, 50 + y_offset), TYPE_COLORS["State"])
					node.set_meta("resource", state)
					graph_edit.connect_node(parent_node.name, 0, node.name, 0)
					y_offset += 80
		
		"Inventory":
			for item in res.get("items") if res.get("items") else []:
				if item:
					var node = _create_graph_node(item.name, Vector2(x_offset, 50 + y_offset), TYPE_COLORS["Item"])
					node.set_meta("resource", item)
					graph_edit.connect_node(parent_node.name, 0, node.name, 0)
					y_offset += 80
		
		"SkillTree":
			for skill in res.get("skills") if res.get("skills") else []:
				if skill:
					var node = _create_graph_node(skill.name, Vector2(x_offset, 50 + y_offset), TYPE_COLORS["Skill"])
					node.set_meta("resource", skill)
					graph_edit.connect_node(parent_node.name, 0, node.name, 0)
					y_offset += 80

func _create_graph_node(title: String, position: Vector2, color: Color) -> GraphNode:
	var node = GraphNode.new()
	node.name = "Node_%d" % _node_counter
	_node_counter += 1
	node.title = title
	node.position_offset = position
	node.resizable = true
	node.set_slot(0, true, 0, color, true, 0, color)
	
	var label = Label.new()
	label.text = " "
	node.add_child(label)
	
	graph_edit.add_child(node)
	return node

func _create_block_node(block_type: String, position: Vector2) -> GraphNode:
	var color = TYPE_COLORS.get(_selected_type, Color.WHITE)
	var node = _create_graph_node(block_type, position, color)
	node.set_meta("block_type", block_type)
	
	# Adiciona campos inline
	match block_type:
		"FilterBlock":
			_add_filter_fields(node)
		"ActionBlock":
			_add_action_fields(node)
		"TriggerBlock":
			_add_trigger_fields(node)
		"ModifierBlock":
			_add_modifier_fields(node)
		"PropertyBlock":
			_add_property_fields(node)
		"RequirementBlock":
			_add_requirement_fields(node)
		"UnlockBlock":
			_add_unlock_fields(node)
	
	_is_dirty = true
	_update_footer()
	return node

func _add_filter_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Filtro:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var option = OptionButton.new()
	option.add_item("Physics")
	option.add_item("Motion")
	option.add_item("Attack")
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	node.add_child(row)

func _add_action_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Ação:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var option = OptionButton.new()
	option.add_item("Damage")
	option.add_item("Heal")
	option.add_item("Spawn")
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	node.add_child(row)

func _add_trigger_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Gatilho:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var option = OptionButton.new()
	option.add_item("OnEnter")
	option.add_item("OnExit")
	option.add_item("OnHit")
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	node.add_child(row)

func _add_modifier_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Atributo:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var edit = LineEdit.new()
	edit.placeholder_text = "damage, speed..."
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	node.add_child(row)

func _add_property_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Prop:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var edit = LineEdit.new()
	edit.placeholder_text = "chave"
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	node.add_child(row)

func _add_requirement_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Requer:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var option = OptionButton.new()
	option.add_item("Level")
	option.add_item("Skill")
	option.add_item("Item")
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	node.add_child(row)

func _add_unlock_fields(node: GraphNode) -> void:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Tipo:"
	label.custom_minimum_size.x = 60
	row.add_child(label)
	var option = OptionButton.new()
	option.add_item("State")
	option.add_item("Ability")
	option.add_item("Passive")
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)
	node.add_child(row)

func _create_resource_for_type(type_name: String) -> Resource:
	match type_name:
		"State": return State.new()
		"Item": return Item.new()
		"Skill": return Skill.new()
		"Compose": return Compose.new()
		"Inventory": return InventoryData.new()
		"SkillTree": return SkillTree.new()
	return null

func _save_resource() -> void:
	if _current_resource and not _current_path.is_empty():
		ResourceSaver.save(_current_resource, _current_path)
		_is_dirty = false
		_update_footer()

func _clear_graph() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()

func _clear_editor() -> void:
	_clear_graph()
	_current_resource = null
	_current_path = ""
	_is_dirty = false
	placeholder_label.visible = true
	_update_footer()

func _update_footer() -> void:
	if _current_path.is_empty():
		current_file_label.text = "Novo " + _selected_type if _current_resource else "Nenhum arquivo aberto"
	else:
		current_file_label.text = _current_path.get_file() + (" *" if _is_dirty else "")
	
	save_btn.disabled = not _current_resource
	cancel_btn.disabled = not _current_resource

func _get_spawn_position() -> Vector2:
	return Vector2(150 + randf() * 200, 150 + randf() * 150)
