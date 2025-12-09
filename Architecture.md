# BehaviorStates — Arquitetura

> **Propósito:** Diagramas, fluxos e estrutura de comunicação entre Nodes.

---

## 1. Estrutura do Personagem

### 2D (CharacterBody2D)

```text
CharacterBody2D (Player)
├── Sprite2D                    # Visual
├── AnimationTree               # OBRIGATÓRIO - State machine de animação
│   └── AnimationPlayer         # Biblioteca de animações
├── CollisionShape2D            # Colisão do corpo
├── AudioStreamPlayer2D         # Som posicional
│
├── Behavior                    # CUSTOM - Intent layer
├── Machine                     # CUSTOM - State selection
└── Backpack                    # CUSTOM - Inventory (opcional)
```

### 3D (CharacterBody3D)

```text
CharacterBody3D (Player)
├── Node3D (Visual Root)
│   ├── Skeleton3D              # Armature
│   │   └── MeshInstance3D      # Model
│   └── AnimationTree           # OBRIGATÓRIO
│       └── AnimationPlayer
├── CollisionShape3D            # Colisão
├── AudioStreamPlayer3D         # Áudio
│
├── Behavior                    # CUSTOM
├── Machine                     # CUSTOM
└── Backpack                    # CUSTOM (opcional)
```

---

## 2. Fluxo de Autoridade

```text
Input (Godot nativo)
    │
    ▼
Behavior (traduz input → intent)
    │ context_changed
    ▼
Machine (seleciona e executa state)  ◄── compose_switched ── Backpack
    │ state_changed                                              │
    ▼                                                            │
StateContext (injeção de dependências)                            │
    │ body, input, stats, runtime                                │
    ▼                                                            │
Components (executam lógica atômica)                             │
    │                                                            │
    ▼                                                            │
Nodes Nativos (AnimationTree, Physics, Audio)                    │
                                                                 │
Behavior ◄───────── item_equipped (aplica equip_effects) ────────┘
```

---

## 3. Comunicação Entre Nodes

```text
┌──────────────────────────────────────────────────────────────────────┐
│                     FLUXO DE COMUNICAÇÃO                             │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   Backpack ─────item_equipped────→ Behavior                          │
│      │                                 │                             │
│      │                                 │ (aplica equip_effects)      │
│      │                                 ▼                             │
│      │                             Effect aplicado                   │
│      │                                 │                             │
│      └──compose_switched────→ Machine ←┘ context_changed             │
│                                   │                                  │
│                                   ▼                                  │
│                             state_changed                            │
│                                   │                                  │
│                                   ▼                                  │
│                           Components executam                        │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Regras de Comunicação

| De           | Para         | Via                       | Quando                          |
| :----------- | :----------- | :------------------------ | :------------------------------ |
| Input Layer  | Behavior     | `behavior.set_intent()`   | Jogador pressiona tecla         |
| Behavior     | Machine      | `context_changed` signal  | Contexto muda                   |
| Machine      | StateContext | Injeção de dependências   | A cada frame                    |
| StateContext | Components   | `on_physics(ctx, delta)`  | A cada physics frame            |
| Backpack     | Machine      | `compose_switched` signal | Item equipado tem Compose       |
| Backpack     | Behavior     | `item_equipped` signal    | Aplicar equip_effects           |
| Machine      | Behavior     | `state_changed` signal    | Para logging/UI                 |
| Component    | Machine      | `StateContext` signals    | Hit conectado, combo disponível |

---

## 4. Hierarquia de Resources

```text
Behavior
├── CharacterSheet (Resource)
│   └── CharacterComponents[] ← Átomos (Health, Stamina, etc.)
├── SkillTree (Resource)
│   └── Skills[] ← Moléculas
│       └── SkillComponents[] ← Átomos
└── Effects[] (runtime)
    └── EffectComponents[] ← Átomos

Machine
├── Compose (Resource)
│   └── States[] ← Moléculas
│       └── StateComponents[] ← Átomos
└── StateContext (runtime) ← Injeção de deps

Backpack
├── Inventory (Resource)
│   └── Items[] ← Moléculas
│       └── ItemComponents[] ← Átomos
└── Equipped{} (runtime) ← Slots de equipamento
```

---

## 5. Nodes e Responsabilidades

| Node       | Gerencia                             | NÃO FAZ                           |
| :--------- | :----------------------------------- | :-------------------------------- |
| `Behavior` | Intent, Context                      | Execução de states, stats         |
| `Machine`  | State selection, transition, exec    | Leitura de input, gestão de stats |
| `Backpack` | Inventory, Equipment, Compose switch | Animação, física                  |

### Sinais Emitidos

| Node       | Sinais                                                    |
| :--------- | :-------------------------------------------------------- |
| `Behavior` | `context_changed`, `effect_applied`, `stat_changed`       |
| `Machine`  | `state_changed`, `state_entered`, `cooldown_started`      |
| `Backpack` | `item_equipped`, `compose_switched`, `item_added/removed` |

---

## 6. Servers vs Nodes

| Situação                 | Node                      | Server                              |
| :----------------------- | :------------------------ | :---------------------------------- |
| Componente persistente   | ✅ Sempre                  | ❌                                   |
| Hitbox efêmera (1 frame) | ❌                         | ✅ `PhysicsServer.intersect_shape()` |
| Animação                 | ✅ AnimationTree           | ❌ Não tem equivalente               |
| Áudio one-shot           | Pool de AudioStreamPlayer | Ou AudioServer para mix             |
| Colisão do personagem    | ✅ CollisionShape          | ❌                                   |

---

## 7. Estrutura de Pastas

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

---

_BehaviorStates — Architecture v1.0_
