@tool
## Machine - Máquina de Estados (Virtual Machine).
##
## Motor de execução que gerencia o estado atual e avalia transições.
## Executa ações do State: apply_velocity, spawn_projectile, play_animation.
## Requer referência ao Behavior. Conecta-se opcionalmente ao Backpack.
class_name Machine extends Node

const VALID_PARENTS = ["CharacterBody2D", "CharacterBody3D"]

signal state_changed(old_state: State, new_state: State)
signal state_action_executed(action: String, params: Dictionary)
signal combo_window_opened(current_state: State)
signal damage_dealt(target: Node, amount: int)

## Referência ao Behavior (obrigatório).
@export var behavior: Behavior
## Referência ao Backpack (opcional, para obter item equipado).
@export var backpack: Backpack
## Compose padrão (usado se não houver Backpack ou item equipado).
@export var default_compose: Compose

## Estado atual sendo executado.
var current_state: State = null
## Tempo no estado atual (segundos).
var time_in_state: float = 0.0
## Se a janela de combo está aberta
var combo_window_open: bool = false
## Velocidade aplicada pelo estado atual
var state_velocity: Vector2 = Vector2.ZERO
## Cooldowns ativos { state_name: remaining_time }
var cooldowns: Dictionary = {}

# Referência ao CharacterBody para aplicar física
var _character_body: Node = null
var _sprite: Sprite2D = null
var _animation_player: AnimationPlayer = null

func _ready() -> void:
	_validate_parent()
	_cache_references()
	
	if behavior:
		behavior.context_changed.connect(_on_context_changed)

func _cache_references() -> void:
	_character_body = get_parent() if _is_valid_parent() else null
	if _character_body:
		_sprite = _character_body.get_node_or_null("Sprite2D")
		_animation_player = _character_body.get_node_or_null("AnimationPlayer")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not _is_valid_parent():
		warnings.append("Machine deve ser filho de CharacterBody2D ou CharacterBody3D!")
	
	if not behavior:
		warnings.append("Machine requer referência ao Behavior!")
	
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
		push_error("[Machine] Deve ser filho de CharacterBody2D/3D!")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_process_cooldowns(delta)
	
	time_in_state += delta
	
	if current_state:
		_process_state(current_state, delta)
		
		# Verifica duração do estado
		if current_state.duration > 0 and time_in_state >= current_state.duration:
			_on_state_duration_ended()
		
		# Verifica janela de combo
		if current_state.combo_window_start > 0 and time_in_state >= current_state.combo_window_start:
			if not combo_window_open:
				combo_window_open = true
				combo_window_opened.emit(current_state)

func _process_cooldowns(delta: float) -> void:
	var to_remove: Array = []
	for key in cooldowns:
		cooldowns[key] -= delta
		if cooldowns[key] <= 0:
			to_remove.append(key)
	for key in to_remove:
		cooldowns.erase(key)

# ==================== STATE PROCESSING ====================

func _process_state(state: State, delta: float) -> void:
	# Apply physics from state
	if _character_body and _character_body is CharacterBody2D:
		var body = _character_body as CharacterBody2D
		
		# Calculate velocity based on state
		if not state.lock_movement:
			var input_dir = _get_input_direction()
			var target_speed = get_calculated_speed(state) * input_dir.x
			
			if state.acceleration > 0:
				body.velocity.x = move_toward(body.velocity.x, target_speed, state.acceleration * delta)
			else:
				body.velocity.x = target_speed
		
		# Apply friction
		if state.friction > 0 and is_zero_approx(body.velocity.x):
			body.velocity.x = move_toward(body.velocity.x, 0, state.friction * delta)
		
		# Gravity (unless ignored)
		if not state.ignore_gravity:
			if not body.is_on_floor():
				body.velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) * delta

func _get_input_direction() -> Vector2:
	# Override this or connect to your input system
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

# ==================== STATE ACTIONS ====================

