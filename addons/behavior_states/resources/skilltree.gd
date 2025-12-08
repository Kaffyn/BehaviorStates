@tool
## SkillTree - Árvore de Habilidades.
##
## Container que organiza Skills em uma estrutura de progressão.
## Suporta posicionamento 2D para visualização em grafo.
class_name SkillTree extends Resource

@export_group("Identity")
@export var id: String = ""
@export var name: String = "Skill Tree"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Skills")
## Todas as skills desta árvore.
@export var skills: Array[Skill] = []

@export_group("Layout")
## Posições das skills no grafo (2D). { skill_id: Vector2 }
@export var positions: Dictionary = {}
## Espaçamento entre níveis
@export var tier_spacing: float = 150.0
## Espaçamento horizontal
@export var horizontal_spacing: float = 120.0

# Cache
var _skills_map: Dictionary = {}
var _unlocked_skills: Dictionary = {}  # { skill_id: level }

func _init() -> void:
	_rebuild_cache()

func _rebuild_cache() -> void:
	_skills_map.clear()
	for s in skills:
		if s:
			_skills_map[s.id] = s

func get_skill_by_id(skill_id: String) -> Skill:
	if _skills_map.is_empty() and not skills.is_empty():
		_rebuild_cache()
	return _skills_map.get(skill_id)

func get_skill_position(skill: Skill) -> Vector2:
	if skill and skill.id in positions:
		return positions[skill.id]
	return Vector2.ZERO

func set_skill_position(skill: Skill, pos: Vector2) -> void:
	if skill:
		positions[skill.id] = pos

## Retorna skills que podem ser desbloqueadas dado o estado atual
func get_available_skills(sheet: CharacterSheet) -> Array[Skill]:
	var available: Array[Skill] = []
	if not sheet: return available
	
	var unlocked_ids = sheet.unlocked_skills.keys()
	
	for skill in skills:
		if not skill: continue
		
		# Se já no máximo, não disponível
		if sheet.has_skill(skill.id):
			if sheet.unlocked_skills[skill.id] >= skill.max_level:
				continue
		
		if skill.can_unlock(sheet, unlocked_ids):
			available.append(skill)
			
	return available

## Retorna todas as skills já desbloqueadas
func get_unlocked_skills() -> Array[Skill]:
	var unlocked: Array[Skill] = []
	for skill in skills:
		if skill and skill.id in _unlocked_skills:
			unlocked.append(skill)
	return unlocked

## Retorna IDs das skills desbloqueadas
func get_unlocked_skill_ids() -> Array:
	return _unlocked_skills.keys()

## Verifica se tem uma skill
func has_skill(skill_id: String) -> bool:
	return skill_id in _unlocked_skills

## Desbloqueia uma skill (chamado pelo Behavior)
func unlock_skill(skill: Skill) -> bool:
	if not skill:
		return false
	
	if skill.id in _unlocked_skills:
		if _unlocked_skills[skill.id] < skill.max_level:
			_unlocked_skills[skill.id] += 1
			return true
	else:
		_unlocked_skills[skill.id] = 1
		return true
	
	return false

## Retorna o nível atual de uma skill
func get_skill_level(skill_id: String) -> int:
	return _unlocked_skills.get(skill_id, 0)

## Retorna todos os States desbloqueados por todas as skills
func get_all_unlocked_states() -> Array[State]:
	var states: Array[State] = []
	for skill_id in _unlocked_skills:
		var skill = get_skill_by_id(skill_id)
		if skill and skill.unlocks_states:
			states.append_array(skill.unlocks_states)
	return states

## Organiza skills automaticamente em tiers baseado em prerequisites
func auto_layout() -> void:
	var tiers: Dictionary = {}  # { skill_id: tier_level }
	
	# Primeira passada: skills sem prerequisites = tier 0
	for skill in skills:
		if not skill: continue
		if skill.prerequisites.is_empty():
			tiers[skill.id] = 0
	
	# Próximas passadas: skill.tier = max(prereq.tier) + 1
	var changed = true
	while changed:
		changed = false
		for skill in skills:
			if not skill or skill.id in tiers: continue
			
			var can_place = true
			var max_prereq_tier = -1
			
			for prereq in skill.prerequisites:
				if prereq and prereq.id in tiers:
					max_prereq_tier = max(max_prereq_tier, tiers[prereq.id])
				else:
					can_place = false
					break
			
			if can_place and max_prereq_tier >= 0:
				tiers[skill.id] = max_prereq_tier + 1
				changed = true
	
	# Agrupar por tier
	var tier_groups: Dictionary = {}  # { tier: [skills] }
	for skill_id in tiers:
		var tier = tiers[skill_id]
		if not tier in tier_groups:
			tier_groups[tier] = []
		tier_groups[tier].append(get_skill_by_id(skill_id))
	
	# Posicionar
	positions.clear()
	for tier in tier_groups:
		var group = tier_groups[tier] as Array
		var y = tier * tier_spacing
		var total_width = (group.size() - 1) * horizontal_spacing
		var start_x = -total_width / 2
		
		for i in range(group.size()):
			var skill = group[i] as Skill
			positions[skill.id] = Vector2(start_x + i * horizontal_spacing, y)
