## ComponentDefinitions — Substitui BlockDefinitions para o sistema de Components.
##
## Auto-descobre todos os components registrados e expõe metadados
## para o editor visual gerar UI dinamicamente.
class_name ComponentDefinitions extends RefCounted

# ══════════════════════════════════════════════════════════════
# REGISTRY AUTOMÁTICO
# ══════════════════════════════════════════════════════════════

## Cache de components por categoria
static var _cache: Dictionary = {}
static var _initialized: bool = false

## Registra todos os components disponíveis
static func _initialize() -> void:
	if _initialized:
		return
	
	_cache = {
		"State": _get_state_components(),
		"Item": _get_item_components(),
		"Effect": _get_effect_components(),
		"Skill": _get_skill_components(),
		"Character": _get_character_components()
	}
	
	_initialized = true

## StateComponents disponíveis
static func _get_state_components() -> Dictionary:
	return {
		"MovementComponent": {
			"script": "res://addons/behavior_states/resources/components/state/movement_component.gd",
			"name": "Movement",
			"color": Color("#22c55e"),
			"fields": [
				{"name": "speed_multiplier", "type": "float", "default": 1.0},
				{"name": "acceleration", "type": "float", "default": 0.0},
				{"name": "friction", "type": "float", "default": 0.0},
				{"name": "lock_input", "type": "bool", "default": false}
			]
		},
		"StandardMoveComponent": {
			"script": "res://addons/behavior_states/resources/components/state/standard_move_component.gd",
			"name": "Standard Move",
			"color": Color("#3b82f6"),
			"fields": [
				{"name": "use_run_speed", "type": "bool", "default": false},
				{"name": "multiplier", "type": "float", "default": 1.0},
				{"name": "friction", "type": "float", "default": 1000.0},
				{"name": "apply_gravity", "type": "bool", "default": true}
			]
		},
		"PhysicsComponent": {
			"script": "res://addons/behavior_states/resources/components/state/physics_component.gd",
			"name": "Physics",
			"color": Color("#06b6d4"),
			"fields": [
				{"name": "gravity_scale", "type": "float", "default": 1.0},
				{"name": "ignore_gravity", "type": "bool", "default": false},
				{"name": "jump_force", "type": "float", "default": 0.0},
				{"name": "air_resistance", "type": "float", "default": 0.0}
			]
		},
		"HitboxComponent": {
			"script": "res://addons/behavior_states/resources/components/state/hitbox_component.gd",
			"name": "Hitbox",
			"color": Color("#ef4444"),
			"fields": [
				{"name": "shape", "type": "Shape2D", "default": null},
				{"name": "offset", "type": "Vector2", "default": Vector2.ZERO},
				{"name": "delay", "type": "float", "default": 0.0},
				{"name": "active_time", "type": "float", "default": 0.1},
				{"name": "damage_multiplier", "type": "float", "default": 1.0},
				{"name": "knockback", "type": "Vector2", "default": Vector2.ZERO}
			]
		},
		"AnimationComponent": {
			"script": "res://addons/behavior_states/resources/components/state/animation_component.gd",
			"name": "Animation",
			"color": Color("#a855f7"),
			"fields": [
				{"name": "animation_name", "type": "StringName", "default": &""},
				{"name": "blend_time", "type": "float", "default": 0.1},
				{"name": "speed_scale", "type": "float", "default": 1.0},
				{"name": "use_animation_tree", "type": "bool", "default": true}
			]
		},
		"SpriteComponent": {
			"script": "res://addons/behavior_states/resources/components/state/sprite_component.gd",
			"name": "Sprite",
			"color": Color("#a855f7"),
			"fields": [
				{"name": "texture", "type": "Texture2D", "default": null},
				{"name": "hframes", "type": "int", "default": 1},
				{"name": "vframes", "type": "int", "default": 1},
				{"name": "animation_row", "type": "int", "default": 0},
				{"name": "loop", "type": "bool", "default": true},
				{"name": "fps", "type": "float", "default": 12.0}
			]
		},
		"AudioComponent": {
			"script": "res://addons/behavior_states/resources/components/state/audio_component.gd",
			"name": "Audio",
			"color": Color("#06b6d4"),
			"fields": [
				{"name": "sound", "type": "AudioStream", "default": null},
				{"name": "volume_db", "type": "float", "default": 0.0},
				{"name": "pitch_scale", "type": "float", "default": 1.0},
				{"name": "pitch_randomness", "type": "float", "default": 0.0}
			]
		},
		"VFXComponent": {
			"script": "res://addons/behavior_states/resources/components/state/vfx_component.gd",
			"name": "VFX",
			"color": Color("#06b6d4"),
			"fields": [
				{"name": "vfx_scene", "type": "PackedScene", "default": null},
				{"name": "offset", "type": "Vector2", "default": Vector2.ZERO},
				{"name": "auto_destroy", "type": "bool", "default": true},
				{"name": "destroy_time", "type": "float", "default": 2.0}
			]
		},
		"ProjectileComponent": {
			"script": "res://addons/behavior_states/resources/components/state/projectile_component.gd",
			"name": "Projectile",
			"color": Color("#f97316"),
			"fields": [
				{"name": "projectile_scene", "type": "PackedScene", "default": null},
				{"name": "spawn_offset", "type": "Vector2", "default": Vector2.ZERO},
				{"name": "projectile_speed", "type": "float", "default": 500.0},
				{"name": "projectile_count", "type": "int", "default": 1},
				{"name": "spread_angle", "type": "float", "default": 0.0},
				{"name": "damage_multiplier", "type": "float", "default": 1.0}
			]
		},
		"ComboComponent": {
			"script": "res://addons/behavior_states/resources/components/state/combo_component.gd",
			"name": "Combo",
			"color": Color("#eab308"),
			"fields": [
				{"name": "next_state", "type": "State", "default": null},
				{"name": "window_start", "type": "float", "default": 0.0},
				{"name": "window_duration", "type": "float", "default": 0.3},
				{"name": "chain_bonus_damage", "type": "float", "default": 0.0}
			]
		},
		"DashComponent": {
			"script": "res://addons/behavior_states/resources/components/state/dash_component.gd",
			"name": "Dash",
			"color": Color("#22c55e"),
			"fields": [
				{"name": "dash_speed", "type": "float", "default": 600.0},
				{"name": "dash_direction", "type": "Vector2", "default": Vector2.RIGHT},
				{"name": "use_input_direction", "type": "bool", "default": true},
				{"name": "preserve_y_velocity", "type": "bool", "default": false}
			]
		},
		"CostComponent": {
			"script": "res://addons/behavior_states/resources/components/state/cost_component.gd",
			"name": "Cost",
			"color": Color("#f59e0b"),
			"fields": [
				{"name": "cost_type", "type": "enum", "options": ["None", "Stamina", "Mana", "Health"], "default": 0},
				{"name": "cost_amount", "type": "float", "default": 0.0},
				{"name": "on_insufficient", "type": "enum", "options": ["Block", "Ignore", "Weaken"], "default": 0}
			]
		},
		"ChargedComponent": {
			"script": "res://addons/behavior_states/resources/components/state/charged_component.gd",
			"name": "Charged",
			"color": Color("#8b5cf6"),
			"fields": [
				{"name": "min_charge_time", "type": "float", "default": 0.3},
				{"name": "max_charge_time", "type": "float", "default": 2.0},
				{"name": "damage_multiplier_min", "type": "float", "default": 1.0},
				{"name": "damage_multiplier_max", "type": "float", "default": 3.0}
			]
		},
		"BufferComponent": {
			"script": "res://addons/behavior_states/resources/components/state/buffer_component.gd",
			"name": "Buffer",
			"color": Color("#eab308"),
			"fields": [
				{"name": "buffer_window_start", "type": "float", "default": 0.3},
				{"name": "buffered_actions", "type": "Array[String]", "default": []}
			]
		},
		"InterruptComponent": {
			"script": "res://addons/behavior_states/resources/components/state/interrupt_component.gd",
			"name": "Interrupt",
			"color": Color("#ec4899"),
			"fields": [
				{"name": "on_physics_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
				{"name": "on_weapon_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
				{"name": "on_motion_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
				{"name": "on_attack_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
				{"name": "on_take_damage", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 0},
				{"name": "min_duration", "type": "float", "default": 0.0}
			]
		},
		"ParryComponent": {
			"script": "res://addons/behavior_states/resources/components/state/parry_component.gd",
			"name": "Parry",
			"color": Color("#8b5cf6"),
			"fields": [
				{"name": "parry_window", "type": "float", "default": 0.2},
				{"name": "block_window", "type": "float", "default": 0.5},
				{"name": "parry_damage_reduction", "type": "float", "default": 1.0},
				{"name": "block_damage_reduction", "type": "float", "default": 0.5}
			]
		},
		"FilterComponent": {
			"script": "res://addons/behavior_states/resources/components/state/filter_component.gd",
			"name": "Filter",
			"color": Color("#3b82f6"),
			"fields": [
				{"name": "entry_requirements", "type": "Dictionary", "default": {}},
				{"name": "priority_override", "type": "int", "default": 0},
				{"name": "required_skill", "type": "String", "default": ""}
			]
		},
		"DurationComponent": {
			"script": "res://addons/behavior_states/resources/components/state/duration_component.gd",
			"name": "Duration",
			"color": Color("#64748b"),
			"fields": [
				{"name": "duration", "type": "float", "default": 0.0},
				{"name": "min_time", "type": "float", "default": 0.0},
				{"name": "can_loop", "type": "bool", "default": false}
			]
		}
	}

## ItemComponents disponíveis
static func _get_item_components() -> Dictionary:
	return {
		"IdentityComponent": {
			"script": "res://addons/behavior_states/resources/components/item/identity_component.gd",
			"name": "Identity",
			"color": Color("#3b82f6"),
			"fields": [
				{"name": "id", "type": "String", "default": ""},
				{"name": "display_name", "type": "String", "default": "Item"},
				{"name": "description", "type": "String", "default": ""},
				{"name": "icon", "type": "Texture2D", "default": null},
				{"name": "category", "type": "enum", "options": ["Weapon", "Consumable", "Material", "Armor", "Accessory", "Key"], "default": 0},
				{"name": "rarity", "type": "enum", "options": ["Common", "Uncommon", "Rare", "Epic", "Legendary"], "default": 0}
			]
		},
		"StackingComponent": {
			"script": "res://addons/behavior_states/resources/components/item/stacking_component.gd",
			"name": "Stacking",
			"color": Color("#22c55e"),
			"fields": [
				{"name": "stackable", "type": "bool", "default": false},
				{"name": "max_stack", "type": "int", "default": 99}
			]
		},
		"DurabilityComponent": {
			"script": "res://addons/behavior_states/resources/components/item/durability_component.gd",
			"name": "Durability",
			"color": Color("#f59e0b"),
			"fields": [
				{"name": "max_durability", "type": "int", "default": 100},
				{"name": "break_on_zero", "type": "bool", "default": true}
			]
		},
		"ConsumableComponent": {
			"script": "res://addons/behavior_states/resources/components/item/consumable_component.gd",
			"name": "Consumable",
			"color": Color("#ef4444"),
			"fields": [
				{"name": "consume_on_use", "type": "bool", "default": true},
				{"name": "use_effects", "type": "Array[Effects]", "default": []}
			]
		},
		"EquipmentComponent": {
			"script": "res://addons/behavior_states/resources/components/item/equipment_component.gd",
			"name": "Equipment",
			"color": Color("#8b5cf6"),
			"fields": [
				{"name": "equip_slot", "type": "enum", "options": ["None", "MainHand", "OffHand", "Head", "Chest", "Legs", "Feet", "Ring", "Amulet"], "default": 0},
				{"name": "compose", "type": "Compose", "default": null},
				{"name": "equip_effects", "type": "Array[Effects]", "default": []}
			]
		},
		"CraftingComponent": {
			"script": "res://addons/behavior_states/resources/components/item/crafting_component.gd",
			"name": "Crafting",
			"color": Color("#06b6d4"),
			"fields": [
				{"name": "craft_recipe", "type": "Dictionary", "default": {}},
				{"name": "craft_time", "type": "float", "default": 0.0},
				{"name": "required_station", "type": "String", "default": ""},
				{"name": "output_quantity", "type": "int", "default": 1}
			]
		},
		"EconomyComponent": {
			"script": "res://addons/behavior_states/resources/components/item/economy_component.gd",
			"name": "Economy",
			"color": Color("#eab308"),
			"fields": [
				{"name": "sell_price", "type": "int", "default": 0},
				{"name": "buy_price", "type": "int", "default": 0}
			]
		}
	}

## EffectComponents disponíveis
static func _get_effect_components() -> Dictionary:
	return {
		"StatModifierComponent": {
			"script": "res://addons/behavior_states/resources/components/effect/stat_modifier_component.gd",
			"name": "Stat Modifier",
			"color": Color("#3b82f6"),
			"fields": [
				{"name": "stat_modifiers", "type": "Dictionary", "default": {}}
			]
		},
		"DamageOverTimeComponent": {
			"script": "res://addons/behavior_states/resources/components/effect/dot_component.gd",
			"name": "Damage Over Time",
			"color": Color("#ef4444"),
			"fields": [
				{"name": "damage_type", "type": "enum", "options": ["Physical", "Fire", "Poison", "Bleed", "Magic"], "default": 0},
				{"name": "damage_per_tick", "type": "int", "default": 5},
				{"name": "tick_interval", "type": "float", "default": 1.0}
			]
		},
		"HealOverTimeComponent": {
			"script": "res://addons/behavior_states/resources/components/effect/hot_component.gd",
			"name": "Heal Over Time",
			"color": Color("#22c55e"),
			"fields": [
				{"name": "heal_per_tick", "type": "int", "default": 5},
				{"name": "tick_interval", "type": "float", "default": 1.0}
			]
		}
	}

## SkillComponents disponíveis
static func _get_skill_components() -> Dictionary:
	return {
		"SkillIdentityComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/identity_component.gd",
			"name": "Identity",
			"color": Color("#ec4899"),
			"fields": [
				{"name": "skill_name", "type": "String", "default": "New Skill"},
				{"name": "description", "type": "String", "default": ""},
				{"name": "icon", "type": "Texture2D", "default": null}
			]
		},
		"SkillTypeComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/type_component.gd",
			"name": "Type",
			"color": Color("#8b5cf6"),
			"fields": [
				{"name": "skill_type", "type": "enum", "options": ["Active", "Passive", "Buff", "Ultimate"], "default": 1},
				{"name": "category", "type": "String", "default": "General"}
			]
		},
		"LevelRequirementComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/level_requirement_component.gd",
			"name": "Level Req",
			"color": Color("#ef4444"),
			"fields": [
				{"name": "min_character_level", "type": "int", "default": 1},
				{"name": "min_attribute_requirements", "type": "Dictionary", "default": {}}
			]
		},
		"PointCostComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/point_cost_component.gd",
			"name": "Cost",
			"color": Color("#f59e0b"),
			"fields": [
				{"name": "skill_points_cost", "type": "int", "default": 1},
				{"name": "gold_cost", "type": "int", "default": 0}
			]
		},
		"PrerequisiteComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/prerequisite_component.gd",
			"name": "Prerequisites",
			"color": Color("#f97316"),
			"fields": [
				{"name": "required_skills", "type": "Array[Resource]", "default": []}
			]
		},
		"UnlockStatesComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/unlock_states_component.gd",
			"name": "Unlock States",
			"color": Color("#22c55e"),
			"fields": [
				{"name": "states_to_unlock", "type": "Array[State]", "default": []},
				{"name": "compose_to_inject", "type": "Compose", "default": null}
			]
		},
		"UnlockItemsComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/unlock_items_component.gd",
			"name": "Unlock Items",
			"color": Color("#3b82f6"),
			"fields": [
				{"name": "items_to_grant", "type": "Array[Item]", "default": []},
				{"name": "recipes_to_unlock", "type": "Array[Resource]", "default": []}
			]
		},
		"PassiveEffectComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/passive_effect_component.gd",
			"name": "Passive Effects",
			"color": Color("#a855f7"),
			"fields": [
				{"name": "effects", "type": "Array[Effects]", "default": []}
			]
		},
		"ActiveAbilityComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/active_ability_component.gd",
			"name": "Active Ability",
			"color": Color("#ef4444"),
			"fields": [
				{"name": "action_state", "type": "State", "default": null},
				{"name": "cooldown", "type": "float", "default": 0.0},
				{"name": "mana_cost", "type": "float", "default": 0.0}
			]
		},
		"SkillLevelComponent": {
			"script": "res://addons/behavior_states/resources/components/skill/level_component.gd",
			"name": "Skill Level",
			"color": Color("#eab308"),
			"fields": [
				{"name": "max_level", "type": "int", "default": 1},
				{"name": "current_level", "type": "int", "default": 0},
				{"name": "scaling_factor", "type": "float", "default": 1.0}
			]
		}
	}

