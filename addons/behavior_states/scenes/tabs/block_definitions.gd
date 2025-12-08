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
			{"name": "icon", "type": "Texture2D", "default": null}
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
	"CategoryBlock": {
		"color": Color("#f59e0b"),
		"fields": [
			{"name": "category", "type": "enum", "options": ["Weapon", "Consumable", "Material", "Armor", "Accessory", "Key"], "default": 0},
			{"name": "sell_price", "type": "int", "default": 0},
			{"name": "rarity", "type": "int", "default": 0}
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
			{"name": "icon", "type": "Texture2D", "default": null}
		]
	},
	"RequirementsBlock": {
		"color": Color("#eab308"),
		"fields": [
			{"name": "required_level", "type": "int", "default": 0},
			{"name": "cost", "type": "int", "default": 1}
		]
	},
	"EffectsBlock": {
		"color": Color("#22c55e"),
		"fields": [
			{"name": "unlocked_states", "type": "Array[State]", "default": []},
			{"name": "unlocked_compose", "type": "Compose", "default": null}
		]
	},
	"ProgressionBlock": {
		"color": Color("#8b5cf6"),
		"fields": [
			{"name": "current_level", "type": "int", "default": 0},
			{"name": "max_level", "type": "int", "default": 1}
		]
	}
}

static func get_blocks_for_type(type_name: String) -> Dictionary:
	match type_name:
		"State": return STATE_BLOCKS
		"Item": return ITEM_BLOCKS
		"Skill": return SKILL_BLOCKS
	return {}

static func get_block_names_for_type(type_name: String) -> Array:
	var blocks = get_blocks_for_type(type_name)
	return blocks.keys()
