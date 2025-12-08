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

- **State.gd (BehaviorUnit):** O átomo do gameplay.
  - **Filtros Context-Aware:** Definindo _requisitos de entrada_ via sistema de tags flexível, não Enums hardcoded.
  - **Ganchos de Ciclo de Vida:** `Enter`, `Exit`, `Update`, `PhysicsUpdate`.
  - **Injeção de Dependência:** Estados declaram o que precisam (ex: "Preciso de um `MovementComponent`"), e a Engine provê.
  - **Composição sobre Herança:** Suporta "Traits" modulares (ex: um Estado pode ter uma `CooldownTrait` e uma `StaminaCostTrait`).
- **Compose.gd (BehaviorManifest):** O indexador de contexto.
  - **Herança de Comportamento:** Um Manifesto pode herdar de outro (ex: `SwordManifest` herda de `BaseMeleeManifest`), sobrescrevendo estados específicos.
  - **Arquitetura em Camadas:** Suporta camadas de comportamento paralelas (ex: "Pernas" fazendo `Walk` enquanto "Torso" faz `CastSpell`).
  - **Geração de Hash-Map O(1):** Constrói automaticamente árvores de busca no editor para lookups de latência zero em runtime.
- **ItemData & WeaponData:**
  - Wrappers semânticos que carregam um `BehaviorManifest`. Equipar um item é simplesmente "montar" um novo Manifesto na Engine.
- **SkillTree & Progression:**
  - Um grafo de `Unlockables` que pode injetar dinamicamente novas `BehaviorUnits` no Manifesto ativo do player.

## 3. Os Nodes (Componentes de Runtime)

- **Behavior.gd (A Camada Semântica):**
  - **Tradução de Input:** Converte inputs brutos (`event.is_action("jump")`) em tags semânticas (`Contexto: Pulo = Desejado`).
  - **Gerenciamento de Intenção:** Mantém um buffer de intenção do usuário (Input Buffering / Coyote Time).
  - **Orquestração de Sub-Sistemas:** É dono da `Machine` e do `Inventory`, coordenando o fluxo de dados entre eles.
- **Machine.gd (A Engine e Interpretador):**
  - **Query Engine:** O algoritmo central. Aceita um `ContextSnapshot` e consulta o `BehaviorManifest` ativo pelo melhor `BehaviorUnit` compatível.
  - **Interpretação e Execução:** Funciona como uma VM que lê o "código" (dados) do Resource. Não tem lógica de decisão hardcoded, mas possui uma **Bibleoteca de Ações Especializadas** (`apply_physics_attack`, `apply_jump`, `spawn_projectile`, `apply_acceleration`) que são invocadas conforme o comando do Resource.
  - **Tratamento de Interrupção:** Avalia se um novo candidato tem prioridade maior que o estado rodando.
  - **Event Bus:** Emite eventos de gameplay de alto nível (`on_state_changed`, `on_cast_started`) para sistemas de UI e VFX consumirem desacoplados.
- **Inventory.gd (Gerenciador de Equipamento):**
  - Gerencia a montagem/desmontagem de Manifestos de Item.
  - Lida com "Lógica de Fallback": Reverte suavemente para um Manifesto padrão (ex: Desarmado) quando uma ação de item está indisponível.

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
