@tool
## Visual Blueprint Editor
##
## Editor visual completo para montar recursos usando Components.
## Suporta State, Item, Skill (component-based) e Compose, Inventory, SkillTree (containers).
extends MarginContainer

const ComponentDefs = preload("res://addons/behavior_states/resources/components/component_definitions.gd")

# Tipos block-based vs containers
const BLOCK_TYPES = ["State", "Item", "Skill", "Effects", "BehaviorStatesConfig", "CharacterSheet"]
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
	"Effects": Color("#a855f7"),
	"Compose": Color("#f59e0b"),
	"Inventory": Color("#8b5cf6"),
	"SkillTree": Color("#a855f7"),
	"BehaviorStatesConfig": Color("#f59e0b"),
	"CharacterSheet": Color("#ef4444")
}

const TYPE_FILTERS = {
	"State": "*.tres",
	"Item": "*.tres",
	"Skill": "*.tres",
	"Effects": "*.tres",
	"Compose": "*.tres",
	"Inventory": "*.tres",
	"SkillTree": "*.tres",
	"BehaviorStatesConfig": "*.tres",
	"CharacterSheet": "*.tres"
}

@onready var block_list: ItemList = $VBoxContainer/HSplitContainer/Sidebar/BlockList
@onready var search_edit: LineEdit = $VBoxContainer/HSplitContainer/Sidebar/SearchEdit
@onready var graph_edit: GraphEdit = $VBoxContainer/HSplitContainer/VBoxContainer/GraphContainer/GraphEdit
@onready var placeholder_label: Label = $VBoxContainer/HSplitContainer/VBoxContainer/GraphContainer/GraphEdit/PlaceholderLabel
@onready var file_dialog: FileDialog = $FileDialog
@onready var current_file_label: Label = $VBoxContainer/HSplitContainer/VBoxContainer/Toolbar/CurrentFileLabel
@onready var save_btn: Button = $VBoxContainer/HSplitContainer/VBoxContainer/Toolbar/SaveBtn
@onready var cancel_btn: Button = $VBoxContainer/HSplitContainer/VBoxContainer/Toolbar/CancelBtn

var _selected_type: String = ""
var _current_resource: Resource = null
var _current_path: String = ""
var _node_counter: int = 0
var _is_dirty: bool = false
var _context_menu: PopupMenu
var _root_node: GraphNode = null

# Maps GraphNode name -> block data
var _block_nodes: Dictionary = {}

# === MULTI-RESOURCE CANVAS ===
# Maps resource_path -> {resource, node, dirty}
var _open_resources: Dictionary = {}

func _ready() -> void:
	# Graph setup
	graph_edit.add_valid_connection_type(0, 0)
	graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	
	# Context menu
	_setup_context_menu()
	graph_edit.gui_input.connect(_on_graph_gui_input)
	
	# Drag from sidebar
	block_list.set_drag_forwarding(_get_drag_data_fw, Callable(), Callable())
	
	# Enable drop from FileSystem
	graph_edit.set_drag_forwarding(Callable(), _can_drop_data_graph, _drop_data_graph)

func _setup_context_menu() -> void:
	_context_menu = PopupMenu.new()
	_context_menu.name = "ContextMenu"
	add_child(_context_menu)
	_context_menu.id_pressed.connect(_on_context_menu_id_pressed)

# ==================== SIDEBAR ====================

func _update_sidebar(filter: String = "") -> void:
	block_list.clear()
	
	if _selected_type.is_empty():
		return
	
	var items: Array = []
	
	if _selected_type in BLOCK_TYPES:
		# Use ComponentDefs instead of BlockDefs
		items = ComponentDefs.get_component_names_for_type(_selected_type)
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

