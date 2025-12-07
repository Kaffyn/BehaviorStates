## Unlock Block - Bloco de desbloqueio para Skills
## Define o que é desbloqueado quando a Skill é adquirida.
class_name UnlockBlock extends BlockBase

enum UnlockType { STATE, ABILITY, PASSIVE, STAT_BONUS }

@export var unlock_type: UnlockType = UnlockType.STATE
@export var unlocked_resource: Resource = null  # State, outro Skill, etc.
@export var bonus_value: float = 0.0
