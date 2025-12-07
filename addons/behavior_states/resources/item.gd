## Item - Wrapper de Dados de Equipamento
##
## Carrega um Compose que é "montado" na Machine ao equipar este item.
class_name Item extends Resource

@export_group("Identity")
## Identificador único do item.
@export var id: String = ""
## Nome de exibição.
@export var name: String = "Item"
## Descrição do item.
@export_multiline var description: String = ""
## Ícone do item.
@export var icon: Texture2D

@export_group("Stacking")
## Se o item pode ser empilhado.
@export var stackable: bool = false
## Quantidade atual na pilha.
@export var quantity: int = 1
## Quantidade máxima por pilha.
@export var max_stack: int = 99

@export_group("Behavior")
## Compose que é montado ao equipar este item.
@export var compose: Compose

@export_group("Category")
## Tipo do item para filtros.
@export_enum("Weapon", "Consumable", "Material", "Armor", "Accessory", "Key") var category: int = 0

@export_group("Stats")
## Valor de venda.
@export var sell_price: int = 0
## Raridade (0-4: Common, Uncommon, Rare, Epic, Legendary).
@export_range(0, 4) var rarity: int = 0

func can_stack_with(other: Item) -> bool:
	if not stackable or not other.stackable:
		return false
	return id == other.id and quantity + other.quantity <= max_stack

func use() -> bool:
	# Override in subclasses
	return false

func equip() -> Compose:
	return compose
