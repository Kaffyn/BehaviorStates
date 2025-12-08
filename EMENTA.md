# BehaviorStates: Uma Arquitetura de Comportamento Next-Gen para Godot

> **Visão:** Prover um Framework de Comportamento nível AAA, orientado a dados, que rivalize com os padrões da indústria (como o GAS da Unreal), permitindo que Designers e Programadores construam sistemas reativos complexos sem acoplamento de código.

## Os Pilares da Arquitetura

O sistema é construído sobre quatro pilares customizados, orquestrando uma separação de responsabilidades que garante escalabilidade.

- **O Cérebro (Behavior Node):** O orquestrador de intenção. Faz a ponte entre o Input Bruto e o Contexto Semântico.
- **A Engine (Machine Node):** O Executor e Interpretador. Além de um processador de decisão O(1), ela atua como uma **Virtual Machine**: lê os dados do Resource e executa funções especializadas (`apply_jump`, `apply_damage`) para materializar o gameplay.
- **O DNA (Resources):** Comportamento é Dado. Mutável, trocável e extensível sem recompilação.
- **A Bancada (Editor Tooling):** Uma IDE totalmente integrada dentro da Godot. Visual, intuitiva e livre de código para criação de conteúdo.

## 🚀 O Roadmap para o Nativo (Vision)

1. **Fase 1 (GDScript Plugin):** Prototipagem rápida e adoção pela comunidade. O foco é a DX (Developer Experience) e a estabilidade da API.
2. **Fase 2 (Rust GDExtension):** Reescrever o _Core_ (Machine e Algoritmos de Busca) em Rust para performance de nível bare-metal, mantendo a API GDScript idêntica.
3. **Fase 3 (Godot Native):** Propor o framework como um módulo oficial da engine (C++), preenchendo a lacuna histórica de uma State Machine visual nativa na Godot.

## 1. A Bancada (Integrated Workspace)

O Painel `BehaviorStates` transforma a Godot em uma IDE especializada.

- **Biblioteca (Library):**
  - Visão em Grid agrupada por contexto (Systems, Composes, Folders).
  - Drag & Drop nativo para o Inspector.
  - Filtro de busca instantâneo para centenas de assets.
- **Editor (Blueprint):**
  - Um inspetor especializado para edição de Recursos de Comportamento.
  - Interface limpa focada em Regras de Negócio e não em propriedades brutas da Godot.
- **Factory:**
  - Um wizard baseado em templates para criar novos `States`, `Composes` ou `Skills`.
  - Garante consistência de nomenclatura e estrutura de pastas automaticamente.
- **Grimório (Documentation):**
  - Viewer de documentação Markdown integrado à engine.
  - Permite consultar a API e o Design Doc sem Alt-Tab.

## 2. O DNA (Hiper-Resources)

Scripts que estendem `Resource`, funcionando como micro-serviços de comportamento autocontidos.

### Recursos Estáticos (Blueprints)

- **State.gd:** Visual, Animação e Lógica de Movimento/Combate. Aceita multiplicadores de dano e define Hitboxes.
- **Compose.gd:** Aglomera States e cria o Hash Map de lookup para a Machine.
- **Item/Weapon:** Define ícone, stacks, crafting, e pode conter um `Compose` (Moveset) próprio e `Effects`.
- **Skills:** Habilidades que desbloqueiam mecânicas, itens ou aplicam efeitos passivos no `CharacterSheet`.
- **SkillTree:** Grafo de dependência para desbloqueio de skills.
- **Effects:** Modificadores temporários ou instantâneos (Duração, Buffs/Debuffs).

### Recursos Vivos (In-Game Editable)

- **Inventory.gd:** Armazena referências aos itens e edita seus dados dinâmicos (durabilidade, quantidade) sem tocar no Blueprint original.
- **CharacterSheet.gd:** A ficha do personagem (Level, XP, Atributos). Central de verdade editável in-game.

## 3. Os Nodes (Componentes de Runtime)

- **Behavior.gd (O Orquestrador):**

  - Gerencia "O que o Player QUER fazer".
  - Valida inputs contra States e Skills desbloqueados (ex: "Posso pular no ar?").
  - Dono dos dados vivos (`CharacterSheet`, `Inventory`).

