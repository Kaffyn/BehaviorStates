## SkillTreeUI - Interface Visual da Árvore de Habilidades.
##
## Exibe skills como nós conectados em um grafo interativo.
## Suporta unlock, upgrade, e visualização de prerequisites.
class_name SkillTreeUI extends Control

signal skill_selected(skill: Skill)
signal skill_unlocked(skill: Skill)
signal skill_upgraded(skill: Skill, new_level: int)

## Referência ao CharacterSheet (para verificar SP e skills desbloqueadas).
@export var character_sheet: CharacterSheet

## Cores do tema
@export_group("Theme")
@export var bg_color: Color = Color(0.08, 0.08, 0.1, 0.95)
@export var node_locked_color: Color = Color(0.25, 0.25, 0.25, 1.0)
@export var node_available_color: Color = Color(0.3, 0.4, 0.5, 1.0)
@export var node_unlocked_color: Color = Color(0.2, 0.5, 0.3, 1.0)
@export var node_maxed_color: Color = Color(0.5, 0.4, 0.2, 1.0)
@export var connection_locked_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var connection_unlocked_color: Color = Color(0.4, 0.7, 0.4, 1.0)

@export_group("Layout")
@export var node_size: Vector2 = Vector2(80, 80)
@export var icon_size: Vector2 = Vector2(48, 48)

# UI Components
var _main_panel: PanelContainer
var _header: HBoxContainer
var _title_label: Label
var _sp_label: Label
var _close_btn: Button
var _canvas: Control
var _tooltip_panel: PanelContainer
var _selected_skill: Skill = null

# Skill nodes { skill_id: Control }
var _skill_nodes: Dictionary = {}

func _ready() -> void:
	_build_ui()

func _process(delta: float) -> void:
	if _tooltip_panel and _tooltip_panel.visible:
		_tooltip_panel.global_position = get_global_mouse_position() + Vector2(15, 15)

# ==================== UI BUILDING ====================

func _build_ui() -> void:
	# Container principal
	_main_panel = PanelContainer.new()
	_main_panel.name = "MainPanel"
	_main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	_main_panel.add_theme_stylebox_override("panel", style)
	add_child(_main_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_main_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	# === HEADER ===
	_header = HBoxContainer.new()
	_header.add_theme_constant_override("separation", 16)
	vbox.add_child(_header)
	
	_title_label = Label.new()
	_title_label.text = "Skill Tree"
	_title_label.add_theme_font_size_override("font_size", 20)
	_header.add_child(_title_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header.add_child(spacer)
	
	_sp_label = Label.new()
	_sp_label.text = "SP: 0"
	_sp_label.add_theme_font_size_override("font_size", 16)
	_sp_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	_header.add_child(_sp_label)
	
	_close_btn = Button.new()
	_close_btn.text = "✕"
	_close_btn.custom_minimum_size = Vector2(32, 32)
	_close_btn.pressed.connect(func(): visible = false)
	_header.add_child(_close_btn)
	
	# === CANVAS (Scroll + Graph) ===
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)
	
	_canvas = Control.new()
	_canvas.name = "Canvas"
	_canvas.custom_minimum_size = Vector2(800, 600)
	scroll.add_child(_canvas)
	
	# === TOOLTIP ===
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.visible = false
	_tooltip_panel.z_index = 100
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tooltip_panel)
	
	var tip_style = StyleBoxFlat.new()
	tip_style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	tip_style.border_color = Color(0.4, 0.4, 0.5)
	tip_style.border_width_bottom = 1
	tip_style.border_width_top = 1
	tip_style.border_width_left = 1
	tip_style.border_width_right = 1
	tip_style.corner_radius_top_left = 4
	tip_style.corner_radius_top_right = 4
	tip_style.corner_radius_bottom_left = 4
	tip_style.corner_radius_bottom_right = 4
	_tooltip_panel.add_theme_stylebox_override("panel", tip_style)

# ==================== LOAD SKILL TREE ====================

func load_skill_tree(tree: SkillTree) -> void:
	if not tree:
		return
	
	_clear_canvas()
	
	# Auto-layout se não tiver posições
	if tree.positions.is_empty() and not tree.skills.is_empty():
		tree.auto_layout()
	
	_title_label.text = tree.name
	
	# Primeiro, desenha conexões
	_draw_connections(tree)
	
	# Depois, cria nós
	for skill in tree.skills:
		if skill:
			_create_skill_node(skill, tree)
	
	_update_sp_display()
	_update_all_node_states(tree)