func _create_root_node(res: Resource, resource_path: String = "") -> GraphNode:
	var res_type = _detect_resource_type(res)
	var title = res.get("name") if "name" in res else res_type
	var color = TYPE_COLORS.get(res_type, Color.WHITE)
	
	var node = GraphNode.new()
	node.name = "Node_%d" % _node_counter
	_node_counter += 1
	node.title = title
	node.position_offset = Vector2(50 + (_open_resources.size() * 300), 50)
	node.set_slot(0, false, 0, color, true, 0, color)
	
	# Store resource info in metadata
	node.set_meta("resource", res)
	node.set_meta("resource_path", resource_path)
	node.set_meta("resource_type", res_type)
	
	# === TOOLBAR ROW ===
	var toolbar = HBoxContainer.new()
	
	# Close Button (X)
	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.tooltip_text = "Fechar (remove do canvas)"
	close_btn.custom_minimum_size = Vector2(28, 24)
	close_btn.pressed.connect(func(): _close_resource_node(node))
	toolbar.add_child(close_btn)
	
	# Save Button
	var save_btn = Button.new()
	save_btn.text = "💾"
	save_btn.tooltip_text = "Salvar"
	save_btn.custom_minimum_size = Vector2(28, 24)
	save_btn.pressed.connect(func(): _save_resource_node(node))
	toolbar.add_child(save_btn)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(spacer)
	
	# Type Label
	var type_label = Label.new()
	type_label.text = res_type
	type_label.add_theme_color_override("font_color", color)
	toolbar.add_child(type_label)
	
	node.add_child(toolbar)
	
	# === NAME ROW ===
	var name_row = HBoxContainer.new()
	var name_label = Label.new()
	name_label.text = "Nome:"
	name_label.custom_minimum_size.x = 60
	name_row.add_child(name_label)
	var name_edit = LineEdit.new()
	name_edit.text = str(title)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(func(t): _on_node_name_changed(node, t))
	name_row.add_child(name_edit)
	node.add_child(name_row)
	
	graph_edit.add_child(node)
	
	# Track in open resources
	_open_resources[node.name] = {
		"resource": res,
		"path": resource_path,
		"node": node,
		"dirty": resource_path.is_empty()
	}
	
	return node

# ==================== COMPONENT SYSTEM LOGIC ====================

func _load_resource_to_graph(res: Resource, path: String) -> void:
	_clear_graph()
	
	_current_resource = res
	_current_path = path
	placeholder_label.visible = false
	
	_create_root_node(res)
	
	# For block-based types, we now load Components
	if _selected_type in BLOCK_TYPES:
		_load_components_for_resource(res)
	elif _selected_type in CONTAINER_TYPES:
		_load_children_for_container(res)
	
	_is_dirty = path.is_empty()
	_update_footer()

func _load_components_for_resource(res: Resource) -> void:
	if not "components" in res:
		return
		
	var components = res.components
	var x_offset = 350
	var y_offset = 50
	
	for comp in components:
		if comp:
			var node = _create_component_node(comp, Vector2(x_offset, y_offset))
			if node:
				y_offset += node.size.y + 40

func _create_component_node(comp: Resource, position: Vector2) -> GraphNode:
	if not comp.has_method("get_component_name"):
		return null
		
	var comp_name = comp.get_component_name()
	var defs = ComponentDefs.get_components_for_type(_selected_type)
	
	# Fallback if component not in current definitions
	var def = defs.get(comp.get_script().get_global_name(), {}) # Try class name first
	# If empty, try to find by iterating
	if def.is_empty():
		for key in defs:
			if defs[key].name == comp_name:
				def = defs[key]
				break
	
	var color = def.get("color", Color.WHITE)
	
	var node = GraphNode.new()
	node.name = "Comp_%d" % _node_counter
	_node_counter += 1
	node.title = comp_name
	node.position_offset = position
	node.resizable = true
	node.set_slot(0, true, 0, color, true, 0, color)
	node.set_meta("component", comp)
	
	# Delete Button in header
	var del_btn = Button.new()
	del_btn.text = "X"
	del_btn.flat = true
	del_btn.pressed.connect(func(): _delete_component(comp, node))
	node.get_titlebar_hbox().add_child(del_btn)
	
	# Generate fields from definition
	var fields = def.get("fields", [])
	for field in fields:
		var row = _create_field_row(field, comp)
		if row:
			node.add_child(row)
	
	graph_edit.add_child(node)
	
	if _root_node:
		graph_edit.connect_node(_root_node.name, 0, node.name, 0)
	
	_block_nodes[node.name] = {"block_name": comp_name, "node": node}
	
	# Force size update (deferred)
	node.size = Vector2(0, 0) 
	return node

func _delete_component(comp: Resource, node: GraphNode) -> void:
	if _current_resource and "components" in _current_resource:
		_current_resource.components.erase(comp)
		_is_dirty = true
		_load_resource_to_graph(_current_resource, _current_path)

