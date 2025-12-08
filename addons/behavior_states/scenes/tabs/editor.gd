@tool
## Visual Blueprint Editor
##
## Editor visual completo para montar recursos usando blocos componentes.
## Suporta State, Item, Skill (block-based) e Compose, Inventory, SkillTree (containers).
extends MarginContainer

const BlockDefs = preload("res://addons/behavior_states/scenes/tabs/block_definitions.gd")

# Tipos block-based vs containers
const BLOCK_TYPES = ["State", "Item", "Skill"]
const CONTAINER_TYPES = ["Compose", "Inventory", "SkillTree"]

const CONTAINER_CHILD_TYPE = {
	"Compose": "State",
	"Inventory": "Item", 
	"SkillTree": "Skill"
}

const TYPE_COLORS = {
	"State": Color("#22c55e"),
	"Item": Color("#3b82f6"),
	"Skill": Color("#ec4899"),
	"Compose": Color("#f59e0b"),
	"Inventory": Color("#8b5cf6"),
	"SkillTree": Color("#a855f7")
}

const TYPE_FILTERS = {
	"State": "*.tres",
	"Item": "*.tres",
	"Skill": "*.tres",
	"Compose": "*.tres",
	"Inventory": "*.tres",
	"SkillTree": "*.tres"
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
var _pending_new_type: String = ""
var _root_node: GraphNode = null

# Maps GraphNode name -> block data
var _block_nodes: Dictionary = {}

func _ready() -> void:
	# Graph setup
	graph_edit.add_valid_connection_type(0, 0)
	graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	graph_edit.block_dropped.connect(_on_block_dropped)
	
	# Context menu
	_setup_context_menu()
	graph_edit.gui_input.connect(_on_graph_gui_input)
	
	# Drag from sidebar
	block_list.set_drag_forwarding(_get_drag_data_fw, Callable(), Callable())
	
	# New type menu
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
	
	var types = BLOCK_TYPES + CONTAINER_TYPES
	for i in range(types.size()):
		_new_type_menu.add_item(types[i], i)
	
	_new_type_menu.id_pressed.connect(_on_new_type_selected)

# ==================== SIDEBAR ====================

func _update_sidebar(filter: String = "") -> void:
	block_list.clear()
	
	if _selected_type.is_empty():
		return
	
	var items: Array = []
	
	if _selected_type in BLOCK_TYPES:
		items = BlockDefs.get_block_names_for_type(_selected_type)
	elif _selected_type in CONTAINER_TYPES:
		items = _scan_assets_for_type(CONTAINER_CHILD_TYPE[_selected_type])
	
	for item in items:
		if filter.is_empty() or filter.to_lower() in str(item).to_lower():
			block_list.add_item(str(item))

func _scan_assets_for_type(type_name: String) -> Array:
	var results: Array = []
	var base_path = "res://addons/behavior_states/data/"
	var dir = DirAccess.open(base_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path = base_path + file_name
				var res = load(full_path)
				if res and res.get_class() == type_name:
					results.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return results

# ==================== GRAPH OPERATIONS ====================

func _clear_graph() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()
	_block_nodes.clear()
	_root_node = null
	_node_counter = 0

func _create_root_node(res: Resource) -> GraphNode:
	var title = res.get("name") if "name" in res else _selected_type
	var color = TYPE_COLORS.get(_selected_type, Color.WHITE)
	
	var node = GraphNode.new()
	node.name = "RootNode"
	node.title = title
	node.position_offset = Vector2(50, 50)
	node.set_slot(0, false, 0, color, true, 0, color)
	
	# Add editable name field for root
	var name_row = HBoxContainer.new()
	var name_label = Label.new()
	name_label.text = "Nome:"
	name_label.custom_minimum_size.x = 60
	name_row.add_child(name_label)
	var name_edit = LineEdit.new()
	name_edit.text = str(title)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(func(t): _on_root_name_changed(t))
	name_row.add_child(name_edit)
	node.add_child(name_row)
	
	graph_edit.add_child(node)
	_root_node = node
	return node

func _create_block_node(block_name: String, position: Vector2) -> GraphNode:
	if _selected_type.is_empty() or not _current_resource:
		return null
	
	var blocks = BlockDefs.get_blocks_for_type(_selected_type)
	if not block_name in blocks:
		return null
	
	var block_def = blocks[block_name]
	var color = block_def.get("color", Color.WHITE)
	
	var node = GraphNode.new()
	node.name = "Block_%d" % _node_counter
	_node_counter += 1
	node.title = block_name
	node.position_offset = position
	node.resizable = true
	node.set_slot(0, true, 0, color, true, 0, color)
	
	# Generate fields from definition
	var fields = block_def.get("fields", [])
	for field in fields:
		var row = _create_field_row(field)
		if row:
			node.add_child(row)
	
	graph_edit.add_child(node)
	
	# Connect to root
	if _root_node:
		graph_edit.connect_node(_root_node.name, 0, node.name, 0)
	
	_block_nodes[node.name] = {"block_name": block_name, "node": node}
	_is_dirty = true
	_update_footer()
	
	return node

func _create_field_row(field: Dictionary) -> Control:
	var row = HBoxContainer.new()
	row.custom_minimum_size.y = 24
	
	var label = Label.new()
	label.text = field.name.capitalize() + ":"
	label.custom_minimum_size.x = 100
	row.add_child(label)
	
	var field_name = field.name
	var field_type = field.type
	var default_val = field.get("default", null)
	
	# Get current value from resource
	var current_val = _current_resource.get(field_name) if field_name in _current_resource else default_val
	
	match field_type:
		"String":
			var edit = LineEdit.new()
			edit.text = str(current_val) if current_val else ""
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			edit.text_changed.connect(func(t): _on_field_changed(field_name, t))
			row.add_child(edit)
		
		"int":
			var spin = SpinBox.new()
			spin.value = int(current_val) if current_val else 0
			spin.min_value = -9999
			spin.max_value = 9999
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.value_changed.connect(func(v): _on_field_changed(field_name, int(v)))
			row.add_child(spin)
		
		"float":
			var spin = SpinBox.new()
			spin.value = float(current_val) if current_val else 0.0
			spin.min_value = -9999.0
			spin.max_value = 9999.0
			spin.step = 0.1
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.value_changed.connect(func(v): _on_field_changed(field_name, v))
			row.add_child(spin)
		
		"bool":
			var check = CheckBox.new()
			check.button_pressed = bool(current_val) if current_val else false
			check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			check.toggled.connect(func(v): _on_field_changed(field_name, v))
			row.add_child(check)
		
		"enum":
			var option = OptionButton.new()
			var options = field.get("options", [])
			for opt in options:
				option.add_item(opt)
			option.selected = int(current_val) if current_val else 0
			option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			option.item_selected.connect(func(idx): _on_field_changed(field_name, idx))
			row.add_child(option)
		
		"Color":
			var picker = ColorPickerButton.new()
			picker.color = current_val if current_val else Color.WHITE
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.color_changed.connect(func(c): _on_field_changed(field_name, c))
			row.add_child(picker)
		
		"Vector2":
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var vec = current_val if current_val else Vector2.ZERO
			
			var x_spin = SpinBox.new()
			x_spin.value = vec.x
			x_spin.min_value = -9999
			x_spin.max_value = 9999
			x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			x_spin.value_changed.connect(func(v): _on_vector2_changed(field_name, "x", v))
			hbox.add_child(x_spin)
			
			var y_spin = SpinBox.new()
			y_spin.value = vec.y
			y_spin.min_value = -9999
			y_spin.max_value = 9999
			y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			y_spin.value_changed.connect(func(v): _on_vector2_changed(field_name, "y", v))
			hbox.add_child(y_spin)
			
			row.add_child(hbox)
		
		"Dictionary":
			var btn = Button.new()
			btn.text = "Editar..."
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(btn)
		
		_:
			var placeholder = Label.new()
			placeholder.text = "[" + field_type + "]"
			placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(placeholder)
	
	return row

func _on_field_changed(field_name: String, value: Variant) -> void:
	if _current_resource and field_name in _current_resource:
		_current_resource.set(field_name, value)
		_is_dirty = true
		_update_footer()

func _on_vector2_changed(field_name: String, component: String, value: float) -> void:
	if _current_resource and field_name in _current_resource:
		var vec = _current_resource.get(field_name)
		if vec is Vector2:
			if component == "x":
				vec.x = value
			else:
				vec.y = value
			_current_resource.set(field_name, vec)
			_is_dirty = true
			_update_footer()

func _on_root_name_changed(new_name: String) -> void:
	if _current_resource and "name" in _current_resource:
		_current_resource.name = new_name
		if _root_node:
			_root_node.title = new_name
		_is_dirty = true
		_update_footer()

# ==================== LOAD / SAVE ====================

func _load_resource_to_graph(res: Resource, path: String) -> void:
	_clear_graph()
	
	_current_resource = res
	_current_path = path
	placeholder_label.visible = false
	
	_create_root_node(res)
	
	# For block-based types, create blocks for non-default values
	if _selected_type in BLOCK_TYPES:
		_load_blocks_for_resource(res)
	elif _selected_type in CONTAINER_TYPES:
		_load_children_for_container(res)
	
	_is_dirty = path.is_empty()  # New resources are dirty
	_update_footer()

func _load_blocks_for_resource(res: Resource) -> void:
	var blocks = BlockDefs.get_blocks_for_type(_selected_type)
	var x_offset = 350
	var y_offset = 50
	
	for block_name in blocks.keys():
		var block_def = blocks[block_name]
		var has_values = false
		
		# Check if any field has non-default value
		for field in block_def.get("fields", []):
			var field_name = field.name
			if field_name in res:
				var current = res.get(field_name)
				var default = field.get("default")
				if current != default:
					has_values = true
					break
		
		if has_values:
			_create_block_node(block_name, Vector2(x_offset, y_offset))
			y_offset += 120

func _load_children_for_container(res: Resource) -> void:
	var x_offset = 350
	var y_offset = 50
	var child_color = TYPE_COLORS.get(CONTAINER_CHILD_TYPE.get(_selected_type, ""), Color.WHITE)
	
	var children: Array = []
	match _selected_type:
		"Compose":
			children.append_array(res.get("move_states") if res.get("move_states") else [])
			children.append_array(res.get("attack_states") if res.get("attack_states") else [])
			children.append_array(res.get("interactive_states") if res.get("interactive_states") else [])
		"Inventory":
			children = res.get("items") if res.get("items") else []
		"SkillTree":
			children = res.get("skills") if res.get("skills") else []
	
	for child in children:
		if child:
			var node = GraphNode.new()
			node.name = "Child_%d" % _node_counter
			_node_counter += 1
			node.title = child.get("name") if "name" in child else "Child"
			node.position_offset = Vector2(x_offset, y_offset)
			node.set_slot(0, true, 0, child_color, false, 0, child_color)
			
			var label = Label.new()
			label.text = child.resource_path.get_file() if child.resource_path else "inline"
			node.add_child(label)
			
			graph_edit.add_child(node)
			
			if _root_node:
				graph_edit.connect_node(_root_node.name, 0, node.name, 0)
			
			y_offset += 80

func _save_resource() -> void:
	if not _current_resource or _current_path.is_empty():
		return
	
	var err = ResourceSaver.save(_current_resource, _current_path)
	if err == OK:
		print("[Editor] Saved: " + _current_path)
		_is_dirty = false
		_update_footer()
	else:
		printerr("[Editor] Error saving: " + str(err))

# ==================== UI HANDLERS ====================

func _on_type_selected(type_name: String) -> void:
	_selected_type = type_name
	_pending_new_type = ""
	_update_sidebar()
	
	# Open file dialog to select existing
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(type_name, "*.tres")])
	file_dialog.title = "Abrir " + type_name
	file_dialog.popup_centered_ratio(0.6)

