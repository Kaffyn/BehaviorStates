# BehaviorStates — Internals

> **Propósito:** Implementação detalhada em GDScript para desenvolvedores do plugin.

---

## 1. State — Resource Minimalista

```gdscript
class_name State extends Resource

# ══════════════════════════════════════════════════════════════
# IDENTITY (2 props)
# ══════════════════════════════════════════════════════════════
@export var id: StringName = &""
@export var priority_override: int = 0

# ══════════════════════════════════════════════════════════════
# REQUIREMENTS (2 props)
# ══════════════════════════════════════════════════════════════
@export var entry_requirements: Dictionary = {}   # { "Category": value }
@export var maintenance: Dictionary = {}

# ══════════════════════════════════════════════════════════════
# TIMING (3 props)
# ══════════════════════════════════════════════════════════════
@export var duration: float = -1.0
@export var cooldown: float = 0.0
@export var sticky: bool = false

# ══════════════════════════════════════════════════════════════
# COMBO
# ══════════════════════════════════════════════════════════════
@export var next_combo_state: State = null

# ══════════════════════════════════════════════════════════════
# COMPONENTS (o que este state FAZ)
# ══════════════════════════════════════════════════════════════
@export var components: Array[StateComponent] = []
```

**Total: 8 propriedades**

---

## 2. StateComponent — Base Unificada

```gdscript
class_name StateComponent extends Resource

# ══════════════════════════════════════════════════════════════
# RUNTIME INTERFACE
# ══════════════════════════════════════════════════════════════

## Chamado quando state é ativado
func on_enter(ctx: StateContext) -> void:
    pass

## Chamado a cada physics frame
func on_physics(ctx: StateContext, delta: float) -> void:
    pass

## Chamado quando state é desativado
func on_exit(ctx: StateContext) -> void:
    pass

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (para o painel visual)
# ══════════════════════════════════════════════════════════════

## Nome exibido no editor
static func _get_component_name() -> String:
    return "Component"

## Cor do node no GraphEdit
static func _get_component_color() -> Color:
    return Color.WHITE

## Ícone para a biblioteca (opcional)
static func _get_component_icon() -> Texture2D:
    return null

## Campos editáveis (para gerar UI dinamicamente)
## Retorna: [{ "name": "x", "type": "float", "default": 0.0 }, ...]
static func _get_component_fields() -> Array:
    return []
```

---

## 3. StateContext — Injeção de Dependências

```gdscript
class_name StateContext extends RefCounted

# ══════════════════════════════════════════════════════════════
# REFERÊNCIAS DO PERSONAGEM
# ══════════════════════════════════════════════════════════════
var body: CharacterBody2D
var facing: int = 1  # 1 ou -1
var animation_tree: AnimationTree
var audio_player: AudioStreamPlayer2D
var space_state: PhysicsDirectSpaceState2D

# ══════════════════════════════════════════════════════════════
# INPUT (preenchido pelo Behavior, NÃO leia Input.* diretamente)
# ══════════════════════════════════════════════════════════════
var input_direction: Vector2 = Vector2.ZERO
var input_actions: Dictionary = {}  # { "attack": true, "jump": false }

# ══════════════════════════════════════════════════════════════
# STATS (readonly, via CharacterSheet)
# ══════════════════════════════════════════════════════════════
var base_speed: float
var base_damage: float

# ══════════════════════════════════════════════════════════════
# COMUNICAÇÃO (Components emitem, Machine/Behavior escutam)
# ══════════════════════════════════════════════════════════════
signal action_executed(action_name: StringName, data: Dictionary)
signal hit_connected(target: Node2D, damage: float)

# ══════════════════════════════════════════════════════════════
# RUNTIME STATE (Estado temporal dos Components - NÃO PERSISTÍVEL)
# ══════════════════════════════════════════════════════════════
## Usado por Components para armazenar estado entre frames.
## Limpo automaticamente no on_enter de cada State.
var runtime: Dictionary = {}  # { "component_id": { estado interno } }
```

---

## 4. Machine — Orquestrador

```gdscript
class_name Machine extends Node

signal state_changed(from: State, to: State)

@export var behavior: Behavior
@export var default_compose: Compose
@export var backpack: Backpack

var current_state: State = null
var cooldowns: Dictionary = {}

func _ready() -> void:
    behavior.context_changed.connect(_on_context_changed)

func _on_context_changed(_cat: String, _val: int) -> void:
    _try_transition()

func _try_transition() -> void:
    var compose = _get_active_compose()
    if not compose:
        return
    
    var candidates = _get_candidates(compose)
    var best = _find_best_match(candidates)
    
    if best and best != current_state:
        if best.name in cooldowns:
            return
        change_state(best)

## Obtém candidatos usando lookup O(K) no índice invertido.
func _get_candidates(compose: Compose) -> Array[State]:
    var candidates: Array[State] = []
    var seen: Dictionary = {}
    
    # Lookup por cada categoria do contexto → O(K)
    for category in behavior.context.keys():
        var value = behavior.context[category]
        var states_for_key = compose.get_states_for_key(category, value)
        for state in states_for_key:
            if not seen.has(state.name):
                seen[state.name] = true
                candidates.append(state)
    
    return candidates

func _find_best_match(candidates: Array[State]) -> State:
    var best: State = null
    var best_score: int = -1
    
    for state in candidates:
        if _matches_context(state):
            var score = _calculate_score(state)
            if score > best_score:
                best_score = score
                best = state
    
    return best

func _calculate_score(state: State) -> int:
    var score = state.priority_override * 100
    
    for category in state.entry_requirements.keys():
        if state.entry_requirements[category] > 0:
            score += 10
    
    if current_state and state == current_state.next_combo_state:
        score += 50
    
    return score
```

