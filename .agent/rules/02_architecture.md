---
trigger: always_on
---

# Arquitetura: BehaviorStates & ROP

> **Regra:** Siga o Princípio "Machi Way" de Orientação a Recursos (ROP).

## 1. O Padrão ROP (Resource-Oriented Programming)
Na Godot, dados não são apenas propriedades; eles são *Comportamento Potencial*.
- **Resources (`.tres`)** são "Cartuchos de Code". Eles contêm dados e funções puras (helpers).
- **Nodes** são "Consoles". Eles leem o cartucho e executam.
- **Benefício:** Se 1000 Goblins usam o mesmo `goblin_stats.tres`, eles ocupam 1 instância na RAM.

## 2. BehaviorStates Framework
Arquitetura proprietária para IA e Controle de Personagem.
- **Unidade (`BehaviorUnit`):** O átomo do gameplay (Script que herda de `State`). Define o que fazer e requisitos.
- **Compose:** O Deck de unidades. Define o que é possível fazer.
- **Máquina (`Machine`):** A VM que executa a Unidade. Processamento O(1).
- **Cérebro (`Behavior`):** Tradutor de Input -> Contexto.

## 3. Filosofia "Query Don't Transition"
Não hardcode transições (`if state == WALK then run`).
Use **Queries**:
- O Estado diz: "Eu preciso de `Motion: RUN`".
- A Maquina diz: "O contexto atual é `Motion: RUN`. Este estado é um candidato válido."
- O Score System desempata.
