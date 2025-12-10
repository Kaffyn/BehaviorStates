# Ramo de Estados (State Branch)

> **Resources:** `State`, `StateComponent` > **Foco:** Definição Micro do Personagem ("Como eu faço isso?").

---

## 1. State (`StateResource`)

O átomo do sistema. Representa uma ação única e contínua.

### Campos Essenciais:

- **Requirements:** `Warning: Dictionary`. Chaves são Categorias de Contexto, Valores são os Enums exigidos.
  - `{ "Motion": RUN, "Weapon": SWORD }`
- **Priority:** `int`. Se dois estados tiverem os mesmos requisitos, o de maior prioridade ganha.
- **Phases:** (Opcional) Define duração fixa, loop, ou wait-for-animation.
- **Flags:** `IsSticky` (Não pode ser interrompido), `IsInstant` (Roda um frame e sai).

## 2. State Components (A Lógica Real)

Nós evitamos colocar código GDScript direto no Resource `State` para não criar dependências cíclicas. Usamos Components.

### Arquitetura de Componentes

1. **Movement:** Aplica `velocity` e chama `move_and_slide()`.
   - _Tipos:_ `WalkMovement`, `JumpImpulse`, `DashMovement`.
2. **Animation:** Gerencia o `AnimationPlayer` ou `AnimationTree`.
   - _Tipos:_ `SimplePlay`, `BlendTreeParameter`.
3. **VFX/SFX:** Toca sons ou partículas.
   - `FootstepSound`, `SlashTrail`.
4. **GameLogic:** Interage com HP, Inventário, etc.
   - `DrainStamina`, `ApplyDamageArea`.

### O Ciclo de Vida:

```gdscript
func enter(context):
    for c in components: c.on_enter()

func process(delta):
    for c in components: c.on_process(delta)

func exit():
    for c in components: c.on_exit()
```

## 3. Vantagem da Composição

Você pode criar um estado "Pulo com Fogo" apenas duplicando o recurso "Pulo Normal" e arrastando um `EffectComponent` de Fogo para a lista. Zero código.
