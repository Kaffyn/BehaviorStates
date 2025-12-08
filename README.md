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

Scripts que estendem `Node`. Adicionados à cena do personagem para processar comportamento.

### 3.1. `Behavior` (O Orquestrador)

O nó de processamento de intenção. Fica na raiz do personagem.

- **Input Handling:** Processa inputs de alto nível e os traduz para Contexto Semântico.
- **Validação:** Antes de mudar contexto (ex: `Jump` no ar), verifica se há State ou Skill que permita.
- **Dono dos Dados:** Possui referências para `CharacterSheet`, `SkillTree` e `Backpack`.
- **Orquestração:** Coordena o fluxo entre `Machine` e `Backpack`.

**Código Exemplo:**

```gdscript
func _physics_process(delta):
    # Traduz Input para Contexto
    if Input.is_action_pressed("run"):
        set_context("Motion", BehaviorStates.Motion.RUN)

    # Gerencia Gravidade e Movimento Físico
    _handle_physics()
```

**Signals:**

- `context_changed(category, value)`: Emitido quando o contexto muda.

### 3.2. `Machine` (A Engine)

O processador de decisão puro. Não sabe o que é "Player" ou "Input".

- **Query Engine:** Consulta o `Compose` ativo pelo melhor `State` compatível com o Contexto.
- **Scoring:** Aplica o algoritmo de pontuação para desempatar candidatos.
- **Execução:** Aplica física, animação, dano e efeitos conforme o `State` ativo.
- **Cálculo de Valores:** Multiplica valores do `State` (damage_multiplier) pelos Stats do `CharacterSheet`.

**Interpretador (VM):** Funciona como uma Virtual Machine com instruções especializadas:

- `apply_velocity(Vector2)`
- `spawn_projectile(PackedScene)`
- `play_animation(String)`

**Signals:**

- `state_changed(old_state, new_state)`: Emitido quando o estado muda.

### 3.3. `Backpack` (A Interface)

A **Interface de Inventário (HUD)**. Gerencia visualmente o `Inventory`.

- **Renderização:** Exibe os slots do `Inventory` usando componentes `Slot`.
- **Seleção:** Gerencia qual item está selecionado/equipado.
- **Crafting:** Provê interface para receitas de craft.
- **Skill Tree:** Exibe a árvore de skills e permite aprendizado.

**Signals:**

- `item_selected(item)`: Emitido quando um item é selecionado.
- `item_used(item)`: Emitido quando um item é usado (clique direito).

### 3.4. `Slot` (Slot Individual)

Um slot individual do inventário.

- **Renderização:** Exibe ícone e quantidade do item.
- **Input:** Detecta cliques para seleção e uso.
- **Drag & Drop:** Suporta arrastar itens entre slots.

---

## 4. O Algoritmo (Reverse Query Hash Map)

> **Status:** Implementado | **Deep Dive Técnico**

Nós rejeitamos iteração O(N). O sistema usa uma **Estratégia de Indexação Reversa** para garantir seleção em tempo constante (`O(1)`).

### 4.1. Estrutura de Indexação (Index Time)

O script `Compose.gd` roda como `@tool`. Sempre que você salva um recurso `.tres`, ele reconstrói os índices:

```gdscript
# Compose.gd
@export var move_rules : Dictionary = {}   # { Motion.RUN: [RunState, ...], ... }
@export var attack_rules : Dictionary = {} # { Attack.FAST: [Slash1, ...], ... }
```

Cada estado define sua chave de indexação via `get_lookup_key()`.

- **Exceções:** Filtros negativos (ex: `EXCEPT_DASH`) são indexados no bucket genérico (`ANY`) para serem testados sempre.

### 4.2. O Fluxo de Query (Runtime)

Quando a Machine precisa decidir o próximo frame:

1. **Chaveamento:** A Machine constrói uma chave a partir do Contexto atual (ex: `Motion.RUN`).
2. **Lookup Direto (O(1)):**

   ```gdscript
   # Machine.gd
   var candidates = current_compose.move_rules.get(current_motion_context, [])
   # Adiciona candidatos genéricos (ANY)
   candidates.append_array(current_compose.move_rules.get(0, []))
   ```

3. **Resultado:** Em vez de iterar 500 estados, iteramos apenas os 2 ou 3 que fazem sentido naquele microssegundo.

### 4.3. Fuzzy Scoring (Desempate)

Com a lista de candidatos reduzida, aplicamos um sistema de pontuação para escolher o vencedor:

1. **Filtro Rígido:** Requisitos booleanos (ex: `Physics: GROUND`) eliminam candidatos incompatíveis imediatamente.
2. **Pontuação de Especificidade:**
   - Match Exato de Atributo (ex: `Weapon: KATANA` quando equipada): **+10 Pontos**.
   - Match Genérico (`Weapon: ANY`): **+0 Pontos**.
   - Prioridade de Chain (Combo): **+20 Pontos**.
   - `priority_override` do State: **+100 \* valor**.

Isso garante que um "Ataque Genérico" seja substituído automaticamente por uma "Cutilada de Katana" quando a arma é equipada, sem nenhum `if/else` no código.

---

## 5. Referência Técnica (Vocabulário Global)

Definido em `BehaviorStates.gd` (Autoload). Serve como a "Verdade Única" para tipos no projeto inteiro.

| Categoria    | Valores                             | Descrição                                  |
| :----------- | :---------------------------------- | :----------------------------------------- |
| **Motion**   | `IDLE`, `WALK`, `RUN`, `DASH`       | Estados de locomoção terrestre             |
| **Physics**  | `GROUND`, `AIR`, `WATER`            | Estado físico do corpo no mundo            |
| **Attack**   | `NONE`, `FAST`, `NORMAL`, `CHARGED` | Intenção de combate                        |
| **Weapon**   | `KATANA`, `BOW`, `NONE`             | Tipo de equipamento ativo                  |
| **Reaction** | `CANCEL`, `ADAPT`, `FINISH`         | Como reagir a mudanças bruscas de contexto |
| **Status**   | `NORMAL`, `STUNNED`, `DEAD`         | Condições de status do personagem          |

---

> _BehaviorStates Framework - Documentação Técnica Unificada._
