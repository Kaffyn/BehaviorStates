# Gameplay Tags — O Sistema Nervoso

> **Propósito:** Explicar a implementação técnica, o sistema de hashing e as queries O(1) das Gameplay Tags.

---

## 1. O Problema das Strings e Enums

Em desenvolvimento de jogos tradicional, estado é gerenciado de forma fragmentada:

- **Booleans:** `is_stunned`, `is_dead`, `has_fire_sword`.
- **Enums:** `State.IDLE`, `State.WALK`.
- **Strings:** `"fire_damage"`, `"ice_resistance"`.

**Problemas:**

1. **Hardcoding:** Adicionar um novo estado requer recompilar ou editar código central.
2. **Performance:** Comparação de strings é lenta (`O(L)`).
3. **Complexidade Combinatória:** E se eu estiver `Stunned` E `Burning`? Enums simples falham. Flags de bits são limitadas (64 bits).

## 2. A Solução MGAS: Hierarchical Gameplay Tags

Uma **Gameplay Tag** é um "Rótulo" hierárquico, como:
`State.Debuff.Stun.Physical`

### 2.1. Representação Interna (C++)

No C++, uma Tag **NÃO É** uma String em tempo de execução.
Durante a inicialização (ou importação), cada tag registrada é convertida para um **Identificador Único (Index ou Hash)**.

```cpp
// Pseudo-implementação C++
struct FGameplayTag {
    uint32_t TagID; // ID único global
    uint32_t ParentID; // ID do pai (State.Debuff)
};
```

Isso significa que comparar `TagA == TagB` é apenas comparar dois inteiros (`uint32`). **Extremamente rápido.**

### 2.2. O GameplayTagContainer

Entidades não possuem uma única tag. Elas possuem um **Container**.
O `AbilitySystemComponent` possui um `FGameplayTagContainer` que armazena todas as tags ativas (vindas de Efeitos, Habilidades, Equipamentos).

Internamente, isso é otimizado usando `TSet` (Hash Set) ou Bit Arrays dinâmicos, permitindo inserção e remoção rápidas.

---

## 3. Consultas (Queries)

O poder real vem das queries hierárquicas.

### 3.1. Exact Match (`HasTagExact`)

"Eu tenho a tag `State.Debuff`?"

- Se eu tiver `State.Debuff.Stun`, a resposta é **FALSE**.
- Só retorna true se eu tiver explicitamente `State.Debuff`.

### 3.2. Any Match (`HasAny`)

"Eu tenho `State.Debuff` OU `State.Dead`?"

- Retorna true se tiver qualquer uma da lista.

### 3.3. Hierarchical Match (`HasTag`)

Esta é a mágica.
"Eu tenho a tag `State.Debuff`?"

- Se eu tiver `State.Debuff.Stun`, a resposta é **TRUE**.
- O sistema entende que "Stun" **É UM** tipo de "Debuff".

Isso permite código desacoplado:

```gdscript
# Código de Input
func _input(event):
    # Não importa se é Stun, Freeze, Sleep ou Petrify.
    # Se for filho de State.Debuff, bloqueia input.
    if asc.has_tag(TAG_State_Debuff):
        return
```

---

## 4. Singleton Gerenciador: `GameplayTagManager`

Todas as Tags válidas devem ser registradas em um arquivo de configuração (`DefaultGameplayTags.ini` ou Project Settings). O `GameplayTagManager` carrega isso no startup.

### Boas Práticas de Nomenclatura

1. **State**: Estados transitórios (`State.Dead`, `State.Casting`).
2. **Input**: Ações do jogador (`Input.Action.Fire`, `Input.Axis.Move`).
3. **Damage**: Tipos de dano (`Damage.Type.Fire`, `Damage.Type.Physical`).
4. **Ability**: Identidade de habilidades (`Ability.Skill.Fireball`).
5. **Cooldown**: Trackers de tempo (`Cooldown.Global`, `Cooldown.Item`).

---

## 5. Implementação na Godot (GDScript)

Para facilitar o uso, expomos as tags como `StringNames` ou Object Wrappers constantes autocompletáveis.

```gdscript
# Exemplo de uso no script
const Tags = preload("res://addons/mgas/gameplay_tags.gd")

func _ready():
    # Adiciona tag manualmente (não recomendado, melhor via Effect)
    asc.add_loose_tag(Tags.State_Combat)

func try_attack():
    # Verifica requisitos
    if not asc.has_tag(Tags.State_Debuff):
        asc.try_activate_ability(Tags.Ability_Melee)
```

---

_MGAS — Gameplay Tags v1.0_
