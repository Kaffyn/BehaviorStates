# Ramo de Itens (Item Branch)

> **Resources:** `Item`, `EquipmentSlot`, `LootTable` > **Foco:** A posse material e sua influência no comportamento.

---

## 1. Item (`ItemResource`)

Define um objeto no mundo do jogo.

### Composição do Item:

1. **Identity:** Nome, Ícone, Descrição, Peso, Preço.
2. **Behavior Provider:** (Opcional) Referência a um `ComposeResource`.
   - Se este item for equipado, ele _sobrescreve_ ou _adiciona_ habilidades ao personagem?
   - No BehaviorStates atual, focamos em _Weapon Injection_: A arma define o moveset.
3. **Stat Modifiers:** Lista de modificadores passivos.
   - `{ "Strength": +5, "Speed": -2 }`.

## 2. Tipos de Item

- **Weapon:** Carrega um `Compose` complexo (Ataques, Parries).
- **Consumable:** Carrega um `Effect` instantâneo (Cura) e é destruído ao usar.
- **Armor:** Carrega apenas `Stat Modifiers`.
- **Quest/Key:** Apenas Tags (`Key.Dungeon1`), sem lógica de stats.

## 3. O Fluxo de Equipar

1. **Input:** Jogador clica na Espada no UI de Inventário.
2. **Backpack:** Move o `ItemResource` para o slot `Hand`.
3. **Behavior Update:**
   - Backpack lê `item.compose`.
   - Envia para `Machine.set_compose()`.
   - Lê `item.modifiers`.
   - Envia para `Behavior.add_modifiers()`.
4. **Visual:** O `Backpack` também emite sinal para o `VisualManager` trocar a mesh da arma na mão do boneco.

---

## 4. Loot Tables

Recursos que definem drops.

- Lista ponderada de `ItemResources`.
- Método `roll()` retorna um Item aleatório baseada na raridade.
