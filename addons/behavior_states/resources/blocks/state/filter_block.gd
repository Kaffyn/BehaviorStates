## Filter Block - Bloco de filtro para States
## Define condições de ativação baseadas no contexto.
class_name FilterBlock extends BlockBase

enum Comparison { EQUALS, NOT_EQUALS, GREATER, LESS }

@export var filter_key: String = "Physics"  # Physics, Motion, Weapon, etc.
@export var filter_value: int = 0
@export var comparison: Comparison = Comparison.EQUALS
