## Requirement Block - Bloco de requisito para Skills
## Define condições para unlock/uso de Skills.
class_name RequirementBlock extends BlockBase

enum RequirementType { LEVEL, SKILL_UNLOCKED, ITEM_OWNED, STAT_MIN }

@export var requirement_type: RequirementType = RequirementType.LEVEL
@export var target_id: String = ""  # ID do skill/item requerido
@export var min_value: int = 1