func _on_new_pressed() -> void:
	if _selected_type.is_empty():
		_new_type_menu.position = Vector2i(get_global_mouse_position())
		_new_type_menu.popup()
		return
	
	_pending_new_type = _selected_type
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(_selected_type, "*.tres")])
	file_dialog.current_file = "new_" + _selected_type.to_lower() + ".tres"
	file_dialog.title = "Salvar novo " + _selected_type
	file_dialog.popup_centered_ratio(0.6)

func _on_new_type_selected(id: int) -> void:
	var types = BLOCK_TYPES + CONTAINER_TYPES
	if id < types.size():
		_selected_type = types[id]
		_pending_new_type = _selected_type
		_update_sidebar()
		
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = PackedStringArray([TYPE_FILTERS.get(_selected_type, "*.tres")])
		file_dialog.current_file = "new_" + _selected_type.to_lower() + ".tres"
		file_dialog.title = "Salvar novo " + _selected_type
		file_dialog.popup_centered_ratio(0.6)

func _on_file_dialog_pressed() -> void:
	# Open file dialog directly - type will be detected from loaded resource
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = PackedStringArray(["*.tres"])
	file_dialog.title = "Abrir Resource"
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	if not _pending_new_type.is_empty():
		# Creating new
		var new_res = _create_resource_for_type(_pending_new_type)
		if new_res:
			var err = ResourceSaver.save(new_res, path)
			if err == OK:
				print("[Editor] Created: " + path)
				_load_resource_to_graph(new_res, path)
				EditorInterface.edit_resource(new_res)
		_pending_new_type = ""
		return
	
	# Loading existing
	var res = load(path)
	if res:
		# Auto-detect type from resource class
		_selected_type = _detect_resource_type(res)
		_update_sidebar()
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
	_clear_graph()
	_current_resource = null
	_current_path = ""
	_is_dirty = false
	placeholder_label.visible = true
	_update_footer()

