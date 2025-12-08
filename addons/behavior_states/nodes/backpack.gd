@tool
## Backpack - Interface de Inventário Minecraft-Style (HUD Control).
##
## UI de inventário com:
## - Grid de inventário principal (27 slots = 9x3)
## - Hotbar (9 slots)
## - Grid de crafting 3x3
## - Slot de resultado de craft
## - Armor slots
## - Preview do personagem
class_name Backpack extends Control

signal item_selected(item: Item)
signal item_used(item: Item)
signal item_equipped(item: Item, slot_type: String)
signal inventory_changed()
signal craft_result_ready(item: Item)

## Dados do inventário (Resource).
@export var inventory_data: Inventory

## Configuração visual.
@export_group("Visual")
@export var slot_size: Vector2 = Vector2(48, 48)
@export var slot_spacing: int = 4

## Cores do tema
@export_group("Theme")
@export var bg_color: Color = Color(0.12, 0.12, 0.12, 0.95)
@export var slot_color: Color = Color(0.2, 0.2, 0.2, 1.0)
@export var slot_hover_color: Color = Color(0.3, 0.3, 0.3, 1.0)
@export var slot_selected_color: Color = Color(0.4, 0.6, 0.4, 1.0)
@export var border_color: Color = Color(0.4, 0.4, 0.4, 1.0)

# Slots organizados
var _main_slots: Array[Slot] = []       # 27 slots (9x3)
var _hotbar_slots: Array[Slot] = []     # 9 slots
var _craft_slots: Array[Slot] = []      # 9 slots (3x3)
var _result_slot: Slot = null           # 1 slot
var _armor_slots: Array[Slot] = []      # 4 slots (head, chest, legs, feet)
var _offhand_slot: Slot = null          # 1 slot

var _selected_index: int = -1
var _held_item: Item = null  # Item no cursor (para drag & drop estilo Minecraft)
var _held_item_preview: TextureRect = null

# Recipes cache (loaded from Item resources)
var _recipes: Dictionary = {}  # { recipe_hash: Item }

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_build_ui()
	_load_recipes()
	
	if inventory_data:
		inventory_data.initialize()
		refresh()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Atualiza posição do item segurado
	if _held_item and _held_item_preview:
		_held_item_preview.global_position = get_global_mouse_position() - slot_size / 2

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Clique direito para dividir stack
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if _held_item:
				# Solta 1 item
				_drop_single_item()

# ==================== UI BUILDING ====================

