# Ramo de Comportamento (Behavior Branch)

> **Resources:** `Compose`, `ContextDefinitions`, `BehaviorData` > **Foco:** Definição Macro do Personagem ("O que eu sou?").

---

## 1. Compose (`ComposeResource`)

O **Compose** é o recurso raiz de comportamento. Ele define o " Moveset" ou a "Personalidade" atual.

### Estrutura do Recurso:

- **Default State:** O estado padrão (normalmente `Idle`).
- **States List:** Lista plana de todos os `State` resources disponíveis.
- **Tag:** Identificador do compose (ex: `Compose.Longsword`).

### Indexação Automática (Hash Generation)

Ao salvar um `Compose` no editor, um script `@tool` roda e gera o **Inverted Index**.
Ele varre a lista de States, lê seus `Requirements` e cria um dicionário otimizado para lookup em tempo real.

- _Objetivo:_ Evitar iterar arrays durante o gameplay.

## 2. Contexto (Context Logic)

O comportamento é guiado pelo Contexto.
Não existem transições hardcoded. Existe mudança de Contexto.

### Categorias Padrão:

1. **Motion:** O estado físico de movimento (ANDANDO, PULANDO, CAINDO).
2. **Activity:** O que estou fazendo (ATACANDO, USANDO_ITEM).
3. **Environment:** O que está ao redor (PAREDE, ESCADA, ÁGUA).
4. **Vitality:** Estado de vida (VIVO, MORTO, STUNNED).

### Regras de Ouro:

- O `Behavior` node é o único que tem permissão para escrever no Contexto.
- A `Machine` tem permissão apenas de LEITURA.

## 3. Blackboard (Memória de Curto Prazo)

Para dados que não cabem no Contexto (que aceita apenas Inteiros/Enums), usamos o Blackboard.
Isso fica no ramo de comportamento pois é dados voláteis de execução.

- _Uso:_ Guardar o `Target` atual (Node3D), guardar a `LastAttackTime` (float).