func _clear_canvas() -> void:
	for child in _canvas.get_children():
		child.queue_free()
	_skill_nodes.clear()

func _draw_connections(tree: SkillTree) -> void:
	# Cria um Control para desenhar linhas
	var line_drawer = Control.new()
	line_drawer.name = "Lines"
	line_drawer.set_anchors_preset(Control.PRESET_FULL_RECT)
	line_drawer.z_index = -1
	_canvas.add_child(line_drawer)
	
	# Conecta draw
	line_drawer.draw.connect(func():
		for skill in tree.skills:
			if not skill: continue
			var to_pos = tree.get_skill_position(skill) + _get_canvas_offset() + node_size / 2
			
			for prereq in skill.prerequisites:
				if prereq:
					var from_pos = tree.get_skill_position(prereq) + _get_canvas_offset() + node_size / 2
					
					# Cor baseada no status
					var color = connection_locked_color
					if character_sheet and character_sheet.has_skill(prereq.id):
						color = connection_unlocked_color
					
					line_drawer.draw_line(from_pos, to_pos, color, 2.0, true)
	)

func _get_canvas_offset() -> Vector2:
	# Offset para centralizar o grafo
	return Vector2(400, 50)

func _create_skill_node(skill: Skill, tree: SkillTree) -> void:
	var pos = tree.get_skill_position(skill) + _get_canvas_offset()
	
	var node = PanelContainer.new()
	node.name = "Skill_" + skill.id
	node.position = pos
	node.custom_minimum_size = node_size
	node.set_meta("skill", skill)
	
	# Style inicial
	var style = StyleBoxFlat.new()
	style.bg_color = node_locked_color
	style.border_color = Color(0.4, 0.4, 0.4)
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	node.add_theme_stylebox_override("panel", style)
	
	# Conteúdo
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	node.add_child(vbox)
	
	# Ícone
	var icon_rect = TextureRect.new()
	icon_rect.name = "Icon"
	icon_rect.custom_minimum_size = icon_size
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if skill.icon:
		icon_rect.texture = skill.icon
	vbox.add_child(icon_rect)
	
	# Level indicator
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(level_label)
	
	# Signals
	node.gui_input.connect(func(event): _on_skill_node_input(event, skill, tree))
	node.mouse_entered.connect(func(): _show_tooltip(skill))
	node.mouse_exited.connect(func(): _hide_tooltip())
	
	_canvas.add_child(node)
	_skill_nodes[skill.id] = node

func _update_all_node_states(tree: SkillTree) -> void:
	for skill_id in _skill_nodes:
		var node = _skill_nodes[skill_id] as PanelContainer
		var skill = tree.get_skill_by_id(skill_id)
		if skill:
			_update_node_state(node, skill, tree)

func _update_node_state(node: PanelContainer, skill: Skill, tree: SkillTree) -> void:
	var style = node.get_theme_stylebox("panel") as StyleBoxFlat
	var level_label = node.get_node("VBoxContainer/LevelLabel") as Label
	
	if not character_sheet:
		style.bg_color = node_locked_color
		style.border_color = Color(0.3, 0.3, 0.3)
		if level_label:
			level_label.text = ""
		return
	
	var current_level = character_sheet.unlocked_skills.get(skill.id, 0)
	var is_unlocked = current_level > 0
	var is_maxed = current_level >= skill.max_level
	var is_available = skill.can_unlock(character_sheet, character_sheet.unlocked_skills.keys())
	
	if is_maxed:
		style.bg_color = node_maxed_color
		style.border_color = Color(0.8, 0.6, 0.2)
	elif is_unlocked:
		style.bg_color = node_unlocked_color
		style.border_color = Color(0.4, 0.8, 0.4)
	elif is_available:
		style.bg_color = node_available_color
		style.border_color = Color(0.5, 0.6, 0.8)
	else:
		style.bg_color = node_locked_color
		style.border_color = Color(0.3, 0.3, 0.3)
	
	if level_label:
		if skill.max_level > 1:
			level_label.text = "%d/%d" % [current_level, skill.max_level]
		elif is_unlocked:
			level_label.text = "✓"
		else:
			level_label.text = ""

# ==================== INTERACTION ====================

func _on_skill_node_input(event: InputEvent, skill: Skill, tree: SkillTree) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_select_skill(skill)
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_try_unlock_skill(skill, tree)

func _select_skill(skill: Skill) -> void:
	_selected_skill = skill
	skill_selected.emit(skill)
	
	# Highlight
	for skill_id in _skill_nodes:
		var node = _skill_nodes[skill_id] as PanelContainer
		var is_selected = skill_id == skill.id
		node.modulate = Color.WHITE if not is_selected else Color(1.2, 1.2, 1.2)

