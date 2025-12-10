# Editor Workbench — A Forja

> **Propósito:** Descrever as ferramentas de editor (Addons) que aceleram o fluxo de trabalho do MGAS.

---

## 1. Visão Geral

O MGAS adiciona um **Bottom Panel** chamado "Behavior".
Ele é dividido em 3 abas principais: **Library**, **Factory** e **Debugger**.

---

## 2. Tab: Library (O Grimório)

Godot FileSystem é ótimo para arquivos, mas ruim para _Lógica_. A Library é uma view filtrada.

### Funcionalidades:

- **Filtro Inteligente:** Mostra apenas `.tres` que herdam de `GameplayAbility`, `GameplayEffect` ou `AttributeSet`.
- **Drag & Drop:** Arraste uma Habilidade da Library direto para o array `GrantedAbilities` no Inspector de um personagem.
- **Categorização:** Agrupa recursos por pasta ou por Tags (se o resource tiver tags definidas).
- **Quick Edit:** Clique duplo abre o Inspector nativo, mas mantém a Library focada.

---

## 3. Tab: Factory (A Fábrica)

Criar Resources manualmente (Right Click -> New -> Resource -> Busca -> Digita Nome) é lento.

### Workflow na Factory:

1. **Tipo:** Selecione "Ability", "Effect" ou "AttributeSet".
2. **Template:** Escolha "Melee Attack", "Projectile Spell", "Simple Buff", "Periodic Damage".
3. **Nome:** Digite "Fireball".
4. **Create:** O sistema gera:
   - `fireball_data.tres` (Configurado com defaults do template).
   - `fireball_logic.gd` (Script herdando de GameplayAbility com boilerplate `_activate_ability` pronto).

---

## 4. Tab: Debugger (O Monitor)

Só funciona quando o jogo está rodando.

### 4.1. Entity Selection

Um dropdown lista todos os `AbilitySystemComponent` ativos na cena (`Player`, `Goblin_1`, `Goblin_2`).

### 4.2. Paineis de Inspeção

- **Tags:** Nuvem de tags ativas naquele frame. Tags piscam quando adicionadas/removidas.
- **Attributes:** Tabela com colunas `Base`, `Current` e `Modifier Breakdown`.
  - _Ex:_ Health: 80 (Base: 100, Mods: [-20 from Poison]).
- **Active Effects:** Lista de GEs com barra de progresso de duração e ícone da stack count.
- **Event Log:** Console dedicado para logs de combate ("Ability Fireball activated", "Effect Poison applied").

---

_MGAS — Editor Workbench v1.0_
