## Modifier Block - Bloco de modificador para Items/Skills
## Define alterações em atributos.
class_name ModifierBlock extends BlockBase

enum ModifierType { FLAT, PERCENT_ADD, PERCENT_MULT }

@export var attribute: String = "damage"  # HP, damage, speed, etc.
@export var modifier_type: ModifierType = ModifierType.FLAT
@export var value: float = 0.0
