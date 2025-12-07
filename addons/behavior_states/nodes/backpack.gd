## Backpack - Interface de Inventário
##
## UI completa de inventário com grid de slots, busca e categorias.
class_name Backpack extends Control

signal item_selected(item: Item, slot: Slot)
signal item_used(item: Item, slot: Slot)
signal inventory_changed()

@export var inventory: Inventory  # Node gerenciador de dados
@export var columns: int = 6
@export var slot_size: Vector2 = Vector2(64, 64)
@export var slot_spacing: int = 4

@onready var grid: GridContainer = $VBoxContainer/ScrollContainer/Grid
@onready var search_edit: LineEdit = $VBoxContainer/Header/SearchEdit
@onready var category_tabs: TabBar = $VBoxContainer/Header/CategoryTabs

var _slots: Array[Slot] = []
var _selected_slot: Slot = null
var _slot_scene: PackedScene = preload("res://addons/behavior_states/scenes/ui/slot.tscn")

func _ready() -> void:
	if search_edit:
		search_edit.text_changed.connect(_on_search_changed)
	if category_tabs:
		category_tabs.tab_changed.connect(_on_category_changed)
	
	_setup_grid()
	refresh()

func _setup_grid() -> void:
	if not grid:
		return
	
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", slot_spacing)
	grid.add_theme_constant_override("v_separation", slot_spacing)

func refresh() -> void:
	if not inventory:
		return
	
	_clear_slots()
	_create_slots()
	_populate_slots()

func _clear_slots() -> void:
	for slot in _slots:
		slot.queue_free()
	_slots.clear()

func _create_slots() -> void:
	if not inventory:
		return
	
	var capacity = inventory.capacity if inventory else 24
	
	for i in range(capacity):
		var slot = _slot_scene.instantiate() as Slot
		slot.slot_index = i
		slot.custom_minimum_size = slot_size
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.item_changed.connect(_on_slot_item_changed)
		grid.add_child(slot)
		_slots.append(slot)

func _populate_slots() -> void:
	if not inventory:
		return
	
	var items = inventory.get_items()
	for i in range(min(items.size(), _slots.size())):
		_slots[i].item = items[i]

func _on_slot_clicked(slot: Slot, button: int) -> void:
	match button:
		MOUSE_BUTTON_LEFT:
			_select_slot(slot)
		MOUSE_BUTTON_RIGHT:
			if slot.item:
				item_used.emit(slot.item, slot)

func _select_slot(slot: Slot) -> void:
	if _selected_slot:
		_selected_slot.selected = false
	
	_selected_slot = slot
	slot.selected = true
	
	if slot.item:
		item_selected.emit(slot.item, slot)

func _on_slot_item_changed(slot: Slot) -> void:
	inventory_changed.emit()

func _on_search_changed(text: String) -> void:
	for slot in _slots:
		if slot.item:
			var matches = text.is_empty() or text.to_lower() in slot.item.name.to_lower()
			slot.visible = matches
		else:
			slot.visible = text.is_empty()

func _on_category_changed(tab: int) -> void:
	# TODO: Filter by category
	pass

func get_selected_item() -> Item:
	if _selected_slot:
		return _selected_slot.item
	return null

func add_item(item: Item) -> bool:
	if not inventory:
		return false
	
	if inventory.add_item(item):
		refresh()
		return true
	return false

func remove_item(item: Item) -> bool:
	if not inventory:
		return false
	
	if inventory.remove_item(item):
		refresh()
		return true
	return false

func toggle_visibility() -> void:
	visible = not visible
