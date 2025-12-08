@tool
## Container de Itens do Inventário.
##
## Resource que armazena uma coleção de Items, similar ao Compose para States.
## Usado pelo Backpack (Node) para renderização e pelo sistema de persistência.
class_name Inventory extends Resource

@export var items: Array[Item] = []
@export var capacity: int = 24

# Cache para busca rápida por ID
var _items_map: Dictionary = {}
var _initialized: bool = false

func initialize() -> void:
	if _initialized:
		return
	
	_items_map.clear()
	for item in items:
		if item and item.id:
			_items_map[item.id] = item
	
	_initialized = true

func get_items() -> Array[Item]:
	return items

func get_item_by_id(id: String) -> Item:
	if not _initialized:
		initialize()
	return _items_map.get(id)

func add_item(item: Item) -> bool:
	if items.size() >= capacity:
		return false
	
	# Try to stack
	if item.stackable:
		for existing in items:
			if existing and existing.id == item.id:
				if existing.quantity + item.quantity <= existing.max_stack:
					existing.quantity += item.quantity
					return true
	
	# Add to first empty slot or append
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item
			_items_map[item.id] = item
			return true
	
	if items.size() < capacity:
		items.append(item)
		_items_map[item.id] = item
		return true
	
	return false

func remove_item(item: Item) -> bool:
	var idx = items.find(item)
	if idx >= 0:
		items[idx] = null
		if item.id in _items_map:
			_items_map.erase(item.id)
		return true
	return false

func has_item(id: String) -> bool:
	return id in _items_map

func count_item(id: String) -> int:
	var count = 0
	for item in items:
		if item and item.id == id:
			count += item.quantity
	return count

func is_full() -> bool:
	if items.size() < capacity:
		return false
	for item in items:
		if item == null:
			return false
	return true

func clear() -> void:
	items.clear()
	_items_map.clear()
	_initialized = false