func _build_ui() -> void:
	# Container principal
	var main_panel = PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.set_anchors_preset(Control.PRESET_CENTER)
	main_panel.custom_minimum_size = Vector2(600, 400)
	
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	main_panel.add_theme_stylebox_override("panel", style)
	add_child(main_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	main_panel.add_child(margin)
	
	var main_hbox = HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 20)
	margin.add_child(main_hbox)
	
	# === LADO ESQUERDO: Crafting ===
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 8)
	main_hbox.add_child(left_vbox)
	
	# Título Crafting
	var craft_title = Label.new()
	craft_title.text = "Crafting"
	craft_title.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(craft_title)
	
	# Crafting area (3x3 + resultado)
	var craft_hbox = HBoxContainer.new()
	craft_hbox.add_theme_constant_override("separation", 16)
	left_vbox.add_child(craft_hbox)
	
	# Grid 3x3
	var craft_grid = GridContainer.new()
	craft_grid.columns = 3
	craft_grid.add_theme_constant_override("h_separation", slot_spacing)
	craft_grid.add_theme_constant_override("v_separation", slot_spacing)
	craft_hbox.add_child(craft_grid)
	
	for i in range(9):
		var slot = _create_slot(i, "craft")
		craft_grid.add_child(slot)
		_craft_slots.append(slot)
	
	# Seta de resultado
	var arrow = Label.new()
	arrow.text = "➡"
	arrow.add_theme_font_size_override("font_size", 24)
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	craft_hbox.add_child(arrow)
	
	# Slot de resultado
	_result_slot = _create_slot(0, "result")
	_result_slot.custom_minimum_size = Vector2(slot_size.x * 1.2, slot_size.y * 1.2)
	craft_hbox.add_child(_result_slot)
	
	# === Armor Slots ===
	var armor_title = Label.new()
	armor_title.text = "Armor"
	armor_title.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(armor_title)
	
	var armor_grid = GridContainer.new()
	armor_grid.columns = 2
	armor_grid.add_theme_constant_override("h_separation", slot_spacing)
	armor_grid.add_theme_constant_override("v_separation", slot_spacing)
	left_vbox.add_child(armor_grid)
	
	var armor_names = ["Head", "Chest", "Legs", "Feet"]
	for i in range(4):
		var slot = _create_slot(i, "armor")
		slot.tooltip_text = armor_names[i]
		armor_grid.add_child(slot)
		_armor_slots.append(slot)
	
	# === LADO DIREITO: Inventário ===
	var right_vbox = VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 8)
	main_hbox.add_child(right_vbox)
	
	# Título Inventory
	var inv_title = Label.new()
	inv_title.text = "Inventory"
	inv_title.add_theme_font_size_override("font_size", 14)
	right_vbox.add_child(inv_title)
	
	# Main inventory grid (9x3 = 27)
	var main_grid = GridContainer.new()
	main_grid.name = "MainGrid"
	main_grid.columns = 9
	main_grid.add_theme_constant_override("h_separation", slot_spacing)
	main_grid.add_theme_constant_override("v_separation", slot_spacing)
	right_vbox.add_child(main_grid)
	
	for i in range(27):
		var slot = _create_slot(i, "main")
		main_grid.add_child(slot)
		_main_slots.append(slot)
	
	# Separador
	var separator = HSeparator.new()
	right_vbox.add_child(separator)
	
	# Hotbar (9 slots)
	var hotbar_title = Label.new()
	hotbar_title.text = "Hotbar"
	hotbar_title.add_theme_font_size_override("font_size", 12)
	right_vbox.add_child(hotbar_title)
	
	var hotbar_grid = GridContainer.new()
	hotbar_grid.name = "HotbarGrid"
	hotbar_grid.columns = 9
	hotbar_grid.add_theme_constant_override("h_separation", slot_spacing)
	hotbar_grid.add_theme_constant_override("v_separation", slot_spacing)
	right_vbox.add_child(hotbar_grid)
	
	for i in range(9):
		var slot = _create_slot(i, "hotbar")
		hotbar_grid.add_child(slot)
		_hotbar_slots.append(slot)
	
	# === HELD ITEM PREVIEW ===
	_held_item_preview = TextureRect.new()
	_held_item_preview.custom_minimum_size = slot_size
	_held_item_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held_item_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held_item_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_item_preview.visible = false
	_held_item_preview.z_index = 100
	add_child(_held_item_preview)

func _create_slot(index: int, slot_type: String) -> Slot:
	var slot = Slot.new()
	slot.slot_index = index
	slot.custom_minimum_size = slot_size
	slot.set_meta("slot_type", slot_type)
	
	# Estilo visual
	var style = StyleBoxFlat.new()
	style.bg_color = slot_color
	style.border_color = border_color
	style.border_width_bottom = 1
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_right = 1
	slot.add_theme_stylebox_override("panel", style)
	
	# Adiciona ícone e label de quantidade
	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	
	var qty_label = Label.new()
	qty_label.name = "QuantityLabel"
	qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qty_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	qty_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	qty_label.add_theme_font_size_override("font_size", 12)
	qty_label.add_theme_color_override("font_color", Color.WHITE)
	qty_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	qty_label.add_theme_constant_override("shadow_offset_x", 1)
	qty_label.add_theme_constant_override("shadow_offset_y", 1)
	qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(qty_label)
	
	var selection = Panel.new()
	selection.name = "SelectionBorder"
	selection.set_anchors_preset(Control.PRESET_FULL_RECT)
	selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection.visible = false
	var sel_style = StyleBoxFlat.new()
	sel_style.bg_color = Color(0, 0, 0, 0)
	sel_style.border_color = slot_selected_color
	sel_style.border_width_bottom = 2
	sel_style.border_width_top = 2
	sel_style.border_width_left = 2
	sel_style.border_width_right = 2
	selection.add_theme_stylebox_override("panel", sel_style)
	slot.add_child(selection)
	
	# Conectar sinais
	slot.slot_clicked.connect(_on_slot_clicked)
	
	return slot

