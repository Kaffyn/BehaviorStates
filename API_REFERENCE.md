# BehaviorStates — API Reference

> **Propósito:** Referência técnica completa com contratos formais para todos os componentes do plugin.

---

## Sumário

- [BehaviorStates — API Reference](#behaviorstates--api-reference)
  - [Sumário](#sumário)
  - [1. Vocabulário Global](#1-vocabulário-global)
  - [2. Core Resources](#2-core-resources)
    - [2.1 State](#21-state)
    - [2.2 Compose](#22-compose)
  - [3. Core Nodes](#3-core-nodes)
    - [3.1 Behavior](#31-behavior)
    - [3.2 Machine](#32-machine)
    - [3.3 Backpack](#33-backpack)
  - [4. Components](#4-components)
    - [4.1 StateComponent](#41-statecomponent)
    - [4.2 ItemComponent](#42-itemcomponent)
    - [4.3 EffectComponent](#43-effectcomponent)
    - [4.4 SkillComponent](#44-skillcomponent)
    - [4.5 CharacterComponent](#45-charactercomponent)
  - [5. Extensions](#5-extensions)
    - [Item](#item)
    - [Effect](#effect)
    - [Skill](#skill)
    - [SkillTree](#skilltree)
    - [Inventory](#inventory)
    - [CharacterSheet](#charactersheet)
  - [6. Algoritmo de Seleção](#6-algoritmo-de-seleção)
    - [Fase 1: Lookup O(K)](#fase-1-lookup-ok)
    - [Fase 2: Scoring](#fase-2-scoring)
    - [Fase 3: Desempate](#fase-3-desempate)
    - [Complexidade](#complexidade)
  - [7. Estrutura de Pastas](#7-estrutura-de-pastas)

---

## 1. Vocabulário Global

> **Arquivo:** `behavior_states.gd` | **Tipo:** Autoload

```gdscript
extends Node

enum Motion { IDLE, WALK, RUN, DASH, CLIMB, SWIM }
enum Physics { GROUND, AIR, WATER, LADDER, WALL }
enum Attack { NONE, FAST, NORMAL, CHARGED, SPECIAL }
enum Weapon { NONE, SWORD, BOW, STAFF, SHIELD }
enum Reaction { CANCEL, ADAPT, FINISH }
enum Status { NORMAL, STUNNED, INVINCIBLE, DEAD }
```

---

## 2. Core Resources

### 2.1 State

> **Arquivo:** `core/state.gd` | **Tipo:** Resource

O State é minimalista — comportamento fica nos Components.

```gdscript
class_name State extends Resource

# IDENTITY
@export var id: StringName = &""
@export var priority_override: int = 0

# REQUIREMENTS
@export var entry_requirements: Dictionary = {}   # { "Category": value }
@export var maintenance: Dictionary = {}

# TIMING
@export var duration: float = -1.0          # -1 = infinito
@export var cooldown: float = 0.0
@export var sticky: bool = false

# COMBO
@export var next_combo_state: State = null

# COMPONENTS
@export var components: Array[StateComponent] = []
```

| Propriedade          | Tipo                  | Descrição                          |
| :------------------- | :-------------------- | :--------------------------------- |
| `id`                 | StringName            | Identificador único                |
| `priority_override`  | int                   | Prioridade para desempate          |
| `entry_requirements` | Dictionary            | Requisitos para entrar             |
| `maintenance`        | Dictionary            | Requisitos para manter ativo       |
| `duration`           | float                 | Tempo de vida (-1 = infinito)      |
| `cooldown`           | float                 | Tempo de recarga após uso          |
| `sticky`             | bool                  | Se true, não pode ser interrompido |
| `next_combo_state`   | State                 | Próximo state do combo (opcional)  |
| `components`         | Array[StateComponent] | Lista de components                |

---

### 2.2 Compose

> **Arquivo:** `core/compose.gd` | **Tipo:** Resource

```gdscript
class_name Compose extends Resource

@export var id: StringName = &""
@export var states: Array[State] = []
@export var parent: Compose = null

# Índice invertido: { "Category": { value: [State, ...] } }
var _index: Dictionary = {}
```

| Método                                             | Retorno      | Descrição                                      |
| :------------------------------------------------- | :----------- | :--------------------------------------------- |
| `get_states_for_key(category: String, value: int)` | Array[State] | Lookup O(1) por categoria + valor              |
| `get_candidates(context: Dictionary)`              | Array[State] | Retorna states que satisfazem o contexto       |
| `build_index()`                                    | void         | Reconstrói índice invertido (TODAS categorias) |

---

## 3. Core Nodes

### 3.1 Behavior

> **Arquivo:** `core/behavior.gd` | **Tipo:** Node
>
> **Gerencia:** Character, Effect, Skill, SkillTree

```gdscript
class_name Behavior extends Node

# Exports
@export var character_sheet: CharacterSheet
@export var skill_tree: SkillTree

# Signals
signal context_changed(category: StringName, old_value: int, new_value: int)
signal effect_applied(effect: Effect)
signal effect_removed(effect: Effect)
signal skill_learned(skill: Skill)
signal stat_changed(stat_name: StringName, old_value: float, new_value: float)
```

| Método                                         | Retorno | Descrição                   |
| :--------------------------------------------- | :------ | :-------------------------- |
| `set_intent(category: StringName, value: int)` | void    | Define intenção no contexto |
| `get_context(category: StringName)`            | int     | Lê valor atual do contexto  |
| `apply_effect(effect: Effect)`                 | void    | Aplica efeito ativo         |
| `remove_effect(effect: Effect)`                | void    | Remove efeito               |
| `learn_skill(skill: Skill)`                    | void    | Aprende skill               |
| `get_stat(name: StringName)`                   | float   | Lê stat calculado           |
| `modify_stat(name: StringName, delta: float)`  | void    | Modifica stat               |

---

### 3.2 Machine

> **Arquivo:** `core/machine.gd` | **Tipo:** Node
>
> **Gerencia:** Compose, State

```gdscript
class_name Machine extends Node

# Exports
@export var behavior: Behavior
@export var compose: Compose

# Signals
signal state_changed(from: State, to: State)
signal state_entered(state: State)
signal state_exited(state: State)
signal cooldown_started(state_id: StringName, duration: float)

# Readonly
var current_state: State
```

| Método                                         | Retorno | Descrição                |
| :--------------------------------------------- | :------ | :----------------------- |
| `force_state(state: State)`                    | void    | Força transição imediata |
| `is_state_available(state: State)`             | bool    | Verifica cooldown        |
| `get_remaining_cooldown(state_id: StringName)` | float   | Tempo restante           |

---

### 3.3 Backpack

> **Arquivo:** `core/backpack.gd` | **Tipo:** Node
>
> **Gerencia:** Inventory, Item

```gdscript
class_name Backpack extends Node

# Exports
@export var inventory: Inventory

# Signals
signal item_added(item: Item, slot: int)
signal item_removed(item: Item, slot: int)
signal item_equipped(item: Item, slot_type: StringName)
signal item_unequipped(item: Item, slot_type: StringName)
signal compose_switched(old_compose: Compose, new_compose: Compose)

# Readonly
var equipped: Dictionary = {}  # { slot_type: Item }
```

| Método                                | Retorno | Descrição                         |
| :------------------------------------ | :------ | :-------------------------------- |
| `add_item(item: Item)`                | bool    | Adiciona item ao inventário       |
| `remove_item(item: Item)`             | bool    | Remove item                       |
| `equip(item: Item)`                   | void    | Equipa item (pode trocar Compose) |
| `unequip(slot_type: StringName)`      | void    | Desequipa slot                    |
| `get_equipped(slot_type: StringName)` | Item    | Retorna item equipado             |

---

## 4. Components

> **Arquivo:** `core/state_context.gd` | **Tipo:** RefCounted

O StateContext é o objeto de **injeção de dependências** passado para todos os Components. Ele fornece acesso seguro aos nodes do personagem e ao input sem acoplar Components ao mundo.

```gdscript
class_name StateContext extends RefCounted

# REFERÊNCIAS DO PERSONAGEM
var body: CharacterBody2D           # Acesso ao CharacterBody
var facing: int = 1                 # Direção (1 = direita, -1 = esquerda)
var animation_tree: AnimationTree   # Para trocar animações
var audio_player: AudioStreamPlayer2D
var space_state: PhysicsDirectSpaceState2D  # Para queries de hitbox

# INPUT (preenchido pelo Behavior, NÃO use Input.* diretamente)
var input_direction: Vector2 = Vector2.ZERO
var input_actions: Dictionary = {}  # { "attack": true, "jump": false }

# STATS (readonly, via CharacterSheet)
var base_speed: float
var base_damage: float

# COMUNICAÇÃO (Components emitem, Machine/Behavior escutam)
signal action_executed(action_name: StringName, data: Dictionary)
signal hit_connected(target: Node2D, damage: float)
```

| Propriedade       | Tipo                      | Descrição                         |
| :---------------- | :------------------------ | :-------------------------------- |
| `body`            | CharacterBody2D           | Referência ao corpo físico        |
| `facing`          | int                       | Direção atual (1 ou -1)           |
| `animation_tree`  | AnimationTree             | Para integração com AnimationTree |
| `input_direction` | Vector2                   | Direção do input normalizada      |
| `input_actions`   | Dictionary                | Ações pressionadas/liberadas      |
| `base_speed`      | float                     | Velocidade base do CharacterSheet |
| `base_damage`     | float                     | Dano base do CharacterSheet       |
| `space_state`     | PhysicsDirectSpaceState2D | Para queries de física (hitboxes) |

### Exemplo de Uso em Component

```gdscript
func on_physics(ctx: StateContext, delta: float) -> void:
    # Ler input do contexto (NUNCA Input.* diretamente)
    var dir = ctx.input_direction
    
    # Aplicar movimento
    ctx.body.velocity.x = dir.x * ctx.base_speed
    
    # Emitir evento
    if hit_something:
        ctx.hit_connected.emit(target, ctx.base_damage)
```

---

## 5. Components

Todos Components herdam de uma base e têm **interface dupla** (runtime + editor).

### 5.1 StateComponent

> **Base para:** State behavior

```gdscript
class_name StateComponent extends Resource

# RUNTIME INTERFACE
func on_enter(ctx: StateContext) -> void
func on_physics(ctx: StateContext, delta: float) -> void
func on_exit(ctx: StateContext) -> void

# EDITOR INTERFACE (static)
static func _get_component_name() -> String
static func _get_component_color() -> Color
static func _get_component_icon() -> Texture2D
static func _get_component_fields() -> Array
```

**Components disponíveis (16):**

| Component           | Cor       | Descrição                        |
| :------------------ | :-------- | :------------------------------- |
| MovementComponent   | 🟢 #22c55e | Velocidade, aceleração, friction |
| PhysicsComponent    | 🔵 #06b6d4 | Gravidade, pulo, air resistance  |
| DashComponent       | 🟢 #22c55e | Dash direcional                  |
| ClimbComponent      | 🟢 #22c55e | Escalada                         |
| HitboxComponent     | 🔴 #ef4444 | Dano query-based                 |
| ProjectileComponent | 🟠 #f97316 | Spawn de projéteis               |
| ChargedComponent    | 🟣 #8b5cf6 | Ataques carregados               |
| ParryComponent      | 🟣 #8b5cf6 | Defesa ativa                     |
| AnimationComponent  | 🟣 #a855f7 | Integração AnimationTree         |
| SpriteComponent     | 🟣 #a855f7 | Sprite frames                    |
| VFXComponent        | 🔵 #06b6d4 | Partículas e efeitos             |
| AudioComponent      | 🔵 #06b6d4 | Som ao entrar                    |
| ComboComponent      | 🟡 #eab308 | Chain de ataques                 |
| BufferComponent     | 🟡 #eab308 | Input buffering                  |
| CostComponent       | 🟠 #f59e0b | Custo de recurso                 |
| InterruptComponent  | 🩷 #ec4899 | Política de interrupção          |

---

### 5.2 ItemComponent

> **Base para:** Item properties

```gdscript
class_name ItemComponent extends Resource

# RUNTIME INTERFACE
func on_use(ctx: ItemContext) -> void
func on_equip(ctx: ItemContext) -> void
func on_unequip(ctx: ItemContext) -> void

# EDITOR INTERFACE (static)
static func _get_component_name() -> String
static func _get_component_color() -> Color
static func _get_component_fields() -> Array
```

**Components disponíveis (14):**

| Component               | Descrição                              |
| :---------------------- | :------------------------------------- |
| ItemIdentityComponent   | id, name, description, icon            |
| RarityComponent         | rarity, color, sparkle                 |
| CategoryComponent       | category, subcategory, tags            |
| StackableComponent      | max_stack, quantity                    |
| DurabilityComponent     | max_durability, current, break_effect  |
| QualityComponent        | quality_level, quality_mult            |
| ConsumableComponent     | consume_on_use, use_time, effects      |
| PlaceableComponent      | placed_scene, placement_rules          |
| EquipmentComponent      | slot_type, compose, equip_effects      |
| WeaponComponent         | damage_type, base_damage, attack_speed |
| ArmorComponent          | defense, resistances, weight           |
| AccessoryComponent      | passive_effects, set_bonus_id          |
| EconomyComponent        | buy_price, sell_price                  |
| CraftingRecipeComponent | ingredients, output_qty, craft_time    |

---

### 5.3 EffectComponent

> **Base para:** Buffs e Debuffs

```gdscript
class_name EffectComponent extends Resource

# RUNTIME INTERFACE
func on_apply(ctx: EffectContext) -> void
func on_tick(ctx: EffectContext, delta: float) -> void
func on_remove(ctx: EffectContext) -> void

# EDITOR INTERFACE (static)
static func _get_component_name() -> String
static func _get_component_color() -> Color
static func _get_component_fields() -> Array
```

**Components disponíveis (12):**

| Component               | Descrição                             |
| :---------------------- | :------------------------------------ |
| EffectIdentityComponent | id, name, description, icon           |
| DurationComponent       | effect_type, duration, tick_interval  |
| StackingComponent       | stackable, max_stacks, stack_behavior |
| StatModifierComponent   | stat_name, modifier_type, value       |
| SpeedModifierComponent  | move_speed_mult, attack_speed_mult    |
| DamageModifierComponent | damage_mult, damage_type_bonus        |
| DamageOverTimeComponent | damage_per_tick, damage_type          |
| HealOverTimeComponent   | heal_per_tick                         |
| PoisonComponent         | damage_per_second, curable            |
| BurnComponent           | damage_per_tick, spread_chance        |
| StunComponent           | stun_duration, break_on_damage        |
| EffectVisualComponent   | particle_scene, tint_color, shader    |

---

### 5.4 SkillComponent

> **Base para:** Skill Tree progression

```gdscript
class_name SkillComponent extends Resource

# RUNTIME INTERFACE
func on_learn(ctx: SkillContext) -> void
func on_activate(ctx: SkillContext) -> void
func on_level_up(ctx: SkillContext) -> void

# EDITOR INTERFACE (static)
static func _get_component_name() -> String
static func _get_component_color() -> Color
static func _get_component_fields() -> Array
```

**Components disponíveis (10):**

| Component                 | Descrição                         |
| :------------------------ | :-------------------------------- |
| SkillIdentityComponent    | id, name, description, icon       |
| SkillTypeComponent        | skill_type, rarity, tree_position |
| LevelRequirementComponent | min_level, xp_cost                |
| SkillPointCostComponent   | skill_points, refundable          |
| PrerequisiteComponent     | required_skills, any_of, all_of   |
| UnlockStatesComponent     | states_to_unlock                  |
| UnlockItemsComponent      | items_to_unlock                   |
| PassiveEffectComponent    | effects                           |
| ActiveAbilityComponent    | activation_state, cooldown, cost  |
| SkillLevelComponent       | max_level, current, scaling       |

---

### 5.5 CharacterComponent

> **Base para:** Character stats (dados estáticos, sem hooks)

```gdscript
class_name CharacterComponent extends Resource

# EDITOR INTERFACE (static)
static func _get_component_name() -> String
static func _get_component_color() -> Color
static func _get_component_fields() -> Array
```

**Components disponíveis (8):**

| Component               | Descrição                              |
| :---------------------- | :------------------------------------- |
| HealthComponent         | max_health, current, regen_rate        |
| StaminaComponent        | max_stamina, current, regen_rate       |
| ManaComponent           | max_mana, current, regen_rate          |
| BaseAttributesComponent | strength, agility, intelligence        |
| DerivedStatsComponent   | attack_power, defense, crit_chance     |
| MovementStatsComponent  | move_speed, jump_force                 |
| ExperienceComponent     | current_xp, level, xp_curve            |
| CombatStatsComponent    | base_damage, attack_speed, crit_damage |

---

## 6. Extensions

### Item

```gdscript
class_name Item extends Resource

@export var id: StringName = &""
@export var components: Array[ItemComponent] = []
```

### Effect

```gdscript
class_name Effect extends Resource

@export var id: StringName = &""
@export var components: Array[EffectComponent] = []
```

### Skill

```gdscript
class_name Skill extends Resource

@export var id: StringName = &""
@export var components: Array[SkillComponent] = []
```

### SkillTree

```gdscript
class_name SkillTree extends Resource

@export var skills: Array[Skill] = []
@export var prerequisites: Dictionary = {}  # { skill_id: [required_ids] }
```

### Inventory

```gdscript
class_name Inventory extends Resource

@export var capacity: int = 24
@export var slots: Array[Item] = []
```

### CharacterSheet

```gdscript
class_name CharacterSheet extends Resource

@export var components: Array[CharacterComponent] = []
```

---

## 7. Algoritmo de Seleção

O sistema usa um **índice invertido** (HashMap) para lookup O(K).

### Fase 1: Indexação (Build Time)

O `Compose` constrói índices **por categoria** quando inicializado:

```gdscript
# compose.gd
func build_index() -> void:
    _index.clear()
    for state in states:
        # Indexa TODAS as categorias do entry_requirements
        for category in state.entry_requirements.keys():
            var value = state.entry_requirements[category]
            if not _index.has(category):
                _index[category] = {}
            if not _index[category].has(value):
                _index[category][value] = []
            _index[category][value].append(state)

## Lookup O(1) por categoria + valor
func get_states_for_key(category: String, value: int) -> Array[State]:
    if _index.has(category) and _index[category].has(value):
        return _index[category][value]
    return []
```

### Fase 2: Lookup O(K)

A `Machine` consulta o índice por cada categoria do contexto:

```gdscript
# machine.gd
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
```

### Fase 3: Scoring O(C)

```gdscript
func _calculate_score(state: State) -> int:
    var score = 0
    score += state.priority_override * 100
    
    # Bonus por especificidade
    for category in state.entry_requirements.keys():
        if state.entry_requirements[category] > 0:
            score += 10
    
    # Bonus de combo
    if current_state and state == current_state.next_combo_state:
        if combo_window_open:
            score += 50
    
    return score
```

### Fase 4: Desempate

1. Maior score (especificidade + priority)
2. Combo chain bonus
3. Ordem de inserção no Compose

### Complexidade

| Operação  | Complexidade                               |
| :-------- | :----------------------------------------- |
| Indexação | O(N) — build time, uma vez por Compose     |
| Lookup    | O(K) onde K = categorias do contexto atual |
| Scoring   | O(C) onde C = candidatos (já filtrados)    |
| Transição | O(1) — apenas troca referência             |

---

## 8. Estrutura de Pastas

```text
addons/behavior_states/
├── core/
│   ├── component_base.gd
│   ├── state_component.gd
│   ├── item_component.gd
│   ├── effect_component.gd
│   ├── skill_component.gd
│   ├── character_component.gd
│   ├── state.gd
│   ├── compose.gd
│   ├── behavior.gd
│   ├── machine.gd
│   └── backpack.gd
│
├── components/
│   ├── state/      # 16 components
│   ├── item/       # 14 components
│   ├── effect/     # 12 components
│   ├── skill/      # 10 components
│   └── character/  # 8 components
│
├── extensions/
│   ├── item.gd
│   ├── effect.gd
│   ├── skill.gd
│   ├── skill_tree.gd
│   ├── inventory.gd
│   └── character_sheet.gd
│
└── editor/
    └── ...
```

**Total: 60 Components unificados em 5 categorias**

---

## 9. Receitas Comuns

### Criar um State de Ataque

```gdscript
# res://states/attack_light.tres
[resource]
script = preload("res://addons/behavior_states/core/state.gd")

id = &"attack_light"
priority = 10
duration = 0.5
cooldown = 0.3

requirements = {
    "Attack": 1,    # Attack.FAST
    "Physics": 0    # Physics.GROUND
}

components = [
    preload("res://states/components/attack_animation.tres"),
    preload("res://states/components/attack_hitbox.tres"),
    preload("res://states/components/attack_audio.tres")
]
```

### Aplicar um Effect de Veneno

```gdscript
# No código do projétil ou hitbox
func _on_hit(target: Node2D) -> void:
    var behavior = target.get_node_or_null("Behavior")
    if behavior:
        var poison = preload("res://effects/poison.tres")
        behavior.apply_effect(poison)
```

```gdscript
# res://effects/poison.tres
[resource]
script = preload("res://addons/behavior_states/extensions/effect.gd")

id = &"poison"
components = [
    preload("res://effects/components/poison_dot.tres"),
    preload("res://effects/components/poison_visual.tres")
]
```

### Equipar Arma e Trocar Compose

```gdscript
# Equipar uma espada (troca Compose automaticamente)
func _on_sword_picked_up(sword_item: Item) -> void:
    backpack.equip(sword_item)
    # O Backpack emite compose_switched
    # A Machine agora usa o Compose da espada
```

```gdscript
# res://items/iron_sword.tres
[resource]
script = preload("res://addons/behavior_states/extensions/item.gd")

id = &"iron_sword"
components = [
    preload("res://items/components/sword_identity.tres"),
    preload("res://items/components/sword_weapon.tres"),
    preload("res://items/components/sword_equipment.tres")  # Contém o Compose!
]
```

### Verificar Cooldown antes de Usar Skill

```gdscript
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("special_attack"):
        var dash_state = preload("res://states/dash.tres")
        if machine.is_state_available(dash_state):
            behavior.set_intent("Motion", BehaviorStates.Motion.DASH)
        else:
            var remaining = machine.get_remaining_cooldown(dash_state.id)
            print("Dash em cooldown: %.1fs" % remaining)
```

---

_BehaviorStates — API Reference v6.0_
