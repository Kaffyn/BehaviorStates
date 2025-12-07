## State - Classe base para todos os Estados do sistema.
##
## Contém propriedades para movimento, combate, visual e requirements.
class_name State extends Resource

# ============= IDENTITY =============
@export_group("Identity & Visuals")
@export var name: String = "State"
@export var texture: Texture2D
@export var hframes: int = 1
@export var vframes: int = 1
@export var animation_res: Animation
@export var loop: bool = false
@export var speed: float = 1.0
@export var sound: AudioStream
@export var debug_color: Color = Color.WHITE

# ============= MOVEMENT =============
@export_group("Movement Logic")
@export var speed_multiplier: float = 1.0
@export var duration: float = 0.0
@export var lock_movement: bool = false
@export var cancel_on_wall: bool = false
@export var ignore_gravity: bool = false

# ============= PHYSICS =============
@export_group("Physics Parameters")
@export var acceleration: float = 0.0
@export var friction: float = 0.0
@export var air_resistance: float = 0.0
@export var jump_force: float = 0.0

# ============= COMBAT =============
@export_group("Combat")
@export var damage: int = 0
@export var area_pivot: Vector2 = Vector2.ZERO
@export var area_size: Vector2 = Vector2.ZERO
@export var preserve_momentum: bool = false

# ============= PROJECTILE =============
@export_group("Combat (Ranged)")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 0.0
@export var projectile_count: int = 0
@export var projectile_spread: float = 0.0
@export var spawn_offset: Vector2 = Vector2.ZERO

# ============= COOLDOWN =============
@export_group("Cooldowns")
@export var cooldown: float = 0.0
@export_enum("None", "Motion", "Attack", "Jump") var context_cooldown_filter: int = 0
@export var context_cooldown_time: float = 0.0

# ============= COMBO =============
@export_group("Combo System")
@export_enum("None", "Step1", "Step2", "Step3", "Finisher") var combo_step: int = 0
@export var next_combo_state: State
@export var combo_window_start: float = 0.0

# ============= CHARGED =============
@export_group("Charged Attack")
@export var is_charged: bool = false
@export var min_charge_time: float = 0.0
@export var max_charge_time: float = 0.0
@export var fully_charged_damage_multiplier: float = 1.0

# ============= BUFFS =============
@export_group("Buffs & Debuffs")
@export var buffs: Array[Resource] = []

# ============= TIMING =============
@export_group("Timing & Windows")
@export var cancel_min_time: float = 0.0
@export var enable_buffering: bool = false
@export var buffer_window_start: float = 0.0

# ============= COSTS =============
@export_group("Costs")
@export_enum("None", "Stamina", "Mana", "Health") var cost_type: int = 0
@export var cost_amount: int = 0
@export_enum("Ignore", "Block", "Weaken") var on_insufficient_resource: int = 0

# ============= REQUIREMENTS =============
@export_category("Filters (Requirements)")
@export var priority_override: int = 0
@export var previous_states: Array[State] = []
@export var entry_requirements: Dictionary = {}
@export var maintenance_requirements: Dictionary = {}

# ============= RESOURCE REQUIREMENTS =============
@export_group("Resource Requirements")
@export var req_min_hp: float = 0.0
@export var req_max_hp: float = 100.0

# ============= REACTIONS =============
@export_category("Reaction Rules")
@export_enum("Cancel", "Adapt", "Ignore", "Finish") var on_physics_change: int = 1
@export_enum("Cancel", "Adapt", "Ignore", "Finish") var on_weapon_change: int = 1
@export_enum("Cancel", "Adapt", "Ignore", "Finish") var on_motion_change: int = 1
@export_enum("Cancel", "Adapt", "Ignore", "Finish") var on_attack_change: int = 1
@export_enum("Cancel", "Adapt", "Ignore", "Finish") var on_take_damage: int = 1

## Retorna a chave de busca para o HashMap.
func get_lookup_key() -> int:
	var motion = entry_requirements.get("motion", 0)
	var attack = entry_requirements.get("attack", 0)
	
	if attack > 0:
		return attack
	return motion