## Aplica velocidade instantânea (ex: dash, knockback)
func apply_velocity(velocity: Vector2) -> void:
	if _character_body and _character_body is CharacterBody2D:
		var body = _character_body as CharacterBody2D
		body.velocity = velocity
		state_action_executed.emit("apply_velocity", {"velocity": velocity})

## Aplica força de pulo
func apply_jump(force: float = 0.0) -> void:
	if _character_body and _character_body is CharacterBody2D:
		var body = _character_body as CharacterBody2D
		var jump_force = force if force != 0 else (current_state.jump_force if current_state else -500.0)
		body.velocity.y = jump_force
		state_action_executed.emit("apply_jump", {"force": jump_force})

## Spawna um projétil
func spawn_projectile(offset: Vector2 = Vector2.ZERO) -> Node:
	if not current_state or not current_state.projectile_scene:
		return null
	
	var projectile = current_state.projectile_scene.instantiate()
	
	# Posição
	var spawn_pos = _character_body.global_position if _character_body else Vector2.ZERO
	spawn_pos += current_state.spawn_offset if current_state.spawn_offset else offset
	
	# Direção (baseada no flip do sprite)
	var direction = 1
	if _sprite and _sprite.flip_h:
		direction = -1
	
	projectile.global_position = spawn_pos
	
	# Se o projétil tiver propriedades comuns
	if "direction" in projectile:
		projectile.direction = direction
	if "speed" in projectile:
		projectile.speed = current_state.projectile_speed
	if "damage" in projectile:
		projectile.damage = get_calculated_damage(current_state)
	
	# Adicionar à cena
	get_tree().current_scene.add_child(projectile)
	
	state_action_executed.emit("spawn_projectile", {"projectile": projectile, "direction": direction})
	return projectile

## Toca animação
func play_animation(anim_name: String) -> void:
	if _animation_player and _animation_player.has_animation(anim_name):
		_animation_player.play(anim_name)
		state_action_executed.emit("play_animation", {"animation": anim_name})

## Aplica a textura/spritesheet do state
func apply_state_visual(state: State) -> void:
	if not _sprite or not state.texture:
		return
	
	_sprite.texture = state.texture
	_sprite.hframes = state.hframes
	_sprite.vframes = state.vframes
	
	state_action_executed.emit("apply_visual", {"texture": state.texture})

## Toca som do state
func play_state_sound(state: State) -> void:
	if not state.sound:
		return
	
	# Criar AudioStreamPlayer temporário
	var player = AudioStreamPlayer2D.new()
	player.stream = state.sound
	player.autoplay = true
	player.finished.connect(func(): player.queue_free())
	
	if _character_body:
		_character_body.add_child(player)
	
	state_action_executed.emit("play_sound", {"sound": state.sound})

# ==================== DAMAGE ====================

## Calcula dano final considerando stats e multiplicadores
func get_calculated_damage(state: State) -> int:
	if not state:
		return 0
	
	var base_damage = state.damage
	
	# Aplicar multiplicador de strength do CharacterSheet
	if behavior and behavior.character_sheet:
		var strength = behavior.get_stat("strength")
		if strength > 0:
			base_damage = int(base_damage * (1.0 + strength * 0.1))
	
	return base_damage

## Calcula velocidade final considerando stats
func get_calculated_speed(state: State) -> float:
	if not state:
		return 0.0
	
	var base_speed = 200.0  # Default
	
	if behavior and behavior.character_sheet:
		base_speed = behavior.get_stat("max_speed")
	
	return base_speed * state.speed_multiplier