- **Machine.gd (A Engine):**

  - Gerencia "Como fazer".
  - Aplica States baseados nos Composes ativos.
  - Calcula valores finais de combate (Dano do State \* Stats do Personagem).

- **Backpack (A Interface):**
  - HUD que gerencia visualmente o Inventário.
  - Exibe Itens, Árvore de Skills e Estatísticas.
  - Provê funcionalidade de Crafting.

## 4. O Algoritmo (Reverse Query Hash Map)

Nós rejeitamos iteração O(N). O sistema usa uma **Estratégia de Indexação Reversa**:

1. **Index Time (Editor):** O `Manifest` organiza estados em buckets por suas tags primárias.
2. **Query Time (Runtime):** A `Machine` constrói uma chave a partir do Contexto atual.
3. **Lookup:** A Machine recupera uma lista pré-filtrada de candidatos em O(1).
4. **Fuzzy Scoring:** Candidatos são ranqueados por pontuação de especificidade (Match Exato > Match Parcial > Match Genérico).

---

_Gerado para a Arquitetura do Framework "BehaviorStates"._

O Framework deve ser construído usando:

- **EditorPlugin:** A classe principal que registra os nós customizados, o painel inferior e os plugins de inspetor.
- **Custom Nodes:** Nós lógicos (`Behavior`, `Machine`, `Inventory`) que o usuário adiciona à cena para processar comportamento.
- **Custom Resources:** A base de dados do sistema (`State`, `Item`, `Skill`), permitindo edição visual e reutilização.
- **Custom Panel Bottom (`BehaviorStates`):** Uma interface IDE-like integrada ao editor da Godot (`add_control_to_bottom_panel`).

  - **Asset Library:** Gerenciador de arquivos `.tres` com filtros e busca.

- Suporta "Duck Typing" para misturar comportamentos (Um estado pode ser `Move` e `Attack` ao mesmo tempo).
- **Compose.gd** (O Deck de Estados / Indexer):

  - Container que agrupa múltiplos `States` em um único pacote lógico.
  - Responsável apenas por criar o índice (`HashMap`) e entregar candidatos. Não realiza queries ou decisões.
  - Funciona como um "Loadout" que pode ser trocado em tempo real (ex: Trocar de Arma troca o Compose ativo).

- **CharacterSheet.gd** (Ficha de Personagem):

  - Armazena atributos vitais (HP, Stamina, Mana).

> Scripts que estendem `Node` (ou `CharacterBody2D/3D`). São o "Cérebro" e o "Corpo".

- **Behavior.gd** (O Orquestrador de Gameplay e Intenção):

  - **Responsabilidade:** Gerenciar "O que o Player QUER fazer".
  - **Input Handling:** Processa inputs de alto nível (Apertou 'Jump', Segurou 'Attack').
  - **Mapeamento de Contexto:** Traduz Inputs em Contexto para a Machine (ex: `Input.is_action_pressed("run")` -> `Machine.set_context("Motion", RUN)`).
  - **Game Actions:** Gerencia interações que não são estados puros (ex: Interagir com NPC, Abrir Inventário).
  - **Comunicação:** É o "Dono" da `Machine`, do `Inventory` e da `CharacterSheet`.

- **Machine.gd** (A Engine de Estados):

  - **Query Engine:** Solicita ao Compose "Quais estados servem para o contexto X?" e executa o algoritmo de escolha.
  - **Decision Loop (Scoring):** A cada tick, avalia os candidatos e decide o melhor estado.
  - **Transition Manager:** Gerencia a troca física de estados, tocando animações e aplicando efeitos.
  - Não sabe o que é "Input", apenas obedece ao Contexto definido pelo `Behavior`.

- **Inventory.gd** (Gerenciador de Equipamento):

  - Componente lógico que gerencia qual `ItemData` está ativo.
  - Notifica o `Behavior` (que notifica a `Machine`) para trocar o `Compose` ativo.
  - Implementa lógica de "Fallback" (mãos vazias).

- **Hud.gd** (Interface de Debug e Feedback):

  - **Console:** Mostra logs de troca de estado.
  - **Visualizer:** Mostra a árvore de decisão em tempo real.
