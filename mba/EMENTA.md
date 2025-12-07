# Ementa do Curso: Godot MBA (Master Business Architecture)

> **Instrutor:** Machi
> **Foco:** Engenharia de Jogos, Arquitetura de Software e Godot Engine.

---

## 🏛️ Fase 1: Fundamentos (The Foundation)

_Objetivo: Nivelamento em Ciência da Computação aplicada._

### Módulo 0: O Mindset do Engenheiro
- Diferença entre Hobbyist vs Engineer.
- Análise de Requisitos antes do código.
- Setup Profissional (Git, Linter, CI/CD).

### Módulo 1: Lógica e Algoritmos Reais
- Estruturas de Dados: `Array` vs `Dictionary` vs `PackedArray`.
- Complexidade De Tempo: O(1) vs O(N).
- Gerenciamento de Memória em GDScript (`ref_counted`).

### Módulo 2: POO e Design Patterns
- Herança vs Composição.
- SOLID Principles na Godot.
- Padrões: Singleton, Observer, Command, Strategy.

---

## ⚙️ Fase 2: Anatomia da Godot (The Engine)

_Objetivo: Dominar a ferramenta por dentro._

### Módulo 4: SceneTree & Lifecycle
- `_init` vs `_enter_tree` vs `_ready`.
- Processamento de Física (`_physics_process`) e Delta Time.
- Árvore de Nós e Propagação de Sinais.

### Módulo 5: Nodes como Agentes
- Responsabilidade Única.
- Encapsulamento de Componentes.
- Comunicação segura (Signal Up, Call Down).

### Módulo 6: ROP (Resource-Oriented Programming)
- **Conceito Chave:** Dados como Comportamento.
- Criação de Custom Resources.
- Injeção de Dependência via Inspector.

---

## 🏗️ Fase 3: Arquitetura de Sistemas (State Engineering)

_Objetivo: Implementar o Core do Framework Machi (Plugin)._

### Módulo 8: Máquinas de Estado Híbridas (Node + Resource)
- **BehaviorMachine:** A evolução da FSM.
- Desacoplamento total entre Lógica (Machine) e Dados (State).
- Implementação de `BehaviorStates` (Enums Globais).

### Módulo 9: Algoritmos de Busca e Decisão
- **HashMap O(1):** Indexação invertida para alta performance.
- **Score System:** Lógica de decisão fuzzy para IA e Player.
- Implementação do `Compose.gd` (`@tool`).

### Módulo 10: Componentes de Gameplay
- **CharacterSheet:** Sistema de Atributos e Stats.
- **Inventory & Itens:** Troca de contexto em tempo real.
- **Buffs & Effects:** Modificadores temporários injetados.

---

## 📦 Fase 4: Sistemas de Produção

_Objetivo: Ferramentas e Polimento._

### Módulo 11: Inventários Complexos
- ItemData vs ItemInstance.
- Save/Load System (Serialização de Resources).
- Persistência de Dados.

### Módulo 12: UI Escalável (MVC)
- Separação Model-View-Controller.
- Themes e Estilização Global.
- Debug Overlay Responsivo.

### Módulo 13: Game Feel & "Juice"
- AnimationPlayer vs Tweens.
- Hitstop, Screenshake e Feedback Visual.
- Sistema de Áudio Dinâmico (AudioServer e Bus Layout).

---

## 🚀 Fase 5: Otimização e Release

### Módulo 14: Profiling & Debugging
- Uso do Profiler e Monitores.
- Detecção de Gargalos (GPU vs CPU).
- Leitura de Logs e Stack Traces.

### Módulo 15: GDExtension (Teórico/Intro)
- Quando descer para C++/Rust.
- Integração de bibliotecas externas.
