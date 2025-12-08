# BehaviorStates: A Next-Gen Behavior Architecture for Godot

> **Visão:** Prover um Framework de Comportamento nível AAA, orientado a dados, que rivalize com os padrões da indústria (como o GAS da Unreal), permitindo que Designers e Programadores construam sistemas reativos complexos sem acoplamento de código.
>
> **Filosofia:** "Query, Don't Transition". Em vez de hardcodar transições, o sistema avalia o **Contexto** atual e escolhe o melhor **State** para aquele momento via Indexação O(1).

---

## 🏛️ Os Pilares da Arquitetura

O sistema inverte a lógica tradicional de State Machines. Em vez de hardcodar transições, usamos **Query de Dados**.

| Pilar         | Componente        | Descrição                                                                           |
| :------------ | :---------------- | :---------------------------------------------------------------------------------- |
| **O Cérebro** | `Behavior` (Node) | O orquestrador de intenção. Faz a ponte entre o Input Bruto e o Contexto Semântico. |
| **A Engine**  | `Machine` (Node)  | O Executor e Interpretador. Processa decisões O(1) e executa o gameplay.            |
| **O DNA**     | Resources         | Comportamento é Dado. Mutável, trocável e extensível sem recompilação.              |
| **A Bancada** | Editor Panel      | Uma IDE totalmente integrada dentro da Godot. Visual, intuitiva e livre de código.  |

---

## 🌟 Filosofia: "Query, Don't Transition"

Em uma FSM tradicional, você define **Transições**:

> _"Se estou andando e aperto Shift, vou para Correr."_

No BehaviorStates, você define **Requisitos**:

> _"O estado Correr requer que o input 'Run' esteja ativo."_

A **Machine** olha para o Contexto atual (Inputs, Física, Status, Arma, Item) e faz uma "Query" no `Compose` disponível para encontrar o **Best Match**.

### Vantagens

- **Desacoplamento Total:** Estados não sabem da existência uns dos outros.
- **Escalabilidade:** Adicione 50 ataques novos apenas criando arquivos `.tres`.
- **Hot-Swapping:** Troque o "Deck" de habilidades (ex: trocar de arma) em tempo real.
- **Performance O(1):** Indexação invertida garante custo fixo de busca.

---

## 🚀 O Roadmap para o Nativo

1. **Fase 1 (GDScript Plugin):** Prototipagem rápida e adoção pela comunidade. Foco na DX e estabilidade da API.
2. **Fase 2 (Rust GDExtension):** Core reescrito em Rust para performance bare-metal.
3. **Fase 3 (Godot Native):** Propor como módulo oficial C++.

---

## 1. A Bancada (Editor Panel)

O Painel `BehaviorStates` transforma a Godot em uma **IDE especializada**.

### Abas do Painel

| Aba          | Descrição                                                                              |
| :----------- | :------------------------------------------------------------------------------------- |
| **Library**  | Tree View de todos os Resources. Drag & Drop, Filtro, Menu de Contexto.                |
| **Editor**   | GraphEdit para edição visual. Campos dinâmicos, Blocos Lógicos, Conexões de SkillTree. |
| **Factory**  | Wizard para criar Resources com Presets (Idle, Walk, Attack, Consumable, Weapon).      |
| **Grimório** | Visualizador de Markdown integrado para consultar documentação sem sair da engine.     |

### Blocos do Editor

| Bloco              | Aplicável a | Descrição                                                |
| :----------------- | :---------- | :------------------------------------------------------- |
| `FilterBlock`      | State       | Define requisitos de entrada (Motion, Physics, Weapon).  |
| `ActionBlock`      | State       | Define o que fazer (velocidade, dano, animação).         |
| `TriggerBlock`     | State       | Define reações a eventos (on_hit, on_duration_end).      |
| `RequirementBlock` | Skill       | Define pré-requisitos (Level, Atributos, outras Skills). |
| `UnlockBlock`      | Skill       | Define o que desbloqueia (States, Items, Buffs).         |
| `ModifierBlock`    | Item        | Define modificadores de stats ao equipar.                |
| `PropertyBlock`    | Item        | Define propriedades (Stackable, Durability, Consumable). |