---

## 5. Components Concretos

### MovementComponent

```gdscript
class_name MovementComponent extends StateComponent

@export var speed_multiplier: float = 1.0
@export var acceleration: float = 0.0
@export var friction: float = 0.0
@export var lock_input: bool = false

func on_physics(ctx: StateContext, delta: float) -> void:
    if lock_input:
        return

    var input = ctx.input_direction
    var speed = ctx.base_speed * speed_multiplier

    if acceleration > 0:
        ctx.body.velocity = ctx.body.velocity.move_toward(
            input * speed, acceleration * delta
        )
    else:
        ctx.body.velocity.x = input.x * speed

static func _get_component_name() -> String:
    return "Movement"

static func _get_component_color() -> Color:
    return Color("#22c55e")

static func _get_component_fields() -> Array:
    return [
        {"name": "speed_multiplier", "type": "float", "default": 1.0},
        {"name": "acceleration", "type": "float", "default": 0.0},
        {"name": "friction", "type": "float", "default": 0.0},
        {"name": "lock_input", "type": "bool", "default": false}
    ]
```

### HitboxComponent (Query-based)

```gdscript
class_name HitboxComponent extends StateComponent

@export var shape: Shape2D
@export var offset: Vector2 = Vector2.ZERO
@export var delay: float = 0.0
@export var active_time: float = 0.1
@export var damage_multiplier: float = 1.0
@export var knockback: Vector2 = Vector2.ZERO
@export var collision_mask: int = 4

# Estado temporal agora vive no ctx.runtime (resolve o problema de Resources compartilhados)
const KEY: String = "hitbox"

func on_enter(ctx: StateContext) -> void:
    ctx.runtime[KEY] = {
        "timer": 0.0,
        "activated": false,
        "hit_targets": []
    }

func on_physics(ctx: StateContext, delta: float) -> void:
    var state: Dictionary = ctx.runtime.get(KEY, {})
    if state.is_empty():
        return
    
    state.timer += delta

    if state.timer < delay or state.timer > delay + active_time:
        return

    if not state.activated:
        state.activated = true

    var params := PhysicsShapeQueryParameters2D.new()
    params.shape = shape
    params.transform = Transform2D(0, ctx.body.global_position + offset * Vector2(ctx.facing, 1))
    params.collision_mask = collision_mask
    params.exclude = [ctx.body.get_rid()]

    var results = ctx.space_state.intersect_shape(params)

    for r in results:
        var target = r.collider
        if target in state.hit_targets:
            continue
        state.hit_targets.append(target)

        var damage = ctx.base_damage * damage_multiplier
        ctx.hit_connected.emit(target, damage)

        if target.has_method("take_damage"):
            target.take_damage(damage, knockback * Vector2(ctx.facing, 1))

static func _get_component_name() -> String:
    return "Hitbox"

static func _get_component_color() -> Color:
    return Color("#ef4444")

static func _get_component_fields() -> Array:
    return [
        {"name": "shape", "type": "Shape2D", "default": null},
        {"name": "offset", "type": "Vector2", "default": Vector2.ZERO},
        {"name": "delay", "type": "float", "default": 0.0},
        {"name": "active_time", "type": "float", "default": 0.1},
        {"name": "damage_multiplier", "type": "float", "default": 1.0},
        {"name": "knockback", "type": "Vector2", "default": Vector2.ZERO},
        {"name": "collision_mask", "type": "int", "default": 4}
    ]
```

### AnimationComponent

```gdscript
class_name AnimationComponent extends StateComponent

@export var animation_name: StringName = &""
@export var blend_time: float = 0.1
@export var speed_scale: float = 1.0

func on_enter(ctx: StateContext) -> void:
    if ctx.animation_tree and animation_name:
        ctx.animation_tree.set(
            "parameters/state/transition_request",
            animation_name
        )

static func _get_component_name() -> String:
    return "Animation"

static func _get_component_color() -> Color:
    return Color("#a855f7")

static func _get_component_fields() -> Array:
    return [
        {"name": "animation_name", "type": "StringName", "default": &""},
        {"name": "blend_time", "type": "float", "default": 0.1},
        {"name": "speed_scale", "type": "float", "default": 1.0}
    ]
```

### ComboComponent

```gdscript
class_name ComboComponent extends StateComponent

@export var next_state: State
@export var window_start: float = 0.0
@export var window_duration: float = 0.3

var _timer: float = 0.0

func on_enter(ctx: StateContext) -> void:
    _timer = 0.0

func on_physics(ctx: StateContext, delta: float) -> void:
    _timer += delta

    if _timer >= window_start and _timer <= window_start + window_duration:
        ctx.action_executed.emit(&"combo_available", {"next": next_state})

static func _get_component_name() -> String:
    return "Combo"

static func _get_component_color() -> Color:
    return Color("#eab308")

static func _get_component_fields() -> Array:
    return [
        {"name": "next_state", "type": "State", "default": null},
        {"name": "window_start", "type": "float", "default": 0.0},
        {"name": "window_duration", "type": "float", "default": 0.3}
    ]
```

---

## 6. Hierarquia de Component Bases

```gdscript
ComponentBase (extends Resource)
├── StateComponent      # on_enter, on_physics, on_exit
├── ItemComponent       # on_use, on_equip, on_unequip
├── EffectComponent     # on_apply, on_tick, on_remove
├── SkillComponent      # on_learn, on_activate, on_level_up
└── CharacterComponent  # (dados estáticos, sem hooks)
```

---

_BehaviorStates — Internals v1.0_
