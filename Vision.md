# BehaviorStates — Visão

> **Framework de Comportamento Next-Gen para Godot 4.x**
>
> Um sistema de estados orientado a dados que rivaliza com o Gameplay Ability System (GAS) da Unreal.

---

## Filosofia: "Query, Don't Transition"

Em uma FSM tradicional, você define **Transições**:

> _"Se estou andando e aperto Shift, vou para Correr."_

No BehaviorStates, você define **Requisitos**:

> _"O estado Correr requer que o input 'Run' esteja ativo."_

A **Machine** olha para o Contexto atual e faz uma "Query" no `Compose` para encontrar o **Best Match** — sem nenhum `if/else` no código.

---

## Princípios Fundamentais

### 🔬 Princípio Atômico

Na física, "átomo" significava indivisível — até descobrirem quarks.

**500 Resources pequenos > 1 Resource com 500 props.**

Cada Component faz UMA coisa. MovementComponent move. HitboxComponent atinge. AudioComponent toca som.

### 🔧 Princípio Nativo

Usar funcionalidades **NATIVAS da Godot** — Servers e Nodes. Não reinventar.

- AnimationTree já existe e é otimizado
- CharacterBody já existe e é otimizado
- PhysicsServer já faz queries eficientes

O framework **integra**, não **substitui**.

### 🔗 Princípio Unificado

Um único sistema de **Components** que funciona tanto em **runtime** quanto no **editor visual**.

- Zero duplicação
- Zero glue code
- Um arquivo = runtime + editor

---

## O que NÃO fazemos

| ❌ Anti-pattern                 | ✅ BehaviorStates               |
| :----------------------------- | :----------------------------- |
| Custom CharacterBody           | Usamos o nativo                |
| Substituir AnimationTree       | Integramos com ele             |
| Reimplementar física           | Delegamos para CharacterBody   |
| Duplicar código editor/runtime | Um Component serve os dois     |
| States conhecem outros States  | States declaram requisitos, só |

---

## Comparativo

| Métrica               | FSM Tradicional | BehaviorStates            |
| :-------------------- | :-------------- | :------------------------ |
| **Transições**        | Hardcoded       | Automáticas via Query     |
| **Acoplamento**       | Estado→Estado   | Estado→Contexto           |
| **Escala**            | O(N²) conexões  | O(N) estados isolados     |
| **Designer-friendly** | ❌ Código        | ✅ Arquivos .tres          |
| **Hot-Swap**          | Difícil         | Trocar Compose em runtime |

---

## Documentação Relacionada

| Documento                         | Conteúdo                          |
| :-------------------------------- | :-------------------------------- |
| [README.md](README.md)            | Quickstart e visão geral          |
| [API Reference](API_REFERENCE.md) | Contratos formais da API          |
| [Architecture](Architecture.md)   | Diagramas e fluxos de comunicação |
| [Internals](Internals.md)         | Código de implementação detalhado |
| [GEMINI.md](GEMINI.md)            | Contexto para Agentes de IA       |

---

_BehaviorStates — Comportamento é Dado._
