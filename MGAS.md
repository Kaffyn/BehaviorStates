# MGAS — Machi Gameplay Ability System

> **Status:** Draft / Specification
> **Target:** Godot 4.x + GDExtension (C++)
> **Inspiration:** Unreal Engine Gameplay Ability System (GAS)

---

## 1. O Manifesto

O **BehaviorStates** (v1) provou que uma arquitetura orientada a dados é superior a Máquinas de Estado Finitas (FSM) tradicionais. Conseguimos desacoplar lógica (`Components`) de dados (`Resources`).

No entanto, para atingir o nível de engenharia de jogos **AAA** — com suporte robusto a **Multiplayer (Replication/Prediction)**, performance para **Milhares de Entidades** e complexidade de RPGs profundos — precisamos descer ao metal.

**MGAS** é a evolução do framework. Uma reimplementação do core em **C++ (GDExtension)**, trazendo a arquitetura de batalha testada do _Unreal GAS_ para a elegância e simplicidade da Godot.

---

## 2. A Trindade do MGAS

Todo o sistema gira em torno de três pilares fundamentais que interagem no `AbilitySystemComponent`.

### 2.1. Gameplay Tags (O Sistema Nervoso)

Substitui o antigo "Context Dictionary" e Enums soltos.

- **Definição:** Identificadores hierárquicos do tipo `State.Debuff.Stun` ou `Weapon.Sword`.
- **Performance:** Mapeados para Hash/Inteiros em C++. Comparações são O(1).
- **Semântica:** Uma Tag diz O QUE o objeto é ou ESTÁ.
- **Query:** "Tenho a tag `Status.Dead`?" retorna instantaneamente.

### 2.2. Gameplay Abilities (GA) (O Comportamento)

Substitui e expande o conceito de `State`.

- **Definição:** Uma habilidade encapsulada que pode ser ativada (Active) ou passiva.
- **Ciclo de Vida:**
  - `CanActivate()`: Verifica Tags e Custos.
  - `Activate()`: Inicia a lógica (tocar anim, spawnar projétil).
  - `Commit()`: Gasta Mana/Stamina e aplica Cooldown.
  - `Cancel()` / `End()`: Limpa o estado.
- **Associação:** Uma GA pode ser concedida e removida dinamicamente do personagem.

### 2.3. Gameplay Attributes & Effects (GE) (Os Dados)

Substitui `CharacterSheet`, `Stats` e `Modificadores`.

- **Attributes (`AttributeSet`):** Valores flutuantes (`Health`, `Mana`, `Speed`).
  - Possuem: `BaseValue` (O valor permanente) e `CurrentValue` (O valor temporário após buffs).
- **Gameplay Effects (GE):** A ÚNICA forma de alterar um Atributo.
  - **Instant:** Dano, Cura.
  - **Duration:** Buff de velocidade temporário.
  - **Infinite:** Equipamento passivo.
  - _Cálculos:_ O GE define a matemática (`Add`, `Multiply`, `Override`).

---

## 3. Arquitetura Híbrida: C++ & GDScript

O MGAS segue a filosofia **"Engine em C++, Gameplay em Script"**.

| Camada         | Tecnologia            | Responsabilidade                                                                               | Exemplo                         |
| :------------- | :-------------------- | :--------------------------------------------------------------------------------------------- | :------------------------------ |
| **Foundation** | **C++ (GDExtension)** | Gerenciamento de Tags, replicação de rede, cálculo matemático de atributos, tick de cooldowns. | `MachiASC`, `MachiAttributeSet` |
| **Logic**      | **GDScript**          | Implementação específica de habilidades. O que acontece quando solta a bola de fogo?           | `FireballAbility.gd`            |
| **Data**       | **Resources (.tres)** | Configuração. Quanto de dano dá? Qual ícone? Quais tags aplica?                                | `fireball_data.tres`            |

---

## 4. Mapa de Migração (BehaviorStates v1 → MGAS v2)

Estamos elevando o nível da abstração.

| Conceito Antigo (v1)             | Conceito MGAS (v2)                      | Mudança Fundamental                                                                                       |
| :------------------------------- | :-------------------------------------- | :-------------------------------------------------------------------------------------------------------- |
| **Nodes** `Behavior` + `Machine` | **Node** `AbilitySystemComponent` (ASC) | Centralização total da lógica de estado e dados.                                                         |
| **Resource** `State`             | **Resource** `GameplayAbility` (GA)     | GA é mais flexível: pode ser um ataque, mas também um passivo, um item consumível ou uma interação de UI. |
| **Resource** `Effect`            | **Resource** `GameplayEffect` (GE)      | GE é puramente dados de mutação de atributos. Efeitos visuais viram `GameplayCues`.                      |
| **Resource** `CharacterSheet`    | **Class** `AttributeSet`                | Atributos agora são definidos em C++ para máxima performance em acesso e replicação.                     |
| **Signal** `context_changed`     | **Event** `TagChanged`                  | Eventos baseados em Tags granulares ao invés de strings genéricas.                                       |

---

## 5. Vantagens do MGAS na Godot

### 🚀 Performance (Tick Rate)

Em GDScript, iterar sobre 50 modificadores (buffs) a cada frame para recalcular o Attack Power de 200 inimigos mataria o FPS.
Em C++, com o MGAS, isso é feito com **Dirty Flags** e memória contígua. O recálculo só ocorre quando um GE muda.

### 🌐 Multiplayer (Replication)

O grande calcanhar de aquiles de frameworks GDScript puros. O MGAS virá com suporte nativo para:

- **Prediction:** O cliente executa a habilidade imediatamente; o servidor confirma ou corrige (Rollback).
- **Variable Replication:** Atributos (`Health`) sincronizam automaticamente via `MultiplayerSynchronizer` otimizado.

### 🧩 Modularidade (Loose Coupling)

Um `GameplayEffect` de "Dano de Fogo" não precisa saber QUAIS personagens existem. Ele apenas diz: "Aplique -10 de Health e adicione a Tag `Debuff.Burn`". Se o alvo tiver um `AttributeSet` com Health, funciona. Se não, é ignorado.

---

## 6. Fluxo de Trabalho (Workflow)

1. **Setup:** Adicione o node `AbilitySystemComponent` ao seu `CharacterBody`.
2. **Define:** Crie seus Atributos em C++ (`MyGameAttributeSet`).
3. **Design:** Crie Resources (`.tres`) para suas Habilidades (`Skill_Bash`) e Efeitos (`Effect_Damage`).
4. **Script:** Implemente a lógica visual da `Skill_Bash.gd` (tocar animação, spawnar area).
5. **Tag:** Adicione Tags aos seus recursos (`Ability.Melee`, `Cooldown.Bash`).
6. **Play:** O MGAS cuida do cooldown, custo de mana, aplicação de dano e replicação.

---

_MGAS — Engenharia de Elite para a Godot Engine._
