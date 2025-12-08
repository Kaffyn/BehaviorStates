## Skill - Nó de Habilidade Individual.
##
## Representa uma habilidade que pode ser desbloqueada e que injeta States no personagem.
class_name Skill extends Resource

@export_group("Identity")
@export var id: String = ""
@export var name: String = "Skill"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Requirements")
## Nível mínimo necessário para desbloquear.
@export var required_level: int = 0
## Skills que precisam estar desbloqueadas antes.
@export var prerequisites: Array[Skill] = []
## Custo em pontos de habilidade.
@export var cost: int = 1

@export_group("Effects")
## States que esta skill desbloqueia.
@export var unlocked_states: Array[State] = []
## Compose adicional que esta skill fornece.
@export var unlocked_compose: Compose

@export_group("Progression")
## Nível máximo da skill.
@export var max_level: int = 1

# Stateless Logic
func can_unlock(character_sheet: CharacterSheet, unlocked_ids: Array) -> bool:
	# Requires CharacterSheet to have 'level' and 'skill_points'
	if character_sheet.level < required_level:
		return false
	
	for prereq in prerequisites:
		if prereq and not prereq.id in unlocked_ids:
			return false
			
	return true