func _create_field_row(field: Dictionary, target_obj: Object) -> Control:
	var row = HBoxContainer.new()
	row.custom_minimum_size.y = 24
	
	var label = Label.new()
	label.text = field.name.capitalize() + ":"
	label.custom_minimum_size.x = 100
	row.add_child(label)
	
	var field_name = field.name
	var field_type = field.type
	var default_val = field.get("default", null)
	
	# Get current value from target object (Component or Resource)
	var current_val = target_obj.get(field_name) if field_name in target_obj else default_val
	
	# Helper to bind change
	var bind_change = func(val): _on_field_changed(target_obj, field_name, val)
	
	match field_type:
		"String", "StringName":
			var edit = LineEdit.new()
			edit.text = str(current_val) if current_val else ""
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			edit.text_changed.connect(bind_change)
			row.add_child(edit)
		
		"int":
			var spin = SpinBox.new()
			spin.value = int(current_val) if current_val else 0
			spin.min_value = -9999
			spin.max_value = 9999
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.value_changed.connect(func(v): bind_change.call(int(v)))
			row.add_child(spin)
		
		"float":
			var spin = SpinBox.new()
			spin.value = float(current_val) if current_val else 0.0
			spin.min_value = -9999.0
			spin.max_value = 9999.0
			spin.step = 0.1
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.value_changed.connect(bind_change)
			row.add_child(spin)
		
		"bool":
			var check = CheckBox.new()
			check.button_pressed = bool(current_val) if current_val else false
			check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			check.toggled.connect(bind_change)
			row.add_child(check)
		
		"enum":
			var option = OptionButton.new()
			var options = field.get("options", [])
			for opt in options:
				option.add_item(opt)
			option.selected = int(current_val) if current_val else 0
			option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			option.item_selected.connect(func(idx): bind_change.call(idx))
			row.add_child(option)
			
		"Color":
			var picker = ColorPickerButton.new()
			picker.color = current_val if current_val else Color.WHITE
			picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			picker.color_changed.connect(bind_change)
			row.add_child(picker)

		"Vector2":
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var vec = current_val if current_val else Vector2.ZERO
			
			var x_spin = SpinBox.new()
			x_spin.value = vec.x
			x_spin.min_value = -9999; x_spin.max_value = 9999
			x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			x_spin.value_changed.connect(func(v): 
				vec.x = v
				bind_change.call(vec))
			hbox.add_child(x_spin)
			
			var y_spin = SpinBox.new()
			y_spin.value = vec.y
			y_spin.min_value = -9999; y_spin.max_value = 9999
			y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			y_spin.value_changed.connect(func(v): 
				vec.y = v
				bind_change.call(vec))
			hbox.add_child(y_spin)
			
			row.add_child(hbox)
			
		"Texture2D", "AudioStream", "PackedScene", "Resource":
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var label_txt = "[None]"
			if current_val and current_val is Resource:
				label_txt = current_val.resource_path.get_file()
			var res_label = Label.new()
			res_label.text = label_txt
			res_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(res_label)
			
			var pick_btn = Button.new()
			pick_btn.text = "📂"
			pick_btn.pressed.connect(func(): _on_pick_resource(target_obj, field_name, field_type))
			hbox.add_child(pick_btn)
			
			row.add_child(hbox)

		_:
			var placeholder = Label.new()
			placeholder.text = "[%s]" % field_type
			row.add_child(placeholder)

	return row

func _on_field_changed(target_obj: Object, field_name: String, value: Variant) -> void:
	if target_obj and field_name in target_obj:
		target_obj.set(field_name, value)
		_is_dirty = true
		_update_footer()

func _on_block_activated(index: int) -> void:
	var item_text = block_list.get_item_text(index)
	
	if _selected_type in BLOCK_TYPES:
		# It's a component name from ComponentDefs
		var defs = ComponentDefs.get_components_for_type(_selected_type)
		var def = null
		
		# Find definition
		for key in defs:
			if defs[key].name == item_text:
				def = defs[key]
				break
				
		if def:
			var script_path = def.script
			var script = load(script_path)
			if script:
				var comp = script.new()
				if _current_resource and "components" in _current_resource:
					_current_resource.components.append(comp)
					_is_dirty = true
					# Refresh graph
					_load_resource_to_graph(_current_resource, _current_path)

	elif _selected_type in CONTAINER_TYPES:
		var child_path = "res://addons/behavior_states/data/" + item_text
		var child_res = load(child_path)
		if child_res:
			_add_child_to_container(child_res)

# ==================== CONTAINER LOGIC ====================

func _load_children_for_container(res: Resource) -> void:
	if _selected_type == "SkillTree":
		_load_skill_tree_graph(res)
		return

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

