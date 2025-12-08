@tool
## Backpack - Interface de Inventário (HUD Control).
##
## UI de inventário que exibe e gerencia items.
## Usa Inventory (Resource) como fonte de dados.
class_name Backpack extends Control

signal item_selected(item: Item)
signal item_used(item: Item)
signal inventory_changed()

## Dados do inventário (Resource).
@export var inventory_data: Inventory

## Configuração visual.
@export_group("Visual")
@export var columns: int = 6
@export var slot_size: Vector2 = Vector2(64, 64)
@export var slot_spacing: int = 4

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/Grid if has_node("VBoxContainer/ScrollContainer/Grid") else null
@onready var search_edit: LineEdit = $VBoxContainer/Header/SearchEdit if has_node("VBoxContainer/Header/SearchEdit") else null
@onready var category_tabs: TabBar = $VBoxContainer/Header/CategoryTabs if has_node("VBoxContainer/Header/CategoryTabs") else null

var _slots: Array[Slot] = []
var _selected_index: int = -1
var _slot_scene: PackedScene

func _ready() -> void:
	if ResourceLoader.exists("res://addons/behavior_states/scenes/ui/slot.tscn"):
		_slot_scene = load("res://addons/behavior_states/scenes/ui/slot.tscn")
	
	if inventory_data:
		inventory_data.initialize()
	
	if search_edit:
		search_edit.text_changed.connect(_on_search_changed)
	if category_tabs:
		category_tabs.tab_changed.connect(_on_category_changed)
	
	_setup_grid()
	refresh()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not inventory_data:
		warnings.append("Backpack precisa de um Inventory resource!")
	
	return warnings

func _setup_grid() -> void:
	if not grid:
		return
	
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", slot_spacing)
	grid.add_theme_constant_override("v_separation", slot_spacing)

func refresh() -> void:
	if not inventory_data:
		return
	
	_clear_slots()
	_create_slots()
	_populate_slots()

func _clear_slots() -> void:
	for slot in _slots:
		if is_instance_valid(slot):
			slot.queue_free()
	_slots.clear()

func _create_slots() -> void:
	if not inventory_data or not grid or not _slot_scene:
		return
	
	for i in range(inventory_data.capacity):
		var slot = _slot_scene.instantiate() as Slot
		if slot:
			slot.slot_index = i
			slot.custom_minimum_size = slot_size
			slot.slot_clicked.connect(_on_slot_clicked)
			slot.item_changed.connect(_on_slot_item_changed)
			grid.add_child(slot)
			_slots.append(slot)

func _populate_slots() -> void:
	if not inventory_data:
		return
	
	var items = inventory_data.get_items()
	for i in range(min(items.size(), _slots.size())):
		_slots[i].item = items[i]

func _on_slot_clicked(slot: Slot, button: int) -> void:
	match button:
		MOUSE_BUTTON_LEFT:
			_select_slot(slot)
		MOUSE_BUTTON_RIGHT:
			if slot.item:
				item_used.emit(slot.item)

func _select_slot(slot: Slot) -> void:
	# Deselect previous
	if _selected_index >= 0 and _selected_index < _slots.size():
		_slots[_selected_index].selected = false
	
	_selected_index = slot.slot_index
	slot.selected = true
	
	if slot.item:
		item_selected.emit(slot.item)

func _on_slot_item_changed(slot: Slot) -> void:
	# Sync back to inventory_data
	if inventory_data and slot.slot_index < inventory_data.capacity:
		var items = inventory_data.get_items()
		if slot.slot_index < items.size():
			items[slot.slot_index] = slot.item
	
	inventory_changed.emit()

func _on_search_changed(text: String) -> void:
	for slot in _slots:
		if slot.item:
			var matches = text.is_empty() or text.to_lower() in slot.item.name.to_lower()
			slot.visible = matches
		else:
			slot.visible = text.is_empty()

func _on_category_changed(tab: int) -> void:
	# Filter by category
	for slot in _slots:
		if slot.item:
			slot.visible = (tab == 0) or (slot.item.category == tab - 1)
		else:
			slot.visible = (tab == 0)

func get_selected_item() -> Item:
	if _selected_index >= 0 and _selected_index < _slots.size():
		return _slots[_selected_index].item
	return null

func select_item(index: int) -> void:
	if index >= 0 and index < _slots.size():
		_select_slot(_slots[index])

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

func use_selected_item() -> void:
	var item = get_selected_item()
	if item:
		item_used.emit(item)

func get_equipped_compose() -> Compose:
	var item = get_selected_item()
	if item:
		return item.compose
	return null

func toggle_visibility() -> void:
	visible = not visible
