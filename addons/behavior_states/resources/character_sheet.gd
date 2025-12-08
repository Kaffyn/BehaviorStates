## A Ficha de Personagem (Stats Container).
##
## Armazena atributos vitais como HP, Stamina e Mana, desacoplados da lógica.

class_name CharacterSheet extends Resource

signal stats_changed

@export_group("Vitals")
@export var max_health: int = 100
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 12.0

@export_group("Movement")
@export var max_speed: float = 230.0
@export var default_acceleration: float = 1200.0
@export var default_friction: float = 1000.0
@export var default_air_resistance: float = 200.0

@export_group("Jump")
@export var jump_force: float = -500.0
@export var gravity_scale: float = 1.0
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.1

@export_group("Progression")
@export var level: int = 1
@export var experience: int = 0
@export var skill_points: int = 0
@export var skill_tree: SkillTree
@export var unlocked_skills: Dictionary = {} # { "skill_id": level }
@export var statistics: Dictionary = {} # { "kills": 100, "time_played": 5000 }
@export var attributes: Dictionary = {} # { "strength": 10, "agility": 5 }
@export var equipment: Dictionary = {} # { "weapon": Item, "armor": Item }

func unlock_skill(skill: Skill) -> bool:
	if not skill: return false
	
	if unlocked_skills.has(skill.id):
		# Upgrade logic
		if unlocked_skills[skill.id] < skill.max_level:
			unlocked_skills[skill.id] += 1
			return true
	else:
		# Unlock logic
		if skill.can_unlock(self, unlocked_skills.keys()):
			unlocked_skills[skill.id] = 1
			return true
			
	return false

func has_skill(skill_id: String) -> bool:
	return unlocked_skills.has(skill_id)
