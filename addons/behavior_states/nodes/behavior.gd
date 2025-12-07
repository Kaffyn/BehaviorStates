@tool
## Behavior - O Orquestrador de Gameplay e Intenção.
##
## Gerencia "O que o Player QUER fazer", traduzindo inputs em contexto para a Machine.
## Deve ser filho de CharacterBody2D ou CharacterBody3D.
class_name Behavior extends Node

const VALID_PARENTS = ["CharacterBody2D", "CharacterBody3D"]

signal context_changed(category: String, value: int)

## CharacterSheet do personagem (stats).
@export var character_sheet: CharacterSheet
## SkillTree do personagem (progressão).
@export var skill_tree: SkillTree
## Referência ao Backpack (opcional, para verificar item equipado).
@export var backpack: Backpack

## Contexto atual (dicionário categoria -> valor).
var context: Dictionary = {}

func _ready() -> void:
	_validate_parent()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not _is_valid_parent():
		warnings.append("Behavior deve ser filho de CharacterBody2D ou CharacterBody3D!")
	
	if not character_sheet:
		warnings.append("Behavior precisa de um CharacterSheet!")
	
	return warnings

func _is_valid_parent() -> bool:
	var parent = get_parent()
	if not parent:
		return false
	return parent.get_class() in VALID_PARENTS or parent is CharacterBody2D or parent is CharacterBody3D

func _validate_parent() -> void:
	if Engine.is_editor_hint():
		return
	
	if not _is_valid_parent():
		push_error("[Behavior] Deve ser filho de CharacterBody2D/3D!")

func set_context(category: String, value: int) -> void:
	var old_value = context.get(category, 0)
	if old_value != value:
		context[category] = value
		context_changed.emit(category, value)

func get_context(category: String) -> int:
	return context.get(category, 0)

func get_character_body() -> Node:
	return get_parent() if _is_valid_parent() else null

func get_all_available_states() -> Array[State]:
	var states: Array[State] = []
	
	# Adiciona states desbloqueados pela SkillTree
	if skill_tree:
		states.append_array(skill_tree.get_all_unlocked_states())
	
	# Adiciona states do item equipado no Backpack
	if backpack:
		var compose = backpack.get_equipped_compose()
		if compose:
			states.append_array(compose.get_move_states())
			states.append_array(compose.get_attack_states())
	
	return states

func get_stat(stat_name: String) -> float:
	if not character_sheet:
		return 0.0
	
	match stat_name:
		"max_health": return float(character_sheet.max_health)
		"max_stamina": return character_sheet.max_stamina
		"max_speed": return character_sheet.max_speed
		"jump_force": return character_sheet.jump_force
		_: return 0.0