func _on_search_changed(text: String) -> void:
	_update_sidebar(text)

func _on_block_activated(index: int) -> void:
	var block_name = block_list.get_item_text(index)
	
	if _selected_type in BLOCK_TYPES:
		_create_block_node(block_name, Vector2(350, 50 + randf() * 200))
	elif _selected_type in CONTAINER_TYPES:
		# Load child resource
		var child_path = "res://addons/behavior_states/data/" + block_name
		var child_res = load(child_path)
		if child_res:
			_add_child_to_container(child_res)

func _add_child_to_container(child_res: Resource) -> void:
	if not _current_resource:
		return
	
	match _selected_type:
		"Compose":
			var arr = _current_resource.get("move_states")
			if arr != null:
				arr.append(child_res)
		"Inventory":
			var arr = _current_resource.get("items")
			if arr != null:
				arr.append(child_res)
		"SkillTree":
			var arr = _current_resource.get("skills")
			if arr != null:
				arr.append(child_res)
	
	# Reload graph
	_load_resource_to_graph(_current_resource, _current_path)
	_is_dirty = true

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	_is_dirty = true
	_update_footer()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	_is_dirty = true
	_update_footer()

func _on_block_dropped(block_name: String, position: Vector2) -> void:
	if _selected_type in BLOCK_TYPES:
		_create_block_node(block_name, position)

