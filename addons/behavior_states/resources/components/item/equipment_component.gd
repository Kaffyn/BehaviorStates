## EquipmentComponent — Comportamento de item equipável.
class_name EquipmentItemComponent extends ItemComponent

enum EquipSlot { NONE, MAIN_HAND, OFF_HAND, HEAD, CHEST, LEGS, FEET, RING, AMULET }

@export var equip_slot: EquipSlot = EquipSlot.NONE
@export var compose: Resource  # Compose (moveset)
@export var equip_effects: Array[Resource] = []  # Effects passivos

func on_equip(ctx: ItemContext) -> void:
	if not enabled:
		return
	
	# Aplica efeitos passivos
	for effect in equip_effects:
		if effect and effect.has_method("apply"):
			effect.apply(ctx.character_sheet)
	
	ctx.equip_slot = EquipSlot.keys()[equip_slot]

func on_unequip(ctx: ItemContext) -> void:
	if not enabled:
		return
	
	# Remove efeitos passivos
	for effect in equip_effects:
		if effect and effect.has_method("remove"):
			effect.remove(ctx.character_sheet)

static func _get_component_name() -> String:
	return "Equipment"

static func _get_component_color() -> Color:
	return Color("#8b5cf6")

static func _get_component_fields() -> Array:
	return [
		{"name": "equip_slot", "type": "enum", "options": ["None", "MainHand", "OffHand", "Head", "Chest", "Legs", "Feet", "Ring", "Amulet"], "default": 0},
		{"name": "compose", "type": "Compose", "default": null},
		{"name": "equip_effects", "type": "Array[Effects]", "default": []}
	]
