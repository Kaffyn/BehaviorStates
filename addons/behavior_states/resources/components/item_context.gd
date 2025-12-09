## ItemContext — Contexto de execução para ItemComponents.
##
## Fornece acesso ao inventário, personagem e item atual.
class_name ItemContext extends RefCounted

## Referência ao item sendo usado/equipado
var item: Resource = null

## Referência ao CharacterSheet do usuário
var character_sheet: Resource = null

## Referência ao Inventory
var inventory: Resource = null

## Referência ao Behavior (para aplicar efeitos)
var behavior: Node = null

## Slot onde o item está equipado (se aplicável)
var equip_slot: String = ""

## Quantidade sendo usada (para consumíveis stackáveis)
var use_quantity: int = 1

## Inicializa o contexto
func setup(p_item: Resource, p_character: Resource, p_inventory: Resource = null, p_behavior: Node = null) -> void:
	item = p_item
	character_sheet = p_character
	inventory = p_inventory
	behavior = p_behavior
