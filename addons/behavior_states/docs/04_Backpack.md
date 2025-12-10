# Backpack Node — O Inventário Vivo

> **Propósito:** Gerenciar Itens, Equipamentos e a Modificação Dinâmica do Comportamento (`Compose`).

---

## 1. O Conceito de Backpack

O Node `Backpack` é o elo entre o sistema de Inventário (Itens) e o sistema de Comportamento (Behavior/Machine).
Ele não apenas "guarda coisas", ele decide **o que o personagem pode fazer** com base no que ele segura.

## 2. Slots de Equipamento

O Backpack define slots semânticos:

- `MainHand` (Espada, Machado)
- `OffHand` (Escudo, Tocha)
- `Head`, `Body`, `Feet` (Armadura)

## 3. Hot-Swapping de Comportamento

Esta é a funcionalidade mais crítica.
Quando um Item do tipo `Weapon` é equipado na `MainHand`:

1. O Backpack lê o recurso `Compose` dentro do Item (`Longsword_Compose.tres`).
2. Ele **injeta** esse Compose na `Machine`.
3. Imediatamente, o personagem perde acesso aos ataques antigos e ganha os novos (ex: Slash, Parry).

### Fluxo de Código:

```gdscript
func equip(item: ItemResource):
    if item.type == ItemType.WEAPON:
        machine.set_compose(item.compose_data)
        behavior.set_context(Context.WEAPON, item.weapon_id)
```

## 4. Integração com Stats

O Backpack também soma os modificadores de atributos dos itens equipados e atualiza o `CharacterSheet` no `Behavior`.

- _Ex:_ Bota (+10 Speed) -> `behavior.sheet.speed += 10`.

## 5. Persistência

O Backpack é serializável. Ao salvar o jogo, salvamos apenas a lista de IDs dos itens e seus slots. Ao carregar, o Backpack re-instancia e re-injeta os Composes.
