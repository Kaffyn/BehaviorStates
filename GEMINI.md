# Godot MBA: O Grimório do Arquiteto

> **Contexto:** Este documento é a "Bíblia" técnica para o desenvolvimento do curso **Godot MBA**. Ele define os pilares da nossa arquitetura e serve como referência absoluta para Agentes de IA e Alunos.

---

## 1. Paradigmas de Desenvolvimento

Para construir sistemas complexos, precisamos entender as ferramentas conceituais à nossa disposição.

### 1.1. Orientação a Objetos (OOP)

**"O Comportamento define o Objeto."**

Na OOP clássica, focamos em **Classes** que encapsulam dados e métodos.

- **Herança:** "Um `Guerreiro` **é um** `Personagem`".
- **Encapsulamento:** O `Guerreiro` protege sua vida (`private health`) e oferece métodos (`take_damage()`).
- **Polimorfismo:** Tratamos `Guerreiro` e `Mago` como `Personagem`, chamando `atacar()` sem saber qual classe específica é.

**Na Godot:**

- Todo Node (`CharacterBody2D`, `Sprite2D`) é um Objeto.
- Scripts `.gd` são Classes.
- Usamos OOP para a **Lógica de Controle** (Controllers, Managers, Machines).

### 1.2. Orientação a Dados (DOP)

**"A Memória define a Performance."**

Na DOP, focamos em como os dados são organizados na memória para otimizar o acesso da CPU (Cache Locality). Em vez de `Array[Objeto]`, preferimos `Array[Int]`, `Array[Vector2]`.

- **ECS (Entity Component System):** Separação total entre Dados (Componentes) e Lógica (Sistemas).

**Na Godot:**

- Usamos `Servers` (`PhysicsServer2D`, `RenderingServer`) para alta performance.
- Usamos `PackedFloat32Array` para grandes volumes de dados numéricos.

### 1.3. Orientação a Resources (ROP)

**"O Machi Way: Onde Dados viram Comportamento."**

O **Resource-Oriented Programming (ROP)** é o "pulo do gato" da Godot. É um híbrido poderoso entre OOP e DOP.

- **Definição:** Resources são objetos de dados serializáveis (`.tres`) que podem conter lógica pura (helper functions).
- **Compartilhamento:** Se 1000 Goblins usam o mesmo `goblin_stats.tres`, eles compartilham a mesma instância na memória RAM.
- **Injeção:** Nodes (Comportamento) recebem Resources (Configuração) para saber o que fazer.

**Diferença Chave:**

- **OOP:** O `Guerreiro` tem `var damage = 10` hardcoded no script.
- **ROP:** O `Guerreiro` tem `var stats: CharacterSheet`. O valor `10` vive num arquivo `.tres` que pode ser trocado em tempo real.

---

## 2. Fundamentos da Godot

### 2.1. Herança e `extends`

Em GDScript, a herança é a base da reutilização de código de _comportamento_.

```gdscript
# entity.gd
class_name Entity extends CharacterBody2D

func take_damage(amount: int):
    print("Entity took damage")

# player.gd
class_name Player extends Entity

# Sobrescreve o comportamento do pai
func take_damage(amount: int):
    super(amount) # Chama a lógica do pai
    HUD.shake_screen() # Adiciona comportamento específico
```

### 2.2. Autoloads (Singletons)

São Nodes que a Godot carrega automaticamente na raiz (`/root/`) ao iniciar o jogo. Eles persistem entre trocas de cena.

**Quando usar:**

- Gerenciadores Globais (`SoundManager`, `SaveSystem`, `GameSettings`).
- Dados de Sessão (`SessionData`).
- Vocabulários Globais (`BehaviorStates.gd`).

**Quando NÃO usar:**

- Para passar dados entre Player e Inimigo (Use Sinais ou Resources).
- Para lógica de gameplay específica de uma cena.

---

## 3. O Framework: BehaviorStates

O **BehaviorStates** é a infraestrutura proprietária do Machi para criar Sistemas de Comportamento Reativos e Orientados a Dados. Ele substitui Máquinas de Estado Finitas (FSM) por **Sistemas de Query Contextual (Query vs Transition)**.

### 3.1. Arquitetura do Framework

A estrutura reflete a separação entre Cérebro, Engine e Dados:

