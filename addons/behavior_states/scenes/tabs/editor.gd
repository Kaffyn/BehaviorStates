@tool
## Visual Blueprint Editor
##
## Editor visual para montar recursos usando blocos componentes.
extends MarginContainer

# Block colors (Tailwind-inspired)
const COLORS = {
	"filter": Color("#22c55e"),    # green-500
	"action": Color("#3b82f6"),    # blue-500
	"trigger": Color("#f59e0b"),   # amber-500
	"modifier": Color("#8b5cf6"),  # violet-500
	"property": Color("#6b7280"),  # gray-500
	"requirement": Color("#ec4899"), # pink-500
	"unlock": Color("#a855f7"),    # purple-500
	"state": Color("#22c55e"),
	"item": Color("#3b82f6"),
	"skill": Color("#ec4899"),
	"compose": Color("#f59e0b")
}

@onready var graph_edit: GraphEdit = $HSplitContainer/GraphContainer/GraphEdit
@onready var placeholder_label: Label = $HSplitContainer/GraphContainer/GraphEdit/PlaceholderLabel
@onready var file_dialog: FileDialog = $FileDialog

var _node_counter: int = 0
var _current_saving_resource: Resource = null

func _ready() -> void:
	graph_edit.add_valid_connection_type(0, 0)
	graph_edit.add_valid_left_disconnect_type(0)
	graph_edit.add_valid_right_disconnect_type(0)
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

func _on_block_activated(index: int, category: String) -> void:
	placeholder_label.visible = false
	var list: ItemList
	match category:
		"state":
			list = $HSplitContainer/Sidebar/StateBlocks
		"item":
			list = $HSplitContainer/Sidebar/ItemBlocks
		"skill":
			list = $HSplitContainer/Sidebar/SkillBlocks
	
	if not list:
		return
	
	var block_name = list.get_item_text(index)
	_create_block_node(block_name, _get_spawn_position())

func _on_container_activated(index: int) -> void:
	placeholder_label.visible = false
	var list = $HSplitContainer/Sidebar/ContainerBlocks
	var container_name = list.get_item_text(index)
	_create_container_node(container_name, _get_spawn_position())

func _get_spawn_position() -> Vector2:
	return Vector2(100 + randf() * 200, 100 + randf() * 150)

func _create_block_node(block_type: String, position: Vector2) -> GraphNode:
	var node = GraphNode.new()
	node.name = "Block_%d" % _node_counter
	_node_counter += 1
	node.title = block_type
	node.position_offset = position
	node.resizable = true
	node.set_meta("block_type", block_type)
	
	var color = _get_block_color(block_type)
	node.set_slot(0, true, 0, color, true, 0, color)
	
	# Add inline editors based on block type
	match block_type:
		"FilterBlock":
			_add_filter_editors(node)
		"ActionBlock":
			_add_action_editors(node)
		"TriggerBlock":
			_add_trigger_editors(node)
		"ModifierBlock":
			_add_modifier_editors(node)
		"PropertyBlock":
			_add_property_editors(node)
		"RequirementBlock":
			_add_requirement_editors(node)
		"UnlockBlock":
			_add_unlock_editors(node)
	
	graph_edit.add_child(node)
	return node

func _create_container_node(container_type: String, position: Vector2) -> GraphNode:
	var node = GraphNode.new()
	node.name = "Container_%d" % _node_counter
	_node_counter += 1
	node.title = container_type
	node.position_offset = position
	node.resizable = true
	node.set_meta("container_type", container_type)
	
	var color = COLORS.get(container_type.to_lower(), Color.WHITE)
	node.set_slot(0, true, 0, color, true, 0, color)
	
	# Name field
	var name_row = _create_row("Nome:")
	var name_edit = LineEdit.new()
	name_edit.placeholder_text = "Nome do " + container_type
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_edit)
	node.add_child(name_row)
	node.set_meta("name_edit", name_edit)
	
	# Add slot for children
	var slot_label = Label.new()
	slot_label.text = "→ Conecte blocos"
	slot_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	node.add_child(slot_label)
	
	graph_edit.add_child(node)
	return node

