# Gameplay Effects (GE) — O Motor de Mutação

> **Propósito:** Definir o Resource `GameplayEffect`, suas regras de aplicação, duração, stacking e tags.

---

## 1. O Recurso `GameplayEffect`

No MGAS, `Ability` é o verbo (fazer), `Attribute` é o sujeito (quem), e `GameplayEffect` é a mudança de estado. Um GE é puramente dados (Data-Asset).

```bash
# Exemplo de Resource (.tres)
Id: "GE_Poison"
DurationPolicy: HasDuration
Duration: 5.0
Period: 1.0 # Tique a cada 1s (DoT)

Modifiers:
  - Attribute: Health
    Operation: Add # (Add negativo = subtrair)
    Value: -10.0
GrantedTags:
  - State.Debuff.Poison
```

---

## 2. Duração e Periodicidade

### 2.1. Políticas de Duração

1. **Instant:** Aplicado e esquecido imediatamente.
   - _Uso:_ Dano direto, Cura direta, ganho de Mana.
   - _Nota:_ Não cria um `ActiveGameplayEffect` na lista, apenas muda o atributo BaseValue.
2. **Infinite:** Dura para sempre, até ser removido manualmente.
   - _Uso:_ Atributos de equipamentos (Espada dá +10 STR), Auras passivas.
3. **HasDuration:** Dura X segundos.
   - _Uso:_ Buffs, Debuffs, Stuns temporários.

### 2.2. Periodic Effects (DoT/HoT)

Se `Period > 0`, o efeito aplica seus modificadores repetidamente a cada intervalo.

- Exemplo: Veneno (Duração 10s, Periodo 1s) = Aplica o dano 10 vezes.

---

## 3. Stacking Rules (Empilhamento)

O que acontece se eu tomar 2 poções de força iguais?

| Stacking Type           | Comportamento                                                  | Exemplo                                   |
| :---------------------- | :------------------------------------------------------------- | :---------------------------------------- |
| **None**                | Aplica os dois independentemente. (Força +10, Força +10 = +20) | Buffs genéricos.                          |
| **Aggregate by Target** | Limita X instâncias por Alvo.                                  | "Máximo 3 stacks de sangramento".         |
| **Aggregate by Source** | Limita X instâncias por Caster.                                | "Cada Mago pode manter 1 escudo no Tank". |

### 3.1. Policies de Overflow

Se atingir o limite de stacks, o que fazer com o novo?

- **Refresh Duration:** Renova o tempo de todos os stacks.
- **Discard:** Ignora o novo.
- **Overwrite:** Remove o mais antigo e aplica o novo.

---

## 4. Tags em Efeitos

GEs são os principais transportadores de Tags.

### 4.1. Granted Tags

"Enquanto este efeito estiver ativo, o dono ganha esta Tag."

- Ex: GE_Stun concede `State.Debuff.Stun`.
- Consequência: Outras skills param de funcionar se tiverem `BlockedBy: Stun`.

### 4.2. Application Tag Requirements

"Este efeito só pega se o alvo tiver a tag X."

- Ex: "Dano Bônus de Gelo" só aplica se alvo tiver `State.Debuff.Frozen`.

### 4.3. Remove Gameplay Effects With Tag

"Ao aplicar este efeito, remova outros efeitos que tenham a tag Y."

- Ex: `GE_Cleanse` remove tudo com tag `State.Debuff`.
- Ex: `GE_Fire` remove `State.Debuff.Frozen` (derrete o gelo).

---

## 5. Execution Calculations (Cálculos Avançados)

Para fórmulas complexas (Dano baseado em Distância, HP perdidx, etc.), usamos `ExecutionCalculations` (ExecCalc).

São classes C++ (ou GDScript) que rodam no momento da aplicação do GE. Capturam atributos de **Source** (Atacante) e **Target** (Vítima).

```cpp
// Pseudo-code ExecCalc Damage
float BaseDamage = Source.AttackPower;
float Armor = Target.Armor;
float Mitigation = Armor / (Armor + 100);
float FinalDamage = BaseDamage * (1.0 - Mitigation);

OutExecutionOutput.AddOutputModifier(Attribute.Health, Add, -FinalDamage);
```

---

_MGAS — Gameplay Effects v1.0_