func _on_graph_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_update_context_menu()
			_context_menu.position = Vector2i(get_global_mouse_position())
			_context_menu.popup()

func _update_context_menu() -> void:
	_context_menu.clear()
	
	if _selected_type.is_empty() or not _selected_type in BLOCK_TYPES:
		return
	
	_context_menu.add_separator("Adicionar Bloco")
	var blocks = BlockDefs.get_block_names_for_type(_selected_type)
	for i in range(blocks.size()):
		_context_menu.add_item(blocks[i], i)

func _on_context_menu_id_pressed(id: int) -> void:
	var blocks = BlockDefs.get_block_names_for_type(_selected_type)
	if id < blocks.size():
		var pos = graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
		_create_block_node(blocks[id], pos)

func _get_drag_data_fw(at_position: Vector2) -> Variant:
	var selected = block_list.get_selected_items()
	if selected.is_empty():
		return null
	
	var block_name = block_list.get_item_text(selected[0])
	
	var preview = Label.new()
	preview.text = block_name
	set_drag_preview(preview)
	
	return {"type": "block", "block_name": block_name}

func _update_footer() -> void:
	if _current_path.is_empty():
		current_file_label.text = "Novo " + _selected_type if _current_resource else "Nenhum arquivo"
	else:
		current_file_label.text = _current_path.get_file() + (" *" if _is_dirty else "")
	
	save_btn.disabled = not _current_resource
	cancel_btn.disabled = not _current_resource

func _create_resource_for_type(type_name: String) -> Resource:
	match type_name:
		"State": return State.new()
		"Item": return Item.new()
		"Skill": return Skill.new()
		"Compose": return Compose.new()
		"Inventory": return InventoryData.new()
		"SkillTree": return SkillTree.new()
	return null

func _detect_resource_type(res: Resource) -> String:
	if res is State:
		return "State"
	elif res is Item:
		return "Item"
	elif res is Skill:
		return "Skill"
	elif res is Compose:
		return "Compose"
	elif res is InventoryData:
		return "Inventory"
	elif res is SkillTree:
		return "SkillTree"
	return ""
