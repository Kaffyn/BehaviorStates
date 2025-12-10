# Architecture — BehaviorStates

> **Filosofia:** "Query, Don't Transition"

## 1. Visão Geral

O BehaviorStates substitui a Máquina de Estados Finita (FSM) tradicional por um sistema de **Seleção de Comportamento Baseada em Pontuação**.

Em vez de:
`Idle -> (Press Jump) -> Jump`

Nós declaramos:
`Jump State` requer `Input: Jump` e `Physics: Ground`.

A cada frame, o sistema pergunta: "Qual o melhor estado para o contexto atual?".

## 2. Fluxo de Dados

1. **Input:** O jogador aperta botões.
2. **Behavior:** Traduz botões para **Intenção** e atualiza o **Contexto** (`Input.Jump = Pressed`).
3. **Machine:**
   - Consulta o **Compose** (Deck de Estados).
   - Usa **HashMaps** para achar candidatos válidos O(1).
   - Calcula **Score** de cada candidato (Prioridade + Especificidade).
   - Seleciona o Vencedor.
4. **State:** Executa lógica visual e física.

## 3. Nodes Principais

- **Behavior:** O Cérebro. Guarda dados (Stats, Skills, Contexto).
- **Machine:** O Motor. Executa o State atual.
- **Backpack:** O Inventário. Troca o `Compose` da Machine quando equipa itens.
