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

# Cache
var _skills_map: Dictionary = {}

func get_skill_by_id(skill_id: String) -> Skill:
	if _skills_map.is_empty() and not skills.is_empty():
		for s in skills: 
			if s: _skills_map[s.id] = s
	return _skills_map.get(skill_id)

func get_available_skills(sheet: CharacterSheet) -> Array[Skill]:
	var available: Array[Skill] = []
	if not sheet: return available
	
	# Pass 1: Get unlocked IDs
	var unlocked_ids = sheet.unlocked_skills.keys()
	
	# Pass 2: Check candidates
	for skill in skills:
		if not skill: continue
		# If already maxed out, not available for unlock (maybe for upgrade?)
		if sheet.has_skill(skill.id):
			if sheet.unlocked_skills[skill.id] >= skill.max_level:
				continue
		
		if skill.can_unlock(sheet, unlocked_ids):
			available.append(skill)
			
	return available

