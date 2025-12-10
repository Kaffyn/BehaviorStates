# API Reference — BehaviorStates

## Classes Principais

### State

`extends Resource`

- `entry_requirements: Dictionary`
- `priority_override: int`
- `components: Array[StateComponent]`

### Behavior

`extends Node`

- `set_context(category: String, value: int)`
- `get_context(category: String) -> int`
- `signal context_changed(cat, val)`

### Machine

`extends Node`

- `current_state: State`
- `force_state(state: State)`: Override manual.
- `get_candidate_list()`: Debugging.

### Components

- `MovementComponent`: Move o corpo.
- `AnimationComponent`: Controla AnimationTree.
- `HitboxComponent`: Gera dano.
- `EffectComponent`: Aplica modificadores.

## Enums (BehaviorStates Global)

- `Motion { IDLE, WALK, RUN, JUMP, FALL }`
- `Physics { GROUND, AIR, WATER }`
- `Attack { NONE, LIGHT, HEAVY }`
