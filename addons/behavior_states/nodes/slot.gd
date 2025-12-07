## Slot de Inventário
##
## Um slot individual que pode conter um Item. Suporta drag & drop, seleção e exibição.
class_name Slot extends PanelContainer

signal item_changed(slot: Slot)
signal slot_clicked(slot: Slot, button: int)
signal slot_hovered(slot: Slot)
signal drag_started(slot: Slot)
signal drag_ended(slot: Slot)

@export var slot_index: int = 0
@export var item: Item = null:
	set(value):
		item = value
		_update_display()
		item_changed.emit(self)

@export var locked: bool = false
@export var selected: bool = false:
	set(value):
		selected = value
		_update_style()

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel
@onready var selection_border: Panel = $SelectionBorder

var _is_dragging: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	_update_display()
	_update_style()

func _update_display() -> void:
	if not is_inside_tree():
		return
	
	if item and item.icon:
		icon.texture = item.icon
		icon.visible = true
		quantity_label.text = str(item.quantity) if item.quantity > 1 else ""
		quantity_label.visible = item.quantity > 1
	else:
		icon.texture = null
		icon.visible = false
		quantity_label.visible = false

func _update_style() -> void:
	if not is_inside_tree():
		return
	
	if selection_border:
		selection_border.visible = selected

func _on_mouse_entered() -> void:
	slot_hovered.emit(self)

func _on_mouse_exited() -> void:
	pass

func _on_gui_input(event: InputEvent) -> void:
	if locked:
		return
	
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.pressed:
			slot_clicked.emit(self, mb.button_index)

func _get_drag_data(at_position: Vector2) -> Variant:
	if not item or locked:
		return null
	
	_is_dragging = true
	drag_started.emit(self)
	
	# Create drag preview
	var preview = TextureRect.new()
	preview.texture = item.icon
	preview.custom_minimum_size = Vector2(48, 48)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.modulate.a = 0.8
	set_drag_preview(preview)
	
	return {"type": "item", "item": item, "source_slot": self}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if locked:
		return false
	if data is Dictionary and data.get("type") == "item":
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.get("type") == "item":
		var source_slot = data.get("source_slot") as Slot
		var dragged_item = data.get("item") as Item
		
		if source_slot and source_slot != self:
			# Swap items
			var temp = self.item
			self.item = dragged_item
			source_slot.item = temp
	
	_is_dragging = false
	drag_ended.emit(self)

func clear() -> void:
	item = null

func is_empty() -> bool:
	return item == null
