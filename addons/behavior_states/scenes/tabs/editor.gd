@tool
## Visual Blueprint Editor
##
## Editor visual para montar recursos usando blocos componentes.
extends MarginContainer

# Tipos e seus blocos correspondentes
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
	"SkillTree": Color("#a855f7"),
	"FilterBlock": Color("#64748b"),
	"ActionBlock": Color("#ef4444"),
	"TriggerBlock": Color("#f97316"),
	"ModifierBlock": Color("#06b6d4"),
	"PropertyBlock": Color("#84cc16"),
	"RequirementBlock": Color("#eab308"),
	"UnlockBlock": Color("#8b5cf6")
}

@onready var block_list: ItemList = $VBoxContainer/HSplitContainer/Sidebar/BlockList
@onready var search_edit: LineEdit = $VBoxContainer/HSplitContainer/Sidebar/SearchEdit
@onready var graph_edit: GraphEdit = $VBoxContainer/HSplitContainer/VBoxContainer/GraphContainer/GraphEdit
@onready var placeholder_label: Label = $VBoxContainer/HSplitContainer/VBoxContainer/GraphContainer/GraphEdit/PlaceholderLabel
@onready var file_dialog: FileDialog = $FileDialog
@onready var current_file_label: Label = $VBoxContainer/Footer/CurrentFileLabel
@onready var save_btn: Button = $VBoxContainer/Footer/SaveBtn
@onready var cancel_btn: Button = $VBoxContainer/Footer/CancelBtn

var _selected_type: String = ""
var _current_resource: Resource = null
var _current_path: String = ""
var _node_counter: int = 0
var _is_dirty: bool = false
var _context_menu: PopupMenu
var _new_type_menu: PopupMenu
var _context_position: Vector2 = Vector2.ZERO
var _pending_new_type: String = ""

func _ready() -> void:
	# Graph connections
	graph_edit.add_valid_connection_type(0, 0)
	graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	
	# Right-click context menu
	_setup_context_menu()
	graph_edit.gui_input.connect(_on_graph_gui_input)
	
	# Drag & drop from sidebar
	block_list.set_drag_forwarding(_get_drag_data_fw, Callable(), Callable())
	
	# Type selection popup for New button
	_setup_new_type_menu()

func _setup_context_menu() -> void:
	_context_menu = PopupMenu.new()
	_context_menu.name = "ContextMenu"
	add_child(_context_menu)
	_context_menu.id_pressed.connect(_on_context_menu_id_pressed)

func _setup_new_type_menu() -> void:
	_new_type_menu = PopupMenu.new()
	_new_type_menu.name = "NewTypeMenu"
	add_child(_new_type_menu)
	
	var types = ["State", "Item", "Skill", "Compose", "Inventory", "SkillTree"]
	for i in range(types.size()):
		_new_type_menu.add_item(types[i], i)
	
	_new_type_menu.id_pressed.connect(_on_new_type_selected)

func _on_new_type_selected(id: int) -> void:
	var types = ["State", "Item", "Skill", "Compose", "Inventory", "SkillTree"]
	if id < types.size():
		_pending_new_type = types[id]
		_selected_type = _pending_new_type
		_update_sidebar()
		# Open FileDialog to save
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(_pending_new_type, "*.tres")])
		file_dialog.current_file = "new_" + _pending_new_type.to_lower() + ".tres"
		file_dialog.title = "Salvar novo " + _pending_new_type
		file_dialog.popup_centered_ratio(0.6)

func _update_context_menu() -> void:
	_context_menu.clear()
	
	if _selected_type.is_empty():
		return
	
	# Add blocks for current type
	if _selected_type in TYPE_BLOCKS:
		_context_menu.add_separator("Criar Bloco")
		var blocks = TYPE_BLOCKS[_selected_type]
		for i in range(blocks.size()):
			_context_menu.add_item(blocks[i], i)

func _on_graph_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_context_position = mb.position + graph_edit.scroll_offset
			_update_context_menu()
			_context_menu.position = Vector2i(get_global_mouse_position())
			_context_menu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
	if _selected_type in TYPE_BLOCKS:
		var blocks = TYPE_BLOCKS[_selected_type]
		if id < blocks.size():
			_create_block_node(blocks[id], _context_position)

func _get_drag_data_fw(at_position: Vector2) -> Variant:
	var selected = block_list.get_selected_items()
	if selected.is_empty():
		return null
	
	var block_name = block_list.get_item_text(selected[0])
	
	# Create drag preview
	var preview = Label.new()
	preview.text = block_name
	preview.add_theme_color_override("font_color", TYPE_COLORS.get(block_name, Color.WHITE))
	set_drag_preview(preview)
	
	return {"type": "block", "block_name": block_name}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.get("type") == "block":
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.get("type") == "block":
		var block_name = data.get("block_name")
		var drop_pos = graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
		_create_block_node(block_name, drop_pos)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		pass

func _on_type_selected(type_name: String) -> void:
	_selected_type = type_name
	_update_sidebar()
	_update_context_menu()
	
	# Abre FileDialog
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(type_name, "*.tres")])
	file_dialog.title = "Selecionar " + type_name
	file_dialog.popup_centered_ratio(0.6)

func _on_new_pressed() -> void:
	if _selected_type.is_empty():
		# Show type selection popup
		_new_type_menu.position = Vector2i(get_global_mouse_position())
		_new_type_menu.popup()
		return
	
	# Open FileDialog to save new resource
	_pending_new_type = _selected_type
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(_selected_type, "*.tres")])
	file_dialog.current_file = "new_" + _selected_type.to_lower() + ".tres"
	file_dialog.title = "Salvar novo " + _selected_type
	file_dialog.popup_centered_ratio(0.6)

func _on_file_dialog_pressed() -> void:
	if _selected_type.is_empty():
		return
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(_selected_type, "*.tres")])
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	# Check if this is a new resource creation or loading existing
	if not _pending_new_type.is_empty():
		# Creating new resource
		var new_res = _create_resource_for_type(_pending_new_type)
		if new_res:
			var err = ResourceSaver.save(new_res, path)
			if err == OK:
				print("Created " + _pending_new_type + " at " + path)
				_load_resource_to_graph(new_res, path)
				EditorInterface.edit_resource(new_res)
			else:
				printerr("Error saving resource: ", err)
		_pending_new_type = ""
		return
	
	# Loading existing resource
	var res = load(path)
	if res:
		_load_resource_to_graph(res, path)

func _on_save_pressed() -> void:
	if not _current_resource:
		return
	
	if _current_path.is_empty():
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
	
	if _selected_type in TYPE_ASSETS:
		var asset_type = TYPE_ASSETS[_selected_type]
		file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(asset_type, "*.tres")])
		file_dialog.title = "Adicionar " + asset_type
		file_dialog.popup_centered_ratio(0.6)
	else:
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
	
	if _selected_type in TYPE_BLOCKS:
		items = TYPE_BLOCKS[_selected_type]
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
	
	var color = TYPE_COLORS.get(_selected_type, Color.WHITE)
	var root = _create_graph_node(res.get("name") if "name" in res else _selected_type, Vector2(100, 100), color)
	root.set_meta("resource", res)
	root.set_meta("is_root", true)
	
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
	var color = TYPE_COLORS.get(block_type, Color.GRAY)
	var node = _create_graph_node(block_type, position, color)
	node.set_meta("block_type", block_type)
	
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
