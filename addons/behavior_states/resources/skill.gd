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
## Nível atual da skill (0 = não desbloqueada).
@export var current_level: int = 0
## Nível máximo da skill.
@export var max_level: int = 1

func is_unlocked() -> bool:
	return current_level > 0

func can_unlock(player_level: int, unlocked_skills: Array[Skill], available_points: int) -> bool:
	if current_level >= max_level:
		return false
	if player_level < required_level:
		return false
	if available_points < cost:
		return false
	
	for prereq in prerequisites:
		if prereq and not prereq.is_unlocked():
			return false
	
	return true

func unlock() -> bool:
	if current_level < max_level:
		current_level += 1
		return true
	return false

func get_unlocked_states() -> Array[State]:
	if is_unlocked():
		return unlocked_states
	return []