## CharacterComponents disponíveis
static func _get_character_components() -> Dictionary:
	return {
		"HealthComponent": {
			"script": "res://addons/behavior_states/resources/components/character/health_component.gd",
			"name": "Health",
			"color": Color("#ef4444"),
			"fields": [
				{"name": "max_health", "type": "float", "default": 100.0},
				{"name": "current_health", "type": "float", "default": 100.0},
				{"name": "regeneration", "type": "float", "default": 0.0}
			]
		},
		"StaminaComponent": {
			"script": "res://addons/behavior_states/resources/components/character/stamina_component.gd",
			"name": "Stamina",
			"color": Color("#22c55e"),
			"fields": [
				{"name": "max_stamina", "type": "float", "default": 100.0},
				{"name": "current_stamina", "type": "float", "default": 100.0},
				{"name": "regeneration", "type": "float", "default": 10.0}
			]
		},
		"ManaComponent": {
			"script": "res://addons/behavior_states/resources/components/character/mana_component.gd",
			"name": "Mana",
			"color": Color("#3b82f6"),
			"fields": [
				{"name": "max_mana", "type": "float", "default": 100.0},
				{"name": "current_mana", "type": "float", "default": 100.0},
				{"name": "regeneration", "type": "float", "default": 5.0}
			]
		},
		"BaseAttributesComponent": {
			"script": "res://addons/behavior_states/resources/components/character/base_attributes_component.gd",
			"name": "Base Attributes",
			"color": Color("#eab308"),
			"fields": [
				{"name": "strength", "type": "int", "default": 10},
				{"name": "dexterity", "type": "int", "default": 10},
				{"name": "intelligence", "type": "int", "default": 10},
				{"name": "vitality", "type": "int", "default": 10}
			]
		},
		"DerivedStatsComponent": {
			"script": "res://addons/behavior_states/resources/components/character/derived_stats_component.gd",
			"name": "Derived Stats",
			"color": Color("#64748b"),
			"fields": [
				{"name": "physical_defense", "type": "float", "default": 0.0},
				{"name": "magic_defense", "type": "float", "default": 0.0},
				{"name": "poise", "type": "float", "default": 0.0},
				{"name": "crit_chance", "type": "float", "default": 0.05},
				{"name": "crit_multiplier", "type": "float", "default": 1.5}
			]
		},
		"MovementStatsComponent": {
			"script": "res://addons/behavior_states/resources/components/character/movement_stats_component.gd",
			"name": "Movement Stats",
			"color": Color("#06b6d4"),
			"fields": [
				{"name": "walk_speed", "type": "float", "default": 200.0},
				{"name": "run_speed", "type": "float", "default": 400.0},
				{"name": "jump_force", "type": "float", "default": -400.0},
				{"name": "acceleration", "type": "float", "default": 1200.0},
				{"name": "friction", "type": "float", "default": 1200.0}
			]
		},
		"ExperienceComponent": {
			"script": "res://addons/behavior_states/resources/components/character/experience_component.gd",
			"name": "Experience",
			"color": Color("#a855f7"),
			"fields": [
				{"name": "level", "type": "int", "default": 1},
				{"name": "current_xp", "type": "int", "default": 0},
				{"name": "xp_to_next_level", "type": "int", "default": 100},
				{"name": "unspent_attribute_points", "type": "int", "default": 0},
				{"name": "unspent_skill_points", "type": "int", "default": 0}
			]
		},
		"CombatStatsComponent": {
			"script": "res://addons/behavior_states/resources/components/character/combat_stats_component.gd",
			"name": "Combat Stats",
			"color": Color("#f43f5e"),
			"fields": [
				{"name": "attack_power", "type": "float", "default": 10.0},
				{"name": "attack_speed", "type": "float", "default": 1.0},
				{"name": "cooldown_reduction", "type": "float", "default": 0.0}
			]
		}
	}

# ══════════════════════════════════════════════════════════════
# PUBLIC API (Compatible with BlockDefinitions)
# ══════════════════════════════════════════════════════════════

static func get_components_for_type(type_name: String) -> Dictionary:
	_initialize()
	return _cache.get(type_name, {})

static func get_component_names_for_type(type_name: String) -> Array:
	var components = get_components_for_type(type_name)
	return components.keys()

## Compatibility with BlockDefinitions
static func get_blocks_for_type(type_name: String) -> Dictionary:
	return get_components_for_type(type_name)

static func get_block_names_for_type(type_name: String) -> Array:
	return get_component_names_for_type(type_name)
