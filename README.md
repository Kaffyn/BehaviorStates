# BehaviorStates: A Next-Gen Behavior Architecture for Godot

> **Visão:** Prover um Framework de Comportamento nível AAA, orientado a dados, que rivalize com os padrões da indústria (como o GAS da Unreal), permitindo que Designers e Programadores construam sistemas reativos complexos sem acoplamento de código.
>
> **Filosofia:** "Query, Don't Transition". Em vez de hardcodar transições, o sistema avalia o **Contexto** atual e escolhe o melhor **BehaviorUnit** para aquele momento via Indexação O(1).

---

## 🏛️ Os Pilares da Arquitetura

O sistema inverte a lógica tradicional de State Machines. Em vez de hardcodar transições, usamos **Query de Dados**.

- **O Cérebro (`Behavior.gd`):** O orquestrador de intenção. Faz a ponte entre o Input Bruto e o Contexto Semântico.
- **A Engine (`Machine.gd`):** O Executor e Interpretador (VM). Lê os dados do Resource e executa funções especializadas (`apply_jump`, `spawn_projectile`) para materializar o gameplay.
- **O DNA (`Resources`):** Comportamento é Dado. Mutável, trocável e extensível sem recompilação.
- **A Bancada (`Workbench`):** Uma IDE totalmente integrada dentro da Godot. Visual, intuitiva e livre de código.

---

## 🌟 Filosofia: "Query, Don't Transition"

Em uma FSM tradicional, você define **Transições**:

> _"Se estou andando e aperto Shift, vou para Correr."_

No BehaviorStates, você define **Requisitos**:

> _"O estado Correr requer que o input 'Run' esteja ativo."_

A **Machine** (Cérebro) olha para o Contexto atual (Inputs, Física, Status, Arma, Item) e faz uma "Query" no banco de dados (`Manifest`) disponível para encontrar o **Best Match**.

### Vantagens

- **Desacoplamento Total:** Estados não sabem da existência uns dos outros.
- **Escalabilidade:** Adicione 50 ataques novos apenas criando arquivos `.tres`.
- **Hot-Swapping:** Troque o "Deck" de habilidades (ex: trocar de arma) em tempo real.
- **Performance O(1):** Indexação invertida garante custo fixo de busca.

---

## 🚀 O Roadmap para o Nativo (Vision)

1. **Fase 1 (GDScript Plugin):** Foco do **Módulo 10** do curso. Prototipagem rápida e adoção pela comunidade. O foco é a DX (Developer Experience) e a estabilidade da API.
2. **Fase 2 (Rust GDExtension):** Reescrever o _Core_ (Machine e Algoritmos de Busca) em Rust para performance de nível bare-metal, mantendo a API GDScript idêntica.
3. **Fase 3 (Godot Native):** Propor o framework como um módulo oficial da engine (C++), preenchendo a lacuna histórica de uma State Machine visual nativa na Godot.

---

## 1. A Bancada (Editor Integration)

O Painel `BehaviorStates` transforma o editor em um workspace poderoso, dividido em quatro abas principais:

- **Biblioteca (Library):**

  - Visão em Grid agrupada por contexto (Systems, Composes, Folders).
  - Componentes `AssetCard` visuais com Drag & Drop para o Inspector.
  - Filtro de busca instantâneo e botão de Refresh.
  - Clique direito para editar (no Blueprint) e clique esquerdo para inspecionar.

- **Editor (Blueprint):**

  - O coração do sistema. Permite editar Recursos (`State`, `Item`, etc.) com campos dinâmicos.
  - Substitui o Inspector padrão para edição de lógica de regra.

- **Factory:**

  - Wizard para criação de novos arquivos.
  - Define presets automáticos (ex: um "Attack State" já vem com tags de `Attack: NORMAL`).
  - Cria estrutura de pastas organizada automaticamente (`entities/player/...`).

- **Grimório:**
  - Documentação integrada (Markdown Viewer).
  - Permite ler a wiki do projeto sem sair da engine.

---

## 2. API de Dados (The DNA)

Scripts que estendem `Resource`. São a "Memória" do sistema.

### 2.1. Recursos Estáticos (Blueprints)