func _load_skill_tree_graph(tree: SkillTree) -> void:
	var skills = tree.skills
	var created_nodes = {} # Skill ID -> GraphNode Name
	
	# Pass 1: Create Nodes
	var index = 0
	for skill in skills:
		if not skill: continue
		var node = GraphNode.new()
		node.name = "Skill_%s" % skill.id
		node.title = skill.name
		node.position_offset = Vector2(300 + (index % 5) * 250, 100 + (index / 5) * 150)
		node.set_slot(0, true, 0, TYPE_COLORS["Skill"], true, 0, TYPE_COLORS["Skill"])
		node.metadata = skill
		
		# Skill Info
		var lvl = Label.new()
		lvl.text = "Min Lvl: %d" % skill.req_level
		node.add_child(lvl)
		
		graph_edit.add_child(node)
		created_nodes[skill.id] = node.name
		_block_nodes[node.name] = {"block_name": skill.id, "node": node}
		
		index += 1
		
	# Pass 2: Create Connections (Prerequisites)
	for skill in skills:
		if not skill: continue
		if skill.id in created_nodes:
			var to_node = created_nodes[skill.id]
			
			for prereq in skill.prerequisites:
				if prereq and prereq.id in created_nodes:
					var from_node = created_nodes[prereq.id]
					graph_edit.connect_node(from_node, 0, to_node, 0)
					
	# Connect to Root (Tree itself)
	if _root_node:
		for skill in skills:
			if skill and skill.prerequisites.is_empty() and skill.id in created_nodes:
				graph_edit.connect_node(_root_node.name, 0, created_nodes[skill.id], 0)

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

func _on_file_dialog_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = PackedStringArray(["*.tres"])
	file_dialog.title = "Abrir Resource"
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_current_path = path
		_save_resource()
		return
	
	var res = load(path)
	if res:
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

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if _selected_type == "SkillTree":
		_connect_skill_dependency(from_node, to_node)
		return

	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	_is_dirty = true
	_update_footer()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if _selected_type == "SkillTree":
		_disconnect_skill_dependency(from_node, to_node)
		return

	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	_is_dirty = true
	_update_footer()

func _connect_skill_dependency(from_node_name: String, to_node_name: String) -> void:
	if not from_node_name in _block_nodes or not to_node_name in _block_nodes:
		return
		
	var from_node = _block_nodes[from_node_name].node
	var to_node = _block_nodes[to_node_name].node
	
	var skill_provider = from_node.metadata as Skill
	var skill_receiver = to_node.metadata as Skill
	
	if skill_provider and skill_receiver:
		if not skill_receiver.prerequisites.has(skill_provider):
			skill_receiver.prerequisites.append(skill_provider)
			ResourceSaver.save(skill_receiver, skill_receiver.resource_path)
			print("Linked %s -> %s" % [skill_provider.id, skill_receiver.id])
			graph_edit.connect_node(from_node_name, 0, to_node_name, 0)

func _disconnect_skill_dependency(from_node_name: String, to_node_name: String) -> void:
	if not from_node_name in _block_nodes or not to_node_name in _block_nodes:
		return
		
	var from_node = _block_nodes[from_node_name].node
	var to_node = _block_nodes[to_node_name].node
	
	var skill_provider = from_node.metadata as Skill
	var skill_receiver = to_node.metadata as Skill
	
	if skill_provider and skill_receiver:
		if skill_receiver.prerequisites.has(skill_provider):
			skill_receiver.prerequisites.erase(skill_provider)
			ResourceSaver.save(skill_receiver, skill_receiver.resource_path)
			print("Unlinked %s -> %s" % [skill_provider.id, skill_receiver.id])
			graph_edit.disconnect_node(from_node_name, 0, to_node_name, 0)

func _on_graph_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_update_context_menu()
			_context_menu.position = Vector2i(get_global_mouse_position())
			_context_menu.popup()

func _update_context_menu() -> void:
	_context_menu.clear()
	
	if _selected_type.is_empty():
		return
	
	_context_menu.add_separator("Adicionar Componente")
	
	if _selected_type in BLOCK_TYPES:
		var blocks = ComponentDefs.get_component_names_for_type(_selected_type)
		for i in range(blocks.size()):
			_context_menu.add_item(blocks[i], i)
	elif _selected_type in CONTAINER_TYPES:
		# Add child resource...
		pass

func _on_context_menu_id_pressed(id: int) -> void:
	_on_block_activated(id)

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
		"Inventory": return Inventory.new()
		"SkillTree": return SkillTree.new()
		"BehaviorStatesConfig": return BehaviorStatesConfig.new()
		"CharacterSheet": return CharacterSheet.new()
	return null

func _detect_resource_type(res: Resource) -> String:
	if res is State: return "State"
	elif res is Item: return "Item"
	elif res is Skill: return "Skill"
	elif res is Compose: return "Compose"
	elif res is Inventory: return "Inventory"
	elif res is SkillTree: return "SkillTree"
	elif res is BehaviorStatesConfig: return "BehaviorStatesConfig"
	elif res is CharacterSheet: return "CharacterSheet"
	elif res is Effect: return "Effects"
	return ""