# ==================== SLOT INTERACTION ====================

func _on_slot_clicked(slot: Slot, button: int) -> void:
	var slot_type = slot.get_meta("slot_type") as String
	
	if button == MOUSE_BUTTON_LEFT:
		if _held_item:
			# Tentar colocar item no slot
			_place_item_in_slot(slot, _held_item)
		elif slot.item:
			# Pegar item do slot
			_pick_item_from_slot(slot)
	elif button == MOUSE_BUTTON_RIGHT:
		if _held_item:
			# Colocar 1 item
			_place_single_item(slot)
		elif slot.item:
			# Pegar metade
			_pick_half_stack(slot)
	
	# Atualizar crafting
	if slot_type == "craft":
		_check_craft_recipe()
	elif slot_type == "result" and slot.item:
		_craft_item()

func _pick_item_from_slot(slot: Slot) -> void:
	_held_item = slot.item
	slot.item = null
	_update_held_item_preview()

func _place_item_in_slot(slot: Slot, item_to_place: Item) -> void:
	if slot.item == null:
		slot.item = item_to_place
		_held_item = null
	elif slot.item.id == item_to_place.id and slot.item.stackable:
		# Stack items
		var space = slot.item.max_stack - slot.item.quantity
		var to_add = min(space, item_to_place.quantity)
		slot.item.quantity += to_add
		item_to_place.quantity -= to_add
		if item_to_place.quantity <= 0:
			_held_item = null
	else:
		# Swap
		var temp = slot.item
		slot.item = item_to_place
		_held_item = temp
	
	_update_held_item_preview()
	slot._update_display()
	inventory_changed.emit()

func _pick_half_stack(slot: Slot) -> void:
	if not slot.item:
		return
	
	var half = ceili(slot.item.quantity / 2.0)
	if half > 0:
		_held_item = slot.item.duplicate()
		_held_item.quantity = half
		slot.item.quantity -= half
		if slot.item.quantity <= 0:
			slot.item = null
		slot._update_display()
	
	_update_held_item_preview()

func _place_single_item(slot: Slot) -> void:
	if not _held_item:
		return
	
	if slot.item == null:
		slot.item = _held_item.duplicate()
		slot.item.quantity = 1
		_held_item.quantity -= 1
	elif slot.item.id == _held_item.id and slot.item.stackable:
		if slot.item.quantity < slot.item.max_stack:
			slot.item.quantity += 1
			_held_item.quantity -= 1
	
	if _held_item.quantity <= 0:
		_held_item = null
	
	_update_held_item_preview()
	slot._update_display()
	inventory_changed.emit()

func _drop_single_item() -> void:
	# Se tiver slot abaixo do cursor, coloca 1 item
	pass

func _update_held_item_preview() -> void:
	if _held_item and _held_item.icon:
		_held_item_preview.texture = _held_item.icon
		_held_item_preview.visible = true
	else:
		_held_item_preview.visible = false

# ==================== CRAFTING ====================

func _load_recipes() -> void:
	# Carrega todas as receitas de Items com craft_recipe
	var dir = DirAccess.open("res://")
	_scan_for_recipes("res://")

