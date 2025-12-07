## Trigger Block - Bloco de gatilho para States
## Define quando callbacks são disparados.
class_name TriggerBlock extends BlockBase

enum TriggerType { ON_ENTER, ON_EXIT, ON_UPDATE, ON_HIT, ON_TIMEOUT }

@export var trigger_type: TriggerType = TriggerType.ON_ENTER
@export var call_method: String = ""  # Nome do método a chamar
@export var delay: float = 0.0
