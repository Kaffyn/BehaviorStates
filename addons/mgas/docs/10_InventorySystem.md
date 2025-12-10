# Inventory & Items — O Arsenal

> **Propósito:** Explicar como o sistema de Itens se integra ao MGAS para conceder Habilidades e Atributos dinamicamente.

---

## 1. Filosofia: Item como Provedor de Habilidade

No MGAS, um item não é apenas um ícone na mochila. Ele é um **Pacote de Habilidades Latentes**.
Ao equipar uma *Espada de Fogo*, o personagem não "vira um espadachim"; ele apenas recebe temporariamente:
1. **GA_MeleeAttack:** A habilidade de bater.
2. **GE_FireSwordStats:** O efeito que dá +10 de Força e +5 de FireDamage.
3. **Tags:** `Weapon.Melee.Sword`, `Element.Fire`.

Ao desequipar, tudo isso é revogado limpo pelo ASC.

---

## 2. Arquitetura de Dados

Separamos a definição estática da instância dinâmica para suportar milhares de itens sem estourar a RAM.

### 2.1. ItemDefinition (Resource)
O "Molde" do item. Dados que nunca mudam.

```gdscript
class_name MachiItemDefinition extends Resource

@export_group("Identity")
@export var id: StringName
@export var name: String
@export var icon: Texture2D

@export_group("GAS Integration")
# Habilidades que o item concede ao ser equipado
@export var granted_abilities: Array[MachiGameplayAbility]
# Efeitos passivos aplicados ao ser equipado
@export var granted_effects: Array[MachiGameplayEffect]
# Tags que o item possui (ex: Item.Type.Weapon)
@export var item_tags: GameplayTagContainer
```

### 2.2. ItemInstance (Ref)
O objeto real no inventário. Pode ter estado mutável.

```gdscript
class_name MachiItemInstance extends RefCounted

var definition: MachiItemDefinition
var stack_count: int = 1
var dynamic_tags: GameplayTagContainer # ex: Enhanced, Cursed

# Integração GAS (Runtime)
# Handles para remover abilities/effects ao desequipar
var granted_ability_handles: Array[AbilitySpecHandle]
var granted_effect_handles: Array[ActiveEffectHandle]

func get_attribute_value(attribute_name: StringName) -> float:
   # Lógica para ler atributos randômicos (ex: Diablo loot)
   return 0.0
```

---

## 3. InventoryComponent (O Container)

Um Node que gerencia a lista de `ItemInstance`. Não processa física, apenas dados.

### Responsabilidades:
1. **Armazenamento:** Lista de slots ou Grid.
2. **Transação:** Add, Remove, Split Stack, Merge Stack.
3. **Equipamento:** Move item do "Backpack" para "EquipmentSlot".

```gdscript
class_name InventoryComponent extends Node

@export var asc: MachiAbilitySystemComponent
@export var capacity: int = 24

var items: Array[MachiItemInstance]
var equipment: Dictionary = {} # { "Hand_R": Instance, "Head": Instance }

func equip_item(item: MachiItemInstance, slot: StringName):
    # 1. Remove item anterior (Unequip)
    if equipment.has(slot):
        unequip_item(slot)
    
    # 2. Concede Habilidades ao ASC
    for ability in item.definition.granted_abilities:
        var handle = asc.give_ability(ability)
        item.granted_ability_handles.append(handle)
        
    # 3. Aplica Efeitos Passivos
    for effect in item.definition.granted_effects:
        var handle = asc.apply_gameplay_effect_to_self(effect)
        item.granted_effect_handles.append(handle)
        
    equipment[slot] = item
```

---

## 4. Integração com GameplayTags

O inventário usa Tags para filtrar compatibilidade (Slots).

*   **Slot:** `Equipment.Slot.Hand.Right`
*   **Item:** Deve ter tag compatível (ex: `Item.Type.Weapon`).

Isso evita `if item.type == SWORD` e permite regras flexíveis:
*   "Posso equipar esta Gema na Espada?" -> Se Espada tiver Slot `Socket` e Gema tiver Tag `Item.Gem`.

---

## 5. Loot e Drop (WorldItem)

Como um Item sai do chão e vai para o Inventário?

1. **WorldItem (Node3D/2D):** Representação física. Tem um `CollisionShape` e um `ItemInstance` dentro.
2. **Interaction:** Jogador interage (GA_Interact).
3. **Pickup:**
    *   O `InventoryComponent` do jogador recebe a `ItemInstance`.
    *   O `WorldItem` é `queue_free()`.

---

## 6. Exemplo de Fluxo: A "Bota de Velocidade"

1. **Definição:** `BootsOfSpeed.tres`
    *   `GrantedEffects`: `GE_SpeedBuff` (+50 Speed).
2. **Equip:** Jogador equipa no slot `Feet`.
3. **InventoryComponent:**
    *   Chama `asc.apply_gameplay_effect(GE_SpeedBuff)`.
    *   O atributo `MoveSpeed` do jogador sobe para 450.
    *   Armazena o `ActiveHandle` na instância da bota.
4. **Unequip:** Jogador tira a bota.
    *   `InventoryComponent` chama `asc.remove_active_effect(handle)`.
    *   O atributo `MoveSpeed` cai para 300 (Base).

---

_MGAS — Inventory System v1.0_