## Executa hitbox de ataque melee
func execute_melee_attack(state: State) -> Array[Node]:
	if not state or state.area_size == Vector2.ZERO:
		return []
	
	var hit_targets: Array[Node] = []
	
	# Criar área de detecção temporária
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = state.area_size
	shape.shape = rect
	area.add_child(shape)
	
	# Posicionar
	var direction = 1
	if _sprite and _sprite.flip_h:
		direction = -1
	
	area.position = state.area_pivot * Vector2(direction, 1)
	
	if _character_body:
		_character_body.add_child(area)
	
	# Detectar overlaps
	await get_tree().physics_frame
	
	for body in area.get_overlapping_bodies():
		if body != _character_body and body.has_method("take_damage"):
			var damage = get_calculated_damage(state)
			body.take_damage(damage)
			hit_targets.append(body)
			damage_dealt.emit(body, damage)
	
	area.queue_free()
	return hit_targets

# ==================== TRANSITIONS ====================

func _on_context_changed(category: String, value: int) -> void:
	_try_transition()

func _on_state_duration_ended() -> void:
	combo_window_open = false
	
	# Check for next combo state
	if current_state and current_state.next_combo_state:
		# Don't auto-transition to combo, just make it available
		pass
	
	change_state(null)
	_try_transition()

func change_state(new_state: State, preserve_time: bool = false) -> void:
	var old_state = current_state
	
	if old_state:
		_exit_state(old_state)
	
	current_state = new_state
	combo_window_open = false
	
	if not preserve_time:
		time_in_state = 0.0
	
	if new_state:
		_enter_state(new_state)
	
	state_changed.emit(old_state, new_state)

func _enter_state(state: State) -> void:
	# Apply visual
	apply_state_visual(state)
	
	# Play sound
	play_state_sound(state)
	
	# Set cooldown
	if state.cooldown > 0:
		cooldowns[state.name] = state.cooldown

func _exit_state(state: State) -> void:
	# Reset state velocity if needed
	if state.lock_movement:
		state_velocity = Vector2.ZERO

func _try_transition() -> void:
	var compose = _get_active_compose()
	if not compose:
		return
	
	var candidates = _get_candidates(compose)
	var best = _find_best_match(candidates)
	
	if best and best != current_state:
		# Check cooldown
		if best.name in cooldowns:
			return
		
		change_state(best)

func _get_active_compose() -> Compose:
	# Prioridade: Backpack -> Item -> Compose
	if backpack:
		var equipped = backpack.get_equipped_compose()
		if equipped:
			return equipped
	
	return default_compose

func _get_candidates(compose: Compose) -> Array[State]:
	var candidates: Array[State] = []
	
	if compose:
		candidates.append_array(compose.get_move_states())
		candidates.append_array(compose.get_attack_states())
	
	# Adiciona states do Behavior (via SkillTree)
	if behavior:
		candidates.append_array(behavior.get_all_available_states())
	
	return candidates

func _find_best_match(candidates: Array[State]) -> State:
	if candidates.is_empty():
		return null
	
	if not behavior:
		return candidates[0]
	
	var best: State = null
	var best_score: int = -1
	
	for state in candidates:
		if _matches_context(state):
			# Check required skill
			if not state.required_skill.is_empty():
				if not behavior.skill_tree or not behavior.skill_tree.has_skill(state.required_skill):
					continue
			
			var score = _calculate_score(state)
			if score > best_score:
				best_score = score
				best = state
	
	return best

func _matches_context(state: State) -> bool:
	if not behavior or not state.entry_requirements:
		return true
	
	for category in state.entry_requirements.keys():
		var required = state.entry_requirements[category]
		var current = behavior.get_context(category)
		
		# ANY (0 ou negativo)
		if required <= 0:
			continue
		
		if current != required:
			return false
	
	return true

func _calculate_score(state: State) -> int:
	var score = 0
	
	# Priority override (highest weight)
	score += state.priority_override * 100
	
	# Specificity bonus
	if state.entry_requirements:
		for category in state.entry_requirements.keys():
			if state.entry_requirements[category] > 0:
				score += 10
	
	# Combo chain bonus
	if current_state and state in [current_state.next_combo_state]:
		if combo_window_open:
			score += 50
	
	# Previous state chain bonus
	if current_state and state.previous_states.has(current_state):
		score += 20
	
	return score
