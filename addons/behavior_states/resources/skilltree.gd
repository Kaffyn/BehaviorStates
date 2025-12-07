## SkillTree - Árvore de Habilidades.
##
## Container que organiza Skills em uma estrutura de progressão.
class_name SkillTree extends Resource

@export_group("Identity")
@export var id: String = ""
@export var name: String = "Skill Tree"
@export_multiline var description: String = ""

@export_group("Skills")
## Todas as skills desta árvore.
@export var skills: Array[Skill] = []

@export_group("Progression")
## Pontos de habilidade disponíveis.
@export var available_points: int = 0
## Pontos totais ganhos.
@export var total_points: int = 0

# Cache
var _skills_map: Dictionary = {}
var _initialized: bool = false

func initialize() -> void:
	if _initialized:
		return
	
	_skills_map.clear()
	for skill in skills:
		if skill and skill.id:
			_skills_map[skill.id] = skill
	
	_initialized = true

func get_skill_by_id(id: String) -> Skill:
	if not _initialized:
		initialize()
	return _skills_map.get(id)

func get_unlocked_skills() -> Array[Skill]:
	var unlocked: Array[Skill] = []
	for skill in skills:
		if skill and skill.is_unlocked():
			unlocked.append(skill)
	return unlocked

func get_available_skills(player_level: int) -> Array[Skill]:
	var available: Array[Skill] = []
	var unlocked = get_unlocked_skills()
	
	for skill in skills:
		if skill and skill.can_unlock(player_level, unlocked, available_points):
			available.append(skill)
	
	return available

func unlock_skill(skill: Skill) -> bool:
	if skill and skill in skills:
		if skill.can_unlock(0, get_unlocked_skills(), available_points):
			if skill.unlock():
				available_points -= skill.cost
				return true
	return false

func add_points(amount: int) -> void:
	available_points += amount
	total_points += amount

func get_all_unlocked_states() -> Array[State]:
	var states: Array[State] = []
	for skill in skills:
		if skill and skill.is_unlocked():
			states.append_array(skill.get_unlocked_states())
	return states
