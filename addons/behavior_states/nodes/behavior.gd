@tool
class_name Behavior extends Node

signal context_changed(category: String, value: int)
signal effect_applied(effect: Effect)
signal skill_learned(skill: Skill)

@export var character_sheet: CharacterSheet
@export var skill_tree: SkillTree
@export var backpack: Backpack

# Context for Queries
var context: Dictionary = {}

# Active Effect Contexts
var active_contexts: Array[EffectContext] = []

func _ready() -> void:
	# Initialize things if needed
	pass

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_process_effects(delta)

# ==================== CONTEXT ====================

func set_context(category: String, value: int) -> void:
	if context.get(category, 0) != value:
		context[category] = value
		context_changed.emit(category, value)

func get_context(category: String) -> int:
	return context.get(category, 0)

# ==================== STATS ====================

func get_stat(stat_name: String) -> Variant:
	if not character_sheet:
		return 0.0
	return character_sheet.get_stat(stat_name)

func modify_stat(stat_name: String, amount: float) -> void:
	if not character_sheet:
		return
	var current = get_stat(stat_name)
	character_sheet.set_stat(stat_name, current + amount)

# ==================== EFFECTS ====================

func apply_effect(effect: Effect) -> void:
	if not effect or not character_sheet:
		return
	
	# Check if already active
	var existing_ctx = _get_active_context(effect)
	
	if existing_ctx:
		# Stack logic
		# We need to know max_stacks from a component? 
		# Let's check StackingComponent
		var stack_comp = effect.get_component("Stacking")
		var max_stacks = stack_comp.max_stacks if stack_comp else 1
		
		if existing_ctx.stacks < max_stacks:
			existing_ctx.stacks += 1
			# Refresh duration if exists
			var dur_comp = effect.get_component("Duration")
			if dur_comp:
				existing_ctx.remaining_time = dur_comp.duration
			
			_trigger_components(existing_ctx, "on_apply")
		else:
			# Refresh duration even at max stacks?
			var dur_comp = effect.get_component("Duration")
			if dur_comp:
				existing_ctx.remaining_time = dur_comp.duration
				
	else:
		# New Context
		var ctx = EffectContext.new()
		ctx.setup(effect, character_sheet, self)
		
		# Check duration
		var dur_comp = effect.get_component("Duration")
		if dur_comp:
			ctx.remaining_time = dur_comp.duration
			active_contexts.append(ctx)
		else:
			# Instant effect? Or Permanent?
			if effect.get_component("Identity"): # Assume valid effect
				# If no duration, it might be instant (run once, don't store) 
				# OR permanent (store forever, but handled via Duration=0 or similar?)
				# Typically Instant effects just run and leave.
				# Buffs need Duration or Infinite Duration.
				pass
			# For now, if no duration component, run once and discard unless specified otherwise?
			# Usage: Health Potion (Instant) -> No Duration Component -> Runs on_apply -> Done.
			# Usage: Aura (Permanent) -> Infinite Duration? 
			# Let's assume if "Duration" component is missing, it's Instant.
			# If Duration component exists but duration is -1, it's Permanent.
			pass

		_trigger_components(ctx, "on_apply")

	effect_applied.emit(effect)

func _process_effects(delta: float) -> void:
	var to_remove = []
	
	for i in range(active_contexts.size()):
		var ctx = active_contexts[i]
		
		# Tick
		ctx.tick_timer += delta
		# We should check `tick_interval` from components? 
		# Or broadcast on_tick every frame and let components decide?
		# EffectComponent definition: on_tick(ctx, delta).
		# Components handle their own timers if needed.
		_trigger_components(ctx, "on_tick", [delta])
		
		# Duration
		if ctx.remaining_time > 0: # If using duration
			ctx.remaining_time -= delta
			if ctx.remaining_time <= 0:
				to_remove.append(ctx)
	
	for ctx in to_remove:
		remove_effect_context(ctx)

func remove_effect(effect: Effect) -> void:
	var ctx = _get_active_context(effect)
	if ctx:
		remove_effect_context(ctx)

func remove_effect_context(ctx: EffectContext) -> void:
	_trigger_components(ctx, "on_remove")
	active_contexts.erase(ctx)

func _get_active_context(effect: Effect) -> EffectContext:
	for ctx in active_contexts:
		if ctx.effect == effect:
			return ctx
	return null

func _trigger_components(ctx: EffectContext, method: String, args: Array = []) -> void:
	if ctx.effect and "components" in ctx.effect:
		for comp in ctx.effect.components:
			if comp.has_method(method):
				comp.callv(method, [ctx] + args)

# ==================== SKILLS & STATES ====================

func get_all_available_states() -> Array[State]:
	var states: Array[State] = []
	
	# From SkillTree
	if skill_tree:
		states.append_array(skill_tree.get_all_unlocked_states())
		
	# From Backpack
	if backpack:
		var compose = backpack.get_equipped_compose()
		if compose:
			states.append_array(compose.get_move_states())
			states.append_array(compose.get_attack_states())
			
	return states
