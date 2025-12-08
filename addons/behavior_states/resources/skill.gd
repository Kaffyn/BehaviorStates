@tool
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
## Items necessários no inventário (ex: "ancient_tome": 1). Consumidos ao aprender.
@export var req_items: Dictionary = {}

# ============= UNLOCKS =============
@export_group("Unlocks")
## States de comportamento que esta skill injeta no personagem.
@export var unlocks_states: Array[State] = []
## Items/Crafts desbloqueados ao aprender (podem ser craftados).
@export var unlocks_items: Array[Item] = []
## Tags de contexto que esta skill ativa globalmente (ex: "can_wall_jump", "can_double_jump").
@export var context_tags: Dictionary = {}

# ============= EFFECTS (Passive) =============
@export_group("Passive Effects")
## Modificadores passivos aplicados enquanto a skill está ativa.
@export var passive_effects: Array[Effects] = []

# ============= EFFECTS (Active) =============
@export_group("Active Skill")
## Efeitos aplicados ao USAR a skill (para ACTIVE skills).
@export var effects_on_use: Array[Effects] = []
## Cooldown em segundos (para ACTIVE skills).
@export var cooldown: float = 0.0
## Custo de recurso (Mana, Stamina) para usar.
@export_enum("None", "Mana", "Stamina", "Health") var cost_type: int = 0
@export var cost_amount: int = 0
## State executado ao usar (para ACTIVE skills com animação).
@export var activation_state: State

# ============= PROGRESSION =============
@export_group("Progression")
## Nível máximo desta skill (para skills com upgrade).
@export var max_level: int = 1
## Se true, os efeitos escalam com o nível da skill.
@export var scales_with_level: bool = false
## Multiplicador de scaling por nível (ex: 1.1 = +10% por nível).
@export var level_scaling: float = 1.0

# ============= VISUAL =============
@export_group("Visual")
## VFX exibido ao aprender a skill.
@export var learn_vfx: PackedScene
## Som tocado ao aprender.
@export var learn_sound: AudioStream

# ============= LOGIC =============

## Verifica se o personagem cumpre todos os requisitos para destravar esta skill.
func can_unlock(sheet: Resource, unlocked_ids: Array, inventory: Resource = null) -> bool:
	if not sheet: return false
	
	# 1. Level Check
	if "level" in sheet and sheet.level < req_level:
		return false
	
	# 2. Prerequisite Check
	for prereq in prerequisites:
		if prereq and not prereq.id in unlocked_ids:
			return false
	
	# 3. Attribute Check
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
	
	# 5. Item Check
	if inventory and "items" in inventory:
		for item_id in req_items:
			var required = req_items[item_id]
			var found = 0
			for item in inventory.items:
				if item and item.id == item_id:
					found += item.quantity
			if found < required:
				return false
			
	return true

## Aplica os efeitos da skill ao aprender.
func on_learn(sheet: Resource) -> void:
	# Apply passive effects
	for effect in passive_effects:
		if effect:
			effect.apply(sheet)
	
	# Apply context tags
	if "context_tags" in sheet:
		for tag in context_tags:
			sheet.context_tags[tag] = context_tags[tag]

## Remove os efeitos da skill (se for possível "desaprender").
func on_unlearn(sheet: Resource) -> void:
	# Remove passive effects
	for effect in passive_effects:
		if effect:
			effect.remove(sheet)
	
	# Remove context tags
	if "context_tags" in sheet:
		for tag in context_tags:
			sheet.context_tags.erase(tag)

## Usa a skill ativa.
## Retorna true se usada com sucesso.
func use(sheet: Resource, target: Resource = null) -> bool:
	if skill_type != SkillType.ACTIVE and skill_type != SkillType.ULTIMATE:
		return false
	
	# Check cost
	if cost_type > 0 and cost_amount > 0:
		var resource_name = ["", "mana", "stamina", "health"][cost_type]
		var current_key = "current_" + resource_name
		if current_key in sheet:
			if sheet.get(current_key) < cost_amount:
				return false
			sheet.set(current_key, sheet.get(current_key) - cost_amount)
	
	# Apply use effects
	var effect_target = target if target else sheet
	for effect in effects_on_use:
		if effect:
			effect.apply(effect_target)
	
	return true

## Retorna cor baseada na raridade.
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.GREEN
		Rarity.RARE: return Color.BLUE
		Rarity.EPIC: return Color.PURPLE
		Rarity.LEGENDARY: return Color.ORANGE
	return Color.WHITE