```text
addons/behavior_states/
├── assets/                # Ícones e Temas
├── nodes/                 # Componentes de Runtime (Behavior, Machine)
├── resources/             # DNA (State, Compose, Skill, Item)
│   ├── blocks/            # Blocos lógicos
│   ├── skill.gd           # Definição Stateless
│   └── state.gd
└── scenes/                # Editor Tools
    ├── components/        # UI Widgets (AssetCard)
    └── tabs/              # Abas do Painel
        ├── library.tscn   # Grid View
        ├── editor.tscn    # Blueprint View
        └── factory.tscn   # Wizards
```

### 3.2. Fluxo de Execução

```mermaid
graph TD
    Input[Input Bruto] -->|1. Traduz| Brain[Behavior (Node)]
    Brain -->|2. Contexto| Machine[Machine (VM)]
    Machine -->|3. Query| Manifest[Manifest (Index)]

    subgraph "Ciclo de Decisão O(1)"
        Manifest -- Lookup Hash --> Candidates[Lista Filtrada]
        Machine -- Fuzzy Score --> BestUnit[BehaviorUnit]
    end

    Machine -->|4. Executa| Actor[Avatar]

    BestUnit -- Apply Physics --> Actor
    BestUnit -- Spawn FX --> Actor
```

### 3.3. Os Componentes (Passo a Passo)

#### 1. Criar as Unidades (`BehaviorUnit`)

No FileSystem ou via **Factory**, crie arquivos `.tres` para comportamento:

- `Slash_Light.tres` (Attack Unit)
- `Run_Fast.tres` (Move Unit)

No Inspector (agora turbinado pelo **Workbench**), defina os **Requisitos**:

- `req_motion: RUN`
- `req_weapon: KATANA`

#### 2. Criar os Composes

Agrupe as unidades em "Decks". Ex: `Katana_Moveset.tres`.
O sistema indexará automaticamente (`@tool`) para lookups O(1).

#### 3. Configurar o Personagem (`Behavior Node`)

No nó raiz do personagem, adicione o nó `Behavior`. Ele orquestrará a `Machine` e o `Inventory`.

#### 4. O Código do Personagem (Semântico)

O `Player.gd` não sabe o que é "Atacar com Espada". Ele apenas comunica intenção.

```gdscript
# Player.gd (Semântico e Limpo)
func _physics_process(delta):
    # 1. Input -> Semântica
    if Input.is_action_pressed("fire"):
        # "Quero atacar, não me importo como"
        behavior.set_context("Attack", BehaviorStates.Attack.NORMAL)

    # 2. A Engine resolve O QUE fazer baseada na Arma equipada
    # (Ex: Disparar Flecha ou Dar Espadada)
```

### 3.4. Diferenciais BehaviorStates

1. **Workbench Integrada:** Uma IDE completa dentro da Godot. **Behavior Graph** para script visual de combos e prioridades, e **Live Debugger** com viagem no tempo.
2. **VM vs Hardcode:** A `Machine` é uma Virtual Machine com instruções especializadas. O Resource dita a instrução, a Machine executa. Zero código customizado no estado.
3. **Roadmap Nativo:** Projetado em GDScript hoje, preparado para ser portado para Rust (GDExtension) e C++ (Module) amanhã.

### 3.5. Otimização O(1) (HashMap)

Para evitar loops lineares (`O(N)`) a cada frame, o sistema utiliza **Indexação Invertida**:

1. **Index Time:** O `Manifest` cria buckets: `Attack = [Slash1, Slash2]`.
2. **Query Time:** A Machine acessa `Index[Attack]` diretamente.
3. **Resultado:** Busca constante, independente de ter 10 ou 1000 habilidades.

---

## 4. Mapa do Conhecimento (Índice de Arquivos)

Para onde ir se você quiser aprender sobre...

### Framework Visionário

- **`README.md`**: A Fonte da Verdade. Visão, Arquitetura e Referência Técnica unificadas.
- **`EMENTA.md`**: O Syllabus do curso Godot MBA, refletindo a estrutura de aprendizado.

### Fundamentos

- **`01_GodotFundamentals.md`**: Tipagem, Sinais e Ciclo de Vida.
- **`03_Singletons.md`**: Quando usar (e não usar) Autoloads.

### ROP e Arquitetura

- **`02_ResourceOrientedProgramming.md`**: A fundação de dados vs lógica.
- **`05_StateMachines.md`**: Da FSM clássica ao BehaviorStates.

### Avançado

- **`14_GDExtensions.md`**: Performance com C++/Rust.

---

Este é o seu arsenal. Use-o para construir não apenas jogos, mas sistemas de engenharia robustos e belos.
**Machi out.**
