# MGAS — API Reference

> **Propósito:** Contrato público das classes C++ expostas ao GDScript.

---

## 1. MachiAbilitySystemComponent (MachiASC)

**Inherits:** `Node`

O orquestrador central. Deve ser filho de um `CharacterBody` (ou qualquer Node que precise de habilidades).

### Properties

| Type                     | Name                | Description                                   |
| :----------------------- | :------------------ | :-------------------------------------------- |
| `MachiAttributeSet`      | `attribute_set`     | O container de atributos (Health, Mana, etc). |
| `Array[GameplayAbility]` | `granted_abilities` | Habilidades iniciais concedidas no `_ready`.  |

### Methods

| Return  | Signature                                                                   | Description                                                |
| :------ | :-------------------------------------------------------------------------- | :--------------------------------------------------------- |
| `bool`  | `try_activate_ability(tag: StringName)`                                     | Tenta ativar habilidade pela tag. Retorna true se iniciou. |
| `bool`  | `try_activate_ability_by_class(ability_class: GDScript)`                    | Tenta ativar pela classe específica.                       |
| `void`  | `cancel_ability(tag: StringName)`                                           | Cancela todas as habilidades ativas com essa tag.          |
| `void`  | `apply_gameplay_effect_to_self(effect: GameplayEffect)`                     | Aplica um GE instantaneamente no dono.                     |
| `void`  | `apply_gameplay_effect_to_target(target: MachiASC, effect: GameplayEffect)` | Aplica GE em outro ASC.                                    |
| `void`  | `remove_gameplay_effect(effect_def: GameplayEffect)`                        | Remove todas instâncias desse tipo de efeito.              |
| `bool`  | `has_tag(tag: StringName)`                                                  | Verifica se possui a Tag (ou filha dela).                  |
| `int`   | `get_tag_count(tag: StringName)`                                            | Quantas instâncias dessa tag eu tenho?                     |
| `float` | `get_attribute_value(name: StringName)`                                     | Retorna o `CurrentValue` do atributo.                      |

### Signals

- `tag_added(tag: StringName)`
- `tag_removed(tag: StringName)`
- `attribute_changed(attribute_name: StringName, new_value: float, delta: float)`
- `ability_activated(ability: GameplayAbility)`
- `ability_ended(ability: GameplayAbility)`
- `effect_applied(effect: GameplayEffect)`

---

## 2. MachiGameplayAbility (MachiGA)

**Inherits:** `Resource`

Base para todas as habilidades.

### Properties (Exported)

| Type                   | Name                      | Description                                      |
| :--------------------- | :------------------------ | :----------------------------------------------- |
| `GameplayTagContainer` | `ability_tags`            | Tags que descrevem esta habilidade.              |
| `GameplayTagContainer` | `cancel_tags`             | Tags que esta habilidade cancela ao iniciar.     |
| `GameplayTagContainer` | `block_tags`              | Tags que esta habilidade bloqueia enquanto roda. |
| `GameplayTagContainer` | `activation_owned_tags`   | Requer que o dono tenha estas tags.              |
| `GameplayTagContainer` | `activation_blocked_tags` | Bloqueia ativação se dono tiver estas tags.      |
| `MachiGameplayEffect`  | `cost_effect`             | GE aplicado no `commit` (gasto de recurso).      |
| `MachiGameplayEffect`  | `cooldown_effect`         | GE aplicado no `commit` (tempo de recarga).      |

### Virtual Methods (Override in GDScript)

| Signature                         | Description                             |
| :-------------------------------- | :-------------------------------------- |
| `_can_activate_ability() -> bool` | Validação customizada. Chame `super()`! |
| `_activate_ability() -> void`     | Onde a lógica começa.                   |
| `_end_ability() -> void`          | Limpeza customizada.                    |

### Helper Methods

| Return     | Signature                            | Description                                       |
| :--------- | :----------------------------------- | :------------------------------------------------ |
| `bool`     | `commit_ability()`                   | Aplica Custo e Cooldown. Retorna false se falhar. |
| `void`     | `end_ability()`                      | Encerra a execução e remove tags de ativação.     |
| `MachiASC` | `get_owning_actor_from_actor_info()` | Retorna o ASC dono desta habilidade.              |

---

## 3. MachiGameplayEffect (MachiGE)

**Inherits:** `Resource`

### Properties (Exported)

| Type                   | Name           | Description                                      |
| :--------------------- | :------------- | :----------------------------------------------- |
| `float`                | `duration`     | Duração em segundos (0 = Instant).               |
| `bool`                 | `is_infinite`  | Se true, ignora duration.                        |
| `float`                | `period`       | Intervalo de aplicação (DoT). 0 = Sem repetição. |
| `Array[Modifier]`      | `modifiers`    | Lista de alterações em atributos.                |
| `GameplayTagContainer` | `granted_tags` | Tags concedidas enquanto ativo.                  |

---

_MGAS — API Reference v1.0_
