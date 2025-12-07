## Action Block - Bloco de ação para States
## Define o que acontece quando o State é executado.
class_name ActionBlock extends BlockBase

enum ActionType { DAMAGE, HEAL, SPAWN, APPLY_FORCE, PLAY_ANIMATION, PLAY_SOUND }
enum Target { SELF, ENEMY, ALLY, ALL }

@export var action_type: ActionType = ActionType.DAMAGE
@export var target: Target = Target.ENEMY
@export var value: float = 10.0
@export var duration: float = 0.0