# ========== INLINE EDITORS ==========

func _add_filter_editors(node: GraphNode) -> void:
	# Filter Key
	var key_row = _create_row("Filtro:")
	var key_option = OptionButton.new()
	key_option.add_item("Physics")
	key_option.add_item("Motion")
	key_option.add_item("Weapon")
	key_option.add_item("Attack")
	key_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_row.add_child(key_option)
	node.add_child(key_row)
	node.set_meta("filter_key", key_option)
	
	# Filter Value
	var value_row = _create_row("Valor:")
	var value_spin = SpinBox.new()
	value_spin.min_value = 0
	value_spin.max_value = 10
	value_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_row.add_child(value_spin)
	node.add_child(value_row)
	node.set_meta("filter_value", value_spin)
	
	# Comparison
	var comp_row = _create_row("Comparação:")
	var comp_option = OptionButton.new()
	comp_option.add_item("Igual")
	comp_option.add_item("Diferente")
	comp_option.add_item("Maior")
	comp_option.add_item("Menor")
	comp_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	comp_row.add_child(comp_option)
	node.add_child(comp_row)
	node.set_meta("comparison", comp_option)

func _add_action_editors(node: GraphNode) -> void:
	# Action Type
	var type_row = _create_row("Ação:")
	var type_option = OptionButton.new()
	type_option.add_item("Damage")
	type_option.add_item("Heal")
	type_option.add_item("Spawn")
	type_option.add_item("ApplyForce")
	type_option.add_item("PlayAnimation")
	type_option.add_item("PlaySound")
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_row.add_child(type_option)
	node.add_child(type_row)
	node.set_meta("action_type", type_option)
	
	# Target
	var target_row = _create_row("Alvo:")
	var target_option = OptionButton.new()
	target_option.add_item("Self")
	target_option.add_item("Enemy")
	target_option.add_item("Ally")
	target_option.add_item("All")
	target_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_row.add_child(target_option)
	node.add_child(target_row)
	node.set_meta("target", target_option)
	
	# Value
	var value_row = _create_row("Valor:")
	var value_spin = SpinBox.new()
	value_spin.min_value = 0
	value_spin.max_value = 9999
	value_spin.value = 10
	value_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_row.add_child(value_spin)
	node.add_child(value_row)
	node.set_meta("value", value_spin)

func _add_trigger_editors(node: GraphNode) -> void:
	# Trigger Type
	var type_row = _create_row("Gatilho:")
	var type_option = OptionButton.new()
	type_option.add_item("OnEnter")
	type_option.add_item("OnExit")
	type_option.add_item("OnUpdate")
	type_option.add_item("OnHit")
	type_option.add_item("OnTimeout")
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_row.add_child(type_option)
	node.add_child(type_row)
	node.set_meta("trigger_type", type_option)
	
	# Method
	var method_row = _create_row("Método:")
	var method_edit = LineEdit.new()
	method_edit.placeholder_text = "nome_da_funcao"
	method_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	method_row.add_child(method_edit)
	node.add_child(method_row)
	node.set_meta("call_method", method_edit)
	
	# Delay
	var delay_row = _create_row("Delay:")
	var delay_spin = SpinBox.new()
	delay_spin.min_value = 0
	delay_spin.max_value = 10
	delay_spin.step = 0.1
	delay_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	delay_row.add_child(delay_spin)
	node.add_child(delay_row)
	node.set_meta("delay", delay_spin)

