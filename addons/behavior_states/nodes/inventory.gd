## Gerenciador de Inventário
##
## Node que gerencia a coleção de Items do jogador.
## Fornece API para adicionar, remover e consultar items.
class_name Inventory extends Node

signal item_added(item: Item, slot_index: int)
signal item_removed(item: Item, slot_index: int)
signal item_selected(item: Item)
signal inventory_changed()

@export var capacity: int = 24
@export var items: Array[Item] = []

var _selected_index: int = -1

func _ready() -> void:
	# Initialize empty slots
	if items.size() < capacity:
		items.resize(capacity)

func get_items() -> Array[Item]:
	return items

func get_item_at(index: int) -> Item:
	if index >= 0 and index < items.size():
		return items[index]
	return null

func add_item(item: Item) -> bool:
	# First try to stack with existing item
	if item.stackable:
		for i in range(items.size()):
			if items[i] and items[i].id == item.id:
				items[i].quantity += item.quantity
				item_added.emit(item, i)
				inventory_changed.emit()
				return true
	
	# Find empty slot
	for i in range(capacity):
		if i >= items.size():
			items.resize(i + 1)
		if items[i] == null:
			items[i] = item
			item_added.emit(item, i)
			inventory_changed.emit()
			return true
	
	return false  # Inventory full

func remove_item(item: Item) -> bool:
	for i in range(items.size()):
		if items[i] == item:
			items[i] = null
			item_removed.emit(item, i)
			inventory_changed.emit()
			return true
	return false

func remove_item_at(index: int) -> Item:
	if index >= 0 and index < items.size():
		var item = items[index]
		items[index] = null
		if item:
			item_removed.emit(item, index)
			inventory_changed.emit()
		return item
	return null

func set_item_at(index: int, item: Item) -> void:
	if index >= 0 and index < capacity:
		if index >= items.size():
			items.resize(index + 1)
		items[index] = item
		inventory_changed.emit()

func swap_items(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= items.size():
		return
	if to_index < 0 or to_index >= capacity:
		return
	
	if to_index >= items.size():
		items.resize(to_index + 1)
	
	var temp = items[from_index]
	items[from_index] = items[to_index]
	items[to_index] = temp
	inventory_changed.emit()

func select_item(index: int) -> void:
	_selected_index = index
	var item = get_item_at(index)
	if item:
		item_selected.emit(item)

func get_selected_item() -> Item:
	return get_item_at(_selected_index)

func get_selected_index() -> int:
	return _selected_index

func has_item(item_id: String) -> bool:
	for item in items:
		if item and item.id == item_id:
			return true
	return false

func count_item(item_id: String) -> int:
	var count = 0
	for item in items:
		if item and item.id == item_id:
			count += item.quantity
	return count

func is_full() -> bool:
	for item in items:
		if item == null:
			return false
	return items.size() >= capacity

func clear() -> void:
	items.clear()
	items.resize(capacity)
	inventory_changed.emit()
