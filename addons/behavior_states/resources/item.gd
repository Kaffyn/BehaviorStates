@tool
## Item - Wrapper de Dados de Equipamento
##
## Carrega um Compose que é "montado" na Machine ao equipar este item.
## Suporta durabilidade, consumíveis, efeitos e crafting.
class_name Item extends Resource

enum Category { WEAPON, CONSUMABLE, MATERIAL, ARMOR, ACCESSORY, KEY }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

# ============= IDENTITY =============
@export_group("Identity")
## Identificador único do item.
@export var id: String = ""
## Nome de exibição.
@export var name: String = "Item"
## Descrição do item.
@export_multiline var description: String = ""
## Ícone do item.
@export var icon: Texture2D
## Tipo do item para filtros.
@export var category: Category = Category.MATERIAL
## Raridade (afeta cor do nome, drop rate, etc.)
@export var rarity: Rarity = Rarity.COMMON

# ============= STACKING =============
@export_group("Stacking")
## Se o item pode ser empilhado.
@export var stackable: bool = false
## Quantidade atual na pilha.
@export var quantity: int = 1
## Quantidade máxima por pilha.
@export var max_stack: int = 99

# ============= DURABILITY =============
@export_group("Durability")
## Se o item tem durabilidade (quebra com uso).
@export var has_durability: bool = false
## Durabilidade atual.
@export var durability: int = 100
## Durabilidade máxima.
@export var max_durability: int = 100

# ============= CONSUMABLE =============
@export_group("Consumable")
## Se o item é consumível (some ao usar).
@export var consumable: bool = false
## Efeitos aplicados ao consumir.
@export var use_effects: Array[Effects] = []

# ============= EQUIPMENT =============
@export_group("Equipment")
## Compose que é montado ao equipar este item (Moveset).
@export var compose: Compose
## Efeitos passivos enquanto equipado.
@export var equip_effects: Array[Effects] = []
## Slot de equipamento (para Armor/Accessory).
@export_enum("None", "MainHand", "OffHand", "Head", "Chest", "Legs", "Feet", "Ring", "Amulet") var equip_slot: int = 0

# ============= CRAFTING =============
@export_group("Crafting")
## Receita de crafting: { Item.id: quantidade }
@export var craft_recipe: Dictionary = {}
## Tempo de craft em segundos.
@export var craft_time: float = 0.0
## Estação necessária para craft (ex: "Anvil", "Furnace", "Workbench").
@export var required_station: String = ""
## Quantidade produzida por craft.
@export var craft_output_quantity: int = 1

# ============= ECONOMY =============
@export_group("Economy")
## Valor de venda.
@export var sell_price: int = 0
## Valor de compra (0 = não comprável).
@export var buy_price: int = 0

# ============= LOGIC =============

func can_stack_with(other: Item) -> bool:
	if not stackable or not other.stackable:
		return false
	return id == other.id and quantity + other.quantity <= max_stack

## Usa o item (consome se consumível).
## Retorna true se usado com sucesso.
func use(target: Resource = null) -> bool:
	if consumable:
		# Apply use effects
		for effect in use_effects:
			if effect and target:
				effect.apply(target)
		
		quantity -= 1
		return true
	
	return false

## Equipa o item, retornando o Compose e aplicando efeitos passivos.
func equip(target: Resource = null) -> Compose:
	# Apply equip effects
	for effect in equip_effects:
		if effect and target:
			effect.apply(target)
	
	return compose

## Desequipa o item, removendo efeitos passivos.
func unequip(target: Resource = null) -> void:
	# Remove equip effects
	for effect in equip_effects:
		if effect and target:
			effect.remove(target)

## Reduz durabilidade. Retorna true se quebrou.
func damage(amount: int = 1) -> bool:
	if not has_durability:
		return false
	
	durability = max(0, durability - amount)
	return durability <= 0

## Repara o item.
func repair(amount: int = -1) -> void:
	if amount < 0:
		durability = max_durability
	else:
		durability = min(max_durability, durability + amount)

## Verifica se pode craftar este item.
func can_craft(inventory: Resource) -> bool:
	if craft_recipe.is_empty():
		return false
	
	if not inventory or not "items" in inventory:
		return false
	
	for item_id in craft_recipe:
		var required = craft_recipe[item_id]
		var found = 0
		for item in inventory.items:
			if item and item.id == item_id:
				found += item.quantity
		if found < required:
			return false
	
	return true

## Retorna cor baseada na raridade.
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.GREEN
		Rarity.RARE: return Color.BLUE
		Rarity.EPIC: return Color.PURPLE
		Rarity.LEGENDARY: return Color.ORANGE
	return Color.WHITE
