# Attributes & AttributeSets — Os Dados

> **Propósito:** Detalhar a classe `AttributeSet`, matemática de atributos, agregadores e replicação.

---

## 1. AttributeSet (A Classe C++)

Diferente de sistemas onde atributos são dicionários (`{"health": 100}`), no MGAS atributos são propriedades float de uma classe C++. Isso garante que o compilador otimize o acesso de leitura/escrita.

```cpp
// Exemplo de definição de AttributeSet
class MachiAttributeSet : public Resource {
    GDCLASS(MachiAttributeSet, Resource);

public:
    // Macro que define getters, setters e initters
    ATTRIBUTE_ACCESSORS(MachiAttributeSet, Health);
    ATTRIBUTE_ACCESSORS(MachiAttributeSet, MaxHealth);
    ATTRIBUTE_ACCESSORS(MachiAttributeSet, Mana);
    ATTRIBUTE_ACCESSORS(MachiAttributeSet, MoveSpeed);

protected:
    // O dado real (replicado)
    FGameplayAttributeData Health;
    FGameplayAttributeData MaxHealth;
    FGameplayAttributeData Mana;
    FGameplayAttributeData MoveSpeed;
};
```

---

## 2. Base vs. Current Value

Cada `FGameplayAttributeData` armazena dois valores para permitir **cálculos não-destrutivos**.

| Valor             | Conceito                                                                                                | Exemplo         |
| :---------------- | :------------------------------------------------------------------------------------------------------ | :-------------- |
| **Base Value**    | O valor "verdadeiro" ou permanente. Só é alterado por efeitos _Instant_ (Dano) ou _Growth_ (Level Up).  | 100             |
| **Current Value** | O valor efetivo atual, somando todos os buffs/debuffs temporários. Recalculado sempre que um buff muda. | 150 (Buff +50%) |

**Exemplo Prático (MaxHealth):**

1. Base: 100.
2. Aplica Buff "Giant Potion" (+50 Flat).
3. Current vira 150. Base continua 100.
4. Remove Buff.
5. Current volta para 100 instantaneamente.

---

## 3. Clamping e Derived Attributes

Para manter a integridade dos dados (ex: Health nunca passar de MaxHealth), usamos callbacks virtuais no C++ ou GDScript.

### 3.1. PreAttributeChange

Chamado _antes_ de qualquer modificação. Útil para clamping de entrada.

```gdscript
# GDScript Override (se suportado pelo binding)
func _pre_attribute_change(attribute, new_value):
    if attribute == "Health":
        return clamp(new_value, 0, get_max_health())
    return new_value
```

### 3.2. PostGameplayEffectExecute

Chamado _após_ um efeito ser aplicado. Onde a lógica de reação acontece (Morreu? Tomou dano?).

```cpp
// C++ Implementation
void MachiAttributeSet::PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) {
    if (Data.EvaluatedData.Attribute == GetHealthAttribute()) {
        SetHealth(FMath::Clamp(GetHealth(), 0.0f, GetMaxHealth()));

        if (GetHealth() <= 0.0f) {
            // Envia evento "ActorDied" para o ASC
            GetOwningAbilitySystemComponent()->HandleGameplayEvent(TAG_State_Dead, Data);
        }
    }
}
```

---

## 4. Agregadores (A Matemática)

Como múltiplos mods se combinam? O MGAS segue a ordem padrão de RPGs (Additive antes de Multiplicative).

Fórmula Final:
`((BaseValue + AdditiveMods) * MultiplicativeMods) / DivisionMods`

Exemplo:

- Base Damage: 10
- Espada (+5 Add)
- Passive (+100% Mult, ou seja, x2.0)

**Cálculo:** `(10 + 5) * 2.0 = 30`.

_Nota: Se fosse na ordem errada, seria `(10 _ 2) + 5 = 25`. A ordem importa.\*

---

## 5. Replicação

Atributos usam um sistema especial de replicação via `MultiplayerSynchronizer` otimizado para enviar apenas deltas.

O Cliente deve tratar atributos como **Read-Only** na maior parte do tempo. Se o cliente tentar `health = 0` localmente, o servidor vai sobrescrever no próximo tick. Para mudar HP, o cliente deve enviar um RPC pedindo para ativar uma Ability ou Effect.

---

_MGAS — Attributes & AttributeSets v1.0_
