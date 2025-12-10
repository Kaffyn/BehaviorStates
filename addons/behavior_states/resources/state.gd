@tool
class_name State
extends Resource

## State (Base Resource)
##
## A unidade fundamental de comportamento (Dados + Metadados).
## A lógica de execução (Physics, Hitbox, etc) VIVE NOS COMPONENTES.
## Este arquivo apenas define a IDENTIDADE e os METADADOS para indexação (Hash Map).

@export_group("Identity & Visuals")
@export var name: String = "State"
@export var priority_override: int = 0 ## Se > 0, ganha prioridade na seleção.
@export var icon: Texture2D
@export var animation_res: Animation
@export var loop: bool = false
@export var speed: float = 1.0
@export var debug_color: Color = Color.WHITE

@export_group("Requirements (Filters)")
# Estes campos existem APENAS para o sistema de Indexação O(1).
# Eles definem QUANDO este estado pode rodar, não O QUE ele faz.
@export var weapon: BehaviorStates.Weapon = BehaviorStates.Weapon.ANY
@export var motion: BehaviorStates.Motion = BehaviorStates.Motion.ANY
@export var attack: BehaviorStates.Attack = BehaviorStates.Attack.ANY
@export var physics: BehaviorStates.Physics = BehaviorStates.Physics.ANY
@export var jump: BehaviorStates.Jump = BehaviorStates.Jump.ANY

@export_group("Reaction Rules")
# Metadados para a Máquina saber como reagir a eventos externos sem carregar compomentes.
@export var on_physics_change: BehaviorStates.Reaction = BehaviorStates.Reaction.IGNORE
@export var on_weapon_change: BehaviorStates.Reaction = BehaviorStates.Reaction.IGNORE
@export var on_motion_change: BehaviorStates.Reaction = BehaviorStates.Reaction.IGNORE
@export var on_take_damage: BehaviorStates.Reaction = BehaviorStates.Reaction.IGNORE

## Gera a chave de Hash para este Estado baseada nos seus Requisitos.
## Esta função é crítica para a performance (Lookup O(1)).
func get_lookup_key() -> int:
	var key: int = 0
	
	key |= (weapon & 0xFF) << 32
	key |= (motion & 0xFF) << 24
	key |= (attack & 0xFF) << 16
	key |= (physics & 0xFF) << 8
	key |= (jump & 0xFF)
	
	return key

# ==================== COMPONENT SYSTEM ====================
# A Lógica Real (Motion, Combat, Stats) vive aqui dentro.
@export_group("Components")
@export var components: Array[StateComponent] = []

## Tries to find a component of the given type. Returns null if not found.
func get_component(type_name: String) -> StateComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

## Tries to find a component by class.
func get_component_by_class(type: Variant) -> StateComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null