---

## 2. API de Dados (The DNA)

Scripts que estendem `Resource`. São a "Memória" do sistema.

### 2.1. Recursos Estáticos (Blueprints)

| Resource      | Descrição                                                                                           |
| :------------ | :-------------------------------------------------------------------------------------------------- |
| **State**     | Unidade atômica. Visual (SpriteSheet), Combat (Hitbox, Damage Multiplier), Movement, Timing, Hooks. |
| **Compose**   | Aglomera States e cria o Hash Map para lookup O(1). Define o "Moveset" atual.                       |
| **Item**      | Ícone, Stackable, Craft, Consumable, Durability. Pode ter `Compose` próprio e `Effects`.            |
| **Skill**     | Desbloqueia States, Items ou aplica Effects passivos. Pode ser PASSIVE ou ACTIVE.                   |
| **SkillTree** | Grafo de dependência de Skills. Organiza progressão.                                                |
| **Effects**   | Modificadores temporários, instantâneos ou permanentes. Duração, Stat Modifiers, Status Effects.    |
| **Config**    | Configuração global do plugin (game_type, physics_mode, default_compose, input_buffer_time).        |

### 2.2. Recursos Vivos (In-Game Editable)

| Resource           | Descrição                                                                                |
| :----------------- | :--------------------------------------------------------------------------------------- |
| **Inventory**      | Lista de itens instanciados. Nunca edita o blueprint original. Persiste entre sessões.   |
| **CharacterSheet** | Ficha do personagem (Level, XP, Atributos, Stats). Central da verdade. Editável in-game. |

---

## 3. Componentes de Runtime (The Nodes)

| Node         | Descrição                                                                                                   |
| :----------- | :---------------------------------------------------------------------------------------------------------- |
| **Behavior** | Orquestrador. Valida inputs, traduz para Contexto, dono de CharacterSheet/SkillTree/Backpack.               |
| **Machine**  | Engine. Consulta Compose, aplica States, calcula valores finais (Dano = State.multiplier \* Char.strength). |
| **Backpack** | HUD de Inventário. Renderiza slots, gerencia seleção, crafting e exibe Skill Tree.                          |
| **Slot**     | Slot individual do inventário. Ícone, quantidade, drag & drop.                                              |

---

## 4. O Algoritmo (Reverse Query Hash Map)

Rejeitamos iteração O(N). Usamos **Indexação Reversa**:

1. **Index Time (Editor):** O `Compose` organiza estados em buckets por tags primárias.
2. **Query Time (Runtime):** A `Machine` constrói uma chave a partir do Contexto.
3. **Lookup O(1):** Recupera lista pré-filtrada de candidatos.
4. **Fuzzy Scoring:** Ranqueia por especificidade (Match Exato +10, Genérico +0, Chain +20).

---

## 5. Referência Técnica (Vocabulário Global)

Definido em `BehaviorStates.gd` (Autoload). Verdade única para tipos.

| Categoria    | Valores                             | Descrição                     |
| :----------- | :---------------------------------- | :---------------------------- |
| **Motion**   | `IDLE`, `WALK`, `RUN`, `DASH`       | Estados de locomoção          |
| **Physics**  | `GROUND`, `AIR`, `WATER`            | Estado físico no mundo        |
| **Attack**   | `NONE`, `FAST`, `NORMAL`, `CHARGED` | Intenção de combate           |
| **Weapon**   | `KATANA`, `BOW`, `NONE`             | Tipo de equipamento ativo     |
| **Reaction** | `CANCEL`, `ADAPT`, `FINISH`         | Reação a mudanças de contexto |
| **Status**   | `NORMAL`, `STUNNED`, `DEAD`         | Condições de status           |

---

> _BehaviorStates Framework - Documentação Técnica Unificada._
