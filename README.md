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

O Painel `BehaviorStates` transforma o editor em um workspace poderoso.

- **A Asset Library:** Um repositório inteligente que indexa todo Recurso de Comportamento no projeto. Suporta tags de metadados ("Agressivo", "Mágico") e filtros instantâneos.
- **O Behavior Graph:** Um ambiente de script visual baseado em nós para definir:
  - **Cadeias de Transição:** Linkar visualmente `Ataque_A` para `Ataque_B` com arestas condicionais.
  - **Lógica de Interrupção:** Definir overrides de prioridade visualmente.
- **A Factory:** Um wizard baseado em templates que gera código boilerplate e resources, forçando consistência arquitetural automaticamente.
- **O Live Debugger:** Ferramentas de análise em runtime:
  - **Viagem no Tempo:** Gravar e navegar pelos últimos 60 segundos de decisões.
  - **Heatmap:** Visualizar frequência de estados.
  - **Live Sync:** O grafo destaca o nó ativo em tempo real.

---

## 2. API de Dados (The DNA)

Scripts que estendem `Resource`. São a "Memória" do sistema. A estrutura abaixo detalha as propriedades principais de cada classe.

### 2.1. `BehaviorUnit` (State.gd)

A unidade atômica de comportamento. Define "O que acontece" e "Quando acontece".

#### Propriedades Exportadas

**Core Identity & Visuals**

- `name: String`
- `texture: Texture2D`
- `animation_res: Animation`
- `loop: bool`
- `debug_color: Color`

**Logica de Filtro (Context-Aware)**
Define os **Requisitos de Entrada** via um Dicionário de Tags.

```gdscript
@export var requirements: Dictionary = {
    "motion": BehaviorStates.Motion.ANY,
    "weapon": BehaviorStates.Weapon.KATANA,
    "physics": BehaviorStates.Physics.GROUND
}
```

**Física e Movimento**

- `speed_multiplier: float`: Multiplica a velocidade base do CharacterSheet.
- `jump_force: float`: Força de impulso vertical.
- `friction: float`: Controle de parada.
- `lock_movement: bool`: Impede input de movimento durante o estado.
- `ignore_gravity: bool`: Útil para dashes aéreos ou skills de voo.

**Combate (Melee & Ranged)**

- `damage: int`: Valor base de dano.
- `cooldown: float`: Tempo antes de poder reentrar neste contexto.
- `projectile_scene: PackedScene`: Cena instanciada para ataques à distância.
- `projectile_speed: float`
- `spawn_offset: Vector2`

**Ciclo de Vida (Hooks)**

- `Enter()`: Aplica modificadores, toca animação.
- `Exit()`: Limpa modificadores.
- `Update(delta)`: Lógica frame a frame.
- `PhysicsUpdate(delta)`: Lógica de física (ex: Homing Missile).

### 2.2. `BehaviorManifest` (Compose.gd)

O "Deck" de estados. Responsável por agrupar e indexar os estados.

- **Storage:** Mantém arrays de States (`move_states`, `attack_states`, `interactive_states`).
- **Indexação (`@tool`):** Constrói os HashMaps (`move_rules`, `attack_rules`) em tempo de edição.
- **Herança:** Suporta empilhamento de Manifestos.

### 2.3. Containers Semânticos

#### `ItemData` e `WeaponData`

Wrappers que carregam um Manifesto.

- `display_name: String`
- `icon: Texture2D`
- `compose: BehaviorManifest`: O comportamento conferido ao equipar.
- `context_modifiers: Dictionary`: Tags passivas (ex: `Weapon: KATANA`) que este item ativa no Contexto Global.

#### `CharacterSheet`

A "Ficha" de RPG.

- `max_health`, `max_stamina`
- `base_speed`, `base_jump_force`
- `attributes: Dictionary` (ex: Força, Agilidade).

---

## 3. Componentes de Runtime (The Nodes)

### 3.1. `Behavior.gd` (O Cérebro)

O nó de processamento de intenção. Fica na raiz do personagem.

- **Responsabilidade:** Traduzir `Input` -> `Contexto`.
- **Input Buffering:** Implementa Coyote Time e Queue de Ações.
- **Orquestração:** Controla a `Machine` e o `Inventory`.
- **Código Exemplo:**

  ```gdscript
  func _physics_process(delta):
      # Traduz Input para Contexto
      if Input.is_action_pressed("run"):
          machine.set_context("Motion", BehaviorStates.Motion.RUN)

      # Gerencia Gravidade e Movimento Físico
      _handle_physics()
  ```

### 3.2. `Machine.gd` (A Engine VM)

O processador de decisão puro. Não sabe o que é um "Player" ou "Input".

- **Query Engine:** Executa a busca O(1).
- **Interpretador:** Funciona como uma VM com instruções especializadas:
  - `apply_velocity(Vector2)`
  - `spawn_projectile(PackedScene)`
  - `play_animation(String)`
- **Event Bus:** `signal state_changed(old, new)`

### 3.3. `Inventory.gd` (Gerenciador de Equipamento)

- Gerencia slots de itens e equipa/desequipa.
- Notifica a Machine para trocar o Manifesto ativo em O(1).
- **Fallback Logic:** Se você tenta atacar com uma Potion e ela não tem estado de ataque, o Inventory fornece o Manifesto "Unharmed" (Desarmado) para garantir que um soco saia.

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