func _add_modifier_editors(node: GraphNode) -> void:
	# Attribute
	var attr_row = _create_row("Atributo:")
	var attr_edit = LineEdit.new()
	attr_edit.placeholder_text = "damage, speed, hp..."
	attr_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attr_row.add_child(attr_edit)
	node.add_child(attr_row)
	node.set_meta("attribute", attr_edit)
	
	# Modifier Type
	var type_row = _create_row("Tipo:")
	var type_option = OptionButton.new()
	type_option.add_item("Flat (+)")
	type_option.add_item("Percent Add (%+)")
	type_option.add_item("Percent Mult (%*)")
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_row.add_child(type_option)
	node.add_child(type_row)
	node.set_meta("modifier_type", type_option)
	
	# Value
	var value_row = _create_row("Valor:")
	var value_spin = SpinBox.new()
	value_spin.min_value = -9999
	value_spin.max_value = 9999
	value_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_row.add_child(value_spin)
	node.add_child(value_row)
	node.set_meta("value", value_spin)

func _add_property_editors(node: GraphNode) -> void:
	# Key
	var key_row = _create_row("Chave:")
	var key_edit = LineEdit.new()
	key_edit.placeholder_text = "nome_propriedade"
	key_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_row.add_child(key_edit)
	node.add_child(key_row)
	node.set_meta("property_key", key_edit)
	
	# Value
	var value_row = _create_row("Valor:")
	var value_edit = LineEdit.new()
	value_edit.placeholder_text = "valor"
	value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_row.add_child(value_edit)
	node.add_child(value_row)
	node.set_meta("property_value", value_edit)

func _add_requirement_editors(node: GraphNode) -> void:
	# Requirement Type
	var type_row = _create_row("Tipo:")
	var type_option = OptionButton.new()
	type_option.add_item("Level")
	type_option.add_item("Skill Unlocked")
	type_option.add_item("Item Owned")
	type_option.add_item("Stat Min")
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_row.add_child(type_option)
	node.add_child(type_row)
	node.set_meta("requirement_type", type_option)
	
	# Target ID
	var target_row = _create_row("ID Alvo:")
	var target_edit = LineEdit.new()
	target_edit.placeholder_text = "skill_id / item_id"
	target_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_row.add_child(target_edit)
	node.add_child(target_row)
	node.set_meta("target_id", target_edit)
	
	# Min Value
	var min_row = _create_row("Mínimo:")
	var min_spin = SpinBox.new()
	min_spin.min_value = 0
	min_spin.max_value = 100
	min_spin.value = 1
	min_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	min_row.add_child(min_spin)
	node.add_child(min_row)
	node.set_meta("min_value", min_spin)

func _add_unlock_editors(node: GraphNode) -> void:
	# Unlock Type
	var type_row = _create_row("Desbloqueia:")
	var type_option = OptionButton.new()
	type_option.add_item("State")
	type_option.add_item("Ability")
	type_option.add_item("Passive")
	type_option.add_item("Stat Bonus")
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_row.add_child(type_option)
	node.add_child(type_row)
	node.set_meta("unlock_type", type_option)
	
	# Bonus Value
	var bonus_row = _create_row("Bônus:")
	var bonus_spin = SpinBox.new()
	bonus_spin.min_value = 0
	bonus_spin.max_value = 9999
	bonus_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bonus_row.add_child(bonus_spin)
	node.add_child(bonus_row)
	node.set_meta("bonus_value", bonus_spin)

# ========== HELPERS ==========

func _create_row(label_text: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 80
	row.add_child(label)
	return row

func _get_block_color(block_type: String) -> Color:
	match block_type:
		"FilterBlock": return COLORS["filter"]
		"ActionBlock": return COLORS["action"]
		"TriggerBlock": return COLORS["trigger"]
		"ModifierBlock": return COLORS["modifier"]
		"PropertyBlock": return COLORS["property"]
		"RequirementBlock": return COLORS["requirement"]
		"UnlockBlock": return COLORS["unlock"]
	return Color.WHITE

func _on_clear_pressed() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			graph_edit.remove_child(child)
			child.queue_free()
	placeholder_label.visible = true

func _on_save_pressed() -> void:
	file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	# TODO: Serialize graph to .tres
	print("Saving to: ", path)
