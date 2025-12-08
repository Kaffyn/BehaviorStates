## Block Definitions
## Define os blocos e suas propriedades para cada tipo de resource.
class_name BlockDefinitions extends RefCounted

# ========== STATE BLOCKS ==========
const STATE_BLOCKS = {
	"IdentityBlock": {
		"color": Color("#ffffff"),
		"fields": [
			{"name": "name", "type": "String", "default": "State"},
			{"name": "debug_color", "type": "Color", "default": Color.WHITE}
		]
	},
	"VisualBlock": {
		"color": Color("#a855f7"),
		"fields": [
			{"name": "texture", "type": "Texture2D", "default": null},
			{"name": "hframes", "type": "int", "default": 1},
			{"name": "vframes", "type": "int", "default": 1},
			{"name": "loop", "type": "bool", "default": false},
			{"name": "speed", "type": "float", "default": 1.0}
		]
	},
	"MovementBlock": {
		"color": Color("#22c55e"),
		"fields": [
			{"name": "speed_multiplier", "type": "float", "default": 1.0},
			{"name": "duration", "type": "float", "default": 0.0},
			{"name": "lock_movement", "type": "bool", "default": false},
			{"name": "cancel_on_wall", "type": "bool", "default": false},
			{"name": "ignore_gravity", "type": "bool", "default": false}
		]
	},
	"PhysicsBlock": {
		"color": Color("#06b6d4"),
		"fields": [
			{"name": "acceleration", "type": "float", "default": 0.0},
			{"name": "friction", "type": "float", "default": 0.0},
			{"name": "air_resistance", "type": "float", "default": 0.0},
			{"name": "jump_force", "type": "float", "default": 0.0}
		]
	},
	"CombatBlock": {
		"color": Color("#ef4444"),
		"fields": [
			{"name": "damage", "type": "int", "default": 0},
			{"name": "area_pivot", "type": "Vector2", "default": Vector2.ZERO},
			{"name": "area_size", "type": "Vector2", "default": Vector2.ZERO},
			{"name": "preserve_momentum", "type": "bool", "default": false}
		]
	},
	"ProjectileBlock": {
		"color": Color("#f97316"),
		"fields": [
			{"name": "projectile_speed", "type": "float", "default": 0.0},
			{"name": "projectile_count", "type": "int", "default": 0},
			{"name": "projectile_spread", "type": "float", "default": 0.0},
			{"name": "spawn_offset", "type": "Vector2", "default": Vector2.ZERO}
		]
	},
	"CooldownBlock": {
		"color": Color("#64748b"),
		"fields": [
			{"name": "cooldown", "type": "float", "default": 0.0},
			{"name": "context_cooldown_filter", "type": "enum", "options": ["None", "Motion", "Attack", "Jump"], "default": 0},
			{"name": "context_cooldown_time", "type": "float", "default": 0.0}
		]
	},
	"ComboBlock": {
		"color": Color("#eab308"),
		"fields": [
			{"name": "combo_step", "type": "enum", "options": ["None", "Step1", "Step2", "Step3", "Finisher"], "default": 0},
			{"name": "combo_window_start", "type": "float", "default": 0.0}
		]
	},
	"ChargedBlock": {
		"color": Color("#8b5cf6"),
		"fields": [
			{"name": "is_charged", "type": "bool", "default": false},
			{"name": "min_charge_time", "type": "float", "default": 0.0},
			{"name": "max_charge_time", "type": "float", "default": 0.0},
			{"name": "fully_charged_damage_multiplier", "type": "float", "default": 1.0}
		]
	},
	"TimingBlock": {
		"color": Color("#84cc16"),
		"fields": [
			{"name": "cancel_min_time", "type": "float", "default": 0.0},
			{"name": "enable_buffering", "type": "bool", "default": false},
			{"name": "buffer_window_start", "type": "float", "default": 0.0}
		]
	},
	"CostBlock": {
		"color": Color("#f59e0b"),
		"fields": [
			{"name": "cost_type", "type": "enum", "options": ["None", "Stamina", "Mana", "Health"], "default": 0},
			{"name": "cost_amount", "type": "int", "default": 0},
			{"name": "on_insufficient_resource", "type": "enum", "options": ["Ignore", "Block", "Weaken"], "default": 0}
		]
	},
	"FilterBlock": {
		"color": Color("#3b82f6"),
		"fields": [
			{"name": "priority_override", "type": "int", "default": 0},
			{"name": "entry_requirements", "type": "Dictionary", "default": {}}
		]
	},
	"ReactionBlock": {
		"color": Color("#ec4899"),
		"fields": [
			{"name": "on_physics_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
			{"name": "on_weapon_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
			{"name": "on_motion_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
			{"name": "on_attack_change", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1},
			{"name": "on_take_damage", "type": "enum", "options": ["Cancel", "Adapt", "Ignore", "Finish"], "default": 1}
		]
	}
}

# ========== ITEM BLOCKS ==========
const ITEM_BLOCKS = {
	"IdentityBlock": {
		"color": Color("#3b82f6"),
		"fields": [
			{"name": "id", "type": "String", "default": ""},
			{"name": "name", "type": "String", "default": "Item"},
			{"name": "description", "type": "String", "default": ""},
			{"name": "icon", "type": "Texture2D", "default": null},
			{"name": "category", "type": "enum", "options": ["Weapon", "Consumable", "Material", "Armor", "Accessory", "Key"], "default": 0},
			{"name": "rarity", "type": "enum", "options": ["Common", "Uncommon", "Rare", "Epic", "Legendary"], "default": 0}
		]
	},
	"StackingBlock": {
		"color": Color("#22c55e"),
		"fields": [
			{"name": "stackable", "type": "bool", "default": false},
			{"name": "quantity", "type": "int", "default": 1},
			{"name": "max_stack", "type": "int", "default": 99}
		]
	},
	"DurabilityBlock": {
		"color": Color("#f59e0b"),
		"fields": [
			{"name": "has_durability", "type": "bool", "default": false},
			{"name": "durability", "type": "int", "default": 100},
			{"name": "max_durability", "type": "int", "default": 100}
		]
	},
	"ConsumableBlock": {
		"color": Color("#ef4444"),
		"fields": [
			{"name": "consumable", "type": "bool", "default": false},
			{"name": "use_effects", "type": "Array[Effects]", "default": []}
		]
	},
	"EquipmentBlock": {
		"color": Color("#8b5cf6"),
		"fields": [
			{"name": "compose", "type": "Compose", "default": null},
			{"name": "equip_effects", "type": "Array[Effects]", "default": []},
			{"name": "equip_slot", "type": "enum", "options": ["None", "MainHand", "OffHand", "Head", "Chest", "Legs", "Feet", "Ring", "Amulet"], "default": 0}
		]
	},
	"CraftingBlock": {
		"color": Color("#06b6d4"),
		"fields": [
			{"name": "craft_recipe", "type": "Dictionary", "default": {}},
			{"name": "craft_time", "type": "float", "default": 0.0},
			{"name": "required_station", "type": "String", "default": ""},
			{"name": "craft_output_quantity", "type": "int", "default": 1}
		]
	},
	"EconomyBlock": {
		"color": Color("#eab308"),
		"fields": [
			{"name": "sell_price", "type": "int", "default": 0},
			{"name": "buy_price", "type": "int", "default": 0}
		]
	}
}

# ========== EFFECTS BLOCKS ==========
const EFFECTS_BLOCKS = {
	"IdentityBlock": {
		"color": Color("#a855f7"),
		"fields": [
			{"name": "id", "type": "String", "default": ""},
			{"name": "name", "type": "String", "default": "Effect"},
			{"name": "description", "type": "String", "default": ""},
			{"name": "icon", "type": "Texture2D", "default": null}
		]
	},
	"TypeBlock": {
		"color": Color("#22c55e"),
		"fields": [
			{"name": "effect_type", "type": "enum", "options": ["Instant", "Temporary", "Permanent"], "default": 0},
			{"name": "duration", "type": "float", "default": 0.0},
			{"name": "stackable", "type": "bool", "default": false},
			{"name": "max_stacks", "type": "int", "default": 1}
		]
	},
	"StatModifiersBlock": {
		"color": Color("#3b82f6"),
		"fields": [
			{"name": "stat_modifiers", "type": "Dictionary", "default": {}}
		]
	},
	"StatusBlock": {
		"color": Color("#ef4444"),
		"fields": [
			{"name": "status_type", "type": "enum", "options": ["None", "Poison", "Burn", "Freeze", "Stun", "Slow", "Haste", "Regen", "Bleed"], "default": 0},
			{"name": "damage_per_tick", "type": "int", "default": 0},
			{"name": "tick_interval", "type": "float", "default": 1.0},
			{"name": "heal_per_tick", "type": "int", "default": 0}
		]
	},
	"VisualBlock": {
		"color": Color("#ec4899"),
		"fields": [
			{"name": "vfx_scene", "type": "PackedScene", "default": null},
			{"name": "tint_color", "type": "Color", "default": Color.WHITE},
			{"name": "apply_sound", "type": "AudioStream", "default": null}
		]
	}
}

# ========== CONFIG BLOCKS ==========
const CONFIG_BLOCKS = {
	"GameType": {
		"color": Color("#f59e0b"),
		"fields": [
			{"name": "game_type", "type": "enum", "options": ["Platform2D", "TopDown2D", "3D"], "default": 0},
			{"name": "physics_process_mode", "type": "enum", "options": ["Idle", "Physics"], "default": 1}
		]
	},
	"Physics": {
		"color": Color("#06b6d4"),
		"fields": [
			{"name": "use_gravity", "type": "bool", "default": true},
			{"name": "default_gravity", "type": "float", "default": 980.0}
		]
	},
	"Visuals": {
		"color": Color("#ec4899"),
		"fields": [
			{"name": "state_node_color", "type": "Color", "default": Color.CORNFLOWER_BLUE},
			{"name": "transition_color", "type": "Color", "default": Color.WHITE},
			{"name": "log_color", "type": "Color", "default": Color.ORANGE}
		]
	}
}

# ========== CHARACTER BLOCKS ==========
const CHARACTER_BLOCKS = {
	"Vitals": {
		"color": Color("#ef4444"),
		"fields": [
			{"name": "max_health", "type": "int", "default": 100},
			{"name": "max_stamina", "type": "float", "default": 100.0},
			{"name": "stamina_regen_rate", "type": "float", "default": 12.0}
		]
	},
	"Movement": {
		"color": Color("#22c55e"),
		"fields": [
			{"name": "max_speed", "type": "float", "default": 230.0},
			{"name": "default_acceleration", "type": "float", "default": 1200.0},
			{"name": "jump_force", "type": "float", "default": -500.0}
		]
	},
	"Progression": {
		"color": Color("#a855f7"),
		"fields": [
			{"name": "level", "type": "int", "default": 1},
			{"name": "experience", "type": "int", "default": 0},
			{"name": "skill_points", "type": "int", "default": 0}
		]
	},
	"Attributes": {
		"color": Color("#f59e0b"),
		"fields": [
			{"name": "attributes", "type": "Dictionary", "default": {}},
			{"name": "statistics", "type": "Dictionary", "default": {}}
		]
	}
}

# ========== INVENTORY BLOCKS ==========
const INVENTORY_BLOCKS = {
	"Storage": {
		"color": Color("#8b5cf6"),
		"fields": [
			{"name": "capacity", "type": "int", "default": 24}
		]
	}
}

# ========== SKILL BLOCKS ==========
const SKILL_BLOCKS = {
	"IdentityBlock": {
		"color": Color("#ec4899"),
		"fields": [
			{"name": "id", "type": "String", "default": ""},
			{"name": "name", "type": "String", "default": "Skill"},
			{"name": "description", "type": "String", "default": ""},
			{"name": "icon", "type": "Texture2D", "default": null},
			{"name": "skill_type", "type": "enum", "options": ["Passive", "Active", "Ultimate", "Meta"], "default": 0},
			{"name": "rarity", "type": "enum", "options": ["Common", "Uncommon", "Rare", "Epic", "Legendary"], "default": 0}
		]
	},
	"RequirementsBlock": {
		"color": Color("#eab308"),
		"fields": [
			{"name": "req_level", "type": "int", "default": 1},
			{"name": "cost", "type": "int", "default": 1},
			{"name": "auto_learn", "type": "bool", "default": false},
			{"name": "req_attributes", "type": "Dictionary", "default": {}},
			{"name": "req_statistics", "type": "Dictionary", "default": {}},
			{"name": "req_items", "type": "Dictionary", "default": {}}
		]
	},
	"UnlocksBlock": {
		"color": Color("#22c55e"),
		"fields": [
			{"name": "unlocks_states", "type": "Array[State]", "default": []},
			{"name": "unlocks_items", "type": "Array[Item]", "default": []},
			{"name": "context_tags", "type": "Dictionary", "default": {}}
		]
	},
	"PassiveEffectsBlock": {
		"color": Color("#a855f7"),
		"fields": [
			{"name": "passive_effects", "type": "Array[Effects]", "default": []}
		]
	},
	"ActiveBlock": {
		"color": Color("#ef4444"),
		"fields": [
			{"name": "effects_on_use", "type": "Array[Effects]", "default": []},
			{"name": "cooldown", "type": "float", "default": 0.0},
			{"name": "cost_type", "type": "enum", "options": ["None", "Mana", "Stamina", "Health"], "default": 0},
			{"name": "cost_amount", "type": "int", "default": 0},
			{"name": "activation_state", "type": "State", "default": null}
		]
	},
	"ProgressionBlock": {
		"color": Color("#06b6d4"),
		"fields": [
			{"name": "max_level", "type": "int", "default": 1},
			{"name": "scales_with_level", "type": "bool", "default": false},
			{"name": "level_scaling", "type": "float", "default": 1.0}
		]
	}
}

static func get_blocks_for_type(type_name: String) -> Dictionary:
	match type_name:
		"State": return STATE_BLOCKS
		"Item": return ITEM_BLOCKS
		"Skill": return SKILL_BLOCKS
		"Effects": return EFFECTS_BLOCKS
		"BehaviorStatesConfig": return CONFIG_BLOCKS
		"CharacterSheet": return CHARACTER_BLOCKS
		"Inventory": return INVENTORY_BLOCKS
	return {}

static func get_block_names_for_type(type_name: String) -> Array:
	var blocks = get_blocks_for_type(type_name)
	return blocks.keys()

