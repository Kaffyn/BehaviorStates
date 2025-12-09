## StateContext — Objeto de Injeção de Dependências para StateComponents.
##
## Fornece acesso seguro aos nodes do personagem e ao input sem acoplar
## Components ao mundo. Criado pela Machine a cada transição de state.
class_name StateContext extends RefCounted

# ══════════════════════════════════════════════════════════════
# REFERÊNCIAS DO PERSONAGEM
# ══════════════════════════════════════════════════════════════

## Referência ao CharacterBody2D/3D
var body: Node = null

## Direção que o personagem está olhando (1 = direita, -1 = esquerda)
var facing: int = 1

## AnimationTree para controle de animações
var animation_tree: AnimationTree = null

## AnimationPlayer para animações diretas
var animation_player: AnimationPlayer = null

## AudioStreamPlayer para sons posicionais
var audio_player: Node = null

## Sprite2D para manipulação visual
var sprite: Node = null

## PhysicsDirectSpaceState para queries de física (hitboxes efêmeras)
var space_state: PhysicsDirectSpaceState2D = null

# ══════════════════════════════════════════════════════════════
# INPUT (Preenchido pelo Behavior — NUNCA use Input.* diretamente)
# ══════════════════════════════════════════════════════════════

## Direção do input normalizada
var input_direction: Vector2 = Vector2.ZERO

## Ações pressionadas/liberadas neste frame
var input_actions: Dictionary = {}  # { "attack": true, "jump": false }

# ══════════════════════════════════════════════════════════════
# STATS (Readonly — via CharacterSheet)
# ══════════════════════════════════════════════════════════════

## Velocidade base do personagem
var base_speed: float = 200.0

## Dano base do personagem
var base_damage: float = 10.0

## Força de pulo base
var jump_force: float = -500.0

# ══════════════════════════════════════════════════════════════
# RUNTIME STATE (Estado temporal dos Components — NÃO PERSISTÍVEL)
# ══════════════════════════════════════════════════════════════

## Usado por Components para armazenar estado entre frames.
## Limpo automaticamente no on_enter de cada State.
## Ex: { "hitbox": { "timer": 0.0, "activated": false } }
var runtime: Dictionary = {}

# ══════════════════════════════════════════════════════════════
# COMUNICAÇÃO (Components emitem, Machine/Behavior escutam)
# ══════════════════════════════════════════════════════════════

## Emitido quando uma ação é executada (para logging/UI)
signal action_executed(action_name: StringName, data: Dictionary)

## Emitido quando um hit é conectado
signal hit_connected(target: Node, damage: float)

## Emitido quando a janela de combo está disponível
signal combo_available(next_state: Resource)

# ══════════════════════════════════════════════════════════════
# HELPER METHODS
# ══════════════════════════════════════════════════════════════

## Inicializa o contexto com referências do personagem
func setup(character_body: Node) -> void:
	body = character_body
	
	if body:
		sprite = body.get_node_or_null("Sprite2D")
		animation_tree = body.get_node_or_null("AnimationTree")
		animation_player = body.get_node_or_null("AnimationPlayer")
		audio_player = body.get_node_or_null("AudioStreamPlayer2D")
		
		# Determina facing inicial baseado no sprite
		if sprite and "flip_h" in sprite:
			facing = -1 if sprite.flip_h else 1
		
		# Obtém space_state para queries de física
		if body is CharacterBody2D:
			space_state = body.get_world_2d().direct_space_state

## Limpa o runtime state (chamado em transições)
func clear_runtime() -> void:
	runtime.clear()

## Obtém ou cria um namespace de runtime para um component
func get_runtime(key: String) -> Dictionary:
	if not runtime.has(key):
		runtime[key] = {}
	return runtime[key]