func _scan_for_recipes(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = path + "/" + file_name
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_for_recipes(full_path)
		elif file_name.ends_with(".tres"):
			var res = load(full_path)
			if res is Item and not res.craft_recipe.is_empty():
				var hash = _get_recipe_hash(res.craft_recipe)
				_recipes[hash] = res
		file_name = dir.get_next()
	dir.list_dir_end()

func _get_recipe_hash(recipe: Dictionary) -> String:
	# Cria hash da disposição 3x3
	var parts: Array = []
	for i in range(9):
		var key = str(i)
		if key in recipe:
			parts.append(recipe[key])
		else:
			parts.append("")
	return "|".join(parts)

func _check_craft_recipe() -> void:
	# Monta o hash atual do grid 3x3
	var current: Dictionary = {}
	for i in range(9):
		if _craft_slots[i].item:
			current[str(i)] = _craft_slots[i].item.id
		else:
			current[str(i)] = ""
	
	var hash = _get_recipe_hash(current)
	
	if hash in _recipes:
		var result_item = _recipes[hash].duplicate() as Item
		result_item.quantity = result_item.craft_output_quantity if "craft_output_quantity" in result_item else 1
		_result_slot.item = result_item
		craft_result_ready.emit(result_item)
	else:
		_result_slot.item = null

func _craft_item() -> void:
	if not _result_slot.item:
		return
	
	# Consumir ingredientes
	for slot in _craft_slots:
		if slot.item:
			slot.item.quantity -= 1
			if slot.item.quantity <= 0:
				slot.item = null
			slot._update_display()
	
	# Dar item ao jogador
	var crafted = _result_slot.item.duplicate() as Item
	if _held_item and _held_item.id == crafted.id and _held_item.stackable:
		_held_item.quantity += crafted.quantity
	elif not _held_item:
		_held_item = crafted
	else:
		# Inventário cheio, não crafta
		return
	
	_update_held_item_preview()
	_result_slot.item = null
	_check_craft_recipe()
	inventory_changed.emit()

# ==================== REFRESH & SYNC ====================

func refresh() -> void:
	if not inventory_data:
		return
	
	var items = inventory_data.get_items()
	
	# Hotbar (primeiros 9)
	for i in range(min(9, _hotbar_slots.size())):
		_hotbar_slots[i].item = items[i] if i < items.size() else null
		_hotbar_slots[i]._update_display()
	
	# Main inventory (próximos 27)
	for i in range(min(27, _main_slots.size())):
		var inv_idx = i + 9
		_main_slots[i].item = items[inv_idx] if inv_idx < items.size() else null
		_main_slots[i]._update_display()

func sync_to_inventory() -> void:
	if not inventory_data:
		return
	
	var items: Array[Item] = []
	
	# Hotbar primeiro
	for slot in _hotbar_slots:
		items.append(slot.item)
	
	# Depois main
	for slot in _main_slots:
		items.append(slot.item)
	
	inventory_data.set_items(items)

# ==================== PUBLIC API ====================

func get_selected_item() -> Item:
	if _selected_index >= 0 and _selected_index < _hotbar_slots.size():
		return _hotbar_slots[_selected_index].item
	return null

func select_hotbar_slot(index: int) -> void:
	if index < 0 or index >= _hotbar_slots.size():
		return
	
	# Deselect previous
	if _selected_index >= 0 and _selected_index < _hotbar_slots.size():
		_hotbar_slots[_selected_index].selected = false
	
	_selected_index = index
	_hotbar_slots[index].selected = true
	
	if _hotbar_slots[index].item:
		item_selected.emit(_hotbar_slots[index].item)

func get_equipped_compose() -> Compose:
	var item = get_selected_item()
	if item:
		return item.compose
	return null

func toggle_visibility() -> void:
	visible = not visible
	if visible:
		refresh()
	else:
		sync_to_inventory()

func close() -> void:
	# Retorna item segurado para o inventário
	if _held_item:
		add_item(_held_item)
		_held_item = null
		_update_held_item_preview()
	
	sync_to_inventory()
	visible = false

func add_item(item: Item) -> bool:
	if inventory_data and inventory_data.add_item(item):
		refresh()
		return true
	return false

func remove_item(item: Item) -> bool:
	if inventory_data and inventory_data.remove_item(item):
		refresh()
		return true
	return false
