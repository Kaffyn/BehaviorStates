## Factory Presets
## Define presets para criação rápida de recursos.
class_name FactoryPresets extends RefCounted

# ========== STATE PRESETS ==========
const STATE_PRESETS = {
	"Idle": {
		"description": "Estado parado, sem movimento",
		"values": {
			"name": "Idle",
			"speed_multiplier": 0.0,
			"duration": 0.0,
			"lock_movement": false
		}
	},
	"Walk": {
		"description": "Movimento lento",
		"values": {
			"name": "Walk",
			"speed_multiplier": 0.5,
			"duration": 0.0
		}
	},
	"Run": {
		"description": "Movimento rápido",
		"values": {
			"name": "Run",
			"speed_multiplier": 1.0,
			"duration": 0.0
		}
	},
	"Jump": {
		"description": "Pulo (Platform2D)",
		"values": {
			"name": "Jump",
			"jump_force": -500.0,
			"ignore_gravity": false,
			"duration": 0.0
		}
	},
	"Fall": {
		"description": "Queda (Platform2D)",
		"values": {
			"name": "Fall",
			"ignore_gravity": false,
			"duration": 0.0
		}
	},
	"Dash": {
		"description": "Dash rápido",
		"values": {
			"name": "Dash",
			"speed_multiplier": 3.0,
			"duration": 0.2,
			"ignore_gravity": true
		}
	},
	"Attack Light": {
		"description": "Ataque leve e rápido",
		"values": {
			"name": "AttackLight",
			"damage": 10,
			"duration": 0.3,
			"lock_movement": true,
			"combo_step": 1
		}
	},
	"Attack Heavy": {
		"description": "Ataque pesado e lento",
		"values": {
			"name": "AttackHeavy",
			"damage": 25,
			"duration": 0.6,
			"lock_movement": true,
			"preserve_momentum": false
		}
	},
	"Hurt": {
		"description": "Tomando dano",
		"values": {
			"name": "Hurt",
			"duration": 0.3,
			"lock_movement": true
		}
	},
	"Die": {
		"description": "Morte",
		"values": {
			"name": "Die",
			"duration": 0.0,
			"lock_movement": true
		}
	}
}

# ========== ITEM PRESETS ==========
const ITEM_PRESETS = {
	"Weapon": {
		"description": "Arma equipável",
		"values": {
			"name": "New Weapon",
			"category": 0,
			"stackable": false,
			"max_stack": 1
		}
	},
	"Consumable": {
		"description": "Item consumível (poções, comida)",
		"values": {
			"name": "New Consumable",
			"category": 1,
			"stackable": true,
			"max_stack": 20
		}
	},
	"Material": {
		"description": "Material para craft",
		"values": {
			"name": "New Material",
			"category": 2,
			"stackable": true,
			"max_stack": 999
		}
	},
	"Armor": {
		"description": "Armadura equipável",
		"values": {
			"name": "New Armor",
			"category": 3,
			"stackable": false,
			"max_stack": 1
		}
	},
	"Key Item": {
		"description": "Item de quest",
		"values": {
			"name": "New Key Item",
			"category": 5,
			"stackable": false,
			"max_stack": 1
		}
	}
}

# ========== SKILL PRESETS ==========
const SKILL_PRESETS = {
	"Active": {
		"description": "Habilidade ativa",
		"values": {
			"name": "New Skill",
			"cost": 1,
			"max_level": 5
		}
	},
	"Passive": {
		"description": "Habilidade passiva",
		"values": {
			"name": "New Passive",
			"cost": 1,
			"max_level": 1
		}
	},
	"Ultimate": {
		"description": "Habilidade poderosa",
		"values": {
			"name": "New Ultimate",
			"cost": 3,
			"required_level": 10,
			"max_level": 3
		}
	}
}

# ========== COMPOSE PRESETS ==========
const COMPOSE_PRESETS = {
	"Movement Set": {
		"description": "Conjunto de movimentos básicos",
		"values": {}
	},
	"Combat Set": {
		"description": "Conjunto de ataques",
		"values": {}
	},
	"Full Set": {
		"description": "Movimento + Combate",
		"values": {}
	}
}

static func get_presets_for_type(type_name: String) -> Dictionary:
	match type_name:
		"State": return STATE_PRESETS
		"Item": return ITEM_PRESETS
		"Skill": return SKILL_PRESETS
		"Compose": return COMPOSE_PRESETS
	return {}

static func get_preset_names_for_type(type_name: String) -> Array:
	var presets = get_presets_for_type(type_name)
	return presets.keys()

static func apply_preset_to_resource(res: Resource, type_name: String, preset_name: String) -> void:
	var presets = get_presets_for_type(type_name)
	if not preset_name in presets:
		return
	
	var values = presets[preset_name].get("values", {})
	for key in values.keys():
		if key in res:
			res.set(key, values[key])
