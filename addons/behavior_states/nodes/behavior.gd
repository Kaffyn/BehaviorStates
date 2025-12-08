@tool
## Behavior - O Orquestrador de Gameplay e Intenção.
##
## Gerencia "O que o Player QUER fazer", traduzindo inputs em contexto para a Machine.
## Deve ser filho de CharacterBody2D ou CharacterBody3D.
class_name Behavior extends Node

const VALID_PARENTS = ["CharacterBody2D", "CharacterBody3D"]

signal context_changed(category: String, value: int)
signal skill_learned(skill: Skill)
signal effect_applied(effect: Effects)

## CharacterSheet do personagem (stats).
@export var character_sheet: CharacterSheet
## SkillTree do personagem (progressão).
@export var skill_tree: SkillTree
## Referência ao Backpack (opcional, para verificar item equipado).
@export var backpack: Backpack

## Contexto atual (dicionário categoria -> valor).
var context: Dictionary = {}
## Context tags ativadas por Skills (ex: "can_wall_jump": true)
var context_tags: Dictionary = {}
## Efeitos ativos temporários
var active_effects: Array[Dictionary] = []  # [{effect, remaining_time, stacks}]

func _ready() -> void:
	_validate_parent()
	_apply_skill_context_tags()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_process_active_effects(delta)

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

# ==================== CONTEXT ====================

func set_context(category: String, value: int) -> void:
	var old_value = context.get(category, 0)
	if old_value != value:
		context[category] = value
		context_changed.emit(category, value)

func get_context(category: String) -> int:
	return context.get(category, 0)

## Verifica se um context tag está ativo (via Skills ou Items)
func has_context_tag(tag: String) -> bool:
	return context_tags.get(tag, false)

## Aplica context tags de todas as skills aprendidas
func _apply_skill_context_tags() -> void:
	if not skill_tree:
		return
	
	context_tags.clear()
	for skill in skill_tree.get_unlocked_skills():
		if skill.context_tags:
			for tag in skill.context_tags:
				context_tags[tag] = skill.context_tags[tag]

# ==================== SKILLS ====================

## Aprende uma skill se os requisitos forem atendidos
func learn_skill(skill: Skill) -> bool:
	if not skill_tree or not character_sheet:
		return false
	
	var unlocked_ids = skill_tree.get_unlocked_skill_ids()
	var inventory = backpack.inventory if backpack else null
	
	if not skill.can_unlock(character_sheet, unlocked_ids, inventory):
		return false
	
	# Consumir skill points
	if character_sheet.skill_points < skill.cost:
		return false
	character_sheet.skill_points -= skill.cost
	
	# Adicionar skill
	skill_tree.unlock_skill(skill)
	skill.on_learn(character_sheet)
	
	# Atualizar context tags
	for tag in skill.context_tags:
		context_tags[tag] = skill.context_tags[tag]
	
	skill_learned.emit(skill)
	return true

## Usa uma skill ativa
func use_skill(skill: Skill, target: Resource = null) -> bool:
	if not skill or skill.skill_type == Skill.SkillType.PASSIVE:
		return false
	
	return skill.use(character_sheet, target if target else character_sheet)

# ==================== EFFECTS ====================

## Aplica um efeito ao personagem
func apply_effect(effect: Effects) -> void:
	if not effect or not character_sheet:
		return
	
	match effect.effect_type:
		Effects.EffectType.INSTANT:
			effect.apply(character_sheet)
		
		Effects.EffectType.TEMPORARY:
			# Check stacking
			var existing_idx = -1
			for i in range(active_effects.size()):
				if active_effects[i]["effect"] == effect:
					existing_idx = i
					break
			
			if existing_idx >= 0 and effect.stackable:
				if active_effects[existing_idx]["stacks"] < effect.max_stacks:
					active_effects[existing_idx]["stacks"] += 1
					active_effects[existing_idx]["remaining_time"] = effect.duration
					effect.apply(character_sheet)
			elif existing_idx < 0:
				effect.apply(character_sheet)
				active_effects.append({
					"effect": effect,
					"remaining_time": effect.duration,
					"stacks": 1,
					"tick_timer": 0.0
				})
		
		Effects.EffectType.PERMANENT:
			effect.apply(character_sheet)
	
	effect_applied.emit(effect)

## Processa efeitos ativos (chamado em _process)
func _process_active_effects(delta: float) -> void:
	var to_remove: Array[int] = []
	
	for i in range(active_effects.size()):
		var data = active_effects[i]
		var effect = data["effect"] as Effects
		
		# Tick timer
		data["tick_timer"] += delta
		if data["tick_timer"] >= effect.tick_interval:
			data["tick_timer"] = 0.0
			effect.process_tick(character_sheet)
		
		# Duration
		data["remaining_time"] -= delta
		if data["remaining_time"] <= 0:
			# Remove effect
			for _s in range(data["stacks"]):
				effect.remove(character_sheet)
			to_remove.append(i)
	
	# Remove expired effects (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		active_effects.remove_at(to_remove[i])

## Remove um efeito específico
func remove_effect(effect: Effects) -> void:
	for i in range(active_effects.size()):
		if active_effects[i]["effect"] == effect:
			for _s in range(active_effects[i]["stacks"]):
				effect.remove(character_sheet)
			active_effects.remove_at(i)
			return

# ==================== STATES ====================

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

# ==================== STATS ====================

func get_stat(stat_name: String) -> float:
	if not character_sheet:
		return 0.0
	
	match stat_name:
		"max_health": return float(character_sheet.max_health)
		"current_health": return float(character_sheet.current_health) if "current_health" in character_sheet else float(character_sheet.max_health)
		"max_stamina": return character_sheet.max_stamina
		"current_stamina": return character_sheet.current_stamina if "current_stamina" in character_sheet else character_sheet.max_stamina
		"max_speed": return character_sheet.max_speed
		"jump_force": return character_sheet.jump_force
		"level": return float(character_sheet.level) if "level" in character_sheet else 1.0
		_: 
			# Try to get from attributes
			if "attributes" in character_sheet:
				return float(character_sheet.attributes.get(stat_name, 0))
			return 0.0

func modify_stat(stat_name: String, amount: float) -> void:
	if not character_sheet:
		return
	
	match stat_name:
		"current_health":
			if "current_health" in character_sheet:
				character_sheet.current_health = clamp(
					character_sheet.current_health + int(amount),
					0,
					character_sheet.max_health
				)
		"current_stamina":
			if "current_stamina" in character_sheet:
				character_sheet.current_stamina = clamp(
					character_sheet.current_stamina + amount,
					0,
					character_sheet.max_stamina
				)
		"experience":
			if "experience" in character_sheet:
				character_sheet.experience += int(amount)
