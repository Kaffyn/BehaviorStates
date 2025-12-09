@tool
class_name RarityComponent extends ItemComponent

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }

@export var rarity: Rarity = Rarity.COMMON
@export var color: Color = Color.WHITE

func get_component_name() -> String:
	return "Rarity"

func get_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.GREEN
		Rarity.RARE: return Color.BLUE
		Rarity.EPIC: return Color.PURPLE
		Rarity.LEGENDARY: return Color.ORANGE
		Rarity.MYTHIC: return Color.RED
		_: return color
