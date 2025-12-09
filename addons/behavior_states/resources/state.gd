@tool
class_name State extends Resource

# Enums (Definitions)
enum Motion { ANY=0, IDLE, WALK, RUN, DASH, EXCEPT_DASH }
enum Jump { ANY=0, NONE, LOW, HIGH, FALL }
enum Attack { ANY=0, NONE, FAST, NORMAL, CHARGED, SPECIAL }
enum Physics { ANY=0, GROUND, AIR, WATER, EXCEPT_GROUND, EXCEPT_AIR, EXCEPT_WATER }
enum Effect { ANY=0, NONE, FIRE, ICE, POISON, ELECTRIC }
enum Weapon { ANY=0, NONE, KATANA, BOW, EXCEPT_NONE }
enum Armor { ANY=0, NONE, IRON, STEEL, GOLD, DIAMOND }
enum Stance { ANY=0, STAND, CROUCH, BLOCK, CLIMB, COVER }
enum Tier { ANY=0, BASE, UPGRADED, MASTER, CORRUPTED }
enum GameState { ANY=0, PLAYING, PAUSED, CUTSCENE, MENU }
enum StateType { MOVE=0, ATTACK, INTERACTIVE, GAME }
enum Status { ANY=0, NORMAL, STUNNED, INVULNERABLE, SUPER_ARMOR, DEAD }
enum InputSource { ANY=0, PLAYER, AI, CINEMATIC, FORCE }
enum EnvType { ANY=0, OPEN, TIGHT_CORRIDOR, LEDGE, WATER_SURFACE }
enum Reaction { IGNORE=0, CANCEL, ADAPT, FINISH }
enum CostType { NONE=0, STAMINA, MANA, HEALTH, AMMO }
enum LowResourceRule { IGNORE_COMMAND=0, EXECUTE_WEAK, CONSUME_HEALTH }
enum ComboStep { NONE=0, STEP_1, STEP_2, STEP_3, STEP_4, FINISHER }

@export var name: String = "New State"
@export var icon: Texture2D
@export var debug_color: Color = Color.RED

## Requisitos para ENTRAR neste estado.
@export var entry_requirements: Dictionary = {
	"attack": Attack.ANY,
	"effect": Effect.ANY,
	"jump": Jump.ANY,
	"motion": Motion.ANY,
	"physics": Physics.ANY,
	"status": Status.ANY
}

## Requisitos para MANTER este estado rodando.
@export var hold_requirements: Dictionary = {
	"attack": Attack.ANY,
	"motion": Motion.ANY,
	"status": Status.ANY,
	"min_time": 0.0 
}

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