#### `State` (Animação e Lógica)

A unidade visual e lógica. Define:

- **Visual:** SpriteSheet, Pivot, Animação (`h_frames`, `v_frames`).
- **Combate:** Hitbox (Area2D), Multiplicador de Dano (O `Machine` multiplica este valor pelo Dano Base do `CharacterSheet` + Bônus de `Skill`).
- **Regras:** Lógica de movimentação (walk, idle, dash attack, hyperdash).

#### `Compose` (O Aglomerador)

Aglomera `States` e monta o **Hash Map** para ser usado pela `Machine`. Define o "Moveset" atual.

#### `Item` / `Weapon`e

- **Identidade:** Ícone, Nome.
- **Propriedades:** Stackable (se aglomera), Craft (receita), Consumível (maçã vs espada).
- **Compose:** Itens podem ter `States` próprios (ex: Espada tem estados de ataque). Se não tiver, usa-se um fallback.
- **Effects:** Pode conter `Effects` (compartilhado com Skills).

#### `Skill`

Habilidades que desbloqueiam mecânicas.

- **Função:** Desbloquear um `State`, um `Item` (craft), ou aplicar `Effects` passivos.
- **Progresso:** Aumentar valores no `CharacterSheet`.

#### `SkillTree`

Similar ao `Compose` e `Inventory`, mas organiza `Skills` em uma estrutura de grafo de dependência.

#### `Effects`

Resource genérico para aplicar modificações temporárias ou instantâneas (Duração, Modificadores de Stats).

### 2.2. Recursos Vivos (In-Game Editable)

Estes recursos são modificados em tempo de execução e salvos no SaveGame.

#### `Inventory`

Armazena a **lista de itens** e seus valores dinâmicos.

- **Conceito Chave:** Nunca edita o `Item` (Resource) original. Ele armazena instâncias ou referências com dados delta (ex: Durabilidade atual, Quantidade).
- **Função:** Resource vivo que persiste entre sessões.

#### `CharacterSheet`

A "Ficha do Personagem".

- **Dados:** Nome, Level, XP, Skills Desbloqueadas.
- **Stats:** Vida, Stamina, Força, etc.
- **Função:** Central de verdade sobre o estado do personagem. Resource vivo.

---

## 3. Componentes de Runtime (The Nodes)

#### `Behavior` (O Orquestrador)

- **Função:** Gerencia e aplica comportamentos com base no `CharacterSheet` e `Inventory`.
- **Validação:** Recebe Inputs e os valida antes de alterar o Contexto (ex: Antes de pular no ar, verifica na skill tree ou states se "Double Jump" está desbloqueado).
- **Dono:** É quem possui as referências para os dados vivos.

#### `Machine` (A Engine)

- **Função:** Gerencia e aplica `States` com base nos `Compose` (fornecidos pelo Item ativo no Inventory) e no `CharacterSheet`.
- **Cálculo:** Aplica os valores finais (Dano do State \* Força do Char).

#### `Backpack` (A Interface)

- **Função:** HUD que gerencia o visual do `Inventory`.
- **Features:** Exibe itens, gerencia Crafting, exibe Estatísticas e a Skill Tree.

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
   var candidates = current_manifest.move_rules.get(current_motion_context, [])
   # Adiciona candidatos genéricos (ANY)
   candidates.append_array(current_manifest.move_rules.get(0, []))
   ```
3. **Resultado:** Em vez de iterar 500 estados, iteramos apenas os 2 ou 3 que fazem sentido naquele microssegundo.

### 4.3. Fuzzy Scoring (Desempate)

Com a lista de candidatos reduzida, aplicamos um sistema de pontuação para escolher o vencedor:

1. **Filtro Rígido:** Requisitos booleanos (ex: `Physics: GROUND`) eliminam candidatos incompatíveis imediatamente.
2. **Pontuação de Especificidade:**
   - Match Exato de Atributo (ex: `Weapon: KATANA` quando equipada): **+10 Pontos**.
   - Match Genérico (`Weapon: ANY`): **+0 Pontos**.
   - Prioridade de Chain (Combo): **+20 Pontos**.

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