func _try_unlock_skill(skill: Skill, tree: SkillTree) -> void:
	if not character_sheet:
		return
	
	var current_level = character_sheet.unlocked_skills.get(skill.id, 0)
	var is_maxed = current_level >= skill.max_level
	
	if is_maxed:
		return
	
	var can_unlock = skill.can_unlock(character_sheet, character_sheet.unlocked_skills.keys())
	if not can_unlock:
		return
	
	# Check SP
	if character_sheet.skill_points < skill.cost:
		return
	
	# Unlock!
	character_sheet.skill_points -= skill.cost
	
	if current_level == 0:
		character_sheet.unlocked_skills[skill.id] = 1
		skill.on_learn(character_sheet)
		skill_unlocked.emit(skill)
	else:
		character_sheet.unlocked_skills[skill.id] = current_level + 1
		skill_upgraded.emit(skill, current_level + 1)
	
	tree.unlock_skill(skill)
	
	_update_sp_display()
	_update_all_node_states(tree)
	
	# Redraw connections
	var lines = _canvas.get_node_or_null("Lines")
	if lines:
		lines.queue_redraw()

func _update_sp_display() -> void:
	if character_sheet:
		_sp_label.text = "SP: %d" % character_sheet.skill_points
	else:
		_sp_label.text = "SP: --"

# ==================== TOOLTIP ====================

func _show_tooltip(skill: Skill) -> void:
	# Limpa tooltip anterior
	for child in _tooltip_panel.get_children():
		child.queue_free()
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	_tooltip_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)
	
	# Nome com raridade
	var name_label = Label.new()
	name_label.text = skill.name
	name_label.add_theme_color_override("font_color", skill.get_rarity_color())
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)
	
	# Tipo
	var type_names = ["Passive", "Active", "Ultimate", "Meta Perk"]
	var type_label = Label.new()
	type_label.text = type_names[skill.skill_type]
	type_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	type_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(type_label)
	
	# Descrição
	if skill.description:
		var desc_label = Label.new()
		desc_label.text = skill.description
		desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size.x = 220
		vbox.add_child(desc_label)
	
	# Custo
	var cost_label = Label.new()
	cost_label.text = "Cost: %d SP" % skill.cost
	cost_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	cost_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(cost_label)
	
	# Requisitos
	if skill.req_level > 1:
		var req_label = Label.new()
		req_label.text = "Requires: Level %d" % skill.req_level
		req_label.add_theme_color_override("font_color", Color(0.7, 0.5, 0.5))
		req_label.add_theme_font_size_override("font_size", 11)
		vbox.add_child(req_label)
	
	# Prerequisites
	if not skill.prerequisites.is_empty():
		var prereq_names: Array = []
		for prereq in skill.prerequisites:
			if prereq:
				prereq_names.append(prereq.name)
		var prereq_label = Label.new()
		prereq_label.text = "Requires: " + ", ".join(prereq_names)
		prereq_label.add_theme_color_override("font_color", Color(0.7, 0.5, 0.5))
		prereq_label.add_theme_font_size_override("font_size", 11)
		vbox.add_child(prereq_label)
	
	# Unlocks
	if not skill.unlocks_states.is_empty():
		var unlock_label = Label.new()
		unlock_label.text = "Unlocks: %d states" % skill.unlocks_states.size()
		unlock_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.5))
		unlock_label.add_theme_font_size_override("font_size", 11)
		vbox.add_child(unlock_label)
	
	# Ação
	var action_label = Label.new()
	if character_sheet:
		var current_level = character_sheet.unlocked_skills.get(skill.id, 0)
		if current_level >= skill.max_level:
			action_label.text = "[Maxed]"
			action_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
		elif skill.can_unlock(character_sheet, character_sheet.unlocked_skills.keys()):
			action_label.text = "[Right-click to unlock]"
			action_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
		else:
			action_label.text = "[Locked]"
			action_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	else:
		action_label.text = "[No character sheet]"
		action_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	action_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(action_label)
	
	_tooltip_panel.visible = true

func _hide_tooltip() -> void:
	_tooltip_panel.visible = false

# ==================== PUBLIC API ====================

func refresh() -> void:
	if character_sheet and character_sheet.skill_tree:
		load_skill_tree(character_sheet.skill_tree)

func toggle_visibility() -> void:
	visible = not visible
	if visible:
		refresh()
