## Slot de Inventário (Minecraft-Style)
##
## Um slot individual que pode conter um Item.
## Suporta drag & drop estilo Minecraft, seleção e exibição.
class_name Slot extends PanelContainer

signal item_changed(slot: Slot)
signal slot_clicked(slot: Slot, button: int)
signal slot_hovered(slot: Slot)

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

# Referências internas
var _icon: TextureRect = null
var _quantity_label: Label = null
var _selection_border: Panel = null
var _durability_bar: ProgressBar = null

func _ready() -> void:
	# Busca ou cria componentes
	_icon = get_node_or_null("Icon")
	_quantity_label = get_node_or_null("QuantityLabel")
	_selection_border = get_node_or_null("SelectionBorder")
	_durability_bar = get_node_or_null("DurabilityBar")
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	_update_display()
	_update_style()

func _update_display() -> void:
	if not is_inside_tree():
		await ready
	
	# Icon
	if _icon:
		if item and item.icon:
			_icon.texture = item.icon
			_icon.visible = true
		else:
			_icon.texture = null
			_icon.visible = false
	
	# Quantity
	if _quantity_label:
		if item and item.quantity > 1:
			_quantity_label.text = str(item.quantity)
			_quantity_label.visible = true
		else:
			_quantity_label.visible = false
	
	# Durability bar
	if _durability_bar:
		if item and item.has_durability and item.durability < item.max_durability:
			_durability_bar.max_value = item.max_durability
			_durability_bar.value = item.durability
			_durability_bar.visible = true
			
			# Cor baseada na durabilidade
			var ratio = float(item.durability) / float(item.max_durability)
			if ratio > 0.5:
				_durability_bar.modulate = Color.GREEN
			elif ratio > 0.25:
				_durability_bar.modulate = Color.YELLOW
			else:
				_durability_bar.modulate = Color.RED
		else:
			_durability_bar.visible = false

func _update_style() -> void:
	if not is_inside_tree():
		return
	
	if _selection_border:
		_selection_border.visible = selected
	
	# Atualiza borda do painel
	var style = get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		if selected:
			style.border_color = Color(0.4, 0.8, 0.4, 1.0)
			style.border_width_bottom = 2
			style.border_width_top = 2
			style.border_width_left = 2
			style.border_width_right = 2
		else:
			style.border_color = Color(0.3, 0.3, 0.3, 1.0)
			style.border_width_bottom = 1
			style.border_width_top = 1
			style.border_width_left = 1
			style.border_width_right = 1

func _on_mouse_entered() -> void:
	slot_hovered.emit(self)
	
	# Efeito de hover
	var style = get_theme_stylebox("panel") as StyleBoxFlat
	if style and not selected:
		style.bg_color = Color(0.25, 0.25, 0.25, 1.0)

func _on_mouse_exited() -> void:
	# Remove efeito de hover
	var style = get_theme_stylebox("panel") as StyleBoxFlat
	if style and not selected:
		style.bg_color = Color(0.18, 0.18, 0.18, 1.0)

func _on_gui_input(event: InputEvent) -> void:
	if locked:
		return
	
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.pressed:
			slot_clicked.emit(self, mb.button_index)

# Minecraft não usa drag & drop nativo, mas sim pick/place com clique
# O Backpack gerencia isso através do _held_item

func clear() -> void:
	item = null

func is_empty() -> bool:
	return item == null

func get_item_tooltip() -> String:
	if not item:
		return ""
	
	var tooltip = "[b]%s[/b]\n" % item.name
	
	if item.description:
		tooltip += item.description + "\n"
	
	if item.has_durability:
		tooltip += "\nDurability: %d/%d" % [item.durability, item.max_durability]
	
	if item.stackable:
		tooltip += "\nStack: %d/%d" % [item.quantity, item.max_stack]
	
	# Rarity color
	var rarity_names = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
	if item.rarity < rarity_names.size():
		tooltip += "\n[color=%s]%s[/color]" % [item.get_rarity_color().to_html(), rarity_names[item.rarity]]
	
	return tooltip

func _make_custom_tooltip(for_text: String) -> Object:
	if not item:
		return null
	
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_color = item.get_rarity_color()
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Nome com cor de raridade
	var name_label = Label.new()
	name_label.text = item.name
	name_label.add_theme_color_override("font_color", item.get_rarity_color())
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)
	
	# Descrição
	if item.description:
		var desc_label = Label.new()
		desc_label.text = item.description
		desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size.x = 200
		vbox.add_child(desc_label)
	
	# Stats
	if item.has_durability:
		var dur_label = Label.new()
		dur_label.text = "Durability: %d/%d" % [item.durability, item.max_durability]
		dur_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		dur_label.add_theme_font_size_override("font_size", 11)
		vbox.add_child(dur_label)
	
	return panel