# ==================== MULTI-RESOURCE CANVAS ====================

func _close_resource_node(node: GraphNode) -> void:
	if node.name in _open_resources:
		_open_resources.erase(node.name)
	node.queue_free()
	_update_footer()

func _save_resource_node(node: GraphNode) -> void:
	var res = node.get_meta("resource") as Resource
	var path = node.get_meta("resource_path") as String
	
	if not res:
		return
	
	if path.is_empty():
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = ["*.tres"]
		file_dialog.current_path = "res://"
		file_dialog.popup_centered(Vector2(600, 400))
		file_dialog.set_meta("target_node", node)
		if not file_dialog.file_selected.is_connected(_on_save_node_file_selected):
			file_dialog.file_selected.connect(_on_save_node_file_selected)
	else:
		var err = ResourceSaver.save(res, path)
		if err == OK:
			if node.name in _open_resources:
				_open_resources[node.name]["dirty"] = false
			node.title = res.get("name") if "name" in res else node.title
			print("Saved: ", path)
		else:
			push_error("Failed to save: ", path)

func _on_save_node_file_selected(path: String) -> void:
	var node = file_dialog.get_meta("target_node") as GraphNode
	if not node:
		return
	
	var res = node.get_meta("resource") as Resource
	if res:
		var err = ResourceSaver.save(res, path)
		if err == OK:
			node.set_meta("resource_path", path)
			if node.name in _open_resources:
				_open_resources[node.name]["path"] = path
				_open_resources[node.name]["dirty"] = false
			print("Saved new resource: ", path)

func _on_node_name_changed(node: GraphNode, new_name: String) -> void:
	var res = node.get_meta("resource") as Resource
	if res and "name" in res:
		res.name = new_name
		node.title = new_name
		if node.name in _open_resources:
			_open_resources[node.name]["dirty"] = true
		_update_footer()

func _can_drop_data_graph(at_position: Vector2, data) -> bool:
	if data is Dictionary:
		if data.get("type") == "files":
			var files = data.get("files", []) as Array
			for file in files:
				if str(file).ends_with(".tres"):
					return true
		elif data.get("type") == "block":
			return true
	return false

func _drop_data_graph(at_position: Vector2, data) -> void:
	if not data is Dictionary:
		return
	
	if data.get("type") == "files":
		var files = data.get("files", []) as Array
		for file in files:
			var file_path = str(file)
			if file_path.ends_with(".tres"):
				add_resource_to_canvas(file_path)
	elif data.get("type") == "block":
		var block_name = data.get("block_name", "")
		if not block_name.is_empty():
			var pos = graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
			_on_block_activated(block_list.get_item_count()) # Hacky, simplified

func add_resource_to_canvas(path: String) -> GraphNode:
	for key in _open_resources:
		if _open_resources[key]["path"] == path:
			var existing = _open_resources[key]["node"] as GraphNode
			graph_edit.scroll_offset = existing.position_offset - Vector2(100, 100)
			return existing
	
	var res = load(path)
	if not res:
		return null
	
	var node = _create_root_node(res, path)
	placeholder_label.visible = false
	return node
	
# Resource Picker Callbacks
var _pending_target_obj: Object
var _pending_field_for_picker: String
var _pending_field_type: String

func _on_pick_resource(target_obj: Object, field_name: String, resource_type: String) -> void:
	_pending_target_obj = target_obj
	_pending_field_for_picker = field_name
	_pending_field_type = resource_type
	
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	if resource_type in ["Texture2D", "Image"]:
		file_dialog.filters = ["*.png", "*.jpg", "*.webp", "*.svg"]
	elif resource_type == "AudioStream":
		file_dialog.filters = ["*.wav", "*.ogg", "*.mp3"]
	elif resource_type == "PackedScene":
		file_dialog.filters = ["*.tscn", "*.scn"]
	else:
		file_dialog.filters = ["*.tres"]
		
	file_dialog.current_path = "res://"
	file_dialog.popup_centered(Vector2(600, 400))
	
	if not file_dialog.file_selected.is_connected(_on_picker_file_selected):
		file_dialog.file_selected.connect(_on_picker_file_selected)

func _on_picker_file_selected(path: String) -> void:
	if not _pending_target_obj:
		return
	
	var res = load(path)
	if res:
		_on_field_changed(_pending_target_obj, _pending_field_for_picker, res)
		# Reload graph to update labels
		_load_resource_to_graph(_current_resource, _current_path)
	
	_pending_target_obj = null
