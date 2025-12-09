## SkillContext — Contexto de execução para SkillComponents.
##
## Fornece acesso ao personagem, skill tree e inventário.
class_name SkillContext extends RefCounted

## Referência à skill sendo usada/aprendida
var skill: Resource = null

## Referência ao CharacterSheet
var character_sheet: Resource = null

## Referência ao SkillTree
var skill_tree: Resource = null

## Referência ao Inventory (para verificar requisitos de itens)
var inventory: Resource = null

## Referência ao Behavior
var behavior: Node = null

## Lista de IDs de skills já desbloqueadas
var unlocked_skill_ids: Array = []

## Nível atual da skill (para multi-level skills)
var skill_level: int = 1

## Alvo da skill (para skills ativas)
var target: Resource = null

## Inicializa o contexto
func setup(p_skill: Resource, p_character: Resource, p_behavior: Node = null) -> void:
	skill = p_skill
	character_sheet = p_character
	behavior = p_behavior
	
	if behavior:
		if "skill_tree" in behavior and behavior.skill_tree:
			skill_tree = behavior.skill_tree
			unlocked_skill_ids = behavior.skill_tree.get_unlocked_skill_ids() if behavior.skill_tree.has_method("get_unlocked_skill_ids") else []
		if "backpack" in behavior and behavior.backpack and "inventory_data" in behavior.backpack:
			inventory = behavior.backpack.inventory_data
