## IdentityComponent — Identidade e metadados do Item.
class_name IdentityItemComponent extends ItemComponent

@export var id: String = ""
@export var display_name: String = "Item"
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var category: int = 0  # Item.Category enum
@export var rarity: int = 0    # Item.Rarity enum

static func _get_component_name() -> String:
	return "Identity"

static func _get_component_color() -> Color:
	return Color("#3b82f6")

static func _get_component_fields() -> Array:
	return [
		{"name": "id", "type": "String", "default": ""},
		{"name": "display_name", "type": "String", "default": "Item"},
		{"name": "description", "type": "String", "default": ""},
		{"name": "icon", "type": "Texture2D", "default": null},
		{"name": "category", "type": "enum", "options": ["Weapon", "Consumable", "Material", "Armor", "Accessory", "Key"], "default": 0},
		{"name": "rarity", "type": "enum", "options": ["Common", "Uncommon", "Rare", "Epic", "Legendary"], "default": 0}
	]
