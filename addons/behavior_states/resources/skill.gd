
## Skill - Nó de Habilidade Individual (Full Specification).
##
## Representa uma habilidade, talento ou perk que pode ser aprendido.
## Suporta requisitos complexos (Stats, Kills, Itens) e efeitos múltiplos (States, Modifiers).
class_name Skill extends Resource

enum SkillType { PASSIVE, ACTIVE, ULTIMATE, META_PERK }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

# ============= IDENTITY =============
@export_group("Identity")
@export var id: String = ""
@export var name: String = "Skill"
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var skill_type: SkillType = SkillType.PASSIVE
@export var rarity: Rarity = Rarity.COMMON

# ============= REQUIREMENTS =============
@export_group("Requirements")
## Nível de personagem necessário.
@export var req_level: int = 1
## Skills antecedentes na árvore.
@export var prerequisites: Array[Skill] = []
## Custo em Skill Points (SP).
@export var cost: int = 1
## Se true, aprende automaticamente quando requisitos são atendidos (Achievement).
@export var auto_learn: bool = false

@export_subgroup("Advanced Requirements")
## Atributos base mínimos (ex: "strength": 10).
@export var req_attributes: Dictionary = {}
## Estatísticas de jogo mínimas (ex: "kills": 100).
@export var req_statistics: Dictionary = {}

# ============= EFFECTS =============
@export_group("Effects")
## States de comportamento que esta skill injeta no personagem.
@export var unlocked_states: Array[State] = []
## Modificadores passivos de estatísticas (ex: +10% Dano).
@export var modifiers: Array[ModifierBlock] = []
## Tags de contexto que esta skill ativa globalmente (ex: "can_wall_jump").
@export var context_tags: Dictionary = {}

# ============= PROGRESSION =============
@export_group("Progression")
@export var max_level: int = 1

# ============= LOGIC =============

## Verifica se o personagem cumpre todos os requisitos para destravar esta skill.
func can_unlock(sheet: Resource, unlocked_ids: Array) -> bool:
	if not sheet: return false
	
	# 1. Level Check
	if "level" in sheet and sheet.level < req_level:
		return false
	
	# 2. Prerequisite Check
	for prereq in prerequisites:
		if prereq and not prereq.id in unlocked_ids:
			return false
	
	# 3. Attribute Check (Requires CharacterSheet to support attributes access)
	if "attributes" in sheet:
		for attr in req_attributes:
			var val = sheet.attributes.get(attr, 0)
			if val < req_attributes[attr]:
				return false
				
	# 4. Statistics Check (Achievements)
	if "statistics" in sheet:
		for stat in req_statistics:
			var val = sheet.statistics.get(stat, 0)
			if val < req_statistics[stat]:
				return false
			
	return true
